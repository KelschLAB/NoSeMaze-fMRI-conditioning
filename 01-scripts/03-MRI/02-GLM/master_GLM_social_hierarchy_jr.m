%% master_GLM_social_hierarchy_jr.m
% Reinwald, Jonathan; 02/2021

% PREPARATION:
% before running this script to create regressors and covariates:
% - create_regressors_social_hierarchy_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_hierarchy/05-GLM/02-regressors/
% - create_covariates_social_hierarchy_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_hierarchy/05-GLM/01-covariates/

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/02-GLM'))

% define paths and regressors/covariates ...
% metainfo are saved in respective pathes
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix_sel{1} = '_v1.mat';
regressorsSuffix_sel{2} = '_v2.mat';
regressorsSuffix_sel{3} = '_v3.mat';
regressorsSuffix_sel{4} = '_v4.mat';
regressorsSuffix_sel{5} = '_v5.mat';
regressorsSuffix_sel{6} = '_v6.mat';
regressorsSuffix_sel{7} = '_v7.mat';
regressorsSuffix_sel{8} = '_v8.mat';

covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% orthogonolization (for PM)
orth = 1;

% Loop over different regressors of interest
for regrIdx = 8:length(regressorsSuffix_sel)
    
    % current regressor of interest
    regressorsSuffix = regressorsSuffix_sel{regrIdx};
    
    % HRF selection
    HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
    HRF_onset = 'withoutOnset'; % 'withoutOnset';
    HRF_infopath = [HRF_onset '_' HRF_estimateLength];
    HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
    
    % selection of EPI
    epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_';
%     epiPrefix = 'med1000_msk_s6_wrst_a1_u_del5_';
    epiSuffix = '_c1_c2t_wds';
%     epiSuffix = '_c1_c2t';
    
    % general result directory
    resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/03-results';
    % outputDirName
    if contains(epiSuffix,'noise')
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_' epiSuffix(end-4:end) '_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth) '___' date];
    elseif ~contains(epiSuffix,'noise')
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth)  '___' date];
    end
    
    
    % definition whether to use der or not
    DerDisp=[0 0];
    
    % subject selection
    subjects = [1:22];
    
    % load filelist
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')
    
    % start SPM fmri
    spm('CreateMenuWin','off');
    spm('CreateIntWin','off');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ------------------------- FIRST-LEVEL ANALYSIS ---------------------- %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==1
        %% Loop over animals/sessions
        for subj = 1:length(subjects)
            tic
            % pre-clearing
            clear regressors Pfuncall ROI Pfuncall ROI COV explicit_mask fmri_t fmri_t0 TR outputDir mask_thres PM
            
            %% ----------- Preparation of input within loop -----------------------
            [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{subj});
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
            
            % 3.2 Create ROI input
            for ix = 1:length(regressors)
                ROI(ix).name = regressors(ix).name;
                ROI(ix).values = regressors(ix).onset;
                ROI(ix).duration = regressors(ix).duration;
            end
            
            % 3.3 Create PM input
            counter=1;
            for ix = 1:length(regressors)
                if ~isempty(regressors(ix).pm)
                    for zx = 1:length(regressors(ix).pm)
                        PM(counter).name = regressors(ix).pm(zx).name;
                        PM(counter).vector = regressors(ix).pm(zx).vector;
                        PM(counter).ROI_numb = ix;
                        counter=counter+1;
                    end
                end
            end
            
            if ~exist('PM');
                PM = [];
            end
            
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
            %         explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
            explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
            
            
            %% 6. Define microtime resolution (fmri_t) and microtime onset (fmri_t0)
            nSlices = 22;
            refSlice = 1;
            fmri_t = 22;
            fmri_t0 = 1;
            
            %% 7. Masking threshold and TR
            mask_thres = 0;
            TR = 1.2;
            
            %% --------------------------- SPM GLM --------------------------------
            if 1==1
                % load animal HRF
                addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));
                % run first-level analysis
                do_firstlevel_jr(Pfuncall,ROI,COV,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
            end
            toc
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==1
        %% 1. Create output directory
        outputDir_secondlevel = [resultsDir filesep outputDirName filesep 'secondlevel'];
        if ~exist(outputDir_secondlevel)
            mkdir(outputDir_secondlevel)
        end
        
        %% 2. Load contrast_names.mat
        load([resultsDir filesep outputDirName filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
        
        %% 3. Explicit mask
        %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
        explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
        
        
        %% 4. Define firstlevel-result directory
        firstlevelDir = [resultsDir filesep outputDirName filesep 'firstlevel'];
        
        
        do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
    end
end











