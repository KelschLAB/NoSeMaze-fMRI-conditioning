%% master_ModMedAna_BOLD_globalGA_NoSeMaze_reappraisal_jr.m

% Script for correlation between the change in betas and the change in global graph
% metrics
% Reinwald, 06/2022

% Before running the script calculate beta coefficients and global metrics:

% 1. run master_calculate_and_plot_mean_betas_jr.m to calculate and save
% beta coefficients in GLM folder (under respictive comparison, e.g.
% TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40) --> mask_activation_Ins_T3485_v24.mat

% 2. run plot_pairedTT_globMetGA_reappraisal_jr.m to calculate and save
% global graph metrics in
% /home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/cormat_v8/combined_hemisphere/bin_connected
% --> res_auc_struc.mat

%% Clearing
clear all
close all
clc

%% Comparison selection
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';
% name_TP1='Odor11to40';
% name_TP2='TPnoPuff11to40';
% name_TP1='Odor81to120';
% name_TP2='TPnoPuff81to120';
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';

%% Selection of input
% beta selection
beta_selection = 'antINS';%'antINS';%  'vHC'
threshold_selection = 'T01';%V 'T001'

% cormat version
cormat_version = 'cormat_v11';%'cormat_v11';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';

%% Load NoSeMaze input (social hierarchy and chasing data)
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% load different hierarchies
% animals in AM1 were scanned at different days (either D45 or D51)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info1_3to16 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_3to16.DS]);
[~,Rank]=sort(Idx);
DS_info1_3to16.Rank = Rank;
DS_info1_3to16.DSzscored = zscore([DS_info1_3to16.DS]);
% chasing
DSchasing_info1_3to16 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_3to16.DS]);
[~,Rank]=sort(Idx);
DSchasing_info1_3to16.Rank = Rank;
DSchasing_info1_3to16.DSzscored = zscore([DSchasing_info1_3to16.DS]);

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day8to21_12mice_withChasing.mat','DS_info','DS_info_chasing');
DS_info1_8to21 = DS_info;
clear Idx Rank
% tube hierarchy
[~,Idx]=sort([DS_info1_8to21.DS]);
[~,Rank]=sort(Idx);
DS_info1_8to21.Rank = Rank;
DS_info1_8to21.DSzscored = zscore([DS_info1_8to21.DS]);
% chasing
DSchasing_info1_8to21 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_8to21.DS]);
[~,Rank]=sort(Idx);
DSchasing_info1_8to21.Rank = Rank;
DSchasing_info1_8to21.DSzscored = zscore([DSchasing_info1_8to21.DS]);

% animals in AM1 were scanned at different days (either D44 and D45)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14_12mice_withChasing.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info2 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info2.DS]);
[~,Rank]=sort(Idx);
DS_info2.Rank = Rank;
DS_info2.DSzscored = zscore([DS_info2.DS]);
% chasing
DSchasing_info2 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info2.DS]);
[~,Rank]=sort(Idx);
DSchasing_info2.Rank = Rank;
DSchasing_info2.DSzscored = zscore([DSchasing_info2.DS]);

clear info
counter=1;
for idxT = 1:size(T,1)
    % add info on IDs
    info.ID_own{counter}=T.AnimalIDCombined{idxT};
    % add infos on Davids Score and Rank for NoSeMaze 1
    if T.Autonomouse(idxT)==1
        info.NoSeMaze(counter)=1;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        if contains(T.DaysToConsider{idxT},'16')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_3to16.DS(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_3to16.Rank(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_3to16.DSzscored(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_3to16.DS(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_3to16.Rank(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_3to16.DSzscored(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
        elseif contains(T.DaysToConsider{idxT},'21')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_8to21.DS(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_8to21.Rank(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_8to21.DSzscored(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_8to21.DS(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_8to21.Rank(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_8to21.DSzscored(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
        end
        counter=counter+1;
        % add infos on Davids Score and Rank for NoSeMaze 2
    elseif T.Autonomouse(idxT)==2
        info.NoSeMaze(counter)=2;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        % tube hierarchy
        info.DS_own(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.Rank_own(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.DSzscored_own(counter)=DS_info2.DSzscored(strcmp(DS_info2.ID,info.ID_own{counter}));
        % chasing
        info.DS_chasing(counter)=DSchasing_info2.DS(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.Rank_chasing(counter)=DSchasing_info2.Rank(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.DSzscored_chasing(counter)=DSchasing_info2.DSzscored(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        counter=counter+1;
    end
end

ExplVar(1).name = 'DavidsScore';
ExplVar(1).values = info.DS_own';
ExplVar(1).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_own','descend');
ExplVar(1).DS_sorted = DSv;
ExplVar(1).DS_sortedIndex = DSi;

ExplVar(2).name = 'Rank';
ExplVar(2).values = info.Rank_own';
ExplVar(2).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_own','descend');
ExplVar(2).DS_sorted = DSv;
ExplVar(2).DS_sortedIndex = DSi;

ExplVar(3).name = 'DavidsScore_zscored';
ExplVar(3).values = info.DSzscored_own';
ExplVar(3).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_own','descend');
ExplVar(3).DS_sorted = DSv;
ExplVar(3).DS_sortedIndex = DSi;

ExplVar(4).name = 'DavidsScoreChasing';
ExplVar(4).values = info.DS_chasing';
ExplVar(4).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_chasing','descend');
ExplVar(4).DS_sorted = DSv;
ExplVar(4).DS_sortedIndex = DSi;

ExplVar(5).name = 'RankChasing';
ExplVar(5).values = info.Rank_chasing';
ExplVar(5).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_chasing','descend');
ExplVar(5).DS_sorted = DSv;
ExplVar(5).DS_sortedIndex = DSi;

ExplVar(6).name = 'DavidsScoreChasing_zscored';
ExplVar(6).values = info.DSzscored_chasing';
ExplVar(6).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_chasing','descend');
ExplVar(6).DS_sorted = DSv;
ExplVar(6).DS_sortedIndex = DSi;

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Load beta coefficients (saved in script master_calculate_and_plot_mean_betas_jr.m)
% res.mat
if strcmp(cormat_version,'cormat_v11')
    if strcmp(beta_selection,'antINS')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'vHC')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
    end
elseif strcmp(cormat_version,'cormat_v14')
    if strcmp(beta_selection,'antINS')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_TPbl3vsbl1_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'vHC')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_rank_' threshold_selection '.mat']);
    end
end

%% Load global metrics (saved in plot_pairedTT_globMetGA_reappraisal_jr.m)
% res_auc_struc_global.mat -->  res_auc_struc
if separated_hemisphere==1
    %     load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version '/separated_hemisphere/' binarization_method '_' connectedness '/res_auc_struc.mat']);
    load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/global_45to50/res_auc_struc_global.mat']);
elseif separated_hemisphere==0
    load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/global_45to50/res_auc_struc_global.mat']);
end
% define global metrics
global_metrics = fieldnames(res_auc_struc);

%% Output directory
outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-BOLD_to_GA');
if separated_hemisphere==1
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-BOLD_to_GA',cormat_version,'separated_hemisphere',[binarization_method '_' connectedness],[name_TP1 'VS' name_TP2]);
elseif separated_hemisphere==0
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-BOLD_to_GA',cormat_version,'combined_hemisphere',[binarization_method '_' connectedness],[name_TP1 'VS' name_TP2]);
end
mkdir(outputDir);
cd(outputDir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over global metrics
for ix=[16,17]%1:length(global_metrics)
    % figure
    fig(ix)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
    % Statistics
    %
%     if strcmp(beta_selection,'antINS') && strcmp(cormat_version,'cormat_v11')
%         beta_diff = [res.mean_beta_TP_Puff_Bl3]'-[res.mean_beta_TP_Puff_Bl1_11to40]';
%         GA_diff = [res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40];
%     else
        beta_diff = [res.mean_betaPos]'-[res.mean_betaNeg]';
        GA_diff = [res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40];
%     end
    % 1. Pearson
    [h_p(ix),p_p(ix)]=corr(beta_diff,GA_diff,'type','Pearson');
    
    % 2. Spearman
    [h_sp(ix),p_sp(ix)]=corr(beta_diff,GA_diff,'type','Spearman');
    
    % Subplot 2:
    subplot(2,2,1:2);
    % scatter plot
    
    sc(1)=scatter(beta_diff,GA_diff);
    sc(1).MarkerFaceAlpha=1; sc(1).SizeData=20;
    sc(1).MarkerFaceColor=[.8 .4 .4];
    sc(1).MarkerEdgeAlpha=1;
    sc(1).MarkerEdgeColor='none';
    % axes definition
    ax=gca;
    ax.XLabel.String = {'beta. [diff bl3-bl1]'};
    ax.YLabel.String = {'Global Metric [diff. bl3-bl1]'};
    ax.LineWidth = 1.5;
    % line
    ll=lsline;
    ll.LineWidth=1.5;
    ll.Color=[.8 .4 .4];
    ll.LineStyle='--';
    % title
    tt=title([global_metrics{ix} ', Pearson']);
    tt.Interpreter='none';
    % text
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(p_p(ix),2))]);
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['rho=' num2str(round(h_p(ix),2))]);
    
    % Subplot 2:
    subplot(2,2,3:4);
    % scatter plot
    clear A1 A2 B1 B2
    [~,A1]=sort(beta_diff);
    [~,B1]=sort(A1);
    [~,A2]=sort(GA_diff);
    [~,B2]=sort(A2);
    sc(1)=scatter(B1,B2);
    sc(1).MarkerFaceAlpha=1; sc(1).SizeData=20;
    sc(1).MarkerFaceColor=[.8 .4 .4];
    sc(1).MarkerEdgeAlpha=1;
    sc(1).MarkerEdgeColor='none';
    % axes definition
    ax=gca;
    ax.XLabel.String = {'Beta [rank, diffTP2-TP1]'};
    ax.YLabel.String = {'Global Metric [rank, diffTP2-TP1]'};
    ax.XLim=[0,25];
    ax.YLim=[0,25];
    ax.LineWidth = 1.5;
    % line
    ll=lsline;
    ll.LineWidth=1.5;
    ll.Color=[.8 .4 .4];
    ll.LineStyle='--';
    % title
    tt=title({[global_metrics{ix} ', Spearman'],[name_TP2 ' vs ' name_TP1]});
    tt.Interpreter='none';
    % text
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(p_sp(ix),2))]);
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['rho=' num2str(round(h_sp(ix),2))]);
    
    % print
%     [annot, srcInfo] = docDataSrc(fig(ix),outputDir,mfilename('fullpath'),logical(1))
%     exportgraphics(fig(ix),fullfile(outputDir,['Correlation_BOLD_to_' global_metrics{ix} '_' beta_selection '_' threshold_selection '.pdf']),'Resolution',300);
%     print('-dpsc',fullfile(outputDir,['Correlation_BOLD_to_allGlobalMetrics_' beta_selection '_' threshold_selection]),'-painters','-r400','-append');
    
    %% ----------------------------------------------------------------- %%
    %% Investigation of mediator/modulator effects
    %% ----------------------------------------------------------------- %%
    %% Loop over NoSeMaze-Variables
    for varIdx = 2:3%length(ExplVar)
        
        %% 1. Sort NoSeMaze variable
        [~,sortIdx]=sort(ExplVar(varIdx).AnimalNumb);
        NoSeMaze_input = ExplVar(varIdx).values(sortIdx);
        
        %% 2. Mediation Analysis
        % Step 1: Regress NoSeMaze_input (Ausgangsvariable) on NoSeMaze_input
        % (Mediator)
        mdl1 = fitlm(NoSeMaze_input, GA_diff);
        
        % Step 2: Regress NoSeMaze_input (Mediator) on beta_diff (Endvariable)
        mdl2 = fitlm(GA_diff, beta_diff);
        
        % Step 3: Regress 
        mdl3 = fitlm(NoSeMaze_input, beta_diff);
        
        % Step 4: Regress GA_diff on beta_diff (controlling for NoSeMaze_input)
        mdl4 = fitlm([NoSeMaze_input, GA_diff], beta_diff);
        
        % Assess mediation
        mediationResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).mediator_coeff(ix) = mdl4.Coefficients.Estimate(3);
        mediationResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).p_value_mediator(ix) = mdl4.Coefficients.pValue(3);
        mediationResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).comparison_name{ix} = global_metrics{ix};       
        
        if mediationResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).p_value_mediator(ix) < 0.05
            disp('Mediation effect detected.');
            if mediationResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).mediator_coeff(ix) < 0
                disp('Mediator (social hierarchy) decreases the effect of GA_diff on beta_diff.');
            else
                disp('Mediator increases the effect of GA_diff on beta_diff.');
            end
        else
            disp('No significant mediation effect.');
        end
        
        %% 3. Moderator Analysis
        % Step 1: Create interaction term
        interaction_term = GA_diff .* NoSeMaze_input;
        
        % Step 2: Include interaction term in regression model
        mdl_mod = fitlm([GA_diff, NoSeMaze_input, interaction_term], beta_diff);
        
        % Assess moderation
        moderatorResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).interaction_coeff(ix) = mdl_mod.Coefficients.Estimate(4);
        moderatorResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).p_value_interaction(ix) = mdl_mod.Coefficients.pValue(4);
        moderatorResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).comparison_name{ix} = global_metrics{ix};
        
        if moderatorResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).p_value_interaction(ix) < 0.05
            disp('Moderator effect detected.');
            if moderatorResults.([beta_selection '_' threshold_selection]).(ExplVar(varIdx).name).interaction_coeff(ix) > 0
                disp('Moderator strengthens the effect of beta_diff on GA_diff.');
            else
                disp('Moderator weakens the effect of beta_diff on GA_diff.');
            end
        else
            disp('No significant moderator effect.');
        end
    end
    
    close all;
end