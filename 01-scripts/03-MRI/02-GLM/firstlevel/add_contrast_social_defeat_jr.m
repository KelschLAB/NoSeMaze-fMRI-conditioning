%% add_contrast_social_defeat_jr.m
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
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/';
regressorsSuffix = '_v1.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c1_c2t_wds';

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results');

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:24];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')

% start SPM fmri
spm('CreateMenuWin','off');
spm('CreateIntWin','off');

%% DEFINE CONTRASTS TO ADD

%% for ROIs v11
% newConName{1} = 'CD1fam highMotion'
% newConWeight{1} = [1]
% newConName{2} = 'CD1unk highMotion'
% newConWeight{2} = [0 0 1]
% newConName{3} = '129sv highMotion'
% newConWeight{3} = [0 0 0 0 1]
% newConName{4} = 'CD1fam vs CD1unk highMotion'
% newConWeight{4} = [1 0 -1 0 0 0]
% newConName{5} = 'CD1fam vs 129sv highMotion'
% newConWeight{5} = [1 0 0 0 -1 0]
% newConName{6} = 'CD1unk vs 129sv highMotion'
% newConWeight{6} = [0 0 1 0 -1 0]
% 
% newConName{7} = 'CD1fam lowMotion'
% newConWeight{7} = [0 1]
% newConName{8} = 'CD1unk lowMotion'
% newConWeight{8} = [0 0 0 1]
% newConName{9} = '129sv lowMotion'
% newConWeight{9} = [0 0 0 0 0 1]
% newConName{10} = 'CD1fam vs CD1unk lowMotion'
% newConWeight{10} = [0 1 0 -1 0 0]
% newConName{11} = 'CD1fam vs 129sv lowMotion'
% newConWeight{11} = [0 1 0 0 0 -1]
% newConName{12} = 'CD1unk vs 129sv lowMotion'
% newConWeight{12} = [0 0 0 1 0 -1]

% %% for ROIs v90
% newConName{1} = 'CD1fam'
% newConWeight{1} = [1]
% newConName{2} = 'CD1unk'
% newConWeight{2} = [0 0 1]
% newConName{3} = '129sv'
% newConWeight{3} = [0 0 0 0 1]
% newConName{4} = 'CD1fam vs CD1unk'
% newConWeight{4} = [1 0 -1 0 0 0]
% newConName{5} = 'CD1fam vs 129sv'
% newConWeight{5} = [1 0 0 0 -1 0]
% newConName{6} = 'CD1unk vs 129sv'
% newConWeight{6} = [0 0 1 0 -1 0]
% 
% newConName{7} = 'CD1fam PM'
% newConWeight{7} = [0 1]
% newConName{8} = 'CD1unk PM'
% newConWeight{8} = [0 0 0 1]
% newConName{9} = '129sv PM'
% newConWeight{9} = [0 0 0 0 0 1]
% newConName{10} = 'CD1fam vs CD1unk PM'
% newConWeight{10} = [0 1 0 -1 0 0]
% newConName{11} = 'CD1fam vs 129sv PM'
% newConWeight{11} = [0 1 0 0 0 -1]
% newConName{12} = 'CD1unk vs 129sv PM'
% newConWeight{12} = [0 0 0 1 0 -1]

% %% for ROI v10 (blocks) and ROI v13
newConName{1} = 'CD1fam_Tr1to3'
newConWeight{1} = [1 0]
newConName{2} = 'CD1fam_Tr4to30'
newConWeight{2} = [0 1]
newConName{3} = 'CD1unk_Tr1to3'
newConWeight{3} = [0 0 1 0]
newConName{4} = 'CD1unk_Tr4to30'
newConWeight{4} = [0 0 0 1]
newConName{5} = '129sv_Tr1to3'
newConWeight{5} = [0 0 0 0 1 0]
newConName{6} = '129sv_Tr4to30'
newConWeight{6} = [0 0 0 0 0 1]

newConName{7} = 'CD1fam_Tr1to3_VS_Tr4to30'
newConWeight{7} = [1 -1]
newConName{8} = 'CD1unk_Tr1to3_VS_Tr4to30'
newConWeight{8} = [0 0 1 -1]
newConName{9} = '129sv_Tr1to3_VS_Tr4to30'
newConWeight{9} = [0 0 0 0 1 -1]
newConName{10} = 'ALL_Tr1to3_VS_Tr4to30'
newConWeight{10} = [1 -1 1 -1 1 -1]

newConName{11} = 'CD1fam_Tr4to30_VS_CD1unk_Tr4to30'
newConWeight{11} = [0 1 0 -1 0 0]
newConName{12} = 'CD1fam_Tr4to30_VS_129sv_Tr4to30'
newConWeight{12} = [0 1 0 0 0 -1]
newConName{13} = '129sv_Tr4to30_VS_CD1unk_Tr4to30'
newConWeight{13} = [0 0 0 1 0 -1]

newConName{14} = 'CD1fam_Tr1to3_VS_CD1unk_Tr1to3'
newConWeight{14} = [1 0 -1 0 0 0]
newConName{15} = 'CD1fam_Tr1to3_VS_129sv_Tr1to3'
newConWeight{15} = [1 0 0 0 -1 0]
newConName{16} = '129sv_Tr1to3_VS_CD1unk_Tr1to3'
newConWeight{16} = [0 0 1 0 -1 0]

%% for ROIs v1 and v4
% newConName{1} = 'CD1fam'
% newConWeight{1} = [1]
% newConName{2} = 'CD1unk'
% newConWeight{2} = [0 1]
% newConName{3} = '129sv'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'CD1fam vs CD1unk'
% newConWeight{4} = [1 -1 0]
% newConName{5} = 'CD1fam vs 129sv'
% newConWeight{5} = [1 0 -1]
% newConName{6} = 'CD1unk vs 129sv'
% newConWeight{6} = [0 1 -1]

% %% for ROIs v1 and v4 with derivatives
% newConName{1} = 'CD1fam'
% newConWeight{1} = [1 0]
% newConName{2} = 'CD1unk'
% newConWeight{2} = [0 0 0 1 0 0]
% newConName{3} = '129sv'
% newConWeight{3} = [0 0 0 0 0 0 1 0 0]
% newConName{4} = 'CD1fam vs CD1unk'
% newConWeight{4} = [1 0 0 -1 0 0 0 0 0]
% newConName{5} = 'CD1fam vs 129sv'
% newConWeight{5} = [1 0 0 0 0 0 -1 0 0]
% newConName{6} = 'CD1unk vs 129sv'
% newConWeight{6} = [0 0 0 1 0 0 -1 0 0]
% newConName{7} = 'CD1famD1'
% newConWeight{7} = [0 1 0]
% newConName{8} = 'CD1unkD1'
% newConWeight{8} = [0 0 0 0 1 0]
% newConName{9} = '129svD1'
% newConWeight{9} = [0 0 0 0 0 0 0 1 0]
% newConName{10} = 'CD1fam vs CD1unk D1'
% newConWeight{10} = [0 1 0 0 -1 0 0 0 0]
% newConName{11} = 'CD1fam vs 129sv D1'
% newConWeight{11} = [0 1 0 0 0 0 0 -1 0]
% newConName{12} = 'CD1unk vs 129sv D1'
% newConWeight{12} = [0 0 0 0 1 0 0 -1 0]
% newConName{13} = 'CD1famVSCD1famD1'
% newConWeight{13} = [1 -1]
% newConName{14} = 'CD1unkVSCD1unkD1'
% newConWeight{14} = [0 0 0 1 -1]
% newConName{15} = '129svVS129svD1'
% newConWeight{15} = [0 0 0 0 0 0 1 -1]
% newConName{16} = 'CD1famD2'
% newConWeight{16} = [0 0 1]
% newConName{17} = 'CD1unkD2'
% newConWeight{17}= [0 0 0 0 0 1]
% newConName{18} = '129svD2'
% newConWeight{18} = [0 0 0 0 0 0 0 0 1]
% newConName{19} = 'CD1fam vs CD1unk D2'
% newConWeight{19} = [0 0 1 0 0 -1 0 0 0]
% newConName{20} = 'CD1fam vs 129sv D2'
% newConWeight{20} = [0 0 1 0 0 0 0 0 -1]
% newConName{21} = 'CD1unk vs 129sv D2'
% newConWeight{21} = [0 0 0 0 0 1 0 0 -1]
% newConName{22} = 'CD1famVSCD1famD2'
% newConWeight{22} = [1 0 -1]
% newConName{23} = 'CD1unkVSCD1unkD2'
% newConWeight{23} = [0 0 0 1 0 -1]
% newConName{24} = '129svVS129svD2'
% newConWeight{24} = [0 0 0 0 0 0 1 0 -1]

% % %% for ROI v6/v9 (blocks)
% newConName{1} = 'CD1fam_Bl1'
% newConWeight{1} = [1 0 0]
% newConName{2} = 'CD1fam_Bl2'
% newConWeight{2} = [0 1 0]
% newConName{3} = 'CD1fam_Bl3'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'CD1unk_Bl1'
% newConWeight{4} = [0 0 0 1 0 0]
% newConName{5} = 'CD1unk_Bl2'
% newConWeight{5} = [0 0 0 0 1 0]
% newConName{6} = 'CD1unk_Bl3'
% newConWeight{6} = [0 0 0 0 0 1]
% newConName{7} = '129sv_Bl1'
% newConWeight{7} = [0 0 0 0 0 0 1 0 0]
% newConName{8} = '129sv_Bl2'
% newConWeight{8} = [0 0 0 0 0 0 0 1 0]
% newConName{9} = '129sv_Bl3'
% newConWeight{9} = [0 0 0 0 0 0 0 0 1]
% newConName{10} = 'CD1fam_Bl1_VS_Bl2and3'
% newConWeight{10} = [1 -0.5 -0.5]
% newConName{11} = 'CD1unk_Bl1_VS_Bl2and3'
% newConWeight{11} = [0 0 0 1 -0.5 -0.5]
% newConName{12} = '129sv_Bl1_VS_Bl2and3'
% newConWeight{12} = [0 0 0 0 0 0 1 -0.5 -0.5]
% newConName{13} = 'CD1fam_Bl1_VS_CD1unk_Bl1'
% newConWeight{13} = [1 0 0 -1]
% newConName{14} = 'CD1fam_Bl2_VS_CD1unk_Bl2'
% newConWeight{14} = [0 1 0 0 -1]
% newConName{15} = 'CD1fam_Bl3_VS_CD1unk_Bl3'
% newConWeight{15} = [0 0 1 0 0 -1]
% newConName{16} = 'CD1fam_Bl1_VS_129sv_Bl1'
% newConWeight{16} = [1 0 0 0 0 0 -1]
% newConName{17} = 'CD1fam_Bl2_VS_129sv_Bl2'
% newConWeight{17} = [0 1 0 0 0 0 0 -1]
% newConName{18} = 'CD1fam_Bl3_VS_129sv_Bl3'
% newConWeight{18} = [0 0 1 0 0 0 0 0 -1]
% newConName{19} = 'CD1unk_Bl1_VS_129sv_Bl1'
% newConWeight{19} = [0 0 0 1 0 0 -1]
% newConName{20} = 'CD1unk_Bl2_VS_129sv_Bl2'
% newConWeight{20} = [0 0 0 0 1 0 0 -1]
% newConName{21} = 'CD1unk_Bl3_VS_129sv_Bl3'
% newConWeight{21} = [0 0 0 0 0 1 0 0 -1]
% newConName{22} = 'CD1fam_Bl2and3_VS_CD1unk_Bl2and3'
% newConWeight{22} = [0 1 1 0 -1 -1]
% newConName{23} = 'CD1fam_Bl2and3_VS_129sv_Bl2and3'
% newConWeight{23} = [0 1 1 0 0 0 0 -1 -1]
% newConName{24} = 'CD1unk_Bl2and3_VS_CD1unk_Bl2and3'
% newConWeight{24} = [0 0 0 0 1 1 0 -1 -1]
% newConName{25} = 'CD1fam_Bl2and3_VS_All_Bl2and3'
% newConWeight{25} = [0 1 1 0 -0.5 -0.5 0 -0.5 -0.5]
% newConName{26} = 'CD1fam_Bl1_VS 2and3_VS_CD1unk_Bl1_VS_Bl2and3'
% newConWeight{26} = [1 -1 -1 -1 1 1]
% newConName{27} = 'CD1fam_Bl1_VS_Bl3'
% newConWeight{27} = [1 0 -1 0 0 0 0 0 0]
% newConName{28} = 'CD1unk_Bl1_VS_Bl3'
% newConWeight{28} = [0 0 0 1 0 -1 0 0 0]
% newConName{29} = '129sv_Bl1_VS_Bl3'
% newConWeight{29} = [0 0 0 0 0 0 1 0 -1]
% newConName{30} = 'CD1fam_Bl2+3'
% newConWeight{30} = [0 0.5 0.5]
% newConName{31} = 'CD1unk_Bl2+3'
% newConWeight{31} = [0 0 0 0 0.5 0.5]
% newConName{32} = '129sv_Bl2+Bl3'
% newConWeight{32} = [0 0 0 0 0 0 0 0.5 0.5]

%% for ROI v7 (blocks) {'CD1fam_Bl1';'TPafter_CD1fam_Bl1';'CD1fam_Bl2';'TPafter_CD1fam_Bl2';'CD1fam_Bl3';'TPafter_CD1fam_Bl3';'CD1unk_Bl1';'TPafter_CD1unk_Bl1';'CD1unk_Bl2';'TPafter_CD1unk_Bl2';'CD1unk_Bl3';'TPafter_CD1unk_Bl3';'129sv_Bl1';'TPafter_129sv_Bl1';'129sv_Bl2';'TPafter_129sv_Bl2';'129sv_Bl3';'TPafter_129sv_Bl3'}
% newConName{1} = 'TPafter_CD1fam_Bl1_VS_TPafter_CD1fam_Bl3'
% newConWeight{1} = [0 1 0 0 0 -1]
% newConName{2} = 'TPafter_CD1fam_Bl2_VS_TPafter_CD1fam_Bl3'
% newConWeight{2} = [0 0 0 1 0 -1]
% newConName{3} = 'TPafter_CD1unk_Bl1_VS_TPafter_CD1unk_Bl3'
% newConWeight{3} = [zeros(1,6) 0 1 0 0 0 -1]
% newConName{4} = 'TPafter_CD1unk_Bl2_VS_TPafter_CD1unk_Bl3'
% newConWeight{4} = [zeros(1,6) 0 0 0 1 0 -1]
% newConName{5} = 'TPafter_129sv_Bl1_VS_TPafter_129sv_Bl3'
% newConWeight{5} = [zeros(1,12) 0 1 0 0 0 -1]
% newConName{6} = 'TPafter_129sv_Bl2_VS_TPafter_129sv_Bl3'
% newConWeight{6} = [zeros(1,12) 0 0 0 1 0 -1]
% newConName{7} = 'TPafter_ALL_Bl1_VS_TPafter_ALL_Bl3'
% newConWeight{7} = [0 1 0 0 0 -1 0 1 0 0 0 -1 0 1 0 0 0 -1]
% newConName{8} = 'TPafter_ALL_Bl2_VS_TPafter_ALL_Bl3'
% newConWeight{8} = [0 0 0 1 0 -1 0 0 0 1 0 -1 0 0 0 1 0 -1]
% newConName{9} = '129sv_Bl3'
% newConWeight{9} = [0 0 0 0 0 0 0 0 1]
% newConName{10} = 'CD1fam_Bl1_VS_Bl2and3'
% newConWeight{10} = [1 -0.5 -0.5]
% newConName{11} = 'CD1unk_Bl1_VS_Bl2and3'
% newConWeight{11} = [0 0 0 1 -0.5 -0.5]
% newConName{12} = '129sv_Bl1_VS_Bl2and3'
% newConWeight{12} = [0 0 0 0 0 0 1 -0.5 -0.5]
% newConName{13} = 'CD1fam_Bl1_VS_CD1unk_Bl1'
% newConWeight{13} = [1 0 0 -1]
% newConName{14} = 'CD1fam_Bl2_VS_CD1unk_Bl2'
% newConWeight{14} = [0 1 0 0 -1]
% newConName{15} = 'CD1fam_Bl3_VS_CD1unk_Bl3'
% newConWeight{15} = [0 0 1 0 0 -1]
% newConName{16} = 'CD1fam_Bl1_VS_129sv_Bl1'
% newConWeight{16} = [1 0 0 0 0 0 -1]
% newConName{17} = 'CD1fam_Bl2_VS_129sv_Bl2'
% newConWeight{17} = [0 1 0 0 0 0 0 -1]
% newConName{18} = 'CD1fam_Bl3_VS_129sv_Bl3'
% newConWeight{18} = [0 0 1 0 0 0 0 0 -1]
% newConName{19} = 'CD1unk_Bl1_VS_129sv_Bl1'
% newConWeight{19} = [0 0 0 1 0 0 -1]
% newConName{20} = 'CD1unk_Bl2_VS_129sv_Bl2'
% newConWeight{20} = [0 0 0 0 1 0 0 -1]
% newConName{21} = 'CD1unk_Bl3_VS_129sv_Bl3'
% newConWeight{21} = [0 0 0 0 0 1 0 0 -1]
% newConName{22} = 'CD1fam_Bl2and3_VS_CD1unk_Bl2and3'
% newConWeight{22} = [0 1 1 0 -1 -1]
% newConName{23} = 'CD1fam_Bl2and3_VS_129sv_Bl2and3'
% newConWeight{23} = [0 1 1 0 0 0 0 -1 -1]
% newConName{24} = 'CD1unk_Bl2and3_VS_CD1unk_Bl2and3'
% newConWeight{24} = [0 0 0 0 1 1 0 -1 -1]
% newConName{25} = 'CD1fam_Bl2and3_VS_All_Bl2and3'
% newConWeight{25} = [0 1 1 0 -0.5 -0.5 0 -0.5 -0.5]
% newConName{26} = 'CD1fam_Bl1_VS 2and3_VS_CD1unk_Bl1_VS_Bl2and3'
% newConWeight{26} = [1 -1 -1 -1 1 1]
% newConName{27} = 'CD1fam_Bl1_VS_Bl3'
% newConWeight{27} = [1 0 -1 0 0 0 0 0 0]
% newConName{28} = 'CD1unk_Bl1_VS_Bl3'
% newConWeight{28} = [0 0 0 1 0 -1 0 0 0]
% newConName{29} = '129sv_Bl1_VS_Bl3'
% newConWeight{29} = [0 0 0 0 0 0 1 0 -1]
% newConName{30} = 'CD1fam_Bl2+3'
% newConWeight{30} = [0 0.5 0.5]
% newConName{31} = 'CD1unk_Bl2+3'
% newConWeight{31} = [0 0 0 0 0.5 0.5]
% newConName{32} = '129sv_Bl2+Bl3'
% newConWeight{32} = [0 0 0 0 0 0 0 0.5 0.5]

%% for ROI v2
% newConName{1} = 'CD1 fam On'
% newConWeight{1} = [1]
% newConName{2} = 'CD1 fam Off'
% newConWeight{2} = [0 1]
% newConName{3} = 'CD1 unk On'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'CD1 unk Off'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = '129sv On'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = '129sv Off'
% newConWeight{6} = [0 0 0 0 0 1]
% 
% newConName{7} = 'CD1famOn Vs CD1famOff'
% newConWeight{7} = [1 -1 0 0]
% newConName{8} = 'CD1unkOn Vs CD1unkOff'
% newConWeight{8} = [0 0 1 -1]
% newConName{9} = '129svOn Vs 29svOff'
% newConWeight{9} = [0 0 0 0 1 -1]
% 
% newConName{10} = 'CD1famOnVsCD1famOff Vs CD1unkOnVsCD1unkOff'
% newConWeight{10} = [1 -1 -1 1]
% newConName{11} = 'CD1famOnVsCD1famOff Vs 129svOnVs29svOff'
% newConWeight{11} = [1 -1 0 0 -1 1]
% newConName{12} = 'CD1unkOnVsCD1unkOff Vs 129svOnVs29svOff'
% newConWeight{12} = [0 0 1 -1 -1 1]
% 
% newConName{13} = 'CD1famOn Vs CD1unkOn'
% newConWeight{13} = [1 0 -1]
% newConName{14} = 'CD1famOn Vs 129svOn'
% newConWeight{14} = [1 0 0 0 -1]
% newConName{15} = 'CD1unkOn Vs 129svOn'
% newConWeight{15} = [0 0 1 0 -1]
% 
% newConName{16} = 'CD1famOff Vs CD1unkOff'
% newConWeight{16} = [0 1 0 -1]
% newConName{17} = 'CD1famOff Vs 129svOff'
% newConWeight{17} = [0 1 0 0 0 -1]
% newConName{18} = 'CD1unkOff Vs 129svOff'
% newConWeight{18} = [0 0 0 1 0 -1]

%% XXXXXXXXXXXXXXXXXXXXXXXX
% newConName{1} = 'Bl1 CD1fam 1stTR'
% newConWeight{1} = [1]
% newConName{2} = 'Bl1 CD1fam 2ndTR'
% newConWeight{2} = [0 1]
% newConName{3} = 'Bl2 CD1fam 1stTR'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'Bl2 CD1fam 2ndTR'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'Bl3 CD1fam 1stTR'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = 'Bl3 CD1fam 2ndTR'
% newConWeight{6} = [0 0 0 0 0 1]
%
% newConName{7} = 'Bl1 CD1unk 1stTR'
% newConWeight{7} = [0 0 0 0 0 0 1]
% newConName{8} = 'Bl1 CD1unk 2ndTR'
% newConWeight{8} = [0 0 0 0 0 0 0 1]
% newConName{9} = 'Bl2 CD1unk 1stTR'
% newConWeight{9} = [0 0 0 0 0 0 0 0 1]
% newConName{10} = 'Bl2 CD1unk 2ndTR'
% newConWeight{10} = [0 0 0 0 0 0 0 0 0 1]
% newConName{11} = 'Bl3 CD1unk 1stTR'
% newConWeight{11} = [0 0 0 0 0 0 0 0 0 0 1]
% newConName{12} = 'Bl3 CD1unk 2ndTR'
% newConWeight{12} = [0 0 0 0 0 0 0 0 0 0 0 1]
%
% newConName{13} = 'Bl1 129sv 1stTR'
% newConWeight{13} = [0 0 0 0 0 0 0 0 0 0 0 0 1]
% newConName{14} = 'Bl1 129sv 2ndTR'
% newConWeight{14} = [0 0 0 0 0 0 0 0 0 0 0 0 0 1]
% newConName{15} = 'Bl2 129sv 1stTR'
% newConWeight{15} = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]
% newConName{16} = 'Bl2 129sv 2ndTR'
% newConWeight{16} = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]
% newConName{17} = 'Bl3 129sv 1stTR'
% newConWeight{17} = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]
% newConName{18} = 'Bl3 129sv 2ndTR'
% newConWeight{18} = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]

% % newConName{1} = 'Bl3 CD1famVsCD1unk 1stTR'
% % newConWeight{1} = [0 0 0 0 1 0 0 0 0 0 -1]
% % newConName{2} = 'Bl3 CD1famVsCD1unk 2ndTR'
% % newConWeight{2} = [0 0 0 0 0 1 0 0 0 0 0 -1]
% % newConName{3} = 'Bl1VsBl3 CD1fam 1stTR'
% % newConWeight{3} = [1 0 0 0 -1 0]
% % newConName{4} = 'Bl1VsBl3 CD1unk 1stTR'
% % newConWeight{4} = [0 0 0 0 0 0 1 0 0 0 -1]
% % newConName{5} = 'Bl1VsBl3 CD1famVSCD1unk 1stTR'
% % newConWeight{5} = [1 0 0 0 -1 0 -1 0 0 0 1 0]
% % newConName{6} = 'Bl1 CD1famVsCD1unk 1stTR'
% % newConWeight{6} = [1 0 0 0 0 0 -1]
% % newConName{7} = 'Bl3 CD1famVs129sv 1stTR'
% % newConWeight{7} = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 -1]
% % newConName{8} = 'Bl3 CD1famVs129sv 2ndTR'
% % newConWeight{8} = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 -1]
% % newConName{9} = 'Bl1VsBl3 129sv 1stTR'
% % newConWeight{9} = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0  -1 0]
% % newConName{10} = 'Bl1VsBl3 CD1famVS129sv 1stTR'
% % newConWeight{10} = [1 0 0 0 -1 0 0 0 0 0 0 0 -1 0 0 0 1 0]
% % newConName{11} = 'Bl1 CD1famVs129sv 1stTR'
% % newConWeight{11} = [1 0 0 0 0 0 0 0 0 0 0 0 -1]
% % newConName{12} = 'Bl1 CD1famVs129sv 2ndTR'
% % newConWeight{12} = [0 1 0 0 0 0 0 0 0 0 0 0 0 -1]
% % newConName{13} = 'Bl2 CD1famVs129sv 1stTR'
% % newConWeight{13} = [0 0 1 0 0 0 0 0 0 0 0 0 0 0 -1]
% % newConName{14} = 'Bl2 CD1famVs129sv 2ndTR'
% % newConWeight{14} = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 -1]

if 1==1
    %% Add Contrast
    if 1==1
        for subj = 1:length(Pfunc_social_defeat)
            
            
            % define subject abbreviation
            [fdir, fname, ext]=fileparts(Pfunc_social_defeat{subj});
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
    %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
    %     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
end













