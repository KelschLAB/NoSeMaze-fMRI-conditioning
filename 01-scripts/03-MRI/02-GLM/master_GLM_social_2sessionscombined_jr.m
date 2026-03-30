%% master_GLM_social_2sessionscombined_jr.m
% Reinwald, Jonathan; 02/2021

% PREPARATION:
% before running this script to create regressors and covariates:
% - create_regressors_social_defeat_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/
% - create_covariates_social_defeat_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/02-GLM'))

% define paths and regressors/covariates ...
% as we use social defeat and social hierarchy data in here, we have *_sd
% and *_sh folders

% SOCIAL DEFEAT
% metainfo are saved in respective pathes
regressorsDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/';
regressorsSuffix_sd_sel{1} = '_v1.mat';% 2.4 s 
regressorsSuffix_sd_sel{2} = '_v4.mat';% 0 s
regressorsSuffix_sd_sel{3} = '_v6.mat';% blocks
regressorsSuffix_sd_sel{4} = '_v2.mat';% On/Off

covarDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_sd = '_v1.mat';

% SOCIAL HIERARCHY
% metainfo are saved in respective pathes
regressorsDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix_sh_sel{1} = '_v1.mat';% 2.4 s 
regressorsSuffix_sh_sel{2} = '_v4.mat';% 0 s
regressorsSuffix_sh_sel{3} = '_v3.mat';% blocks
regressorsSuffix_sh_sel{4} = '_v2.mat';% On/Off

covarDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_sh = '_v1.mat';

% orthogonolization (for PM)
orth = 1;

% Loop over different regressors of interest
for regrIdx = 1:length(regressorsSuffix_sh_sel)
    
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
    
    regressorsSuffix_sd = regressorsSuffix_sd_sel{regrIdx};
    regressorsSuffix_sh = regressorsSuffix_sh_sel{regrIdx};
    
    % % % general result directory
    resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/05-GLM/03-results';
    % outputDirName
    if contains(epiSuffix,'noise')
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_' epiSuffix(end-4:end) '_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix_sd(2:end-4) '_' regressorsSuffix_sh(2:end-4) '___COV_' covarSuffix_sd(2:3) '_' covarSuffix_sh(2:3) '___ORTH_' num2str(orth) '___' date];
    elseif ~contains(epiSuffix,'noise')
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix_sd(2:end-4) '_' regressorsSuffix_sh(2:end-4) '___COV_' covarSuffix_sd(2:3) '_' covarSuffix_sh(2:3) '___ORTH_' num2str(orth)  '___' date];
    end
    
    % definition whether to use der or not
    DerDisp=[0 0];
    
    % load filelists
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')
    
    % subject selection (CAVE: 22 subjects vor SH, 24 subjects for SD)
    subfolders_sd = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing');
    mySubjects_sd = {subfolders_sd(contains({subfolders_sd.name},'ZI_')).name};
    
    subfolders_sh = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing');
    mySubjects_sh = {subfolders_sh(contains({subfolders_sh.name},'ZI_')).name};
    
    selection_sd = ismember(mySubjects_sd,mySubjects_sh);
    subjects = [1:length(mySubjects_sh)];
    
    Pfunc_social_defeat=Pfunc_social_defeat(selection_sd);
    
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
            clear regressors Pfuncall
            
            %% ----------- Preparation of input within loop -----------------------
            [fdir_sd, fname_sd, ext_sd]=fileparts(Pfunc_social_defeat{subj});
            [fdir_sh, fname_sh, ext_sh]=fileparts(Pfunc_social_hierarchy{subj});
            
            subjAbrev = fname_sd(1:6)
            
            %% 1. Create output directory
            outputDir = [resultsDir filesep outputDirName filesep 'firstlevel' filesep subjAbrev];
            if ~exist(outputDir)
                mkdir(outputDir)
            end
            
            %% 2. Load functional data
            if contains(epiPrefix,'wave');
                Pfuncall_sd = spm_select('ExtFPlist',[fdir_sd filesep 'wavelet'],[epiPrefix fname_sd epiSuffix '.nii'],[1:2500]);
                Pfuncall_sh = spm_select('ExtFPlist',[fdir_sh filesep 'wavelet'],[epiPrefix fname_sh epiSuffix '.nii'],[1:2500]);
            elseif ~contains(epiPrefix,'wave');
                Pfuncall_sd = spm_select('ExtFPlist',fdir_sd,[epiPrefix fname_sd epiSuffix '.nii'],[1:2500]);
                Pfuncall_sh = spm_select('ExtFPlist',fdir_sh,[epiPrefix fname_sh epiSuffix '.nii'],[1:2500]);
            end
            
            %% 3. Regressors of interest and Parametric Modulation
            % SOCIAL DEFEAT
            % 3.1 Load regressors of interest (ROIs)
            clear regressors ROI_sd PM_sd
            load([regressorsDir_sd subjAbrev regressorsSuffix_sd],'regressors');
            
            % 3.2 Create ROI input
            for ix = 1:length(regressors)
                ROI_sd(ix).name = regressors(ix).name;
                ROI_sd(ix).values = regressors(ix).onset;
                ROI_sd(ix).duration = regressors(ix).duration;
            end
            
            % 3.3 Create PM input
            counter=1;
            for ix = 1:length(regressors)
                if ~isempty(regressors(ix).pm)
                    for zx = 1:length(regressors(ix).pm)
                        PM_sd(counter).name = regressors(ix).pm(zx).name;
                        PM_sd(counter).vector = regressors(ix).pm(zx).vector;
                        PM_sd(counter).ROI_numb = ix;
                        counter=counter+1;
                    end
                end
            end
            
            if ~exist('PM');
                PM = [];
            end
            
            % SOCIAL HIERARCHY
            % 3.1 Load regressors of interest (ROIs)
            clear regressors ROI_sh PM_sh
            load([regressorsDir_sh subjAbrev regressorsSuffix_sh],'regressors');
            
            % 3.2 Create ROI input
            for ix = 1:length(regressors)
                ROI_sh(ix).name = regressors(ix).name;
                ROI_sh(ix).values = regressors(ix).onset;
                ROI_sh(ix).duration = regressors(ix).duration;
            end
            
            % 3.3 Create PM input
            counter=1;
            for ix = 1:length(regressors)
                if ~isempty(regressors(ix).pm)
                    for zx = 1:length(regressors(ix).pm)
                        PM_sh(counter).name = regressors(ix).pm(zx).name;
                        PM_sh(counter).vector = regressors(ix).pm(zx).vector;
                        PM_sh(counter).ROI_numb = ix;
                        counter=counter+1;
                    end
                end
            end
            
            if ~exist('PM');
                PM = [];
            end
            
            %% 4. Covariates
            % SOCIAL DEFEAT
            % 4.1 Load covariate regressors (motion, CSF, ...)
            clear covar COV_sd
            if ~(contains(covarSuffix_sd,'_v0'))
                load([covarDir_sd subjAbrev covarSuffix_sd],'covar');
                
                % 4.2 Save covariate input 0and names
                R = [covar.value];
                names = {covar.name};
                save([outputDir filesep 'cov_1.mat'],'R','names')
                COV_sd = [outputDir filesep 'cov_1.mat'];
            elseif contains(covarSuffix_sd,'_v0')
                COV_sd = [];
            end
            
            % SOCIAL HIERARCHY
            % 4.1 Load covariate regressors (motion, CSF, ...)
            clear covar COV_sh
            if ~(contains(covarSuffix_sh,'_v0'))
                load([covarDir_sh subjAbrev covarSuffix_sh],'covar');
                
                % 4.2 Save covariate input 0and names
                R = [covar.value];
                names = {covar.name};
                save([outputDir filesep 'cov_2.mat'],'R','names')
                COV_sh = [outputDir filesep 'cov_2.mat'];
            elseif contains(covarSuffix_sh,'_v0')
                COV_sh = [];
            end
            
            %% 5. Explicit mask
            %         explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';
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
                do_firstlevel_2sessions_jr(Pfuncall_sd,Pfuncall_sh,ROI_sd,ROI_sh,COV_sd,COV_sh,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
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
            explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
        
        
        %% 4. Define firstlevel-result directory
        firstlevelDir = [resultsDir filesep outputDirName filesep 'firstlevel'];
        
        
        do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
    end
end










