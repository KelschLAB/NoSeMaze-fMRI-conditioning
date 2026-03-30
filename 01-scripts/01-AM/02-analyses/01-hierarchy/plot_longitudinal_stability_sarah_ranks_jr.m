%% Plot longitudinal (across cohort) stability of hierarchy by tube test
%   last edited by David Wolf, 23.11.2023
%
%
%% load dataset
clear;clc;
addpath(genpath('/home/david.wolf/Documents/github/NoSeMaze-hierarchy-main/'));
save_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/plots';
%data_dir = '/zi-flstorage/data/Shared/NoSeMaze/000_hierarchy/DATA/chasing_td15_tt2/';%JR
data_dir = '/zi-flstorage/data/Shared/NoSeMaze/000_hierarchy/DATA/chasing_vs_following/';%JR
meta_data_dir = '/zi-flstorage/data/Sarah/AM-Data/master_matrix.xlsx';
load('/zi-flstorage/data/Shared/NoSeMaze/dataset_for_modeling/gr1-10/data.mat');
data_coh1=data;
load('/zi-flstorage/data/Shared/NoSeMaze/dataset_for_modeling/gr11-21/data.mat');
data_coh2=data;
T = [data_coh1(:,[1,2,4,8,12,13]);data_coh2(:,[1,2,4,8,12,13])];
T(T.Group_ID>19,:)=[];
T(T.Group_ID==16,:)=[];


%% compute and parse rank and David score
for gr = [1:15,17:19]

    % import hierarchy from integrated Tube-Test (ITT)
    load(fullfile(data_dir, ['full_hierarchy_G',num2str(gr),'_10s.mat']))

    %% social
    full_match_matrix = zeros(size(full_hierarchy(1).match_matrix,1),size(full_hierarchy(1).match_matrix,2)); % preallocate matrix to store match matrices that are built one by one and concatenate
    for day = 1:numel(full_hierarchy)
        full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix;        
    end
    % compute hierarchy
    DS_info = compute_DS_from_match_matrix(full_match_matrix);
    [~,current_ranks] = sort(DS_info.DS_sortedIndex);
    
    %% chasing
    full_match_matrix_chasing = zeros(size(full_hierarchy(1).match_matrix_chasing,1),size(full_hierarchy(1).match_matrix_chasing,2)); % preallocate matrix to store match matrices that are built one by one and concatenate
    for day = 1:numel(full_hierarchy)
        full_match_matrix_chasing = full_match_matrix_chasing + full_hierarchy(day).match_matrix_chasing;        
    end
    % compute hierarchy
    DS_info_chasing = compute_DS_from_match_matrix(full_match_matrix_chasing);
    [~,current_ranks_chasing] = sort(DS_info_chasing.DS_sortedIndex);
    
    for an=1:size(full_hierarchy(1).match_matrix,1)
        
       % find index in master matrix
       animal_idx = find(T.Group_ID==gr & contains(T.Mouse_RFID,full_hierarchy(1).ID{an}));
       if ~isempty(animal_idx)
           T.rank(animal_idx) = current_ranks(an);
           T.DS(animal_idx) = DS_info.DS(an);
           T.rank_chasing(animal_idx) = current_ranks_chasing(an);
           T.DS_chasing(animal_idx) = DS_info_chasing.DS(an);
           if contains(T.genotype(animal_idx),'Oxt') && contains(T.genotype(animal_idx),'+')
               T.genotype_code(animal_idx)=1;
           end
           if contains(T.genotype(animal_idx),'Oxt') && ~contains(T.genotype(animal_idx),'+')
               T.genotype_code(animal_idx)=2;
           end
       end
    end
end

%% correlate the first to second repetition

%% 1. social hierarchy
unique_animals = unique(T.Mouse_RFID);
% find how many repetitions one animal did
for an=1:numel(unique_animals)
    repetitions_per_animal(an) = nnz(contains(T.Mouse_RFID,unique_animals(an))); 
    tmp = find(contains(T.Mouse_RFID,unique_animals(an)));
    sort_idx = T.repetition(contains(T.Mouse_RFID,unique_animals(an)));
    repetitions_index{an} = tmp;%(sort_idx);
end
ii = 1; jj = 2;

% find first and second repetition per animal (only animals that did at
% least two repetitions)
rank_first = []; rank_second = [];
for an = 1:numel(unique_animals)
    if numel(repetitions_index{an})>=jj
        rank_first = cat(1,rank_first, T.rank(repetitions_index{an}(ii)));
        rank_second = cat(1,rank_second, T.rank(repetitions_index{an}(jj)));    
    end
end


f = figure;
[rho,pval] = corr(rank_first, rank_second,'type','Pearson');
[rho_sp,pval_sp] = corr(rank_first,rank_second,'type','Spearman');
scatter(rank_first, rank_second,'k','.');
lsline
ax=gca;
axis square;
hold on
A = [rank_first,rank_second];
un_combs = unique(A,'rows');
for ab = 1:size(un_combs,1)
    dot_size = 15*(nnz(sum(A==un_combs(ab,:),2)==2)-1)+3;
    scatter(un_combs(ab,1),un_combs(ab,2),dot_size,'k','filled');
end

ylim([0.1 10.9]);
xlim([0.1 10.9]);
xlabel({'rank',['timepoint ',num2str(ii)]});
ylabel({'rank',['timepoint ',num2str(jj)]});
title({['n = ',num2str(numel(rank_first)),' animals'],['Pearson R = ',num2str(round(rho,2)),'. p = ',num2str(round(pval,3))],...
    ['Spearman R = ',num2str(round(rho_sp,2)),'. p = ',num2str(round(pval_sp,3))]});
set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 4 4];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['tube_rank_correlation_repetition_',num2str(ii),'_to_',num2str(jj),'.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['tube_rank_correlation_repetition_',num2str(ii),'_to_',num2str(jj),]),'-painters','-r400','-append');
close all;



f = figure;
DS_first = []; DS_second = [];
for an = 1:numel(unique_animals)
    if numel(repetitions_index{an}) >=jj
        DS_first = cat(1,DS_first, T.DS(repetitions_index{an}(ii)));
        DS_second = cat(1,DS_second, T.DS(repetitions_index{an}(jj)));    
    end
end
[rho,pval] = corr(DS_first, DS_second,'type','Pearson');
[rho_sp,pval_sp] = corr(DS_first, DS_second,'type','Spearman');
scatter(DS_first, DS_second,'k','.');
ax=gca;
axis square;
lsline        
xlim([1.1*min(DS_first) 1.1*max(DS_first)]);
ylim([1.1*min(DS_second) 1.1*max(DS_second)]);
xlabel({'David score',['timepoint ',num2str(ii)]});
ylabel({'David score',['timepoint ',num2str(jj)]});
title({['n = ',num2str(numel(rank_first)),' animals'],['Pearson R = ',num2str(round(rho,2)),'. p = ',num2str(round(pval,3))],...
    ['Spearman R = ',num2str(round(rho_sp,2)),'. p = ',num2str(round(pval_sp,3))]});
set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 4 4];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['tube_DS_correlation_repetition_',num2str(ii),'_to_',num2str(jj),'.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['tube_DS_correlation_repetition_',num2str(ii),'_to_',num2str(jj),]),'-painters','-r400','-append');
close all;

%% 2. chasing hierarchy
unique_animals = unique(T.Mouse_RFID);
% find how many repetitions one animal did
for an=1:numel(unique_animals)
    repetitions_per_animal(an) = nnz(contains(T.Mouse_RFID,unique_animals(an))); 
    tmp = find(contains(T.Mouse_RFID,unique_animals(an)));
    sort_idx = T.repetition(contains(T.Mouse_RFID,unique_animals(an)));
    repetitions_index{an} = tmp;%(sort_idx);
end
ii = 1; jj = 2;

% find first and second repetition per animal (only animals that did at
% least two repetitions)
rank_first = []; rank_second = [];
for an = 1:numel(unique_animals)
    if numel(repetitions_index{an})>=jj
        rank_first = cat(1,rank_first, T.rank_chasing(repetitions_index{an}(ii)));
        rank_second = cat(1,rank_second, T.rank_chasing(repetitions_index{an}(jj)));    
    end
end


f = figure;
[rho,pval] = corr(rank_first, rank_second,'type','Pearson');
[rho_sp,pval_sp] = corr(rank_first,rank_second,'type','Spearman');
scatter(rank_first, rank_second,'k','.');
lsline
ax=gca;
axis square;
hold on
A = [rank_first,rank_second];
un_combs = unique(A,'rows');
for ab = 1:size(un_combs,1)
    dot_size = 15*(nnz(sum(A==un_combs(ab,:),2)==2)-1)+3;
    scatter(un_combs(ab,1),un_combs(ab,2),dot_size,'k','filled');
end

ylim([0.1 10.9]);
xlim([0.1 10.9]);
xlabel({'rank',['timepoint ',num2str(ii)]});
ylabel({'rank',['timepoint ',num2str(jj)]});
title({['n = ',num2str(numel(rank_first)),' animals'],['Pearson R = ',num2str(round(rho,2)),'. p = ',num2str(round(pval,3))],...
    ['Spearman R = ',num2str(round(rho_sp,2)),'. p = ',num2str(round(pval_sp,3))]});
set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 4 4];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['chasing_rank_correlation_repetition_',num2str(ii),'_to_',num2str(jj),'.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['chasing_rank_correlation_repetition_',num2str(ii),'_to_',num2str(jj),]),'-painters','-r400','-append');
close all;



f = figure;
DS_first = []; DS_second = [];
for an = 1:numel(unique_animals)
    if numel(repetitions_index{an}) >=jj
        DS_first = cat(1,DS_first, T.DS_chasing(repetitions_index{an}(ii)));
        DS_second = cat(1,DS_second, T.DS_chasing(repetitions_index{an}(jj)));    
    end
end
[rho,pval] = corr(DS_first, DS_second,'type','Pearson');
[rho_sp,pval_sp] = corr(DS_first, DS_second,'type','Spearman');
scatter(DS_first, DS_second,'k','.');
ax=gca;
axis square;
lsline        
xlim([1.1*min(DS_first) 1.1*max(DS_first)]);
ylim([1.1*min(DS_second) 1.1*max(DS_second)]);
xlabel({'David score',['timepoint ',num2str(ii)]});
ylabel({'David score',['timepoint ',num2str(jj)]});
title({['n = ',num2str(numel(rank_first)),' animals'],['Pearson R = ',num2str(round(rho,2)),'. p = ',num2str(round(pval,3))],...
    ['Spearman R = ',num2str(round(rho_sp,2)),'. p = ',num2str(round(pval_sp,3))]});
set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 4 4];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['chasing_DS_correlation_repetition_',num2str(ii),'_to_',num2str(jj),'.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['chasing_DS_correlation_repetition_',num2str(ii),'_to_',num2str(jj),]),'-painters','-r400','-append');
close all;




