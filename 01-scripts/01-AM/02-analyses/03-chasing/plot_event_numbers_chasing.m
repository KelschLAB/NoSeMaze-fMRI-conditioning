%% Plot chasing event distribution across days
%   last edited by David Wolf, 11.12.2023
%
%
%% load dataset
clear;clc;
save_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/plots';
data_dir_am1 = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/';
data_dir_am2 = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/';


%% loop over groups and collect number of chasing events

collect_chasing = [];

% import hierarchy from integrated Tube-Test (ITT)
load(fullfile(data_dir_am1, 'full_hierarchy_withChasing.mat'))

for day = 1:numel(full_hierarchy)

    [locx,locy] = find(full_hierarchy(day).match_matrix_chasing);
    collect_chasing = cat(1,collect_chasing,numel(locx));
end
   
% import hierarchy from integrated Tube-Test (ITT)
load(fullfile(data_dir_am2, 'full_hierarchy_withChasing.mat'))

for day = 1:numel(full_hierarchy)

    [locx,locy] = find(full_hierarchy(day).match_matrix_chasing);
    collect_chasing = cat(1,collect_chasing,numel(locx));
end

%% plot mean and sem total chasing events per day over time



f = figure;
histogram(collect_chasing,'Normalization','probability','FaceColor',[.5 .5 .5],'BinWidth',2);
ylabel('probability','FontSize',6);
xlabel({'number of detected','events per day'},'FontSize',6);
title('chasing','FontSize',8);
set(gca, 'FontSize', 6);
box('off')
f.Units = 'centimeters';
f.Position = [3 3 4 4];

exportgraphics(gcf, fullfile(save_dir,'chasing_number_of_events_both_AM_combined.pdf'),'ContentType','vector','BackgroundColor','none');

% export source data
writetable(array2table(collect_chasing),fullfile(save_dir,'chasing_number_of_events_both_AM_combined_source.xlsx'));

