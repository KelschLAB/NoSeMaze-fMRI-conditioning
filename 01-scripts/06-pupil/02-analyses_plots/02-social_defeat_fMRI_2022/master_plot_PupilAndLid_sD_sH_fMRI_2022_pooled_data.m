%% master_plot_PupilAndLid_sD_sH_fMRI_2022_pooled_data.m
% 01/2023 Reinwald, Jonathan
% Script for plotting pupil and eye-lid data for ephys task and 160Neroli
% Task in comparison

clear all
% close all
clc

% path def
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))

% Load pupil and lid data from social_defeat task
load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/04-pupil/02-social_defeat/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp_SD = summary_all;
% for ix=1:length(summary_all_rp_SD)
%     summary_all_rp_SD(ix).PupilBaseDiameterMatrix_Corrected(1:30,:)=[];
%     summary_all_rp_SD(ix).odor_num(1:30,:)=[];
% end

% Load pupil and lid data from social_hierarchy task
load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/04-pupil/03-social_hierarchy/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp_SH = summary_all;
% for ix=1:length(summary_all_rp_SH)
%     summary_all_rp_SH(ix).PupilBaseDiameterMatrix_Corrected(1:30,:)=[];
%     summary_all_rp_SH(ix).odor_num(1:30,:)=[];
% end

% Output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/02-social_defeat_fMRI_2022/pooled_data/';
mkdir(outputDir);

% define odor numbers as unique set
odor_list_SD(1).name = 'CD1familiar';
odor_list_SD(1).code = 20;
odor_list_SD(2).name = 'CD1unknown';
odor_list_SD(2).code = 21;
odor_list_SD(3).name = '129sv';
odor_list_SD(3).code = 22;

odor_list_SH(1).name = 'C57Bl6High';
odor_list_SH(1).code = 20;
odor_list_SH(2).name = 'C57Bl6Low';
odor_list_SH(2).code = 21;

% Set smoothing kernel
smoothing_kernel = 119*3;

% Set colors
color_scheme{1}=[0.5 0 0]; color_scheme{2}=[0.5 0.25 0]; color_scheme{3}=[0.25 0.5 0]; color_scheme{4}=[0 0 .5]; color_scheme{5}=[0 .25 0.25];

%% Pooled plot: PUPIL
if 1==1
    %% social_defeat condition
    % clearing of data matrix before concatenation
    clear data_rp data_long_rp
    % concatenate data for each range
    % Loop over odors social defeat
    for jx=1:length(odor_list_SD)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a social_defeat session)
        for ix=1:length(summary_all_rp_SD)
            %% Data for each range (=blocks)
            data_rp{jx}=[data_rp{jx};summary_all_rp_SD(ix).PupilBaseDiameterMatrix_Corrected([summary_all_rp_SD(ix).odor_num]==odor_list_SD(jx).code,:)];
%            %% Data for the whole session
%             if jx==1
%                 clear transposed_data
%                 transposed_data = summary_all_rp_SD(ix).PupilDiameterMatrix';
%                 data_long_rp(ix,:)=transposed_data(:)';    
%                 data_long_rp_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
%             end
        end
    end
    
    % Loop over odors social hierarchy
    for jx=1:length(odor_list_SH)
        data_rp{jx+length(odor_list_SD)}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a social_defeat session)
        for ix=1:length(summary_all_rp_SH)
            %% Data for each range (=blocks)
            data_rp{jx+length(odor_list_SD)}=[data_rp{jx+length(odor_list_SD)};summary_all_rp_SH(ix).PupilBaseDiameterMatrix_Corrected([summary_all_rp_SH(ix).odor_num]==odor_list_SH(jx).code,:)];
            %            %% Data for the whole session
            %             if jx==1
            %                 clear transposed_data
            %                 transposed_data = summary_all_rp_SD(ix).PupilDiameterMatrix';
            %                 data_long_rp(ix,:)=transposed_data(:)';
            %                 data_long_rp_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
            %             end
        end
    end
    
    %% Figure 11: Intra-Trial Plot
    fig13=figure(13);
    fig13.Position = [100 100 440 600];
    
    % Loop over range
    for jx=1:length(data_rp)
        figure(jx);
        hold on;
        %% Subplot for social_defeat condition (Lavender)
        selection=[]; for ix=1:(length(data_rp{jx})./30); selection=[selection,1+(ix-1)*30:30+(ix-1)*30]; end

        sd{jx}=shadedErrorBar([1:size(data_rp{jx}(selection,:),2)],nanmean(data_rp{jx}(selection,:)),SEM_calc(data_rp{jx}(selection,:)));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.3];
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
    hold on;
    ll=line([45+7,45+7],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
    txl=text([46+7],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
    txl.Color=[0.2,0.6,0.2];
    
%     % Sign. *
%     %         clear h p
%     [h,p]=ttest2(data_rp{1},data_rp{3});
%     for px=1:length(p)
%         if p(px)<0.001
%             text(px,ax.YLim(2)*0.99,'*');
%             text(px,ax.YLim(2)*0.98,'*');
%             text(px,ax.YLim(2)*0.97,'*');
%         elseif p(px)<0.01
%             text(px,ax.YLim(2)*0.99,'*');
%             text(px,ax.YLim(2)*0.98,'*');
%         elseif p(px)<0.05
%             text(px,ax.YLim(2)*0.99,'*');
%         end
%     end
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine],[odor_list_SD(1).name],[odor_list_SD(2).name],[odor_list_SD(3).name],[odor_list_SH(1).name],[odor_list_SH(2).name],'Location','SouthEast');   
    
    % Super title
    sp=title('pupil data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_socialDefeatANDHierarchy_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_PUPIL_INTRATRIAL_PupilAndLid_socialDefeatANDHierarchy_fMRI_2022']),'-painters','-r400');
    
    
% % %     %% Figure 12: Session Plot
% % %     fig12=figure(12);
% % %     fig12.Position = [100 100 840 800];    
% % %     
% % %     %% Subplot 2: Session-Plot
% % %     for ix=1:2
% % %         % subplot
% % %         hold on;
% % %         subplot(2,5,(1:3)+(ix-1)*5);
% % %     
% % %         %% Subplot for social_defeat condition (Lavender)
% % %         clear sd
% % %         if ix==1
% % %             sd=shadedErrorBar([1:size(data_long_rp,2)],nanmean(data_long_rp),SEM_calc(data_long_rp));
% % %         elseif ix==2
% % %             sd=shadedErrorBar([1:size(data_long_rp_smoothed,2)],nanmean(data_long_rp_smoothed),SEM_calc(data_long_rp_smoothed));            
% % %         end
% % %         sd.patch.EdgeColor='none';
% % %         sd.mainLine.Color=color_scheme{1};
% % %         sd.mainLine.LineWidth=1.5;
% % %         sd.patch.FaceColor=color_scheme{1};
% % %         sd.edge(1).Color='none';
% % %         sd.edge(2).Color='none';
% % %         
% % %         % axes
% % %         ax=gca;
% % %         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
% % %         ax.YLabel.String='A.U.';
% % %         ax.XLabel.String='time [min]';
% % %         ax.XTick=[0:1200:size(data_long_rp,2)];
% % %         ax.XTickLabel=[0:2:size(data_long_rp,2)/600];
% % %         ax.FontWeight='bold';
% % %         ax.LineWidth=1;
% % %         
% % %         % plot odor
% % %         hold on;
% % %         pt=patch([size(data_long_rp,2)/3+1,(size(data_long_rp,2)*2)/3,(size(data_long_rp,2)*2)/3,size(data_long_rp,2)/3+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
% % %         pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
% % %         txp=text(size(data_long_rp,2)/3+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
% % %         txp.Color=[0.2,0.2,0.2];
% % %         
% % %         % title
% % %         if ix==1
% % %             tt=title('pupil data unsmoothed');
% % %         elseif ix==2
% % %             tt=title(['pupil data smoothed (' num2str(smoothing_kernel) ' kernel)']);
% % %         end
% % %         
% % %         %% subplot mean-val
% % %         hold on;
% % %         subplot(2,5,(4:5)+(ix-1)*5);
% % %         if ix==1
% % %             notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp(:,0*119+1:40*119),2),nanmean(data_long_rp(:,40*119+1:80*119),2),nanmean(data_long_rp(:,80*119+1:120*119),2)])
% % %         elseif ix==2
% % %             notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp_smoothed(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed(:,40*119+1:80*119),2),nanmean(data_long_rp_smoothed(:,80*119+1:120*119),2)])
% % %         end
% % %         
% % %         % axes
% % %         ax=gca;
% % % %         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
% % %         ax.YLabel.String='A.U.';
% % %         ax.XLabel.String='Blocks';
% % %         ax.XTick=[1:1:3];
% % %         ax.XTickLabel={'1','2','3'};
% % %         ax.FontWeight='bold';
% % %         ax.LineWidth=1;
% % %          
% % %         % Sign. *
% % %         clear h p
% % %         if ix==1
% % %             [p,h]=signrank(nanmean(data_long_rp(:,0*119+1:40*119),2),nanmean(data_long_rp(:,80*119+1:120*119),2));
% % %         elseif ix==2
% % %             [p,h]=signrank(nanmean(data_long_rp_smoothed(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed(:,80*119+1:120*119),2));
% % %         end
% % %         for px=1:length(p)
% % %             if p(px)<0.001
% % %                 sigstar({{'1','3'}},0.001,0,20)
% % %             elseif p(px)<0.01
% % %                 sigstar({{'1','3'}},0.01,0,20)
% % %             elseif p(px)<0.05
% % %                 sigstar({{'1','3'}},0.05,0,20)
% % %             end
% % %         end
% % %     end
% % %         
% % %     % print
% % %     print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400','-append');
% % %     print('-dpdf',fullfile(outputDir,['Plots_PUPIL_INTRASESSION_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400');
end

%% Pooled plot: LID
if 1==1
    %% social_defeat condition
    % clearing of data matrix before concatenation
    clear data_rp data_long_rp
    % concatenate data for each range
    % Loop over odors social defeat
    for jx=1:length(odor_list_SD)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a social_defeat session)
        for ix=1:length(summary_all_rp_SD)
            %% Data for each range (=blocks)
            data_rp{jx}=[data_rp{jx};summary_all_rp_SD(ix).LidBaseDiameterMatrix_Corrected([summary_all_rp_SD(ix).odor_num]==odor_list_SD(jx).code,:)];
%            %% Data for the whole session
%             if jx==1
%                 clear transposed_data
%                 transposed_data = summary_all_rp_SD(ix).PupilDiameterMatrix';
%                 data_long_rp(ix,:)=transposed_data(:)';    
%                 data_long_rp_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
%             end
        end
    end
    
%     % Loop over odors social hierarchy
%     for jx=1:length(odor_list_SH)
%         data_rp{jx+length(odor_list_SD)}=[];
%         % Loop over animals (CAVE: only every third sessions in this
%         % struct is a social_defeat session)
%         for ix=1:length(summary_all_rp_SH)
%             %% Data for each range (=blocks)
%             data_rp{jx+length(odor_list_SD)}=[data_rp{jx+length(odor_list_SD)};summary_all_rp_SH(ix).LidBaseDiameterMatrix_Corrected([summary_all_rp_SH(ix).odor_num]==odor_list_SH(jx).code,:)];
%             %            %% Data for the whole session
%             %             if jx==1
%             %                 clear transposed_data
%             %                 transposed_data = summary_all_rp_SD(ix).PupilDiameterMatrix';
%             %                 data_long_rp(ix,:)=transposed_data(:)';
%             %                 data_long_rp_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
%             %             end
%         end
%     end
    
    %% Figure 11: Intra-Trial Plot
    fig13=figure(13);
    fig13.Position = [100 100 440 600];
    
    % Loop over range
    clear sd
    for jx=1:length(data_rp)
        
        %% Subplot for social_defeat condition (Lavender)
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
    ax.YLim=[0.8,1.2];
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
    hold on;
    ll=line([45+7,45+7],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
    txl=text([46+7],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
    txl.Color=[0.2,0.6,0.2];
    
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
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine],[odor_list_SD(1).name],[odor_list_SD(2).name],[odor_list_SD(3).name],[odor_list_SH(1).name],[odor_list_SH(2).name],'Location','SouthEast');   
     
    % Super title
    sp=title('lid data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_LID_INTRATRIAL_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400');
    
    
    %% Figure 14: Session Plot
    fig14=figure(14);
    fig14.Position = [100 100 840 800];    
    
    %% Subplot 2: Session-Plot
    for ix=1:2
        % subplot
        hold on;
        subplot(2,5,(1:3)+(ix-1)*5);
    
        %% Subplot for social_defeat condition (Lavender)
        clear sd
        if ix==1
            sd=shadedErrorBar([1:size(data_long_rp,2)],nanmean(data_long_rp),SEM_calc(data_long_rp));
        elseif ix==2
            sd=shadedErrorBar([1:size(data_long_rp_smoothed,2)],nanmean(data_long_rp_smoothed),SEM_calc(data_long_rp_smoothed));            
        end
        sd.patch.EdgeColor='none';
        sd.mainLine.Color=color_scheme{1};
        sd.mainLine.LineWidth=1.5;
        sd.patch.FaceColor=color_scheme{1};
        sd.edge(1).Color='none';
        sd.edge(2).Color='none';
        
        % axes
        ax=gca;
        ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [min]';
        ax.XTick=[0:1200:size(data_long_rp,2)];
        ax.XTickLabel=[0:2:size(data_long_rp,2)/600];
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([size(data_long_rp,2)/3+1,(size(data_long_rp,2)*2)/3,(size(data_long_rp,2)*2)/3,size(data_long_rp,2)/3+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(size(data_long_rp,2)/3+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
        txp.Color=[0.2,0.2,0.2];
        
        % title
        if ix==1
            tt=title('lid data unsmoothed');
        elseif ix==2
            tt=title(['lid data smoothed (' num2str(smoothing_kernel) ' kernel)']);
        end
        
        %% subplot mean-val
        hold on;
        subplot(2,5,(4:5)+(ix-1)*5);
        if ix==1
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp(:,0*119+1:40*119),2),nanmean(data_long_rp(:,40*119+1:80*119),2),nanmean(data_long_rp(:,80*119+1:120*119),2)])
        elseif ix==2
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp_smoothed(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed(:,40*119+1:80*119),2),nanmean(data_long_rp_smoothed(:,80*119+1:120*119),2)])
        end
        
        % axes
        ax=gca;
%         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='Blocks';
        ax.XTick=[1:1:3];
        ax.XTickLabel={'1','2','3'};
        ax.FontWeight='bold';
        ax.LineWidth=1;
         
        % Sign. *
        clear h p
        if ix==1
            [p,h]=signrank(nanmean(data_long_rp(:,0*119+1:40*119),2),nanmean(data_long_rp(:,80*119+1:120*119),2));
        elseif ix==2
            [p,h]=signrank(nanmean(data_long_rp_smoothed(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed(:,80*119+1:120*119),2));
        end
        for px=1:length(p)
            if p(px)<0.001
                sigstar({{'1','3'}},0.001,0,20)
            elseif p(px)<0.01
                sigstar({{'1','3'}},0.01,0,20)
            elseif p(px)<0.05
                sigstar({{'1','3'}},0.05,0,20)
            end
        end
        
    end
        
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_LID_INTRASESSION_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400');
end

%% Pooled plot: PUPILMOVEMENT
if 1==1
    %% social_defeat condition
    % clearing of data matrix before concatenation
    clear data_rp data_long_rp
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a social_defeat session)
        for ix=1:length(summary_all_rp_SD)
            %% Data for each range (=blocks)
            data_rp{jx}=[data_rp{jx};summary_all_rp_SD(ix).PupilBaseMovementMatrix_Corrected(range{jx},:)];
            %% Data for the whole session
            if jx==1
                clear transposed_data
                transposed_data = summary_all_rp_SD(ix).PupilMovementMatrix';
                data_long_rp(ix,:)=transposed_data(:)';    
                data_long_rp_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
            end
        end
    end
    
    %% Figure 11: Intra-Trial Plot
    fig11=figure(11);
    fig11.Position = [100 100 440 600];
    
    % Loop over range
    for jx=1:length(range)
        
        %% Subplot for social_defeat condition (Lavender)cl
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
    ax.YLim=[0,10];
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
    hold on;
    ll=line([45+7,45+7],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
    txl=text([46+7],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
    txl.Color=[0.2,0.6,0.2];
    
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
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine],['Bl. ' num2str(range{1}(1)) '-' num2str(range{1}(end))],['Bl. ' num2str(range{2}(1)) '-' num2str(range{2}(end))],['Bl. ' num2str(range{3}(1)) '-' num2str(range{3}(end))],'Location','SouthEast');   
    
    % Super title
    sp=title('pupil data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_PUPILMOVEMENT_INTRATRIAL_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400');
    
    
    %% Figure 12: Session Plot
    fig12=figure(12);
    fig12.Position = [100 100 840 800];    
    
    %% Subplot 2: Session-Plot
    for ix=1:2
        % subplot
        hold on;
        subplot(2,5,(1:3)+(ix-1)*5);
    
        %% Subplot for social_defeat condition (Lavender)
        clear sd
        if ix==1
            sd=shadedErrorBar([1:size(data_long_rp,2)],nanmean(data_long_rp),SEM_calc(data_long_rp));
        elseif ix==2
            sd=shadedErrorBar([1:size(data_long_rp_smoothed,2)],nanmean(data_long_rp_smoothed),SEM_calc(data_long_rp_smoothed));            
        end
        sd.patch.EdgeColor='none';
        sd.mainLine.Color=color_scheme{1};
        sd.mainLine.LineWidth=1.5;
        sd.patch.FaceColor=color_scheme{1};
        sd.edge(1).Color='none';
        sd.edge(2).Color='none';
        
        % axes
        ax=gca;
        ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [min]';
        ax.XTick=[0:1200:size(data_long_rp,2)];
        ax.XTickLabel=[0:2:size(data_long_rp,2)/600];
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([size(data_long_rp,2)/3+1,(size(data_long_rp,2)*2)/3,(size(data_long_rp,2)*2)/3,size(data_long_rp,2)/3+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(size(data_long_rp,2)/3+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
        txp.Color=[0.2,0.2,0.2];
        
        % title
        if ix==1
            tt=title('pupil data unsmoothed');
        elseif ix==2
            tt=title(['pupil data smoothed (' num2str(smoothing_kernel) ' kernel)']);
        end
        
        %% subplot mean-val
        hold on;
        subplot(2,5,(4:5)+(ix-1)*5);
        if ix==1
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp(:,0*119+1:40*119),2),nanmean(data_long_rp(:,40*119+1:80*119),2),nanmean(data_long_rp(:,80*119+1:120*119),2)])
        elseif ix==2
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp_smoothed(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed(:,40*119+1:80*119),2),nanmean(data_long_rp_smoothed(:,80*119+1:120*119),2)])
        end
        
        % axes
        ax=gca;
%         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='Blocks';
        ax.XTick=[1:1:3];
        ax.XTickLabel={'1','2','3'};
        ax.FontWeight='bold';
        ax.LineWidth=1;
         
        % Sign. *
        clear h p
        if ix==1
            [p,h]=signrank(nanmean(data_long_rp(:,0*119+1:40*119),2),nanmean(data_long_rp(:,80*119+1:120*119),2));
        elseif ix==2
            [p,h]=signrank(nanmean(data_long_rp_smoothed(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed(:,80*119+1:120*119),2));
        end
        for px=1:length(p)
            if p(px)<0.001
                sigstar({{'1','3'}},0.001,0,20)
            elseif p(px)<0.01
                sigstar({{'1','3'}},0.01,0,20)
            elseif p(px)<0.05
                sigstar({{'1','3'}},0.05,0,20)
            end
        end
    end
        
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_PUPILMOVEMENT_INTRASESSION_PupilAndLid_social_defeat_fMRI_2022']),'-painters','-r400');
end


