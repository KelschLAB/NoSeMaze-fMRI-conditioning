%% create_covariates_TC_analysis_ICON_RPE_jr.m
% Reinwald, Jonathan 06/2021

% Info:
% - create covariates ("regressors without interest")

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts'))

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_RPE/data/MRTPrediction/fMRI/preprocessing/fMRI_new_mat_sorted';
outputdir='/home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/TC_analysis/covariates';
if exist(outputdir)==0;
    mkdir(outputdir);
end
cd(outputdir);

% load filelist
load('/home/jonathan.reinwald/ICON_RPE/data/MRTPrediction/fMRI/filelists/filelist_awake_MAIN_JR.mat');

% define suffix of the respective .mat-files
suffix = 'v1';
    
%% Loop over animals
for sess = 1:length(Pfunc)
    % clear variables
    clear covar regressors
    
    
    %% 1. find and load regressor-files
    [fpath,fname,ext]=fileparts(Pfunc{sess});
    regressors=load([fpath filesep 'regressors_motcsf_der.txt']);
    
    %% 2. write information into regressors-file
    % select those manually
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% v1
    for ix = 1:6; 
        covar(ix).name = ['rp' num2str(ix)];
        covar(ix).value = regressors(:,ix);
        covar(ix+6).name = ['rp' num2str(ix) '_deriv'];
        covar(ix+6).value = regressors(:,ix+7);
    end;
        
    covar(13).name = ['csf'];
    covar(13).value = regressors(:,7);
    
    covar(14).name = ['csf_deriv'];
    covar(14).value = regressors(:,14);

    suffix = 'v1';
    outputdir_version = [outputdir filesep suffix];
    if exist(outputdir_version)==0;
        mkdir(outputdir_version);
    end
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% v2       
%     covar(1).name = ['csf'];
%     covar(1).value = regressors(:,7);
%     
%     covar(2).name = ['csf_deriv'];
%     covar(2).value = regressors(:,14);
% 
%     suffix = 'v2';
%     outputdir_version = [outputdir filesep suffix];
%     if exist(outputdir_version)==0;
%         mkdir(outputdir_version);
%     end
    
    save([outputdir_version filesep fname(1:11) '_' suffix],'covar');
end

%% Update metainfo

% load metafile
if exist ([outputdir_version filesep 'metainfo_covariates.mat']);
    load([outputdir_version filesep 'metainfo_covariates.mat']);
else
    metainfo = table;
    save([outputdir_version filesep 'metainfo_covariates.mat'],'metainfo')
end

% prepare clear new table (T) to add to metainfo
T=table(string(''),string(''),string(''),string(''),string(''),string(''),string(''),string(''),string(''),string(''));
for i = 1:10;
    T.Properties.VariableNames{i} = ['Cov_' num2str(i) '_' 'Name'];
end
T.Properties.RowNames = cellstr(suffix);

% create new table for current version
for i = 1:length(covar);
    T(1,i)=cellstr(covar(i).name);
end

% add new table to metainfo file and save it
metainfo=[metainfo;T];
save([outputdir_version filesep 'metainfo_covariates.mat'],'metainfo');
writetable(metainfo,[outputdir_version filesep 'metainfo_covar.csv'],'Delimiter',',','QuoteStrings',true);



















