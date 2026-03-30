%% add_contrast_jr.m
%% Add additional contrasts

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/scripts/fMRI/GLM/'))

% define paths and regressors/covariates ...
% metainfo are saved in respective pathes
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/GLM/regressors/';
regressorsSuffix = '_v1.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/GLM/covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c1_c2t_wds';

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/GLM/results');

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:24];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/filelists/filelist_ICON_reappraisal_jr.mat')

% start SPM fmri
spm fmri;

%% DEFINE CONTRASTS TO ADD
% newConName{1} = 'Od_NoPuff_Bl1'
% newConWeight{1} = [1]
% newConName{2} = 'Od_NoPuff_Bl2'
% newConWeight{2} = [0 1]
% newConName{3} = 'Od_Puff_Bl2'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'Od_NoPuff_Bl3'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'TP_NoPuff_Bl1'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = 'TP_NoPuff_Bl2'
% newConWeight{6} = [0 0 0 0 0 1]
% newConName{7} = 'TP_Puff_Bl2'
% newConWeight{7} = [0 0 0 0 0 0 1]
% newConName{8} = 'TP_NoPuff_Bl3'
% newConWeight{8} = [0 0 0 0 0 0 0 1]
% 
% newConName{9} = 'OdVsTP_NoPuff_Bl1'
% newConWeight{9} = [1 0 0 0 -1]
% newConName{10} = 'OdVsTP_NoPuff_Bl2'
% newConWeight{10} = [0 1 0 0 0 -1]
% newConName{11} = 'OdVsTP_Puff_Bl2'
% newConWeight{11} = [0 0 1 0 0 0 -1]
% newConName{12} = 'OdVsTP_NoPuff_Bl3'
% newConWeight{12} = [0 0 0 1 0 0 0 -1]

% newConName{13} = 'OdVsTP_NoPuff_Bl1 vs OdVsTP_NoPuff_Bl3'
% newConWeight{13} = [1 0 0 -1 -1 0 0 1]


newConName{1} = 'Od_NoPuff_Bl1_1to21 vs Od_NoPuff_Bl3'
newConWeight{1} = [1 0 0 0 -1 0 0 0 0 0]
newConName{2} = 'TP_NoPuff_Bl1_1to21 vs TP_NoPuff_Bl3'
newConWeight{2} = [0 0 0 0 0 1 0 0 0 -1]
newConName{3} = 'Od_NoPuff_Bl1_21to40 vs Od_NoPuff_Bl3'
newConWeight{3} = [0 1 0 0 -1 0 0 0 0 0]
newConName{4} = 'TP_NoPuff_Bl1_21to40 vs TP_NoPuff_Bl3'
newConWeight{4} = [0 0 0 0 0 0 1 0 0 -1]
newConName{5} = 'Od_NoPuff_Bl2 vs Od_Puff_Bl2'
newConWeight{5} = [0 0 1 -1 0 0 0 0 0 0]
newConName{6} = 'TP_NoPuff_Bl2 vs TP_Puff_Bl2'
newConWeight{6} = [0 0 0 0 0 0 0 1 -1 0]
newConName{7} = 'TP_NoPuff_Bl2 vs TP_NoPuff_Bl3'
newConWeight{7} = [0 0 0 0 0 0 0 1 0 -1]

% newConName{1} = 'Lavender'
% newConWeight{1} = [1]
% newConName{2} = 'Puff'
% newConWeight{2} = [0 1]
% newConName{3} = 'TP1late_HighMotion'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'TP1late_LowMotion'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'TP2late_HighMotion'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = 'TP2late_LowMotion'
% newConWeight{6} = [0 0 0 0 0 1]
% newConName{7} = 'TP1late_HighVSLowMotion'
% newConWeight{7} = [0 0 1 -1]
% newConName{8} = 'TP2late_HighVSLowMotion'
% newConWeight{8} = [0 0 0 0 1 -1]
% newConName{9} = 'Puff VS ALLlate_HighVSLowMotion'
% newConWeight{9} = [0 1 -1 1 -1 1]

% newConName{1} = 'Lavender'
% newConWeight{1} = [1]
% newConName{2} = 'LowMotion Puff'
% newConWeight{2} = [0 1]
% newConName{3} = 'HighMotion Puff'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'LowVSHighMotion Puff'
% newConWeight{4} = [0 1 -1]

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
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/preprocessing/DARTEL/mask_template_6_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
end













