%% master_GLM_SecondLevel_SocialDefeatVsSocialHierarchy.m
% 08/2022 Reinwald, Jonathan
% Script for second-level analyses pairing sessions 2 (Social Defeat) and
% session 3 (Social Hierarchy) for the 


%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/02-GLM'))

% define paths and regressors/covariates ...
% as we use social defeat and social hierarchy data in here, we have *_sd
% and *_rp folders

% SOCIAL DEFEAT
% metainfo are saved in respective pathes
regressorsDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/';
regressorsSuffix_sd = '_v10.mat';
covarDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_sd = '_v1.mat';

% SOCIAL HIERARCHY
% metainfo are saved in respective pathes
regressorsDir_rp = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/02-regressors/';
regressorsSuffix_rp = '_v22.mat';
covarDir_rp = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_rp = '_v1.mat';


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

% general result directory
resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/05-social_between_sessions/05-GLM/03-results';

% firstlevel directory social defeat
firstlevelMainDir_SD = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results';
GLM_name = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix_sd(2:end-4) '___COV_' covarSuffix_sd(2:3) '___ORTH_' num2str(orth) '___28-Apr-2023'];%'___20-Jan-2023'
subDir = dir(firstlevelMainDir_SD);
firstlevelDir_SD = fullfile(subDir(contains({subDir.name},GLM_name)).folder,subDir(contains({subDir.name},GLM_name)).name,'firstlevel');

% firstlevel directory social hierarchy
firstlevelMainDir_RP = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results';
GLM_name = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix_rp(2:end-4) '___COV_' covarSuffix_rp(2:3) '___ORTH_' num2str(orth)];
subDir = dir(firstlevelMainDir_RP);
firstlevelDir_RP = fullfile(subDir(contains({subDir.name},GLM_name)).folder,subDir(contains({subDir.name},GLM_name)).name,'firstlevel');

% definition whether to use der or not
DerDisp=[0 0];

% load filelists
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')
% subject selection (CAVE: 22 subjects vor SH, 24 subjects for SD)
subfolders_sd = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing');
mySubjects_sd = {subfolders_sd(contains({subfolders_sd.name},'ZI_')).name};
subfolders_rp = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing');
mySubjects_rp = {subfolders_rp(contains({subfolders_rp.name},'ZI_')).name};
selection_sd = ismember(mySubjects_sd,mySubjects_rp);
selection_rp = ismember(mySubjects_rp,mySubjects_sd);
subjects = [1:sum(selection_rp)];
Pfunc_social_defeat=Pfunc_social_defeat(selection_sd);
Pfunc_reappraisal=Pfunc_reappraisal(selection_rp);

% clearing
clear matlabbatch input
% load predefined job
job_secondlevel_pairedTT_jr    

% contrast definition
load(fullfile(firstlevelDir_SD,'contrast_info.mat'));
contrast_names_SD = contrast_info.names(~contains([contrast_info.names],'vs'));
contrast_IDs_SD = find(~contains([contrast_info.names],'vs'));
contrast_names_SD = contrast_info.names(~contains([contrast_info.names],'VS'));
contrast_IDs_SD = find(~contains([contrast_info.names],'VS'));

load(fullfile(firstlevelDir_RP,'contrast_info.mat'));
contrast_names_RP = contrast_info.names(~contains([contrast_info.names],'vs'));
contrast_IDs_RP = find(~contains([contrast_info.names],'vs'));

if 1==1
    %% Loop over social defeat
    for i_SD = 1:length(contrast_names_SD) %[30:32]% (for selection of the regressors v6 in the defeat task including blocks 1-3)
        %% Loop over social hierarchy
        for i_RP = 1:length(contrast_names_RP) %[4,8]% (for selection of the regressors v3 in the hierarchy task including blocks 1-3)
            % definition of output directory
            outputDir = fullfile(resultsDir,['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '____SD_ROI_' regressorsSuffix_sd(2:end-4) '_vs_RP_ROI_' regressorsSuffix_rp(2:end-4)],[contrast_names_SD{i_SD} 'vs' contrast_names_RP{i_RP}]);
            if ~exist(outputDir)
                mkdir(outputDir);
            end
            
            % 1. Define output directory
            matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(outputDir)
            
            % 2. fill in the contrast pairs
            %% Loop over animals/sessions
            for subj = 1:length(subjects)
                % Subject
                [fdir_sd, fname_sd, ext_sd]=fileparts(Pfunc_social_defeat{subj});
                [fdir_rp, fname_rp, ext_rp]=fileparts(Pfunc_reappraisal{subj});
                subjAbrev = fname_sd(1:6);
                
                % Define Scans
                if contrast_IDs_SD(i_SD)<10
                    scan_SD = fullfile(firstlevelDir_SD,subjAbrev,['con_000' num2str(contrast_IDs_SD(i_SD)) '.nii']);
                else
                    scan_SD = fullfile(firstlevelDir_SD,subjAbrev,['con_00' num2str(contrast_IDs_SD(i_SD)) '.nii']);
                end
                
                if contrast_IDs_RP(i_RP)<10
                    scan_RP = fullfile(firstlevelDir_RP,subjAbrev,['con_000' num2str(contrast_IDs_RP(i_RP)) '.nii']);
                else
                    scan_RP = fullfile(firstlevelDir_RP,subjAbrev,['con_00' num2str(contrast_IDs_RP(i_RP)) '.nii']);
                end
                
                % Fill in Scans
                matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(subj).scans = {scan_SD;scan_RP};
            end
            
            explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
            matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
            matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);

            % 3. Run matlabscript
            spm_jobman('run',matlabbatch)
        end
    end
end

if 1==0
    % 
    i_SD = 4; i_RP = 8;
    
    % definition of output directory
    outputDir = fullfile(resultsDir,GLM_name,[contrast_names_RP{i_SD} 'vs' contrast_names_RP{i_RP}]);
    if ~exist(outputDir)
        mkdir(outputDir);
    end
    
    % 1. Define output directory
    matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(outputDir)
    
    % 2. fill in the contrast pairs
    %% Loop over animals/sessions
    for subj = 1:length(subjects)
        % Subject
        [fdir_sd, fname_sd, ext_sd]=fileparts(Pfunc_social_defeat{subj});
        [fdir_rp, fname_rp, ext_rp]=fileparts(Pfunc_reappraisal{subj});
        subjAbrev = fname_sd(1:6);
        
        % Define Scans
        if contrast_IDs_SD(i_SD)<10
            scan_SD = fullfile(firstlevelDir_RP,subjAbrev,['con_000' num2str(contrast_IDs_RP(i_SD)) '.nii']);
        else
            scan_SD = fullfile(firstlevelDir_RP,subjAbrev,['con_00' num2str(contrast_IDs_RP(i_SD)) '.nii']);
        end
        
        if contrast_IDs_RP(i_RP)<10
            scan_RP = fullfile(firstlevelDir_RP,subjAbrev,['con_000' num2str(contrast_IDs_RP(i_RP)) '.nii']);
        else
            scan_RP = fullfile(firstlevelDir_RP,subjAbrev,['con_00' num2str(contrast_IDs_RP(i_RP)) '.nii']);
        end
        
        % Fill in Scans
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(subj).scans = {scan_SD;scan_RP};
    end
    
    % 3. Run matlabscript
    spm_jobman('run',matlabbatch)
end
