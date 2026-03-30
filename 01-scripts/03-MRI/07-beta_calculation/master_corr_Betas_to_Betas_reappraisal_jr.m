%% master_corr_Betas_to_Betas_reappraisal_jr.m
% Jonathan Reinwald, 26.04.2023

% Script loads the precalculated betas (from:
% /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/07-beta_calculation/master_calculate_and_plot_mean_betas_jr.m)
% and correlates them to each other

% load activation/deactivation at odor and tp of no puff and write them
% into beta_table
clear beta_table

% select input

load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_v22_OdorBl3vsBl1_T01.mat');
beta_table=table(res.mean_beta_Lavender_Bl1_11to40','VariableNames',{'S1_bl1'});
beta_table=[beta_table,table(res.mean_beta_Lavender_Bl3','VariableNames',{'S1_bl3'})];
beta_table=[beta_table,table(res.mean_beta_Lavender_Bl3'-res.mean_beta_Lavender_Bl1_11to40','VariableNames',{'S1_bl3vsbl1'})];
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_v22_OdorBl3vsBl1_T01.mat');
beta_table=[beta_table,table(res.mean_beta_Lavender_Bl1_11to40','VariableNames',{'PFC_bl1'})];
beta_table=[beta_table,table(res.mean_beta_Lavender_Bl3','VariableNames',{'PFC_bl3'})];
beta_table=[beta_table,table(res.mean_beta_Lavender_Bl3'-res.mean_beta_Lavender_Bl1_11to40','VariableNames',{'PFC_bl3vsbl1'})];
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T01.mat');
beta_table=[beta_table,table(res.mean_beta_TP_Puff_Bl1_11to40','VariableNames',{'INS_bl1'})];
beta_table=[beta_table,table(res.mean_beta_TP_Puff_Bl3','VariableNames',{'INS_bl3'})];
beta_table=[beta_table,table(res.mean_beta_TP_Puff_Bl3'-res.mean_beta_TP_Puff_Bl1_11to40','VariableNames',{'INS_bl3vsbl1'})];
% load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_v22_Bl3vsBl1_T01.mat');
% beta_table=[beta_table,table(res.mean_beta_TP_Puff_Bl1_11to40','VariableNames',{'S1new_bl1'})];
% beta_table=[beta_table,table(res.mean_beta_TP_Puff_Bl3','VariableNames',{'S1new_bl3'})];
% beta_table=[beta_table,table(res.mean_beta_TP_Puff_Bl3'-res.mean_beta_TP_Puff_Bl1_11to40','VariableNames',{'S1new_bl3vsbl1'})];

%% Overview plot correlation analysis
% figure
fig1=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);

% calculation of correlation coefficients
% in here: selection of the beta differences
input=beta_table(:,:);
[rho,p]=corr(table2array(input));
rho(logical(triu(p)))=nan;
p(logical(triu(p)))=nan;

% plot
imagesc(rho);
set(gca,'dataAspectRatio',[1 1 1])
ax=gca;
set(gca,'TickLabelInterpreter','none');
ax.CLim=[-1,1];
ax.Colormap=jet;
variablenames=input.Properties.VariableNames;
ax.XTick=[1:length(variablenames)];
ax.XTickLabel=variablenames;
ax.YTick=[1:length(variablenames)];
ax.YTickLabel=variablenames;
ax.FontSize=8;
rotateXLabels(ax,90);

% Title
tt = title('Correlation Coefficients');
[pID,pN,qvalues] = FDR(p(:),0.05);
clear fdrmat
if ~isempty(pID)
    fdrmat=p<=pID;
else
    fdrmat=logical(zeros(size(p)));
end

grid on
% Mark not FDR_corrected values
for x=1:size(p,1)
    for y=1:size(p,2) %size(T,2);
        if fdrmat(y,x)
            xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
            line(xv,yv,'linewidth',4,'color',[1 0 0]);
        elseif p(y,x)<0.05
            xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
            line(xv,yv,'linewidth',4,'color',[0 0 0],'Linestyle',':');        
        end
    end
end

%% 
