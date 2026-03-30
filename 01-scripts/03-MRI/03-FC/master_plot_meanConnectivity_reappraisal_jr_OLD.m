%% master_plot_meanConnectivity_reappraisal_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Preferences 
% blocks
block_selection{1}='Odor1to10';
block_selection{2}='TPnoPuff1to10';
block_selection{3}='Odor11to40';
block_selection{4}='TPnoPuff11to40';
block_selection{5}='Odor81to120';
block_selection{6}='TPnoPuff81to120';
% graph metrics
selected_metrics = {'degree','strength','bci','cc'};
% range for thresholds
thresh_range=[1:41];
% color
histogram_color={[102/255,102/255,204/255];[0,1,1];[102/255,102/255,204/255];[0,1,1];[102/255,102/255,204/255];[0,1,1]};
% y-axis limits
yaxis_lim={[0,2500],[0,4500],[0,5000],[0,10000]};
% binwidth
binwidth=[1,1,100,0.025];

%% Selection of input
% cormat version
cormat_version = 'cormat_v11';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'bin'; % 'max'
connectedness = 'connected';
% input directories
inputDir_GA = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];

%% Output directory
outputdir=['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version '/combined_hemisphere/' binarization_method '_' connectedness '/histograms_localMetrics'];
if ~exist(outputdir)
    mkdir(outputdir)
end

%% Data compilation
% Loop over current metric (degree, strength, ...)
for curr_metricID = 1:length(selected_metrics)
    % set figure
    fig(curr_metricID)=figure;
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
    % predefine subfigure
    subfig=1;
    
    % Loop over blocks
    for bl=1:length(block_selection)
        % load gstruc-file
        load(fullfile(inputDir_GA,['gstruc_' block_selection{bl} '_p.mat']));
        
        % Loop over thresholds
        for thr=thresh_range
            
            % Loop over subjects
            for subj=1:size(gstruc,2)
                % Fieldnames
                myFieldnames = fieldnames(gstruc);
                % Condition: only when metrics exists
                if any(strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}]))
                    % fill data in 
                    myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(thr,subj,:)=gstruc(thr,subj).(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])});
                else
                    % close figure if no metrics (for strength)
                    if ishandle(fig(curr_metricID))
                        close(fig(curr_metricID));
                    end
                end
                
            end
        end
        
        %% Plotting for the metrics
        % if metric exist
        if any(strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}]))
            
            % subplots
            if bl==1 || bl==3 || bl==5
                subplot(1,3,subfig);
                counter=1;
                if bl==1 || bl==3
                    subfig=subfig+1;
                end
            end
            
            % histogram
            hh(counter)=histogram(myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(:),'BinWidth',binwidth(curr_metricID));
            box off
            % color definition
            hh(counter).EdgeColor='none';
            hh(counter).FaceColor=histogram_color{bl};
            hh(counter).FaceAlpha=0.5;           
            hold on;
            hh2(counter)=histogram(myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(:),'BinWidth',binwidth(curr_metricID),'DisplayStyle','stairs');
            hh2(counter).EdgeColor=histogram_color{bl};
            hh2(counter).EdgeColor=histogram_color{bl};
            hh2(counter).LineWidth=1;
            hold on;
            % axis
            ax=gca;
            ax.YLim=yaxis_lim{curr_metricID};
            ax.XLim=[0,max(hh(counter).Data)];
            % legend
            if bl==2 || bl==4 || bl==6
                legend([hh(1),hh(2)],{block_selection{bl-1},block_selection{bl}})
            end
            % super title
            if bl==6
                suptitle(selected_metrics{curr_metricID});
            end
            % counter update
            counter=counter+1;
        end
    end
    
    % print
    [annot, srcInfo] = docDataSrc(fig15,outputDir,mfilename('fullpath'),logical(1))
    exportgraphics(fig15,fullfile(outputDir,['Plots_Lid_Bl3VSBl1_reappraisal_ephys_2022_' LME_type 'SLOPE.pdf']),'Resolution',300);
    print('-dpsc',fullfile(outputDir,['Plots_Lid_Bl3VSBl1_reappraisal_ephys_2022_' LME_type 'SLOPE']),'-painters','-r400','-append');
end








