%% compute_hierarchy_AM2_jr.m

%% Hi Jonathan
%  ich nutze paar Skripte, die auf Github: KelschLab/NoSeMaze-hierarchy
%  liegen für die Berechnungen etc
%
% David, 01/2023, adapted: Jonathan Reinwald 17.01.2023
%% 
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab/NoSeMaze-hierarchy-main')); % adjusted JR, 17.01.2023
clear;

data_path = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest'; % adapted JR, 17.01.2023
save_dir = fullfile(data_path,'plots');
if ~exist(save_dir)
    mkdir(save_dir);
end 
load(fullfile(data_path,'full_hierarchy.mat'));

%% Example: for every animal compute the hierarchy until 23.07.20 (day before first animals were scanned the first time)

% ANIMALS:
% exclude animals that only entered later
% SCAN 1 - REAPPRAISAL: ID index according to full_hierarchy(1).ID for 
exclude_animals =[];

% SCAN 2 - SOCIAL DEFEAT: ID index according to full_hierarchy(1).ID for 
% exclude_animals =[];

% SCAN 3 - SOCIAL HIERARCHY: ID index according to full_hierarchy(1).ID for 
% exclude_animals = [12]; % animals which were replaced in the NoSeMaze after the reappraisal task or the social defeat task and therefore did not perform the social hierarchy task (0007CB6B2C, #12)

num_animals = numel(full_hierarchy(1).ID);
matrix_index_include = ~ismember(1:num_animals,exclude_animals);

% DAYS:
% include days from the beginning until (including) 23.07.20
% when looking at full_hierarchy(day).Data you can check the date if
% unsure
% Scanning days: 
% Scan 1 (D15 and D16)
% Scan 2 (D29 and D30)
% Scan 3 (D44 and D45)
include_days = 5:14;

% full hierarchy stores data day-by-day 
full_match_matrix = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
for day = 1:numel(include_days)
    full_match_matrix = full_match_matrix + full_hierarchy(include_days(day)).match_matrix(matrix_index_include',matrix_index_include');        
end

% compute hierarchy
DS_info = compute_DS_from_match_matrix(full_match_matrix);

% add ID (JR, 17.01.2023)
DS_info.ID = full_hierarchy(1).ID(matrix_index_include);
DS_info.sortedID = DS_info.ID(DS_info.DS_sortedIndex);

% save David's scores (JR, 17.01.2023)
save(fullfile(data_path,['DS_info_AM2_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '.mat']),'DS_info');

% plot DS in group in Carla's original design
f = plot_David_score_in_group(DS_info,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['rank_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

f = plot_hierarchy_graph_in_group(DS_info,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['graph_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '.pdf']),'ContentType','vector','BackgroundColor','none');
close all;



