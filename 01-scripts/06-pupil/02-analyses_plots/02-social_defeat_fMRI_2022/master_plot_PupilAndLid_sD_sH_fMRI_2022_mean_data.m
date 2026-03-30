%% master_plot_PupilAndLid_sD_sH_fMRI_2022_mean_data.m
% 07/2022 Reinwald, Jonathan
% Script for plotting pupil and eye-lid data for ephys task and 160Neroli
% Task in comparison

clear all
close all
clc

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
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/02-social_defeat_fMRI_2022/mean_data/';
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

% Set colors
color_scheme{1}=[0.5 0 0]; color_scheme{2}=[0.5 0.25 0]; color_scheme{3}=[0.25 0.5 0]; color_scheme{4}=[0 0 .5]; color_scheme{5}=[0 .25 0.25];

%% mean plot: PUPIL
if 1==1
    % figure
    fig11=figure(11);
    fig11.Position = [100 100 600 600];
    subplot(2,2,[1,3]);
    
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(odor_list_SD)
        data_rp{jx}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a reappraisal session)
        for ix=1:length(summary_all_rp_SD)
            data_rp{jx}(ix,:)=nanmean(summary_all_rp_SD(ix).PupilBaseDiameterMatrix_Corrected([summary_all_rp_SD(ix).odor_num]==odor_list_SD(jx).code,:));
            data_rp{jx}(ix,:)=nanmean(summary_all_rp_SD(ix).PupilBaseDiameterMatrix_Corrected([summary_all_rp_SD(ix).odor_num]==odor_list_SD(jx).code.*[ones(30,1);zeros(60,1)],:));
        end
    end 
    
    for jx=1:length(odor_list_SH)
        data_rp{jx+length(odor_list_SD)}=[];
        % Loop over animals (CAVE: only every third sessions in this
        % struct is a reappraisal session)
        for ix=1:length(summary_all_rp_SH)
            data_rp{jx+length(odor_list_SD)}(ix,:)=nanmean(summary_all_rp_SH(ix).PupilBaseDiameterMatrix_Corrected([summary_all_rp_SH(ix).odor_num]==odor_list_SH(jx).code,:));
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
        sd{jx}.mainLine.LineStyle='-';
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.patch.FaceAlpha=0.1;
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.95,1.4];
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
       
    % Anova
    myData = [data_rp{1};data_rp{2};data_rp{3};data_rp{4};data_rp{5}];
    for ix=1:size(data_rp{1},2)
        [p_anova(ix),anovatbl,stats]=anova1(myData(:,ix),[ones(size(data_rp{1},1),1);2*ones(size(data_rp{2},1),1);3*ones(size(data_rp{3},1),1);4*ones(size(data_rp{4},1),1);5*ones(size(data_rp{5},1),1)],'off');
        [comparison,means,h,gnames] =multcompare(stats,'display','off');
        multcomp_res(:,ix)=comparison(:,6);
    end
    
    % Sign. *
    for px=1:length(p_anova)
        if p_anova(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p_anova(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p_anova(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine],[odor_list_SD(1).name],[odor_list_SD(2).name],[odor_list_SD(3).name],[odor_list_SH(1).name],[odor_list_SH(2).name],'Location','best');   
    
    % Subplot
    subplot(2,2,[2,4]);
    imagesc(multcomp_res<0.05);
    
    
    % Super title
    sp=suptitle('pupil data (mean)');
    
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
