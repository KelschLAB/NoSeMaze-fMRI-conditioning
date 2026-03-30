%% create_vid_and_protocol_pathlist_160TrialsNeroli_ephys_2022_jr.m.m
% Reinwald, Jonathan 07/2022

% clearing
clear all
clc
close all

% Predefine folders
vid_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/06-160TrialsNeroli_ephys_2022/03-videos_pupil';
subfolder_list = dir(vid_mainDir);
% delete ./..
subfolder_list(contains({subfolder_list.name},'vid_') | contains({subfolder_list.name},'.') | contains({subfolder_list.name},'..'))=[];

% Create videolist
for ix=1:length(subfolder_list)
    vid_path_list{ix} = fullfile(subfolder_list(ix).folder,subfolder_list(ix).name);
end

% Save
save(fullfile(vid_mainDir,'vid_pathlist_160TrialsNeroli_ephys_2022.mat'),'vid_path_list');

% Predefine folders
protocol_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/04-pupil/06-160TrialsNeroli_ephys_2022/01-processed_protocol_files';
protocol_path_list=spm_select('FPlistrec',protocol_mainDir,'.*._new.mat');
protocol_path_list=cellstr(protocol_path_list)';

% Save
save(fullfile(protocol_mainDir,'protocol_pathlist_160TrialsNeroli_ephys_2022.mat'),'protocol_path_list');