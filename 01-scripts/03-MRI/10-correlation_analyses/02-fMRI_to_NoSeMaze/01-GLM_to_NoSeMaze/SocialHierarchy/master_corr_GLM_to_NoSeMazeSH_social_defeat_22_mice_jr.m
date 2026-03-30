%% master_corr_GLM_to_NoSeMazeSH_social_defeat_22_mice_jr.m
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

%% Option 1: Difference between Davids Score before and after social defeat (10 days)
clear DS_before DS_after DS_info1
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day26to35_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day38to47_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info');
DS_after = DS_info;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info1.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info1.DSBefore = DS_before.DS;
        DS_info1.DSAfter = DS_after.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS],'descend');
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS],'descend');
            [~,Rank_before]=sort(Idx_before);
            DS_info1.RankDiff = [Rank_after-Rank_before];
            DS_info1.RankBefore = Rank_before;
            DS_info1.RankAfter = Rank_after;
        end
    else
        DS_info1.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

clear DS_before DS_after DS_info2
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day19to28_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day31to40_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info');
DS_after = DS_info;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info2.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info2.DSBefore = DS_before.DS;
        DS_info2.DSAfter = DS_after.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS],'descend');
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS],'descend');
            [~,Rank_before]=sort(Idx_before);
            DS_info2.RankDiff = [Rank_after-Rank_before];
            DS_info2.RankBefore = Rank_before;
            DS_info2.RankAfter = Rank_after;
        end
    else
        DS_info2.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

ExplVar(1).name = 'Diff_DS';
ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(1).values,'descend');
ExplVar(1).DS_sorted = myDS_sorted;
ExplVar(1).DS_sortedIndex = myDS_Idx;

ExplVar(2).name = 'Diff_DSz';
ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(2).values,'descend');
ExplVar(2).DS_sorted = myDS_sorted;
ExplVar(2).DS_sortedIndex = myDS_Idx;

ExplVar(3).name = 'Diff_Ranks';
ExplVar(3).values = [[DS_info1.RankDiff]';[DS_info2.RankDiff]'];
ExplVar(3).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(3).values,'descend');
ExplVar(3).DS_sorted = myDS_sorted;
ExplVar(3).DS_sortedIndex = myDS_Idx;

ExplVar(4).name = 'DS_before';
ExplVar(4).values = [[DS_info1.DSBefore]';[DS_info2.DSBefore]'];
ExplVar(4).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(4).values,'descend');
ExplVar(4).DS_sorted = myDS_sorted;
ExplVar(4).DS_sortedIndex = myDS_Idx;

ExplVar(5).name = 'DSz_before';
ExplVar(5).values = [zscore([DS_info1.DSBefore])';zscore([DS_info2.DSBefore])'];
ExplVar(5).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(5).values,'descend');
ExplVar(5).DS_sorted = myDS_sorted;
ExplVar(5).DS_sortedIndex = myDS_Idx;

ExplVar(6).name = 'Rank_before';
ExplVar(6).values = [[DS_info1.RankBefore]';[DS_info2.RankBefore]'];
ExplVar(6).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(6).values,'descend');
ExplVar(6).DS_sorted = myDS_sorted;
ExplVar(6).DS_sortedIndex = myDS_Idx;

ExplVar(7).name = 'DS_after';
ExplVar(7).values = [[DS_info1.DSAfter]';[DS_info2.DSAfter]'];
ExplVar(7).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(7).values,'descend');
ExplVar(7).DS_sorted = myDS_sorted;
ExplVar(7).DS_sortedIndex = myDS_Idx;

ExplVar(8).name = 'DSz_after';
ExplVar(8).values = [zscore([DS_info1.DSAfter])';zscore([DS_info2.DSAfter])'];
ExplVar(8).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(8).values,'descend');
ExplVar(8).DS_sorted = myDS_sorted;
ExplVar(8).DS_sortedIndex = myDS_Idx;

ExplVar(9).name = 'Rank_after';
ExplVar(9).values = [[DS_info1.RankAfter]';[DS_info2.RankAfter]'];
ExplVar(9).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(9).values,'descend');
ExplVar(9).DS_sorted = myDS_sorted;
ExplVar(9).DS_sortedIndex = myDS_Idx;

clear DS_before DS_after DS_info1 DS_info
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day26to35_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info_chasing');
DS_before = DS_info_chasing;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day38to47_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info_chasing');
DS_after = DS_info_chasing;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info1.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info1.DSBefore = DS_before.DS;
        DS_info1.DSAfter = DS_after.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS],'descend');
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS],'descend');
            [~,Rank_before]=sort(Idx_before);
            DS_info1.RankDiff = [Rank_after-Rank_before];
            DS_info1.RankBefore = Rank_before;
            DS_info1.RankAfter = Rank_after;
        end
    else
        DS_info1.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

clear DS_before DS_after DS_info2 DS_info
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day19to28_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info_chasing');
DS_before = DS_info_chasing;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day31to40_11mice_withChasingAndDoubleChasing_thresh10.mat','DS_info_chasing');
DS_after = DS_info_chasing;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info2.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info2.DSBefore = DS_before.DS;
        DS_info2.DSAfter = DS_after.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS],'descend');
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS],'descend');
            [~,Rank_before]=sort(Idx_before);
            DS_info2.RankDiff = [Rank_after-Rank_before];
            DS_info2.RankBefore = Rank_before;
            DS_info2.RankAfter = Rank_after;
        end
    else
        DS_info2.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

ExplVar(10).name = 'Diff_DS_chasing';
ExplVar(10).values = [[DS_info1.DS]';[DS_info2.DS]'];
ExplVar(10).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(1).values,'descend');
ExplVar(10).DS_sorted = myDS_sorted;
ExplVar(10).DS_sortedIndex = myDS_Idx;

ExplVar(11).name = 'Diff_DSz_chasing';
ExplVar(11).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
ExplVar(11).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(11).values,'descend');
ExplVar(11).DS_sorted = myDS_sorted;
ExplVar(11).DS_sortedIndex = myDS_Idx;

ExplVar(12).name = 'Diff_Ranks_chasing';
ExplVar(12).values = [[DS_info1.RankDiff]';[DS_info2.RankDiff]'];
ExplVar(12).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(12).values,'descend');
ExplVar(12).DS_sorted = myDS_sorted;
ExplVar(12).DS_sortedIndex = myDS_Idx;

ExplVar(13).name = 'DS_before_chasing';
ExplVar(13).values = [[DS_info1.DSBefore]';[DS_info2.DSBefore]'];
ExplVar(13).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(13).values,'descend');
ExplVar(13).DS_sorted = myDS_sorted;
ExplVar(13).DS_sortedIndex = myDS_Idx;

ExplVar(14).name = 'DSz_before_chasing';
ExplVar(14).values = [zscore([DS_info1.DSBefore])';zscore([DS_info2.DSBefore])'];
ExplVar(14).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(14).values,'descend');
ExplVar(14).DS_sorted = myDS_sorted;
ExplVar(14).DS_sortedIndex = myDS_Idx;

ExplVar(15).name = 'Rank_before_chasing';
ExplVar(15).values = [[DS_info1.RankBefore]';[DS_info2.RankBefore]'];
ExplVar(15).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(15).values,'descend');
ExplVar(15).DS_sorted = myDS_sorted;
ExplVar(15).DS_sortedIndex = myDS_Idx;

ExplVar(16).name = 'DS_after_chasing';
ExplVar(16).values = [[DS_info1.DSAfter]';[DS_info2.DSAfter]'];
ExplVar(16).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(16).values,'descend');
ExplVar(16).DS_sorted = myDS_sorted;
ExplVar(16).DS_sortedIndex = myDS_Idx;

ExplVar(17).name = 'DSz_after_chasing';
ExplVar(17).values = [zscore([DS_info1.DSAfter])';zscore([DS_info2.DSAfter])'];
ExplVar(17).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(17).values,'descend');
ExplVar(17).DS_sorted = myDS_sorted;
ExplVar(17).DS_sortedIndex = myDS_Idx;

ExplVar(18).name = 'Rank_after_chasing';
ExplVar(18).values = [[DS_info1.RankAfter]';[DS_info2.RankAfter]'];
ExplVar(18).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(18).values,'descend');
ExplVar(18).DS_sorted = myDS_sorted;
ExplVar(18).DS_sortedIndex = myDS_Idx;

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
    outputDir_secondlevel = [workDir filesep 'secondlevel_' ExplVar(varIdx).name '_22_mice'];
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
    
    do_secondlevel_GLM_to_NoSeMaze_22_mice_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))
end











