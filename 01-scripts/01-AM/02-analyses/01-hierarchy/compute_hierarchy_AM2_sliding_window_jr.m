%% compute_hierarchy_AM2_sliding_window_jr.m

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
for ix=1:(length(full_hierarchy)-6)
    include_days = ix:(ix+6);

    % full hierarchy stores data day-by-day
    full_match_matrix = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
    for day = 1:numel(include_days)
        full_match_matrix = full_match_matrix + full_hierarchy(include_days(day)).match_matrix(matrix_index_include',matrix_index_include');
    end

    % compute hierarchy
    myData(ix).DS_info = compute_DS_from_match_matrix(full_match_matrix);
    myData(ix).DS_info.ID = full_hierarchy(1).ID(matrix_index_include);
    DS_all(ix,:)=myData(ix).DS_info.DS;
    DSz_all(ix,:)=zscore(myData(ix).DS_info.DS);
    clear temp1 temp2
    [~,idx]=sort(DS_all(ix,:));
    [~,rank]=sort(idx);
    Rank_all(ix,:)=rank;
end

% ranks of interest
rankMat = Rank_all([1:22],:);
DSMat = DS_all([1:22],:);
DSzMat = DSz_all([1:22],:);

% estimate distribution of rank changes when comparing 1-7 to 10-17 (Week
% 1, 2 days, Week 2)
% for i = [1:(22-9)]
%     [r(i,1),p(i,1)]=corr(DSMat(i,:)',DSMat(i+9,:)');
%     [r(i,2),p(i,2)]=corr(rankMat(i,:)',rankMat(i+9,:)');
%     [r(i,3),p(i,3)]=corr(DSzMat(i,:)',DSzMat(i+9,:)');
% end

% estimate distribution of rank changes when comparing 1-7 to 10-17 (Week
% 1, 2 days, Week 2)
for i = [1:(22-7)]
    [r(i,1),p(i,1)]=corr(DSMat(i,:)',DSMat(i+7,:)');
    [r(i,2),p(i,2)]=corr(rankMat(i,:)',rankMat(i+7,:)');
    [r(i,3),p(i,3)]=corr(DSzMat(i,:)',DSzMat(i+7,:)');
end












