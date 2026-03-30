function lick_params = compute_learning_parameters_ICON(d,phase_cutoff)
%% This function computes the learning parameters from lick data
%   The list of parameters to compute:
%   "\\flstorage\data\Shared\NoSeMaze\learning-analysis\possible readouts
%   112122wk_dw.xlsx"
%
%   input data is the struct containing all learning trials from a group of
%   animals (reord-data.mat)
%
%   07/23: This version is modified for the needs of Jonathan's reappraisal
%   analysis
%
% David Wolf, 12/2022
%%
lick_params = struct;

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

%% Compute "Step 1" parameters (see excel file)
%
%

%% average lick-rate (Hz) during baseline (0 to 0.5s after trial-start)
% subselect = (cell2mat(cellfun(@isempty, {gng_data(:).licks_bef_od},'UniformOutput',0)) & ...
% cell2mat(cellfun(@isempty, {gng_data(:).licks_aft_od},'UniformOutput',0)));

lick_params(an).baseline_rate_isnormal = 1-adtest(cell2mat(cellfun(@numel, {gng_data(:).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_mean = mean(cell2mat(cellfun(@numel, {gng_data(:).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_sd = std(cell2mat(cellfun(@numel, {gng_data(:).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_median = median(cell2mat(cellfun(@numel, {gng_data(:).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_quartile = quantile(cell2mat(cellfun(@numel, {gng_data(:).licks_bef_od},'UniformOutput',0)).*2, [0.25, 0.75]);

%% CS+/- lick modulation in relation to baseline for the last 150 trials
% before reversal respectively
reversal_index = [1,find(diff([gng_data.phase])==1)+1];
cs_plus_trials_before_reversal = []; cs_minus_trials_before_reversal = [];
for rev = 2:numel(reversal_index)
    cs_plus_trials_before_reversal = cat(1, cs_plus_trials_before_reversal, reversal_index(rev-1)-1+find([gng_data(reversal_index(rev-1):reversal_index(rev)).reward]==1,150,'last')');
    cs_minus_trials_before_reversal = cat(1, cs_minus_trials_before_reversal, reversal_index(rev-1)-1+find([gng_data(reversal_index(rev-1):reversal_index(rev)).reward]==0,150,'last')');
end

% baseline before reversal
lick_params(an).baseline_rate_before_reversal_isnormal = 1-adtest(cell2mat(cellfun(@numel, {gng_data([cs_plus_trials_before_reversal,cs_minus_trials_before_reversal]).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_before_reversal_mean = mean(cell2mat(cellfun(@numel, {gng_data([cs_plus_trials_before_reversal,cs_minus_trials_before_reversal]).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_before_reversal_sd = std(cell2mat(cellfun(@numel, {gng_data([cs_plus_trials_before_reversal,cs_minus_trials_before_reversal]).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_before_reversal_median = median(cell2mat(cellfun(@numel, {gng_data([cs_plus_trials_before_reversal,cs_minus_trials_before_reversal]).licks_bef_od},'UniformOutput',0)).*2);
lick_params(an).baseline_rate_before_reversal_quartile = quantile(cell2mat(cellfun(@numel, {gng_data([cs_plus_trials_before_reversal,cs_minus_trials_before_reversal]).licks_bef_od},'UniformOutput',0)).*2, [0.25, 0.75]);

% get lick counts in 0.5 to 1.5s window (first second of odor presentation)
cs_plus_lick_count = []; cs_minus_lick_count = []; cs_plus_lick_count_delta = []; cs_minus_lick_count_delta = [];
edges = 0.5:0.05:1.5; edges(1) = [];
for tr = 1:numel(cs_plus_trials_before_reversal)
    % high-temporal resolution psth over window
    cs_plus_lick_count = cat(1,cs_plus_lick_count, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
    
    % trial-by-trial delta to baseline
    cs_plus_lick_count_delta(tr) = nnz(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od<1.5)-numel(gng_data(cs_plus_trials_before_reversal(tr)).licks_bef_od).*2;
end
for tr = 1:numel(cs_minus_trials_before_reversal)
    cs_minus_lick_count = cat(1,cs_minus_lick_count, histcounts(gng_data(cs_minus_trials_before_reversal(tr)).licks_aft_od,edges));
    cs_minus_lick_count_delta(tr) = nnz(gng_data(cs_minus_trials_before_reversal(tr)).licks_aft_od<1.5)-numel(gng_data(cs_minus_trials_before_reversal(tr)).licks_bef_od).*2;
end
lick_params(an).cs_plus_modulation_averaged = mean(sum(cs_plus_lick_count,2))/lick_params(an).baseline_rate_mean;
lick_params(an).cs_minus_modulation_averaged = mean(sum(cs_minus_lick_count,2))/lick_params(an).baseline_rate_mean;
% lick_params(an).cs_plus_modulation_trialwise = median(cs_plus_lick_count_delta);
% lick_params(an).cs_minus_modulation_trialwise = median(cs_minus_lick_count_delta);
lick_params(an).cs_plus_modulation_peak_to_base = max(mean(cs_plus_lick_count,1)*20)/lick_params(an).baseline_rate_mean; % 
lick_params(an).cs_minus_modulation_peak_to_base = max(mean(cs_minus_lick_count,1)*20)/lick_params(an).baseline_rate_mean; % 
lick_params(an).cs_plus_modulation_min_to_base = min(mean(cs_plus_lick_count,1)*20)/lick_params(an).baseline_rate_mean; % 
lick_params(an).cs_minus_modulation_min_to_base = min(mean(cs_minus_lick_count,1)*20)/lick_params(an).baseline_rate_mean; % 


%% CS+ anticipation
cs_plus_lick_count = []; 
edges = 0.5:1:2.5;
for tr = 1:numel(cs_plus_trials_before_reversal)
    cs_plus_lick_count = cat(1,cs_plus_lick_count, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
end
lick_params(an).cs_plus_ramping = mean(cs_plus_lick_count(:,2))/mean(cs_plus_lick_count(:,1));

%% CS+ detection/valuation speed
cs_plus_lick_count = []; 
edges = 0.5:0.05:1.5;
for tr = 1:numel(cs_plus_trials_before_reversal)
    % high-temporal resolution psth over window
    cs_plus_lick_count = cat(1,cs_plus_lick_count, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
end

psth = mean(cs_plus_lick_count)*20; %omit the first bin because of odor delivery lick peak?
% lick_params(an).cs_plus_detection_speed = 0.05+.05*find(psth(2:end)>2*lick_params(an).baseline_rate_mean,1,'first');
lick_params(an).cs_plus_detection_speed = 0.05+.05*find(psth(2:end)>.5+lick_params(an).baseline_rate_mean,1,'first');
if isempty(lick_params(an).cs_plus_detection_speed); lick_params(an).cs_plus_detection_speed=NaN; end 

%% CS- detection/valuation speed
cs_minus_lick_count = [];
for tr = 1:numel(cs_minus_trials_before_reversal)
    % high-temporal resolution psth over window
    cs_minus_lick_count = cat(1,cs_minus_lick_count, histcounts(gng_data(cs_minus_trials_before_reversal(tr)).licks_aft_od,edges));
end
psth = mean(cs_minus_lick_count)*20; %omit the first bin because of odor delivery lick peak?
% lick_params(an).cs_minus_detection_speed = 0.05+.05*find(psth(2:end)<.25*lick_params(an).baseline_rate_mean,1,'first');
lick_params(an).cs_minus_detection_speed = 0.05+.05*find(psth(2:end)<-.5+lick_params(an).baseline_rate_mean,1,'first');
if isempty(lick_params(an).cs_minus_detection_speed); lick_params(an).cs_minus_detection_speed=NaN; end 

%% Switching flexibility: identify giving-up episodes
edges = 1.5:3.5;
for phase = 2:numel(reversal_index) % 
    cs_plus_trials_before_reversal = []; cs_plus_trials_after_reversal = []; cs_plus_lick_count_before = []; cs_plus_lick_count_after = [];
    cs_plus_trials_before_reversal = reversal_index(phase-1)-1+find([gng_data(reversal_index(phase-1):reversal_index(phase)).reward]==1,150,'last')';
    cs_plus_trials_after_reversal = reversal_index(phase)-1+find([gng_data(reversal_index(phase):end).reward]==1,70,'first')';
    cs_plus_trials_after_reversal(1:20) = [];
    
    % lick count in pre-reversal
    for tr = 1:numel(cs_plus_trials_before_reversal)
        cs_plus_lick_count_before = cat(1,cs_plus_lick_count_before, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
    end
    
    % lick count after reversal
    for tr = 1:numel(cs_plus_trials_after_reversal)
        cs_plus_lick_count_after = cat(1,cs_plus_lick_count_after, histcounts(gng_data(cs_plus_trials_after_reversal(tr)).licks_aft_od,edges));
    end
    
    % giving up at CS
    if mean(cs_plus_lick_count_after(:,1))<.25*mean(cs_plus_lick_count_before(:,1))
        lick_params(an).(['giving_up_at_CS_rev',num2str(phase-1)]) = 1;
    else
        lick_params(an).(['giving_up_at_CS_rev',num2str(phase-1)]) = 0;
    end
    
    % giving up at US
    if mean(cs_plus_lick_count_after(:,2))<.25*mean(cs_plus_lick_count_before(:,2))
        lick_params(an).(['giving_up_at_US_rev',num2str(phase-1)]) = 1;
    else
        lick_params(an).(['giving_up_at_US_rev',num2str(phase-1)]) = 0;
    end
end

%% Switching flexibility: quantify CS re-learning by calculating latency to switch (in number of trials)
edges = 0.5:3.5;
reversal_index = [1, find(diff([gng_data.phase])==1)+1,numel(gng_data)];
cs_plus_switch_latency_at_cs = []; cs_plus_switch_latency_at_us = [];
cs_minus_switch_latency_at_cs = []; cs_minus_switch_latency_at_us = [];
complete_relearning_cs = []; complete_relearning_us = [];

% recompute drop_or_not and false_alarm for CS and US windows
% respectively
for tr=1:numel(gng_data)
    gng_data(tr).hit_at_cs = 0;
    gng_data(tr).cr_at_cs = 0;    
    gng_data(tr).hit_at_us = 0;
    gng_data(tr).cr_at_us = 0;
    
    current_lick_count = histcounts(gng_data(tr).licks_aft_od,edges);
    switch gng_data(tr).reward
        case 0
            if sum(current_lick_count(1:2))<=3
                gng_data(tr).cr_at_cs = 1;
            end
            if sum(current_lick_count(3))<=3
                gng_data(tr).cr_at_us = 1;
            end
        case 1
            if sum(current_lick_count(1:2))>1
                gng_data(tr).hit_at_cs = 1;
            end
            if sum(current_lick_count(3))>1
                gng_data(tr).hit_at_us = 1;
            end
    end
end
        
for phase = 2:numel(reversal_index)-1 % 
    cs_plus_trials_before_reversal = []; cs_plus_trials_after_reversal = []; cs_minus_trials_before_reversal = []; cs_minus_trials_after_reversal = []; 
    cs_plus_lick_count_before = []; cs_plus_lick_count_after = []; cs_minus_lick_count_before = []; cs_minus_lick_count_after = []; 
    cs_plus_trials_before_reversal = reversal_index(phase-1)-1+find([gng_data(reversal_index(phase-1):reversal_index(phase)).reward]==1,150,'last')';
    cs_plus_trials_after_reversal = reversal_index(phase)-1+find([gng_data(reversal_index(phase):reversal_index(phase+1)).reward]==1)';
    cs_minus_trials_before_reversal = reversal_index(phase-1)-1+find([gng_data(reversal_index(phase-1):reversal_index(phase)).reward]==0,150,'last')';
    cs_minus_trials_after_reversal = reversal_index(phase)-1+find([gng_data(reversal_index(phase):reversal_index(phase+1)).reward]==0)';
    
    % lick count in pre-reversal
    for tr = 1:numel(cs_plus_trials_before_reversal)
        cs_plus_lick_count_before = cat(1,cs_plus_lick_count_before, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
    end
    for tr = 1:numel(cs_minus_trials_before_reversal)
        cs_minus_lick_count_before = cat(1,cs_minus_lick_count_before, histcounts(gng_data(cs_minus_trials_before_reversal(tr)).licks_aft_od,edges));
    end
    
    % lick count after reversal
    for tr = 1:numel(cs_plus_trials_after_reversal)
        cs_plus_lick_count_after = cat(1,cs_plus_lick_count_after, histcounts(gng_data(cs_plus_trials_after_reversal(tr)).licks_aft_od,edges));
    end
    for tr = 1:numel(cs_minus_trials_after_reversal)
        cs_minus_lick_count_after = cat(1,cs_minus_lick_count_after, histcounts(gng_data(cs_minus_trials_after_reversal(tr)).licks_aft_od,edges));
    end
    
    % original 
%     cs_plus_switch_latency_at_cs = cat(1,cs_plus_switch_latency_at_cs,find(mean(cs_plus_lick_count_after(:,1:2),2)>.7*mean(cs_plus_lick_count_before(:,1:2),'all'),1,'first'));
%     cs_plus_switch_latency_at_us = cat(1,cs_plus_switch_latency_at_us,find(cs_plus_lick_count_after(:,3)>.7*mean(cs_plus_lick_count_before(:,3),'all'),1,'first'));
%     cs_minus_switch_latency_at_cs = cat(1,cs_minus_switch_latency_at_cs,find(mean(cs_minus_lick_count_after(:,1:2),2)<1.3*mean(cs_minus_lick_count_before(:,1:2),'all'),1,'first'));
%     cs_minus_switch_latency_at_us = cat(1,cs_minus_switch_latency_at_us,find(cs_minus_lick_count_after(:,3)<1.3*mean(cs_minus_lick_count_before(:,3),'all'),1,'first'));

    % more stringent thresholding: 6 out of 10 consecutive trials above 70%
    % of last phase lick-frequency or respective cs- criterium
    cs_plus_switch_latency_at_cs = cat(1,cs_plus_switch_latency_at_cs,find(movmean(mean(cs_plus_lick_count_after(:,1:2),2)>.7*mean(cs_plus_lick_count_before(:,1:2),'all'),[0 9])>.6,1,'first'));
    cs_plus_switch_latency_at_us = cat(1,cs_plus_switch_latency_at_us,find(movmean(cs_plus_lick_count_after(:,3)>.7*mean(cs_plus_lick_count_before(:,3),'all'),[0 9])>.6,1,'first'));
    cs_minus_switch_latency_at_cs = cat(1,cs_minus_switch_latency_at_cs,find(movmean(mean(cs_minus_lick_count_after(:,1:2),2)<.5*mean(cs_plus_lick_count_before(:,1:2),'all'),[0 9])>.6,1,'first'));
    cs_minus_switch_latency_at_us = cat(1,cs_minus_switch_latency_at_us,find(movmean(cs_minus_lick_count_after(:,3)<.5*mean(cs_plus_lick_count_before(:,3),'all'),[0 9])>.6,1,'first'));
    
    % parse indidividual switches to lick_params
    lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)]) = find(movmean(mean(cs_plus_lick_count_after(:,1:2),2)>.7*mean(cs_plus_lick_count_before(:,1:2),'all'),[0 9])>.6,1,'first');
    lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)]) = find(movmean(cs_plus_lick_count_after(:,3)>.7*mean(cs_plus_lick_count_before(:,3),'all'),[0 9])>.6,1,'first');
    lick_params(an).(['cs_minus_switch_latency_at_cs_rev',num2str(phase-1)]) = find(movmean(mean(cs_minus_lick_count_after(:,1:2),2)<.5*mean(cs_plus_lick_count_before(:,1:2),'all'),[0 9])>.6,1,'first');
    lick_params(an).(['cs_minus_switch_latency_at_us_rev',num2str(phase-1)]) = find(movmean(cs_minus_lick_count_after(:,3)<.5*mean(cs_plus_lick_count_before(:,3),'all'),[0 9])>.6,1,'first');
    
    % fill with nan if threshold not passed for latency
    if isempty(lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])); lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)])=lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)]); end
    if isempty(lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)])); lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])=lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)]); end
    if isempty(lick_params(an).(['cs_minus_switch_latency_at_cs_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['cs_minus_switch_latency_at_us_rev',num2str(phase-1)])); lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)])=lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)]); end
    if isempty(lick_params(an).(['cs_minus_switch_latency_at_us_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['cs_minus_switch_latency_at_cs_rev',num2str(phase-1)])); lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])=lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)]); end
    
    % fill with nan if threshold not passed for latency and CS/US also not
    % available to impute
    if isempty(lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)])) && ~isnan(lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])); lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase-1)])=NaN; end
    if isempty(lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])); lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase-1)])=NaN; end
    if isempty(lick_params(an).(['cs_minus_switch_latency_at_cs_rev',num2str(phase-1)])); lick_params(an).(['cs_minus_switch_latency_at_cs_rev',num2str(phase-1)])=NaN; end
    if isempty(lick_params(an).(['cs_minus_switch_latency_at_us_rev',num2str(phase-1)])); lick_params(an).(['cs_minus_switch_latency_at_us_rev',num2str(phase-1)])=NaN; end
    
        % complete re-learning @CS: omit after discussion with WK for now. Parameters should be descriptive of pattern and not rely on performance criterion measured by the task design
    % trialtypes: 1 = hit, 2 = miss, 3 = correct rejection, 4 = false alarm
    % moving average of 10 trials in the future. switch achieved if more
    % than two consecutive blocks of 10 trials are above 80% performance
    
%     relearning_cs = [find(movmean(movmean([gng_data(cs_plus_trials_after_reversal).hit_at_cs],[0 9])>=.8,[0 1])==1,1,'first'), ...
%         find(movmean(movmean([gng_data(cs_minus_trials_after_reversal).cr_at_cs],[0 9])>=.8,[0 1])==1,1,'first')];
%     relearning_us = [find(movmean(movmean([gng_data(cs_plus_trials_after_reversal).hit_at_us],[0 9])>=.8,[0 1])==1,1,'first'), ...
%         find(movmean(movmean([gng_data(cs_minus_trials_after_reversal).cr_at_us],[0 9])>=.8,[0 1])==1,1,'first')];
%     
%     if numel(relearning_cs)==2; lick_params(an).(['complete_relearning_cs_rev',num2str(phase-1)]) = max(relearning_cs); else; lick_params(an).(['complete_relearning_cs_rev',num2str(phase-1)]) = NaN; end
%     if numel(relearning_us)==2; lick_params(an).(['complete_relearning_us_rev',num2str(phase-1)]) = max(relearning_us); else; lick_params(an).(['complete_relearning_us_rev',num2str(phase-1)]) = NaN; end
%     
%     complete_relearning_cs = cat(1,complete_relearning_cs, lick_params(an).(['complete_relearning_cs_rev',num2str(phase-1)]));
%     complete_relearning_us = cat(1,complete_relearning_us, lick_params(an).(['complete_relearning_us_rev',num2str(phase-1)]));
end

% parse averages of switching latencies to lick_params
lick_params(an).cs_plus_switch_latency_at_cs_mean = mean(cs_plus_switch_latency_at_cs);
lick_params(an).cs_plus_switch_latency_at_us_mean = mean(cs_plus_switch_latency_at_us);
lick_params(an).cs_minus_switch_latency_at_cs_mean = mean(cs_minus_switch_latency_at_cs);
lick_params(an).cs_minus_switch_latency_at_us_mean = mean(cs_minus_switch_latency_at_us);
% lick_params(an).complete_relearning_latency_at_cs_mean = mean(complete_relearning_cs);
% lick_params(an).complete_relearning_latency_at_us_mean  = mean(complete_relearning_us);


%% delay avoidance learner: 10 successive correct rejections as definition?
% lick_params(an).delay_avoidance_learner = any(movmean([gng_data(~[gng_data.reward]).cr_at_us],[0 100])>.9);
reversal_index = [1,find(diff([gng_data.phase])==1)+1];
cs_minus_trials_before_reversal = [];
for rev = 2:numel(reversal_index)
    cs_minus_trials_before_reversal = cat(1, cs_minus_trials_before_reversal, reversal_index(rev-1)-1+find([gng_data(reversal_index(rev-1):reversal_index(rev)).reward]==0,150,'last')');
end

edges = 0.5:2.5;
cs_minus_lick_count_before = [];
for tr = 1:numel(cs_minus_trials_before_reversal)
    cs_minus_lick_count_before = cat(1,cs_minus_lick_count_before,histcounts(gng_data(cs_minus_trials_before_reversal(tr)).licks_aft_od,edges));
end

dal = mean(cs_minus_lick_count_before,'all')<=1;
if dal
    lick_params(an).delay_avoidance_learner = 1;
else
    lick_params(an).delay_avoidance_learner = 0;
end

% CS- lick modulation
lick_params(an).cs_minus_modulation_full_window_averaged = mean(cs_minus_lick_count_before,'all')/lick_params(an).baseline_rate_mean;

%% Step 2: cross-reversal shaping
%
%
%
%% CS re-learning progression @CS/US

try
    lick_params(an).cs_plus_relearning_progression_at_cs = lick_params(an).cs_plus_switch_latency_at_cs_rev2/lick_params(an).(['cs_plus_switch_latency_at_cs_rev',num2str(phase_cutoff-1)]);
    lick_params(an).cs_plus_relearning_progression_at_us = lick_params(an).cs_plus_switch_latency_at_us_rev2/lick_params(an).(['cs_plus_switch_latency_at_us_rev',num2str(phase_cutoff-1)]); 
    lick_params(an).cs_minus_relearning_progression_at_cs = lick_params(an).cs_minus_switch_latency_at_cs_rev2/lick_params(an).(['cs_minus_switch_latency_at_cs_rev',num2str(phase_cutoff-1)]);
    lick_params(an).cs_minus_relearning_progression_at_us = lick_params(an).cs_minus_switch_latency_at_us_rev2/lick_params(an).(['cs_minus_switch_latency_at_us_rev',num2str(phase_cutoff-1)]); 
catch
    lick_params(an).cs_plus_relearning_progression_at_cs = NaN;
    lick_params(an).cs_plus_relearning_progression_at_us = NaN; 
    lick_params(an).cs_minus_relearning_progression_at_cs = NaN;
    lick_params(an).cs_minus_relearning_progression_at_us = NaN;     
end
% complete re-learning ratios
% lick_params(an).complete_relearning_progression_at_cs = lick_params(an).complete_relearning_cs_rev6/lick_params(an).complete_relearning_cs_rev2;
% lick_params(an).complete_relearning_progression_at_us = lick_params(an).complete_relearning_us_rev6/lick_params(an).complete_relearning_us_rev2; 

%% delay avoidance shaping
reversal_index = [1,find(diff([gng_data.phase])==1)+1];
cs_minus_trials_before_reversal_2 = reversal_index(2)-1+find([gng_data(reversal_index(2):reversal_index(3)).reward]==0,150,'last')';
cs_minus_trials_before_reversal_6 = reversal_index(phase_cutoff-1)-1+find([gng_data(reversal_index(phase_cutoff-1):reversal_index(phase_cutoff)).reward]==0,150,'last')';

edges = 0.5:2.5;
cs_minus_lick_count_before_2 = []; cs_minus_lick_count_before_6 = [];
for tr = 1:numel(cs_minus_trials_before_reversal_2)
    cs_minus_lick_count_before_2 = cat(1,cs_minus_lick_count_before_2, histcounts([gng_data(cs_minus_trials_before_reversal_2(tr)).licks_aft_od],edges));
end
for tr = 1:numel(cs_minus_trials_before_reversal_6)
    cs_minus_lick_count_before_6 = cat(1,cs_minus_lick_count_before_6, histcounts([gng_data(cs_minus_trials_before_reversal_6(tr)).licks_aft_od],edges));
end
lick_params(an).delay_avoidance_shaping = mean(cs_minus_lick_count_before_2,'all')./(mean(cs_minus_lick_count_before_2,'all')+mean(cs_minus_lick_count_before_6,'all'));
if isinf(lick_params(an).delay_avoidance_shaping); lick_params(an).delay_avoidance_shaping = NaN; end
%% "giving-up" cross-reversal shaping
edges = 1.5:3.5;
reversal_index = [1,find(diff([gng_data.phase])==1)+1, numel(gng_data)];
for phase = 2:numel(reversal_index)-1 % 
    cs_plus_trials_before_reversal = []; cs_plus_trials_after_reversal = []; cs_plus_lick_count_before = []; cs_plus_lick_count_after = [];
    cs_plus_trials_before_reversal = reversal_index(phase-1)-1+find([gng_data(reversal_index(phase-1):reversal_index(phase)).reward]==1,150,'last')';
    cs_plus_trials_after_reversal = reversal_index(phase)-1+find([gng_data(reversal_index(phase):reversal_index(phase+1)).reward]==1)';
    
    % lick count in pre-reversal
    for tr = 1:numel(cs_plus_trials_before_reversal)
        cs_plus_lick_count_before = cat(1,cs_plus_lick_count_before, histcounts(gng_data(cs_plus_trials_before_reversal(tr)).licks_aft_od,edges));
    end
    
    % lick count after reversal
    for tr = 1:numel(cs_plus_trials_after_reversal)
        cs_plus_lick_count_after = cat(1,cs_plus_lick_count_after, histcounts(gng_data(cs_plus_trials_after_reversal(tr)).licks_aft_od,edges));
    end
    
    % number of trials CS+ freq < 25% of CS+ freq pre-reversal
    lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]) = find(movmean(cs_plus_lick_count_after(:,1) > 0.25*mean(cs_plus_lick_count_before(:,1)),[0 9])>.6,1,'first');
    % number of trials CS+ freq < 25% of CS+ freq pre-reversal @US
    lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)]) = find(movmean(cs_plus_lick_count_after(:,2) > 0.25*mean(cs_plus_lick_count_before(:,2)),[0 9])>.6,1,'first');
    
    
    if isempty(lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)]))
        lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]) = lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)]);
    elseif isempty(lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)])) && isempty(lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)]))
        lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]) = NaN;
    end
    
    if isempty(lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]))
        lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)]) = lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]);
    elseif isempty(lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)])) && ~isempty(lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]))
        lick_params(an).(['pause_duration_at_US_rev',num2str(phase-1)]) = NaN;
    end
    
    % duration in minutes of pause
    if ~isnan(lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)]))
        lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1),'_in_minutes']) = minutes((duration('24:00:00')*(str2num(gng_data(reversal_index(phase)+lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)])).date)>str2num(gng_data(reversal_index(phase)).date))... % day offset
            +duration(gng_data(reversal_index(phase)+lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1)])).time_StartTrial))-... % time of end of pause
            duration(gng_data(reversal_index(phase)).time_StartTrial)); % time of reversal
    else
        lick_params(an).(['pause_duration_at_CS_rev',num2str(phase-1),'_in_minutes']) = NaN;
    end
%     % giving up at CS
%     if mean(cs_plus_lick_count_after(:,1))<.25*mean(cs_plus_lick_count_before(:,1))
%         lick_params(an).(['giving_up_at_CS_rev',num2str(phase-1)]) = 1;
%     else
%         lick_params(an).(['giving_up_at_CS_rev',num2str(phase-1)]) = 0;
%     end
%     
%     % giving up at US
%     if mean(cs_plus_lick_count_after(:,2))<.25*mean(cs_plus_lick_count_before(:,2))
%         lick_params(an).(['giving_up_at_US_rev',num2str(phase-1)]) = 1;
%     else
%         lick_params(an).(['giving_up_at_US_rev',num2str(phase-1)]) = 0;
%     end
end

lick_params(an).pause_duration_at_CS_shaping_rev_1to2 = lick_params(an).pause_duration_at_CS_rev1/lick_params(an).pause_duration_at_CS_rev2;
lick_params(an).pause_duration_at_CS_shaping_rev_1toLate = lick_params(an).pause_duration_at_CS_rev1/mean([lick_params(an).(['pause_duration_at_CS_rev',num2str(phase_cutoff-3)]),lick_params(an).(['pause_duration_at_CS_rev',num2str(phase_cutoff-2)]),lick_params(an).(['pause_duration_at_CS_rev',num2str(phase_cutoff-1)])],'omitnan');
lick_params(an).pause_duration_at_CS_shaping_rev_2toLate = lick_params(an).pause_duration_at_CS_rev2/mean([lick_params(an).(['pause_duration_at_CS_rev',num2str(phase_cutoff-3)]),lick_params(an).(['pause_duration_at_CS_rev',num2str(phase_cutoff-2)]),lick_params(an).(['pause_duration_at_CS_rev',num2str(phase_cutoff-1)])],'omitnan');

lick_params(an).pause_duration_at_US_shaping_rev_1to2 = lick_params(an).pause_duration_at_US_rev1/lick_params(an).pause_duration_at_US_rev2;
lick_params(an).pause_duration_at_US_shaping_rev_1toLate = lick_params(an).pause_duration_at_US_rev1/mean([lick_params(an).(['pause_duration_at_US_rev',num2str(phase_cutoff-3)]),lick_params(an).(['pause_duration_at_US_rev',num2str(phase_cutoff-2)]),lick_params(an).(['pause_duration_at_US_rev',num2str(phase_cutoff-1)])],'omitnan');
lick_params(an).pause_duration_at_US_shaping_rev_2toLate = lick_params(an).pause_duration_at_US_rev2/mean([lick_params(an).(['pause_duration_at_US_rev',num2str(phase_cutoff-3)]),lick_params(an).(['pause_duration_at_US_rev',num2str(phase_cutoff-2)]),lick_params(an).(['pause_duration_at_US_rev',num2str(phase_cutoff-1)])],'omitnan');

%% CS+ detection/valuation speed intra-phase 3 shaping
edges = 0:0.05:1.5;
reversal_index = [1,find(diff([gng_data.phase])==1)+1, numel(gng_data)];

tmp_rew_trials = find([gng_data(reversal_index(3):reversal_index(4)).reward]==1)';
cs_plus_trials_phase3 = reversal_index(3)-1+tmp_rew_trials(lick_params(an).cs_plus_switch_latency_at_cs_rev2:end); % only start looking for detection peak after switch!
% cs_plus_trials_phase3 = reversal_index(3)-1+find([gng_data(reversal_index(3):reversal_index(4)).reward]==1)';

cs_plus_lick_count = [];
for tr=1:numel(cs_plus_trials_phase3)
    cs_plus_lick_count = cat(1, cs_plus_lick_count, histcounts(cat(2,gng_data(cs_plus_trials_phase3(tr)).licks_bef_od, gng_data(cs_plus_trials_phase3(tr)).licks_aft_od),edges));
end
psth_first = mean(cs_plus_lick_count(1:100,:))*20; 
psth_last = mean(cs_plus_lick_count(end-99:end,:))*20; 
baseline_first = mean(cs_plus_lick_count(1:100,2:10),'all')*20;
baseline_last = mean(cs_plus_lick_count(end-99:end,2:10),'all')*20;

% latency_first = 0.05+0.05*find(psth_first(12:end)>2*baseline_first,1,'first');
% latency_last = 0.05+0.05*find(psth_last(12:end)>2*baseline_last,1,'first');
latency_first = 0.05+0.05*find(psth_first(12:end)>.5+baseline_first,1,'first');
latency_last = 0.05+0.05*find(psth_last(12:end)>.5+baseline_last,1,'first');

if isempty(latency_first) || isempty(latency_last)
    lick_params(an).cs_plus_detection_speed_intraphase_shaping = NaN;
else
    lick_params(an).cs_plus_detection_speed_intraphase_shaping = latency_first/latency_last;
end
%% CS- detection/valuation speed intra-phase 3 shaping
edges = 0:0.05:1.5;
reversal_index = [1,find(diff([gng_data.phase])==1)+1, numel(gng_data)];

cs_minus_trials_phase3 = reversal_index(3)-1+find([gng_data(reversal_index(3):reversal_index(4)).reward]==0)';

cs_minus_lick_count = [];
for tr=1:numel(cs_minus_trials_phase3)
    cs_minus_lick_count = cat(1, cs_minus_lick_count, histcounts(cat(2,gng_data(cs_minus_trials_phase3(tr)).licks_bef_od, gng_data(cs_minus_trials_phase3(tr)).licks_aft_od),edges));
end
psth_first = mean(cs_minus_lick_count(1:100,:))*20; 
psth_last = mean(cs_minus_lick_count(end-99:end,:))*20; 
baseline = mean(cs_minus_lick_count(:,2:10),'all')*20;

latency_first = 0.05+0.05*find(psth_first(12:end)<.25*baseline,1,'first');
latency_last = 0.05+0.05*find(psth_last(12:end)<.25*baseline,1,'first');

if isempty(latency_first) || isempty(latency_last)
    lick_params(an).cs_minus_detection_speed_intraphase_shaping = NaN;
else
    lick_params(an).cs_minus_detection_speed_intraphase_shaping = latency_first/latency_last;
end

%% CS+ detection/valuation speed cross-reversal
edges = 0:0.05:1.5;
reversal_index = [1,find(diff([gng_data.phase])==1)+1, numel(gng_data)];
cs_plus_trials_2 = reversal_index(3)-1+find([gng_data(reversal_index(3):reversal_index(4)).reward]==1,150,'last')';
cs_plus_trials_6 = reversal_index(phase_cutoff)-1+find([gng_data(reversal_index(phase_cutoff):reversal_index(phase_cutoff+1)).reward]==1,150,'last')';

cs_plus_lick_count_2 = [];
for tr=1:numel(cs_plus_trials_2)
    cs_plus_lick_count_2 = cat(1, cs_plus_lick_count_2, histcounts(cat(2,gng_data(cs_plus_trials_2(tr)).licks_bef_od, gng_data(cs_plus_trials_2(tr)).licks_aft_od),edges));
end

cs_plus_lick_count_6 = [];
for tr=1:numel(cs_plus_trials_6)
    cs_plus_lick_count_6 = cat(1, cs_plus_lick_count_6, histcounts(cat(2,gng_data(cs_plus_trials_6(tr)).licks_bef_od, gng_data(cs_plus_trials_6(tr)).licks_aft_od),edges));
end

psth_2 = mean(cs_plus_lick_count_2)*20;
baseline_2 = mean(psth_2(2:10));
% latency_2 = 0.05+0.05*find(psth_2(12:end)>baseline_2*2,1,'first');
latency_2 = 0.05+0.05*find(psth_2(12:end)>baseline_2+.5,1,'first');

psth_6 = mean(cs_plus_lick_count_6)*20;
baseline_6 = mean(psth_6(2:10));
% latency_6 = 0.05+0.05*find(psth_6(12:end)>baseline_6*2,1,'first');
latency_6 = 0.05+0.05*find(psth_6(12:end)>baseline_6+.5,1,'first');

if isempty(latency_2) || isempty(latency_6)
    lick_params(an).cs_plus_detection_speed_crossreversal_shaping = NaN;
else
    lick_params(an).cs_plus_detection_speed_crossreversal_shaping = latency_2/latency_6;
end
%% CS- detection/valuation speed cross-reversal
edges = 0:0.05:1.5;
reversal_index = [1,find(diff([gng_data.phase])==1)+1, numel(gng_data)];
cs_minus_trials_2 = reversal_index(3)-1+find([gng_data(reversal_index(3):reversal_index(4)).reward]==1,150,'last')';
cs_minus_trials_6 = reversal_index(phase_cutoff)-1+find([gng_data(reversal_index(phase_cutoff):reversal_index(phase_cutoff+1)).reward]==1,150,'last')';

cs_minus_lick_count_2 = [];
for tr=1:numel(cs_minus_trials_2)
    cs_minus_lick_count_2 = cat(1, cs_minus_lick_count_2, histcounts(cat(2,gng_data(cs_minus_trials_2(tr)).licks_bef_od, gng_data(cs_minus_trials_2(tr)).licks_aft_od),edges));
end

cs_minus_lick_count_6 = [];
for tr=1:numel(cs_minus_trials_6)
    cs_minus_lick_count_6 = cat(1, cs_minus_lick_count_6, histcounts(cat(2,gng_data(cs_minus_trials_6(tr)).licks_bef_od, gng_data(cs_minus_trials_6(tr)).licks_aft_od),edges));
end

psth_2 = mean(cs_minus_lick_count_2)*20;
baseline_2 = mean(psth_2(2:10));
latency_2 = 0.05+0.05*find(psth_2(12:end)<baseline_2*.25,1,'first');

psth_6 = mean(cs_minus_lick_count_6)*20;
baseline_6 = mean(psth_6(2:10));
latency_6 = 0.05+0.05*find(psth_6(12:end)<baseline_6*.25,1,'first');

if isempty(latency_2) || isempty(latency_6)
   lick_params(an).cs_minus_detection_speed_crossreversal_shaping = NaN; 
else
   lick_params(an).cs_minus_detection_speed_crossreversal_shaping = latency_2/latency_6;
end
%% Baseline licking shaping cross-reversal
edges = 0:0.05:0.5;
subselect = (cell2mat(cellfun(@isempty, {gng_data(:).licks_bef_od},'UniformOutput',0)) & ...
    cell2mat(cellfun(@isempty, {gng_data(:).licks_aft_od},'UniformOutput',0)));
trials_2 = find([gng_data.phase]==3);
trials_2 = trials_2(ismember(trials_2,find(~subselect)));
trials_6 = find([gng_data.phase]==phase_cutoff);
trials_6 = trials_6(ismember(trials_6,find(~subselect)));


baseline_2 = [];
for tr = 1:numel(trials_2)
    baseline_2 = cat(1, baseline_2, histcounts(gng_data(trials_2(tr)).licks_bef_od, edges)); 
end

baseline_6 = [];
for tr = 1:numel(trials_6)
    baseline_6 = cat(1, baseline_6, histcounts(gng_data(trials_6(tr)).licks_bef_od, edges)); 
end

lick_params(an).baseline_crossreversal_shaping = mean(baseline_2(:,2:end),'all')/mean(baseline_6(:,2:end),'all');

end


