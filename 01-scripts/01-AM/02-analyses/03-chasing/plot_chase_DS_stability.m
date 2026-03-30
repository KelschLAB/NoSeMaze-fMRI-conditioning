%% Plot temporal stability of DS within animals 
%   last edited by David Wolf, 11.12.2023
%
%
%% load dataset
clear;clc;
save_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/plots';
T = readtable('/zi-flstorage/data/jonathan/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

data_dir{1} = '/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/';
data_dir{2} = '/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/';

addpath(genpath('/home/david.wolf/Documents/github/NoSeMaze-hierarchy-main/'));

%% suboptimal computaion, use the one below
% %% compute and parse rank and David score
% for gr = 1:2
% 
%     % import hierarchy from integrated Tube-Test (ITT)
%     load(fullfile(data_dir{gr}, 'full_hierarchy.mat'))
% 
%     % week 1
%     full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
%     for day = 1:7
%         full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix;        
%     end
%     % compute hierarchy
%     DS_info_1 = compute_DS_from_match_matrix(full_match_matrix);
%     [~,current_ranks_1] = sort(DS_info_1.DS_sortedIndex);
%     
%     % week 2
%     full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
%     for day = 8:14
%         full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix;        
%     end
%     % compute hierarchy
%     DS_info_2 = compute_DS_from_match_matrix(full_match_matrix);
%     [~,current_ranks_2] = sort(DS_info_2.DS_sortedIndex);
%     
%     
%     for an=1:numel(current_ranks_1)
%         
%        % find index in master matrix
%        animal_idx = find(T.Autonomouse==gr & contains(T.AnimalIDCombined,full_hierarchy(1).ID{an}));
%        if ~isempty(animal_idx)
%            % week 1
%            T.rank_1(animal_idx) = current_ranks_1(an);
%            T.DS_1(animal_idx) = DS_info_1.DS(an);
% 
%            % week 2
%            T.rank_2(animal_idx) = current_ranks_2(an);
%            T.DS_2(animal_idx) = DS_info_2.DS(an);
%        end
%     end
% end

%% compute and parse rank and David score: matchin the relevant time window for the animal

for an = 1:size(T,1)

     % import hierarchy from integrated Tube-Test (ITT)
    load(fullfile(data_dir{T.Autonomouse(an)}, 'full_hierarchy_withChasing.mat'))

    start = str2double(T.DaysToConsider{an}(1));
    stop = str2double(T.DaysToConsider{an}(end-1:end));
    split_point = start+ceil((stop-start)/2);
    
    % full
    full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
    for day = start:stop
        full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix_chasing;        
    end
    % compute hierarchy
    DS_info_full = compute_DS_from_match_matrix(full_match_matrix);
    [~,current_ranks_full] = sort(DS_info_full.DS_sortedIndex);
    
    % first 7
    full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
    for day = start:split_point-1
        full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix_chasing;        
    end
    % compute hierarchy
    DS_info_1 = compute_DS_from_match_matrix(full_match_matrix);
    [~,current_ranks_1] = sort(DS_info_1.DS_sortedIndex);
    
    % week 2
    full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
    for day = split_point:stop
        full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix_chasing;        
    end
    % compute hierarchy
    DS_info_2 = compute_DS_from_match_matrix(full_match_matrix);
    [~,current_ranks_2] = sort(DS_info_2.DS_sortedIndex);
   
   
    % find index in DS info
    idx = find(contains(full_hierarchy(1).ID,T.AnimalIDCombined{an}));
   
   
    % full 2 weeks
    T.rank_full(an) = 13-current_ranks_full(idx);
    T.DS_full(an) = DS_info_full.DS(idx);

    % week 1
    T.rank_1(an) = 13-current_ranks_1(idx);
    T.DS_1(an) = DS_info_1.DS(idx);

    % week 2
    T.rank_2(an) = 13-current_ranks_2(idx);
    T.DS_2(an) = DS_info_2.DS(idx);
   
end


%% correlation across weeks

f = figure;
hold on;
scatter(T.DS_1,T.DS_2,20,'.','k');
[rho_sp,pval_sp] = corr(T.DS_1,T.DS_2,'type','Spearman');
[rho,pval] = corr(T.DS_1,T.DS_2,'type','Pearson');
l=lsline;
xlabel('David Score (week 1)');
ylabel('David Score (week 2)');
title({['Pearson: ',num2str(round(rho,2)),', p = ',num2str(round(pval,4))],...
    ['Spearman: ',num2str(round(rho_sp,2)),', p = ',num2str(round(pval_sp,4))]});
set_fonts()

f.Units = 'centimeters';
f.Position = [3 3 4 4];
exportgraphics(f,fullfile(save_dir,'chase_DS_correlation_within_week_1_to_2.pdf'));

f = figure;
hold on;
scatter(T.rank_1,T.rank_2,20,'.','k');
[rho_sp,pval_sp] = corr(T.rank_1,T.rank_2,'type','Spearman');
[rho,pval] = corr(T.rank_1,T.rank_2,'type','Pearson');
l=lsline;
xlabel('rank (week 1)');
ylabel('rank (week 2)');
xlim([.5 12.5]);
ylim([.5 12.5]);
title({['Pearson: ',num2str(round(rho,2)),', p = ',num2str(round(pval,4))],...
    ['Spearman: ',num2str(round(rho_sp,2)),', p = ',num2str(round(pval_sp,4))]});
set_fonts()

f.Units = 'centimeters';
f.Position = [3 3 4 4];
exportgraphics(f,fullfile(save_dir,'chase_rank_correlation_within_week_1_to_2.pdf'));


writetable(T,fullfile(save_dir,'chase_stability_source.xlsx'));