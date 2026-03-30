%% create_vid_pathlist_reappraisal_jr.m
% Reinwald, Jonathan 07/2022

% clearing
clear all
clc
close all

% Predefine folders
vid_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/01-reappraisal/03-videos_pupil';
subfolder_list = dir(vid_mainDir);
% delete ./..
subfolder_list(strcmp({subfolder_list.name},'.') | strcmp({subfolder_list.name},'..'))=[];

% Create videolist
for ix=1:length(subfolder_list)
    vid_path_list{ix} = fullfile(subfolder_list(ix).folder,subfolder_list(ix).name,'Video');
end

% Save
save(fullfile(vid_mainDir,'vid_pathlist_reappraisal.mat'),'vid_path_list');