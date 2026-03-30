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

% cormat
suffix = 'v6';
cormat_selection = ['cormat_' suffix ];
metainfo_file = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/input' filesep 'metainfo_' suffix '.mat'];
load(metainfo_file);

% general mask
Pmsk_general = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';

% select a high negative threshold NOT to exclude any data
threshold=-1000;

% Select seed region (e.g. masked activation from a 2nd-level GLM)
%% I:
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___05-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation.nii';
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins.nii';

% P_seeds{1} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3/mask_activation_PFC_T3_v24.nii';
% P_seeds{2} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3/mask_deactivation_CORT_T3_v24.nii';
% P_seeds{3} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3_v24.nii';
% P_seeds{4} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3485_v24.nii';
% P_seeds{5} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl2 vs TP_Puff_Bl2/mask_activation_Amyg_T3485_v24.nii';
% P_seeds{6} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl2 vs TP_Puff_Bl2/mask_deactivation_VTARN_T5_v24.nii';
P_seeds{1} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3/mask_activation_PFC_T3_v22.nii';
P_seeds{2} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3/mask_activation_PFC_T3485_v22.nii';
P_seeds{3} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3/mask_deactivation_CORT_T3_v22.nii';
P_seeds{4} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_NoPuff_Bl1_11to40 vs Od_NoPuff_Bl3/mask_deactivation_CORT_T3485_v22.nii';
P_seeds{5} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3_v2.nii';
P_seeds{6} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3485_v22.nii';
P_seeds{7} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_activation_Amyg_T3_v22.nii';
P_seeds{8} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_activation_Amyg_T3485_V22.nii';
P_seeds{9} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_deactivation_RNVTA_FWE_v22.nii';
P_seeds{10} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_deactivation_S1_FWE_v22.nii';

%% II:
% P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___05-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_activation_AMYG.nii';
% P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___05-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_activation_CORTEX.nii';
% P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___05-Jan-2022/secondlevel/Od_Puff_Bl2 vs TP_Puff_Bl2/mask_activation_RN.nii';

% select specific timepoint
% betaseries names are:
%     {'Lavender'}    {'Odor11to40'}    {'Odor1to10'}    {'Odor1to40'}    {'Odor41to80'}
%     {'Odor81to120'}    {'Odor_TPNoPuff'}    {'Odor_TPPuff'}    {'TP-NoPuff'}    {'TP-Puff'}
%     {'TPnoPuff11to40'}    {'TPnoPuff1to10'}    {'TPnoPuff1to40'}    {'TPnoPuff41to80'}
%     {'TPnoPuff81to120'}
%% I:
% beta_selection_contains{1,1} = 'TPnoPuff81to120'; beta_selection_contains{1,2} = 'TPnoPuff11to40';
%% II:
beta_selection_contains{1,1} = 'Odor11to40'; beta_selection_contains{1,2} = 'Odor81to120';
beta_selection_contains{2,1} = 'Odor11to40'; beta_selection_contains{2,2} = 'Odor81to120';
beta_selection_contains{3,1} = 'Odor11to40'; beta_selection_contains{3,2} = 'Odor81to120';
beta_selection_contains{4,1} = 'Odor11to40'; beta_selection_contains{4,2} = 'Odor81to120';
beta_selection_contains{5,1} = 'TPnoPuff81to120'; beta_selection_contains{5,2} = 'TPnoPuff11to40';
beta_selection_contains{6,1} = 'TPnoPuff81to120'; beta_selection_contains{6,2} = 'TPnoPuff11to40';
beta_selection_contains{7,1} = 'TPnoPuff41to80'; beta_selection_contains{7,2} = 'TP-Puff';
beta_selection_contains{8,1} = 'TPnoPuff41to80'; beta_selection_contains{8,2} = 'TP-Puff';
beta_selection_contains{9,1} = 'TPnoPuff41to80'; beta_selection_contains{9,2} = 'TP-Puff';
beta_selection_contains{10,1} = 'TPnoPuff41to80'; beta_selection_contains{10,2} = 'TP-Puff';



%% Loop over seed regions
for ix=1:length(P_seeds)
    
    clear beta_selection
   
    % Select beta-series suffix for comparison
    direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO' filesep cormat_selection filesep 'beta4D'];
    [beta_list,~] = spm_select('FPListRec',direc,['^ZI_M11_betaseries_' suffix '_.*.nii$']); % ZI_M11_ is just an exemplary animal to select the suffixes
    for jx=1:size(beta_list,1)
        find_idx = strfind(beta_list(jx,:),['betaseries_' suffix '_']);
        start_idx = find_idx+length(['betaseries_' suffix '_']);
        end_idx = strfind(beta_list(jx,:),'.nii')-1;
        beta_selection{jx} = beta_list(jx,start_idx:end_idx);
    end
    
        [~,seed_name,~]=fileparts(P_seeds{ix})

    
    beta_selection=beta_selection(contains(beta_selection,beta_selection_contains{ix,1}) | contains(beta_selection,beta_selection_contains{ix,2}));

    
    %% FIRSTLEVEL
    if 1==1
        %% Loop over beta selection
        for kx = 1:length(beta_selection)
            % Select beta-series
            direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO' filesep cormat_selection filesep 'beta4D'];
            P_betaseries = spm_select('FPListRec',direc,['^ZI_.*.' beta_selection{kx} '.*.nii$'])
            
            P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep cormat_selection filesep seed_name filesep 'firstlevel' filesep beta_selection{kx}];
            if exist(P_outputdir_cur)~=7
                mkdir(P_outputdir_cur)
            end
            do_seedanalysis_firstlevel_jr(P_seeds{ix}, P_betaseries, P_betaseries, P_outputdir_cur, threshold, Pmsk_general)
        end
    end
    
    %% SECONDLEVEL
    if 1==1
        %% Loop over beta selection
        for kx = 1:length(beta_selection)
            % Select beta-series suffix for comparison
            direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep cormat_selection filesep seed_name filesep];
            % Select beta-series Gr1
            P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{kx} '.*.nii$']);
            % 
            if kx<length(beta_selection)
                for hx=kx+1:length(beta_selection)
                    % Select beta-series suffix for comparison
                    direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep cormat_selection filesep seed_name filesep];
                    % Select beta-series Gr2 (for comparison)
                    P_betaseries_gr2 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{hx} '.*.nii$']);
                    
                    P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis' filesep cormat_selection filesep seed_name filesep 'secondlevel' filesep beta_selection{kx} '_VS_' beta_selection{hx}];
                    if exist(P_outputdir_cur)~=7
                        mkdir(P_outputdir_cur)
                    end
                    
                    % define contrasts
                    contrast.name{1} = [beta_selection{kx} ' > ' beta_selection{hx}];
                    contrast.val{1} = [1 -1];
                    contrast.name{2} = [beta_selection{kx} ' < ' beta_selection{hx}];
                    contrast.val{2} = [-1 1];
                    
                    % run 2nd level analysis
                    do_seedanalysis_secondlevel_jr(P_betaseries_gr1, P_betaseries_gr2, P_outputdir_cur, Pmsk_general, contrast)
                end
            end
        end
    end
end













