%% master_BASCO_seedbasedAnalysis_reappraisal_jr.m
% Information:
%


%% Preparation
clear all;
close all;

%% Set pathes for scripts
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% Seed analysis path
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/06-SeedAnalysis_BASCO/'));

%% Preselection
% cormat for v24 (duration 2.4s)
% suffix_unsmoothed = 'v10';
% cormat_selection_unsmoothed = ['cormat_' suffix_unsmoothed ];
% suffix_smoothed = 'v8';
% cormat_selection_smoothed = ['cormat_' suffix_smoothed ];
% cormat for v22 (duration 0s)
% suffix_unsmoothed = 'v14';
% cormat_selection_unsmoothed = ['cormat_' suffix_unsmoothed ];
% suffix_smoothed = 'v15';
% cormat_selection_smoothed = ['cormat_' suffix_smoothed ];
suffix_unsmoothed = 'v11';
cormat_selection_unsmoothed = ['cormat_' suffix_unsmoothed ];
suffix_smoothed = 'v9';
cormat_selection_smoothed = ['cormat_' suffix_smoothed ];

% general mask
% Pmsk_general = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
Pmsk_general = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished_refined.nii';

% select a high negative threshold NOT to exclude any data
threshold=-1000;

% Select seed region (e.g. masked activation from a 2nd-level GLM)
%% I:
% v24 (2.4s)
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v24_Bl3vsBl1_T01.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v24_Bl3vsBl1_T001.nii';
% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v24_RankOwn_Bl3vsBl1_T01.nii';
% P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v24_RankOwn_Bl3vsBl1_T001.nii';
% P_seeds{5} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl_2/mask_deactivation_v24_RankOwn_NoPuffBl2_T01.nii';
% P_seeds{6} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl_2/mask_deactivation_v24_RankOwn_NoPuffBl2_T001.nii';
% P_seeds{7} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_v24_OdorBl3vsBl1_T01.nii';
% P_seeds{8} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_v24_Bl3vsBl1_T01.nii';
% P_seeds{9} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_v24_OdorBl3vsBl1_T01.nii';

% v22 (0s)
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/beta4D/combined_hemisphere/I_dors.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/beta4D/combined_hemisphere/I_ventr.nii';
% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/dIns_l.nii';
% P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/dIns_r.nii';
% P_seeds{5} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/vIns_l.nii';
% P_seeds{6} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/vIns_r.nii';


% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/beta4D/combined_hemisphere/I_dors.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/beta4D/combined_hemisphere/I_ventr.nii';
% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/dIns_l.nii';
% P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/dIns_r.nii';
% P_seeds{5} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/vIns_l.nii';
% P_seeds{6} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/vIns_r.nii';

% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3/mask_activation_v22_Interaction_T001.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3/mask_activation_v22_Interaction_T01.nii';
% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3/mask_deactivation_v22_Interaction_T001.nii';
% P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Od_NoPuff_Bl1_11to40_vs_TP_NoPuff_Bl1_11to40_vs_Od_NoPuff_Bl3_vs_TP_NoPuff_Bl3/mask_deactivation_v22_Interaction_T01.nii';
  
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/beta4D/combined_hemisphere/I_dors.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v11/beta4D/combined_hemisphere/I_ventr.nii';
P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T01.nii';
P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T001.nii';

% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_v22_RankOwn_Bl3vsBl1_T01.nii';
% P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_v22_RankOwn_Bl3vsBl1_T001.nii';
% P_seeds{5} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl_2/mask_activation_v22_RankOwn_NoPuffBl2_T01.nii';
% P_seeds{6} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl_2/mask_activation_v22_RankOwn_NoPuffBl2_T001.nii';
% P_seeds{7} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_v22_OdorBl3vsBl1_T001.nii';
% P_seeds{8} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_v22_OdorBl3vsBl1_T01.nii';
% P_seeds{9} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_v22_OdorBl3vsBl1_T001.nii';
% P_seeds{10} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_v22_OdorBl3vsBl1_T01.nii';

%% Additionally scrubbed data
% Block 3 vs 1 at time point of no puff
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_TPbl3vsbl1_T001.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_TPbl3vsbl1_T01.nii';
% % Block 3 vs 1 at odor of no puff
% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_OdorBl3vsBl1_T001.nii';
% P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_OdorBl3vsBl1_T01.nii';
% P_seeds{5} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_OdorBl3vsBl1_T001.nii';
% P_seeds{6} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_OdorBl3vsBl1_T01.nii';
% % Social Rank
% P_seeds{7} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_rank_T001.nii';
% P_seeds{8} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_rank_T01.nii';
% % Chasing
% P_seeds{9} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_DavidsScoreChasing_zscored/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_chasing_T001.nii';
% P_seeds{10} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_DavidsScoreChasing_zscored/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_chasing_T01.nii';
% Social Rank (time point of no Puff, block 2)
% P_seeds{11} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl_2/mask_thalamusCP_noPuffbl2_corrRank_T01.nii';
% P_seeds{12} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl_2/mask_thalamusCP_noPuffbl2_corrRank_T001.nii';
% P_seeds{13} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl_2/mask_noPuffbl2_corrRank_T01.nii';
%%:
beta_selection_contains{1,1} = 'TPnoPuff81to120'; beta_selection_contains{1,2} = 'TPnoPuff11to40'; beta_selection_contains{1,3} = 'Odor81to120'; beta_selection_contains{1,4} = 'Odor11to40';

% beta_selection_contains{1} = 'SocialRank';
% beta_selection_contains{1} = 'TPnoPuff41to80';
%
% beta_selection_contains{9,1} = 'TPnoPuff41to80';
% beta_selection_contains{10,1} = 'TPnoPuff41to80';

%% Loop over seed regions
for ix=1:length(P_seeds)
    % clear
    clear beta_selection
    
    % Select beta-series suffix for comparison
    direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO' filesep cormat_selection_smoothed filesep 'beta4D'];
    [beta_list,~] = spm_select('FPListRec',direc,['^ZI_M11_betaseries_' suffix_smoothed '_.*.nii$']); % ZI_M11_ is just an exemplary animal to select the suffixes
    for jx=1:size(beta_list,1)
        find_idx = strfind(beta_list(jx,:),['betaseries_' suffix_smoothed '_']);
        start_idx = find_idx+length(['betaseries_' suffix_smoothed '_']);
        end_idx = strfind(beta_list(jx,:),'.nii')-1;
        beta_selection{jx} = beta_list(jx,start_idx:end_idx);
    end
    
    [~,seed_name,~]=fileparts(P_seeds{ix})
    
    beta_selection = beta_selection_contains;
%     if ~isempty(beta_selection_contains{ix,2})
%         beta_selection=beta_selection(contains(beta_selection,beta_selection_contains{1,1}) | contains(beta_selection,beta_selection_contains{1,2}) | contains(beta_selection,beta_selection_contains{1,3}) | contains(beta_selection,beta_selection_contains{1,4}));
%     elseif isempty(beta_selection_contains{ix,2})
%         beta_selection=beta_selection(contains(beta_selection,beta_selection_contains{1,1}));
%     end
    
    %% FIRSTLEVEL
    if 1==1
        %% Loop over beta selection
        for kx = 1:length(beta_selection)
            % Select beta-series
            direc_smoothed=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO' filesep cormat_selection_smoothed filesep 'beta4D'];
            P_betaseries_smoothed = spm_select('FPListRec',direc_smoothed,['^ZI_.*.' beta_selection{kx} '.*.nii$'])
            
            direc_unsmoothed=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO' filesep cormat_selection_unsmoothed filesep 'beta4D'];
            P_betaseries_unsmoothed = spm_select('FPListRec',direc_unsmoothed,['^ZI_.*.' beta_selection{kx} '.*.nii$'])
            
            P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'firstlevel' filesep beta_selection{kx} filesep ];
            if exist(P_outputdir_cur)~=7
                mkdir(P_outputdir_cur)
            end
            do_seedanalysis_firstlevel_jr(P_seeds{ix}, P_betaseries_unsmoothed, P_betaseries_smoothed, P_outputdir_cur, threshold, Pmsk_general)
        end
    end
    
    %% SECONDLEVEL
    if 1==1
        if length(beta_selection)>1
            %% Loop over beta selection
            for kx = 1:length(beta_selection)
                % Select beta-series suffix for comparison
                direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
                % Select beta-series Gr1
                P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' '_' beta_selection{kx} '.nii$']);
                %
                if kx<length(beta_selection)
                    for hx=kx+1:length(beta_selection)
                        % Select beta-series suffix for comparison
                        direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
                        % Select beta-series Gr2 (for comparison)
                        P_betaseries_gr2 = spm_select('FPListRec',direc,['^fCC_ZI.*.' '_' beta_selection{hx} '.nii$']);
                        
                        P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'secondlevel' filesep beta_selection{kx} '_VS_' beta_selection{hx}];
                        
                        % define contrasts
                        contrast.name{1} = [beta_selection{kx} ' > ' beta_selection{hx}];
                        contrast.val{1} = [1 -1];
                        contrast.name{2} = [beta_selection{kx} ' < ' beta_selection{hx}];
                        contrast.val{2} = [-1 1];
                        
                        % run 2nd level analysis
                        do_seedanalysis_secondlevel_jr(P_betaseries_gr1, P_betaseries_gr2, P_outputdir_cur, Pmsk_general, contrast)
                    end
                end
                
                % calculation of interaction effect
                if kx==1
                    % beta series selection
                    P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' '_' beta_selection{1} '.nii$']); % TP 11-40
                    P_betaseries_gr2 = spm_select('FPListRec',direc,['^fCC_ZI.*.' '_' beta_selection{2} '.nii$']); % TP 81-120
                    P_betaseries_gr3 = spm_select('FPListRec',direc,['^fCC_ZI.*.' '_' beta_selection{3} '.nii$']); % Odor 11-40
                    P_betaseries_gr4 = spm_select('FPListRec',direc,['^fCC_ZI.*.' '_' beta_selection{4} '.nii$']); % Odor 81-120
                    
                    
                    
                    for subj=1:size(P_betaseries_gr1,1)
                        
                        %% Difference between Odor bl1 and TP bl1
                        clear V1 img1 V3 img3
                        V1=spm_vol(deblank(P_betaseries_gr1(subj,:)));
                        img1=spm_read_vols(V1);
                        V3=spm_vol(deblank(P_betaseries_gr3(subj,:)));
                        img3=spm_read_vols(V3);
                        
                        V_diffBl1=V3;
                        [~,fname,~]=fileparts(P_betaseries_gr1(subj,:));
                        find_=strfind(fname,beta_selection{1});
                        
                        new_outdir=fullfile(direc,'firstlevel',[beta_selection{1} 'VS' beta_selection{3}],'fCC');
                        if exist(new_outdir)~=7
                            mkdir(new_outdir)
                        end
                        V_diffBl1.fname=fullfile(new_outdir,[fname(1:(find_-1)) beta_selection{1} 'VS' beta_selection{3} '.nii']);
                        spm_write_vol(V_diffBl1,img1-img3);
                        
                        %% Difference between Odor bl3 and TP bl3
                        clear V2 img2 V4 img4
                        V2=spm_vol(deblank(P_betaseries_gr2(subj,:)));
                        img2=spm_read_vols(V2);
                        V4=spm_vol(deblank(P_betaseries_gr4(subj,:)));
                        img4=spm_read_vols(V4);
                        
                        V_diffBl3=V4;
                        [~,fname,~]=fileparts(P_betaseries_gr2(subj,:));
                        find_=strfind(fname,beta_selection{2});
                        
                        new_outdir=fullfile(direc,'firstlevel',[beta_selection{2} 'VS' beta_selection{4}],'fCC');
                        if exist(new_outdir)~=7
                            mkdir(new_outdir)
                        end
                        V_diffBl3.fname=fullfile(new_outdir,[fname(1:(find_-1)) beta_selection{2} 'VS' beta_selection{4} '.nii']);
                        spm_write_vol(V_diffBl3,img2-img4);
                        
                        %% Difference between TP bl3 and TP bl1
                        clear V2 img2 V4 img4 V1 img1 V3 img3
                        V1=spm_vol(deblank(P_betaseries_gr1(subj,:)));
                        img1=spm_read_vols(V1);
                        V2=spm_vol(deblank(P_betaseries_gr2(subj,:)));
                        img2=spm_read_vols(V2);
                        
                        V_diffTP=V2;
                        [~,fname,~]=fileparts(P_betaseries_gr2(subj,:));
                        find_=strfind(fname,beta_selection{2});
                        
                        new_outdir=fullfile(direc,'firstlevel',[beta_selection{1} 'VS' beta_selection{2}],'fCC');
                        if exist(new_outdir)~=7
                            mkdir(new_outdir)
                        end
                        V_diffTP.fname=fullfile(new_outdir,[fname(1:(find_-1)) beta_selection{1} 'VS' beta_selection{2} '.nii']);
                        spm_write_vol(V_diffTP,img1-img2);
                        
                        %% Difference between Odor bl3 and Odor bl1
                        clear V2 img2 V4 img4 V1 img1 V3 img3
                        V3=spm_vol(deblank(P_betaseries_gr3(subj,:)));
                        img3=spm_read_vols(V3);
                        V4=spm_vol(deblank(P_betaseries_gr4(subj,:)));
                        img4=spm_read_vols(V4);
                        
                        V_diffOdor=V4;
                        [~,fname,~]=fileparts(P_betaseries_gr4(subj,:));
                        find_=strfind(fname,beta_selection{4});
                        
                        new_outdir=fullfile(direc,'firstlevel',[beta_selection{3} 'VS' beta_selection{4}],'fCC');
                        if exist(new_outdir)~=7
                            mkdir(new_outdir)
                        end
                        V_diffOdorV_diffOdor.fname=fullfile(new_outdir,[fname(1:(find_-1)) beta_selection{3} 'VS' beta_selection{4} '.nii']);
                        spm_write_vol(V_diffOdor,img3-img4);
                    end
                    
                    P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'secondlevel' filesep beta_selection{1} 'VS' beta_selection{3} '_VS_' beta_selection{2} 'VS' beta_selection{4}];
                    
                    % beta series selection
                    P_betaseries_diff1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{1} 'VS' beta_selection{3} '.*.nii$']); % Odor 11-40
                    P_betaseries_diff2 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{2} 'VS' beta_selection{4} '.*.nii$']); % Odor 11-40
                    
                    % define contrasts
                    contrast.name{1} = [beta_selection{1} 'VS' beta_selection{3} ' > ' beta_selection{2} 'VS' beta_selection{4}];
                    contrast.val{1} = [1 -1];
                    contrast.name{2} = [beta_selection{1} 'VS' beta_selection{3} ' < ' beta_selection{2} 'VS' beta_selection{4}];
                    contrast.val{2} = [-1 1];
                    
                    % run 2nd level analysis
                    if 1==1
                        do_seedanalysis_secondlevel_jr(P_betaseries_diff1, P_betaseries_diff2, P_outputdir_cur, Pmsk_general, contrast)
                    end
                end
                
            end
            
            %% 
        elseif length(beta_selection)==1 && ~strcmp(beta_selection,'SocialRank')
            direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
            % Select beta-series Gr1
            P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{kx} '.*.nii$']);
            
            P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'secondlevel' filesep beta_selection{1}];
            if exist(P_outputdir_cur)~=7
                mkdir(P_outputdir_cur)
            end
            
            % define contrasts
            contrast.name{1} = [beta_selection{1} '_pos'];
            contrast.val{1} = [1];
            contrast.name{2} = [beta_selection{1} '_neg'];
            contrast.val{2} = [-1];
            contrast.name{3} = ['cov_pos'];
            contrast.val{3} = [0 1];
            contrast.name{4} = ['cov_neg'];
            contrast.val{4} = [0 -1];
            
            [seed_dir,~,~] = fileparts(P_seeds{ix-1});
            load(fullfile(seed_dir,'SPM.mat'))
            myCovariate.name = SPM.xC.rcname;
            myCovariate.val = SPM.xC.rc;
            
            % run 2nd level analysis
            do_seedanalysis_secondlevel_onewayTtestwithCov_jr(P_betaseries_gr1, P_outputdir_cur, Pmsk_general, contrast, myCovariate)
            
            %% Social Rank
        elseif strcmp(beta_selection,'SocialRank')
            direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
            % Select beta-series Gr1
            P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.TPnoPuff81to120VSTPnoPuff11to40.*.nii$']);
            
            P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'secondlevel' filesep 'TPnoPuff81to120VSTPnoPuff11to40_' beta_selection{1}];
            if exist(P_outputdir_cur)~=7
                mkdir(P_outputdir_cur)
            end
            
            % define contrasts
            contrast.name{1} = ['TPnoPuff81to120VSTPnoPuff11to40_pos'];
            contrast.val{1} = [1];
            contrast.name{2} = ['TPnoPuff81to120VSTPnoPuff11to40_pos'];
            contrast.val{2} = [-1];
            contrast.name{3} = ['SocialRank_pos'];
            contrast.val{3} = [0 1];
            contrast.name{4} = ['SocialRank_neg'];
            contrast.val{4} = [0 -1];
            
            load(fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/','SPM.mat'));
            myCovariate.name = SPM.xC.rcname;
            myCovariate.val = SPM.xC.rc;
            
            % run 2nd level analysis
            do_seedanalysis_secondlevel_onewayTtestwithCov_jr(P_betaseries_gr1, P_outputdir_cur, Pmsk_general, contrast, myCovariate)
        end
    end
end













