%% master_preprocess_protocol__social_defeat.m
%% 

% Jonathan Reinwald 12/2020
% - protocollist (based on protocolfiles in Headerfiles_MRTprediction_JR)
% - rhdlist selects all rhd-files on zistna12
% - perform EPHYSPUPILprediction_protocol_JR → for details, see below
% - copy and sort _protocol_new.mat-files in new folder


%% Set pathes
clear all
close all
clc
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB'))


%% Definition of basic pathes
protocol_dir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/MRI/paradigm_social_defeat/protocol_files' % Files are manually controlled, including only protocol.mat-files with rhd-files
rhd_dir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/MRI/paradigm_social_defeat/rhd_files'
outputdir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/MRI/paradigm_social_defeat/processed_protocol_files'
mkdir(outputdir)
rootdir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/MRI/paradigm_social_defeat'

%% get all rhds and mats, create pairs of corresponding files, ...

rhdlist=getAllFiles(rhd_dir, '*.rhd',1);
% rhdlist_2=getAllFiles(rhd_dir_2, '*.rhd',1);
protocollist=getAllFiles(protocol_dir, '*protocol.mat', 1);
% rhdlist=[rhdlist_1; rhdlist_2];

nVolume = 1100;

if 1==1;
    process_protocol__social_defeat(protocollist,rhdlist,outputdir,rootdir,nVolume);
end;





























% Aim: Copy and rename ..._new.mat-files
if 1==0;
    cd(basedir);
    mkdir fMRI_new_mat_sorted
    for ix=1:size(Pfunc,2);
        cd([basedir '/fMRI_new_mat']);
        % find and copy "fMRINO"-files (files with no odor exposition) and
        % rename them
        newname=['/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fMRI_new_mat_sorted/ZI_M' date_time_long{ix} '_' animal_number{ix} '_protocol_new.mat'];
        syscmd=['find . -maxdepth 4 -type f -name ''' animal_number{ix} '*' date_time{ix} '*'' -exec cp {} ' newname '  \;'];
        system(syscmd);
    end;
end;



