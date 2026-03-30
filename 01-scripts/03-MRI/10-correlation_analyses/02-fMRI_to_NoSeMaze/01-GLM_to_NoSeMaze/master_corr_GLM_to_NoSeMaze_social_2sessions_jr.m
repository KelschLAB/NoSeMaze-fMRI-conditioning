%% master_corr_GLM_to_NoSeMaze_social_2sessions_jr.m
% Reinwald, Jonathan; 01/2023

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

%% Load regressors of interest
% Social hierarchy with David's Score
ExplVar(1).name = 'DavidsScore';
load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day1to43.mat','DS_info');
DS_info1 = DS_info;
load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to43.mat','DS_info');
DS_info2 = DS_info;
ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];

ExplVar(2).name = 'DavidsScore_Zscored';
ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];

% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Predefinitions for GLM selection

% define paths and regressors/covariates ...
% as we use social defeat and social hierarchy data in here, we have *_sd
% and *_sh folders

% SOCIAL DEFEAT
% metainfo are saved in respective pathes
regressorsDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/';
regressorsSuffix_sd = '_v1.mat';
covarDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_sd = '_v1.mat';

% SOCIAL HIERARCHY
% metainfo are saved in respective pathes
regressorsDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix_sh = '_v1.mat';
covarDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_sh = '_v1.mat';

% orthogonolization (for PM)
orth = 1; 

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_';
% epiPrefix = 'med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c1_c2t_wds';
% epiSuffix = '_c1_c2t';

% general result input and output directory
inputDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results';
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/08-correlation_analyses_fMRI_to_NoSeMaze/01-GLM_to_NoSeMaze';

% date specification if you want to select a specific analysis
date = '20-Dec-2022';

% % % general result directory
resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessions/05-GLM/03-results';
% inputDirName
if contains(epiSuffix,'noise')
    inputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_' epiSuffix(end-4:end) '_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix_sd(2:end-4) '_' regressorsSuffix_sh(2:end-4) '___COV_' covarSuffix_sd(2:3) '_' covarSuffix_sh(2:3) '___ORTH_' num2str(orth) '___' date];
elseif ~contains(epiSuffix,'noise')
    inputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix_sd(2:end-4) '_' regressorsSuffix_sh(2:end-4) '___COV_' covarSuffix_sd(2:3) '_' covarSuffix_sh(2:3) '___ORTH_' num2str(orth)  '___' date];
end

% definition whether to use der or not
DerDisp=[0 0];


% load filelists
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = 1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [resultsDir filesep inputDirName filesep 'secondlevel_' ExplVar(varIdx).name ];
    if ~exist(outputDir_secondlevel)
        mkdir(outputDir_secondlevel)
    end
    
    %% 2. Load contrast_names.mat
    load([resultsDir filesep inputDirName filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');

    %% 3. Explicit mask
%     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';

    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep inputDirName filesep 'firstlevel'];
    
    
    do_secondlevel_GLM_to_NoSeMaze_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))
end











