%% scatterplot_lickFeatures_to_socialMetrics_jr.m

clear all
close all
clc

outputMainDir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/plots'

% load lick features
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params_new.mat'),'lick_params_short');

% load different hierarchies
% For each animal, social hierarchy is used based on the 14 days before the scans
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% animals in AM1 were scanned at different days (either D45 or D51)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day10to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info1_3to16 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_3to16.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_3to16.Rank = Rank;
DS_info1_3to16.DSzscored = zscore([DS_info1_3to16.DS]);
% chasing
DSchasing_info1_3to16 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_3to16.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info1_3to16.Rank = Rank;
DSchasing_info1_3to16.DSzscored = zscore([DSchasing_info1_3to16.DS]);

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day8to21_12mice_withChasing.mat','DS_info','DS_info_chasing');
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day15to21_12mice_withChasing.mat','DS_info','DS_info_chasing');
DS_info1_8to21 = DS_info;
clear Idx Rank
% tube hierarchy
[~,Idx]=sort([DS_info1_8to21.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_8to21.Rank = Rank;
DS_info1_8to21.DSzscored = zscore([DS_info1_8to21.DS]);
% chasing
DSchasing_info1_8to21 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_8to21.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info1_8to21.Rank = Rank;
DSchasing_info1_8to21.DSzscored = zscore([DSchasing_info1_8to21.DS]);

% animals in AM1 were scanned at different days (either D44 and D45)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14_12mice_withChasing.mat','DS_info','DS_info_chasing');
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day8to14_12mice_withChasing.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info2 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info2.DS],'descend');
[~,Rank]=sort(Idx);
DS_info2.Rank = Rank;
DS_info2.DSzscored = zscore([DS_info2.DS]);
% chasing
DSchasing_info2 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info2.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info2.Rank = Rank;
DSchasing_info2.DSzscored = zscore([DSchasing_info2.DS]);

clear info
counter=1;
for idxT = 1:size(T,1)
    % add info on IDs
    info.ID{counter}=T.AnimalIDCombined{idxT};
    % add infos on Davids Score and Rank for NoSeMaze 1
    if T.Autonomouse(idxT)==1
        info.NoSeMaze(counter)=1;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        if contains(T.DaysToConsider{idxT},'16')
            % tube hierarchy
            info.DS_social(counter)=DS_info1_3to16.DS(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            info.Rank_social(counter)=DS_info1_3to16.Rank(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            info.DSzscored_social(counter)=DS_info1_3to16.DSzscored(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            % number/fraction of wins/losses
            clear help_n_wins help_n_losses help_fr_winner help_fr_losses
            help_n_wins = sum(DS_info1_3to16.match_matrix,2);
            help_n_losses = sum(DS_info1_3to16.match_matrix,1)';
            help_fr_winner = help_n_wins./sum(help_n_wins);
            help_fr_losses = help_n_losses./sum(help_n_losses);
            info.n_winner(counter)=help_n_wins(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            info.n_loser(counter)=help_n_losses(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            info.fr_winner(counter)=help_fr_winner(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            info.fr_loser(counter)=help_fr_losses(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            % prob
            clear match_matrix_prob
            match_matrix_prob = DS_info1_3to16.match_matrix./(DS_info1_3to16.match_matrix+DS_info1_3to16.match_matrix');
            help_prob_winner = nansum(match_matrix_prob,2);
            help_prob_losses = nansum(match_matrix_prob,1)';
            info.prob_winner(counter)=help_prob_winner(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            info.prob_loser(counter)=help_prob_losses(strcmp(DS_info1_3to16.ID,info.ID{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_3to16.DS(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_3to16.Rank(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_3to16.DSzscored(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            % number/fraction of chasings
            clear help_n_chaser help_n_chased help_fr_chaser help_fr_chased
            help_n_chaser = sum(DSchasing_info1_3to16.match_matrix,2);
            help_n_chased = sum(DSchasing_info1_3to16.match_matrix,1)';
            help_fr_chaser = help_n_chaser./sum(help_n_chaser);
            help_fr_chased = help_n_chased./sum(help_n_chased);
            info.n_chaser(counter)=help_n_chaser(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            info.n_chased(counter)=help_n_chased(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            info.fr_chaser(counter)=help_fr_chaser(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));   
            info.fr_chased(counter)=help_fr_chased(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            % prob
            clear match_matrix_prob
            match_matrix_prob = DSchasing_info1_3to16.match_matrix./(DSchasing_info1_3to16.match_matrix+DSchasing_info1_3to16.match_matrix');
            help_prob_winner = nansum(match_matrix_prob,2);
            help_prob_losses = nansum(match_matrix_prob,1)';
            info.prob_chaser(counter)=help_prob_winner(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
            info.prob_chased(counter)=help_prob_losses(strcmp(DSchasing_info1_3to16.ID,info.ID{counter}));
        elseif contains(T.DaysToConsider{idxT},'21')
            % tube hierarchy
            info.DS_social(counter)=DS_info1_8to21.DS(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            info.Rank_social(counter)=DS_info1_8to21.Rank(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            info.DSzscored_social(counter)=DS_info1_8to21.DSzscored(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            % number/fraction of wins/losses
            clear help_n_wins help_n_losses help_fr_winner help_fr_losses
            help_n_wins = sum(DS_info1_8to21.match_matrix,2);
            help_n_losses = sum(DS_info1_8to21.match_matrix,1)';
            help_fr_winner = help_n_wins./sum(help_n_wins);
            help_fr_losses = help_n_losses./sum(help_n_losses);
            info.n_winner(counter)=help_n_wins(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            info.n_loser(counter)=help_n_losses(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            info.fr_winner(counter)=help_fr_winner(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            info.fr_loser(counter)=help_fr_losses(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            % prob
            clear match_matrix_prob
            match_matrix_prob = DS_info1_8to21.match_matrix./(DS_info1_8to21.match_matrix+DS_info1_8to21.match_matrix');
            help_prob_winner = nansum(match_matrix_prob,2);
            help_prob_losses = nansum(match_matrix_prob,1)';
            info.prob_winner(counter)=help_prob_winner(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            info.prob_loser(counter)=help_prob_losses(strcmp(DS_info1_8to21.ID,info.ID{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_8to21.DS(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_8to21.Rank(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_8to21.DSzscored(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            % number/fraction of chasings
            clear help_n_chaser help_n_chased help_fr_chaser help_fr_chased
            help_n_chaser = sum(DSchasing_info1_8to21.match_matrix,2);
            help_n_chased = sum(DSchasing_info1_8to21.match_matrix,1)';
            help_fr_chaser = help_n_chaser./sum(help_n_chaser);
            help_fr_chased = help_n_chased./sum(help_n_chased);
            info.n_chaser(counter)=help_n_chaser(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            info.n_chased(counter)=help_n_chased(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            info.fr_chaser(counter)=help_fr_chaser(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));   
            info.fr_chased(counter)=help_fr_chased(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            % prob
            clear match_matrix_prob
            match_matrix_prob = DSchasing_info1_8to21.match_matrix./(DSchasing_info1_8to21.match_matrix+DSchasing_info1_8to21.match_matrix');
            help_prob_winner = nansum(match_matrix_prob,2);
            help_prob_losses = nansum(match_matrix_prob,1)';
            info.prob_chaser(counter)=help_prob_winner(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
            info.prob_chased(counter)=help_prob_losses(strcmp(DSchasing_info1_8to21.ID,info.ID{counter}));
        end
        counter=counter+1;
        % add infos on Davids Score and Rank for NoSeMaze 2
    elseif T.Autonomouse(idxT)==2
        info.NoSeMaze(counter)=2;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        % tube hierarchy
        info.DS_social(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID{counter}));
        info.Rank_social(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID{counter}));
        info.DSzscored_social(counter)=DS_info2.DSzscored(strcmp(DS_info2.ID,info.ID{counter}));
        % number/fraction of wins/losses
        clear help_n_wins help_n_losses help_fr_winner help_fr_losses
        help_n_wins = sum(DS_info2.match_matrix,2);
        help_n_losses = sum(DS_info2.match_matrix,1)';
        help_fr_winner = help_n_wins./sum(help_n_wins);
        help_fr_losses = help_n_losses./sum(help_n_losses);
        info.n_winner(counter)=help_n_wins(strcmp(DS_info2.ID,info.ID{counter}));
        info.n_loser(counter)=help_n_losses(strcmp(DS_info2.ID,info.ID{counter}));
        info.fr_winner(counter)=help_fr_winner(strcmp(DS_info2.ID,info.ID{counter}));
        info.fr_loser(counter)=help_fr_losses(strcmp(DS_info2.ID,info.ID{counter}));
        % prob
        clear match_matrix_prob
        match_matrix_prob = DS_info2.match_matrix./(DS_info2.match_matrix+DS_info2.match_matrix');
        help_prob_winner = nansum(match_matrix_prob,2);
        help_prob_losses = nansum(match_matrix_prob,1)';
        info.prob_winner(counter)=help_prob_winner(strcmp(DS_info2.ID,info.ID{counter}));
        info.prob_loser(counter)=help_prob_losses(strcmp(DS_info2.ID,info.ID{counter}));
        % chasing
        info.DS_chasing(counter)=DSchasing_info2.DS(strcmp(DSchasing_info2.ID,info.ID{counter}));
        info.Rank_chasing(counter)=DSchasing_info2.Rank(strcmp(DSchasing_info2.ID,info.ID{counter}));
        info.DSzscored_chasing(counter)=DSchasing_info2.DSzscored(strcmp(DSchasing_info2.ID,info.ID{counter}));
        % number/fraction of chasings
        clear help_n_chaser help_n_chased help_fr_chaser help_fr_chased
        help_n_chaser = sum(DSchasing_info2.match_matrix,2);
        help_n_chased = sum(DSchasing_info2.match_matrix,1)';
        help_fr_chaser = help_n_chaser./sum(help_n_chaser);
        help_fr_chased = help_n_chased./sum(help_n_chased);
        info.n_chaser(counter)=help_n_chaser(strcmp(DSchasing_info2.ID,info.ID{counter}));
        info.n_chased(counter)=help_n_chased(strcmp(DSchasing_info2.ID,info.ID{counter}));
        info.fr_chaser(counter)=help_fr_chaser(strcmp(DSchasing_info2.ID,info.ID{counter}));
        info.fr_chased(counter)=help_fr_chased(strcmp(DSchasing_info2.ID,info.ID{counter}));
        % prob
        clear match_matrix_prob
        match_matrix_prob = DSchasing_info2.match_matrix./(DSchasing_info2.match_matrix+DSchasing_info2.match_matrix');
        help_prob_winner = nansum(match_matrix_prob,2);
        help_prob_losses = nansum(match_matrix_prob,1)';
        info.prob_chaser(counter)=help_prob_winner(strcmp(DSchasing_info2.ID,info.ID{counter}));
        info.prob_chased(counter)=help_prob_losses(strcmp(DSchasing_info2.ID,info.ID{counter}));
        counter=counter+1;
    end
end

% reduce social metrics and lick features and sort them in the same way

% Extract IDs from the cell arrays
IDs_tube = info.ID;
IDs_gng = lick_params_short.ID;
% Find the indices of IDs_tube that match IDs_gng
[~, idx] = ismember(IDs_gng, IDs_tube);
% Make a table "TubeMetrics" sorted in the order of IDs_gng
myFieldnames = fieldnames(info);
myFieldnames = myFieldnames(~contains(myFieldnames,{'NoSeMaze','AnimalNumb'}));
TubeMetrics = table();
for field_idx = 1:length(myFieldnames)
    TubeMetrics = [TubeMetrics,table(info.(myFieldnames{field_idx})(idx)','VariableNames',{myFieldnames{field_idx}})];
end
% Make a reduced table "LickMetrics" (same order as IDs_tube)
selection = contains(lick_params_short.Properties.VariableNames,{'ID','baseline_rate_mean_omitfirst','cs_plus_modulation_peak_to_base','cs_minus_modulation_peak_to_base','cs_plus_modulation_min_to_base','cs_minus_modulation_min_to_base','cs_plus_ramping',...
    'cs_plus_detection_speed','cs_minus_detection_speed','cs_plus_switch_latency_at_cs_rev1','cs_minus_switch_latency_at_cs_rev1','cs_plus_switch_latency_at_cs_rev2','cs_minus_switch_latency_at_cs_rev2',...
    'cs_plus_switch_latency_at_cs_rev3','cs_minus_switch_latency_at_cs_rev3','cs_plus_switch_latency_at_cs_rev4','cs_minus_switch_latency_at_cs_rev4',...
    'pause_duration_at_CS_shaping_rev_1to2','pause_duration_at_CS_shaping_rev_1toLate','pause_duration_at_CS_shaping_rev_2toLate',...
    'pause_duration_at_US_rev1','pause_duration_at_US_rev2','pause_duration_at_US_rev3','pause_duration_at_US_rev4',...
    'delay_avoidance_learner','giving_up_at_US_rev1','giving_up_at_US_rev2','giving_up_at_US_rev3','giving_up_at_US_rev4'}) & ...
    ~contains(lick_params_short.Properties.VariableNames,{'intraphase','crossreversal'});
LickMetrics = lick_params_short(:,selection);
% 
CombinedMetrics = [TubeMetrics,LickMetrics(:,[2:end])];
[r_MAT,p_MAT] = corr(table2array(CombinedMetrics(:,[2:end])))
figure; imagesc(r_MAT.*(p_MAT<.1)); ax=gca; ax.Colormap=jet; names=CombinedMetrics.Properties.VariableNames(2:end); ax.YTick=[1:1:65]; ax.XTick=[1:1:65];  ax.YTickLabel=names; %ax.XTickLabel=names; rotateXLabels(ax,90)


[r_MAT,p_MAT] = corr(table2array(TubeMetrics(:,[2:end])),'type','Pearson')
figure; imagesc(r_MAT.*(p_MAT<.1)); ax=gca; ax.Colormap=jet; names=TubeMetrics.Properties.VariableNames(2:end); ax.YTick=[1:1:14]; ax.XTick=[1:1:14];  ax.YTickLabel=names; ax.XTickLabel=names; rotateXLabels(ax,90)

% Original data
data = TubeMetrics.fr_chaser;
% Add a small constant to avoid zero or negative values
epsilon = 1e-6; % Small constant
data_adj = data + epsilon;
% Define a range of lambda values to test
lambda_values = -2:0.01:2;
% Initialize variable to store the maximum log-likelihood and the best lambda
max_log_likelihood = -Inf;
best_lambda = NaN;
% Iterate over each lambda value
for lambda = lambda_values
if lambda == 0
% For lambda = 0, use log transformation
transformed_data = log(data_adj);
else
% Box-Cox transformation for lambda != 0
transformed_data = (data_adj .^ lambda - 1) / lambda;
end
% Calculate the log-likelihood
n = length(data_adj);
log_likelihood = -n/2 * log(var(transformed_data)) + (lambda - 1) * sum(log(data_adj));
% Update the best lambda if the current log-likelihood is higher
if log_likelihood > max_log_likelihood
max_log_likelihood = log_likelihood;
best_lambda = lambda;
end
end
% Display the optimal lambda
disp('Optimal Lambda:');
disp(best_lambda);

transformed_data = (data_adj .^ best_lambda - 1) / best_lambda;




[~,idx]=sort(DS_info1_3to16.Rank)
myMat(:,:,1)=DS_info1_3to16.match_matrix(idx,idx);%./max(max(DS_info1_3to16.match_matrix))
[~,idx]=sort(DS_info1_8to21.Rank)
myMat(:,:,2)=DS_info1_8to21.match_matrix(idx,idx);%./max(max(DS_info1_8to21.match_matrix))
[~,idx]=sort(DS_info2.Rank)
myMat(:,:,3)=DS_info2.match_matrix(idx,idx);%./max(max(DS_info2.match_matrix));
myMat(:,:,4)=DS_info2.match_matrix(idx,idx);%./max(max(DS_info2.match_matrix));
figure(1); subplot(2,2,1); imagesc(squeeze(sum(myMat,3)))

[~,idx]=sort(DSchasing_info1_3to16.Rank)
myMat(:,:,1)=DSchasing_info1_3to16.match_matrix(idx,idx);%./max(max(DSchasing_info1_3to16.match_matrix))
[~,idx]=sort(DSchasing_info1_8to21.Rank)
myMat(:,:,2)=DSchasing_info1_8to21.match_matrix(idx,idx);%./max(max(DSchasing_info1_8to21.match_matrix))
[~,idx]=sort(DSchasing_info2.Rank)
myMat(:,:,3)=DSchasing_info2.match_matrix(idx,idx);%./max(max(DSchasing_info2.match_matrix));
myMat(:,:,4)=DSchasing_info2.match_matrix(idx,idx);%./max(max(DSchasing_info2.match_matrix));
subplot(2,2,2); imagesc(squeeze(sum(myMat,3)))
