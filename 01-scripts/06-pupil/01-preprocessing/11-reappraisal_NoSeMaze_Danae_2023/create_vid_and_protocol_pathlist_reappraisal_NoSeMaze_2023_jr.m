%% create_vid_and_protocol_pathlist_reappraisal_NoSeMaze_2023_jr.m
% Reinwald, Jonathan 07/2022

% clearing
clear all
clc
close all

% Predefine folders
vid_mainDir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/04-pupil/10-reappraisal_NoSeMaze_Danae_2023/03-videos_pupil';
subfolder_list = dir(vid_mainDir);
% Selection of videos ./..
subfolder_list = subfolder_list(contains({subfolder_list.name},'.wmv'));

% Create videolist
for ix=1:length(subfolder_list)
    vid_path_list{ix} = fullfile(subfolder_list(ix).folder,subfolder_list(ix).name);
end

% Save
save(fullfile(vid_mainDir,'vid_pathlist_reappraisal_NoSeMaze_2023.mat'),'vid_path_list');

% Predefine folders
protocol_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/04-pupil/10-reappraisal_NoSeMaze_Danae_2023/01-processed_protocol_files';
protocol_path_list=spm_select('FPlistrec',protocol_mainDir,'.*._new.mat');
protocol_path_list=cellstr(protocol_path_list)';

% Save
save(fullfile(protocol_mainDir,'protocol_pathlist_reappraisal_NoSeMaze_2023.mat'),'protocol_path_list');