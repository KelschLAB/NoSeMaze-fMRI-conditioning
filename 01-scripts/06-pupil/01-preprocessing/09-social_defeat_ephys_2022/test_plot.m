%% master_plot_PupilAndLid_reappraisal_ephys_2022_mean_data.m
% 07/2022 Reinwald, Jonathan
% Script for plotting pupil and eye-lid data for ephys task and 160Neroli
% Task in comparison

clear all
close all
clc

% Load pupil and lid data from reappraisal task
load('/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/04_reappraisal_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp = summary_all;

% Load pupil and lid data from control task with neroli
load('/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/06-160TrialsNeroli_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
summary_all_con = summary_all;

% Output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/04_reappraisal_ephys_2022/mean_data/';
mkdir(outputDir);

% set ranges
range{1}=[11:40]; range{2}=[41:80]; range{3}=[81:120]; range{4}=[121:160];

%% mean plot: PUPIL
if 1==1
    % figure
    fig11=figure(11);
    fig11.Position = [100 100 840 400];
    %% Control condition
    % clearing of data matrix before concatenation
    clear data_con
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_con{jx,1}=[];
        % Loop over sessions
        counter=1;
        for ix=[1,3:length(summary_all_con)]
            data_con{jx,1}(counter,:)=nanmean(summary_all_con(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:));
            counter=counter+1;
        end
    end
        
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        % Loop over Sessions (1=rp, 2=1h after, 3=24h after)
        for kx=1:3
            data_rp{jx,kx}=[];
            % Loop over animals (CAVE: only every third sessions in this
            % struct is a reappraisal session)
            counter=1;
            for ix=kx:3:length(summary_all_rp)
                if kx==1
                    data_rp{jx,kx}(counter,:)=nanmean(summary_all_rp(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:));
                    counter=counter+1
                elseif kx>1 && jx<3
                    data_rp{jx,kx}(counter,:)=nanmean(summary_all_rp(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:));
                    counter=counter+1
                end
            end
        end
    end
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
        
        %% Subplot for Control condition (Neroli)
        subplot(1,4,jx);
        sd1=shadedErrorBar([1:size(data_con{jx,1},2)],nanmean(data_con{jx,1}),SEM_calc(data_con{jx,1}));
        sd1.mainLine.Color=[0.5 0.25 0];
        sd1.mainLine.LineWidth=1.5;
        sd1.patch.FaceColor=[0.5 0.25 0];
        sd1.patch.EdgeColor='none';
        sd1.edge(1).Color='none';
        sd1.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        sd2=shadedErrorBar([1:size(data_rp{jx,1},2)],nanmean(data_rp{jx,1}),SEM_calc(data_rp{jx,1}));
        sd2.patch.EdgeColor='none';
        sd2.mainLine.Color=[0 0.5 0.5];
        sd2.mainLine.LineWidth=1.5;
        sd2.patch.FaceColor=[0 0.5 0.5];
        sd2.edge(1).Color='none';sd2.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        if jx<3
            sd3=shadedErrorBar([1:size(data_rp{jx,2},2)],nanmean(data_rp{jx,2}),SEM_calc(data_rp{jx,2}));
            sd3.patch.EdgeColor='none';
            sd3.mainLine.Color=[0.75 0.25 0.5];
            sd3.mainLine.LineWidth=1.5;
            sd3.mainLine.LineStyle='-';
            sd3.patch.FaceColor=[0.75 0.25 0.5];
            sd3.edge(1).Color='none';sd3.edge(2).Color='none';
            
            sd4=shadedErrorBar([1:size(data_rp{jx,3},2)],nanmean(data_rp{jx,3}),SEM_calc(data_rp{jx,3}));
            sd4.patch.EdgeColor='none';
            sd4.mainLine.Color=[0 0.25 0.5];
            sd4.mainLine.LineWidth=1.5;
            sd4.mainLine.LineStyle='-';
            sd4.patch.FaceColor=[0 0.25 0.5];
            sd4.edge(1).Color='none';sd4.edge(2).Color='none';
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
        pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
        txp.Color=[0.2,0.2,0.2];
        
        % 
        if jx==2
            hold on;
            ll=line([45,45],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
            txl=text([46],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
            txl.Color=[0.2,0.6,0.2];
        end
                 
        % Sign. *
        %         clear h p
        [h,p]=ttest(data_rp{jx,1},data_con{jx,1});
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
        if jx==1;
            ll=legend([sd1.mainLine,sd2.mainLine,sd3.mainLine,sd4.mainLine],'Con.(Ner)','Reapp.(Lav)','1h-post(Lav)','24h-post(Lav)','Location','South');
        end
        
        % Title
        tt=title(['Tr. ' num2str(range{jx}(1)) '-' num2str(range{jx}(end))]);
    end
    
    % Super title
    sp=suptitle('pupil data (mean)');
    
    % % print
    % print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
    % print('-dpdf',fullfile(outputDir,['Plots_PUPIL_1_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1,1},2)],nanmean(data_rp{1,1}),SEM_calc(data_rp{1,1}));
    sd1.mainLine.Color=[0.7 0.25 0];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[0.7 0.25 0];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3,1},2)],nanmean(data_rp{3,1}),SEM_calc(data_rp{3,1}));
    sd2.patch.EdgeColor='none';
    sd2.mainLine.Color=[0 0.5 0.7];
    sd2.mainLine.LineWidth=1.5;
    sd2.patch.FaceColor=[0 0.5 0.7];
    sd2.edge(1).Color='none';sd2.edge(2).Color='none';
    
    % axes
    ax=gca;
    ax.YLim=[0.8,1.4];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
        
    % plot odor
    hold on;
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.06],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % Sign. *
    clear h p
    [h,p]=ttest(data_rp{1,1},data_rp{3,1});
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
    ll=legend([sd1.mainLine,sd2.mainLine],'Bl. 1','Bl. 3');
    
    % Title
    tt=title({'pupil data (mean)','Bl1 vs. Bl3'});
    
    % % print
    % print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
    % print('-dpdf',fullfile(outputDir,['Plots_PUPIL_2_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
end

%% mean plot: LID
if 1==1   
    % figure
    fig13=figure(13);
    fig13.Position = [100 100 840 400];
    %% Control condition
    % clearing of data matrix before concatenation
    clear data_con
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_con{jx,1}=[];
        % Loop over sessions
        counter=1;
        for ix=[1,3:length(summary_all_con)]
            data_con{jx,1}(counter,:)=nanmean(summary_all_con(ix).LidBaseDiameterMatrix_Corrected(range{jx},:));
            counter=counter+1;
        end
    end
        
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        % Loop over Sessions (1=rp, 2=1h after, 3=24h after)
        for kx=1:3
            data_rp{jx,kx}=[];
            % Loop over animals (CAVE: only every third sessions in this
            % struct is a reappraisal session)
            counter=1;
            for ix=kx:3:length(summary_all_rp)
                if kx==1
                    data_rp{jx,kx}(counter,:)=nanmean(summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:));
                    counter=counter+1
                elseif kx>1 && jx<3
                    data_rp{jx,kx}(counter,:)=nanmean(summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:));
                    counter=counter+1
                end
            end
        end
    end
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
        
        %% Subplot for Control condition (Neroli)
        subplot(1,4,jx);
        sd1=shadedErrorBar([1:size(data_con{jx,1},2)],nanmean(data_con{jx,1}),SEM_calc(data_con{jx,1}));
        sd1.mainLine.Color=[0.5 0.25 0];
        sd1.mainLine.LineWidth=1.5;
        sd1.patch.FaceColor=[0.5 0.25 0];
        sd1.patch.EdgeColor='none';
        sd1.edge(1).Color='none';
        sd1.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        sd2=shadedErrorBar([1:size(data_rp{jx,1},2)],nanmean(data_rp{jx,1}),SEM_calc(data_rp{jx,1}));
        sd2.patch.EdgeColor='none';
        sd2.mainLine.Color=[0 0.5 0.5];
        sd2.mainLine.LineWidth=1.5;
        sd2.patch.FaceColor=[0 0.5 0.5];
        sd2.edge(1).Color='none';sd2.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        if jx<3
            sd3=shadedErrorBar([1:size(data_rp{jx,2},2)],nanmean(data_rp{jx,2}),SEM_calc(data_rp{jx,2}));
            sd3.patch.EdgeColor='none';
            sd3.mainLine.Color=[0.75 0.25 0.5];
            sd3.mainLine.LineWidth=1.5;
            sd3.mainLine.LineStyle='-';
            sd3.patch.FaceColor=[0.75 0.25 0.5];
            sd3.edge(1).Color='none';sd3.edge(2).Color='none';
            
            sd4=shadedErrorBar([1:size(data_rp{jx,3},2)],nanmean(data_rp{jx,3}),SEM_calc(data_rp{jx,3}));
            sd4.patch.EdgeColor='none';
            sd4.mainLine.Color=[0 0.25 0.5];
            sd4.mainLine.LineWidth=1.5;
            sd4.mainLine.LineStyle='-';
            sd4.patch.FaceColor=[0 0.25 0.5];
            sd4.edge(1).Color='none';sd4.edge(2).Color='none';
        end
            
            
            
        % axes
        ax=gca; 
        ax.YLim=[0.5,1.2];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [s]';
        ax.XTick=[0:20:size(data_rp{1},2)];
        ax.XTickLabel=([-2:2:10]);
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor     
        hold on;
        pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
        txp.Color=[0.2,0.2,0.2];
        
        % 
        if jx==2
            hold on;
            ll=line([45,45],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
            txl=text([46],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
            txl.Color=[0.2,0.6,0.2];
        end
                 
        % Sign. *
        %         clear h p
        [h,p]=ttest(data_rp{jx,1},data_con{jx,1});
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
        if jx==1;
            ll=legend([sd1.mainLine,sd2.mainLine,sd3.mainLine,sd4.mainLine],'Con.(Ner)','Reapp.(Lav)','1h-post(Lav)','24h-post(Lav)','Location','South');
        end
        
        % Title
        tt=title(['Tr. ' num2str(range{jx}(1)) '-' num2str(range{jx}(end))]);
    end
      
    % Super title
    sp=suptitle('eye-lid data (mean)');
    
    % % print
    % print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
    % print('-dpdf',fullfile(outputDir,['Plots_EYELID_1_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig14=figure(14);
    fig14.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1,1},2)],nanmean(data_rp{1,1}),SEM_calc(data_rp{1,1}));
    sd1.mainLine.Color=[0.7 0.25 0];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[0.7 0.25 0];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3,1},2)],nanmean(data_rp{3,1}),SEM_calc(data_rp{3,1}));
    sd2.patch.EdgeColor='none';
    sd2.mainLine.Color=[0 0.5 0.7];
    sd2.mainLine.LineWidth=1.5;
    sd2.patch.FaceColor=[0 0.5 0.7];
    sd2.edge(1).Color='none';sd2.edge(2).Color='none';
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.15];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
        
    % plot odor
    hold on;
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.06],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % Sign. *
    clear h p
    [h,p]=ttest(data_rp{1,1},data_rp{3,1});
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
    ll=legend([sd1.mainLine,sd2.mainLine],'Bl. 1','Bl. 3');

    
    % Title
    tt=title({'eye-lid data (mean)','Bl1 vs. Bl3'});
    
    % % print
    % print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
    % print('-dpdf',fullfile(outputDir,['Plots_EYELID_2_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
end
