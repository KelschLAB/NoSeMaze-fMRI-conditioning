%% Plot chasing event distribution within day
%   last edited by David Wolf, 11.12.2023
%
%
%% load dataset
clear;clc;
save_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/plots';
data_dir_am1 = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/';
data_dir_am2 = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/';


%% get daytime of the chasing events

collect_daytime = [];

% import hierarchy from integrated Tube-Test (ITT)
load(fullfile(data_dir_am1, 'full_hierarchy_withChasing.mat'))

for day = 1:numel(full_hierarchy)

    [locx,locy] = find(full_hierarchy(day).match_matrix);
    for dyad = 1:numel(locx)
        for events = 1:numel(full_hierarchy(day).match_info{locx(dyad),locy(dyad)})
            collect_daytime = cat(1,collect_daytime,full_hierarchy(day).match_info{locx(dyad),locy(dyad)}(events).winner_entry_time/3600);
        end
    end
end
   
% import hierarchy from integrated Tube-Test (ITT)
load(fullfile(data_dir_am2, 'full_hierarchy_withChasing.mat'))

for day = 1:numel(full_hierarchy)

    [locx,locy] = find(full_hierarchy(day).match_matrix);
    for dyad = 1:numel(locx)
        for events = 1:numel(full_hierarchy(day).match_info{locx(dyad),locy(dyad)})
            collect_daytime = cat(1,collect_daytime,full_hierarchy(day).match_info{locx(dyad),locy(dyad)}(events).winner_entry_time/3600);
        end
    end
end

%% Plot a simple polar histogram with all events from all animals


f = figure;
h = polarhistogram(collect_daytime*(2*pi/24),24,'Normalization','probability',...
    'FaceColor',[227 30 36]./255,'FaceAlpha',1);
h.EdgeColor = 'k'; %[227 30 36]./255;
h.LineWidth = 1;
axis = gca;
axis.ThetaTickLabel = cellfun(@num2str,num2cell((0:2:22)'),'UniformOutput',0);
axis.FontSize = 6;
set(gcf, 'Units', 'centimeters');
set(gcf, 'Position', [3 3 4.5 3]);
exportgraphics(gcf, fullfile(save_dir,'tube_events_over_daytime_both_AM_combined_all_events.pdf'),'ContentType','vector','BackgroundColor','none');
close all;

% export source data
writetable(array2table(collect_daytime),fullfile(save_dir,'tube_events_over_daytime_both_AM_combined_all_events_source.xlsx'));
