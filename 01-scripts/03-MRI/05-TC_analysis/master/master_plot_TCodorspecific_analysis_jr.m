%% master_plot_TC_analysis_jr
% Reinwald, Jonathan 06/2021

% Run master_TC_analysis_jr.m before to create tc_matrsess_all.mat for all
% regions of interest

%% Preparation
clear all;
close all;
clc;

% set path for scripts
addpath(genpath('/zi-flstorage/data/Jonathan/Programs/spm12'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/toolboxes/spm12_animal'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/MRTPrediction/fMRI/GLM'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/MRTPrediction/fMRI/TC_analysis'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/general/helpers'))


% define paths and regressors/covariates ...
regressorsSuffsess = '_v99.mat';
orth = 1;
covarSuffsess = '_v1.mat';

% selection of EPI
epiPrefsess = 'msk_s_rwst_a1_u_del5_';
% epiPrefsess = 's_rwst_a1_u_del5_';
% epiPrefsess = 's6_wave_10cons_med1000_msk_rwst_a1_u_del5_';
epiSuffsess = '_c1_c2t';
% epiSuffsess = '_c1_c2t_icaden25_16-Feb-2020';
% epiSuffsess = '_c1_c2t_wds';

% general result directory
resultsDir = '/home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/TC_analysis/results';
% outputDirName
if contains(epiSuffsess,'noise')
    outputDirName = [epiSuffsess(end-4:end) '_EPI_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '____Orth_' num2str(orth)];
elseif contains(epiSuffsess,'ica')
    outputDirName = ['EPI_ICA_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '___Orth_' num2str(orth)];
elseif contains(epiPrefsess,'wave')
    outputDirName = ['EPI_WD_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '____Orth_' num2str(orth)];
elseif ~contains(epiSuffsess,'noise')
    outputDirName = ['EPI_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '____Orth_' num2str(orth)];
end
% meanTC directory
meanTCdir = [resultsDir filesep outputDirName filesep 'meanTC'];

% sessect selection
sessions = [1:83];

% load filelist and dstruct
load('/zi-flstorage/data/Jonathan/ICON_RPE/data/MRTPrediction/fMRI/filelists/filelist_awake_MAIN_JR.mat');
load('/zi-flstorage/data/Jonathan/ICON_RPE/data/MRTPrediction/fMRI/d_struct/dstruct_fMRI_MRTPrediction_22-Apr-2021.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Get all directories with meanTCs
dirlist = dir(meanTCdir);
dirlist = dirlist(~contains({dirlist.name},'..') & ~contains({dirlist.name},'.'));

%% Loop over regions of interest
for ix = 1:length(dirlist)
    
    % 1. Load tc-matrix for region of interest
    % - this is a sessions (83) x trials (160) x timepoints (10) matrix
    clear tc_matrsess_all.mat
    load([meanTCdir filesep dirlist(ix).name filesep 'tc_matrsess_all.mat']);
    load([meanTCdir filesep dirlist(ix).name filesep 'FD_matrsess_all.mat']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% I.: SUBPLOT Plot by REWARD/NON-REWARD
    % 1. Create a reward matrix for all sessions in the same format
    % - sessions (83) x trials (160) x timepoints (10)
    clear rew_mat rew_mat_large
    rew_mat=[];
    for sess=sessions
        rew_mat=[rew_mat;[d.events{sess}.drop_or_not]];
    end
    rew_mat_large = repmat(rew_mat,[1,1,10]);
    
    % 2. Create mean_TC matrix for rewarded and non-rewarded trials
    clear mtc_R mtc_NR
    % rewarded:
    mtc_R=squeeze(mean(tc_matrsess_all.*rew_mat_large,1));
    FD_R=squeeze(mean(FD_matrsess_all.*rew_mat_large,1));
    % non-rewarded:
    mtc_NR=squeeze(mean(tc_matrsess_all.*(rew_mat_large==0),1));
    FD_NR=squeeze(mean(FD_matrsess_all.*(rew_mat_large==0),1));
    
    % 3. Figure:
    fig=figure(1);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.5, 0.96]);
    % subplot
    subplot(3,2,1)
    % rewarded:
    sh(1) = shadedErrorBar([1:10],mean(mtc_R),SEM_calc(mtc_R));
    sh(1).mainLine.Color=[0,1,0];
    sh(1).patch.EdgeColor=[0,1,0];
    sh(1).patch.FaceColor=[0,1,0];
    sh(1).edge(1).Color=[1,1,1];
    sh(1).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(2) = shadedErrorBar([1:10],mean(mtc_NR),SEM_calc(mtc_NR));
    sh(2).mainLine.Color=[1,0,0];
    sh(2).patch.EdgeColor=[1,0,0];
    sh(2).patch.FaceColor=[1,0,0];
    sh(2).edge(1).Color=[1,1,1];
    sh(2).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(3) = shadedErrorBar([1:10],mean(FD_R),SEM_calc(FD_R));
    sh(3).mainLine.Color=[.2,.6,.2];
    sh(3).patch.EdgeColor=[.2,.6,.2];
    sh(3).patch.FaceColor=[.2,.6,.2];
    sh(3).edge(1).Color=[1,1,1];
    sh(3).edge(2).Color=[1,1,1];   
    hold on;
    % non-rewarded:
    sh(4) = shadedErrorBar([1:10],mean(FD_NR),SEM_calc(FD_NR));
    sh(4).mainLine.Color=[.6,.2,.2];
    sh(4).patch.EdgeColor=[.6,.2,.2];
    sh(4).patch.FaceColor=[.6,.2,.2];
    sh(4).edge(1).Color=[1,1,1];
    sh(4).edge(2).Color=[1,1,1];       
    
    % Axis
    ax=gca;
    ax.YLim=[-.3,.3];
    ax.YTick=[-.3:.1:.3];
    ax.YLabel.String='Residual BOLD (z-scored)';
    
    ax.XLim=[0,10];
    ax.XLabel.String=['Time'];
    ax.XTick=[0:1:10];
    ax.XTickLabel=[-1.2:1.2:12];
    rotateXLabels(ax,70);
    
    % Odor
    hold on;
    fill([1 1 1+1/1.2 1+1/1.2],[-0.3 0.3 0.3 -0.3],[0.2 0.2 0.8],'FaceColor',[0.2 0.2 0.5],'FaceAlpha',0.1,'EdgeAlpha',0);
    hold on;
    tt=text(1.2,0.2,'Od.');
    tt.Color=[0.2 0.2 0.8];
    
    % Reward
    hold on;
    ll=line([1+2.2/1.2,1+2.2/1.2],[-.3,.3]); % 2.2 as RP-timepoint is actually at 2.7, but we already included the reward delay
    ll.Color=[0.8 0.2 0.8];
    ll.LineWidth=2;
    tt=text(1+2.4/1.2,0.2,'Rew.');
    tt.Color=[0.8 0.2 0.8];
    
    % lgd=legend
    lgd=legend([sh(1).mainLine,sh(2).mainLine],{'rew.','non-rew.'},'Location','southeast');
    lgd.FontSize=6;
    
    % Sign. *
    clear h p
    [h,p]=ttest2(mtc_R,mtc_NR);
    for px=1:length(p)
        if p(px)<0.001
            text(px,0.28,'*');
            text(px,0.295,'*');
            text(px,0.265,'*');
        elseif p(px)<0.01
            text(px,0.28,'*');
            text(px,0.265,'*');
        elseif p(px)<0.05
            text(px,0.28,'*');
        end
    end
    
    % Sign. *
    clear h p
    [h,p]=ttest2(FD_R,FD_NR);
    for px=1:length(p)
        if p(px)<0.001
            text(px,-0.28,'*');
            text(px,-0.295,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.01
            text(px,-0.28,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.05
            text(px,-0.28,'*');
        end
    end
    text(1,-.275,'FD')
    
    % Title
    title({'Reward vs. Non-Rewarded','(no deconv.)'});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% II.: SUBPLOT by 75%/25% (Learnerns vs. Non-Learners) LAST PART
    % 1. Create a reward matrix for all sessions in the same format
    % - sessions (83) x trials (160) x timepoints (10)
    clear RP_mat RP_mat_large Od_mat Od_mat_large
    RP_mat=[];
    Od_mat=[];
    for sess=sessions
        RP_mat=[RP_mat;[d.events{sess}.rew_prob_cur]];
        Od_mat=[Od_mat;[d.events{sess}.curr_odor_num]];
    end
    RP_mat_large = repmat(RP_mat,[1,1,10]);
    Od_mat_large = repmat(Od_mat,[1,1,10]);
    
    % 2. Selection of learners/non-learners and matrix reduction
    clear selection_p75 selection_p25 selection_n75 selection_n25
%     selection_p75 = [d.info.sign_75];
%     selection_p25 = [d.info.sign_25];
%     selection_n75 = ([d.info.sign_75]==0);
%     selection_n25 = ([d.info.sign_25]==0);
    selection_p75 = [d.info.p_75start]<0.05
    selection_p25 = [d.info.p_25start]<0.05
    selection_n75 = [d.info.p_75start]>0.5
    selection_n25 = [d.info.p_75start]>0.5  
    
    
    
    clear odor_75 odor_25
    for kx=1:83; 
        odor_75(kx)=d.info(kx).odors(1,1); 
        odor_25(kx)=d.info(kx).odors(1,2); 
    end

    % 3. Matrix reduction by ODOR
    tc_matrsess_all9 = tc_matrsess_all;
    tc_matrsess_all9(Od_mat_large==5)=nan;
    tc_matrsess_all5 = tc_matrsess_all;
    tc_matrsess_all5(Od_mat_large==9)=nan;
    
    for kx=1:length(odor_75)
        if odor_75(kx)==5
            tc_matrsess_st75(kx,:,:) = tc_matrsess_all5(kx,:,:);
        elseif odor_75(kx)==9
            tc_matrsess_st75(kx,:,:) = tc_matrsess_all9(kx,:,:);
        end
    end
    for kx=1:length(odor_25)
        if odor_25(kx)==5
            tc_matrsess_st25(kx,:,:) = tc_matrsess_all5(kx,:,:);
        elseif odor_25(kx)==9
            tc_matrsess_st25(kx,:,:) = tc_matrsess_all9(kx,:,:);
        end
    end       
            
    tc_matrsess_newP=[tc_matrsess_st75(selection_p75,:,:);tc_matrsess_st25(selection_p25,:,:)]
    tc_matrsess_newN=[tc_matrsess_st75(selection_n75,:,:);tc_matrsess_st25(selection_n25,:,:)]
   
    
    clear tc_matrsess_sel RP_mat_sel FD_matrsess_sel
    RP_mat_selP = [RP_mat_large(selection_p75,:,:);RP_mat_large(selection_p25,:,:)];
    RP_mat_selN = [RP_mat_large(selection_n75,:,:);RP_mat_large(selection_n25,:,:)];
    
    FD_mat_selP = [FD_matrsess_all(selection_p75,:,:);FD_matrsess_all(selection_p25,:,:)];
    FD_mat_selN = [FD_matrsess_all(selection_n75,:,:);FD_matrsess_all(selection_n25,:,:)];
    
    % 4. Create mean_TC matrix for High and Low RP
    clear mtc_H mtc_L FD_H FD_L
    % 75% RP
    mtc_H=squeeze(nanmean(tc_matrsess_newP.*(RP_mat_selP==.75),1));
    FD_H=squeeze(nanmean(FD_mat_selP.*(RP_mat_selP==.75),1));
    % 25% RP
    mtc_L=squeeze(nanmean(tc_matrsess_newP.*(RP_mat_selP==.25),1));
    FD_L=squeeze(nanmean(FD_mat_selP.*(RP_mat_selP==.25),1));
    
    % 5. Reduce matrices to LAST BLOCK
    mtc_H=mtc_H([21:40,61:80,101:120,141:160],:);
    mtc_L=mtc_L([21:40,61:80,101:120,141:160],:);
    FD_H=FD_H([21:40,61:80,101:120,141:160],:);
    FD_L=FD_L([21:40,61:80,101:120,141:160],:);
    
    % 5. Figure:
    % subplot
    subplot(3,2,3)
    % rewarded:
    sh(1) = shadedErrorBar([1:10],nanmean(mtc_H),SEM_calc(mtc_H));
    sh(1).mainLine.Color=[0,1,0];
    sh(1).patch.EdgeColor=[0,1,0];
    sh(1).patch.FaceColor=[0,1,0];
    sh(1).edge(1).Color=[1,1,1];
    sh(1).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(2) = shadedErrorBar([1:10],nanmean(mtc_L),SEM_calc(mtc_L));
    sh(2).mainLine.Color=[1,0,0];
    sh(2).patch.EdgeColor=[1,0,0];
    sh(2).patch.FaceColor=[1,0,0];
    sh(2).edge(1).Color=[1,1,1];
    sh(2).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(3) = shadedErrorBar([1:10],nanmean(FD_H),SEM_calc(FD_H));
    sh(3).mainLine.Color=[.2,.6,.2];
    sh(3).patch.EdgeColor=[.2,.6,.2];
    sh(3).patch.FaceColor=[.2,.6,.2];
    sh(3).edge(1).Color=[1,1,1];
    sh(3).edge(2).Color=[1,1,1];   
    hold on;
    % non-rewarded:
    sh(4) = shadedErrorBar([1:10],nanmean(FD_L),SEM_calc(FD_L));
    sh(4).mainLine.Color=[.6,.2,.2];
    sh(4).patch.EdgeColor=[.6,.2,.2];
    sh(4).patch.FaceColor=[.6,.2,.2];
    sh(4).edge(1).Color=[1,1,1];
    sh(4).edge(2).Color=[1,1,1];   
    
    % Axis
    ax=gca;
    ax.YLim=[-.3,.3];
    ax.YTick=[-.3:.1:.3];
    ax.YLabel.String='Residual BOLD (z-scored)';
    
    ax.XLim=[0,10];
    ax.XLabel.String=['Time'];
    ax.XTick=[0:1:10];
    ax.XTickLabel=[-1.2:1.2:12];
    rotateXLabels(ax,70);
    
    % Odor
    hold on;
    fill([1 1 1+1/1.2 1+1/1.2],[-0.3 0.3 0.3 -0.3],[0.2 0.2 0.8],'FaceColor',[0.2 0.2 0.5],'FaceAlpha',0.1,'EdgeAlpha',0);
    hold on;
    tt=text(1.2,0.2,'Od.');
    tt.Color=[0.2 0.2 0.8];
    
    % Reward
    hold on;
    ll=line([1+2.2/1.2,1+2.2/1.2],[-.3,.3]); % 2.2 as RP-timepoint is actually at 2.7, but we already included the reward delay
    ll.Color=[0.8 0.2 0.8];
    ll.LineWidth=2;
    tt=text(1+2.4/1.2,0.2,'Rew.');
    tt.Color=[0.8 0.2 0.8];
    
    % lgd=legend
    lgd=legend([sh(1).mainLine,sh(2).mainLine],{'75% RP','25% RP'},'Location','southeast');
    lgd.FontSize=6;
    
    % Sign. *
    clear h p
    [h,p]=ttest2(mtc_H,mtc_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,0.28,'*');
            text(px,0.295,'*');
            text(px,0.265,'*');
        elseif p(px)<0.01
            text(px,0.28,'*');
            text(px,0.265,'*');
        elseif p(px)<0.05
            text(px,0.28,'*');
        end
    end
    
     % Sign. *
    clear h p
    [h,p]=ttest2(FD_H,FD_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,-0.28,'*');
            text(px,-0.295,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.01
            text(px,-0.28,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.05
            text(px,-0.28,'*');
        end
    end
    text(1,-.275,'FD')
    
    % Title
    title({'Learners','(Sign pos., last 10)'});
    
    % AGAIN:
    % 4. Create mean_TC matrix for High and Low RP
    clear mtc_H mtc_L FD_H FD_L
    % 75% RP
    mtc_H=squeeze(nanmean(tc_matrsess_newN.*(RP_mat_selN==.75),1));
    FD_H=squeeze(nanmean(FD_mat_selN.*(RP_mat_selN==.75),1));
    % 25% RP
    mtc_L=squeeze(nanmean(tc_matrsess_newN.*(RP_mat_selN==.25),1));
    FD_L=squeeze(nanmean(FD_mat_selN.*(RP_mat_selN==.25),1));
    
    % 5. Reduce matrices to LAST BLOCK
    mtc_H=mtc_H([21:40,61:80,101:120,141:160],:);
    mtc_L=mtc_L([21:40,61:80,101:120,141:160],:);
    FD_H=FD_H([21:40,61:80,101:120,141:160],:);
    FD_L=FD_L([21:40,61:80,101:120,141:160],:);
    
    % 5. Figure:
    % subplot
    subplot(3,2,4)
    % rewarded:
    sh(1) = shadedErrorBar([1:10],nanmean(mtc_H),SEM_calc(mtc_H));
    sh(1).mainLine.Color=[0,1,0];
    sh(1).patch.EdgeColor=[0,1,0];
    sh(1).patch.FaceColor=[0,1,0];
    sh(1).edge(1).Color=[1,1,1];
    sh(1).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(2) = shadedErrorBar([1:10],nanmean(mtc_L),SEM_calc(mtc_L));
    sh(2).mainLine.Color=[1,0,0];
    sh(2).patch.EdgeColor=[1,0,0];
    sh(2).patch.FaceColor=[1,0,0];
    sh(2).edge(1).Color=[1,1,1];
    sh(2).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(3) = shadedErrorBar([1:10],nanmean(FD_H),SEM_calc(FD_H));
    sh(3).mainLine.Color=[.2,.6,.2];
    sh(3).patch.EdgeColor=[.2,.6,.2];
    sh(3).patch.FaceColor=[.2,.6,.2];
    sh(3).edge(1).Color=[1,1,1];
    sh(3).edge(2).Color=[1,1,1];   
    hold on;
    % non-rewarded:
    sh(4) = shadedErrorBar([1:10],nanmean(FD_L),SEM_calc(FD_L));
    sh(4).mainLine.Color=[.6,.2,.2];
    sh(4).patch.EdgeColor=[.6,.2,.2];
    sh(4).patch.FaceColor=[.6,.2,.2];
    sh(4).edge(1).Color=[1,1,1];
    sh(4).edge(2).Color=[1,1,1];   
    
    % Axis
    ax=gca;
    ax.YLim=[-.3,.3];
    ax.YTick=[-.3:.1:.3];
    ax.YLabel.String='Residual BOLD (z-scored)';
    
    ax.XLim=[0,10];
    ax.XLabel.String=['Time'];
    ax.XTick=[0:1:10];
    ax.XTickLabel=[-1.2:1.2:12];
    rotateXLabels(ax,70);
    
    % Odor
    hold on;
    fill([1 1 1+1/1.2 1+1/1.2],[-0.3 0.3 0.3 -0.3],[0.2 0.2 0.8],'FaceColor',[0.2 0.2 0.5],'FaceAlpha',0.1,'EdgeAlpha',0);
    hold on;
    tt=text(1.2,0.2,'Od.');
    tt.Color=[0.2 0.2 0.8];
    
    % Reward
    hold on;
    ll=line([1+2.2/1.2,1+2.2/1.2],[-.3,.3]); % 2.2 as RP-timepoint is actually at 2.7, but we already included the reward delay
    ll.Color=[0.8 0.2 0.8];
    ll.LineWidth=2;
    tt=text(1+2.4/1.2,0.2,'Rew.');
    tt.Color=[0.8 0.2 0.8];
    
    % lgd=legend
    lgd=legend([sh(1).mainLine,sh(2).mainLine],{'75% RP','25% RP'},'Location','southeast');
    lgd.FontSize=6;
    
    % Sign. *
    clear h p
    [h,p]=ttest2(mtc_H,mtc_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,0.28,'*');
            text(px,0.295,'*');
            text(px,0.265,'*');
        elseif p(px)<0.01
            text(px,0.28,'*');
            text(px,0.265,'*');
        elseif p(px)<0.05
            text(px,0.28,'*');
        end
    end
    
     % Sign. *
    clear h p
    [h,p]=ttest2(FD_H,FD_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,-0.28,'*');
            text(px,-0.295,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.01
            text(px,-0.28,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.05
            text(px,-0.28,'*');
        end
    end
    text(1,-.275,'FD')
    
    % Title
    title({'Non-Learners','(Sign neg., last 10)'});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% II.: SUBPLOT by 75%/25% (Learnerns vs. Non-Learners) LAST PART
    % 1. Create a reward matrix for all sessions in the same format
    % - sessions (83) x trials (160) x timepoints (10)
    clear RP_mat RP_mat_large Od_mat Od_mat_large
    RP_mat=[];
    Od_mat=[];
    for sess=sessions
        RP_mat=[RP_mat;[d.events{sess}.rew_prob_cur]];
        Od_mat=[Od_mat;[d.events{sess}.curr_odor_num]];
    end
    RP_mat_large = repmat(RP_mat,[1,1,10]);
    Od_mat_large = repmat(Od_mat,[1,1,10]);
    
    % 2. Selection of learners/non-learners and matrix reduction
    clear selection_p75 selection_p25 selection_n75 selection_n25
%     selection_p75 = [d.info.sign_75];
%     selection_p25 = [d.info.sign_25];
%     selection_n75 = ([d.info.sign_75]==0);
%     selection_n25 = ([d.info.sign_25]==0);
    selection_p75 = [d.info.p_75start]<0.05
    selection_p25 = [d.info.p_25start]<0.05
    selection_n75 = [d.info.p_75start]>0.5
    selection_n25 = [d.info.p_75start]>0.5  
    
    
    
    clear odor_75 odor_25
    for kx=1:83; 
        odor_75(kx)=d.info(kx).odors(1,1); 
        odor_25(kx)=d.info(kx).odors(1,2); 
    end

    % 3. Matrix reduction by ODOR
    tc_matrsess_all9 = tc_matrsess_all;
    tc_matrsess_all9(Od_mat_large==5)=nan;
    tc_matrsess_all5 = tc_matrsess_all;
    tc_matrsess_all5(Od_mat_large==9)=nan;
    
    for kx=1:length(odor_75)
        if odor_75(kx)==5
            tc_matrsess_st75(kx,:,:) = tc_matrsess_all5(kx,:,:);
        elseif odor_75(kx)==9
            tc_matrsess_st75(kx,:,:) = tc_matrsess_all9(kx,:,:);
        end
    end
    for kx=1:length(odor_25)
        if odor_25(kx)==5
            tc_matrsess_st25(kx,:,:) = tc_matrsess_all5(kx,:,:);
        elseif odor_25(kx)==9
            tc_matrsess_st25(kx,:,:) = tc_matrsess_all9(kx,:,:);
        end
    end       
            
    tc_matrsess_newP=[tc_matrsess_st75(selection_p75,:,:);tc_matrsess_st25(selection_p25,:,:)]
    tc_matrsess_newN=[tc_matrsess_st75(selection_n75,:,:);tc_matrsess_st25(selection_n25,:,:)]
   
    
    clear tc_matrsess_sel RP_mat_sel FD_matrsess_sel
    RP_mat_selP = [RP_mat_large(selection_p75,:,:);RP_mat_large(selection_p25,:,:)];
    RP_mat_selN = [RP_mat_large(selection_n75,:,:);RP_mat_large(selection_n25,:,:)];
    
    FD_mat_selP = [FD_matrsess_all(selection_p75,:,:);FD_matrsess_all(selection_p25,:,:)];
    FD_mat_selN = [FD_matrsess_all(selection_n75,:,:);FD_matrsess_all(selection_n25,:,:)];
    
    % 4. Create mean_TC matrix for High and Low RP
    clear mtc_H mtc_L FD_H FD_L
    % 75% RP
    mtc_H=squeeze(nanmean(tc_matrsess_newP.*(RP_mat_selP==.75),1));
    FD_H=squeeze(nanmean(FD_mat_selP.*(RP_mat_selP==.75),1));
    % 25% RP
    mtc_L=squeeze(nanmean(tc_matrsess_newP.*(RP_mat_selP==.25),1));
    FD_L=squeeze(nanmean(FD_mat_selP.*(RP_mat_selP==.25),1));
    
    % 5. Reduce matrices to LAST BLOCK
    mtc_H=mtc_H([1:20,41:60,81:100,121:140],:);
    mtc_L=mtc_L([1:20,41:60,81:100,121:140],:);
    FD_H=FD_H([1:20,41:60,81:100,121:140],:);
    FD_L=FD_L([1:20,41:60,81:100,121:140],:);
    
    % 5. Figure:
    % subplot
    subplot(3,2,5)
    % rewarded:
    sh(1) = shadedErrorBar([1:10],nanmean(mtc_H),SEM_calc(mtc_H));
    sh(1).mainLine.Color=[0,1,0];
    sh(1).patch.EdgeColor=[0,1,0];
    sh(1).patch.FaceColor=[0,1,0];
    sh(1).edge(1).Color=[1,1,1];
    sh(1).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(2) = shadedErrorBar([1:10],nanmean(mtc_L),SEM_calc(mtc_L));
    sh(2).mainLine.Color=[1,0,0];
    sh(2).patch.EdgeColor=[1,0,0];
    sh(2).patch.FaceColor=[1,0,0];
    sh(2).edge(1).Color=[1,1,1];
    sh(2).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(3) = shadedErrorBar([1:10],nanmean(FD_H),SEM_calc(FD_H));
    sh(3).mainLine.Color=[.2,.6,.2];
    sh(3).patch.EdgeColor=[.2,.6,.2];
    sh(3).patch.FaceColor=[.2,.6,.2];
    sh(3).edge(1).Color=[1,1,1];
    sh(3).edge(2).Color=[1,1,1];   
    hold on;
    % non-rewarded:
    sh(4) = shadedErrorBar([1:10],nanmean(FD_L),SEM_calc(FD_L));
    sh(4).mainLine.Color=[.6,.2,.2];
    sh(4).patch.EdgeColor=[.6,.2,.2];
    sh(4).patch.FaceColor=[.6,.2,.2];
    sh(4).edge(1).Color=[1,1,1];
    sh(4).edge(2).Color=[1,1,1];   
    
    % Axis
    ax=gca;
    ax.YLim=[-.3,.3];
    ax.YTick=[-.3:.1:.3];
    ax.YLabel.String='Residual BOLD (z-scored)';
    
    ax.XLim=[0,10];
    ax.XLabel.String=['Time'];
    ax.XTick=[0:1:10];
    ax.XTickLabel=[-1.2:1.2:12];
    rotateXLabels(ax,70);
    
    % Odor
    hold on;
    fill([1 1 1+1/1.2 1+1/1.2],[-0.3 0.3 0.3 -0.3],[0.2 0.2 0.8],'FaceColor',[0.2 0.2 0.5],'FaceAlpha',0.1,'EdgeAlpha',0);
    hold on;
    tt=text(1.2,0.2,'Od.');
    tt.Color=[0.2 0.2 0.8];
    
    % Reward
    hold on;
    ll=line([1+2.2/1.2,1+2.2/1.2],[-.3,.3]); % 2.2 as RP-timepoint is actually at 2.7, but we already included the reward delay
    ll.Color=[0.8 0.2 0.8];
    ll.LineWidth=2;
    tt=text(1+2.4/1.2,0.2,'Rew.');
    tt.Color=[0.8 0.2 0.8];
    
    % lgd=legend
    lgd=legend([sh(1).mainLine,sh(2).mainLine],{'75% RP','25% RP'},'Location','southeast');
    lgd.FontSize=6;
    
    % Sign. *
    clear h p
    [h,p]=ttest2(mtc_H,mtc_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,0.28,'*');
            text(px,0.295,'*');
            text(px,0.265,'*');
        elseif p(px)<0.01
            text(px,0.28,'*');
            text(px,0.265,'*');
        elseif p(px)<0.05
            text(px,0.28,'*');
        end
    end
    
     % Sign. *
    clear h p
    [h,p]=ttest2(FD_H,FD_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,-0.28,'*');
            text(px,-0.295,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.01
            text(px,-0.28,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.05
            text(px,-0.28,'*');
        end
    end
    text(1,-.275,'FD')
    
    % Title
    title({'Learners','(Sign pos., first 10)'});
    
    % AGAIN:
    % 4. Create mean_TC matrix for High and Low RP
    clear mtc_H mtc_L FD_H FD_L
    % 75% RP
    mtc_H=squeeze(nanmean(tc_matrsess_newN.*(RP_mat_selN==.75),1));
    FD_H=squeeze(nanmean(FD_mat_selN.*(RP_mat_selN==.75),1));
    % 25% RP
    mtc_L=squeeze(nanmean(tc_matrsess_newN.*(RP_mat_selN==.25),1));
    FD_L=squeeze(nanmean(FD_mat_selN.*(RP_mat_selN==.25),1));
    
    % 5. Reduce matrices to LAST BLOCK
    mtc_H=mtc_H([1:20,41:60,81:100,121:140],:);
    mtc_L=mtc_L([1:20,41:60,81:100,121:140],:);
    FD_H=FD_H([1:20,41:60,81:100,121:140],:);
    FD_L=FD_L([1:20,41:60,81:100,121:140],:);
    
    % 5. Figure:
    % subplot
    subplot(3,2,6)
    % rewarded:
    sh(1) = shadedErrorBar([1:10],nanmean(mtc_H),SEM_calc(mtc_H));
    sh(1).mainLine.Color=[0,1,0];
    sh(1).patch.EdgeColor=[0,1,0];
    sh(1).patch.FaceColor=[0,1,0];
    sh(1).edge(1).Color=[1,1,1];
    sh(1).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(2) = shadedErrorBar([1:10],nanmean(mtc_L),SEM_calc(mtc_L));
    sh(2).mainLine.Color=[1,0,0];
    sh(2).patch.EdgeColor=[1,0,0];
    sh(2).patch.FaceColor=[1,0,0];
    sh(2).edge(1).Color=[1,1,1];
    sh(2).edge(2).Color=[1,1,1];
    hold on;
    % non-rewarded:
    sh(3) = shadedErrorBar([1:10],nanmean(FD_H),SEM_calc(FD_H));
    sh(3).mainLine.Color=[.2,.6,.2];
    sh(3).patch.EdgeColor=[.2,.6,.2];
    sh(3).patch.FaceColor=[.2,.6,.2];
    sh(3).edge(1).Color=[1,1,1];
    sh(3).edge(2).Color=[1,1,1];   
    hold on;
    % non-rewarded:
    sh(4) = shadedErrorBar([1:10],nanmean(FD_L),SEM_calc(FD_L));
    sh(4).mainLine.Color=[.6,.2,.2];
    sh(4).patch.EdgeColor=[.6,.2,.2];
    sh(4).patch.FaceColor=[.6,.2,.2];
    sh(4).edge(1).Color=[1,1,1];
    sh(4).edge(2).Color=[1,1,1];   
    
    % Axis
    ax=gca;
    ax.YLim=[-.3,.3];
    ax.YTick=[-.3:.1:.3];
    ax.YLabel.String='Residual BOLD (z-scored)';
    
    ax.XLim=[0,10];
    ax.XLabel.String=['Time'];
    ax.XTick=[0:1:10];
    ax.XTickLabel=[-1.2:1.2:12];
    rotateXLabels(ax,70);
    
    % Odor
    hold on;
    fill([1 1 1+1/1.2 1+1/1.2],[-0.3 0.3 0.3 -0.3],[0.2 0.2 0.8],'FaceColor',[0.2 0.2 0.5],'FaceAlpha',0.1,'EdgeAlpha',0);
    hold on;
    tt=text(1.2,0.2,'Od.');
    tt.Color=[0.2 0.2 0.8];
    
    % Reward
    hold on;
    ll=line([1+2.2/1.2,1+2.2/1.2],[-.3,.3]); % 2.2 as RP-timepoint is actually at 2.7, but we already included the reward delay
    ll.Color=[0.8 0.2 0.8];
    ll.LineWidth=2;
    tt=text(1+2.4/1.2,0.2,'Rew.');
    tt.Color=[0.8 0.2 0.8];
    
    % lgd=legend
    lgd=legend([sh(1).mainLine,sh(2).mainLine],{'75% RP','25% RP'},'Location','southeast');
    lgd.FontSize=6;
    
    % Sign. *
    clear h p
    [h,p]=ttest2(mtc_H,mtc_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,0.28,'*');
            text(px,0.295,'*');
            text(px,0.265,'*');
        elseif p(px)<0.01
            text(px,0.28,'*');
            text(px,0.265,'*');
        elseif p(px)<0.05
            text(px,0.28,'*');
        end
    end
    
     % Sign. *
    clear h p
    [h,p]=ttest2(FD_H,FD_L);
    for px=1:length(p)
        if p(px)<0.001
            text(px,-0.28,'*');
            text(px,-0.295,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.01
            text(px,-0.28,'*');
            text(px,-0.265,'*');
        elseif p(px)<0.05
            text(px,-0.28,'*');
        end
    end
    text(1,-.275,'FD')
    
    % Title
    title({'Non-Learners','(Sign neg., last 10)'});
    
    % Super Title and SAVE
    if contains(dirlist(ix).name,'APC')
        suptitle('APC');
        print('-dpsc',[meanTCdir filesep dirlist(ix).name filesep 'APC_meanTC.ps'],'-r400','-append','-bestfit');
        %         saveas(fig,[meanTCdir filesep dirlist(ix).name filesep 'APC_meanTC.ps']);
    elseif contains(dirlist(ix).name,'olftubercle')
        suptitle('OTu');
        print('-dpsc',[meanTCdir filesep dirlist(ix).name filesep 'OTu_meanTC.ps'],'-r400','-append','-bestfit');
        %         saveas(fig,[meanTCdir filesep dirlist(ix).name filesep 'OTu_meanTC.ps']);
    end
end