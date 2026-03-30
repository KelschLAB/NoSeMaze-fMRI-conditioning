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
% and *_sh folders

% SOCIAL DEFEAT
% metainfo are saved in respective pathes
regressorsDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/';
regressorsSuffix_sd = '_v4.mat';
covarDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix_sd = '_v1.mat';

% SOCIAL HIERARCHY
% metainfo are saved in respective pathes
regressorsDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix_sh = '_v4.mat';
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

% general result directory
resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/05-social_between_sessions/05-GLM/03-results';

% firstlevel directory social defeat
firstlevelMainDir_SD = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results';
GLM_name = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix_sd(2:end-4) '___COV_' covarSuffix_sd(2:3) '___ORTH_' num2str(orth) '___20-Jan-2023'];
subDir = dir(firstlevelMainDir_SD);
firstlevelDir_SD = fullfile(subDir(contains({subDir.name},GLM_name)).folder,subDir(contains({subDir.name},GLM_name)).name,'firstlevel');

% firstlevel directory social hierarchy
firstlevelMainDir_SH = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/03-results';
GLM_name = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix_sh(2:end-4) '___COV_' covarSuffix_sh(2:3) '___ORTH_' num2str(orth)];
subDir = dir(firstlevelMainDir_SH);
firstlevelDir_SH = fullfile(subDir(contains({subDir.name},GLM_name)).folder,subDir(contains({subDir.name},GLM_name)).name,'firstlevel');

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

% clearing
clear matlabbatch input
% load predefined job
job_secondlevel_pairedTT_jr    

% contrast definition
load(fullfile(firstlevelDir_SD,'contrast_info.mat'));
contrast_names_SD = contrast_info.names(~contains([contrast_info.names],'vs'));
contrast_IDs_SD = find(~contains([contrast_info.names],'vs'));


load(fullfile(firstlevelDir_SH,'contrast_info.mat'));
contrast_names_SH = contrast_info.names(~contains([contrast_info.names],'vs'));
contrast_IDs_SH = find(~contains([contrast_info.names],'vs'));

if 1==1
    %% Loop over social defeat
    for i_SD = 1:length(contrast_names_SD) %[30:32]% (for selection of the regressors v6 in the defeat task including blocks 1-3)
        %% Loop over social hierarchy
        for i_SH = 1:length(contrast_names_SH) %[4,8]% (for selection of the regressors v3 in the hierarchy task including blocks 1-3)
            % definition of output directory
            outputDir = fullfile(resultsDir,['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '____SD_ROI_' regressorsSuffix_sd(2:end-4) '_vs_SH_ROI_' regressorsSuffix_sh(2:end-4)],[contrast_names_SD{i_SD} 'vs' contrast_names_SH{i_SH}]);
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
                [fdir_sh, fname_sh, ext_sh]=fileparts(Pfunc_social_hierarchy{subj});
                subjAbrev = fname_sd(1:6);
                
                % Define Scans
                if contrast_IDs_SD(i_SD)<10
                    scan_SD = fullfile(firstlevelDir_SD,subjAbrev,['con_000' num2str(contrast_IDs_SD(i_SD)) '.nii']);
                else
                    scan_SD = fullfile(firstlevelDir_SD,subjAbrev,['con_00' num2str(contrast_IDs_SD(i_SD)) '.nii']);
                end
                
                if contrast_IDs_SH(i_SH)<10
                    scan_SH = fullfile(firstlevelDir_SH,subjAbrev,['con_000' num2str(contrast_IDs_SH(i_SH)) '.nii']);
                else
                    scan_SH = fullfile(firstlevelDir_SH,subjAbrev,['con_00' num2str(contrast_IDs_SH(i_SH)) '.nii']);
                end
                
                % Fill in Scans
                matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(subj).scans = {scan_SD;scan_SH};
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
    i_SD = 4; i_SH = 8;
    
    % definition of output directory
    outputDir = fullfile(resultsDir,GLM_name,[contrast_names_SH{i_SD} 'vs' contrast_names_SH{i_SH}]);
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
        [fdir_sh, fname_sh, ext_sh]=fileparts(Pfunc_social_hierarchy{subj});
        subjAbrev = fname_sd(1:6);
        
        % Define Scans
        if contrast_IDs_SD(i_SD)<10
            scan_SD = fullfile(firstlevelDir_SH,subjAbrev,['con_000' num2str(contrast_IDs_SH(i_SD)) '.nii']);
        else
            scan_SD = fullfile(firstlevelDir_SH,subjAbrev,['con_00' num2str(contrast_IDs_SH(i_SD)) '.nii']);
        end
        
        if contrast_IDs_SH(i_SH)<10
            scan_SH = fullfile(firstlevelDir_SH,subjAbrev,['con_000' num2str(contrast_IDs_SH(i_SH)) '.nii']);
        else
            scan_SH = fullfile(firstlevelDir_SH,subjAbrev,['con_00' num2str(contrast_IDs_SH(i_SH)) '.nii']);
        end
        
        % Fill in Scans
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(subj).scans = {scan_SD;scan_SH};
    end
    
    % 3. Run matlabscript
    spm_jobman('run',matlabbatch)
end
