%% master_preprocess_protocol__reappraisal__pupil.m
%% 

% Jonathan Reinwald 06/2022
% - protocollist (based on protocolfiles in Headerfiles_MRTprediction_JR)
% - rhdlist selects all rhd-files on zistna12
% - perform EPHYSPUPILprediction_protocol_JR → for details, see below
% - copy and sort _protocol_new.mat-files in new folder

%% pre-Clearing
clear all
close all
clc

%% Set pathes
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/'))


%% Definition of basic pathes
protocol_dir='/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/01-reappraisal/01-protocol_files' % Files are manually controlled, including only protocol.mat-files with rhd-files
rhd_dir='/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/01-reappraisal/02-rhd_files'
outputdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/04-pupil/01-reappraisal/01-processed_protocol_files'
mkdir(outputdir)
rootdir='/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil'

%% get all rhds and mats, create pairs of corresponding files, ...

rhdlist=getAllFiles(rhd_dir, '*.rhd',1);
% rhdlist_2=getAllFiles(rhd_dir_2, '*.rhd',1);
protocollist=getAllFiles(protocol_dir, '*protocol.mat', 1);
% rhdlist=[rhdlist_1; rhdlist_2];
nVolume=1600;

if 1==1
    process_protocol__reappraisal__pupil(protocollist,rhdlist,outputdir,rootdir,nVolume);
end





























% Aim: Copy and rename ..._new.mat-files
if 1==0;
    cd(basedir);
    mkdir fEPHYS_new_mat_sorted
    for ix=1:size(Pfunc,2);
        cd([basedir '/fEPHYS_new_mat']);
        % find and copy "fEPHYSNO"-files (files with no odor exposition) and
        % rename them
        newname=['/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fEPHYS_new_mat_sorted/ZI_M' date_time_long{ix} '_' animal_number{ix} '_protocol_new.mat'];
        syscmd=['find . -maxdepth 4 -type f -name ''' animal_number{ix} '*' date_time{ix} '*'' -exec cp {} ' newname '  \;'];
        system(syscmd);
    end;
end;



