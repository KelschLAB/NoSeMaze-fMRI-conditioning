%% master_corr_GLM_to_NoSeMazeSH_reappraisal_jr.m
% Reinwald, Jonathan; 07/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

% correlation type
corr_type{1}='Spearman';
corr_type{2}='Pearson';

% output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/08-correlation_analyses_fMRI_to_NoSeMaze/02-Motion_to_NoSeMaze';

%% Load Social Hierarchy and Chasing
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

% sort ExplVar by animal number
for ix=1:length(ExplVar)
    [~,idx]=sort(ExplVar(ix).AnimalNumb);
    ExplVar(ix).values_sortedbyAnimalNumb = ExplVar(ix).values(idx);
end

%% loop over correlation type (Pearson/Spearman)
for corr_idx = 1:length(corr_type)
    
    % load FD
    % CAVE: double check of FD is based on AFNI-despiked data or not
    %% Load FD
    % load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/Amyg/FD_matrsess_all_BINS6_TRsbefore2.mat')
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/tc_matrsess_all_BINS6_TRsbefore2.mat')
    
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/FD_matrsess_all_BINS6_TRsbefore2.mat')
    % load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v99___COV_v1___ORTH_1___11-Jan-2022/meanTC/Amyg/tc_matrsess_all_BINS6_TRsbefore2.mat')
    
    meanFD_block1 = squeeze(mean(FD_matrsess_all(:,[11:40],:),2));
    meanFD_block3 = squeeze(mean(FD_matrsess_all(:,[81:120],:),2));
    
    [~,sortingIdx_FD]=sort(tc_matrsess_info.AnimalNumb,'ascend');
    meanFD_block1_sorted=meanFD_block1(sortingIdx_FD,:);
    meanFD_block3_sorted=meanFD_block3(sortingIdx_FD,:);
    
    %% Correlation analysis
    clear corr_coeff p_val
    [corr_coeff(1).rho,p_val(1).p]=corr([meanFD_block1_sorted,mean(meanFD_block1_sorted,2)],[ExplVar.values_sortedbyAnimalNumb],'type',corr_type{corr_idx});
    [corr_coeff(2).rho,p_val(2).p]=corr([meanFD_block3_sorted,mean(meanFD_block3_sorted,2)],[ExplVar.values_sortedbyAnimalNumb],'type',corr_type{corr_idx});
    [corr_coeff(3).rho,p_val(3).p]=corr([meanFD_block3_sorted,mean(meanFD_block3_sorted,2)]-[meanFD_block1_sorted,mean(meanFD_block1_sorted,2)],[ExplVar.values_sortedbyAnimalNumb],'type',corr_type{corr_idx});
    
    % plot correlation matrix
    for fig_idx = 1:length(corr_coeff)
        fig(fig_idx)=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
        imagesc(corr_coeff(fig_idx).rho);%.*(p<.05));
        set(gca,'dataAspectRatio',[1 1 1])
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        crameri vik;
        ax.YTick=1:size(corr_coeff(fig_idx).rho,1);
        for yy = 1:size(corr_coeff(fig_idx).rho,1)
            y_names{yy}=['TR #' num2str(yy)];
        end
        y_names{size(corr_coeff(fig_idx).rho,1)}='mean FD';
        ax.YTickLabel=y_names;
        ax.XTick=1:size(corr_coeff(fig_idx).rho,2);
        ax.XTickLabel={ExplVar.name};
        ax.XLabel.String='NoSeMaze-Variables';
        ax.YLabel.String='FD (at TR within trial)';
        rotateXLabels(ax,45);
        ax.FontSize=10;
        
        % Title
        if fig_idx==1
            tt = title({['corr. NoSeMaze to FD (' corr_type{corr_idx} ')'],['Block 1']});
        elseif fig_idx==2
            tt = title({['corr. NoSeMaze to FD (' corr_type{corr_idx} ')'],['Block 3']});
        elseif fig_idx==3
            tt = title({['corr. NoSeMaze to FD (' corr_type{corr_idx} ')'],['Block 3 - Block 1']});
        end
        tt.Interpreter='none';
        colorbar;
        
        % Mark significant p-values
        for x=1:size(p_val(fig_idx).p,2)
            for y=1:size(p_val(fig_idx).p,1)
                if p_val(fig_idx).p(y,x)<.05
                    xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                    line(xv,yv,'linewidth',2,'color',[0 0 0]);
                end
            end
        end
        
        % print
        if fig_idx==1
            [annot, srcInfo] = docDataSrc(fig(fig_idx),outputDir,mfilename('fullpath'),logical(1))
            exportgraphics(fig(fig_idx),fullfile(outputDir,['CorrNoSeMazetoFD_Block1_' corr_type{corr_idx} '.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['CorrNoSeMazetoFD_Block1_' corr_type{corr_idx}]),'-painters','-r400');
        elseif fig_idx==2
            [annot, srcInfo] = docDataSrc(fig(fig_idx),outputDir,mfilename('fullpath'),logical(1))
            exportgraphics(fig(fig_idx),fullfile(outputDir,['CorrNoSeMazetoFD_Block3_' corr_type{corr_idx} '.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['CorrNoSeMazetoFD_Block3_' corr_type{corr_idx}]),'-painters','-r400');
        elseif fig_idx==3
            [annot, srcInfo] = docDataSrc(fig(fig_idx),outputDir,mfilename('fullpath'),logical(1))
            exportgraphics(fig(fig_idx),fullfile(outputDir,['CorrNoSeMazetoFD_Block3vs1_' corr_type{corr_idx} '.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['CorrNoSeMazetoFD_Block3vs1_' corr_type{corr_idx}]),'-painters','-r400');
        end
    end
end







