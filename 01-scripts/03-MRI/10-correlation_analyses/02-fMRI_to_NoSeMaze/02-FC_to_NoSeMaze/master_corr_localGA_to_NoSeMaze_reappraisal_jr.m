%% master_corr_localGA_to_NoSeMaze_reappraisal_jr.m
% Jonathan Reinwald, 01/2023

%% Clearing
clear all
close all

%% Predefinitions
% cormat
suffix = 'v11';
cormat_version = ['cormat_' suffix ];
% bi-/unihemispheric atlas
separated_hemisphere = 1;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';

%% Comparison selection
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';
%% Comparison selection
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));

%% Load local metrics (saved in plot_pairedTT_globMetGA_reappraisal_jr.m)
% res_auc_struc_global.mat -->  res_auc_struc
if separated_hemisphere==1
    load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/res_auc_struc_local.mat']);
elseif separated_hemisphere==0
    load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/res_auc_struc_local.mat']);
end
% define global metrics
local_metrics = fieldnames(res_auc_struc);   

%% Load regional names
if separated_hemisphere==1
    load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version '/beta4D/separated_hemisphere/roidata_' cormat_version(strfind(cormat_version,'v'):end) '_Odor81to120.mat']);
elseif separated_hemisphere==0
    load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version '/beta4D/combined_hemisphere/roidata_' cormat_version(strfind(cormat_version,'v'):end) '_Odor81to120.mat']);    
end
names = {subj(1).roi.name};

%% Output directory
if separated_hemisphere==1
    outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/corrGAtoNoSeMaze'];
elseif separated_hemisphere==0
    outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/corrGAtoNoSeMaze'];
end
mkdir(outputDir);
cd(outputDir);

%% Load regressors of interest: For each animal, social hierarchy/chasing is used based on the 14 days before the scans
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

%% Loop over explanatory variables
clear h_p p_p h_sp p_sp
for varIdx = 1:length(ExplVar)
    
    % sort by animal number
    [B,Idx]=sort(ExplVar(varIdx).AnimalNumb,'ascend');
    input_table = table(B,[ExplVar(varIdx).values(Idx)],'VariableNames',{'No.','DavidsScore'});
    
    % INS
%     load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T01.mat');
    % vHC
%     load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_T01.mat');
    % bl2, 
%     load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl_2/mask_activation_corrRank_own_T001.mat');
%     load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl_2/mask_activation_corrRank_own_T01.mat');
    
%     input_table = table([res.mean_beta_TP_Puff_Bl3-res.mean_beta_TP_Puff_Bl1_11to40]',[res.mean_beta_TP_Puff_Bl3-res.mean_beta_TP_Puff_Bl1_11to40]','VariableNames',{'spaceholder','beta_Ins'});
%     input_table = table([res.mean_betaPos-res.mean_betaNeg]',[res.mean_betaPos-res.mean_betaNeg]','VariableNames',{'spaceholder','beta_Ins'});

    %% Loop over local metrics
    for lmIdx = 1:length(local_metrics)
              
        %% Loop over regions of interest
        roi_names=fieldnames(res_auc_struc.(local_metrics{lmIdx}).(name_TP2));
        for roi_idx = 1:length(roi_names)
            % create metric difference
            myMetric_diff = res_auc_struc.(local_metrics{lmIdx}).(name_TP2).(names{roi_idx})-res_auc_struc.(local_metrics{lmIdx}).(name_TP1).(names{roi_idx});
            
            [h_p.(local_metrics{lmIdx}).(ExplVar(varIdx).name)(roi_idx,1),p_p.(local_metrics{lmIdx}).(ExplVar(varIdx).name)(roi_idx,1)]=corr(myMetric_diff,table2array(input_table(:,2)),'type','Pearson');
            [h_sp.(local_metrics{lmIdx}).(ExplVar(varIdx).name)(roi_idx,1),p_sp.(local_metrics{lmIdx}).(ExplVar(varIdx).name)(roi_idx,1)]=corr(myMetric_diff,table2array(input_table(:,2)),'type','Spearman');
%       
        end
    end

end
    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% STATISTICS for all local metrics
% clear h_p p_p h_sp p_sp
% % Loop over local metrics
% for ix=1:length(local_metrics)   
%     % Loop over regions of interes
%     for jx=1:length(names)        
%         [h_p(ix,jx),p_p(ix,jx)]=corr(myMetric_diff',table2array(input_table(:,2),'type','Pearson');
%         [h_sp(ix,jx),p_sp(ix,jx)]=corr(([res.mean_beta_TP_Puff_Bl3]'-[res.mean_beta_TP_Puff_Bl1_11to40]'),([res_auc_struc.(local_metrics{ix}).TPnoPuff81to120.(names{jx})]-[res_auc_struc.(local_metrics{ix}).TPnoPuff11to40.(names{jx})]),'type','Spearman');
% %         [h_p(ix,jx),p_p(ix,jx)]=corr(([res.mean_beta_Lavender_Bl3]'-[res.mean_beta_Lavender_Bl1_11to40]'),([res_auc_struc.(local_metrics{ix}).Odor81to120.(names{jx})]-[res_auc_struc.(local_metrics{ix}).Odor11to40.(names{jx})]),'type','Pearson');
% %         [h_sp(ix,jx),p_sp(ix,jx)]=corr(([res.mean_beta_Lavender_Bl3]'-[res.mean_beta_Lavender_Bl1_11to40]'),([res_auc_struc.(local_metrics{ix}).Odor81to120.(names{jx})]-[res_auc_struc.(local_metrics{ix}).Odor11to40.(names{jx})]),'type','Spearman');
%     end
% end
% 
% %% Plot overview figure
% % Figure
% f=figure(1);
% set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.35,0.7]);
% 
% % Subplot
% sp1=subplot(1,4,1);
% imagesc([p_p<0.05]');
% % axes
% ax=gca;
% ax.XTick=[1:size(p_p,1)];
% ax.XTickLabel=local_metrics;
% ax.YTick=[1:size(p_p,2)];
% ax.YTickLabel=names;
% rotateXLabels(ax,90);
% set(gca,'TickLabelInterpreter','none')
% % Sign
% [x1,y1]=find(p_p<.05);
% for ix=1:length(x1)
%     if p_p(x1(ix),y1(ix))<.001
%         tx=text(x1(ix),y1(ix),'$');
%         tx.FontSize=8;
%     elseif p_p(x1(ix),y1(ix))<.01
%         tx=text(x1(ix),y1(ix),'§');
%         tx.FontSize=8;
%     elseif p_p(x1(ix),y1(ix))<.05
%         tx=text(x1(ix),y1(ix),'*');
%         tx.FontSize=8;
%     end
% end
% % title
% tt=title(['Pearson (p<.05)']);
% 
% tx=text(-6,-1,'*: p<.05');
% tx.FontSize=8;
% tx=text(-6,-2,'§: p<.01');
% tx.FontSize=8;
% tx=text(-6,-3,'$: p<.001');
% tx.FontSize=8;
% 
% 
% % Subplot
% sp2=subplot(1,4,2);
% imagesc([h_p]');
% % axes
% ax=gca;
% ax.XTick=[1:size(p_p,1)];
% ax.XTickLabel=local_metrics;
% ax.YTick=[1:size(p_p,2)];
% ax.YTickLabel=names;
% colormap(sp2,jet);
% ax.CLim=[-0.6,0.6];
% rotateXLabels(ax,90);
% set(gca,'TickLabelInterpreter','none')
% % title
% tt=title(['Pearson (rho)']);
% 
% % Subplot
% sp3=subplot(1,4,3);
% imagesc([p_sp<0.05]');
% % axes
% ax=gca;
% ax.XTick=[1:size(p_sp,1)];
% ax.XTickLabel=local_metrics;
% ax.YTick=[1:size(p_sp,2)];
% ax.YTickLabel=names;
% rotateXLabels(ax,90);
% set(gca,'TickLabelInterpreter','none')
% % Sign
% [x1,y1]=find(p_sp<.05);
% for ix=1:length(x1)
%     if p_sp(x1(ix),y1(ix))<.001
%         tx=text(x1(ix),y1(ix),'$');
%         tx.FontSize=8;
%     elseif p_sp(x1(ix),y1(ix))<.01
%         tx=text(x1(ix),y1(ix),'§');
%         tx.FontSize=8;
%     elseif p_sp(x1(ix),y1(ix))<.05
%         tx=text(x1(ix),y1(ix),'*');
%         tx.FontSize=8;
%     end
% end
% % title
% tt=title(['Spearman (p<.05)']);
% 
% % Subplot
% sp4=subplot(1,4,4);
% imagesc([h_sp]');
% % axes
% ax=gca;
% ax.XTick=[1:size(p_p,1)];
% ax.XTickLabel=local_metrics;
% ax.YTick=[1:size(p_p,2)];
% ax.YTickLabel=names;
% colormap(sp4,jet);
% ax.CLim=[-0.6,0.6];
% rotateXLabels(ax,90);
% set(gca,'TickLabelInterpreter','none')
% % title
% tt=title(['Spearman (rho)']);
% 
% % print
% print('-dpsc',fullfile(outputDir,['Correlation_BetaCoeffToLocalGA_overview']),'-painters','-r400','-fillpage');
% % print('-dpdf',fullfile(outputDir,['Correlation_BetaCoeffToLocalGA_overview']),'-painters','-r400');
% exportgraphics(f, fullfile(outputDir,['Correlation_BetaCoeffToLocalGA_overview.pdf']),'ContentType','vector','BackgroundColor','none');
% 
% 
% 
% 





