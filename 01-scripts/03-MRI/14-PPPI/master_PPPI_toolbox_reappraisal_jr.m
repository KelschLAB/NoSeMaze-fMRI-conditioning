%% master_PPPI_toolbox_reappraisal_jr.m
% Reinwald, Jonathan, 20.06.2023

% master script for running PPPI analyses
% citation
% subscripts
% ...


%% Preparation
clear all;
close all;

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
HRF_name = ['HRF' HRF_TCbased '_' HRF_infopath];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% selection of EPI
epiPrefix = 'DVARSscrub_0_1_lin_wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_'; % No smoothing before cormat creation
epiSuffix = '_c1_c2t_wds';

%% Set pathes for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/PPPIv13.1'));

% GLM dir
GLM_dir = spm_select(1,'dir','Select GLM Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results');
filelist = spm_select('FPList',[GLM_dir filesep 'firstlevel'],'dir',['^ZI_M.*.']);

% selection of VOI
% myVOIs=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T001.nii'];
% myVOIs='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_T01.nii';
% Block 3 vs 1 at time point of no puff
% myVOIs = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_TPbl3vsbl1_T001.nii';
% myVOIs = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_TPbl3vsbl1_T01.nii';
% Social Rank
% myVOIs = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_rank_T001.nii';
myVOIs = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_rank_T01.nii';

%% Loop over animal folders
for animal_idx = 1:size(filelist,1)
    
    % Set up the control param structure P which determines the run
    [fdir,fname,ext]=fileparts(filelist(animal_idx,:));
    P.subject=fname;
    P.directory=[GLM_dir filesep 'firstlevel' filesep P.subject];
    P.VOI=myVOIs;
    [VOIdir,VOIname,VOIext]=fileparts(P.VOI);
    P.Region=VOIname;
    P.analysis='psy';
    P.method='cond';
    P.Estimate=1;
    P.contrast=0;
    P.extract='eig';
    % P.Tasks={'0' 'Lavender_Bl1_1to10' 'Lavender_Bl1_11to40' 'Lavender_Bl2' 'Od_Puff_Bl2' 'Lavender_Bl3' 'TP_Puff_Bl_1_1to10' 'TP_Puff_Bl_1_11to40' 'TP_Puff_Bl_2' 'TP_Puff_Bl_2' 'TP_Puff_Bl_3'};
    P.Tasks={'0' 'Lavender_Bl1_1to10' 'Lavender_Bl1_11to40' 'Lavender_Bl2_NoPuff' 'Lavender_Bl2_Puff' 'Lavender_Bl3' 'TP_Puff_Bl1_1to10' 'TP_Puff_Bl1_11to40' 'TP_Puff_Bl2_NoPuff' 'TP_Puff_Bl2_Puff' 'TP_Puff_Bl3'};
    P.Weights=[];
    P.equalroi=1;
    P.FLmask=0;
    P.CompContrasts=1;
    
    % % I don't *think* we need these but I may be wrong - Niles.
    % % P.maskdir='';
    % % P.Contrasts(1).name='La';
    % % P.Contrasts(1).left={'Lavender_Bl1_1to10' 'Lavender_Bl1_11to40' 'Lavender_Bl2_NoPuff' 'Lavender_Bl2_Puff' 'Lavender_Bl3' 'TP_Puff_Bl1_1to10' 'TP_Puff_Bl1_11to40' 'TP_Puff_Bl2_NoPuff' 'TP_Puff_Bl2_Puff' 'TP_Puff_Bl3'};
    % % P.Contrasts(1).right={'none'};
    % % P.Contrasts(1).MinEvents=9;
    % % P.Contrasts(1).STAT='T';
    %
    P.Contrasts(1).name='TPnoPuff_Bl1_VS_Bl3'
    P.Contrasts(1).left={'TP_Puff_Bl1_11to40'};
    P.Contrasts(1).right={'TP_Puff_Bl3'};
    P.Contrasts(1).MinEvents=9;
    P.Contrasts(1).STAT='T';

    PPPI(P, ['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/running_gPPI_generic/running_gPPI_generic' filesep 'sampleData' filesep 'stats' filesep 'gPPI_sampleDataTest.mat']);
end

