%% add_contrast_reappraisal_jr.m
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
regressorsSuffix = '_v24.mat';
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

%% DEFINE CONTRASTS TO ADD

%% v25
newConName{1} = 'Od_NoPuff_Bl1_31to40 vs Od_NoPuff_Bl3_81to90'
newConWeight{1} = [0 1 0 0 -1 0 0]
newConName{2} = 'Od_NoPuff_Bl1_31to40 vs Od_NoPuff_Bl3_81to100'
newConWeight{2} = [0 1 0 0 -.5 -.5 0]
newConName{3} = 'Od_NoPuff_Bl1_31to40 vs Od_NoPuff_Bl3_101to120'
newConWeight{3} = [0 1 0 0 0 0 -1]
newConName{4} = 'Od_NoPuff_Bl3_81to90 vs Od_NoPuff_Bl3_101to120'
newConWeight{4} = [0 0 0 0 1 0 -1]
newConName{5} = 'TP_NoPuff_Bl3_81to90 vs TP_NoPuff_Bl1_31to40'
newConWeight{5} = [0 0 0 0 0 0 0 0 -1 0 0 1 0 0]
newConName{6} = 'TP_NoPuff_Bl3_81to100 vs TP_NoPuff_Bl1_31to40'
newConWeight{6} = [0 0 0 0 0 0 0 0 -1 0 0 .5 .5 0]

if 1==1
    %% Add Contrast
    if 1==1
        for subj = 1:length(Pfunc_reappraisal)
            
            
            % define subject abbreviation
            [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
            subjAbrev = fname(1:6)
            
            for conNumb = 1:length(newConName)
                % define SPM.mat
                matlabbatch{1}.spm.stats.con.spmmat = {[resultsDir filesep 'firstlevel' filesep subjAbrev filesep 'SPM.mat']};
                matlabbatch{1}.spm.stats.con.consess{conNumb}.tcon.name = newConName{conNumb};
                matlabbatch{1}.spm.stats.con.consess{conNumb}.tcon.weights = newConWeight{conNumb};
                matlabbatch{1}.spm.stats.con.consess{conNumb}.tcon.sessrep = 'none';
                matlabbatch{1}.spm.stats.con.delete = 1;
            end
            spm_jobman('run',matlabbatch);
            1==1;
        end
    end
    %% Add Contrast to contrast_info.mat
    % load
%     load([resultsDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
%     length_contrastinfo = length(contrast_info)
    
    for conNumb = 1:length(newConName)
        % add
%         new_contrast_numb = length_contrastinfo+conNumb;
        new_contrast_numb = conNumb;
        if isfield(matlabbatch{1}.spm.stats.con.consess{conNumb},'fcon')
            contrast_info{new_contrast_numb}.names = matlabbatch{1}.spm.stats.con.consess{conNumb}.fcon.name;
            contrast_info{new_contrast_numb}.test = 'fcon';
        elseif isfield(matlabbatch{1}.spm.stats.con.consess{conNumb},'tcon')
            contrast_info{new_contrast_numb}.names = matlabbatch{1}.spm.stats.con.consess{conNumb}.tcon.name;
            contrast_info{new_contrast_numb}.test = 'tcon';
        end
    end
    % save
    save([resultsDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==1
    %% 1. Create output directory
    outputDir_secondlevel = [resultsDir filesep 'secondlevel'];
    
    %% 2. Load contrast_names.mat
    load([resultsDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
    
    %% 3. Explicit mask
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
end













