%% master_corr_GLM_to_NoSeMazeSH_social_defeat_jr.m
% Reinwald, Jonathan; 01/2021

%% Preparation
clear all;
% close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

%% Load regressors of interest
% Social hierarchy with David's Score
% Scans: AM1 at D36 and D37
% Scans: AM2 at D29 and D30
% ExplVar(1).name = 'DavidsScore';

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
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day29to35_11ANIMALS.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day38to44_11ANIMALS.mat','DS_info');
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
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day22to28.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day31to37.mat','DS_info');
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

% %% add distance metrics
% % Load data
% load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData_22ANIMALS.mat');
% 
% ExplVar(6).name = 'DistanceVideos';
% ExplVar(6).values = T.Dist_Median_all;
% ExplVar(6).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(6).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(7).name = 'DistanceVideos_Zscored';
% ExplVar(7).values = zscore(T.Dist_Median_all);
% ExplVar(7).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(7).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(8).name = 'DistanceVideos_Ranked';
% [~,idx]=sort(ExplVar(6).values);
% [~,myRank]=sort(idx);
% ExplVar(8).values = myRank;
% ExplVar(8).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(8).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(9).name = 'DistanceVideos_Ranked_subgroup';
% Gr1=logical(sum([ExplVar(8).AnimalNumb]==[16,26,27,30,31,32,33,34,36,37,40,41],2));
% Gr2=logical(sum([ExplVar(8).AnimalNumb]==[11,12,13,14,17,18,19,22,23,24,25,39],2));
% [~,idx_Gr1]=sort(ExplVar(6).values(Gr1));
% [~,myRank_Gr1]=sort(idx_Gr1);
% [~,idx_Gr2]=sort(ExplVar(6).values(Gr2));
% [~,myRank_Gr2]=sort(idx_Gr2);
% newRank=zeros(24,1);
% newRank(Gr1)=myRank_Gr1;newRank(Gr2)=myRank_Gr2;
% ExplVar(9).values = newRank;
% ExplVar(9).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(9).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(10).name = 'FrontToBack_All';
% ExplVar(10).values = T.FtoB_Aall;
% ExplVar(10).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(10).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(11).name = 'Front_All';
% ExplVar(11).values = T.BackAll;
% ExplVar(11).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(11).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(12).name = 'Back_All';
% ExplVar(12).values = T.FrontAll;
% ExplVar(12).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(12).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(13).name = 'PCA1';
% ExplVar(13).values = T.PCA1;
% ExplVar(13).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(13).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(14).name = 'PCA2';
% ExplVar(14).values = T.PCA2;
% ExplVar(14).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(14).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(15).name = 'PCA1_vid';
% ExplVar(15).values = T.PCA1_vid;
% ExplVar(15).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(15).AnimalNumb = Animal_Number_Dist';
% 
% ExplVar(16).name = 'PCA2_vid';
% ExplVar(16).values = T.PCA2_vid;
% ExplVar(16).ID = T.Animal_ID;
% for ii=1:length(T.Animal_Number) 
%     Animal_Number_Dist(ii)=str2num(T.Animal_Number{ii}(2:3)); 
% end
% ExplVar(16).AnimalNumb = Animal_Number_Dist';
% 
% % delete animals without pre/post hierarchy
% ToDelete=logical(strcmp(ExplVar(6).ID,'0007CB08A5') + strcmp(ExplVar(6).ID,'0007CB6B2C'));
% for i_ExplVar=6:12
%     ExplVar(i_ExplVar).values = ExplVar(i_ExplVar).values(~ToDelete);
%     ExplVar(i_ExplVar).ID = ExplVar(i_ExplVar).ID(~ToDelete);
%     ExplVar(i_ExplVar).AnimalNumb = ExplVar(i_ExplVar).AnimalNumb(~ToDelete);
% end

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = 1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [workDir filesep 'secondlevel_' ExplVar(varIdx).name '_23ANIMALS'];
    if ~exist(outputDir_secondlevel)
        mkdir(outputDir_secondlevel)
    end
    
    %% 2. Load contrast_names.mat
    load([workDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
    
    %% 3. Explicit mask
    %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [workDir filesep 'firstlevel'];
    
    do_secondlevel_GLM_to_NoSeMaze_23ANIMALS_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))
end











