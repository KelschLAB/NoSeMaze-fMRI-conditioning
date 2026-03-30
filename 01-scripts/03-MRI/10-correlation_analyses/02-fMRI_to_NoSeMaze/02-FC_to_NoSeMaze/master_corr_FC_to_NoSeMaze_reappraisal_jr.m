%% master_corr_FC_to_NoSeMaze_reappraisal_jr.m
% Jonathan Reinwald, 01/2023

%% Clearing
clear all
close all

%% Predefinitions
% cormat
suffix = 'v11';
cormat_selection = ['cormat_' suffix ];
atlasHemisphere_selection = 'combined'; %'combined'; % 'separated'

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));

%% Define directories
% Working Directory
workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_selection '/beta4D/' atlasHemisphere_selection '_hemisphere'];
% workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/' cormat_selection '/beta4D/'];
% workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/06-FC/01-BASCO/' cormat_selection '/beta4D/'];

% Output directory
outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/' cormat_selection '/' atlasHemisphere_selection '_hemisphere/corr_FC_to_NoSeMaze'];
mkdir(outputdir);

%% Define cormat pathes
% Make filelist for cormat and roidata mat-files
[cormat_files,dirs] = spm_select('List',workdir,'^cormat*')
[roidatamat_files,dirs] = spm_select('List',workdir,'^roidata*')
% Load roidata.mat to make ROI-names
load([workdir filesep deblank(roidatamat_files(1,:))]);
names = {subj(1).roi.name};

%% Load regressors of interest
%% Option 1: Days 1-14/1-16, respectively
% %% Load regressors of interest
% % Social hierarchy with David's Score
% load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day1to16.mat','DS_info');
% 
% DS_info1 = DS_info;
% load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14.mat','DS_info');
% 
% DS_info2 = DS_info;
% 
% ExplVar(1).name = 'DavidsScore';
% ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
% ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
% 
% ExplVar(2).name = 'DavidsScore_Zscored';
% ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
% ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];
% 
% % define ID and Animal numb for all regressors
% load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
% for ix=1:length(ExplVar)
%     for jx=1:length(ExplVar(ix).ID)
%         ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
%     end
% end

%% Option 2: For each animal, social hierarchy is used based on the 14 days before the scans
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

%% Load FD
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/tc_matrsess_all_BINS6_TRsbefore2.mat')
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/FD_matrsess_all_BINS6_TRsbefore2.mat')

meanFD_block1 = squeeze(mean(FD_matrsess_all(:,[11:40],:),2));
meanFD_block3 = squeeze(mean(FD_matrsess_all(:,[81:120],:),2));
meanFD = squeeze(mean(FD_matrsess_all(:,[1:120],:),2));

[FD_AnimalNumb,sortingIdx_FD]=sort(tc_matrsess_info.AnimalNumb,'ascend');
meanFD_block1_sorted=meanFD_block1(sortingIdx_FD,:);
meanFD_block3_sorted=meanFD_block3(sortingIdx_FD,:);
meanFD_sorted_perTR=meanFD(sortingIdx_FD,:);
meanFD_sorted=mean(meanFD_sorted_perTR,2);

%% Loop over explanatory variables
for varIdx = 2:length(ExplVar)
    
    % sort by animal number
    [B,Idx]=sort(ExplVar(varIdx).AnimalNumb,'ascend');
    input_table = table(B,[ExplVar(varIdx).values(Idx)],'VariableNames',{'No.','DavidsScore'});
    
    %% Loop over cormat conditions (e.g. Lavender, Puff, ...)
    for ix = 1%:size(cormat_files,1)
               
        % Load Cormat
        load([workdir filesep deblank(cormat_files(12,:))]);
        % Make title-name
        clear curr_name find_
        [fdir,fname,fext] = fileparts(deblank(cormat_files(12,:)));
        find_ = strfind(fname,'_');
        curr_name = fname(find_(2)+1:end);
        
        % Make 3D connectivity matrix
        clear cormat_3D
        cormat_3D_tp11to40 = cat(3,cormat{:});
        
        % Load Cormat
        load([workdir filesep deblank(cormat_files(17,:))]);
        % Make title-name
        clear curr_name find_
        [fdir,fname,fext] = fileparts(deblank(cormat_files(17,:)));
        find_ = strfind(fname,'_');
        curr_name = fname(find_(2)+1:end);
        
        % Make 3D connectivity matrix
        clear cormat_3D
        cormat_3D_tp81to120 = cat(3,cormat{:});
        
                     
        % Load Cormat
        load([workdir filesep deblank(cormat_files(ix,:))]);
        % Make title-name
        clear curr_name find_
        [fdir,fname,fext] = fileparts(deblank(cormat_files(ix,:)));
        find_ = strfind(fname,'_');
        curr_name = fname(find_(2)+1:end);
        
        % Make 3D connectivity matrix
        clear cormat_3D
        cormat_3D = cat(3,cormat{:});
        
        % Correlation
        for r1=1:size(cormat_3D,1)
            for r2=1:size(cormat_3D,2)
                [corrRes_pearson(varIdx,ix).rho_mat(r1,r2),corrRes_pearson(varIdx,ix).p_mat(r1,r2)]=corr(squeeze(cormat_3D_tp81to120(r1,r2,:))-squeeze(cormat_3D_tp11to40(r1,r2,:)),table2array(input_table(:,2)),'type','Pearson');
                [corrRes_spearman(varIdx,ix).rho_mat(r1,r2),corrRes_spearman(varIdx,ix).p_mat(r1,r2)]=corr(squeeze(cormat_3D_tp81to120(r1,r2,:))-squeeze(cormat_3D_tp11to40(r1,r2,:)),table2array(input_table(:,2)),'type','Spearman');
                [corrFD_pearsonBlock1(varIdx,ix).rho_mat(r1,r2),corrFD_pearsonBlock1(varIdx,ix).p_mat(r1,r2)]=corr(squeeze(cormat_3D_tp11to40(r1,r2,:)),mean(meanFD_block1_sorted,2),'type','Pearson');
                [corrFD_pearsonBlock3(varIdx,ix).rho_mat(r1,r2),corrFD_pearsonBlock3(varIdx,ix).p_mat(r1,r2)]=corr(squeeze(cormat_3D_tp81to120(r1,r2,:)),mean(meanFD_block3_sorted,2),'type','Spearman');
            
            end
        end
        corrRes_spearman(varIdx,ix).name = curr_name;
        corrRes_pearson(varIdx,ix).name = curr_name;
        corrRes_spearman(varIdx,ix).explVar = ExplVar(varIdx).name;
        corrRes_pearson(varIdx,ix).explVar = ExplVar(varIdx).name;
        %
        % Plot
        fig=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
        
        imagesc(corrRes_pearson(varIdx,ix).rho_mat);
        set(gca,'dataAspectRatio',[1 1 1])
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        ax.XTick=[1:length(names)];
        ax.XTickLabel=names;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=names;
        ax.FontSize=4;
        %         axis square;
        rotateXLabels(ax,90);
        % Title
        tt = title([curr_name ', ' ExplVar(varIdx).name]);
        tt.Interpreter='none';
        colorbar;
        
        % Mark significant p-values
        p_map = corrRes_pearson(varIdx,ix).p_mat<.05;
        for x=1:size(p_map,1)
            for y=x:size(p_map,2) %size(T,2);
                if (x == y)
                    xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
                    patch(xv,yv,[1 1 1])
                end
                if p_map(y,x)
                    xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                    line(xv,yv,'linewidth',1,'color',[0 0 0]);
                end
            end
        end
        
        %         % Save
        %         if 1==1
        %             [wd_file,wd_name,wd_ext] = fileparts(workdir);
        %             [wd_file,wd_name,wd_ext] = fileparts(wd_file);
        %             [wd_file,wd_name,wd_ext] = fileparts(wd_file);
        %             print('-dpsc',fullfile([outputdir filesep],['MeanCormatALLConditions_' wd_name '_' date '.ps']) ,'-r400','-append')
        %         end
        %         mean_conn(ix,:)=squeeze(mean(squeeze(mean(cormat_3D,1)),1));
        %         close(fig);
    end
end

% clear corrRes_pearson corrRes_spearman
% 
% % Load Cormat
% load([workdir filesep deblank(cormat_files(12,:))]);
% % Make 3D connectivity matrix
% cormat_3D_odor11to40 = cat(3,cormat{:});
% 
% % Load Cormat
% load([workdir filesep deblank(cormat_files(17,:))]);
% % Make 3D connectivity matrix
% cormat_3D_odor81to120 = cat(3,cormat{:});
% 
% % sort by animal number
% [B,Idx]=sort(ExplVar(varIdx).AnimalNumb,'ascend');
% input_table = table(B,[ExplVar(varIdx).values(Idx)],'VariableNames',{'No.','DavidsScore'});
% 
% % Correlation
% for r1=1:size(cormat_3D_odor81to120,1)
%     for r2=1:size(cormat_3D_odor81to120,2)
%         [corrRes_pearson(varIdx,1).rho_mat(r1,r2),corrRes_pearson(varIdx,1).p_mat(r1,r2)]=corr(squeeze(cormat_3D_odor81to120(r1,r2,:)-cormat_3D_odor11to40(r1,r2,:)),table2array(input_table(:,2)),'type','Pearson');
%         [corrRes_spearman(varIdx,1).rho_mat(r1,r2),corrRes_spearman(varIdx,1).p_mat(r1,r2)]=corr(squeeze(cormat_3D_odor81to120(r1,r2,:)-cormat_3D_odor11to40(r1,r2,:)),table2array(input_table(:,2)),'type','Spearman');
%     end
% end
% corrRes_spearman(varIdx,1).name = curr_name;
% corrRes_pearson(varIdx,1).name = curr_name;
% corrRes_spearman(varIdx,1).explVar = ExplVar(varIdx).name;
% corrRes_pearson(varIdx,1).explVar = ExplVar(varIdx).name;
% %
% % Plot
% fig=figure('visible', 'on');
% set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
% 
% imagesc(corrRes_pearson(varIdx,1).rho_mat);
% set(gca,'dataAspectRatio',[1 1 1])
% ax=gca;
% set(gca,'TickLabelInterpreter','none');
% ax.CLim=[-1,1];
% ax.Colormap=jet;
% ax.XTick=[1:length(names)];
% ax.XTickLabel=names;
% ax.YTick=[1:length(names)];
% ax.YTickLabel=names;
% ax.FontSize=4;
% %         axis square;
% rotateXLabels(ax,90);
% % Title
% tt = title([curr_name ', ' ExplVar(varIdx).name]);
% tt.Interpreter='none';
% colorbar;








