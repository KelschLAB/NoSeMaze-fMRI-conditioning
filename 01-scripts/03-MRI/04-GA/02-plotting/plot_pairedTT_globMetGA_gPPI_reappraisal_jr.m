%% plot_pairedTT_globMetGA_gPPI_reappraisal_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Comparison selection
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';
name_TP1='TP_Puff_Bl1_11to40';
name_TP2='TP_Puff_Bl3';

%% Selection of method
% bi-/unihemispheric atlas
separated_hemisphere = 2;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness_val = 'connected';

%% Select preprocessing type
mySelectedGLM = 'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023';

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));
% add GA scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-GitLab'));
% add brain connectivity toolbox
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/2019_03_03_BCT'));

%% Load filelist
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')
end

%% Define directories
% main directory
if separated_hemisphere==0
    mainDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/combined_hemisphere/',mySelectedGLM);
elseif separated_hemisphere==1
    mainDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/separated_hemisphere/',mySelectedGLM);
elseif separated_hemisphere==2
    mainDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/separated_v2_2023_hemisphere/',mySelectedGLM);
end
% output directory
[fdir,fname2,~]=fileparts(mainDir);
[~,fname1,~]=fileparts(fdir);
inputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/09-GA_gPPI',fname1,fname2,binarization_method);
cd(inputDir)
% load PPI file
load(fullfile(mainDir,'results_PPI_symmetric.mat'));
% output directory
outputDir = fullfile(inputDir,'plots');
if ~exist(outputDir)
    mkdir(outputDir);
end
cd(outputDir);

%% Load input data
load(fullfile(inputDir,['auc_struc_' name_TP1 '_p.mat']));
auc_struc_TP1 = auc_struc;
load(fullfile(inputDir,['auc_struc_' name_TP2 '_p.mat']));
auc_struc_TP2 = auc_struc;

%% Selection of global metrics
metricnames_all = fieldnames(auc_struc_TP1)
global_metrics = metricnames_all(contains(fieldnames(auc_struc_TP1),'g_'))
% throw out: null models, _JR (doubled), _clus,  _path (both for SWP)
global_metrics=global_metrics(logical(~contains(global_metrics,'_JR') .* ~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
if strcmp(binarization_method,'max')
    global_metrics(7)=[];
end

%% Loop over global names for plotting
for ig=1:length(global_metrics)
    clear h ax
    
    % figure
    fig(ig)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
    % boxplot
    bb=notBoxPlot_modified([[auc_struc_TP1.(global_metrics{ig})]',[auc_struc_TP2.(global_metrics{ig})]']);
    for ib=1:length(bb)
        bb(ib).data.MarkerSize=8;
        bb(ib).data.MarkerEdgeColor='none';
        bb(ib).semPtch.EdgeColor='none';
        bb(ib).sdPtch.EdgeColor='none';
    end
    % color definitions
    bb(1).data.MarkerFaceColor= [204/255 51/255 204/255];
    bb(1).mu.Color= [204/255 51/255 204/255];
    bb(1).semPtch.FaceColor= [255/255 102/255 204/255];
    bb(1).sdPtch.FaceColor= [255/255 204/255 204/255];
    % color definitions
    bb(2).data.MarkerFaceColor= [0 160/255 227/255];
    bb(2).mu.Color= [0 160/255 227/255];
    bb(2).semPtch.FaceColor= [75/255 207/255 227/255];
    bb(2).sdPtch.FaceColor= [150/255 255/255 227/255];
    
    % axis
    box('off');
    ax=gca;
    %     ax.YLim=[axlimit{ig}];
    ax.YLabel.String='A.U.';
    ax.XTickLabel={'Bl. 1','Bl. 3'};
    ax.XLim=[.5,2.5];
    ax.FontSize=18;
    ax.FontWeight='bold';
    ax.LineWidth=2;
    %     rotateXLabels(ax,45);
    % title
    tt=title({global_metrics{ig};[name_TP1 ' vs ' name_TP2]});
    tt.Interpreter='none';
    
    % significance test
    [h,p]=ttest([auc_struc_TP1.(global_metrics{ig})]',[auc_struc_TP2.(global_metrics{ig})]');
    [clusters, p_values, t_sums, permutation_distribution ] = permutest([auc_struc_TP1.(global_metrics{ig})],[auc_struc_TP2.(global_metrics{ig})],true,0.05,10000,true);
    % sign. star
    if p_values<0.05
        H=sigstar({[1,2]},p_values,0,30);
    end
    % plot permutation result
    tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_p_e_r_m=' num2str(p_values)]);
    
    % results for saving
    res_auc_struc.(global_metrics{ig}).(name_TP1) = [auc_struc_TP1.(global_metrics{ig})]';
    res_auc_struc.(global_metrics{ig}).(name_TP2) = [auc_struc_TP2.(global_metrics{ig})]';
    
    % print
    [annot, srcInfo] = docDataSrc(fig(ig),fullfile(outputDir),mfilename('fullpath'),logical(1));
    exportgraphics(fig(ig),fullfile(outputDir,['GA_global_' global_metrics{ig} '.pdf']),'Resolution',300);
    print('-dpsc',fullfile(outputDir,['GA_global']),'-painters','-r400','-append');
    
    % close
    close all;
end
% save data
save(fullfile(outputDir,['res_auc_struc_global.mat']),'res_auc_struc');
