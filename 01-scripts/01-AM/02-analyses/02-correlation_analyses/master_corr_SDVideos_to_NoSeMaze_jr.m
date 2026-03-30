%% master_corr_SDVideos_to_NoSeMaze_jr.m
% Reinwald, Jonathan; 22.02.2023

% Info
% - script to correlate behavioral data from the social defeat videos
%   (e.g., distance, time in ROI, escape attempts, ...) with social hierarchy
% - original video data (processed by Marcel) is located in
%   /zi-flstorage/data/Shared/SocialDefeat_Marcel/WrapUP_Meeting/Data_and_Plots
% - combined excel file with the hierarchy and Marcel's data is stored in
%   /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/Behavioral_Data_Social_Defeat.xlsx
%   mat-file in: /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData.mat
% - CAVE: Animal 26 is missing

%% Preparation
% clear all;
% close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))

% Load data
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData_22ANIMALS.mat');

% output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/05-social_defeat_videos';

%% I.Overview plot

% add additional metrics
% T=[T,table(T.ROI_Front_1./T.ROI_Back_1,'VariableNames',{'FtoB1'})];
% T=[T,table(T.ROI_Front_2./T.ROI_Back_2,'VariableNames',{'FtoB2'})];
% T=[T,table(T.ROI_Front_3./T.ROI_Back_3,'VariableNames',{'FtoB3'})];
% T=[T,table(T.ROI_Front_3+T.ROI_Front_2+T.ROI_Front_1,'VariableNames',{'FrontAll'})];
% T=[T,table(T.ROI_Back_1+T.ROI_Back_2+T.ROI_Back_3,'VariableNames',{'BackAll'})];
% T=[T,table((T.ROI_Front_3+T.ROI_Front_2+T.ROI_Front_1)./(T.ROI_Back_1+T.ROI_Back_2+T.ROI_Back_3),'VariableNames',{'FtoB_Aall'})];

% I.1 Creation of input matrix and correlation
% get variable names
myVariableNames = T.Properties.VariableNames;
% exclude Animal_ID and Animal_Number
myVariableNames = myVariableNames(~contains(myVariableNames,'Animal_ID') & ~contains(myVariableNames,'Animal_Number'));
% reduce table to variables of interest
T_red = T(:, myVariableNames);
% create matrix out of table
myMat = T_red{:,:};
% correlation analysis
[rho_mat,p_mat]=corr(myMat,myMat,'type','Spearman');

% I.2 Plot
% figure
fig(1)=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);

% plot
imagesc(rho_mat);

% axes
ax=gca;
axis square;
box(ax,'on');
set(gca,'TickLabelInterpreter','none');
ax.CLim=[-1,1];
ax.Colormap=jet;
cbar = colorbar;
cbar.Label.String=['Pearsons rho'];

ax.XTick=[1:1:size(rho_mat)];
ax.XTickLabel=myVariableNames;
ax.YTick=[1:1:size(rho_mat)];
ax.YTickLabel=myVariableNames;
rotateXLabels(ax,90);

% Mark significant  p-values
for x=1:size(rho_mat,1)
    for y=x:size(rho_mat,2) %size(T,2);
        if (x == y)
            xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
            patch(xv,yv,[1 1 1])
        end
        if p_mat(y,x)<.05
            xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
            line(xv,yv,'linewidth',1,'color',[0 0 0]);
            tx=text((x-1)+.5,y+.5,sprintf('%0.3f',p_mat(y,x)),'color',[0 0 0], ...
                'fontsize',5);
            tx.Rotation=45;
        end
    end
end

% title
title('correlation matrix SD vids/hierarchy');

% print
[annot, srcInfo] = docDataSrc(fig(1),outputDir,mfilename('fullpath'),logical(1))
exportgraphics(fig(1),fullfile(outputDir,['correlation_matrix_SDVideosToNoSeMaze_22animals.pdf']),'ContentType','vector','BackgroundColor','none','Resolution',300);
print('-dpsc',fullfile(outputDir,['correlation_matrix_SDVideosToNoSeMaze_22animals']),'-painters','-r400','-bestfit');
close all;


%% II. Individual plots
selection_xAxis = myVariableNames(contains(myVariableNames,'Rank') | contains(myVariableNames,'DS'));
% selection_yAxis{1} = myVariableNames(contains(myVariableNames,'Front'));
% selection_yAxis{2} = myVariableNames(contains(myVariableNames,'Back'));
% selection_yAxis{3} = myVariableNames(contains(myVariableNames,'Dist_Median'));
% selection_yAxis{4} = myVariableNames(contains(myVariableNames,'Dist_Mean'));
% selection_yAxis{5} = myVariableNames(contains(myVariableNames,'Dist_SD'));
selection_yAxis{1} = myVariableNames(contains(myVariableNames,'Dist_Median'));
selection_yAxis{2} = myVariableNames(contains(myVariableNames,'FtoB_Aall'));

% loop over x-axis selection
for ix = 1:length(selection_xAxis)
    % loop over y-axis selection
    for iy=1:length(selection_yAxis)
        
        % figure
        fig(2)=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);
        
        % loop over subplots
        for subpl=1:(length(selection_yAxis{iy}))
            % subplot (summary)
            subplot(2,2,subpl);
            % define y-input
            clear y_input
            y_input=T{:,selection_yAxis{iy}{subpl}};
            % scatter
            sc=scatter(T{:,selection_xAxis{ix}},y_input);
            sc.MarkerEdgeColor='none';
            sc.MarkerFaceColor=[.8,.4,.4];
            % axes
            ax=gca;
%             axis square;
            box(ax,'on');
            set(gca,'TickLabelInterpreter','none');
            ax.XLabel.String=selection_xAxis{ix};
            ax.YLabel.String=selection_yAxis{iy}{subpl};
            ax.YLabel.Interpreter='none';
            ax.LineWidth=1.5;
            ax.FontWeight='bold';
            % correlation line
            ll=lsline(ax);
            ll.Color=[.8,.4,.4];
            ll.LineWidth=1.5;
            % plot correlation value
            clear r p
            [r,p]=corr(T{:,selection_xAxis{ix}},y_input);
            tx1=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(p,2))]);
            tx2=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['r=' num2str(round(r,2))]);            
        end
        
        % print
        [annot, srcInfo] = docDataSrc(fig(2),outputDir,mfilename('fullpath'),logical(1))
        exportgraphics(fig(2),fullfile(outputDir,['scatters_' selection_xAxis{ix} 'To' selection_yAxis{iy}{1}(1:end-2) '_22animals.pdf']),'ContentType','vector','BackgroundColor','none','Resolution',300);
        print('-dpsc',fullfile(outputDir,['scatters_' selection_xAxis{ix} 'To' selection_yAxis{iy}{1}(1:end-2) '_22animals']),'-painters','-r400','-bestfit');
        close all;
    end
end





















