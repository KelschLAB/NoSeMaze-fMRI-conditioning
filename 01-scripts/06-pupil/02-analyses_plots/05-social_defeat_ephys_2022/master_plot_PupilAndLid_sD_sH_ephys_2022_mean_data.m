%% master_plot_PupilAndLid_sD_sH_fMRI_2022_mean_data.m
% 07/2022 Reinwald, Jonathan
% Script for plotting pupil and eye-lid data for ephys task and 160Neroli
% Task in comparison

clear all
close all
clc

% path def
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))

% Load pupil and lid data from social_defeat task
load('/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/07-social_defeat_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp = summary_all;

% Output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/02-social_defeat_fMRI_2022/mean_data/';
mkdir(outputDir);

% define odor numbers as unique set
odor_list(1).name = 'CD1familiar';
odor_list(1).code = 7;
odor_list(2).name = 'CD1unknown';
odor_list(2).code = 8;
odor_list(3).name = 'C57Bl6familiar';
odor_list(3).code = 9;
odor_list(4).name = 'C57Bl6unknown';
odor_list(4).code = 10;

% Set smoothing kernel
smoothing_kernel = 119*3;

% Set colors
color_scheme{1}=[0.5 0 0]; color_scheme{2}=[0.5 0.25 0]; color_scheme{3}=[0 0 .5]; color_scheme{4}=[0 .25 0.25];

%% mean plot: PUPIL
if 1==1
    % figure
    fig11=figure(11);
    fig11.Position = [100 100 440 600];
    
    %% social_defeat condition
    % clearing of data matrix before concatenation
    clear data_rp data_long_rp
    % concatenate data for each range
    % Loop over odors social defeat
    for jx=1:length(odor_list)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a social_defeat session)
        for ix=1:length(summary_all_rp)
            %% Data for each range (=blocks)
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a reappraisal session)
            data_rp{jx}(ix,:)=nanmean(summary_all_rp(ix).PupilBaseDiameterMatrix_Corrected([summary_all_rp(ix).odor_num]==odor_list(jx).code,:));
        %            %% Data for the whole session
%             if jx==1
%                 clear transposed_data
%                 transposed_data = summary_all_rp(ix).PupilDiameterMatrix';
%                 data_long_rp(ix,:)=transposed_data(:)';    
%                 data_long_rp_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
%             end
        end
    end
    
    %% Plot
    % Loop over range
    for jx=1:length(data_rp)
        
        %% Subplot for reappraisal condition (Lavender)
        sd{jx}=shadedErrorBar([1:size(data_rp{jx},2)],nanmean(data_rp{jx}),SEM_calc(data_rp{jx}));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.8,1.6];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % plot odor
    hold on;
    pt=patch([20+7,44+7,44+7,20+7],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21+7,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
    txp.Color=[0.2,0.2,0.2];
       
    % Sign. *
    %         clear h p
    [h,p]=ttest(data_rp{1},data_rp{2});
    for px=1:length(p)
        if p(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine],[odor_list(1).name],[odor_list(2).name],[odor_list(3).name],[odor_list(4).name],'Location','SouthEast');   
    
    % Super title
    sp=title('pupil data (mean)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_sD_sH_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_PUPIL_PupilAndLid_sD_sH_fMRI_2022']),'-painters','-r400');
end

%% mean plot: LID
if 1==1
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 600];
    
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a reappraisal session)
        counter=1;
        for ix=[1:length(summary_all_rp)]
            data_rp{jx}(counter,:)=nanmean(summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:));
            counter=counter+1;
        end
        data_rp{jx}(isinf(data_rp{jx}))=nan;
    end 
    
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
        %% Subplot for reappraisal condition (Lavender)
        sd{jx}=shadedErrorBar([1:size(data_rp{jx},2)],nanmean(data_rp{jx}),SEM_calc(data_rp{jx}));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.1];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % plot odor
    hold on;
    pt=patch([20+7,44+7,44+7,20+7],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21+7,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    %
    if jx==2
        hold on;
        ll=line([45+7,45+7],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
        txl=text([46+7],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
        txl.Color=[0.2,0.6,0.2];
    end
    
    % Sign. *
    %         clear h p
    [h,p]=ttest2(data_rp{1},data_rp{3});
    for px=1:length(p)
        if p(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine],['Bl. ' num2str(range{1}(1)) '-' num2str(range{1}(end))],['Bl. ' num2str(range{2}(1)) '-' num2str(range{2}(end))],['Bl. ' num2str(range{3}(1)) '-' num2str(range{3}(end))],'Location','South');
    
    % Super title
    sp=suptitle('eye-lid data (mean)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_EYE-LID_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400');
end

%% mean plot: LID
if 1==1
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 600];
    
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a reappraisal session)
        counter=1;
        for ix=[1:length(summary_all_rp)]
            data_rp{jx}(counter,:)=nanmean(summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:));
            counter=counter+1;
        end
        data_rp{jx}(isinf(data_rp{jx}))=nan;
    end 
    
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
        %% Subplot for reappraisal condition (Lavender)
        sd{jx}=shadedErrorBar([1:size(data_rp{jx},2)],nanmean(data_rp{jx}),SEM_calc(data_rp{jx}));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.1];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % plot odor
    hold on;
    pt=patch([20+7,44+7,44+7,20+7],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21+7,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    %
    if jx==2
        hold on;
        ll=line([45+7,45+7],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
        txl=text([46+7],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
        txl.Color=[0.2,0.6,0.2];
    end
    
    % Sign. *
    %         clear h p
    [h,p]=ttest2(data_rp{1},data_rp{3});
    for px=1:length(p)
        if p(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine],['Bl. ' num2str(range{1}(1)) '-' num2str(range{1}(end))],['Bl. ' num2str(range{2}(1)) '-' num2str(range{2}(end))],['Bl. ' num2str(range{3}(1)) '-' num2str(range{3}(end))],'Location','South');
    
    % Super title
    sp=suptitle('eye-lid data (mean)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_EYE-LID_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400');
end
