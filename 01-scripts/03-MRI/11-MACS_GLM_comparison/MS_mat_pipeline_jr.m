% MACS Toolbox: Model Space Pipeline

% modified by Jonathan Reinwald, 06.01.2022

% This script assists in setting up a batch for defining a model space that
% can be viewed and executed in the SPM batch editor. It is particularly
% advantageous when the number of subjects or the number of models in your
% analyses is very large.
%
% If this is the case, you can simply enter
% - the statistics directory into "stat_dir",
% - the working directory into "work_dir",
% - the subject folder names into "subj_ids" and
% - the model folder names into "mod_names" below.
%
% In addition, you will have to specify
% - a model space name as "ms_name" and
% - a model space suffix as "ms_suff"
% which, together with the statistics directory, will determine where the
% model space directory will be located and the model space file will be
% written. Use these two parameters to distinguish different model space
% and analyses from each other.
%
% Author: Joram Soch, BCCN Berlin
% E-Mail: joram.soch@bccn-berlin.de
%
% First edit: 18/08/2017, 17:35 (V1.1/V17)
%  Last edit: 11/06/2018, 15:35 (V1.2/V18)

%%% Step 0: Study parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc
% close all
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'))

% project directories
stat_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/04-modelselection';
work_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results';

% list of subjects
subj_ids = {'ZI_M11' 'ZI_M12' 'ZI_M13' 'ZI_M14' 'ZI_M17' 'ZI_M18' 'ZI_M19' 'ZI_M22' 'ZI_M23' 'ZI_M24' ...
    'ZI_M25' 'ZI_M26' 'ZI_M27' 'ZI_M30' 'ZI_M31' 'ZI_M32' 'ZI_M33' 'ZI_M34' 'ZI_M35' 'ZI_M36' ...
    'ZI_M37' 'ZI_M38' 'ZI_M39' 'ZI_M40'};

% list of models
% mod_names = {'HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___05-Jan-2022' ...
%     'HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___05-Jan-2022' ...
% %     'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022' ...
% %     'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022' ...
% %     'HRFmeanTCbased_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v21___COV_v1___05-Jan-2022' ...
%     'HRFmeanTCbased_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___05-Jan-2022' ...
%     'HRFmeanTCbased_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___05-Jan-2022'};

% mod_names = {'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Sep-2022' ...
%     'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___09-Sep-2022'};

mod_names = {'no_despiking','AFNI_despiking','WD_and_AFNI_despiking'};

mod_directories = {'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v22___COV_v2___ORTH_1___DERDISP0___07-Aug-2023',...
    'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___29-Mar-2023',...
    'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023'};

% model space details
ms_name  =  'MACS';
ms_suff = '_1_NoDespiking_2_AFNIDespiking_3_AFNIplusWaveletDespiking';

% study dimensions
N = numel(subj_ids);
M = numel(mod_names);


%%% Step 1: Create model space job %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% working directory
clear job
job.dir{1} = strcat(stat_dir,'/',ms_name,'_',ms_suff,'/');

% assemble SPM.mats
for i = 1:N
    for j = 1:M
        job.models{i}{j}{1} = strcat(work_dir,'/',mod_directories{j},'/firstlevel/',subj_ids{i},'/','SPM.mat');
    end
end

% assemble GLM names
for j = 1:M
    job.names{j} = mod_names{j};
end


%%% Step 2: Execute model space job %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save batch
clear matlabbatch
mkdir(job.dir{1});
filename = strcat(job.dir{1},'batch.mat');
matlabbatch{1}.spm.tools.MACS.MA_model_space = job;
save(filename,'matlabbatch');

% execute job
MA_model_space(job);

% display message
fprintf('\n');
fprintf('\n-> Thank you! The following files have been created:\n');
fprintf('   - SPM batch: %s.\n', strcat(job.dir{1},'batch.mat'));
fprintf('   - MS.mat file: %s.\n', strcat(job.dir{1},'MS.mat'));
fprintf('\n');

%%% Step 3: cvBMS definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;
matlabbatch{3}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = cfg_dep('MA: define model space: model space (MS.mat file)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','MS_mat'));
matlabbatch{3}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
matlabbatch{3}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
matlabbatch{3}.spm.tools.MACS.MS_BMS_group_auto.EPs = 1;
matlabbatch{4}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BMS_mat'));
matlabbatch{4}.spm.tools.MACS.MS_SMM_BMS.extent = 10;

spm_jobman('run',matlabbatch);

% display message
fprintf('\n');
fprintf('\n-> cvBMS estimation was successfully done! \n');
fprintf('\n');