%% compute_hierarchy_AM1andAM2_sliding_window_jr.m

% pre-clearing
clear all;
clc;
close all;

% predefine sliding window length (in days)
sw_length = 7;
n_perm=100;

%% AM1
% path definition and data loading
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab/NoSeMaze-hierarchy-main'));
data_path = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest';
save_dir = fullfile(data_path,'plots');
if ~exist(save_dir)
    mkdir(save_dir);
end
load(fullfile(data_path,'full_hierarchy.mat'));

% predefine empty table
full_hierarchy_AM1 = full_hierarchy;
data=nan(length(full_hierarchy_AM1(1).ID),length(full_hierarchy_AM1)-(sw_length-1));
DS_table_AM1 = array2table(data);
DS_table_AM1.Properties.RowNames = full_hierarchy(1).ID;
% variable names for table
clear variable_names
for ix=1:(length(full_hierarchy_AM1)-(sw_length-1))
    variable_names{ix} = ['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))];
end
DS_table_AM1.Properties.VariableNames = variable_names;
Rank_table_AM1 = DS_table_AM1;
DSz_table_AM1 = DS_table_AM1;

% loop
for ix=1:(length(full_hierarchy)-(sw_length-1))
    % ANIMALS:
    
    % To exclude
    % animal #10: 0007CB0EDD or 0007CD330D was in the NoSeMaze including
    % the 22nd day
    % animal #5: 0007CB0ABC was in the NoSeMaze including the 22nd day
    if (ix+(sw_length-1))<23
        exclude_animals = [7,4];
        num_animals = numel(full_hierarchy(1).ID);
        matrix_index_include = ~ismember(1:num_animals,exclude_animals);
        % animal #7: 0007CB0EAF or 0007CB0F95 was in the NoSeMaze from the 23rd
        % day on
        % animal #4: 0007CB090F was in the NoSeMaze from the 23rd day on
    elseif (ix+(sw_length-1))>=23 && ix<23
        exclude_animals = [7,4,10,5];
        num_animals = numel(full_hierarchy(1).ID);
        matrix_index_include = ~ismember(1:num_animals,exclude_animals);
    elseif ix>=23 && (ix+(sw_length-1))<38
        exclude_animals = [10,5];
        num_animals = numel(full_hierarchy(1).ID);
        matrix_index_include = ~ismember(1:num_animals,exclude_animals);
        % animal #3: 0007CB08A5 was in the NoSeMaze including the 37nd day
    elseif (ix+(sw_length-1))>=38
        exclude_animals = [10,5,3];
        num_animals = numel(full_hierarchy(1).ID);
        matrix_index_include = ~ismember(1:num_animals,exclude_animals);
    end
    
    % DAYS:
    % days to include
    include_days = ix:(ix+(sw_length-1));
    % full hierarchy stores data day-by-day
    full_match_matrix = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
    for day = 1:numel(include_days)
        full_match_matrix = full_match_matrix + full_hierarchy(include_days(day)).match_matrix(matrix_index_include',matrix_index_include');
    end
    % compute hierarchy
    myData_AM1(ix).DS_info = compute_DS_from_match_matrix(full_match_matrix);
    %
    myData_AM1(ix).DS_info.ID = full_hierarchy(1).ID(matrix_index_include);
    myData_AM1(ix).DS_info.DSz=zscore(myData_AM1(ix).DS_info.DS);
    clear idx rank
    [~,idx]=sort(myData_AM1(ix).DS_info.DS);
    [~,rank]=sort(idx);
    myData_AM1(ix).DS_info.Rank=rank;
    % fill table
    for jx=1:length(myData_AM1(ix).DS_info.ID)
        DS_table_AM1.(['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))])(myData_AM1(ix).DS_info.ID{jx}) = myData_AM1(ix).DS_info.DS(jx);
        Rank_table_AM1.(['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))])(myData_AM1(ix).DS_info.ID{jx}) = myData_AM1(ix).DS_info.Rank(jx);
        DSz_table_AM1.(['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))])(myData_AM1(ix).DS_info.ID{jx}) = myData_AM1(ix).DS_info.DSz(jx);
    end
end

%% AM2
% path definition and data loading
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab/NoSeMaze-hierarchy-main')); % adjusted JR, 17.01.2023
data_path = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest'; % adapted JR, 17.01.2023
save_dir = fullfile(data_path,'plots');
if ~exist(save_dir)
    mkdir(save_dir);
end
load(fullfile(data_path,'full_hierarchy.mat'));

% predefine empty table (Important: Use full_hierarchy_AM1 for definition
% of number of columns)
full_hierarchy_AM2=full_hierarchy;
data=nan(length(full_hierarchy_AM2(1).ID),length(full_hierarchy_AM1)-(sw_length-1));
DS_table_AM2 = array2table(data);
DS_table_AM2.Properties.RowNames = full_hierarchy_AM2(1).ID;
% variable names for table
clear variable_names
for ix=1:(length(full_hierarchy_AM1)-(sw_length-1))
    variable_names{ix} = ['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))];
end
DS_table_AM2.Properties.VariableNames = variable_names;
Rank_table_AM2 = DS_table_AM2;
DSz_table_AM2 = DS_table_AM2;

% loop
for ix=1:(length(full_hierarchy)-(sw_length-1))
    
    % ANIMALS:
    if (ix+(sw_length-1))>=38
        exclude_animals =[12];
        num_animals = numel(full_hierarchy(1).ID);
        matrix_index_include = ~ismember(1:num_animals,exclude_animals);
    else
        exclude_animals =[];
        num_animals = numel(full_hierarchy(1).ID);
        matrix_index_include = ~ismember(1:num_animals,exclude_animals);
    end
    % DAYS:
    % days to include
    include_days = ix:(ix+(sw_length-1));
    % full hierarchy stores data day-by-day
    full_match_matrix = zeros(numel(full_hierarchy(1).ID)-numel(exclude_animals));
    for day = 1:numel(include_days)
        full_match_matrix = full_match_matrix + full_hierarchy(include_days(day)).match_matrix(matrix_index_include',matrix_index_include');
    end
    % compute hierarchy
    myData_AM2(ix).DS_info = compute_DS_from_match_matrix(full_match_matrix);
    %
    myData_AM2(ix).DS_info.ID = full_hierarchy(1).ID(matrix_index_include);
    myData_AM2(ix).DS_info.DSz=zscore(myData_AM2(ix).DS_info.DS);
    clear idx rank
    [~,idx]=sort(myData_AM2(ix).DS_info.DS);
    [~,rank]=sort(idx);
    myData_AM2(ix).DS_info.Rank=rank;
    % fill table
    for jx=1:length(myData_AM2(ix).DS_info.ID)
        DS_table_AM2.(['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))])(myData_AM2(ix).DS_info.ID{jx}) = myData_AM2(ix).DS_info.DS(jx);
        Rank_table_AM2.(['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))])(myData_AM2(ix).DS_info.ID{jx}) = myData_AM2(ix).DS_info.Rank(jx);
        DSz_table_AM2.(['D' num2str(ix) 'toD' num2str(ix+(sw_length-1))])(myData_AM2(ix).DS_info.ID{jx}) = myData_AM2(ix).DS_info.DSz(jx);
    end
end

% concatenate tables
DS_table = [DS_table_AM1;DS_table_AM2];
DSz_table = [DSz_table_AM1;DSz_table_AM2];
Rank_table = [Rank_table_AM1;Rank_table_AM2];



% ranks of interest
% for i = 1:size(Rank_table,2)-(sw_length+1)
%     [r(i,1),p(i,1)]=corr(table2array(DS_table(~isnan(table2array(DS_table(:,i))),i)),table2array(DS_table(~isnan(table2array(DS_table(:,i+sw_length))),i+sw_length)));
%     [r(i,2),p(i,2)]=corr(table2array(Rank_table(~isnan(table2array(Rank_table(:,i))),i)),table2array(Rank_table(~isnan(table2array(Rank_table(:,i+sw_length))),i+sw_length)));
%     [r(i,3),p(i,3)]=corr(table2array(DSz_table(~isnan(table2array(DSz_table(:,i))),i)),table2array(DSz_table(~isnan(table2array(DSz_table(:,i+sw_length))),i+sw_length)));
% end

% days_of_scan = [17;22;17;nan;17;22;nan;17;22;22;17;22;22;17;16;15;16;15;16;16;15;15;15;15;16;16];
days_of_scan = [17;22;17;nan;17;22;nan;17;22;22;17;22;22;17;15;15;15;15;15;15;15;15;15;15;15;15];
relevant_pre_days = nan(1,length(days_of_scan));
relevant_post_days = nan(1,length(days_of_scan));
week1_rank = nan(1,length(days_of_scan));
week2_rank = nan(1,length(days_of_scan));
week1_DSz = nan(1,length(days_of_scan));
week2_DSz = nan(1,length(days_of_scan));
pre_rank = nan(1,length(days_of_scan));
post_rank = nan(1,length(days_of_scan));
pre_DSz = nan(1,length(days_of_scan));
post_DSz = nan(1,length(days_of_scan));

% for ix=1:26
%     if ~isnan(days_of_scan(ix))
%         pre_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length));
%         pre_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length));
%         relevant_pre_days(ix) = days_of_scan(ix)-sw_length;
%         post_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)+1));
%         post_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)+1));
%         relevant_post_days(ix) = days_of_scan(ix)+1;
%         random_scan_day(ix,:) = randi([1+sw_length,size(Rank_table,2)-1],10000,1);
%         for jx=1:n_perm
%             random_pre_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)-sw_length));
%             random_post_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)+1));
%         end
%         week1_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-7));
%         week2_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-7*2));
%     end
% end
Rank_table=Rank_table(:,[1:24]);
DSz_table=DSz_table(:,[1:24]);

counter=1;
for ix=1:26
    if ~isnan(days_of_scan(ix))
        if days_of_scan(ix)==15
            pre_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length));
            pre_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length));
            relevant_pre_days(ix) = days_of_scan(ix)-sw_length;
            post_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)+2));
            post_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)+2));
            
            relevant_post_days(ix) = days_of_scan(ix)+2;
            random_scan_day(ix,:) = randi([1+sw_length,size(Rank_table,2)-2],10000,1);
            for jx=1:n_perm
                random_pre_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)-sw_length));
                random_post_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)+2));
            end
            if sw_length==7
                week2_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length));
                week1_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length*2));
                week2_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length));
                week1_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length*2));
            end
            counter=counter+1;
        else
            pre_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length));
            pre_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length));
            relevant_pre_days(ix) = days_of_scan(ix)-sw_length;
            post_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)+1));
            post_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)+2));
            relevant_post_days(ix) = days_of_scan(ix)+1;
            random_scan_day(ix,:) = randi([1+sw_length,size(Rank_table,2)-1],10000,1);
            for jx=1:n_perm
                random_pre_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)-sw_length));
                random_post_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)+1));
            end
            if sw_length==7
                week2_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length));
                week1_rank(ix)=table2array(Rank_table(ix,days_of_scan(ix)-sw_length*2));
                week2_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length));
                week1_DSz(ix)=table2array(DSz_table(ix,days_of_scan(ix)-sw_length*2));
            end
            counter=counter+1;
        end
        random_scan_day(ix,:) = randi([1+sw_length,size(Rank_table,2)-1],10000,1);
        for jx=1:n_perm
            random_pre_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)-sw_length));
            random_post_rank(ix,jx) = table2array(Rank_table(ix,random_scan_day(ix,jx)+1));
        end
    end
end

% Load social hierarchy from Danae
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/05-AM_Danae_cohort1/social_hierarchy_Danae_control_2023.xlsx','Sheet',1,'ReadVariableNames', true);

figure; 
subplot(2,2,1);
axis square
scatter([week1_rank(~isnan(week1_rank))';T.social_rank_1to7],[week2_rank(~isnan(week2_rank))';T.social_rank_8to13]);
lsline;
[r(1),p(1)]=corr([week1_rank(~isnan(week1_rank))';T.social_rank_1to7],[week2_rank(~isnan(week2_rank))';T.social_rank_8to13]);
subplot(2,2,2);
axis square
scatter([week1_DSz(~isnan(week1_DSz))';zscore(T.Davids_score_1to7)],[week2_DSz(~isnan(week2_DSz))';zscore(T.Davids_score_8to13)]);
lsline;
[r(2),p(2)]=corr([week1_DSz(~isnan(week1_DSz))';zscore(T.Davids_score_1to7)],[week2_DSz(~isnan(week2_DSz))';zscore(T.Davids_score_8to13)]);

% % % for jx=1:n_perm
% % %     [r_rand(jx),p_rand(jx)]=corr(random_pre_rank(logical((~isnan(random_pre_rank(:,jx))).*(~isnan(random_post_rank(:,jx)))),jx),random_post_rank(logical((~isnan(random_pre_rank(:,jx))).*(~isnan(random_post_rank(:,jx)))),jx));
% % % end
% % % 
% % % [r,p]=corr(post_rank(logical(~isnan(post_rank).*~isnan(post_rank)))',pre_rank(logical(~isnan(post_rank).*~isnan(post_rank)))');
% % % 
% % % figure; histogram(r_rand,'EdgeColor','none'); ax=gca; hold on; line([r,r],ax.YLim,'Color',[1,0,0])
% % % 
% % % p_value = sum(r_rand<r)./n_perm


%% CORRELATION PRE VS POST-PRE
% % % [r,p]=corr(post_rank(~isnan(post_rank))'-pre_rank(~isnan(post_rank))',pre_rank(~isnan(post_rank))')
% % %
% % %
% % % for i = 1:n_perm
% % %     random_index = randperm(24-1);
% % %     post_rank_reduced = post_rank(~isnan(post_rank));
% % %     pre_rank_reduced = pre_rank(~isnan(post_rank));
% % %     [r_rand(i),p_rand(i)]=corr(post_rank_reduced(random_index)'-pre_rank_reduced',pre_rank_reduced');
% % % end
% % %
% % % figure; histogram(r_rand,'EdgeColor','none'); ax=gca; hold on; line([r,r],ax.YLim,'Color',[1,0,0])


% % % estimate distribution of rank changes when comparing 1-7 to 10-17 (Week
% % % 1, 2 days, Week 2)
% % for i = [1:(22-7)]
% %     [r(i,1),p(i,1)]=corr(DSMat(i,:)',DSMat(i+7,:)');
% %     [r(i,2),p(i,2)]=corr(rankMat(i,:)',rankMat(i+7,:)');
% %     [r(i,3),p(i,3)]=corr(DSzMat(i,:)',DSzMat(i+7,:)');
% % end












