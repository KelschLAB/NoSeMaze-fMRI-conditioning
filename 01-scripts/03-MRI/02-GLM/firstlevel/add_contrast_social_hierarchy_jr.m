%% add_contrast_social_hierarchy_jr.m
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
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix = '_v1.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c1_c2t_wds';

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/03-results');

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:22];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')

% start SPM fmri
spm('CreateMenuWin','off');
spm('CreateIntWin','off');

%% DEFINE CONTRASTS TO ADD
%% for ROI v1 and v4
% newConName{1} = 'Low'
% newConWeight{1} = [1]
% newConName{2} = 'High'
% newConWeight{2} = [0 1]
% newConName{3} = 'HighvsLow'
% newConWeight{3} = [-1 1]
% newConName{4} = 'HighANDLow'
% newConWeight{4} = [.5 .5]
% %% for ROI v3 (blocks)
% newConName{1} = 'Low_Bl1'
% newConWeight{1} = [1 0 0]
% newConName{2} = 'Low_Bl2'
% newConWeight{2} = [0 1 0]
% newConName{3} = 'Low_Bl3'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'Low_Bl2+Bl3'
% newConWeight{4} = [0 .5 .5]
% newConName{5} = 'High_Bl1'
% newConWeight{5} = [0 0 0 1 0 0]
% newConName{6} = 'High_Bl2'
% newConWeight{6} = [0 0 0 0 1 0]
% newConName{7} = 'High_Bl3'
% newConWeight{7} = [0 0 0 0 0 1]
% newConName{8} = 'High_Bl2+Bl3'
% newConWeight{8} = [0 0 0 0 .5 .5]
% newConName{9} = 'Low_Bl2+Bl3VSHigh_Bl2+Bl3'
% newConWeight{9} = [0 .5 .5 0 -.5 -.5]
% newConName{10} = 'Low_Bl1VSLow_Bl3'
% newConWeight{10} = [1 0 -1]
% newConName{11} = 'High_Bl1VSHigh_Bl3'
% newConWeight{11} = [0 0 0 1 0 -1]
% newConName{11} = 'High_Bl1VSLow_Bl1'
% newConWeight{11} = [-1 0 0 1 0 0]
%% for ROI v2 (On/Off)
% newConName{1} = 'Low_On'
% newConWeight{1} = [1 0 0]
% newConName{2} = 'Low_Off'
% newConWeight{2} = [0 1 0]
% newConName{3} = 'High_On'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'High_Off'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'Low_On_VS_Low_off'
% newConWeight{5} = [1 -1 0 0]
% newConName{6} = 'High_On_VS_High_off'
% newConWeight{6} = [0 0 1 -1]
% newConName{7} = 'High_On_VS_Low_On'
% newConWeight{7} = [-1 0 1 0]
% newConName{8} = 'High_Off_VS_Low_Off'
% newConWeight{8} = [0 -1 0 1]
% %% for ROI v5 (blocks)
% newConName{1} = 'Low_Bl1'
% newConWeight{1} = [1 0 0]
% newConName{2} = 'TP_Low_Bl1'
% newConWeight{2} = [0 1 0]
% newConName{3} = 'Low_B2'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'TP_Low_B2'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'Low_B3'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = 'TP_Low_B3'
% newConWeight{6} = [0 0 0 0 0 1]
% newConName{7} = 'High_Bl1'
% newConWeight{7} = [0 0 0 0 0 0 1 0 0]
% newConName{8} = 'TP_High_Bl1'
% newConWeight{8} = [0 0 0 0 0 0 0 1 0]
% newConName{9} = 'High_B2'
% newConWeight{9} = [0 0 0 0 0 0 0 0 1]
% newConName{10} = 'TP_High_B2'
% newConWeight{10} = [0 0 0 0 0 0 0 0 0 1]
% newConName{11} = 'High_B3'
% newConWeight{11} = [0 0 0 0 0 0 0 0 0 0 1]
% newConName{12} = 'TP_High_B3'
% newConWeight{12} = [0 0 0 0 0 0 0 0 0 0 0 1]
% %
% newConName{13} = 'Low_Bl1 VS TP_Low_Bl1'
% newConWeight{13} = [1 -1 0 0 0 0 0 0 0 0 0 0]
% newConName{14} = 'Low_Bl2 VS TP_Low_Bl2'
% newConWeight{14} = [0 0 1 -1 0 0 0 0 0 0 0 0]
% newConName{15} = 'Low_Bl3 VS TP_Low_Bl3'
% newConWeight{15} = [0 0 0 0 1 -1 0 0 0 0 0 0]
% newConName{16} = 'High_Bl1 VS TP_High_Bl1'
% newConWeight{16} = [0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0]
% newConName{17} = 'High_Bl2 VS TP_High_Bl2'
% newConWeight{17} = [0 0 0 0 0 0 0 0 1 -1 0 0]
% newConName{18} = 'High_Bl3 VS TP_High_Bl3'
% newConWeight{18} = [0 0 0 0 0 0 0 0 0 0 1 -1]
% %
% newConName{19} = 'TP_Low_Bl1 VS TP_Low_Bl3'
% newConWeight{19} = [0 1 0 0 0 -1 0 0 0 0 0 0]
% newConName{20} = 'TP_High_Bl1 VS TP_High_Bl3'
% newConWeight{20} = [0 0 0 0 0 0 0 1 0 0 0 -1]
% newConName{21} = 'TP_HighAndLow_Bl1 VS TP_HighAndLow_Bl3'
% newConWeight{21} = [0 1 0 0 0 -1 0 1 0 0 0 -1]
% %
% newConName{22} = 'TP_Low_Bl2 VS TP_Low_Bl3'
% newConWeight{22} = [0 0 0 1 0 -1 0 0 0 0 0 0]
% newConName{23} = 'TP_High_Bl2 VS TP_High_Bl3'
% newConWeight{23} = [0 0 0 0 0 0 0 0 0 1 0 -1]
% newConName{24} = 'TP_HighAndLow_Bl2 VS TP_HighAndLow_Bl3'
% newConWeight{24} = [0 0 0 1 0 -1 0 0 0 1 0 -1]
% %
% newConName{25} = 'Low_Bl1vsTP_Low_Bl1 VS Low_Bl3vsTP_Low_Bl3'
% newConWeight{25} = [1 -1 0 0 - 1 0 0 0 0 0 0]
% newConName{26} = 'High_Bl1vsTP_High_Bl1 VS High_Bl3vsTP_High_Bl3'
% newConWeight{26} = [0 0 0 0 0 0 1 -1 0 0 - 1]
% % 
% newConName{27} = 'OD_Low_Bl1 VS OD_Low_Bl3'
% newConWeight{27} = [1 0 0 0 -1 0 0 0 0 0 0]
% newConName{28} = 'OD_High_Bl1 VS OD_High_Bl3'
% newConWeight{28} = [0 0 0 0 0 0 1 0 0 0 -1]
% newConName{29} = 'OD_HighAndLow_Bl1 VS OD_HighAndLow_Bl3'
% newConWeight{29} = [1 0 0 0 -1 0 1 0 0 0 -1]
% %
% newConName{30} = 'OD_Low_Bl2 VS OD_Low_Bl3'
% newConWeight{30} = [0 0 1 0 -1 0 0 0 0 0 0]
% newConName{31} = 'OD_High_Bl2 VS OD_High_Bl3'
% newConWeight{31} = [0 0 0 0 0 0 0 0 1 0 -1]
% newConName{32} = 'OD_HighAndLow_Bl2 VS OD_HighAndLow_Bl3'
% newConWeight{32} = [0 0 1 0 -1 0 0 0 1 0 -1]

% %% for ROI v8 (blocks)
newConName{1} = 'OD_HighAndLow_Bl2_3 VS OD_HighAndLow_Bl5_6'
newConWeight{1} = [0 0 1 0 1 0 0 0 -1 0 -1 0 0 0 1 0 1 0 0 0 -1 0 -1 0]
newConName{2} = 'TP_HighAndLow_Bl2_3 VS TP_HighAndLow_Bl5_6'
newConWeight{2} = [0 0 0 1 0 1 0 0 0 -1 0 -1 0 0 0 1 0 1 0 0 0 -1 0 -1]


if 1==1
    %% Add Contrast
    if 1==1
        for subj = 1:length(Pfunc_social_hierarchy)
            
            
            % define subject abbreviation
            [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{subj});
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
            contrast_info.names{new_contrast_numb} = matlabbatch{1}.spm.stats.con.consess{conNumb}.fcon.name;
            contrast_info.test{new_contrast_numb} = 'fcon';
        elseif isfield(matlabbatch{1}.spm.stats.con.consess{conNumb},'tcon')
            contrast_info.names{new_contrast_numb} = matlabbatch{1}.spm.stats.con.consess{conNumb}.tcon.name;
            contrast_info.test{new_contrast_numb} = 'tcon';
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
    
    do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
end













