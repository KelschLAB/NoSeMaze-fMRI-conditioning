%% add_contrast_reappraisal_secondlevel_pairedTT_jr.m
%% Add additional contrasts

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

% define paths and regressors/covariates ...
% metainfo are saved in respective pathes
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/02-regressors';
regressorsSuffix = '_v22.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/01-covariates';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c1_c2t_wds';

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results');

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:24];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% start SPM fmri
spm fmri;

% specification of contrasts to compare
contrast_new{1}.con1_name = 'Od_NoPuff_Bl1_11to40 vs TP_NoPuff_Bl1_11to40';
contrast_new{1}.con2_name = 'Od_NoPuff_Bl3 vs TP_NoPuff_Bl3';
contrast_new{1}.output_name = 'Od1TP1 vs Od3TP3';
contrast_new{2}.con1_name = 'Od_NoPuff_Bl2 vs TP_NoPuff_Bl2'
contrast_new{2}.con2_name = 'Od_Puff_Bl2 vs TP_Puff_Bl2'
contrast_new{2}.output_name = 'Od2TP2 vs Od2Puff2';
contrast_new{3}.con1_name = 'TP_NoPuff_Bl3 vs Od_NoPuff_Bl3'
contrast_new{3}.con2_name = 'TP_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl1_11to40'
contrast_new{3}.output_name = 'TP3Od3 vs TP1Od1';
contrast_new{4}.con1_name = 'TP_NoPuff_Bl2 vs Od_NoPuff_Bl2'
contrast_new{4}.con2_name = 'TP_Puff_Bl2 vs Od_Puff_Bl2'
contrast_new{4}.output_name = 'TP2Od2 vs Puff2Od2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==1
    %% 1. Create output directory
    outputDir_secondlevel = [resultsDir filesep 'secondlevel_pairedTT'];
    
    %% 2. Load contrast_names.mat
    load([resultsDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
    
    %% 3. Explicit mask
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    for con_ix = 1:length(contrast_new)
        
        % select current new contrast
        contrast_new_temp = contrast_new{con_ix};
        do_secondlevel_pairedTT_jr(outputDir_secondlevel,contrast_info,contrast_new_temp,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
    end
end


