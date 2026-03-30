%% master_corr_FC_to_NoSeMaze_social_defeat_jr.m
% Jonathan Reinwald, 01/2023

%% Clearing
clear all
close all

%% Predefinitions
% cormat
suffix = 'v4';
cormat_selection = ['cormat_' suffix ];

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));

%% Define directories
% Working Directory
workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/' cormat_selection '/beta4D/'];

% Output directory
outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/' cormat_selection '/corr_FC_to_NoSeMaze'];
mkdir(outputdir);

%% Define cormat pathes
% Make filelist for cormat and roidata mat-files
[cormat_files,dirs] = spm_select('List',workdir,'^cormat*')
[roidatamat_files,dirs] = spm_select('List',workdir,'^roidata*')
% Load roidata.mat to make ROI-names
load([workdir filesep deblank(roidatamat_files(1,:))]);
names = {subj(1).roi.name};

%% Load regressors of interest
% % Social hierarchy with David's Score

%% Option 1: Normal Davids Score
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day1to35.mat','DS_info');
% DS_info1 = DS_info;

% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to28.mat','DS_info');
% DS_info2 = DS_info;

% ExplVar(1).name = 'DavidsScore';
% ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
% ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
% 
% ExplVar(2).name = 'DavidsScore_Zscored';
% ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
% ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];

%% Option 2: Difference between Davids Score before and after social defeat (10 days)
clear DS_before DS_after DS_info1
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day26to35.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day38to47.mat','DS_info');
DS_after = DS_info;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info1.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info1.DS_before = DS_before.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS]);
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS]);
            [~,Rank_before]=sort(Idx_before);
            DS_info1.RankDiff = [Rank_after-Rank_before];
            DS_info1.RankBefore = Rank_before;
        end
    else
        DS_info1.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

clear DS_before DS_after DS_info2
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day19to28.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day31to40.mat','DS_info');
DS_after = DS_info;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info2.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info2.DS_before = DS_before.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS]);
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS]);
            [~,Rank_before]=sort(Idx_before);
            DS_info2.RankDiff = [Rank_after-Rank_before];
            DS_info2.RankBefore = Rank_before;
        end
    else
        DS_info2.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

ExplVar(1).name = 'Diff_DavidsScore';
ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(1).values,'descend');
ExplVar(1).DS_sorted = myDS_sorted;
ExplVar(1).DS_sortedIndex = myDS_Idx;

ExplVar(2).name = 'Diff_DavidsScore_Zscored';
ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(2).values,'descend');
ExplVar(2).DS_sorted = myDS_sorted;
ExplVar(2).DS_sortedIndex = myDS_Idx;

ExplVar(3).name = 'Diff_DavidsScore_Ranks';
ExplVar(3).values = [[DS_info1.RankDiff]';[DS_info2.RankDiff]'];
ExplVar(3).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(3).values,'descend');
ExplVar(3).DS_sorted = myDS_sorted;
ExplVar(3).DS_sortedIndex = myDS_Idx;

ExplVar(4).name = 'DavidsScoreBefore';
ExplVar(4).values = [[DS_info1.DS_before]';[DS_info2.DS_before]'];
ExplVar(4).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(4).values,'descend');
ExplVar(4).DS_sorted = myDS_sorted;
ExplVar(4).DS_sortedIndex = myDS_Idx;

ExplVar(5).name = 'Ranks';
ExplVar(5).values = [[DS_info1.RankBefore]';[DS_info2.RankBefore]'];
ExplVar(5).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(5).values,'descend');
ExplVar(5).DS_sorted = myDS_sorted;
ExplVar(5).DS_sortedIndex = myDS_Idx;

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% add distance metrics
% Load data
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData.mat');

ExplVar(6).name = 'DistanceVideos';
ExplVar(6).values = T.Dist_Median_all;
ExplVar(6).ID = T.Animal_ID;
for ii=1:length(T.Animal_Number) 
    Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
end
ExplVar(6).AnimalNumb = Animal_Number_Dist';

ExplVar(7).name = 'DistanceVideos_Zscored';
ExplVar(7).values = zscore(T.Dist_Median_all);
ExplVar(7).ID = T.Animal_ID;
for ii=1:length(T.Animal_Number) 
    Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
end
ExplVar(7).AnimalNumb = Animal_Number_Dist';

ExplVar(8).name = 'DistanceVideos_Ranked';
[~,idx]=sort(ExplVar(6).values);
[~,myRank]=sort(idx);
ExplVar(8).values = myRank;
ExplVar(8).ID = T.Animal_ID;
for ii=1:length(T.Animal_Number) 
    Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
end
ExplVar(8).AnimalNumb = Animal_Number_Dist';

ExplVar(9).name = 'DistanceVideos_Ranked_subgroup';
Gr1=logical(sum([ExplVar(8).AnimalNumb]==[16,26,27,30,31,32,33,34,36,37,40,41],2));
Gr2=logical(sum([ExplVar(8).AnimalNumb]==[11,12,13,14,17,18,19,22,23,24,25,39],2));
[~,idx_Gr1]=sort(ExplVar(6).values(Gr1));
[~,myRank_Gr1]=sort(idx_Gr1);
[~,idx_Gr2]=sort(ExplVar(6).values(Gr2));
[~,myRank_Gr2]=sort(idx_Gr2);
newRank=zeros(24,1);
newRank(Gr1)=myRank_Gr1;newRank(Gr2)=myRank_Gr2;
ExplVar(9).values = newRank;
ExplVar(9).ID = T.Animal_ID;
for ii=1:length(T.Animal_Number) 
    Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
end
ExplVar(9).AnimalNumb = Animal_Number_Dist';


%% Loop over explanatory variables
for varIdx =3%1:length(ExplVar)
    
    % sort by animal number
    [B,Idx]=sort(ExplVar(varIdx).AnimalNumb,'ascend');
    input_table = table(B,[ExplVar(varIdx).values(Idx)],'VariableNames',{'No.',ExplVar(varIdx).name});
    
    %% Loop over cormat conditions (e.g. Lavender, Puff, ...)
    for ix = 8%,7,8,14,15,21]%1:size(cormat_files,1)
                
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
                [corrRes_pearson(varIdx,ix).rho_mat(r1,r2),corrRes_pearson(varIdx,ix).p_mat(r1,r2)]=corr(squeeze(cormat_3D(r1,r2,:)),table2array(input_table(:,2)),'type','Pearson');
                [corrRes_spearman(varIdx,ix).rho_mat(r1,r2),corrRes_spearman(varIdx,ix).p_mat(r1,r2)]=corr(squeeze(cormat_3D(r1,r2,:)),table2array(input_table(:,2)),'type','Spearman');
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
        ax.CLim=[-.7,.7];
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








