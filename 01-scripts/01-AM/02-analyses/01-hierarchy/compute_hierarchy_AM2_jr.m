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

%% add chasing events
% add plotting/threshold options, ...
ops=[];
% calculate chasing events
[full_hierarchy]=extract_chasing_from_full_hierarchy_v2_jr(full_hierarchy,ops);
% [full_hierarchy]=extract_chasing_from_full_hierarchy_jr(full_hierarchy,ops);
% save new full hierarchy data
save(fullfile(data_path,'full_hierarchy_withChasing.mat'),'full_hierarchy');

%% add multiple chasing events
% define threshold for time between successive following events
time_threshold = 10;
% calculate multiple chasing events
[full_hierarchy] = extract_multiple_chasing_from_full_hierarchy_v2_jr(full_hierarchy,time_threshold);
% save new full hierarchy data
save(fullfile(data_path,'full_hierarchy_withChasingAndMultipleChasing.mat'),'full_hierarchy');

%% Example: for every animal compute the hierarchy until 23.07.20 (day before first animals were scanned the first time)

% ANIMALS:
% exclude animals that only entered later
% SCAN 1 - REAPPRAISAL: ID index according to full_hierarchy(1).ID for 
% exclude_animals =[];

% SCAN 2 - SOCIAL DEFEAT: ID index according to full_hierarchy(1).ID for 
exclude_animals =[12];

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
include_days = 31:40;

% full hierarchy stores data day-by-day 
% traditional tube test hierarchy
full_match_matrix = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
for day = 1:numel(include_days)
    full_match_matrix = full_match_matrix + full_hierarchy(include_days(day)).match_matrix(matrix_index_include',matrix_index_include');        
end

% chasing
full_match_matrix_chasing = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
for day = 1:numel(include_days)
    full_match_matrix_chasing = full_match_matrix_chasing + full_hierarchy(include_days(day)).match_matrix_chasing(matrix_index_include',matrix_index_include');        
end

% multiple chasing
full_match_matrix_multiple_chasing = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
full_match_matrix_double_chasing = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
full_match_matrix_single_following = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
for day = 1:numel(include_days)
    full_match_matrix_multiple_chasing = full_match_matrix_multiple_chasing + full_hierarchy(include_days(day)).match_matrix_multiple_chasing(matrix_index_include',matrix_index_include');     
    full_match_matrix_double_chasing = full_match_matrix_double_chasing + full_hierarchy(include_days(day)).match_matrix_double_chasing(matrix_index_include',matrix_index_include');
    full_match_matrix_single_following = full_match_matrix_single_following + full_hierarchy(include_days(day)).match_matrix_single_following(matrix_index_include',matrix_index_include');
end

% compute traditional hierarchy
DS_info = compute_DS_from_match_matrix(full_match_matrix);

% compute chasing hierarchy
DS_info_chasing = compute_DS_from_match_matrix(full_match_matrix_chasing);

% compute multiple chasing hierarchy
DS_info_multiple_chasing = compute_DS_from_match_matrix(full_match_matrix_multiple_chasing);
DS_info_double_chasing = compute_DS_from_match_matrix(full_match_matrix_double_chasing);
DS_info_single_following = compute_DS_from_match_matrix(full_match_matrix_single_following);

% add ID (JR, 17.01.2023)
DS_info.ID = full_hierarchy(1).ID(matrix_index_include);
clear rank_idx
[~,rank_idx] = sort(DS_info.DS,'descend');
[~,DS_info.rank] = sort(rank_idx);
DS_info.sortedID = DS_info.ID(DS_info.DS_sortedIndex);
DS_info_chasing.ID = full_hierarchy(1).ID(matrix_index_include);
DS_info_chasing.sortedID = DS_info.ID(DS_info.DS_sortedIndex);
DS_info_double_chasing.ID = full_hierarchy(1).ID(matrix_index_include);
DS_info_double_chasing.sortedID = DS_info.ID(DS_info.DS_sortedIndex);
DS_info_single_following.ID = full_hierarchy(1).ID(matrix_index_include);
DS_info_single_following.sortedID = DS_info.ID(DS_info.DS_sortedIndex);

% save David's scores (JR, 17.01.2023)
save(fullfile(data_path,['DS_info_AM2_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasingAndDoubleChasing_thresh' num2str(time_threshold) '.mat']),'DS_info','DS_info_chasing','DS_info_double_chasing');

% plot DS in group in Carla's original design
f = plot_David_score_in_group(DS_info,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['rank_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasing.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

f = plot_hierarchy_graph_in_group(DS_info,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['graph_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasing.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

% plot DS in group in Carla's original design
f = plot_David_score_in_group(DS_info_chasing,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['chasing_rank_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasing.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

f = plot_hierarchy_graph_in_group(DS_info_chasing,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['chasing_graph_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasing.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

% plot DS in group in Carla's original design
f = plot_David_score_in_group(DS_info_double_chasing,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['double_chasing_rank_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasing.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

f = plot_hierarchy_graph_in_group(DS_info_double_chasing,full_hierarchy(1).ID(matrix_index_include));
exportgraphics(f, fullfile(save_dir,['double_chasing_graph_plot_day' num2str(include_days(1)) 'to' num2str(include_days(end)) '_' num2str(sum(matrix_index_include)) 'mice_withChasing.pdf']),'ContentType','vector','BackgroundColor','none');
close all;

% 
figure;

subplot(2,2,1);
sc=scatter(DS_info_single_following.DS,DS_info_double_chasing.DS);
axis square
ax=gca;
ax.YLabel.String = {['double chasing: ' num2str(time_threshold) 's'],'Davids score'};
ax.XLabel.String = {['following'],'Davids score'};
lsline;
text(1,1,['r=' num2str(corr(DS_info_single_following.DS',DS_info_double_chasing.DS'))]);

subplot(2,2,2);
sc=scatter(DS_info.DS,DS_info_double_chasing.DS);
axis square
ax=gca;
ax.YLabel.String = {['double chasing: ' num2str(time_threshold) 's'],'Davids score'};
ax.XLabel.String = {['social hierarchy'],'Davids score'};
lsline;
text(1,1,['r=' num2str(corr(DS_info.DS',DS_info_double_chasing.DS'))]);

T1 = table([sum(sum(sum(cat(3,full_hierarchy(:).match_matrix)))),sum(sum(sum(cat(3,full_hierarchy(:).match_matrix_chasing)))),sum(sum(sum(cat(3,full_hierarchy(:).match_matrix_multiple_chasing)))),sum(sum(sum(cat(3,full_hierarchy(:).match_matrix_double_chasing))))]','RowNames',{'SH','Follow','ChaseM','ChaseD'},'VariableNames',{'All days'});
T2 = table([sum(sum(sum(cat(3,full_hierarchy(include_days).match_matrix)))),sum(sum(sum(cat(3,full_hierarchy(include_days).match_matrix_chasing)))),sum(sum(sum(cat(3,full_hierarchy(include_days).match_matrix_multiple_chasing)))),sum(sum(sum(cat(3,full_hierarchy(include_days).match_matrix_double_chasing))))]','RowNames',{'SH','Follow','ChaseM','ChaseD'},'VariableNames',{[num2str(include_days(1)) 'to' num2str(include_days(end))]});

T = [T1,T2];
