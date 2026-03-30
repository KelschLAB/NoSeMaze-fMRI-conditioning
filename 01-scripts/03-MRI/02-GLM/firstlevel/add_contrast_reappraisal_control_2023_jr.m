%% add_contrast_reappraisal_control_2023_jr.m
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
regressorsDir = '/home/jonathan.reinwald/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/02-regressors';
regressorsSuffix = '_v5.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/01-covariates';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c2t_wds';

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/03-results');

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:24];

% load filelist
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat')

% start SPM fmri
spm fmri;

%% DEFINE CONTRASTS TO ADD
%% 22
newConName{1} = 'Od_NoPuff_Bl1_1to10 vs Od_NoPuff_Bl3'
newConWeight{1} = [1 0 0 -1 0 0 0 0]
newConName{2} = 'TP_NoPuff_Bl1_1to10 vs TP_NoPuff_Bl3'
newConWeight{2} = [0 0 0 0 1 0 0 -1]
newConName{3} = 'Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3'
newConWeight{3} = [0 1 0 -1 0 0 0 0]
newConName{4} = 'TP_NoPuff_Bl1_11to40 vs TP_NoPuff_Bl3'
newConWeight{4} = [0 0 0 0 0 1 0 -1]
newConName{5} = 'TP_NoPuff_Bl2 vs TP_NoPuff_Bl3'
newConWeight{5} = [0 0 0 0 0 0 1 -1]
newConName{6} = 'Od_NoPuff_Bl1_1to10'
newConWeight{6} = [1]
newConName{7} = 'Od_NoPuff_Bl1_11to40'
newConWeight{7} = [0 1]
newConName{8} = 'Od_NoPuff_Bl2'
newConWeight{8} = [0 0 1]
newConName{9} = 'Od_NoPuff_Bl3'
newConWeight{9} = [0 0 0 1]
newConName{10} = 'TP_NoPuff_Bl1_1to10'
newConWeight{10} = [0 0 0 0 1]
newConName{11} = 'TP_NoPuff_Bl1_11to40'
newConWeight{11} = [0 0 0 0 0 1]
newConName{12} = 'TP_NoPuff_Bl2'
newConWeight{12} = [0 0 0 0 0 0 1]
newConName{13} = 'TP_NoPuff_Bl3'
newConWeight{13} = [0 0 0 0 0 0 0 1]
newConName{14} = 'Od_NoPuff_Bl2 vs TP_NoPuff_Bl2'
newConWeight{14} = [0 0 1 0 0 0 -1 0]
newConName{15} = 'Od_NoPuff_Bl1_1to10 vs TP_NoPuff_Bl1_1to10'
newConWeight{15} = [1 0 0 0 -1 0 0 0]
newConName{16} = 'Od_NoPuff_Bl1_11to40 vs TP_NoPuff_Bl1_11to40'
newConWeight{16} = [0 1 0 0 0 -1 0 0]
newConName{17} = 'Od_NoPuff_Bl3 vs TP_NoPuff_Bl3'
newConWeight{17} = [0 0 0 1 0 0 0 -1]
newConName{18} = 'Od_NoPuff_Bl1_1to10 vs TP_NoPuff_Bl1_1to10 VS Od_NoPuff_Bl3 vs TP_NoPuff_Bl3'
newConWeight{18} = [1 0 0 -1 -1 0 0 1]
newConName{19} = 'Od_NoPuff_Bl1_11to40 vs TP_NoPuff_Bl1_11to40 VS Od_NoPuff_Bl3 vs TP_NoPuff_Bl3'
newConWeight{19} = [0 1 0 -1 0 -1 0 1]
newConName{20} = 'TP_NoPuff_all'
newConWeight{20} = [0 0 0 0 1 1 1 1]
newConName{21} = 'TP_NoPuff_Bl_1'
newConWeight{21} = [0 0 0 0 1 1 0 0]
newConName{22} = 'Od_NoPuff_Bl1_vs_TP_NoPuff_Bl1_VS_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3'
newConWeight{22} = [1 1 0 -1 -1 -1 0 1]
newConName{23} = 'Od_NoPuff_Bl1_1to10_vs_Od_NoPuff_Bl1_11to40'
newConWeight{23} = [1 -1 0 0 0 0 0 0]
newConName{24} = 'Od_NoPuff_Bl3 vs Od_NoPuff_Bl2'
newConWeight{24} = [0 0 -1 1 0 0 0 0]
newConName{25} = 'Od_NoPuff_Bl2 vs Od_NoPuff_Bl1_11to40'
newConWeight{25} = [0 -1 1 0 0 0 0 0]
newConName{26} = 'Odor_all'
newConWeight{26} = [1 1 1 1 0 0 0 0]
newConName{27} = 'TP_all'
newConWeight{27} = [0 0 0 0 1 1 1 1 ]
newConName{28} = 'TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40'
newConWeight{28} = [0 0 0 0 0 -1 0 1]
newConName{29} = 'Od_NoPuff_Bl3 vs Od_NoPuff_Bl1_11to40'
newConWeight{29} = [0 -1 0 1 0 0 0 0]
newConName{30} = 'TP_NoPuff_Bl3 vs TP_NoPuff_Bl2'
newConWeight{30} = [0 0 0 0 0 0 -1 1]
newConName{31} = 'TP_NoPuff_Bl11to40 vs TP_NoPuff_Bl2'
newConWeight{31} = [0 0 0 0 0 1 -1 0]

if 1==0
    %% Add Contrast
    if 1==1
        for subj = 1:length(Pfunc_reappraisal)
            
            
            % define subject abbreviation
            [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
            subjAbrev = ['ZI_' fname(4:11)];
            
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
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    do_secondlevel_control_2023_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
end













