%% master_RS_seedbasedAnalysis_jr.m
% Information:
%


%% Preparation
clear all;
close all;

%% Set pathes for scripts
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));

%% Preselection

% EPI
epiPrefix = 'bpm_0.01_0.1_wave_10cons_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
epiSuffix = '_c1_c2t_wds';

% input directory for EPIs
inputDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing';

% EPI input: Pfunc_unsmoothed and Pfunc_smoothed
Pfunc_unsmoothed = spm_select('ExtFPlistrec',inputDir,['^' epiPrefix '.*.' epiSuffix '.nii'],1);
% Additional smoothing (broader kernel)
if 1==0
    for ix=1:size(Pfunc_unsmoothed,1)
        Pcur=deblank(Pfunc_unsmoothed(ix,:));
        fwhm_cur=[8 8 12];
        do_smooth_jr(Pcur,fwhm_cur);
    end
end
% Pfunc_smoothed = spm_select('ExtFPlistrec',inputDir,['^s8812_' epiPrefix '.*.' epiSuffix '.nii'],1);
Pfunc_smoothed = spm_select('ExtFPlistrec',inputDir,['^' epiPrefix '.*.' epiSuffix '.nii'],1);

% general mask
Pmsk_general = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';

% select a high negative threshold NOT to exclude any data
threshold=-1000;

% Select seed region (e.g. masked activation from a 2nd-level GLM)
%% I:
P_seeds{1} ='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v5___ORTH_1___DERDISP0___17-May-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3485_v24.nii';

%% Loop over seed regions
for ix=1:length(P_seeds)
    %% FIRSTLEVEL
    % output directory
    P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/10-resting_state' filesep '02-seed-analysis' filesep epiPrefix];
    if exist(P_outputdir_cur)~=7
        mkdir(P_outputdir_cur)
    end
    if 1==1
        do_seedanalysis_firstlevel_jr(P_seeds{ix}, Pfunc_unsmoothed, Pfunc_smoothed, P_outputdir_cur, threshold, Pmsk_general)
    end
    
    %% SECONDLEVEL
    if 1==1
        % Selection of fcc-series
        P_fccSeries = spm_select('FPListRec',P_outputdir_cur,['^fCC_.*.nii$']);
        % output directory        
        P_outputdir_cur=[P_outputdir_cur filesep 'secondlevel'];
        if exist(P_outputdir_cur)~=7
            mkdir(P_outputdir_cur)
        end
                
        % define contrasts
        contrast.name{1} = ['positive'];
        contrast.val{1} = [1];
        contrast.name{2} = ['negative'];
        contrast.val{2} = [-1];
        
        % run 2nd level analysis
        do_seedanalysis_secondlevel_RS_jr(P_fccSeries, P_outputdir_cur, Pmsk_general, contrast)
    end
end













