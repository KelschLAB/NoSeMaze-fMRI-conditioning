%% add_contrast_social_2sessionscombined_jr.m
%% Add additional contrasts

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

% % % define paths and regressors/covariates ...
% % % metainfo are saved in respective pathes
% % regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
% % regressorsSuffix = '_v2.mat';
% % covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% % % if covarSuffix is _v0.mat, no covariates are used
% % covarSuffix = '_v1.mat';
% % 
% % % selection of EPI
% % epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_';
% % epiSuffix = '_c1_c2t_wds';

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/05-GLM/03-results/');

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
%% for ROI_v1_v1 and ROI_v4_v4
newConName{1} = 'CD1fam'
newConWeight{1} = [1]
newConName{2} = 'CD1unk'
newConWeight{2} = [0 1]
newConName{3} = '129sv'
newConWeight{3} = [0 0 1]
newConName{4} = 'CD1fam vs CD1unk'
newConWeight{4} = [1 -1 0]
newConName{5} = 'CD1fam vs 129sv'
newConWeight{5} = [1 0 -1]
newConName{6} = 'CD1unk vs 129sv'
newConWeight{6} = [0 1 -1]
newConName{7} = 'C57BL_low'
newConWeight{7} = [0 0 0 zeros(1,14) 1 0]
newConName{8} = 'C57BL_high'
newConWeight{8} = [0 0 0 zeros(1,14) 0 1]
newConName{9} = 'C57BL_low vs C57BL_high'
newConWeight{9} = [0 0 0 zeros(1,14) 1 -1]
newConName{10} = 'CD1fam vs C57BL_low'
newConWeight{10} = [1 0 0 zeros(1,14) -1 0]
newConName{11} = 'CD1unk vs C57BL_low'
newConWeight{11} = [0 1 0 zeros(1,14) -1 0]
newConName{12} = '129sv vs C57BL_low'
newConWeight{12} = [0 0 1 zeros(1,14) -1 0]
newConName{13} = 'CD1fam vs C57BL_high'
newConWeight{13} = [1 0 0 zeros(1,14) 0 -1]
newConName{14} = 'CD1unk vs C57BL_high'
newConWeight{14} = [0 1 0 zeros(1,14) 0 -1]
newConName{15} = '129sv vs C57BL_high'
newConWeight{15} = [0 0 1 zeros(1,14) 0 -1]
newConName{16} = 'CD1fam vs C57BL_BOTH'
newConWeight{16} = [1 0 0 zeros(1,14) -.5 -.5]
newConName{17} = 'CD1unk vs C57BL_BOTH'
newConWeight{17} = [0 1 0 zeros(1,14) -.5 -.5]
newConName{18} = '129sv vs C57BL_BOTH'
newConWeight{18} = [0 0 1 zeros(1,14) -.5 -.5]
newConName{19} = 'Sess1_allOdors vs Sess2_allOdors'
newConWeight{19} = [1 1 1 zeros(1,14) -1 -1]
newConName{20} = 'Sess1_Res vs Sess2_Res'
newConWeight{20} = [0 0 0 zeros(1,14) 0 0 zeros(1,14) 1 -1]

% %% for ROI_v6_v3
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
% newConName{10} = 'Low_Bl1'
% newConWeight{10} = [0 0 0 0 0 0 0 0 0 zeros(1,14) 1 0 0]
% newConName{11} = 'Low_Bl2'
% newConWeight{11} = [0 0 0 0 0 0 0 0 0 zeros(1,14) 0 1 0]
% newConName{12} = 'Low_Bl3'
% newConWeight{12} = [0 0 0 0 0 0 0 0 0 zeros(1,14) 0 0 1]
% newConName{13} = 'High_Bl1'
% newConWeight{13} = [0 0 0 0 0 0 0 0 0 zeros(1,14) 0 0 0 1 0 0]
% newConName{14} = 'High_Bl2'
% newConWeight{14} = [0 0 0 0 0 0 0 0 0 zeros(1,14) 0 0 0 0 1 0]
% newConName{15} = 'High_Bl3'
% newConWeight{15} = [0 0 0 0 0 0 0 0 0 zeros(1,14) 0 0 0 0 0 1]
% % Bl1
% newConName{16} = 'CD1fam_Bl1_VS_Low_Bl1'
% newConWeight{16} = [1 0 0 0 0 0 0 0 0 zeros(1,14) -1]
% newConName{17} = 'CD1unk_Bl1_VS_Low_Bl1'
% newConWeight{17} = [0 0 0 1 0 0 0 0 0 zeros(1,14) -1]
% newConName{18} = '129sv_Bl1_VS_Low_Bl1'
% newConWeight{18} = [0 0 0 0 0 0 1 0 0 zeros(1,14) -1]
% newConName{19} = 'CD1fam_Bl1_VS_High_Bl1'
% newConWeight{19} = [1 0 0 0 0 0 0 0 0 zeros(1,14) 0 0 0 -1]
% newConName{20} = 'CD1unk_Bl1_VS_High_Bl1'
% newConWeight{20} = [0 0 0 1 0 0 0 0 0 zeros(1,14) 0 0 0 -1]
% newConName{21} = '129sv_Bl1_VS_High_Bl1'
% newConWeight{21} = [0 0 0 0 0 0 1 0 0 zeros(1,14) 0 0 0 -1]
% % Bl2
% newConName{22} = 'CD1fam_Bl2_VS_Low_Bl2'
% newConWeight{22} = [0 1 0 0 0 0 0 0 0 zeros(1,14) 0 -1]
% newConName{23} = 'CD1unk_Bl2_VS_Low_Bl2'
% newConWeight{23} = [0 0 0 0 1 0 0 0 0 zeros(1,14) 0 -1]
% newConName{24} = '129sv_Bl2_VS_Low_Bl2'
% newConWeight{24} = [0 0 0 0 0 0 0 1 0 zeros(1,14) 0 -1]
% newConName{25} = 'CD1fam_Bl2_VS_High_Bl2'
% newConWeight{25} = [0 1 0 0 0 0 0 0 0 zeros(1,14) 0 0 0 0 -1]
% newConName{26} = 'CD1unk_Bl2_VS_High_Bl2'
% newConWeight{26} = [0 0 0 0 1 0 0 0 0 zeros(1,14) 0 0 0 0 -1]
% newConName{27} = '129sv_Bl2_VS_High_Bl2'
% newConWeight{27} = [0 0 0 0 0 0 0 1 0 zeros(1,14) 0 0 0 0 -1]
% % Bl3
% newConName{28} = 'CD1fam_Bl3_VS_Low_Bl3'
% newConWeight{28} = [0 0 1 0 0 0 0 0 0 zeros(1,14) 0 0 -1]
% newConName{29} = 'CD1unk_Bl3_VS_Low_Bl3'
% newConWeight{29} = [0 0 0 0 0 1 0 0 0 zeros(1,14) 0 0 -1]
% newConName{30} = '129sv_Bl3_VS_Low_Bl3'
% newConWeight{30} = [0 0 0 0 0 0 0 0 1 zeros(1,14) 0 0 -1]
% newConName{31} = 'CD1fam_Bl3_VS_High_Bl3'
% newConWeight{31} = [0 0 0 0 0 0 0 0 1 zeros(1,14) 0 0 0 0 0 -1]
% newConName{32} = 'CD1unk_Bl3_VS_High_Bl3'
% newConWeight{32} = [0 0 0 0 0 0 0 0 1 zeros(1,14) 0 0 0 0 0 -1]
% newConName{33} = '129sv_Bl3_VS_High_Bl3'
% newConWeight{33} = [0 0 0 0 0 0 0 0 1 zeros(1,14) 0 0 0 0 0 -1]
% % Bl2Bl3
% newConName{34} = 'CD1fam_Bl2Bl3_VS_Low_Bl2Bl3'
% newConWeight{34} = [0 .5 .5 0 0 0 0 0 0 zeros(1,14) 0 -.5 -.5]
% newConName{35} = 'CD1unk_Bl2Bl3_VS_Low_Bl2Bl3'
% newConWeight{35} = [0 0 0 0 .5 .5 0 0 0 zeros(1,14) 0 -.5 -.5]
% newConName{36} = '129sv_Bl2Bl3_VS_Low_Bl2Bl3'
% newConWeight{36} = [0 0 0 0 0 0 0 .5 .5 zeros(1,14) 0 -.5 -.5]
% newConName{37} = 'CD1fam_Bl2Bl3_VS_High_Bl2Bl3'
% newConWeight{37} = [0 .5 .5 0 0 0 0 0 0 zeros(1,14) 0 0 0 0 -.5 -.5]
% newConName{38} = 'CD1unk_Bl2Bl3_VS_High_Bl2Bl3'
% newConWeight{38} = [0 0 0 0 .5 .5 0 0 0 zeros(1,14) 0 0 0 0 -.5 -.5]
% newConName{39} = '129sv_Bl2Bl3_VS_High_Bl2Bl3'
% newConWeight{39} = [0 0 0 0 0 0 0 .5 .5 zeros(1,14) 0 0 0 0 -.5 -.5]

% %% for ROI_v2_v2
% newConName{1} = 'CD1fam_On'
% newConWeight{1} = [1 0]
% newConName{2} = 'CD1fam_Off'
% newConWeight{2} = [0 1]
% newConName{3} = 'CD1unk_On'
% newConWeight{3} = [0 0 1]
% newConName{4} = 'CD1unk_Off'
% newConWeight{4} = [0 0 0 1]
% newConName{5} = '129sv_On'
% newConWeight{5} = [0 0 0 0 1]
% newConName{6} = '129sv_Off'
% newConWeight{6} = [0 0 0 0 0 1]
% newConName{7} = 'CD1unk_On'
% newConWeight{7} = [0 0 1]
% newConName{8} = 'CD1unk_Off'
% newConWeight{8} = [0 0 0 1]
% newConName{9} = '129sv_On'
% newConWeight{9} = [0 0 0 0 1]
% newConName{10} = '129sv_Off'
% newConWeight{10} = [0 0 0 0 0 1]
% newConName{11} = 'Low_On'
% newConWeight{11} = [0 0 0 0 0 0 zeros(1,14) 1 0 0 0]
% newConName{12} = 'Low_Off'
% newConWeight{12} = [0 0 0 0 0 0 zeros(1,14) 0 1 0 0]
% newConName{13} = 'High_On'
% newConWeight{13} = [0 0 0 0 0 0 zeros(1,14) 0 0 1 0]
% newConName{14} = 'High_Off'
% newConWeight{14} = [0 0 0 0 0 0 zeros(1,14) 0 0 0 1]
% % CD1fam On / off
% newConName{15} = 'CD1fam_On VS Low_On'
% newConWeight{15} = [1 0 0 0 0 0 zeros(1,14) -1 0 0 0]
% newConName{16} = 'CD1fam_On VS High_On'
% newConWeight{16} = [1 0 0 0 0 0 zeros(1,14) 0 0 -1 0]
% newConName{17} = 'CD1fam_On VS Low_OnANDHigh_On'
% newConWeight{17} = [1 0 0 0 0 0 zeros(1,14) -.5 0 -.5 0]
% newConName{18} = 'CD1fam_Off VS Low_Off'
% newConWeight{18} = [0 1 0 0 0 0 zeros(1,14) 0 -1 0 0]
% newConName{19} = 'CD1fam_Off VS High_Off'
% newConWeight{19} = [0 1 0 0 0 0 zeros(1,14) 0 0 0 -1]
% newConName{20} = 'CD1fam_Off VS Low_OffANDHigh_Off'
% newConWeight{20} = [0 1 0 0 0 0 zeros(1,14) 0 -.5 0 -.5]
% % CD1unk On / off
% newConName{21} = 'CD1unk_On VS Low_On'
% newConWeight{21} = [0 0 1 0 0 0 zeros(1,14) -1 0 0 0]
% newConName{22} = 'CD1unk_On VS High_On'
% newConWeight{22} = [0 0 1 0 0 0 zeros(1,14) 0 0 -1 0]
% newConName{23} = 'CD1unk_On VS Low_OnANDHigh_On'
% newConWeight{23} = [0 0 1 0 0 0 zeros(1,14) -.5 0 -.5 0]
% newConName{24} = 'CD1unk_Off VS Low_Off'
% newConWeight{24} = [0 0 0 1 0 0 zeros(1,14) 0 -1 0 0]
% newConName{25} = 'CD1unk_Off VS High_Off'
% newConWeight{25} = [0 0 0 1 0 0 zeros(1,14) 0 0 0 -1]
% newConName{26} = 'CD1unk_Off VS Low_OffANDHigh_Off'
% newConWeight{26} = [0 0 0 1 0 0 zeros(1,14) 0 -.5 0 -.5]
% % 129sv On / off
% newConName{27} = '129sv_On VS Low_On'
% newConWeight{27} = [0 0 0 0 1 0 zeros(1,14) -1 0 0 0]
% newConName{28} = '129sv_On VS High_On'
% newConWeight{28} = [0 0 0 0 1 0 zeros(1,14) 0 0 -1 0]
% newConName{29} = '129sv_On VS Low_OnANDHigh_On'
% newConWeight{29} = [0 0 0 0 1 0 zeros(1,14) -.5 0 -.5 0]
% newConName{30} = '129sv_Off VS Low_Off'
% newConWeight{30} = [0 0 0 0 0 1 zeros(1,14) 0 -1 0 0]
% newConName{31} = '129sv_Off VS High_Off'
% newConWeight{31} = [0 0 0 0 0 1 zeros(1,14) 0 0 0 -1]
% newConName{32} = '129sv_Off VS Low_OffANDHigh_Off'
% newConWeight{32} = [0 0 0 0 0 1 zeros(1,14) 0 -.5 0 -.5]
% 
% % CD1fam On + off
% newConName{33} = 'CD1fam_OnOff VS Low_OnOff'
% newConWeight{33} = [1 1 0 0 0 0 zeros(1,14) -1 -1 0 0]
% newConName{34} = 'CD1fam_OnOff VS High_OnOff'
% newConWeight{34} = [1 1 0 0 0 0 zeros(1,14) 0 0 -1 -1]
% newConName{35} = 'CD1fam_OnOff VS Low_OnOffANDHigh_OnOff'
% newConWeight{35} = [1 1 0 0 0 0 zeros(1,14) -.5 -.5 -.5 -.5]
% 
% % CD1fam On + off
% newConName{36} = 'CD1unk_OnOff VS Low_OnOff'
% newConWeight{36} = [0 0 1 1 0 0 zeros(1,14) -1 -1 0 0]
% newConName{37} = 'CD1unk_OnOff VS High_OnOff'
% newConWeight{37} = [0 0 1 1 0 0 zeros(1,14) 0 0 -1 -1]
% newConName{38} = 'CD1unk_OnOff VS Low_OnOffANDHigh_OnOff'
% newConWeight{38} = [0 0 1 1 0 0 zeros(1,14) -.5 -.5 -.5 -.5]
% 
% % 129sv On + off
% newConName{39} = '129_OnOff VS Low_OnOff'
% newConWeight{39} = [0 0 0 0 1 1 zeros(1,14) -1 -1 0 0]
% newConName{40} = '129_OnOff VS High_OnOff'
% newConWeight{40} = [0 0 0 0 1 1 zeros(1,14) 0 0 -1 -1]
% newConName{41} = '129_OnOff VS Low_OnOffANDHigh_OnOff'
% newConWeight{41} = [0 0 0 0 1 1 zeros(1,14) -.5 -.5 -.5 -.5]












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
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [resultsDir filesep 'firstlevel'];
    
    do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
%     add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,length(newConWeight))
end













