%% corr_BetaCoeffToGlobalGA_jr.m

% Script for correlation between the change in betas and the change in global graph
% metrics
% Reinwald, 06/2022

% Before running the script calculate beta coefficients and global metrics: 

% 1. run master_calculate_and_plot_mean_betas_jr.m to calculate and save
% beta coefficients in GLM folder (under respictive comparison, e.g. 
% TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40) --> mask_activation_Ins_T3485_v24.mat

% 2. run plot_pairedTT_globMetGA_reappraisal_jr.m to calculate and save
% global graph metrics in
% /home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/cormat_v8/combined_hemisphere/bin_connected
% --> res_auc_struc.mat

%% Clearing
clear all
close all
clc

%% Comparison selection
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';
% name_TP1='Odor11to40';
% name_TP2='TPnoPuff11to40';
% name_TP1='Odor81to120';
% name_TP2='TPnoPuff81to120';
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';

%% Selection of input
% cormat version
cormat_version = 'cormat_v10';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';

%% Load beta coefficients (saved in script master_calculate_and_plot_mean_betas_jr.m)
% res.mat
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v5___ORTH_1___DERDISP0___17-May-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3485_v24.mat');

%% Load global metrics (saved in plot_pairedTT_globMetGA_reappraisal_jr.m)
% res_auc_struc_global.mat -->  res_auc_struc
if separated_hemisphere==1
%     load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version '/separated_hemisphere/' binarization_method '_' connectedness '/res_auc_struc.mat']);
    load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/res_auc_struc_global.mat']);
elseif separated_hemisphere==0
    load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '/res_auc_struc_global.mat']);
end
% define global metrics
global_metrics = fieldnames(res_auc_struc);

%% Output directory
outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-GA_to_BetaCoeff');
if separated_hemisphere==1
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-GA_to_BetaCoeff',cormat_version,'separated_hemisphere',[binarization_method '_' connectedness],[name_TP1 'VS' name_TP2]);
elseif separated_hemisphere==0
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-GA_to_BetaCoeff',cormat_version,'combined_hemisphere',[binarization_method '_' connectedness],[name_TP1 'VS' name_TP2]);
end
mkdir(outputDir);
cd(outputDir);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over global metrics
for ix=1:length(global_metrics)
    % figure
    figure(ix);
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
    % Statistics
    % 1. Pearson
    [h_p(ix),p_p(ix)]=corr(([res.mean_betaPos]'-[res.mean_betaNeg]'),([res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40]),'type','Pearson');
    % 2. Spearman
    [h_sp(ix),p_sp(ix)]=corr(([res.mean_betaPos]'-[res.mean_betaNeg]'),([res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40]),'type','Spearman');
    
    
    % Subplot 2: 
    subplot(2,2,1:2);
    % scatter plot
    sc(1)=scatter(([res.mean_betaPos]'-[res.mean_betaNeg]'),([res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40]));
    sc(1).MarkerFaceAlpha=1; sc(1).SizeData=20;
    sc(1).MarkerFaceColor=[.8 .4 .4];
    sc(1).MarkerEdgeAlpha=1;
    sc(1).MarkerEdgeColor='none';
    % axes definition
    ax=gca;
    ax.XLabel.String = {'Beta [diffTP2-TP1]'};
    ax.YLabel.String = {'Global Metric [diffTP2-TP1]'};
    ax.LineWidth = 1.5;
    % line
    ll=lsline;
    ll.LineWidth=1.5;
    ll.Color=[.8 .4 .4];
    ll.LineStyle='--';
    % title
    tt=title([global_metrics{ix} ', Pearson']);
    tt.Interpreter='none';
    % text
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(p_p(ix),2))]);
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['rho=' num2str(round(h_p(ix),2))]);
    
    % Subplot 2: 
    subplot(2,2,3:4);
    % scatter plot
    clear A1 A2 B1 B2
    [~,A1]=sort([res.mean_betaPos]'-[res.mean_betaNeg]');
    [~,B1]=sort(A1);
    [~,A2]=sort([res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40]);
    [~,B2]=sort(A2);
    sc(1)=scatter(B1,B2);
    sc(1).MarkerFaceAlpha=1; sc(1).SizeData=20;
    sc(1).MarkerFaceColor=[.8 .4 .4];
    sc(1).MarkerEdgeAlpha=1;
    sc(1).MarkerEdgeColor='none';
    % axes definition
    ax=gca;
    ax.XLabel.String = {'Beta [rank, diffTP2-TP1]'};
    ax.YLabel.String = {'Global Metric [rank, diffTP2-TP1]'};
    ax.XLim=[0,25];
    ax.YLim=[0,25];
    ax.LineWidth = 1.5;
    % line
    ll=lsline;
    ll.LineWidth=1.5;
    ll.Color=[.8 .4 .4];
    ll.LineStyle='--';
    % title
    tt=title([global_metrics{ix} ', Spearman']);
    tt.Interpreter='none';
    % text
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(round(p_sp(ix),2))]);
    tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['rho=' num2str(round(h_sp(ix),2))]);
    
    % print
    print('-dpsc',fullfile(outputDir,['Correlation_BetaCoeffToGlobalGA']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Correlation_BetaCoeffToGlobalGA_' global_metrics{ix}]),'-painters','-r400');
    
    close all;
end