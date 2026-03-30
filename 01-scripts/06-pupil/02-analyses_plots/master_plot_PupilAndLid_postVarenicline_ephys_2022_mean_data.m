% clearing
close all
clear all

% load pupil data
load('/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/08-varenicline_ephys_2022/03-videos_pupil/post_varenicline/pupil_summary_all.mat');

% smoothing_length in frames, empty for no smoothing
smoothing_length = 600;

% Output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/08_postVarenicline_ephys_2022/mean_data/';
mkdir(outputDir);

if 1==0
    % figure
    fig11=figure(11);
    fig11.Position = [100 100 600 840];
    
    %% Plot 1: Mean pupil over time
    if 1==1
        % Create matrix with data from all sessions
        % Info: pupil data cropped to the start of the paradigm is saved in
        % summary_all.PupilDiameter, but differs in length for each session
        % (probably due to jittering)
        
        % predefine nan matrix
        myMatrix = nan(length(summary_all),30000);
        % fill matrix
        for sess=1:length(summary_all)
            x = (summary_all(sess).PupilDiameter);
            myMatrix(sess,1:length(summary_all(sess).PupilDiameter))=(x - nanmean(x))/nanstd(x);;
            sess_length(sess) = length(summary_all(sess).PupilDiameter);
        end
        % reduce matrix
        myMatrix=myMatrix(:,1:min(sess_length));
        
        % smoothing
        if smoothing_length
            myMatrix=smoothdata(myMatrix,2,'movmean',600)
        end
        
        % plot
        subplot(3,2,1:2);
        sd1 = shadedErrorBar(1:size(myMatrix,2),nanmean(myMatrix),SEM_calc(myMatrix));
        sd1.mainLine.Color=[0.5 0.25 0];
        sd1.mainLine.LineWidth=1.5;
        sd1.patch.FaceColor=[0.5 0.25 0];
        sd1.patch.EdgeColor='none';
        sd1.edge(1).Color='none';
        sd1.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [min]';
    ax.XLim=[0,size(myMatrix,2)];
    ax.XTick=[0:600*2:size(myMatrix,2)];
    ax.XTickLabel=([0:2:size(myMatrix,2)/(600)]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    %% Plot 3: Mean for each odor and the laser
    
    % clearing of data matrix before concatenation
    clear myData_mean myData_pooled
    
    % define quality of
    myTrialQuality(1).odor_num = 37;
    myTrialQuality(1).name = 'Jasmin 5%';
    myTrialQuality(1).color = [0.5 0 0];
    myTrialQuality(2).odor_num = 35;
    myTrialQuality(2).name = 'YlangYlang 5%';
    myTrialQuality(2).color = [0.5 0.5 0];
    myTrialQuality(3).odor_num = 0;
    myTrialQuality(3).name = 'Laser Stim.';
    myTrialQuality(3).color = [0 0 0.5];
    
    % Loop over each odor/laser quality
    for qual=1:length(myTrialQuality)
        % define empty matrix for pooling of the data
        myData_pooled(qual).pooledData=[];
        % Loop over session
        for sess = 1:length(summary_all)
            myData_mean(qual,sess,:)=nanmean(summary_all(sess).PupilBaseDiameterMatrix_Corrected([summary_all(sess).odor_num]==myTrialQuality(qual).odor_num,:));
            % early
            clear helpMat
            helpMat = summary_all(sess).PupilBaseDiameterMatrix_Corrected([summary_all(sess).odor_num]==myTrialQuality(qual).odor_num,:);
            myData_mean_early(qual,sess,:)=nanmean(helpMat(11:30,:));
            myData_mean_late(qual,sess,:)=nanmean(helpMat(end-19:end,:));
            
            myData_pooled(qual).pooledData=[myData_pooled(qual).pooledData;summary_all(sess).PupilBaseDiameterMatrix_Corrected([summary_all(sess).odor_num]==myTrialQuality(qual).odor_num,:)];
        end
    end
    
    tt=title('z-scored pupil');
    
    % subplot
    subplot(3,2,3);
    for qual=1:length(myTrialQuality)
        sd{qual} = shadedErrorBar(1:size(squeeze(myData_mean(qual,:,:)),2),nanmean(squeeze(myData_mean(qual,:,:))),SEM_calc(squeeze(myData_mean(qual,:,:))));
        sd{qual}.mainLine.Color=myTrialQuality(qual).color;
        sd{qual}.mainLine.LineWidth=1.5;
        sd{qual}.patch.FaceColor=myTrialQuality(qual).color;
        sd{qual}.patch.EdgeColor='none';
        sd{qual}.edge(1).Color='none';
        sd{qual}.edge(2).Color='none';
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.6];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XLim=[0,size(myData_mean,3)];
    ax.XTick=[0:20:size(myData_mean,3)];
    ax.XTickLabel=([-2:2:5]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % hold on
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.5],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine],myTrialQuality(1).name,myTrialQuality(2).name,myTrialQuality(3).name,'Location','bestoutside');
    
    % subplot
    subplot(3,2,5:6);
    counter=1;
    for qual=1:length(myTrialQuality)
        hold on;
        sd{counter} = shadedErrorBar(1:size(squeeze(myData_mean_early(qual,:,:)),2),nanmean(squeeze(myData_mean_early(qual,:,:))),SEM_calc(squeeze(myData_mean_early(qual,:,:))));
        sd{counter}.mainLine.Color=myTrialQuality(qual).color;
        sd{counter}.mainLine.LineWidth=1.5;
        sd{counter}.mainLine.LineStyle=':';
        sd{counter}.patch.FaceColor=myTrialQuality(qual).color;
        sd{counter}.patch.EdgeColor='none';
        sd{counter}.edge(1).Color='none';
        sd{counter}.edge(2).Color='none';
        counter=counter+1;
        hold on;
        sd{counter} = shadedErrorBar(1:size(squeeze(myData_mean_late(qual,:,:)),2),nanmean(squeeze(myData_mean_late(qual,:,:))),SEM_calc(squeeze(myData_mean_late(qual,:,:))));
        sd{counter}.mainLine.Color=myTrialQuality(qual).color;
        sd{counter}.mainLine.LineWidth=1.5;
        sd{counter}.mainLine.LineStyle='--';
        sd{counter}.patch.FaceColor=myTrialQuality(qual).color;
        sd{counter}.patch.EdgeColor='none';
        sd{counter}.edge(1).Color='none';
        sd{counter}.edge(2).Color='none';
        counter=counter+1;
    end
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.6];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XLim=[0,size(myData_mean,3)];
    ax.XTick=[0:20:size(myData_mean,3)];
    ax.XTickLabel=([-2:2:5]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % hold on
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.5],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % legend
    ll=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine,sd{6}.mainLine],[myTrialQuality(1).name ' early'],[myTrialQuality(1).name ' late'],[myTrialQuality(2).name ' early'],[myTrialQuality(2).name ' late'],[myTrialQuality(3).name ' early'],[myTrialQuality(3).name ' late'],'Location','bestoutside');
    
    % title
    tt=title('early (tr. 11-30); late (tr. end-19:end)');
    
    %% Super title
    sp=suptitle('pupil data (mean)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Pupil_postVarenicline']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Pupil_postVarenicline']),'-painters','-r400');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIGURE BASELINE

% figure
fig12=figure(12);
fig12.Position = [100 100 500 840];

%% Baseline Plot: Mean for each odor and the laser

% clearing of data matrix before concatenation
clear myData_mean myData_pooled myData_mean_early myData_mean_late

% define quality of
myTrialQuality(1).odor_num = 37;
myTrialQuality(1).name = 'JAS';
myTrialQuality(1).color = [0.5 0 0];
myTrialQuality(2).odor_num = 35;
myTrialQuality(2).name = 'YY';
myTrialQuality(2).color = [0.5 0 0.5];
myTrialQuality(3).odor_num = 0;
myTrialQuality(3).name = 'LED';
myTrialQuality(3).color = [0 0 0.5];

% baseline
baseline_selection = [1:20];


% Loop over each odor/laser quality
for qual=1:length(myTrialQuality)
    % define empty matrix for pooling of the data
    myData_pooled(qual).pooledData=[];
    % Loop over session
    for sess = 1:length(summary_all)
        myData_mean(qual,sess,:)=nanmean(summary_all(sess).PupilDiameterMatrix([summary_all(sess).odor_num]==myTrialQuality(qual).odor_num,baseline_selection));
        % early
        clear helpMat
        helpMat = summary_all(sess).PupilDiameterMatrix([summary_all(sess).odor_num]==myTrialQuality(qual).odor_num,baseline_selection);
        myData_mean_early(qual,sess,:)=nanmean(helpMat(11:30,:));
        myData_mean_late(qual,sess,:)=nanmean(helpMat(end-19:end,:));
        
        myData_pooled(qual).pooledData=[myData_pooled(qual).pooledData;summary_all(sess).PupilDiameterMatrix([summary_all(sess).odor_num]==myTrialQuality(qual).odor_num,baseline_selection)];
    end
end

% subplot
clear sd
counter=1;
for qual=1:length(myTrialQuality)
    subplot(3,1,qual);
    hold on;
    sd{counter} = shadedErrorBar(1:size(squeeze(myData_mean_early(qual,:,:)),2),nanmean(squeeze(myData_mean_early(qual,:,:))),SEM_calc(squeeze(myData_mean_early(qual,:,:))));
    sd{counter}.mainLine.Color=myTrialQuality(qual).color;
    sd{counter}.mainLine.LineWidth=1.5;
    sd{counter}.mainLine.LineStyle=':';
    sd{counter}.patch.FaceColor=myTrialQuality(qual).color;
    sd{counter}.patch.EdgeColor='none';
    sd{counter}.edge(1).Color='none';
    sd{counter}.edge(2).Color='none';
    counter=counter+1;
    hold on;
    sd{counter} = shadedErrorBar(1:size(squeeze(myData_mean_late(qual,:,:)),2),nanmean(squeeze(myData_mean_late(qual,:,:))),SEM_calc(squeeze(myData_mean_late(qual,:,:))));
    sd{counter}.mainLine.Color=myTrialQuality(qual).color.*2;
    sd{counter}.mainLine.LineWidth=1.5;
    sd{counter}.mainLine.LineStyle='--';
    sd{counter}.patch.FaceColor=myTrialQuality(qual).color.*2;
    sd{counter}.patch.EdgeColor='none';
    sd{counter}.edge(1).Color='none';
    sd{counter}.edge(2).Color='none';
    counter=counter+1;     
    
    % axes
    ax=gca;
    % ax.YLim=[0.9,1.6];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XLim=[1,size(myData_mean,3)];
    ax.XTick=[1:10:size(myData_mean,3)];
    ax.XTickLabel=([-2:1:0]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % legend
    ll=legend([sd{counter-2}.mainLine,sd{counter-1}.mainLine],[myTrialQuality(qual).name ' early'],[myTrialQuality(qual).name ' late'],'Location','bestoutside'); 
    
    % ttest
    [h,p,ci,stat{qual}]=ttest(squeeze(myData_mean_early(qual,:,:)),squeeze(myData_mean_late(qual,:,:)));
    for p_indx = 1:length(p)
        if p(p_indx)<0.001
            tx = text(p_indx-0.2,ax.YLim(1)+0.95*(ax.YLim(2)-ax.YLim(1)),'*');
            tx.Color = myTrialQuality(qual).color;
            tx = text(p_indx-0.2,ax.YLim(1)+0.9*(ax.YLim(2)-ax.YLim(1)),'*');
            tx.Color = myTrialQuality(qual).color;
            tx = text(p_indx-0.2,ax.YLim(1)+0.85*(ax.YLim(2)-ax.YLim(1)),'*');
            tx.Color = myTrialQuality(qual).color;
        elseif p(p_indx)<0.01
            tx = text(p_indx-0.2,ax.YLim(1)+0.95*(ax.YLim(2)-ax.YLim(1)),'*');
            tx.Color = myTrialQuality(qual).color;
            tx = text(p_indx-0.2,ax.YLim(1)+0.9*(ax.YLim(2)-ax.YLim(1)),'*');
            tx.Color = myTrialQuality(qual).color;
                    elseif p(p_indx)<0.05
            tx = text(p_indx-0.2,ax.YLim(1)+0.95*(ax.YLim(2)-ax.YLim(1)),'*');
            tx.Color = myTrialQuality(qual).color;
        end
    end
   
end

% title
tt=title('early (tr. 11-30); late (tr. end-19:end)');

%% Super title
sp=suptitle('pupil data (baseline mean)');

% print
print('-dpsc',fullfile(outputDir,['Plots_Pupil_Baseline_postVarenicline']),'-painters','-r400','-append');
print('-dpdf',fullfile(outputDir,['Plots_Pupil_Baseline_postVarenicline']),'-painters','-r400');