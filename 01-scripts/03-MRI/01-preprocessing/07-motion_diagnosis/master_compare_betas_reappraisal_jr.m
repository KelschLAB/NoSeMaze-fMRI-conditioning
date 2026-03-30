%% master_compare_betas_reappraisal_jr.m
% XXX
% Jonathan Reinwald, 08.08.2023

% clearing
clear all
close all
clc

% Define the different preprocessing methods for the comparison
preprocessing_names = {'RP12_CSF2','RP12_CSF2_AFNI','RP12_CSF2_WD','RP12_CSF2_AFNI_WD','RP12_CSF2_AFNI_WD_scrub','RP12_CSF2_WD_scrub','RP12_CSF2_AFNI_WD_DVARSscrub'};
% use the folders from the mean TC construction in here (as the RPs are already included as covariates)
preprocessing_folders = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v22___COV_v2___ORTH_1___DERDISP0___07-Aug-2023',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___29-Mar-2023',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_scrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___08-Aug-2023',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_scrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_del5____ROI_v22___COV_v2___ORTH_1___DERDISP0___08-Aug-2023',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023',...
    };

%% Loop over preprocessing methods
for ppm_idx = 1:length(preprocessing_names)
    
    load(fullfile(preprocessing_folders{ppm_idx},'beta_coefficients_covariates.mat'));
    load(fullfile(preprocessing_folders{ppm_idx},'beta_coefficients_regressors.mat'));
    
    for subj=1:length(myBetaValuesCovariates)
        
        COV{ppm_idx,subj}=myBetaValuesCovariates(subj).beta_coeff;
        ROI{ppm_idx,subj}=myBetaValuesRegressors(subj).beta_coeff;
        
        COV_mean(ppm_idx,subj,:)=nanmean(COV{ppm_idx,subj}./COV{1,subj},2);
        COV_median(ppm_idx,subj,:)=nanmedian(COV{ppm_idx,subj}./COV{1,subj},2);
        
        ROI_mean(ppm_idx,subj,:)=nanmean(ROI{ppm_idx,subj}./ROI{1,subj},2);
        ROI_median(ppm_idx,subj,:)=nanmedian(ROI{ppm_idx,subj}./ROI{1,subj},2);
        
        %         COV_mean(ppm_idx,subj,:)=nanmean(COV{ppm_idx,subj},2);%./COV{1,subj},2);
        %         COV_median(ppm_idx,subj,:)=nanmedian(COV{ppm_idx,subj},2);%./COV{1,subj},2);
        %
        %         ROI_mean(ppm_idx,subj,:)=nanmean(ROI{ppm_idx,subj},2);%./ROI{1,subj},2);
        %         ROI_median(ppm_idx,subj,:)=nanmedian(ROI{ppm_idx,subj},2);%./ROI{1,subj},2);
        
        
        %         cov_div{ppm_idx}=co v_all{ppm_idx}./cov_all{1};
        %     reg_div{ppm_idx}=reg_all{ppm_idx}./reg_all{1};
    end
    
    
end

figure;
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
subplot(2,2,1);
notBoxPlot(squeeze(median(ROI_median(:,:,:),3))');
ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('regressors of interest');
subplot(2,2,2);
notBoxPlot(squeeze(median(COV_median(:,:,:),3))')
ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('covariates');
subplot(2,2,3);
notBoxPlot(squeeze(median(ROI_median(:,:,:),3))'./squeeze(median(COV_median(:,:,:),3))');
ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('regressors of interest/covariates');
suptitle('All regressors of interest');

for fig_idx=1:10
    fig(fig_idx)=figure(fig_idx+1);
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    subplot(2,2,1);
    notBoxPlot(squeeze(median(ROI_median(:,:,fig_idx),3))');
    ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('regressors of interest');
    subplot(2,2,2);
    notBoxPlot(squeeze(median(COV_median(:,:,:),3))')
    ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('covariates');
    subplot(2,2,3);
    notBoxPlot(squeeze(median(ROI_median(:,:,fig_idx),3))'./squeeze(median(COV_median(:,:,:),3))');
    ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('regressors of interest/covariates');
    suptitle(['Regressor of interest #' num2str(fig_idx)]);
end
    
% figure;
% subplot(2,2,1);
% notBoxPlot(squeeze(mean(ROI_mean(:,:,:),3))');
% ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('regressors of interest');
% subplot(2,2,2);
% notBoxPlot(squeeze(mean(COV_mean(:,:,:),3))')
% ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('covariates');
% subplot(2,2,3);
% notBoxPlot(squeeze(mean(ROI_mean(:,:,:),3))'./squeeze(mean(COV_mean(:,:,:),3))');
% ax=gca; ax.XTickLabel=preprocessing_names; rotateXLabels(ax,45); title('regressors of interest/covariates');
% 
% 
% 
% 
% figure; hold on;
% for ppm_idx=1:length(preprocessing_names);
%     hh(ppm_idx)=histogram(ROI_median(ppm_idx,:,:),'BinWidth',0.05);
%     hh(ppm_idx).EdgeColor='none';
% end
% 
% figure; hold on;
% for ppm_idx=1:length(preprocessing_names);
%     hh(ppm_idx)=histogram(COV_median(ppm_idx,:,:),'BinWidth',0.05);
%     hh(ppm_idx).EdgeColor='none';
% end
% 
% figure; hh(1)=histogram(C1all(:),'BinWidth',200); hold on; hh(2)=histogram(C2all(:),'BinWidth',200); hold on; hh(3)=histogram(C3all(:),'BinWidth',200);
% for ix=1:length(hh); hh(ix).EdgeColor='none'; end
