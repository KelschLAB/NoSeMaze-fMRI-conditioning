function [lick_params,histogram_data] = compute_impulsivity_ICON(d,phase_cutoff,ntrials_before_reversal)
%% This function computes the learning parameters from lick data
%   Compute different metrics of impulsivity, based on Dalley, Everitt,
%   Robbins (Neuron, 2011)
%
%       1: modified "premature responding", that is if the animals lick
%       impulsively upon odor onset (separate CS+/- and pooled)
%       2: modified "ntrials" as the number of trials before the reversal
%       to account and figure
%       3: added histogram data (JR)
%
% David Wolf, 12/2023
%%
lick_params = struct;
histogram_data = struct;

for an = 1:numel(d)
    
    gng_data = d(an).events; %data_0007AC2B02;
    lick_params(an).ID = gng_data(1).ID;
    % lick_params(an).groupID = 
    % perform quality checks on the input data
    assert(numel(unique({gng_data.ID}))==1);


    %% Data Cleaning: minimum lick-timestamp difference = 50ms
    for tr = 1:numel(gng_data)

       all_trial_licks = cat(2, gng_data(tr).licks_bef_od, gng_data(tr).licks_aft_od);
    %    for lc = 1:numel(all_trial_licks)
       lc = 1;
       while lc<=numel(all_trial_licks)
          curr_diff = all_trial_licks-all_trial_licks(lc);
          all_trial_licks = all_trial_licks(~(curr_diff>0 & curr_diff<0.05));
          lc=lc+1;
       end

       gng_data(tr).licks_bef_od = all_trial_licks(all_trial_licks<0.5);
       gng_data(tr).licks_aft_od = all_trial_licks(all_trial_licks>=0.5);

    end

    %% Remove data after phase cutoff
    gng_data([gng_data.phase]'>phase_cutoff) = [];

    %% average lick-rate (Hz) during baseline (0 to 0.5s after trial-start)
    % subselect = (cell2mat(cellfun(@isempty, {gng_data(:).licks_bef_od},'UniformOutput',0)) & ...
    % cell2mat(cellfun(@isempty, {gng_data(:).licks_aft_od},'UniformOutput',0)));

    baseline_licks = {gng_data(:).licks_bef_od};
    lick_params(an).baseline_rate_mean = mean(cell2mat(cellfun(@numel, baseline_licks,'UniformOutput',0)).*2);

    baseline_licks = cellfun(@(x) x(x>0.05),baseline_licks,'UniformOutput',0);
    lick_params(an).baseline_rate_mean_omitfirst = mean(cell2mat(cellfun(@numel, baseline_licks,'UniformOutput',0)).*(1./0.45));


    %% Peak lick at odor onset
    % ntrials_before_reversal defines the number of trials before reversal respectively
    reversal_index = [1,find(diff([gng_data.phase])==1)+1];
    cs_plus_trials_before_reversal = []; cs_minus_trials_before_reversal = [];
    for rev = 2:numel(reversal_index)
        cs_plus_trials_before_reversal = cat(1, cs_plus_trials_before_reversal, reversal_index(rev-1)-1+find([gng_data(reversal_index(rev-1):reversal_index(rev)).reward]==1,ntrials_before_reversal,'last')');
        cs_minus_trials_before_reversal = cat(1, cs_minus_trials_before_reversal, reversal_index(rev-1)-1+find([gng_data(reversal_index(rev-1):reversal_index(rev)).reward]==0,ntrials_before_reversal,'last')');
    end

    % baseline_licks in the 150 trials before reversal
    baseline_licks = {gng_data(cs_minus_trials_before_reversal).licks_bef_od};
    lick_params(an).baseline_rate_CSminus_mean = mean(cell2mat(cellfun(@numel, baseline_licks,'UniformOutput',0)).*2);
    baseline_licks = cellfun(@(x) x(x>0.05),baseline_licks,'UniformOutput',0);
    lick_params(an).baseline_rate_CSminus_mean_omitfirst = mean(cell2mat(cellfun(@numel, baseline_licks,'UniformOutput',0)).*(1./0.45));
    baseline_licks = {gng_data(cs_plus_trials_before_reversal).licks_bef_od};
    lick_params(an).baseline_rate_CSplus_mean = mean(cell2mat(cellfun(@numel, baseline_licks,'UniformOutput',0)).*2);
    baseline_licks = cellfun(@(x) x(x>0.05),baseline_licks,'UniformOutput',0);
    lick_params(an).baseline_rate_CSplus_mean_omitfirst = mean(cell2mat(cellfun(@numel, baseline_licks,'UniformOutput',0)).*(1./0.45));    
    
    % get lick counts in 0.5 to 0.6s window (odor onset)
    cs_plus_lick_count = []; cs_minus_lick_count = []; 
    edges = 0.5:0.1:0.6; 
    for tr = 1:numel(cs_plus_trials_before_reversal)
        % high-temporal resolution psth over window
        cs_plus_lick_count = cat(1,cs_plus_lick_count, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
    end
    for tr = 1:numel(cs_minus_trials_before_reversal)
        cs_minus_lick_count = cat(1,cs_minus_lick_count, histcounts(gng_data(cs_minus_trials_before_reversal(tr)).licks_aft_od,edges));
    end

    % calculate correct rejection and reward
    correct_rejection = sum(strcmp({gng_data(cs_minus_trials_before_reversal).false_alarm},'False'))/length(cs_minus_trials_before_reversal);
    correct_reward = sum([gng_data(cs_plus_trials_before_reversal).drop_or_not])/length(cs_plus_trials_before_reversal);    
        
    % parse
    lick_params(an).lick_rate_at_odor_on_csplus = mean(cs_plus_lick_count)*10;
    lick_params(an).lick_rate_at_odor_on_csminus = mean(cs_minus_lick_count)*10;
    lick_params(an).lick_rate_at_odor_on_pooled = mean(cat(1,cs_plus_lick_count,cs_minus_lick_count))*10;
    
    lick_params(an).correct_rejection = correct_rejection;
    lick_params(an).correct_reward= correct_reward;

    lick_params(an).lick_rate_at_odor_on_csplus_to_base = (mean(cs_plus_lick_count)*10)/lick_params(an).baseline_rate_mean_omitfirst;
    lick_params(an).lick_rate_at_odor_on_csminus_to_base = (mean(cs_minus_lick_count)*10)/lick_params(an).baseline_rate_mean_omitfirst;
    lick_params(an).lick_rate_at_odor_on_pooled_to_base = (mean(cat(1,cs_plus_lick_count,cs_minus_lick_count))*10)/lick_params(an).baseline_rate_mean_omitfirst;
    
    lick_params(an).lick_rate_at_odor_on_csplus_to_base_150trials = (mean(cs_plus_lick_count)*10)/lick_params(an).baseline_rate_CSplus_mean_omitfirst;
    lick_params(an).lick_rate_at_odor_on_csminus_to_base_150trials = (mean(cs_minus_lick_count)*10)/lick_params(an).baseline_rate_CSminus_mean_omitfirst;
    lick_params(an).lick_rate_at_odor_on_pooled_to_base_150trials = (mean(cat(1,cs_plus_lick_count,cs_minus_lick_count))*10)/((lick_params(an).baseline_rate_CSplus_mean_omitfirst+lick_params(an).baseline_rate_CSminus_mean_omitfirst)/2);
    
    histogram_data(an).BinEdges = [0:0.1:3];
    histogram_data(an).BinCount_CSminus = histcounts([[gng_data(cs_minus_trials_before_reversal).licks_bef_od],[gng_data(cs_minus_trials_before_reversal).licks_aft_od]],histogram_data(an).BinEdges).*(10/length(cs_minus_trials_before_reversal));
    histogram_data(an).BinCount_CSplus = histcounts([[gng_data(cs_plus_trials_before_reversal).licks_bef_od],[gng_data(cs_plus_trials_before_reversal).licks_aft_od]],histogram_data(an).BinEdges).*(10/length(cs_plus_trials_before_reversal));
end
end

