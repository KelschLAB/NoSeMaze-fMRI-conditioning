%% plot_histograms_localGA_reappraisal_control_2023_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Preferences
% blocks
block_selection{1}='Odor11to40';
block_selection{2}='TPnoPuff11to40';
block_selection{3}='Odor11to40';
block_selection{4}='Odor81to120';
block_selection{5}='TPnoPuff11to40';
block_selection{6}='TPnoPuff81to120';

% graph metrics
selected_metrics = {'degree','strength','bci','cc','PI'};

ax_limits_x{3} = {[0,50],[0,30],[0,400],[0,1],[0,1]};
ax_limits_y{3} = {[0,800],[0,1000],[0,7000],[0,2200],[0,1400]};

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=36%[1,31,36];
maxthr_ind_range=41%[41,41,41];

% color
histogram_color={[204/255 51/255 204/255];[0 160/255 227/255];[204/255 51/255 204/255];[0 160/255 227/255];[204/255 51/255 204/255];[0 160/255 227/255]};%[1,0,0];[0,1,0]}%
% binwidth
binwidth=[1,1,100,0.05,0.05];

%% Selection of input
% cormat version
cormat_version = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max';
connectedness = 'connected';
% input directories
if separated_hemisphere==1
    inputDir_GA = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
elseif separated_hemisphere==0
    inputDir_GA = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
end

%% Loop over threshold ranges
for mx = 1:length(minthr_ind_range)
    clear myMetrics

    %% current thresholds
    minthr_ind = minthr_ind_range(mx)
    maxthr_ind = maxthr_ind_range(mx)
    
    %% Output directory
    if separated_hemisphere==1
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/histograms_localMetrics'];
    elseif separated_hemisphere==0
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/histograms_localMetrics'];
    end
    outputDir = fullfile(outputDir,[num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
    if ~exist(outputDir)
        mkdir(outputDir)
    end
    
    %% Data compilation
    % Loop over current metric (degree, strength, ...)
    for curr_metricID = [4]%1:length(selected_metrics)
        % set figure
        fig(curr_metricID)=figure('visible','on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.8,0.8]);
        % predefine subfigure
        subfig=1;
        
        % Loop over blocks
        for bl=[5,6]%1:length(block_selection)
            % load gstruc-file
            load(fullfile(inputDir_GA,['gstruc_' block_selection{bl} '_p.mat']));
            
            % Fieldnames
            myFieldnames = fieldnames(gstruc);
            % Condition: only when metrics exists
            if any(strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}]))
                % fill data in
                myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values=[gstruc([minthr_ind:maxthr_ind],:).(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])})];
            else
                % close figure if no metrics (for strength)
                if ishandle(fig(curr_metricID))
                    close(fig(curr_metricID));
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
                hh(bl)=histogram(myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(:),'BinWidth',binwidth(curr_metricID));
                box off
                % color definition
                hh(bl).EdgeColor='none';
                hh(bl).FaceColor=histogram_color{bl};
                hh(bl).FaceAlpha=0.1;
                hold on;
                hh2(bl)=histogram(myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(:),'BinWidth',binwidth(curr_metricID),'DisplayStyle','stairs');
                hh2(bl).EdgeColor=histogram_color{bl};
                hh2(bl).EdgeColor=histogram_color{bl};
                hh2(bl).LineWidth=2;
                hold on;
                % axis
                ax(bl)=gca;
                if mx==3
                    ax(bl).YLim=ax_limits_y{mx}{curr_metricID};%[0,round(max([hh.BinCounts,hh2.BinCounts]+300),-2)];
                    ax(bl).XLim=ax_limits_x{mx}{curr_metricID};%[0,max(hh(bl).Data)];
                end
                ax(bl).LineWidth=2.5;
                ax(bl).FontWeight='bold';
                ax(bl).FontSize=16;
                ax(bl).YLabel.String='rate';
                ax(bl).XLabel.String=selected_metrics{curr_metricID};
                % mean value as line
                ll=line([mean(mean(mean(myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(:)))),mean(mean(mean(myMetrics.(myFieldnames{strcmp(myFieldnames,['l_' selected_metrics{curr_metricID}])}).(block_selection{bl}).values(:))))],[0,round(max(hh(bl).BinCounts),-2)])
                ll.Color=histogram_color{bl};
                ll.LineWidth=1.5;
                if counter==2
                    ll.LineStyle='--';
                end
                % legend and pvalue
                if bl==2 || bl==4 || bl==6
                    legend([hh(bl-1),hh(bl)],{block_selection{bl-1},block_selection{bl}})
                    
                    %                     [p_value,~,stats]=signrank(hh(bl-1).Data,hh(bl).Data);
                    [clusters, p_values, t_sums, permutation_distribution ] = permutest(hh(bl-1).Data', hh(bl).Data',true,0.05,10000,true);
                    tx = text(ax(bl).XLim(2)*.6,ax(bl).YLim(2)*.8,['p=' num2str(round(p_values,5))]);
                    %                     tx = text(ax(bl).XLim(2)*.6,ax(bl).YLim(2)*.7,['zval=' num2str(round(stats.zval,3))]);
                end
                
                % super title
                if bl==6
                    suptitle(selected_metrics{curr_metricID});
                    ax(1).YLim = [min([ax(1).YLim,ax(2).YLim,ax(3).YLim,ax(4).YLim,ax(5).YLim,ax(6).YLim]),round(max([ax(1).YLim,ax(2).YLim,ax(3).YLim,ax(4).YLim,ax(5).YLim,ax(6).YLim]),1)+0.05];
                    for i_bl=1:6
                        ax(i_bl).YLim = ax(1).YLim;
                    end
                end
                
                % counter update
                counter=counter+1;
            end
        end
        % equalize limits of axes in all subplots
%         axAll = findobj(fig(curr_metricID),'type','axes');
%         for axIdx=1:length(axAll)-1
%             axAll(axIdx+1).XLim=[0,max([axAll.XLim])];
%             axAll(axIdx+1).YLim=[0,max([axAll.YLim])];
%         end
%         lineAll = findobj(fig(curr_metricID),'type','line');
%         for lineIdx=1:length(lineAll)
%             lineAll(lineIdx).YData=[0,max([axAll.YLim])];
%         end
        % print
        % if figure exists (e.g. strength only in max)
%         if ishandle(fig(curr_metricID))
%             [annot, srcInfo] = docDataSrc(fig(curr_metricID),outputDir,mfilename('fullpath'),logical(1))
%             exportgraphics(fig(curr_metricID),fullfile(outputDir,['Histogram_' selected_metrics{curr_metricID} '.pdf']),'Resolution',300);
%             print('-dpsc',fullfile(outputDir,['Histograms']),'-painters','-r400','-append');
%         end
    end
    % save data
    save(fullfile(outputDir,'myMetrics.mat'),'myMetrics');
end