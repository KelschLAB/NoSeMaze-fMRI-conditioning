%% master_corr_SHandSDVideos_to_GA_CD1famVSCD1unk_22ANIMALS_jr.m
% Reinwald, Jonathan; 16.07.2024

% Info
% - script to correlate behavioral data from the social defeat videos
%   (e.g., distance, time in ROI, escape attempts, ...) and social
%   hierarchy with graph metrics
% - original video data (processed by Marcel) is located in
%   /zi-flstorage/data/Shared/SocialDefeat_Marcel/WrapUP_Meeting/Data_and_Plots
% - combined excel file with the hierarchy and Marcel's data is stored in
%   /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/Behavioral_Data_Social_Defeat.xlsx
%   mat-file in: /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData.mat
% - CAVE: Animal 26 was initially missing

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))

% load behavioral and social hierarchy data
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData_22ANIMALS.mat');

% load graph analysis data
GA_dirName = 'cormat_v2/combined_hemisphere/max_connected';
% GA_dirName = 'cormat_v4/separated_hemisphere/max_connected';
myGADataDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/07-GA/01-gstruct_files/',GA_dirName);
load(fullfile(myGADataDir,'auc_struc_CD1-familiar_4to30_p.mat'));
auc_struc_CD1fam = auc_struc; 
load(fullfile(myGADataDir,'auc_struc_CD1-unknown_4to30_p.mat'));
auc_struc_CD1unk = auc_struc; 
% load(fullfile(myGADataDir,'cormat_v4_CD1-familiar_4to30_p.mat'));
load(fullfile(myGADataDir,'cormat_v2_CD1-familiar_4to30_p.mat'));

% region selection
region_selection = {'VP','Nacc','CP'};
plot_selection{1} = 'VP';
% region_selection = {'Nacc_r','FundStr_r','PallD_r','PallV_r','PallM_r','PallC_r','Nacc_l','FundStr_l','PallD_l','PallV_l','PallM_l','PallC_l',};
% plot_selection = {'FundStr_r','PallV_r','PallM_r','PallC_r','FundStr_l','PallV_l','PallM_l','PallC_l'};

% Correlation type
corrType = 'Pearson';

% output directory
outputDir = fullfile('/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/02-social_defeat/05-GA/01-corr_SocialHierarchyandSDVideos_to_GA/',GA_dirName);
mkdir(outputDir);

%% I.Overview plot

% I.1 Creation of input matrix and correlation
% get variable names
myVariableNames_behav = T.Properties.VariableNames;
% exclude Animal_ID and Animal_Number
myVariableNames_behav = myVariableNames_behav(~contains(myVariableNames_behav,'Animal_ID') & ~contains(myVariableNames_behav,'Animal_Number'));
% reduce table to variables of interest
T_red = T(:, myVariableNames_behav);

% II. graph analytical data
selection = [1:9,11:17,19:24]; %reduces 24 animals to the 22 animals of interest

myGAmetrics = fieldnames(auc_struc);
myLocalMetrics = myGAmetrics(contains(myGAmetrics,'l_') & ~contains(myGAmetrics,{'null','g_'}));
myGlobalMetrics = {'g_cc','g_cc_norm','g_cpl','g_swi','g_modularity','g_swp','g_delta_L','g_delta_C'};
T_GA = table();

for metric_idx = 1:length(myGlobalMetrics)    
    myMetric = [auc_struc.(myGlobalMetrics{metric_idx})]';
    T_GA = [T_GA,table(myMetric(selection),'VariableNames',{myGlobalMetrics{metric_idx}})];    
end

for metric_idx = 1:length(myLocalMetrics)    
    for region_idx = 1:length(region_selection)
        myMetric_CD1fam = [auc_struc_CD1fam.(myLocalMetrics{metric_idx})]';
        myMetric_CD1unk = [auc_struc_CD1unk.(myLocalMetrics{metric_idx})]';
        myMetric = myMetric_CD1fam-myMetric_CD1unk;
        T_GA = [T_GA,table(myMetric(selection,strcmp(names,region_selection{region_idx})),'VariableNames',{['Diff_' myLocalMetrics{metric_idx} '_' region_selection{region_idx}]})];
    end
end

% create matrix out of table
myMat_behavior = T_red{:,:};
myMat_GA = T_GA{:,:};

% get variable names
myVariableNames_GA = T_GA.Properties.VariableNames;

% correlation analysis
[rho_mat,p_mat]=corr(myMat_behavior,myMat_GA,'type',corrType);

% I.2 Plot
% figure
fig(1)=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);

% plot
imagesc(rho_mat);

% axes
ax=gca;
% axis square;
box(ax,'on');
set(gca,'TickLabelInterpreter','none');
ax.CLim=[-1,1];
ax.Colormap=jet;
cbar = colorbar;
cbar.Label.String=[corrType 's r'];

ax.XTick=[1:1:size(rho_mat,2)];
ax.XTickLabel=myVariableNames_GA
ax.YTick=[1:1:size(rho_mat)];
ax.YTickLabel=myVariableNames_behav;
rotateXLabels(ax,90);

% Mark significant  p-values
for x=1:size(rho_mat,1)
    for y=1:size(rho_mat,2) %size(T,2);
        if p_mat(x,y)<.1
            yv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];xv=[y-.5 y+.5 y+.5 y-.5 y-.5];
            line(xv,yv,'linewidth',1,'color',[0 0 0]);
            tx=text((y-1)+.5,x+.5,sprintf('%0.3f',p_mat(x,y)),'color',[0 0 0], ...
                'fontsize',5);
            tx.Rotation=45;
        end
    end
end

% title
title('correlation matrix SD vids/hierarchy');

% print
[annot, srcInfo] = docDataSrc(fig(1),outputDir,mfilename('fullpath'),logical(1))
exportgraphics(fig(1),fullfile(outputDir,['correlation_matrix_DiffCD1famVSCD1unk_SDVideosToNoSeMaze_22animals_' corrType '.pdf']),'ContentType','vector','BackgroundColor','none','Resolution',300);
exportgraphics(fig(1),fullfile(outputDir,['correlation_matrix_DiffCD1famVSCD1unk_SDVideosToNoSeMaze_22animals_' corrType '.png']),'ContentType','vector','BackgroundColor','none','Resolution',300);
% print('-dpsc',fullfile(outputDir,['correlation_matrix_SDVideosToNoSeMaze_22animals']),'-painters','-r400','-bestfit');
close all;

%% II. Individual plots
selection_xAxis = myVariableNames_behav(contains(myVariableNames_behav,'Rank') | contains(myVariableNames_behav,'DS') | contains(myVariableNames_behav,'Zscored'));
for idx = 1:length(plot_selection)
    selection_yAxis{idx} = myVariableNames_GA(contains(myVariableNames_GA,plot_selection{idx}));
end

% loop over x-axis selection
for ix = 1:length(selection_xAxis)
    % loop over y-axis selection
    for iy=1:length(selection_yAxis)
        
        % figure
        fig(2)=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);
        [annot, srcInfo] = docDataSrc(fig(2),outputDir,mfilename('fullpath'),logical(1))
        
        % loop over subplots
        for subpl=1:(length(selection_yAxis{iy}))
        
            % subplot (summary)
            subplot(3,3,subpl)
            % define y-input
            clear y_input
            y_input=T_GA{:,selection_yAxis{iy}{subpl}};
            % scatter
            sc=scatter(T{:,selection_xAxis{ix}},y_input);
            sc.MarkerEdgeColor='none';
            sc.MarkerFaceColor=[0,0,0];%[.8,.4,.4];
            % axes
            axis square;
        
            ax=gca;
            %             axis square;
            box(ax,'off');
            set(gca,'TickLabelInterpreter','none');
            ax.XLabel.String=selection_xAxis{ix};
            ax.YLabel.String=selection_yAxis{iy}{subpl};
            ax.YLabel.Interpreter='none';
            ax.LineWidth=1.5;
            % ax.FontWeight='bold';
            ax.FontSize=14;
            % correlation line
            ll=lsline(ax);
            ll.Color=[0,0,0];%[.8,.4,.4];
            ll.LineWidth=1.5;
            % plot correlation value
            clear r p
            [r,p]=corr(T{:,selection_xAxis{ix}},y_input);
            tx1=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(p,2))]);
            tx2=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['r=' num2str(round(r,2))]);
            clear r p
            [r,p]=corr(T{:,selection_xAxis{ix}},y_input,'type','Spearman');
            tx1=text(ax.XLim(1)+diff(ax.XLim)*0.5,ax.YLim(1)+diff(ax.YLim)*0.1,['psp=' num2str(round(p,2))]);
            tx2=text(ax.XLim(1)+diff(ax.XLim)*0.5,ax.YLim(1)+diff(ax.YLim)*0.2,['rsp=' num2str(round(r,2))]);
        end

        % print
        strfind_ = strfind(selection_yAxis{iy}{1},'_');
        exportgraphics(fig(2),fullfile(outputDir,['scatters_CD1famVSCD1unk_' selection_xAxis{ix} 'ToGA_' selection_yAxis{iy}{1}(strfind_(2)+1:end) '_' corrType '_22animals.pdf']),'ContentType','vector','BackgroundColor','none','Resolution',300);
        exportgraphics(fig(2),fullfile(outputDir,['scatters_CD1famVSCD1unk_' selection_xAxis{ix} 'ToGA_' selection_yAxis{iy}{1}(strfind_(2)+1:end) '_' corrType '_22animals.png']),'ContentType','vector','BackgroundColor','none','Resolution',300);
        % print('-dpsc',fullfile(outputDir,['scatters_' selection_xAxis{ix} 'To' selection_yAxis{iy}{1}(1:end-2) '_22animals']),'-painters','-r400','-bestfit');
        close all;
    end
end
