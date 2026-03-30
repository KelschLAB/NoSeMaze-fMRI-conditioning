%% plot_meanFC_reappraisalVScontrol_jr.m
% script to compare mean connectivity between different time points of the
% task and the control group
% Reinwald, Jonathan 15.10.2023

%% pre-clearing
close all
clear all
clc

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))

%% Comparison selection
name_TP1='Odor11to40';
name_TP2='Odor81to120';
% name_TP1='TPnoPuff11to40';
% name_TP2='TPnoPuff81to120';

%% Take positive or positive and negative edges into account
take_negative_edges_into_account = 0; %1: take negative edges into account; 0: do not take negative edges into account

%% Selection of input
% cormat version
cormat_version_task = 'cormat_v11';
cormat_version_control = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% folder selection
if separated_hemisphere==1
    inputDirTask = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version_task filesep 'beta4D' filesep 'separated_hemisphere'];
    inputDirControl = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version_control filesep 'beta4D' filesep 'separated_hemisphere'];
elseif separated_hemisphere==0
    inputDirTask = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version_task filesep 'beta4D' filesep 'combined_hemisphere'];
    inputDirControl = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version_control filesep 'beta4D' filesep 'combined_hemisphere'];
end

%% Output directory
if separated_hemisphere==1
    outputDir = ['/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/' cormat_version_task filesep 'separated_hemisphere' filesep 'meanFC_plots'];
elseif separated_hemisphere==0
    outputDir = ['/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/' cormat_version_task filesep 'combined_hemisphere' filesep 'meanFC_plots'];
end
if ~exist(outputDir)
    mkdir(outputDir);
end
cd(outputDir);

%% Load cormats
% Task
load(fullfile(inputDirTask,[cormat_version_task '_' name_TP2 '.mat']));
c3_task=cat(3,cormat{:})
load(fullfile(inputDirTask,[cormat_version_task '_' name_TP1 '.mat']));
c1_task=cat(3,cormat{:})
% make diagonal nan
c1_task(c1_task==1)=nan;
c3_task(c3_task==1)=nan;
if take_negative_edges_into_account == 0
    c1_task(c1_task<=0)=nan;
    c3_task(c3_task<=0)=nan;
end
% calculate meanFC_diff
meanFC_diff_task = squeeze(nanmean(nanmean(c3_task)))-squeeze(nanmean(nanmean(c1_task)));
medianFC_diff_task = squeeze(nanmedian(nanmedian(c3_task)))-squeeze(nanmedian(nanmedian(c1_task)));

% Control
load(fullfile(inputDirControl,[cormat_version_control '_' name_TP2 '.mat']));
c3_con=cat(3,cormat{:})
load(fullfile(inputDirControl,[cormat_version_control '_' name_TP1 '.mat']));
c1_con=cat(3,cormat{:})
% make diagonal nan
c1_con(c1_con==1)=nan;
c3_con(c3_con==1)=nan;
if take_negative_edges_into_account == 0
    c1_con(c1_con<=0)=nan;
    c3_con(c3_con<=0)=nan;
end
% calculate meanFC_diff
meanFC_diff_con = squeeze(nanmean(nanmean(c3_con)))-squeeze(nanmean(nanmean(c1_con)));
medianFC_diff_con = squeeze(nanmedian(nanmedian(c3_con)))-squeeze(nanmedian(nanmedian(c1_con)));

% figure
fig(1)=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.6]);

% Loop:
for subpl_idx = 1:3
    subplot(1,3,subpl_idx);
    
    if subpl_idx==1
        bb{subpl_idx}=notBoxPlot_modified([squeeze(nanmean(nanmean(c1_task))),squeeze(nanmean(nanmean(c3_task)))]);
    elseif subpl_idx==2
        bb{subpl_idx}=notBoxPlot_modified([squeeze(nanmean(nanmean(c1_con))),squeeze(nanmean(nanmean(c3_con)))]);
    elseif subpl_idx==3
        bb{subpl_idx}=notBoxPlot_modified([meanFC_diff_task,meanFC_diff_con]);
    end

    for ib=1:length(bb{subpl_idx})
        bb{subpl_idx}(ib).data.MarkerSize=8;
        bb{subpl_idx}(ib).data.MarkerEdgeColor='none';
        bb{subpl_idx}(ib).semPtch.EdgeColor='none';
        bb{subpl_idx}(ib).sdPtch.EdgeColor='none';
    end

    if subpl_idx==1 || subpl_idx==2
        % color definitions
        bb{subpl_idx}(1).data.MarkerFaceColor= [204/255 51/255 204/255];
        bb{subpl_idx}(1).mu.Color= [204/255 51/255 204/255];
        bb{subpl_idx}(1).semPtch.FaceColor= [255/255 102/255 204/255];
        bb{subpl_idx}(1).sdPtch.FaceColor= [255/255 204/255 204/255];
        % color definitions
        bb{subpl_idx}(2).data.MarkerFaceColor= [0 160/255 227/255];
        bb{subpl_idx}(2).mu.Color= [0 160/255 227/255];
        bb{subpl_idx}(2).semPtch.FaceColor= [75/255 207/255 227/255];
        bb{subpl_idx}(2).sdPtch.FaceColor= [150/255 255/255 227/255];
    else
        % color definitions
        bb{subpl_idx}(1).data.MarkerFaceColor= [0/255 128/255 128/255];
        bb{subpl_idx}(1).mu.Color= [0/255 128/255 128/255];
        bb{subpl_idx}(1).semPtch.FaceColor= [102/255 200/255 200/255];
        bb{subpl_idx}(1).sdPtch.FaceColor= [204/255 230/255 230/255];
        bb{subpl_idx}(2).data.MarkerFaceColor= [75/255 75/255 75/255];
        bb{subpl_idx}(2).mu.Color= [75/255 75/255 75/255];
        bb{subpl_idx}(2).semPtch.FaceColor= [125/255 125/255 125/255];
        bb{subpl_idx}(2).sdPtch.FaceColor= [175/255 175/255 175/255];
    end

    % axis
    box('off');
    ax(subpl_idx)=gca;
    ax(subpl_idx).YLabel.String='A.U.';
    if subpl_idx~=3
        ax(subpl_idx).XTickLabel={'Bl. 1','Bl. 3'};
    elseif subpl_idx==3
        ax(subpl_idx).XTickLabel={'task','con'};
    end
    ax(subpl_idx).XLim=[.5,2.5];
    ax(subpl_idx).FontSize=20;
    ax(subpl_idx).FontWeight='bold';
    ax(subpl_idx).LineWidth=4;

    % title
    if subpl_idx==1
        tt=title('task');
    elseif subpl_idx==2
        tt=title('control');
    elseif subpl_idx==3
        tt=title('task vs control');
    end
    tt.Interpreter='none';

    % significance test
    if subpl_idx==1
        [h,p]=ttest(squeeze(nanmean(nanmean(c3_task))),squeeze(nanmean(nanmean(c1_task))));
        % [clusters, p_values, t_sums, permutation_distribution ] = permutest(squeeze(nanmean(nanmean(c3_task)))',squeeze(nanmean(nanmean(c1_task)))',true,0.05,10000,true);
        [~, ~, p_values] = permutation_test_paired(squeeze(nanmean(nanmean(c3_task)))',squeeze(nanmean(nanmean(c1_task)))', 10000, 'mean');
    elseif subpl_idx==2
        [h,p]=ttest(squeeze(nanmean(nanmean(c3_con))),squeeze(nanmean(nanmean(c1_con))));
        % [clusters, p_values, t_sums, permutation_distribution ] = permutest(squeeze(nanmean(nanmean(c3_con)))',squeeze(nanmean(nanmean(c1_con)))',true,0.05,10000,true);
        [~, ~, p_values] = permutation_test_paired(squeeze(nanmean(nanmean(c3_con)))',squeeze(nanmean(nanmean(c1_con)))', 10000, 'mean');
    elseif subpl_idx==3
        [h,p]=ttest2(meanFC_diff_task,meanFC_diff_con);
        % [clusters, p_values, t_sums, permutation_distribution ] = permutest(meanFC_diff_task',meanFC_diff_con',false,0.05,10000,true);
        [~, ~, p_values] = permutation_test_unpaired(meanFC_diff_task, meanFC_diff_con, 10000, 'mean');
    end
    % sign. star
    if p_values<0.05
        H=sigstar({[1,2]},p_values,0,30);
    end
    % plot permutation result
    tx=text(ax(subpl_idx).XLim(1)+.1*(diff(ax(subpl_idx).XLim)),ax(subpl_idx).YLim(1)+.2*(diff(ax(subpl_idx).YLim)),['p_p_e_r_m=' num2str(p_values)]);

    % ax limits
    if subpl_idx==2
        ax(1).YLim = [min([ax(1).YLim,ax(2).YLim]),round(max([ax(1).YLim,ax(2).YLim]),1)+0.05];
        ax(2).YLim = ax(1).YLim;
    end
end

% source data
plot_data  = [squeeze(nanmean(nanmean(c1_task))),squeeze(nanmean(nanmean(c3_task))),squeeze(nanmean(nanmean(c1_con))),squeeze(nanmean(nanmean(c3_con))),meanFC_diff_task,meanFC_diff_con];
SourceData = array2table(plot_data,'VariableNames',{'pre_task','test_task','pre_con','test_con','FCdiff_task','FCdiff_con'});
writetable(SourceData,fullfile(outputDir,['SourceData_Mean_FC_TaskVsControl_onlyPosEdges.csv']),'WriteVariableNames',true,'WriteRowNames',true)

% print
if take_negative_edges_into_account == 0
    [annot, srcInfo] = docDataSrc(fig(1),fullfile(outputDir),mfilename('fullpath'),logical(1));
    exportgraphics(fig(1),fullfile(outputDir,['Mean_FC_TaskVsControl_onlyPosEdges.pdf']),'Resolution',300);
    print('-dpsc',fullfile(outputDir,['Mean_FC_TaskVsControl_onlyPosEdges']),'-painters','-r400','-bestfit','-append');
else
    [annot, srcInfo] = docDataSrc(fig(1),fullfile(outputDir),mfilename('fullpath'),logical(1));
    exportgraphics(fig(1),fullfile(outputDir,['Mean_FC_TaskVsControl_postANDnegEdges.pdf']),'Resolution',300);
    print('-dpsc',fullfile(outputDir,['Mean_FC_TaskVsControl_postANDnegEdges']),'-painters','-r400','-bestfit','-append');   
end

% for ix=1:61; tempMat1 = cat(3,myMat_1{ix}{:}); tempMat2 = cat(3,myMat_2{ix}{:}); tempMat1(tempMat1==0)=nan; tempMat2(tempMat2==0)=nan; myDiff(ix,:)=squeeze(nanmean(nanmean(tempMat1)))-squeeze(nanmean(nanmean(tempMat2))); end