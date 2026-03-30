%% master_plot_SDVideosBehavior_22ANIMALS_jr.m
% Reinwald, Jonathan; 22.02.2023

% Info
% - script to plot behavioral data from the social defeat videos
%   (e.g., distance, time in ROI, escape attempts, ...)
% - original video data (processed by Marcel) is located in
%   /zi-flstorage/data/Shared/SocialDefeat_Marcel/WrapUP_Meeting/Data_and_Plots
% - combined excel file with the hierarchy and Marcel's data is stored in
%   /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/Behavioral_Data_Social_Defeat.xlsx
%   mat-file in: /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData.mat
% - CAVE: Animal 26 was initially missing; from this animal, escape
% attempts are still missing

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))

% Load data
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData_22ANIMALS.mat');

% output directory
outputDir = '/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/05-social_defeat_videos';

% plot selection
VarNames = T.Properties.VariableNames;
selection_vector{1} = contains(VarNames,'Back') & ~contains(VarNames,'All');
selection_name{1} = 'time in back';
selection_abbrev{1} = 'back';
selection_vector{2} = contains(VarNames,'Center') & ~contains(VarNames,'All');
selection_name{2} = 'time in center';
selection_abbrev{2} = 'center';
selection_vector{3} = contains(VarNames,'Front') & ~contains(VarNames,'All');
selection_name{3} = 'time in front';
selection_abbrev{3} = 'front';
selection_vector{4} = contains(VarNames,'FtoB') & ~contains(VarNames,'All');
selection_name{4} = 'front to back';
selection_abbrev{4} = 'FtoB';
selection_vector{5} = contains(VarNames,'Dist_Median') & ~contains(VarNames,'all');
selection_name{5} = 'median distance';
selection_abbrev{5} = 'MedianDist';
selection_vector{6} = contains(VarNames,'Dist_Mean') & ~contains(VarNames,'all');
selection_name{6} = 'mean distance';
selection_abbrev{6} = 'MeanDist';


% figure
fig(1)=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);

% loop over subplots
for idx=1:(length(selection_name))
    
    % subplot (summary)
    subplot(2,3,idx);
    
    % define input data
    clear myData
    myData = table2array(T(:,selection_vector{idx}));
    bb = notBoxPlot_modified_pupilANDlid(myData);
    for ib=1:length(bb)
        bb(ib).data.MarkerSize=6;
        bb(ib).data.MarkerEdgeColor='none';
        bb(ib).semPtch.EdgeColor='none';
        bb(ib).sdPtch.EdgeColor='none';
        % color definitions
        bb(ib).data.MarkerFaceColor= [204/255 51/255 204/255];
        bb(ib).mu.Color= [204/255 51/255 204/255];
        bb(ib).semPtch.FaceColor= [255/255 102/255 204/255];
        bb(ib).sdPtch.FaceColor= [255/255 204/255 204/255];
    end
    
    % axes
    ax=gca;
    box(ax,'off');
    set(gca,'TickLabelInterpreter','none');
    ax.XLabel.String={'social defeat round'};
    if idx < 4
        ax.YLabel.String={selection_name{idx},'(fraction)'};
    elseif idx == 4
        ax.YLabel.String={selection_name{idx},'(fraction)'};
    elseif idx > 4
        ax.YLabel.String={selection_name{idx},'(cm)'};
    end
    ax.YLabel.Interpreter='none';
    ax.XTickLabel=[1:3];
    ax.LineWidth=1.5;
    % ax.FontWeight='bold';
    ax.FontSize=14;
    
    % statistics
    animal = [[1:22]';[1:22]';[1:22]'];
    rounds=[ones(22,1);2*ones(22,1);3*ones(22,1)];
    myTable(idx).input = table([myData(:,1);myData(:,2);myData(:,3)],animal,rounds,'VariableNames',{'meas','animal','rounds'});
    myTable(idx).input.animal = categorical(myTable(idx).input.animal);
    myTable(idx).input.rounds = categorical(myTable(idx).input.rounds);
    % fit linear mixed effects model (% choosing between individual
    % slopes for all animals (block|animal) or on slope (1|animal),
    % see also:
    % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
    % ( The Importance of Random Slopes in Mixed Models for Bayesian
    % Hypothesis Testing, Klaus Oberauer)
    lme = fitlme(myTable(idx).input,'meas ~ 1 + rounds + (1|animal)');
    
    tx1=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(double(lme.Coefficients(2,6)),4))]);
    tx2=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['est=' num2str(round(double(lme.Coefficients(2,2)),4))]);
    tx1=text(ax.XLim(1)+diff(ax.XLim)*0.5,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(double(lme.Coefficients(3,6)),4))]);
    tx2=text(ax.XLim(1)+diff(ax.XLim)*0.5,ax.YLim(1)+diff(ax.YLim)*0.2,['est=' num2str(round(double(lme.Coefficients(3,2)),4))]);
    
    % titlw
    tt=title(selection_name{idx});
end

% print
[annot, srcInfo] = docDataSrc(fig(1),outputDir,mfilename('fullpath'),logical(1))
exportgraphics(fig(1),fullfile(outputDir,['SocialDefeat_Behavior_22animals.pdf']),'ContentType','vector','BackgroundColor','none','Resolution',300);
exportgraphics(fig(1),fullfile(outputDir,['SocialDefeat_Behavior_22animals.png']),'ContentType','vector','BackgroundColor','none','Resolution',300);
% print('-dpsc',fullfile(outputDir,['scatters_' selection_xAxis{ix} 'To' selection_yAxis{iy}{1}(1:end-2) '_22animals']),'-painters','-r400','-bestfit');