%% master_corr_meanBOLD_to_NoSeMazeSH_reappraisal_jr.m
% Reinwald, Jonathan; 08/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate
% - run XXX BEFORE

%% Preparation
clear all;
close all;

%% Comparison selection
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';

%% Selection of input
% beta selection
beta_selection = 'vHC';%'antINS';%  'vHC'
threshold_selection = 'T001';%V 'T001' % 'FWE05vHC' FWE_TempA;FWE_all --> all FWE voxels from the cluster

% Chose whether you want to use the data with or without scrubbing
scrubbed_version = 'no_scrubbing'; %'scrubbing';'no_scrubbing'

% working directory
workDir = '/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/08-correlation_analyses_fMRI_to_NoSeMaze/01-BOLD_to_NoSeMaze';
cd(workDir);

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

%% Load NoSeMaze input (social hierarchy and chasing data)
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% load different hierarchies
% animals in AM1 were scanned at different days (either D45 or D51)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
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
for varIdx=1:length(ExplVar)
    for jx=1:length(ExplVar(varIdx).ID)
        ExplVar(varIdx).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(varIdx).ID(jx))).AnimalNumb;
    end
end

%% plots
% for ix=1:length(ExplVar)
%     f = plot_David_score_in_group(ExplVar(ix),ExplVar(ix).ID);
%     exportgraphics(f, fullfile(outputDir,['rank_plot_day_' ExplVar(ix).name '.pdf']),'ContentType','vector','BackgroundColor','none');
%     close all;
% end

%% Load beta coefficients (saved in script master_calculate_and_plot_mean_betas_jr.m)
% res.mat
if strcmp(scrubbed_version,'no_scrubbing')
    if strcmp(beta_selection,'antINS')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'vHC')
%         load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_positiveCorrRank_' threshold_selection '.mat']);
    end
elseif strcmp(scrubbed_version,'scrubbing')
    if strcmp(beta_selection,'antINS')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_TPbl3vsbl1_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'vHC')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_rank_' threshold_selection '.mat']);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over ExplVar
for varIdx = 2:length(ExplVar)
    
    %% Create output directory
    outputDir = fullfile(workDir,'corr_SocialHierarchy',[name_TP1 'VS' name_TP2 '_' scrubbed_version],ExplVar(varIdx).name);
    if ~exist(outputDir)
        mkdir(outputDir)
    end
    
    % figure
    fig(varIdx)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
    
    %% Load and calculate beta difference (BOLD)
    if strcmp(beta_selection,'antINS') && strcmp(scrubbed_version,'scrubbing')
        beta_diff = [res.mean_beta_TP_Puff_Bl3]'-[res.mean_beta_TP_Puff_Bl1_11to40]';
        beta_bl1 = [res.mean_beta_TP_Puff_Bl1_11to40]';
        beta_bl3 = [res.mean_beta_TP_Puff_Bl3]';
    else
        beta_diff = [res.mean_betaPos]'-[res.mean_betaNeg]';
        beta_bl1 = [res.mean_betaNeg]';
        beta_bl3 = [res.mean_betaPos]';
    end
    
    %% Sort NoSeMaze variable
    [~,sortIdx]=sort(ExplVar(varIdx).AnimalNumb);
    NoSeMaze_input = ExplVar(varIdx).values(sortIdx);
    
    % Correlations: 
    [rr(1),pp(1)]=corr(NoSeMaze_input,beta_bl1,'type','Pearson');
    [rr(2),pp(2)]=corr(NoSeMaze_input,beta_bl1,'type','Spearman');
    [rr(3),pp(3)]=corr(NoSeMaze_input,beta_bl3,'type','Pearson');
    [rr(4),pp(4)]=corr(NoSeMaze_input,beta_bl3,'type','Spearman');
    [rr(5),pp(5)]=corr(NoSeMaze_input,beta_diff,'type','Pearson'); 
    [rr(6),pp(6)]=corr(NoSeMaze_input,beta_diff,'type','Spearman');
    
    %% subplot
    subplot(2,3,1);
    % boxplot
    bb=notBoxPlot_modified([beta_bl1,beta_bl3]);
    for ib=1:length(bb)
        bb(ib).data.MarkerSize=6;
        bb(ib).data.MarkerEdgeColor='none';
        bb(ib).semPtch.EdgeColor='none';
        bb(ib).sdPtch.EdgeColor='none';
    end
    % color definitions
    bb(1).data.MarkerFaceColor= [204/255 51/255 204/255];
    bb(1).mu.Color= [204/255 51/255 204/255];
    bb(1).semPtch.FaceColor= [255/255 102/255 204/255];
    bb(1).sdPtch.FaceColor= [255/255 204/255 204/255];
    % color definitions
    bb(2).data.MarkerFaceColor= [0 160/255 227/255];
    bb(2).mu.Color= [0 160/255 227/255];
    bb(2).semPtch.FaceColor= [75/255 207/255 227/255];
    bb(2).sdPtch.FaceColor= [150/255 255/255 227/255];
    
    % axis
    box('off');
    ax1=gca;
    %     ax1.YLim=[axlimit{ig}];
    ax1.YLabel.String={'mean BOLD'};
    ax1.XTickLabel={'pre','test'};
    ax1.FontSize=10;
    ax1.FontWeight='bold';
    ax1.LineWidth=1.5;
    ax1.XLim=[.5,2.5];
    %     rotateXLabels(ax1,45);
    
    % significance test
    [h,p]=ttest(beta_bl1,beta_bl3);
    [clusters, p_values, t_sums, permutation_distribution ] = permutest(beta_bl1',beta_bl3',true,0.05,10000,true);
    % sign. star
    if p_values<0.05
        H=sigstar({[1,2]},p_values,0,10);
    end
    
    % plot permutation result
    tx=text(ax1.XLim(1)+.1*(diff(ax1.XLim)),ax1.YLim(1)+.2*(diff(ax1.YLim)),['p_p_e_r_m=' num2str(p_values)]);
    tx.Interpreter='tex';
    
    %% subplot
    subplot(2,3,[2,3]);
    % scatter
    sc(1)=scatter(NoSeMaze_input,beta_bl1); hold on;
    sc(2)=scatter(NoSeMaze_input,beta_bl3);
    for isc=1:length(sc)
        sc(isc).SizeData=40;
        sc(isc).MarkerEdgeColor='none';
    end
    % color definitions
    sc(1).MarkerFaceColor= [204/255 51/255 204/255];
    % color definitions
    sc(2).MarkerFaceColor= [0 160/255 227/255];
    
    % axis
    box('off');
    axis square;
    ax2=gca;
    ax2.YLabel.String={'mean BOLD'};
    ax2.XLabel.String=ExplVar(varIdx).name;
    if contains(ExplVar(varIdx).name,'Rank');
        ax2.XLim=[1,12];
        ax2.XTick=[1:1:12];
        ax2.XTickLabel=[1:1:12];
    end
    ax2.YLim(2)=ax1.YLim(2);
    ax2.FontSize=10;
    ax2.FontWeight='bold';
    ax2.LineWidth=1.5;
    
    % plot correlation lines
    ll = lsline;
    ll(1).Color=[0 160/255 227/255];
    ll(1).LineWidth=1.5;
    ll(2).Color=[204/255 51/255 204/255];
    ll(2).LineWidth=1.5;
    
    % plot permutation result
    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['p=' num2str(round(pp(1),3))]);
    tx.Color=[204/255 51/255 204/255];
    tx.FontWeight='bold';
    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['p=' num2str(round(pp(3),3))]);
    tx.Color=[0 160/255 227/255];
    tx.FontWeight='bold';
    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['rho=' num2str(round(rr(1),3))]);
    tx.Color=[204/255 51/255 204/255];
    tx.FontWeight='bold';
    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['rho=' num2str(round(rr(3),3))]);
    tx.Color=[0 160/255 227/255];
    tx.FontWeight='bold';
    
    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.9*(diff(ax2.YLim)),['psp=' num2str(round(pp(2),3))]);
    tx.Color=[204/255 51/255 204/255];
    tx.FontWeight='bold';
    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.8*(diff(ax2.YLim)),['psp=' num2str(round(pp(4),3))]);
    tx.Color=[0 160/255 227/255];
    tx.FontWeight='bold';
    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.9*(diff(ax2.YLim)),['rhosp=' num2str(round(rr(2),3))]);
    tx.Color=[204/255 51/255 204/255];
    tx.FontWeight='bold';
    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.8*(diff(ax2.YLim)),['rhosp=' num2str(round(rr(4),3))]);
    tx.Color=[0 160/255 227/255];
    tx.FontWeight='bold';
    
    %% subplot
    subplot(2,3,[5,6]);
    % boxplot
    sc=scatter(NoSeMaze_input,[beta_bl3-beta_bl1]);
    sc.SizeData=40;
    sc.MarkerEdgeColor='none';
    
    % color definitions
    sc.MarkerFaceColor= ([204/255 51/255 204/255]+[0 160/255 227/255])./2;
    
    % axis
    box('off');
    axis square;
    ax=gca;
    ax.YLabel.String={'mean BOLD','(beta values; test - pre)'};
    ax.XLabel.String=ExplVar(varIdx).name;
    if contains(ExplVar(varIdx).name,'Rank');
        ax.XLim=[1,12];
        ax.XTick=[1:1:12];
        ax.XTickLabel=[1:1:12];
    end
    ax.FontSize=10;
    ax.FontWeight='bold';
    ax.LineWidth=1.5;
    
    % plot correlation lines
    ll = lsline;
    ll.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
    ll.LineWidth=1.5;
    
    % plot permutation result
    tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['p=' num2str(round(pp(5),3))]);
    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
    tx.FontWeight='bold';
    tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['rho=' num2str(round(rr(5),3))]);
    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
    tx.FontWeight='bold';
    tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_s_p=' num2str(round(pp(6),3))]);
    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
    tx.FontWeight='bold';
    tx.Interpreter='tex';
    tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['rho_s_p=' num2str(round(rr(6),3))]);
    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
    tx.FontWeight='bold';
    tx.Interpreter='tex';
    
    % title
    supt=suptitle({ExplVar(varIdx).name,[beta_selection '_' threshold_selection]});
    supt.Interpreter='none';
    
    % 
    ax1.YLim=ax2.YLim;
    
    % print
    [annot, srcInfo] = docDataSrc(fig(varIdx),fullfile(outputDir),mfilename('fullpath'),logical(1));
    exportgraphics(fig(varIdx),fullfile(outputDir,['Correlation_BOLD_to_' ExplVar(varIdx).name '_' beta_selection '_' threshold_selection '.pdf']),'Resolution',300);
                
    % save source data in csv
    SourceData = array2table([NoSeMaze_input,beta_bl1,beta_bl3,beta_diff],'VariableNames',{ExplVar(varIdx).name,'beta_block1','beta_block3','diff'});
    writetable(SourceData,fullfile(outputDir,['SourceData_Correlation_BOLD_to_' ExplVar(varIdx).name '_' beta_selection '_' threshold_selection '.csv']),'WriteVariableNames',true,'WriteRowNames',true)

end
close all