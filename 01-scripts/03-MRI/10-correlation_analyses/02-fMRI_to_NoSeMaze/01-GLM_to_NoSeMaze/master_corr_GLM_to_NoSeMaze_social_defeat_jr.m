%% master_corr_GLM_to_NoSeMaze_social_defeat_jr.m
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
ExplVar(1).name = 'DavidsScore';

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
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS]);
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS]);
            [~,Rank_before]=sort(Idx_before);
            DS_info1.RankDiff = [Rank_after-Rank_before];
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
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS]);
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS]);
            [~,Rank_before]=sort(Idx_before);
            DS_info2.RankDiff = [Rank_after-Rank_before];
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

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = 1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [workDir filesep 'secondlevel_' ExplVar(varIdx).name ];
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
    
    do_secondlevel_GLM_to_NoSeMaze_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))
end











