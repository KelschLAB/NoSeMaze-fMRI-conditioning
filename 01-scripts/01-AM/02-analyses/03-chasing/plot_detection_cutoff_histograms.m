%% Plot time cutoff for chasing events rationale
%   last edited by David Wolf, 04.12.2023
%
%
%% load dataset

clear; close all; clc;
addpath(genpath('/home/david.wolf/Documents/github/NoSeMaze-hierarchy-main/'));
save_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/plots/';
data_dir_am1 = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/';
data_dir_am2 = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/';


%% compute and parse rank and David score from chase events
tt_win = []; tt_los = []; td_entry = []; td_exit = [];


% import data
load(fullfile(data_dir_am1, 'full_hierarchy_withChasing.mat'))

for day = 1:numel(full_hierarchy)

    % find events. Cave in the dataset there are typos in the extracted
    % values for chasing! Fix that in the future...
    [win,los] = find(full_hierarchy(day).match_matrix_chasing);
    for ww = 1:numel(win)
       for ee = 1:numel(full_hierarchy(day).match_info_chasing{win(ww),los(ww)})
           tt_win = cat(1,tt_win,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_exit_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_entry_time);
           tt_los = cat(1,tt_los,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_exit_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_entry_time);
           td_entry = cat(1,td_entry,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_entry_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_entry_time);
           td_exit = cat(1,td_exit,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_exit_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_exit_time);

       end           
    end
end

% import data AM2
load(fullfile(data_dir_am2, 'full_hierarchy_withChasing.mat'))

for day = 1:numel(full_hierarchy)

    % find events. Cave in the dataset there are typos in the extracted
    % values for chasing! Fix that in the future...
    [win,los] = find(full_hierarchy(day).match_matrix_chasing);
    for ww = 1:numel(win)
       for ee = 1:numel(full_hierarchy(day).match_info_chasing{win(ww),los(ww)})
           tt_win = cat(1,tt_win,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_exit_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_entry_time);
           tt_los = cat(1,tt_los,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_exit_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_entry_time);
           td_entry = cat(1,td_entry,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_entry_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_entry_time);
           td_exit = cat(1,td_exit,full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).loser_exit_time-...
               full_hierarchy(day).match_info_chasing{win(ww),los(ww)}(ee).winner_exit_time);

       end           
    end
end


% remove artifacts
exclude = abs(tt_win)<0 | abs(tt_los)<0 | abs(td_entry)<0 | abs(td_exit)<0;
tt_win(exclude)=[]; tt_los(exclude)=[]; td_entry(exclude)=[]; td_exit(exclude)=[];

td_entry = abs(td_entry);
td_exit = abs(td_exit);

%% plot

f=figure;
hold on;
h=histogram(td_entry,'BinWidth',.1,'FaceColor',[0 51 153]./255,'Normalization','probability')
histogram(td_exit,'BinWidth',.1,'FaceColor',[51 204 102]./255,'Normalization','probability')
line([1.5 1.5],[0 0.4],'LineStyle','--','Color','k')
xlim([0 2]);
legend({'at entry','at exit'},'Location','eastoutside');
legend('boxoff');
ylabel('probability');
xlabel('\Delta time at detector (s)');
set_fonts();
f.Units = 'centimeters';
f.Position = [3 3 6 3];
exportgraphics(f,fullfile(save_dir,'chasing_time_cutoff_detector.pdf'));
writetable(array2table([td_entry,td_exit],'VariableNames',{'td_entry','td_exit'}),fullfile(save_dir,'chasing_time_cutoff_detector_source.xlsx'));
close all;

f=figure;
hold on;
histogram(abs(tt_win),'BinWidth',.1,'FaceColor',[0 51 153]./255,'Normalization','probability')
histogram(abs(tt_los),'BinWidth',.1,'FaceColor',[51 204 102]./255,'Normalization','probability')
line([2 2],[0 0.25],'LineStyle','--','Color','k')
xlim([0 2.5]);
legend({'winner','loser'},'Location','eastoutside');
legend('boxoff');
ylabel('probability');
xlabel('\Delta time through tube (s)');
set_fonts();
f.Units = 'centimeters';
f.Position = [3 3 6 3];
exportgraphics(f,fullfile(save_dir,'chasing_time_cutoff_through.pdf'));
writetable(array2table([tt_win,tt_los],'VariableNames',{'tt_win','tt_los'}),fullfile(save_dir,'chasing_time_cutoff_through_source.xlsx'));
close all;


