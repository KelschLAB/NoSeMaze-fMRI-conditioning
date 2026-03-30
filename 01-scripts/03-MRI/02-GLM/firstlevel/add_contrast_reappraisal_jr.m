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
regressorsSuffix = '_v22.mat';
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
spm('CreateMenuWin','off');
spm('CreateIntWin','off');

%% DEFINE CONTRASTS TO ADD
%% v22, DerDisp1
% % % % % newConName{1} = 'Od_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3'
% % % % % newConWeight{1} = [0 0 0, 1 0 0, 0 0 0, 0 0 0, -1 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0]
% % % % % newConName{2} = 'Od_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3 DerDisp 1'
% % % % % newConWeight{2} = [0 0 0, 0 1 0, 0 0 0, 0 0 0, 0 -1 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0]
% % % % % newConName{3} = 'Od_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3 DerDisp 2'
% % % % % newConWeight{3} = [0 0 0, 0 0 1, 0 0 0, 0 0 0, 0 0 -1, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0]
% % % % % 
% % % % % newConName{4} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40'
% % % % % newConWeight{4} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, -1 0 0, 0 0 0, 0 0 0, 1 0 0]
% % % % % newConName{5} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40 DerDisp 1'
% % % % % newConWeight{5} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, -1 0 0, 0 0 0, 0 0 0, 1 0 0]
% % % % % newConName{6} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40 DerDisp 2'
% % % % % newConWeight{6} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, -1 0 0, 0 0 0, 0 0 0, 1 0 0]
% % % % % 
% % % % % newConName{7} = 'Od_Puff_Bl2_vs_TP_Puff_Bl2'
% % % % % newConWeight{7} = [0 0 0, 0 0 0, 0 0 0, 1 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, -1 0 0, 0 0 0]
% % % % % newConName{8} = 'Od_Puff_Bl2_vs_TP_Puff_Bl2 DerDisp 1'
% % % % % newConWeight{8} = [0 0 0, 0 0 0, 0 0 0, 0 1 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 -1 0, 0 0 0]
% % % % % newConName{9} = 'Od_Puff_Bl2_vs_TP_Puff_Bl2 DerDisp 2'
% % % % % newConWeight{9} = [0 0 0, 0 0 0, 0 0 0, 0 0 1, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 -1, 0 0 0]
% % % % % 
% % % % % newConName{10} = 'TP_Puff_Bl2_VS_TP_NoPuff_Bl2'
% % % % % newConWeight{10} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, -1 0 0, 1 0 0, 0 0 0]
% % % % % newConName{11} = 'TP_Puff_Bl2_VS_TP_NoPuff_Bl2 DerDisp 1'
% % % % % newConWeight{11} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 -1 0, 0 1 0, 0 0 0]
% % % % % newConName{12} = 'TP_Puff_Bl2_VS_TP_NoPuff_Bl2 DerDisp 2'
% % % % % newConWeight{12} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 -1, 0 0 1, 0 0 0]
% % % % % 
% % % % % newConName{13} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40 ALL'
% % % % % newConWeight{13} = [0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, 0 0 0, -1/3 -1/3 -1/3, 0 0 0, 0 0 0, 1/3 1/3 1/3]
% v19 
% newConName{1} = 'Lavender'0
% newConWeight{1} = [1]
% newConName{2} = 'Puff'
% newConWeight{2} = [0 1]
% newConName{3} = 'NoPuff'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'PuffvsNoPuff'
% newConWeight{4} = [0 1 -1]
% newConName{5} = 'PuffvsLavANDNoPuff'
% newConWeight{5} = [-1 1 -1]




% newConName{10} = 'PuffvsHigh'
% newConWeight{10} = [0 1 -1 0 -1]
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
% 
% newConName{13} = 'OdVsTP_NoPuff_Bl1_vs_OdVsTP_NoPuff_Bl3'
% newConWeight{13} = [1 0 0 -1 -1 0 0 1]

%% for ROIs: v22 and v24
%% Basic
newConName{1} = 'Od_NoPuff_Bl1_1to10'
newConWeight{1} = [1]
newConName{2} = 'Od_NoPuff_Bl1_11to40'
newConWeight{2} = [0 1]
newConName{3} = 'Od_NoPuff_Bl2'
newConWeight{3} = [0 0 1]
newConName{4} = 'Od_Puff_Bl2'
newConWeight{4} = [0 0 0 1]
newConName{5} = 'Od_NoPuff_Bl3'
newConWeight{5} = [0 0 0 0 1]
newConName{6} = 'TP_NoPuff_Bl_1_1to10'
newConWeight{6} = [0 0 0 0 0 1 0 0 0 0]
newConName{7} = 'TP_NoPuff_Bl_1_11to40'
newConWeight{7} = [0 0 0 0 0 0 1 0 0 0]
newConName{8} = 'TP_NoPuff_Bl_2'
newConWeight{8} = [0 0 0 0 0 0 0 1 0 0]
newConName{9} = 'TP_Puff_Bl_2'
newConWeight{9} = [0 0 0 0 0 0 0 0 1 0]
newConName{10} = 'TP_NoPuff_Bl_3'
newConWeight{10} = [0 0 0 0 0 0 0 0 0 1]
% %% TP Puff/No Puff
newConName{11} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40'
newConWeight{11} = [0 0 0 0 0 0 -1 0 0 1]
newConName{12} = 'TP_NoPuff_Bl3_vs_TP_Puff_Bl1_all'
newConWeight{12} = [0 0 0 0 0 -0.25 -0.75 0 0 1]
newConName{13} = 'TP_NoPuff_Bl2_vs_TP_Puff_Bl2'
newConWeight{13} = [0 0 0 0 0 0 0 1 -1 0]
newConName{14} = 'TP_NoPuff_Bl3_vs_TP_Puff_Bl2'
newConWeight{14} = [0 0 0 0 0 0 0 0 -1 1]
newConName{15} = 'TP_NoPuff_Bl11to40_vs_TP_Puff_Bl2'
newConWeight{15} = [0 0 0 0 0 0 1 0 -1 0]
newConName{16} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl2'
newConWeight{16} = [0 0 0 0 0 0 0 -1 0 1]
newConName{17} = 'TP_NoPuff_Bl11to40_vs_TP_NoPuff_Bl2'
newConWeight{17} = [0 0 0 0 0 0 1 -1 0 0]
% %% Odor
newConName{18} = 'Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40'
newConWeight{18} = [0 -1 0 0 1 0 0 0 0 0]
newConName{19} = 'Odor_NoPuff_Bl3_vs_Odor_Puff_Bl1_all'
newConWeight{19} = [-0.25 -0.75 0 0 1 0 0 0 0 0]
newConName{20} = 'Odor_NoPuff_Bl2_vs_Odor_Puff_Bl2'
newConWeight{20} = [0 0 1 -1 0 0 0 0 0 0]
newConName{21} = 'Odor_NoPuff_Bl3_vs_Odor_Puff_Bl2'
newConWeight{21} = [0 0 0 -1 1 0 0 0 0 0]
newConName{22} = 'Odor_NoPuff_Bl11to40_vs_Odor_Puff_Bl2'
newConWeight{22} = [0 1 0 -1 0 0 0 0 0 0]
newConName{23} = 'Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl2'
newConWeight{23} = [0 0 -1 0 1 0 0 0 0 0]
newConName{24} = 'Odor_NoPuff_Bl11to40_vs_Odor_NoPuff_Bl2'
newConWeight{24} = [0 1 -1 0 0 0 0 0 0 0]
% %% Complex
newConName{25} = 'Od_NoPuff_Bl1_1to10_vs_TP_NoPuff_Bl1_1to10_vs_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3'
newConWeight{25} = [0.5 0 0 0 -0.5 -0.5 0 0 0 0.5]
newConName{26} = 'Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3'
newConWeight{26} = [0 0.5 0 0 -0.5 0 -0.5 0 0 0.5]
% 
% %% Od_vs_TP
newConName{27} = 'Od_NoPuff_Bl1_1to10_vs_TP_NoPuff_Bl1_1to10'
newConWeight{27} = [1 0 0 0 0 -1 0 0 0 0]
newConName{28} = 'Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40'
newConWeight{28} = [0 1 0 0 0 0 -1 0 0 0]
newConName{29} = 'Od_NoPuff_Bl2_vs_TP_NoPuff_Bl2'
newConWeight{29} = [0 0 1 0 0 0 0 -1 0 0]
newConName{30} = 'Od_Puff_Bl2_vs_TP_Puff_Bl2'
newConWeight{30} = [0 0 0 1 0 0 0 0 -1 0]
newConName{31} = 'Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3'
newConWeight{31} = [0 0 0 0 1 0 0 0 0 -1]

newConName{32} = 'TP_NoPuff_Bl1_1to10_vs_TP_NoPuff_Bl1_11to40'
newConWeight{32} = [0 0 0 0 0 1 -1 0 0 0]
newConName{33} = 'Od_NoPuff_Bl1_1to10_vs_TP_NoPuff_Bl1_1to10_vs_Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40'
newConWeight{33} = [0.5 -0.5 0 0 0 -0.5 0.5 0 0 0]

newConName{34} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_1to10'
newConWeight{34} = [0 0 0 0 0 -1 0 0 0 1]
newConName{35} = 'TP_NoPuff_Bl1_1to10_vs_TP_NoPuff_Bl2'
newConWeight{35} = [0 0 0 0 0 1 0 -1 0 0]
newConName{36} = 'TP_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl2'
newConWeight{36} = [0 0 0 0 0 0 1 -1 0 0]

newConName{37} = 'Od_NoPuff_Bl1_1to10_vs_Od_NoPuff_Bl1_11to40'
newConWeight{37} = [1 -1]

newConName{38} = 'Od_NoPuff_Bl1_all'
newConWeight{38} = [.25 .75]

newConName{39} = 'TP_NoPuff_Bl3_vs_Od_NoPuff_Bl1_11to40'
newConWeight{39} = [0 -1 0 0 0 0 0 0 0 1]

newConName{40} = 'Od_NoPuff_Bl1_11to40_and_Bl3_vs_TP_NoPuff_Bl1_11to40_and_Bl3_MAIN_OdvsTp'
newConWeight{40} = [0 1 0 0 1 0 -1 0 0 -1]

newConName{41} = 'Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40_and_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3_MAIN_Bl1vsBl3'
newConWeight{41} = [0 1 0 0 -1 0 1 0 0 -1]

newConName{42} = 'Odor_NoPuff_Bl2_vs_Odor_NoPuff_Bl1_11to40'
newConWeight{42} = [0 -1 1 0 0 0 0 0 0 0]

newConName{43} = 'Odor_NoPuff_Bl2_vs_Odor_NoPuff_Bl1_11to40_and_Bl3'
newConWeight{43} = [0 -.5 1 0 -.5 0 0 0 0 0]
% % % %% for ROIs: v79
% % % %% Basic
% % % newConName{1} = 'Od_NoPuff_Bl1_1to10'
% % % newConWeight{1} = [1]
% % % newConName{2} = 'Od_NoPuff_Bl1_11to40'
% % % newConWeight{2} = [0 1]
% % % newConName{3} = 'Od_NoPuff_Bl2'
% % % newConWeight{3} = [0 0 1]
% % % newConName{4} = 'Od_Puff_Bl2'
% % % newConWeight{4} = [0 0 0 1]
% % % newConName{5} = 'Od_NoPuff_Bl3'
% % % newConWeight{5} = [0 0 0 0 1]
% % % newConName{6} = 'PM_Od_NoPuff_Bl3'
% % % newConWeight{6} = [0 0 0 0 0 1]
% % % newConName{7} = 'TP_NoPuff_Bl_1_1to10'
% % % newConWeight{7} = [0 0 0 0 0 0 1 0 0 0 0]
% % % newConName{8} = 'TP_NoPuff_Bl_1_11to40'
% % % newConWeight{8} = [0 0 0 0 0 0 0 1 0 0 0]
% % % newConName{9} = 'TP_NoPuff_Bl_2'
% % % newConWeight{9} = [0 0 0 0 0 0 0 0 1 0 0]
% % % newConName{10} = 'TP_Puff_Bl_2'
% % % newConWeight{10} = [0 0 0 0 0 0 0 0 0 1 0]
% % % newConName{11} = 'TP_NoPuff_Bl_3'
% % % newConWeight{11} = [0 0 0 0 0 0 0 0 0 0 1]
% % % newConName{12} = 'PM_TP_NoPuff_Bl_3'
% % % newConWeight{12} = [0 0 0 0 0 0 0 0 0 0 0 1]
% % % %% TP Puff/No Puff
% % % newConName{13} = 'TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40'
% % % newConWeight{13} = [0 0 0 0 0 0 0 -1 0 0 1 0]
% % % newConName{14} = 'PM_TP_NoPuff_Bl3_vs_TP_Puff_Bl1_11to40'
% % % newConWeight{14} = [0 0 0 0 0 0 0 -1 0 0 0 1]
% % % newConName{15} = 'PM_TP_NoPuff_Bl3_vs_TP_NoPuff_Bl3'
% % % newConWeight{15} = [0 0 0 0 0 0 0 0 0 0 -1 1]
% % % %% Odor
% % % newConName{16} = 'Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40'
% % % newConWeight{16} = [0 -1 0 0 1 0 0 0 0 0 0 0]
% % % newConName{17} = 'PM_Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40'
% % % newConWeight{17} = [0 -1 0 0 0 1 0 0 0 0 0 0]
% % % newConName{18} = 'Odor_NoPuff_Bl3_vs_PM_Odor_NoPuff_Bl3'
% % % newConWeight{18} = [0 0 0 0 -1 1 0 0 0 0 0 0]

%% for ROIs: v25
% %% Basic
% newConName{1} = 'OdorON_Bl1_1to10'
% newConWeight{1} = [1]
% newConName{2} = 'OdorON_Bl1_11to40'
% newConWeight{2} = [0 1]
% newConName{3} = 'OdorON_nopuff_Bl2'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'OdorON_puff_Bl2'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'OdorON_Bl3'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = 'OdorOFF_Bl_1_1to10'
% newConWeight{6} = [0 0 0 0 0 1 0 0 0 0]
% newConName{7} = 'OdorOFF_Bl_1_11to40'
% newConWeight{7} = [0 0 0 0 0 0 1 0 0 0]
% newConName{8} = 'OdorOFF_nopuff_Bl_2'
% newConWeight{8} = [0 0 0 0 0 0 0 1 0 0]
% newConName{9} = 'OdorOFF_puff_Bl_2'
% newConWeight{9} = [0 0 0 0 0 0 0 0 1 0]
% newConName{10} = 'OdorOFF_Bl_3'
% newConWeight{10} = [0 0 0 0 0 0 0 0 0 1]
% %% TP Puff/No Puff
% newConName{11} = 'OdorOFF_Bl3_vs_OdorOFF_Bl1_11to40'
% newConWeight{11} = [0 0 0 0 0 0 -1 0 0 1]
% newConName{12} = 'OdorOFF_Bl3_vs_TP_Puff_Bl1_all'
% newConWeight{12} = [0 0 0 0 0 -0.25 -0.75 0 0 1]
% newConName{13} = 'OdorOFF_nopuff_Bl2_vs_OdorOFF_puff_Bl2'
% newConWeight{13} = [0 0 0 0 0 0 0 1 -1 0]
% newConName{14} = 'OdorOFF_Bl3_vs_OdorOFF_puff_Bl2'
% newConWeight{14} = [0 0 0 0 0 0 0 0 -1 1]
% newConName{15} = 'OdorOFF_Bl1_all_vs_OdorOFF_puff_Bl2'
% newConWeight{15} = [0 0 0 0 0 0.25 0.75 0 -1 0]
% newConName{16} = 'OdorOFF_Bl3_vs_OdorOFF_nopuff_Bl2'
% newConWeight{16} = [0 0 0 0 0 0 0 -1 0 1]
% newConName{17} = 'OdorOFF_Bl1_all_vs_OdorOFF_nopuff_Bl2'
% newConWeight{17} = [0 0 0 0 0 0.25 0.75 -1 0 0]
% %% Odor
% newConName{18} = 'OdorON_Bl3_vs_OdorON_Bl1_11to40'
% newConWeight{18} = [0 -1 0 0 1 0 0 0 0 0]
% newConName{19} = 'OdorON_Bl3_vs_OdorON_puff_Bl1_all'
% newConWeight{19} = [-0.25 -0.75 0 0 1 0 0 0 0 0]
% newConName{20} = 'OdorON_nopuff_Bl2_vs_OdorON_puff_Bl2'
% newConWeight{20} = [0 0 1 -1 0 0 0 0 0 0]
% newConName{21} = 'OdorON_Bl3_vs_OdorON_puff_Bl2'
% newConWeight{21} = [0 0 0 -1 1 0 0 0 0 0]
% newConName{22} = 'OdorON_Bl1_all_vs_OdorON_puff_Bl2'
% newConWeight{22} = [0.25 0.75 0 -1 0 0 0 0 0 0]
% newConName{23} = 'OdorON_Bl3_vs_OdorON_nopuff_Bl2'
% newConWeight{23} = [0 0 -1 0 1 0 0 0 0 0]
% newConName{24} = 'OdorON_Bl1_all_vs_OdorON_nopuff_Bl2'
% newConWeight{24} = [0.25 0.75 -1 0 0 0 0 0 0 0]
% %% Complex
% newConName{25} = 'OdorON_Bl1_1to10_vs_OdorOFF_Bl1_1to10_vs_OdorON_Bl3_vs_OdorOFF_Bl3'
% newConWeight{25} = [0.5 0 0 0 -0.5 -0.5 0 0 0 0.5]
% newConName{26} = 'OdorON_Bl1_11to40_vs_OdorOFF_Bl1_11to40_vs_OdorON_Bl3_vs_OdorOFF_Bl3'
% newConWeight{26} = [0 0.5 0 0 -0.5 0 -0.5 0 0 0.5]
% 
% %% Od_vs_TP
% newConName{27} = 'OdorON_Bl1_1to10_vs_OdorOFF_Bl1_1to10'
% newConWeight{27} = [1 0 0 0 0 -1 0 0 0 0]
% newConName{28} = 'OdorON_Bl1_11to40_vs_OdorOFF_Bl1_11to40'
% newConWeight{28} = [0 1 0 0 0 0 -1 0 0 0]
% newConName{29} = 'OdorON_nopuff_Bl2_vs_OdorOFF_nopuff_Bl2'
% newConWeight{29} = [0 0 1 0 0 0 0 -1 0 0]
% newConName{30} = 'OdorON_puff_Bl2_vs_OdorOFF_puff_Bl2'
% newConWeight{30} = [0 0 0 1 0 0 0 0 -1 0]
% newConName{31} = 'OdorON_Bl3_vs_OdorOFF_Bl3'
% newConWeight{31} = [0 0 0 0 1 0 0 0 0 -1]
% 
% newConName{32} = 'OdorOFF_Bl1_1to10_vs_OdorOFF_Bl1_11to40'
% newConWeight{32} = [0 0 0 0 0 1 -1 0 0 0]
% newConName{33} = 'OdorON_Bl1_1to10_vs_OdorOFF_Bl1_1to10_vs_OdorON_Bl1_11to40_vs_OdorOFF_Bl1_11to40'
% newConWeight{33} = [0.5 -0.5 0 0 0 -0.5 0.5 0 0 0]
% 
% newConName{34} = 'OdorOFF_Bl3_vs_OdorOFF_Bl1_1to10'
% newConWeight{34} = [0 0 0 0 0 -1 0 0 0 1]
% newConName{35} = 'OdorOFF_Bl1_1to10_vs_OdorOFF_nopuff_Bl2'
% newConWeight{35} = [0 0 0 0 0 1 0 -1 0 0]
% newConName{36} = 'OdorOFF_Bl1_11to40_vs_OdorOFF_nopuff_Bl2'
% newConWeight{36} = [0 0 0 0 0 0 1 -1 0 0]
% 
% newConName{37} = 'OdorON_Bl1_1to10_vs_OdorON_Bl1_11to40'
% newConWeight{37} = [1 -1]
% 
% newConName{38} = 'OdorON_Bl1_11to40_PLUS_OdorOFF_Bl1_11to40_vs_OdorON_Bl3_PLUS_OdorOFF_Bl3'
% newConWeight{38} = [0 .5 0 0 -.5 0 .5 0 0 -.5]
% 
% newConName{39} = 'OdorON_Bl1_11to40_PLUS_OdorON_Bl3_vs_OdorOFF_Bl1_11to40_PLUS_OdorOFF_Bl3'
% newConWeight{39} = [0 .5 0 0 .5 0 -.5 0 0 -.5]
% 
% newConName{40} = 'OdorON_all'
% newConWeight{40} = [0 1 1 0 1 0 0 0 0 0]
% 
% newConName{41} = 'OdorOFF_all'
% newConWeight{41} = [0 0 0 0 0 0 1 1 0 1]

% %% for ROIs: v29
% %% Basic
% newConName{1} = 'Od_NoPuff_Bl1_1to20'
% newConWeight{1} = [1]
% newConName{2} = 'Od_NoPuff_Bl1_21to40'
% newConWeight{2} = [0 1]
% newConName{3} = 'Od_NoPuff_Bl2'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'Od_Puff_Bl2'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = 'Od_NoPuff_Bl3_81to100'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = 'Od_NoPuff_Bl3_101to120'
% newConWeight{6} = [0 0 0 0 0 1]
% newConName{7} = 'TP_NoPuff_Bl_1_1to20'
% newConWeight{7} = [0 0 0 0 0 0 1]
% newConName{8} = 'TP_NoPuff_Bl_1_21to40'
% newConWeight{8} = [0 0 0 0 0 0 0 1]
% newConName{9} = 'TP_NoPuff_Bl_2'
% newConWeight{9} = [0 0 0 0 0 0 0 0 1]
% newConName{10} = 'TP_Puff_Bl_2'
% newConWeight{10} = [0 0 0 0 0 0 0 0 0 1]
% newConName{11} = 'TP_NoPuff_Bl3_81to100'
% newConWeight{11} = [0 0 0 0 0 0 0 0 0 0 1]
% newConName{12} = 'TP_NoPuff_Bl3_101to120'
% newConWeight{12} = [0 0 0 0 0 0 0 0 0 0 0 1]
% %% TP Puff/No Puff
% newConName{13} = 'TP_NoPuff_Bl_1_1to20_VS_TP_NoPuff_Bl_1_21to40'
% newConWeight{13} = [0 0 0 0 0 0 1 -1]
% newConName{14} = 'TP_NoPuff_Bl_1_1to20_VS_TP_NoPuff_Bl3_81to100'
% newConWeight{14} = [0 0 0 0 0 0 1 0 0 0 -1]
% newConName{15} = 'TP_NoPuff_Bl_1_1to20_VS_TP_NoPuff_Bl3_101to120'
% newConWeight{15} = [0 0 0 0 0 0 1 0 0 0 0 -1]
% newConName{16} = 'TP_NoPuff_Bl_1_21to40_VS_TP_NoPuff_Bl3_81to100'
% newConWeight{16} = [0 0 0 0 0 0 0 1 0 0 -1]
% newConName{17} = 'TP_NoPuff_Bl_1_21to40_VS_TP_NoPuff_Bl3_101to120'
% newConWeight{17} = [0 0 0 0 0 0 0 1 0 0 0 -1]
% newConName{18} = 'TP_NoPuff_Bl_3_81to100_VS_TP_NoPuff_Bl3_101to120'
% newConWeight{18} = [0 0 0 0 0 0 0 0 0 0 1 -1]
% newConName{19} = 'TP_NoPuff_Bl_1_1to20_VS_TP_NoPuff_Bl3_81to120'
% newConWeight{19} = [0 0 0 0 0 0 1 0 0 0 -.5 -.5]
% newConName{20} = 'TP_NoPuff_Bl_1_21to40_VS_TP_NoPuff_Bl3_81to120'
% newConWeight{20} = [0 0 0 0 0 0 0 1 0 0 -.5 -.5]
% 
% newConName{21} = 'Od_NoPuff_Bl1_1to20_vs_21to40'
% newConWeight{21} = [1 -1]
% newConName{22} = 'TP_NoPuff_Bl1_1to20_vs_21to40'
% newConWeight{22} = [0 0 0 0 0 0 1 -1]
% newConName{23} = 'Od_NoPuff_Bl3_81to100_vs_101to120'
% newConWeight{23} = [0 0 0 0 1 -1]
% newConName{24} = 'TP_NoPuff_Bl3_81to100_vs_101to120'
% newConWeight{24} = [0 0 0 0 0 0 0 0 0 0 1 -1]
% newConName{25} = 'Od_NoPuff_Bl1_1to20_vs_TP_NoPuff_Bl1_1to20_VS_Od_NoPuff_Bl1_21to40_vs_TP_NoPuff_Bl1_21to40'
% newConWeight{25} = [1 -1 0 0 0 0 -1 1]

%% v11 / v20
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
% newConName{9} = 'Puff_vs_HighMotion'
% newConWeight{9} = [0 1 -1 0 -1 0]
% newConName{10} = 'Puff_vs_LowMotion'
% newConWeight{10} = [0 1 0 -1 0 -1]
% newConName{11} = 'High_vs_LowMotion'
% newConWeight{11} = [0 0 1 -1 1 -1]


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
            matlabbatch{1}.spm.stats.con.spmmat = {[resultsDir filesep 'firstlevel' filesep subjAbrev filesep 'SPM.mat']};
            matlabbatch{1}.spm.stats.con.consess{conNumb+1}.fcon.name = 'FD';
            matlabbatch{1}.spm.stats.con.consess{conNumb+1}.fcon.weights = [zeros(1,24) ones(1,1)];
            matlabbatch{1}.spm.stats.con.consess{conNumb+1}.fcon.sessrep = 'none';
            if 1==1
                spm_jobman('run',matlabbatch);
            end
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
    contrast_info.names{new_contrast_numb+1} = matlabbatch{1}.spm.stats.con.consess{conNumb+1}.fcon.name;
    contrast_info.test{new_contrast_numb+1} = 'fcon';
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
    %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished_refined.nii';
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
end













