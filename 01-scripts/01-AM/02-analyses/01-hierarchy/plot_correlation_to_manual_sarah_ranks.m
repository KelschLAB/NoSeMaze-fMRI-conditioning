%% save correlation of integrated tube test hierarchy to external tube test
%   last edited by David Wolf, 21.11.2023
%
%
%% load dataset

clear;clc;
addpath(genpath('/home/david.wolf/Documents/github/NoSeMaze-hierarchy-main/'));
save_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/plots';
data_dir = '/zi-flstorage/data/Shared/NoSeMaze/000_hierarchy/DATA/chasing_td15_tt2/';
manual_data_dir = '/zi-flstorage/data/Shared/NoSeMaze/000_hierarchy/manual-TT-correlation/DATA/';

%% loop over Groups
MTT_DS_pooled = []; ITT_1_DS_pooled = []; 
MTT_ranks_pooled = []; ITT_1_ranks_pooled = []; 

for gr = 1:10
    
    % import manual TT (MTT) and calculate DS
    [MTT_match_matrix, MTT_IDs] = import_MTT(fullfile(manual_data_dir,['MTT_G',num2str(gr),'.xlsx']));
    MTT_DS = compute_DS_from_match_matrix(MTT_match_matrix);

    % import hierarchy from integrated Tube-Test (ITT)
    load(fullfile(data_dir,['full_hierarchy_G',num2str(gr),'.mat']));

    % compute DS 
    ITT_match_matrix_1 = sum(cat(3,full_hierarchy.match_matrix),3); %full three weeks
    ITT_DS_1 = compute_DS_from_match_matrix(ITT_match_matrix_1); 
    
    
    %% realign IDs (sort alphabetically)
    ITT_IDs = full_hierarchy(1).ID;
    [ITT_IDs_sorted,sortIndex_ITT]=sort(ITT_IDs);
    ITT_DS_1_sorted = ITT_DS_1.DS(sortIndex_ITT);
    
    if gr==9 % one animal (0007CDEAA7) was taken out during the  experiment (so only 9 remained) --> exclude from correlation because not present in MTT
        ITT_DS_1_sorted(7) = []; 
    end
    
    [MTT_IDs_sorted,sortIndex_MTT]=sort(MTT_IDs);
    MTT_DS_sorted = MTT_DS.DS(sortIndex_MTT);
    
    % pool data across groups
    MTT_DS_pooled = cat(2,MTT_DS_pooled,MTT_DS_sorted); 
    ITT_1_DS_pooled = cat(2,ITT_1_DS_pooled,ITT_DS_1_sorted);  
    
    [~,tmp] = sort(MTT_DS_sorted); 
    [~,MTT_ranks] = sort(tmp);
    MTT_ranks_pooled = cat(2,MTT_ranks_pooled,MTT_ranks); 
    
    [~,tmp] = sort(ITT_DS_1_sorted); 
    [~,ITT_ranks] = sort(tmp);
    ITT_1_ranks_pooled = cat(2,ITT_1_ranks_pooled,ITT_ranks);  
    
    
end
%% Pooled correlation

f=figure;
[rho,pval] = corr(ITT_1_ranks_pooled',MTT_ranks_pooled','type','Pearson');
[rho_sp,pval_sp] = corr(ITT_1_ranks_pooled',MTT_ranks_pooled','type','Spearman');
scatter(ITT_1_ranks_pooled',MTT_ranks_pooled','k','.');
lsline
ax=gca;
axis square;
xlabel({'ranks','(NoSeMaze)'});
ylabel({'ranks', '(manual)'});
title({['Pearson R = ',num2str(rho)],['p = ',num2str(pval)],...
    ['Spearman rho = ',num2str(rho_sp)],['p = ',num2str(pval_sp)]});
set_fonts()
xlim([0 11]);
ylim([0 11]);
f.Units = 'centimeters';
f.Position = [3 3 6 5];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['tube_test_to_manual_corr_ranks.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['tube_test_to_manual_corr_ranks']),'-painters','-r400','-append');

close all;

f=figure;
[rho,pval] = corr(ITT_1_ranks_pooled',MTT_ranks_pooled','type','Pearson');
[rho_sp,pval_sp] = corr(ITT_1_ranks_pooled',MTT_ranks_pooled','type','Spearman');
scatter(ITT_1_ranks_pooled',MTT_ranks_pooled',1,'k','.');
lsline
hold on
A = [ITT_1_ranks_pooled',MTT_ranks_pooled'];
un_combs = unique(A,'rows');
for ii = 1:size(un_combs,1)
    dot_size = 15*(nnz(sum(A==un_combs(ii,:),2)==2)-1)+3;
    scatter(un_combs(ii,1),un_combs(ii,2),dot_size,'k','filled');
end
xlabel({'ranks','(NoSeMaze)'});
ylabel({'ranks', '(manual)'});
title({['Pearson R = ',num2str(rho)],['p = ',num2str(pval)],...
    ['Spearman rho = ',num2str(rho_sp)],['p = ',num2str(pval_sp)]});
ax=gca;
axis square;
ax.XTick = 1:10;
ax.YTick = 1:10;
set_fonts()
xlim([0 11]);
ylim([0 11]);
f.Units = 'centimeters';
f.Position = [3 3 6 5];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['tube_test_to_manual_corr_ranks_circlesize.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['tube_test_to_manual_corr_ranks_circlesize']),'-painters','-r400','-append');

close all;


% export source data
writetable(array2table([ITT_1_ranks_pooled',MTT_ranks_pooled'],'VariableNames',{'NoSeMaze','manual'}),fullfile(save_dir,'tube_test_to_manual_corr_ranks_source.xlsx'));


f=figure;
[rho,pval] = corr(ITT_1_DS_pooled',MTT_DS_pooled','type','Pearson');
[rho_sp,pval_sp] = corr(ITT_1_DS_pooled',MTT_DS_pooled','type','Spearman');
scatter(ITT_1_DS_pooled',MTT_DS_pooled','k','.');
lsline
ax=gca;
axis square;
xlabel({'ranks','(NoSeMaze)'});
ylabel({'ranks', '(manual)'});
title({['Pearson R = ',num2str(rho)],['p = ',num2str(pval)],...
    ['Spearman rho = ',num2str(rho_sp)],['p = ',num2str(pval_sp)]});
set_fonts()
xlim([-45 45]);
ylim([-30 30]);
f.Units = 'centimeters';
f.Position = [3 3 6 5];
% save
[annot, srcInfo] = docDataSrc(f,fullfile(save_dir),mfilename('fullpath'),logical(1));
exportgraphics(f,fullfile(save_dir,['tube_test_to_manual_corr_DS.pdf']),'Resolution',300);
print('-dpsc',fullfile(save_dir,['tube_test_to_manual_corr_DS']),'-painters','-r400','-append');

close all;

% export source data
writetable(array2table([ITT_1_DS_pooled',MTT_DS_pooled'],'VariableNames',{'NoSeMaze','manual'}),fullfile(save_dir,'tube_test_to_manual_corr_DS_source.xlsx'));

%% Functions
function [match_matrix, IDs] = import_MTT(filename)
    
    MTT_table = readtable(filename);
    IDs = MTT_table.Var1;
    
    MTT_table = table2cell(MTT_table(:,2:end));
    match_matrix = zeros(size(MTT_table));
    match_matrix(contains(MTT_table,'W')) = 1;
end
