%% master_corr_GLM_to_NoSeMazeSH_reappraisal_control_2023_jr.m
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

%% Load regressors of interest
%% For each animal, social hierarchy is used based on the 14 days before the scans
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/05-AM_Danae_cohort1/social_hierarchy_Danae_control_2023.xlsx','Sheet',1,'ReadVariableNames', true);

ExplVar(1).name = 'DavidsScore';
ExplVar(1).values = T.Davids_score;
ExplVar(1).ID = T.scan_ID;
ExplVar(1).AnimalNumb = T.scan_ID;

ExplVar(2).name = 'Rank';
ExplVar(2).values = T.social_rank;
ExplVar(2).ID = T.scan_ID;
ExplVar(2).AnimalNumb = T.scan_ID;

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/03-results');
outputDir = fullfile(workDir,'corr_SocialHierarchy');
if exist(outputDir)~=7
    mkdir(outputDir);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = 1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [outputDir filesep 'secondlevel_' ExplVar(varIdx).name ];
    if ~exist(outputDir_secondlevel)
        mkdir(outputDir_secondlevel)
    end
    
    %% 2. Load contrast_names.mat
    load([workDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
    
    %% 3. Explicit mask
    %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [workDir filesep 'firstlevel'];
    
    do_secondlevel_GLM_to_NoSeMaze_control_2023_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))  
end











