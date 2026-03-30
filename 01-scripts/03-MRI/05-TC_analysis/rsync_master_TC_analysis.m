%% Preparation
clear all;
% close all;
clc;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/toolboxes/spm12_animal'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/MRTPrediction/fMRI/GLM'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/MRTPrediction/fMRI/TC_analysis'))
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_RPE/scripts/MRTPrediction/fMRI/preprocessing/EPI/general/framewise_displacement'))

% define paths and regressors/covariates ...
regressorsSuffsess = '_v99.mat';
orth = 1;
covarSuffsess = '_v1.mat';

% selection of EPI
epiPrefsess = 'msk_s_rwst_a1_u_del5_';
% epiPrefsess = 's_rwst_a1_u_del5_';
% epiPrefsess = 's6_wave_10cons_med1000_msk_rwst_a1_u_del5_';
epiSuffsess = '_c1_c2t';
% epiSuffsess = '_c1_c2t_icaden25_16-Feb-2020';
% epiSuffsess = '_c1_c2t_wds';

% general result directory
resultsDir = '/zi-flstorage/data/Jonathan/ICON_RPE/analyses/MRTPrediction/fMRI/TC_analysis/results';
local_resultsDir = '/home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/TC_analysis/results';
% mkdir(local_resultsDir);

% outputDirName
if contains(epiSuffsess,'noise')
    outputDirName = [epiSuffsess(end-4:end) '_EPI_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '____Orth_' num2str(orth)];
elseif contains(epiSuffsess,'ica')
    outputDirName = ['EPI_ICA_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '___Orth_' num2str(orth)];
elseif contains(epiPrefsess,'wave')
    outputDirName = ['EPI_WD_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '____Orth_' num2str(orth)];
elseif ~contains(epiSuffsess,'noise')
    outputDirName = ['EPI_' epiPrefsess(1:15) '___ROI_' regressorsSuffsess(2:end-4) '___COV_' covarSuffsess(2:3) '____Orth_' num2str(orth)];
end

firstleveldir = [resultsDir filesep outputDirName filesep 'firstlevel_residuals'];
local_firstleveldir = [local_resultsDir filesep outputDirName filesep 'firstlevel_residuals'];
% mkdir(local_firstleveldir);

% Define session path ...
dirlist = dir(firstleveldir);
dirlist = dirlist(contains({dirlist.name},'ZI_M'));
numbersess = numel(dirlist);

% sessect selection
sessions = [1:83];

% addon = ' - 12 rps '

if 1==0
    %%  LET'S GETTING STARTED ...
    for sess=sessions
        
        %% Preparation of current session
        % get sessiondir ...
        sessiondir = [firstleveldir filesep dirlist(sess).name];
        local_sessiondir = [local_firstleveldir filesep dirlist(sess).name];
        mkdir(local_sessiondir);
        
        % select ...
        %     Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_' dirlist(sess).name '.nii']);
        Pcur=spm_select('FpList', sessiondir ,['^SPM.mat']);
        
        cmd = ['rsync -a ' Pcur ' ' local_sessiondir]
        system(cmd);
    end
end

%% Synchronisation of scripts
if 1==0
    cmd = ['rsync -a /zi-flstorage/data/Jonathan/ICON_RPE/scripts/ /home/jonathan.reinwald/ICON_RPE/scripts']
    system(cmd);
end



