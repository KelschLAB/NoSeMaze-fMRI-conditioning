%% plot_globMetGA_reappraisalVScontrol_thresholdPlot_jr.m

%% Clearing
close all
clear all
clc

%% Path setting
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));

%% Selection of input
% cormat version
cormat_version_task = 'cormat_v11';
cormat_version_control = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';
% folder selection
if separated_hemisphere==2
    controlDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness];
    taskDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness];
    outputDir=['/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version_task filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness filesep 'threshold_plots'];
elseif separated_hemisphere==1
    controlDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
    taskDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
    outputDir=['/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version_task filesep 'separated_hemisphere' filesep binarization_method '_' connectedness filesep 'threshold_plots'];
elseif separated_hemisphere==0
    controlDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    taskDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    outputDir=['/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version_task filesep 'combined_hemisphere' filesep binarization_method '_' connectedness filesep 'threshold_plots'];
end
outputDir = fullfile(outputDir,[cormat_version_task 'VS' cormat_version_control]);
mkdir(outputDir);
cd(outputDir);
if exist(fullfile(outputDir,'GA_global_TaskVsCon_thresholdPlot.ps'))==2
    delete(fullfile(outputDir,'GA_global_TaskVsCon_thresholdPlot.ps'));
end

%% global metric selection
global_metrics = {'g_delta_C','g_delta_L','g_swp','g_cpl','g_cc','g_swi'};%,'g_modularity','g_reg_path','g_reg_clus','g_rand_path','g_rand_clus','g_net_path','g_net_clus'};

%% LOOP over global metrics
for gx=1:length(global_metrics)
    % figure
    fig(gx)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.8,0.7]);
    
    % load data
    clear myData
    load(fullfile(controlDir,'gstruc_TPnoPuff81to120_p.mat'));
    for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myData{1}(ix,jx)=gstruc(ix,jx).(global_metrics{gx}); end; end
    load(fullfile(controlDir,'gstruc_TPnoPuff11to40_p.mat'));
    for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myData{2}(ix,jx)=gstruc(ix,jx).(global_metrics{gx}); end; end
    load(fullfile(taskDir,'gstruc_TPnoPuff81to120_p.mat'));
    for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myData{3}(ix,jx)=gstruc(ix,jx).(global_metrics{gx}); end; end
    load(fullfile(taskDir,'gstruc_TPnoPuff11to40_p.mat'));
    for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myData{4}(ix,jx)=gstruc(ix,jx).(global_metrics{gx}); end; end
    
    cohort_name = {'control_test_block','control_pre_block','task_test_block','task_pre_block'};
%     myData{1}=myData{1}(:,[1:4,6:end])
%     myData{2}=myData{2}(:,[1:4,6:end])
    % plot
    subplot(2,3,1);
    clear sd;
    hold on;
    for data_ix=1:length(myData)
        sd{data_ix}=shadedErrorBar([1:size(myData{data_ix},1)],nanmean(myData{data_ix}'),SEM_calc(myData{data_ix}'));
        sd{data_ix}.edge(1).Color='none';
        sd{data_ix}.edge(2).Color='none';
        sd{data_ix}.mainLine.LineWidth=2;
        if data_ix<3
            sd{data_ix}.mainLine.LineStyle='--';
        end
        
        % save source data for plot
        clear VarNames RowNames       
        for i = 1:size(myData{data_ix},1)
            VarNames{i} = ['timebin_' num2str(i)];
        end
        for i = 1:size(myData{data_ix},2)
            RowNames{i} = ['AnimalAbbrev' num2str(i)];
        end
        SourceData = array2table(myData{data_ix}','VariableNames',VarNames,'RowNames',RowNames);
        writetable(SourceData,fullfile(outputDir,['SourceData_' global_metrics{gx} '_' cohort_name{data_ix} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
 
    end
    % color definitions
    sd{1}.mainLine.Color= [0 160/255 227/255].*0.5;
    sd{1}.patch.FaceColor= [0 160/255 227/255].*0.5;
    sd{2}.mainLine.Color= [204/255 51/255 204/255].*0.5;
    sd{2}.patch.FaceColor= [204/255 51/255 204/255].*0.5;
    sd{3}.mainLine.Color= [0 160/255 227/255];
    sd{3}.patch.FaceColor= [0 160/255 227/255];
    sd{4}.mainLine.Color= [204/255 51/255 204/255];
    sd{4}.patch.FaceColor= [204/255 51/255 204/255];
    % axes
    ax=gca;
    ax.XLim=[1,41];
    if gx>0 && gx<4
        ax.YLim=[0,1]
    end
    yLim=ax.YLim;
    ax.XTick=[1:5:41];
    ax.XTickLabel=[0:5:40]+10;
    ax.XLabel.String={'sparsity threshold','(%)'};
    ax.YLabel.String={'A.U.'};ax.YLabel.Interpreter='none';
    ax.FontSize=10;
    ax.LineWidth=1.5;
    % statistics
    %     [h,p]=ttest(myData{3}(1:41,:)',myData{4}(1:41,:)');
    for ix=1:41;
        [~, p_values(ix), ~, ~] = permutest(myData{3}(ix,:),myData{4}(ix,:),true,0.05,10000,true);
    end
    for ix=1:length(p_values)
        if p_values(ix)<0.001
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.85*(yLim(2)-yLim(1)),'*');
        elseif p_values(ix)<0.01
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
        elseif p_values(ix)<0.05
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
        elseif p_values(ix)<0.1
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'^{#}');
        end
    end
    % legend
    ll=legend({'control: bl.3','control: bl.1','task: bl.3','task: bl.1'},'Location','north');
    
    % plot
    subplot(2,3,2);
    clear sd;
    hold on;
    for data_ix=[1,3]
        sd{data_ix}=shadedErrorBar([1:size(myData{data_ix},1)],nanmean(myData{data_ix}'-myData{data_ix+1}'),SEM_calc(myData{data_ix}'-myData{data_ix+1}'));
        sd{data_ix}.edge(1).Color='none';
        sd{data_ix}.edge(2).Color='none';
        sd{data_ix}.mainLine.LineWidth=2;
        % save source data for plot
        clear VarNames RowNames       
        for i = 1:size(myData{data_ix},1)
            VarNames{i} = ['timebin_' num2str(i)];
        end
        for i = 1:size(myData{data_ix},2)
            RowNames{i} = ['AnimalAbbrev' num2str(i)];
        end
        SourceData = array2table(myData{data_ix}'-myData{data_ix+1}','VariableNames',VarNames,'RowNames',RowNames);
        if data_ix==1
            writetable(SourceData,fullfile(outputDir,['SourceData_Diff_' global_metrics{gx} '_control.csv']),'WriteVariableNames',true,'WriteRowNames',true)
        else
            writetable(SourceData,fullfile(outputDir,['SourceData_Diff_' global_metrics{gx} '_task.csv']),'WriteVariableNames',true,'WriteRowNames',true)
        end
    end
    % color definitions
    sd{1}.mainLine.Color= [75/255 75/255 75/255];
    sd{1}.patch.FaceColor= [75/255 75/255 75/255];
    sd{3}.mainLine.Color= [0/255 128/255 128/255];
    sd{3}.patch.FaceColor= [0/255 128/255 128/255];
    
    
    % axes
    ax=gca;
    ax.XLim=[1,41];
    yLim=ax.YLim;
    ax.XTick=[1:5:41];
    ax.XTickLabel=[0:5:40]+10;
    ax.XLabel.String={'sparsity threshold','(%)'};
    ax.YLabel.String={'A.U.','(bl. 3 - bl. 1)'};ax.YLabel.Interpreter='none';
    ax.FontSize=10;
    ax.LineWidth=1.5;
    % statistics
%     [h,p]=ttest2(myData{1}'-myData{2}',myData{3}(1:41,:)'-myData{4}(1:41,:)');
    for ix=1:41
        [p_perm(ix), observeddifference_perm(ix), effectsize_perm(ix)] = permutationTest(myData{1}(ix,:)'-myData{2}(ix,:)',myData{3}(ix,:)'-myData{4}(ix,:)',10000)
    end
    for ix=1:length(p_perm)
        if p_perm(ix)<0.001
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.85*(yLim(2)-yLim(1)),'*');
        elseif p_perm(ix)<0.01
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
        elseif p_perm(ix)<0.05
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
        elseif p_perm(ix)<0.1
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'^{#}');
        end
    end

    % legend
    ll=legend({'control','task'},'Location','north');

    
    %%
    %% Load NoSeMaze input (social hierarchy and chasing data)
    % read table for info on animals ID and pairing
    T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);
    
    % load different hierarchies
    % animals in AM1 were scanned at different days (either D45 or D51)
    load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
    % tube hierarchy
    DS_info1_3to16 = DS_info;
    clear Idx Rank
    [~,Idx]=sort([DS_info1_3to16.DS],'descend');
    [~,Rank]=sort(Idx);
    DS_info1_3to16.Rank = Rank;
    DS_info1_3to16.DSzscored = zscore([DS_info1_3to16.DS]);
    % chasing
    DSchasing_info1_3to16 = DS_info_chasing;
    clear Idx Rank
    [~,Idx]=sort([DSchasing_info1_3to16.DS],'descend');
    [~,Rank]=sort(Idx);
    DSchasing_info1_3to16.Rank = Rank;
    DSchasing_info1_3to16.DSzscored = zscore([DSchasing_info1_3to16.DS]);
    
    load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day8to21_12mice_withChasing.mat','DS_info','DS_info_chasing');
    DS_info1_8to21 = DS_info;
    clear Idx Rank
    % tube hierarchy
    [~,Idx]=sort([DS_info1_8to21.DS],'descend');
    [~,Rank]=sort(Idx);
    DS_info1_8to21.Rank = Rank;
    DS_info1_8to21.DSzscored = zscore([DS_info1_8to21.DS]);
    % chasing
    DSchasing_info1_8to21 = DS_info_chasing;
    clear Idx Rank
    [~,Idx]=sort([DSchasing_info1_8to21.DS],'descend');
    [~,Rank]=sort(Idx);
    DSchasing_info1_8to21.Rank = Rank;
    DSchasing_info1_8to21.DSzscored = zscore([DSchasing_info1_8to21.DS]);
    
    % animals in AM1 were scanned at different days (either D44 and D45)
    load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14_12mice_withChasing.mat','DS_info','DS_info_chasing');
    % tube hierarchy
    DS_info2 = DS_info;
    clear Idx Rank
    [~,Idx]=sort([DS_info2.DS],'descend');
    [~,Rank]=sort(Idx);
    DS_info2.Rank = Rank;
    DS_info2.DSzscored = zscore([DS_info2.DS]);
    % chasing
    DSchasing_info2 = DS_info_chasing;
    clear Idx Rank
    [~,Idx]=sort([DSchasing_info2.DS],'descend');
    [~,Rank]=sort(Idx);
    DSchasing_info2.Rank = Rank;
    DSchasing_info2.DSzscored = zscore([DSchasing_info2.DS]);
    
    clear info
    counter=1;
    for idxT = 1:size(T,1)
        % add info on IDs
        info.ID_own{counter}=T.AnimalIDCombined{idxT};
        % add infos on Davids Score and Rank for NoSeMaze 1
        if T.Autonomouse(idxT)==1
            info.NoSeMaze(counter)=1;
            info.AnimalNumb(counter)=T.AnimalNumber(idxT);
            if contains(T.DaysToConsider{idxT},'16')
                % tube hierarchy
                info.DS_own(counter)=DS_info1_3to16.DS(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
                info.Rank_own(counter)=DS_info1_3to16.Rank(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
                info.DSzscored_own(counter)=DS_info1_3to16.DSzscored(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
                % chasing
                info.DS_chasing(counter)=DSchasing_info1_3to16.DS(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
                info.Rank_chasing(counter)=DSchasing_info1_3to16.Rank(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
                info.DSzscored_chasing(counter)=DSchasing_info1_3to16.DSzscored(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            elseif contains(T.DaysToConsider{idxT},'21')
                % tube hierarchy
                info.DS_own(counter)=DS_info1_8to21.DS(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
                info.Rank_own(counter)=DS_info1_8to21.Rank(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
                info.DSzscored_own(counter)=DS_info1_8to21.DSzscored(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
                % chasing
                info.DS_chasing(counter)=DSchasing_info1_8to21.DS(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
                info.Rank_chasing(counter)=DSchasing_info1_8to21.Rank(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
                info.DSzscored_chasing(counter)=DSchasing_info1_8to21.DSzscored(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            end
            counter=counter+1;
            % add infos on Davids Score and Rank for NoSeMaze 2
        elseif T.Autonomouse(idxT)==2
            info.NoSeMaze(counter)=2;
            info.AnimalNumb(counter)=T.AnimalNumber(idxT);
            % tube hierarchy
            info.DS_own(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info2.DSzscored(strcmp(DS_info2.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info2.DS(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info2.Rank(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info2.DSzscored(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
            counter=counter+1;
        end
    end
    
    ExplVar(1).name = 'DavidsScore';
    ExplVar(1).values = info.DS_own';
    ExplVar(1).ID = info.ID_own;
    %%%%% David's score plot
    [DSv,DSi]=sort(info.DS_own','descend');
    ExplVar(1).DS_sorted = DSv;
    ExplVar(1).DS_sortedIndex = DSi;
    
    ExplVar(2).name = 'Rank';
    ExplVar(2).values = info.Rank_own';
    ExplVar(2).ID = info.ID_own;
    %%%%% David's score plot
    [DSv,DSi]=sort(info.Rank_own','descend');
    ExplVar(2).DS_sorted = DSv;
    ExplVar(2).DS_sortedIndex = DSi;
    
    ExplVar(3).name = 'DavidsScore_zscored';
    ExplVar(3).values = info.DSzscored_own';
    ExplVar(3).ID = info.ID_own;
    %%%%% David's score plot
    [DSv,DSi]=sort(info.DSzscored_own','descend');
    ExplVar(3).DS_sorted = DSv;
    ExplVar(3).DS_sortedIndex = DSi;
    
    ExplVar(4).name = 'DavidsScoreChasing';
    ExplVar(4).values = info.DS_chasing';
    ExplVar(4).ID = info.ID_own;
    %%%%% David's score plot
    [DSv,DSi]=sort(info.DS_chasing','descend');
    ExplVar(4).DS_sorted = DSv;
    ExplVar(4).DS_sortedIndex = DSi;
    
    ExplVar(5).name = 'RankChasing';
    ExplVar(5).values = info.Rank_chasing';
    ExplVar(5).ID = info.ID_own;
    %%%%% David's score plot
    [DSv,DSi]=sort(info.Rank_chasing','descend');
    ExplVar(5).DS_sorted = DSv;
    ExplVar(5).DS_sortedIndex = DSi;
    
    ExplVar(6).name = 'DavidsScoreChasing_zscored';
    ExplVar(6).values = info.DSzscored_chasing';
    ExplVar(6).ID = info.ID_own;
    %%%%% David's score plot
    [DSv,DSi]=sort(info.DSzscored_chasing','descend');
    ExplVar(6).DS_sorted = DSv;
    ExplVar(6).DS_sortedIndex = DSi;
    
    %% define ID and Animal numb for all regressors
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
    for ix=1:length(ExplVar)
        for jx=1:length(ExplVar(ix).ID)
            ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
        end
    end    
    [~,sortIdx]=sort(ExplVar(2).AnimalNumb);
    NoSeMaze_Rank = ExplVar(2).values(sortIdx);
    NoSeMaze_DsZ = ExplVar(3).values(sortIdx);  
    
    %% 
    subplot(2,3,3)
    % Correlation to rank
    [rho,p]=corr((myData{3}(1:41,:)'-myData{4}(1:41,:)'),NoSeMaze_Rank);
    pp=plot(rho);
    % save source data for plot
    clear VarNames RowNames
    for i = 1:size(myData{3}(1:41,:)',2)
        VarNames{i} = ['timebin_' num2str(i)];
    end
    SourceData = array2table(rho','VariableNames',VarNames,'RowNames',{'Pearsons_rho'});
    writetable(SourceData,fullfile(outputDir,['SourceData_corrCoeff_' global_metrics{gx} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)

    pp.LineWidth=2;
    % axes
    ax=gca;
    ax.Box='off';
    ax.XLim=[1,41];
    ax.YLim=[-.7,.7];
    yLim=ax.YLim;
    ax.XTick=[1:5:41];
    ax.XTickLabel=[0:5:40]+10;
    ax.XLabel.String={'sparsity threshold','(%)'};
    ax.YLabel.String={'corr. coeff','(Pearsons r)'};
    ax.FontSize=10;
    ax.LineWidth=1.5;
    % mark statistical sign.
    for ix=1:length(rho)
        if p(ix)<0.001
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.85*(yLim(2)-yLim(1)),'*');
        elseif p(ix)<0.01
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
            tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
        elseif p(ix)<0.05
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'*');
        elseif p(ix)<0.1
            tx=text(ix-0.5,yLim(1)+0.95*(yLim(2)-yLim(1)),'^{#}');
        end
    end
    % title
    tt=title('correlation: rank');
    
%     subplot(2,2,4)    
%     % Correlation to rank
%     [rho,p]=corr((myData{3}(1:61,:)'-myData{4}(1:61,:)'),NoSeMaze_DsZ);
%     pp=plot(rho);
%     pp.LineWidth=2;
%     % axes
%     ax=gca;
%     ax.Box='off';
%     ax.XLim=[1,41];
%     ax.YLim=[-.7,.7];
%     yLim=ax.YLim;
%     ax.XTick=[1:5:41];
%     ax.XTickLabel=[0:5:40]+10;
%     ax.XLabel.String={'sparsity threshold','(%)'};
%     ax.YLabel.String={'corr. coeff','Pearson'};
%     ax.FontSize=10;
%     ax.LineWidth=1.5;
%     % mark statistical sign.
%     for ix=1:length(rho)
%         if p(ix)<0.05
%             tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
%         elseif p(ix)<0.1
%             tx=text(ix-0.5,yLim(1)+0.9*(yLim(2)-yLim(1)),'^{#}');
%         end
%     end
%     % title
%     tt=title('correlation: DS (z-scored)');
%     
%     hold on;
%     pp2=plot(effectsize_perm);
%     pp.LineWidth=2;
%     pp.LineStyle='--';
%     
%     % legend
%     ll=legend({'corr. coeff','effectsize'},'Location','north');

    %% suptitle
    sup=suptitle(global_metrics{gx});
    sup.Interpreter='none';
    
    % print
    [annot, srcInfo] = docDataSrc(fig(gx),fullfile(outputDir),mfilename('fullpath'),logical(1));
    exportgraphics(fig(gx),fullfile(outputDir,['GA_' global_metrics{gx} '_TaskVsCon_thresholdPlot.pdf']),'Resolution',300);
    print('-dpsc',fullfile(outputDir,['GA_global_TaskVsCon_thresholdPlot']),'-painters','-bestfit','-r400','-append');
end

close all
