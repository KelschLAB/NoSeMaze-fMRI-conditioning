%% master_corr_GLM_to_NoSeMazeGNG_reappraisal_jr.m
% Reinwald, Jonathan; 07/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)


%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

%% Load regressors of interest
%% Option 1: "short" regressors (only including the first 4 switches, phase 1-5)
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% load different hierarchies
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/covariates_short_jr.mat');
covariates_short = readtable('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/impulsivity_150trials.xlsx','Sheet',1,'ReadVariableNames', true);

% clearing
clear info

% variable names in the covariate file from David
VarNames = covariates_short.Properties.VariableNames;
% selection of variables in which we are interested
% VarSelection = {'lick_rate_at_odor_on_csminus_to_base','lick_rate_at_odor_on_csminus','cs_minus_pc1','cs_minus_pc2'};
VarSelection = {'cs_minus_pc1','cs_minus_pc2','correct_rejection','cs_minus_pc1_base','cs_minus_pc2_base','baseline_rate_CSminus_mean_omitfirst'};
% set variable counter
var_counter=1;
% Loop over variables
for idxV = 1:length(VarSelection)

    animal_counter=1;
    for idxT = 1:size(T,1)
        % add info on IDs
        info.ID_own{animal_counter}=T.AnimalIDCombined{idxT};
        % add infos on animal number
        info.AnimalNumb(animal_counter)=T.AnimalNumber(idxT);
        % add infos on covariates
        info.(VarSelection{idxV})(animal_counter)=covariates_short.(VarSelection{idxV})(strcmp(covariates_short.ID,info.ID_own{animal_counter}));
        animal_counter=animal_counter+1;
    end
    
    ExplVar(idxV).name = VarSelection{idxV};
    ExplVar(idxV).values = info.(VarSelection{idxV})';
    ExplVar(idxV).ID = info.ID_own;   
end

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results');

outputDir = fullfile(workDir,'corr_GNG_short');

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
    
    do_secondlevel_GLM_to_NoSeMaze_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))  
end


