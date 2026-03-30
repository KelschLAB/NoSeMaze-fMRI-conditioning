%% master_RS_reappraisal_jr.m

%% Preparation
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINITIONS
% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% Predefine atlas
% Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged_jr.txt';
% Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged.nii';
% separated_hemisphere=0;
Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.nii';
Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr_sorted.txt';
separated_hemispheres = 1;% 1 = unilateral, 0 = bilateral

% selection of EPI
% epiPrefix = 'bpm_0.01_0.1_wave_10cons_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
epiPrefix = 'bpm_0.01_0.1_med1000_msk_s6_regfilt_motcsfgsder_wrst_a1_u_despiked_del5_';
% epiPrefix = 'bpm_0.01_0.1_wave_10cons_med1000_msk_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
epiSuffix = '_c1_c2t';
% epiSuffix = '_c1_c2t_wds';
% epiPrefix = 'bpm_0.01_0.1_scrub_0_1_lin_wave_10cons_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
% epiSuffix = '_c1_c2t_wds';

% input and output directory
inputDir = '/zi-flstorage/data/jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing';
if separated_hemispheres==1
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/10-resting_state','01-cormat',epiPrefix,'separated_hemisphere');
elseif separated_hemispheres==0
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/10-resting_state','01-cormat',epiPrefix,'combined_hemisphere');   
end
mkdir(outputDir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pcur = spm_select('ExtFPlistrec',inputDir,['^' epiPrefix '.*.' epiSuffix '.nii'],1);

cd(outputDir);
[cormat  subj]=wwf_covmat_hres_jr(Ptxt,Pcur,Patlas);

save([outputDir filesep 'cormat.mat'],'cormat');
save([outputDir filesep 'roidata.mat'],'subj');