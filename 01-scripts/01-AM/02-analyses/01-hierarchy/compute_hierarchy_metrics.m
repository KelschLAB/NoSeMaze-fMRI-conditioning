%% Compute linearity, steepness and triangle transitivity for the full networks
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
addpath(genpath('/zi-flstorage/data/Shared/NoSeMaze/000_hierarchy/code for figures/functions/'));

%%
for gr=1:2; data{gr} = load(fullfile(data_dir{gr}, 'full_hierarchy_withChasing.mat'),'full_hierarchy'); end
output = struct;

%%%%%
% AM1 days 3-16
%%%%%
full_hierarchy = data{1}.full_hierarchy;
disp(['Tube test AM1. Days to consider: 3-16']);
output(1).info = 'AM1 days 3-16';    

% tube test hierarchy
full_match_matrix = zeros(size(full_hierarchy(3).match_matrix_misaligned)); % preallocate matrix to store match matrices that are built one by one and concatenate
for day = 3:16
    full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix_misaligned;        
end
DS_info = compute_DS_from_match_matrix_corrected_for_chance(full_match_matrix);

% compute steepness (quantifies "dominance success")
DS_info_normalized = normalize_DS(DS_info);
output(1).steepness_tt = compute_hierarchy_steepness(DS_info_normalized.DS_sorted);
output(1).steepness_tt_pvalue = test_steepness_significance(full_match_matrix);

% compute linearity (quantifies transitivity)
[output(1).h_unbiased_tt, output(1).h_unbiased_tt_pvalue] = compute_linearity(full_match_matrix);

% compute triad transitivity significance with permutation test
% binarize matrix where the dominant is 1, mutual dyads both are 1
bin_matrix  = round(full_match_matrix./(full_match_matrix+full_match_matrix'));
bin_matrix(isnan(bin_matrix)) = 0;
[triadCounts, n_triangle] = triadCensus(bin_matrix);
output(1).t_tri_tt = compute_triangle_transitivity(triadCounts, n_triangle);
output(1).t_tri_tt_pvalue = compute_triangle_transitivity_pvalue(bin_matrix);

    
% chasing
disp(['Chasing AM1. Days to consider: 3-16']);
include = [1:3,5,6,8:14];
full_match_matrix = zeros(size(full_match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
for day = 3:16
    full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix_chasing(include,include);        
end
DS_info = compute_DS_from_match_matrix_corrected_for_chance(full_match_matrix);

% compute steepness (quantifies "dominance success")
DS_info_normalized = normalize_DS(DS_info);
output(1).steepness_ch = compute_hierarchy_steepness(DS_info_normalized.DS_sorted);
output(1).steepness_ch_pvalue = test_steepness_significance(full_match_matrix);

% compute linearity (quantifies transitivity)
[output(1).h_unbiased_ch, output(1).h_unbiased_ch_pvalue] = compute_linearity(full_match_matrix);

% compute triangle transitivity
bin_matrix  = round(full_match_matrix./(full_match_matrix+full_match_matrix'));
bin_matrix(isnan(bin_matrix)) = 0;
[triadCounts, n_triangle] = triadCensus(bin_matrix);
output(1).t_tri_ch = compute_triangle_transitivity(triadCounts, n_triangle);
output(1).t_tri_ch_pvalue = compute_triangle_transitivity_pvalue(bin_matrix);

%%%%%
% AM2 days 1-14
%%%%%
full_hierarchy = data{2}.full_hierarchy;
disp(['Tube test AM2. Days to consider: 1-14']);
output(2).info = 'AM2 days 1-14';    

% tube test hierarchy
full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
for day = 1:14
    full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix;        
end
DS_info = compute_DS_from_match_matrix_corrected_for_chance(full_match_matrix);

% compute steepness (quantifies "dominance success")
DS_info_normalized = normalize_DS(DS_info);
output(2).steepness_tt = compute_hierarchy_steepness(DS_info_normalized.DS_sorted);
output(2).steepness_tt_pvalue = test_steepness_significance(full_match_matrix);

% compute linearity (quantifies transitivity)
[output(2).h_unbiased_tt, output(2).h_unbiased_tt_pvalue] = compute_linearity(full_match_matrix);

% compute triad transitivity significance with permutation test
% binarize matrix where the dominant is 1, mutual dyads both are 1
bin_matrix  = round(full_match_matrix./(full_match_matrix+full_match_matrix'));
bin_matrix(isnan(bin_matrix)) = 0;
[triadCounts, n_triangle] = triadCensus(bin_matrix);
output(2).t_tri_tt = compute_triangle_transitivity(triadCounts, n_triangle);
output(2).t_tri_tt_pvalue = compute_triangle_transitivity_pvalue(bin_matrix);

    
% chasing
disp(['Chasing AM2. Days to consider: 1-14']);

full_match_matrix = zeros(size(full_hierarchy(1).match_matrix)); % preallocate matrix to store match matrices that are built one by one and concatenate
for day = 1:14
    full_match_matrix = full_match_matrix + full_hierarchy(day).match_matrix_chasing;        
end
DS_info = compute_DS_from_match_matrix_corrected_for_chance(full_match_matrix);

% compute steepness (quantifies "dominance success")
DS_info_normalized = normalize_DS(DS_info);
output(2).steepness_ch = compute_hierarchy_steepness(DS_info_normalized.DS_sorted);
output(2).steepness_ch_pvalue = test_steepness_significance(full_match_matrix);

% compute linearity (quantifies transitivity)
[output(2).h_unbiased_ch, output(2).h_unbiased_ch_pvalue] = compute_linearity(full_match_matrix);

% compute triangle transitivity
bin_matrix  = round(full_match_matrix./(full_match_matrix+full_match_matrix'));
bin_matrix(isnan(bin_matrix)) = 0;
[triadCounts, n_triangle] = triadCensus(bin_matrix);
output(2).t_tri_ch = compute_triangle_transitivity(triadCounts, n_triangle);
output(2).t_tri_ch_pvalue = compute_triangle_transitivity_pvalue(bin_matrix);



save(fullfile(save_dir,'hierarchy_metrics_grouplevel.mat'),'output');
writetable(struct2table(output),fullfile(save_dir,'hierarchy_metrics_grouplevel.xlsx'));


% X = array2table([steepness_tt',p_steep_ch', h_unbiased_tt', p_random_tt', t_tri_tt', p_tt', ...
%     steepness_ch',p_steep_ch', h_unbiased_ch', p_random_ch', t_tri_ch', p_ch'],...
%     'VariableNames',{'steepness_tube','steepness_pval_tube','Lindau_h_tube','Lindau_pval_tube','triangle_tube','triangle_p_tube',...
%     'steepness_chasing','steepness_pval_chasing','Lindau_h_chasing','Lindau_pval_chasing','triangle_chasing','triangle_p_chasing'});
% writetable(X, fullfile(save_dir,'hierarchy_metrics_grouplevel.xlsx'));
