%% master_GLM_residuals_reappraisal_jr.m
% Reinwald, Jonathan; 06/2021

% PREPARATION:
% before running this script to create regressors and covariates:
% - create_regressors_ICON_RPE_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/GLM/regressors/
% --> script in /home/jonathan.reinwald/ICON_RPE/scripts/MRTPrediction/fMRI/GLM/regressors
% - create_covariates_ICON_RPE_jr.m --> creates covariates in /home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/GLM/covariates/
% --> script in /home/jonathan.reinwald/ICON_RPE/scripts/MRTPrediction/fMRI/GLM/covariates

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-TC_analysis'))

%% Preparation
clear all;
% close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

% define paths and regressors/covariates ...
% metainfo are saved in respective pathes
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/01-regressors/';
regressorsSuffix = '_v99.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/02-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% orthogonolization (for PM)
orth = 1; 

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'

% selection of EPI
% epiPrefix = 'DVARSscrub_0_1_lin_wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_';
epiPrefix = 'med1000_msk_s6_wrst_a1_u_despiked_del5_';
% epiPrefix = 'med1000_msk_s6_scrub_0_1_lin_wrst_a1_u_del5_';
% epiSuffix = '_c1_c2t_wds';
epiSuffix = '_c1_c2t';

% date ='10-Jan-2022'

% general result directory
resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results';
% outputDirName
if contains(epiSuffix,'noise')
    outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_' epiSuffix(end-4:end) '_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth) '___' date];
elseif ~contains(epiSuffix,'noise')
    outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth)  '___' date];
end

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:24];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% start SPM fmri
spm('CreateMenuWin','off');
spm('CreateIntWin','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------- FIRST-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==1
    
    
    %% I. Switch SPM-version
    % This step is needed to use the correct SPM-version, in which the
    % residuals will not be automatically deleted
    spm12switch_residuals_JR
    
     %% Loop over animals/sessions
    for subj = 1:length(subjects)
        tic
        % pre-clearing
        clear regressors Pfuncall
        
        %% ----------- Preparation of input within loop -----------------------
        [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
        subjAbrev = fname(1:6)
        
        %% 1. Create output directory        
        outputDir = [resultsDir filesep outputDirName filesep 'firstlevel' filesep subjAbrev];
        if ~exist(outputDir)
            mkdir(outputDir)
        end
        
        %% 2. Load functional data
        if contains(epiPrefix,'wave');
            Pfuncall = spm_select('ExtFPlist',[fdir filesep 'wavelet'],[epiPrefix fname epiSuffix '.nii'],[1:2500]);
        elseif ~contains(epiPrefix,'wave');
            Pfuncall = spm_select('ExtFPlist',fdir,[epiPrefix fname epiSuffix '.nii'],[1:2500]);
        end
            
        %% 3. Regressors of interest and Parametric Modulation
        % 3.1 Load regressors of interest (ROIs)
        load([regressorsDir subjAbrev regressorsSuffix],'regressors');
                       
        %% 4. Covariates
        % 4.1 Load covariate regressors (motion, CSF, ...)
        if ~(contains(covarSuffix,'_v0'))
            load([covarDir subjAbrev covarSuffix],'covar');
            
            % 4.2 Save covariate input 0and names
            R = [covar.value];
            names = {covar.name};
            save([outputDir filesep 'cov.mat'],'R','names')
            COV = [outputDir filesep 'cov.mat'];
        elseif contains(covarSuffix,'_v0')
            COV = [];
        end
            
        %% 5. Explicit mask
        explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
        
        %% 6. Define microtime resolution (fmri_t) and microtime onset (fmri_t0)
        nSlices = 22;
        refSlice = 1;
        fmri_t = 22;
        fmri_t0 = 1;
        
        %% 7. Masking threshold and TR
        mask_thres = 0;
        TR = 1.2;
        PM=[];
        ROI=[];
        
        %% --------------------------- SPM GLM --------------------------------
        if 1==1
             % load animal HRF
             addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));
            
            % run first-level analysis
            do_firstlevel_residuals_jr(Pfuncall,ROI,COV,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,PM,mask_thres,orth)

        end
        toc
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------- MERGE RESIDUAL FILES ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==1
    %% Clear
    clear outputDir
    
    %% Define output directory
    outputDir = [resultsDir filesep outputDirName];
    
    %% Merge residuals
    merge_residuals_jr(outputDir)
end



