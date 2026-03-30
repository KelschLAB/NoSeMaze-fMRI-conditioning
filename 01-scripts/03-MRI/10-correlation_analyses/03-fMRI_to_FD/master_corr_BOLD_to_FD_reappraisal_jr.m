%% master_corr_BOLD_to_FD_reappraisal_jr.m
% relationship between significant BOLD signal (beta-values) at odor and time point of no puff
% Jonathan Reinwald, 08.08.2023

% clearing
clear all
close all
clc

% define t-threshold
tthresh{1}='01';
tthresh{2}='001';

% correlation type
corr_type{1}='Spearman';
corr_type{2}='Pearson';

% output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/07-correlation_analyses_fMRI_to_fMRI/03-BOLD_to_FD';

%% loop over thresholds
for corr_idx = 1:length(corr_type)
    
    %% loop over thresholds
    for tthresh_idx = 1:length(tthresh)
        
        %% load beta-values and create table
        % load "mask_activation_v22_OdorBl3vsBl1_T01" --> PFC
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T' tthresh{tthresh_idx} '.mat'])
        resINS=res;
        
        % load "mask_activation_v22_OdorBl3vsBl1_T01" --> PFC
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_activation_v22_OdorBl3vsBl1_T' tthresh{tthresh_idx} '.mat']);
        resS1=res;
        
        % load "mask_deactivation_v22_OdorBl3vsBl1_T01" --> PFC
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/Odor_NoPuff_Bl3_vs_Odor_NoPuff_Bl1_11to40/mask_deactivation_v22_OdorBl3vsBl1_T' tthresh{tthresh_idx} '.mat']);
        resPFC=res;
        
        % create data table
        myBetas.(['T' tthresh{tthresh_idx}]).beta_table = table(resINS.mean_beta_TP_Puff_Bl1_11to40',resINS.mean_beta_TP_Puff_Bl3',resINS.mean_beta_TP_Puff_Bl3'-resINS.mean_beta_TP_Puff_Bl1_11to40',...
            resPFC.mean_beta_Lavender_Bl1_11to40',resPFC.mean_beta_Lavender_Bl3',resPFC.mean_beta_Lavender_Bl3'-resPFC.mean_beta_Lavender_Bl1_11to40',...
            resS1.mean_beta_Lavender_Bl1_11to40',resS1.mean_beta_Lavender_Bl3',resS1.mean_beta_Lavender_Bl3'-resS1.mean_beta_Lavender_Bl1_11to40',...
            'VariableNames',{'TP_INS_bl1','TP_INS_bl3','TP_INS_bl3-bl1','OD_PFC_bl1','OD_PFC_bl3','OD_PFC_bl3-bl1','OD_S1_bl1','OD_S1_bl3','OD_S1_bl3-bl1'});
        
        % load FD
        % CAVE: double check of FD is based on AFNI-despiked data or not
        %% Load FD
        % load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/Amyg/FD_matrsess_all_BINS6_TRsbefore2.mat')
        load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/tc_matrsess_all_BINS6_TRsbefore2.mat')
        
        load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/FD_matrsess_all_BINS6_TRsbefore2.mat')
        % load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v99___COV_v1___ORTH_1___11-Jan-2022/meanTC/Amyg/tc_matrsess_all_BINS6_TRsbefore2.mat')
        
        meanFD_block1 = squeeze(mean(FD_matrsess_all(:,[11:40],:),2));
        meanFD_block3 = squeeze(mean(FD_matrsess_all(:,[81:120],:),2));
        
        [~,sortingIdx_FD]=sort(tc_matrsess_info.AnimalNumb,'ascend');
        meanFD_block1_sorted=meanFD_block1(sortingIdx_FD,:);
        meanFD_block3_sorted=meanFD_block3(sortingIdx_FD,:);
        
        %% correlation analysis
        %% Correlation analysis
        [corr_coeff(1).rho,p_val(1).p]=corr([meanFD_block1_sorted,mean(meanFD_block1_sorted,2)],table2array(myBetas.(['T' tthresh{tthresh_idx}]).beta_table),'type',corr_type{corr_idx});
        [corr_coeff(2).rho,p_val(2).p]=corr([meanFD_block3_sorted,mean(meanFD_block3_sorted,2)],table2array(myBetas.(['T' tthresh{tthresh_idx}]).beta_table),'type',corr_type{corr_idx});
        [corr_coeff(3).rho,p_val(3).p]=corr([meanFD_block3_sorted,mean(meanFD_block3_sorted,2)]-[meanFD_block1_sorted,mean(meanFD_block1_sorted,2)],table2array(myBetas.(['T' tthresh{tthresh_idx}]).beta_table),'type',corr_type{corr_idx});
        
        % plot correlation matrix
        for fig_idx = 1:length(corr_coeff)
            fig(fig_idx)=figure('visible', 'off');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
            imagesc(corr_coeff(fig_idx).rho);%.*(p<.05));
            set(gca,'dataAspectRatio',[1 1 1])
            ax=gca;
            set(gca,'TickLabelInterpreter','none');
            ax.CLim=[-1,1];
            crameri vik;
            ax.YTick=1:size(corr_coeff(fig_idx).rho,1);
            for yy = 1:size(corr_coeff(fig_idx).rho,1)
                y_names{yy}=['TR #' num2str(yy)];
            end
            y_names{size(corr_coeff(fig_idx).rho,1)}='mean FD';
            ax.YTickLabel=y_names;
            ax.XTick=1:size(corr_coeff(fig_idx).rho,2);
            ax.XTickLabel=myBetas.(['T' tthresh{tthresh_idx}]).beta_table.Properties.VariableNames;
            ax.XLabel.String='betas';
            ax.YLabel.String='FD (at TR within trial)';
            rotateXLabels(ax,90);
            ax.FontSize=10;
            
            % Title
            if fig_idx==1
                tt = title({['corr. BOLD to FD (' corr_type{corr_idx} ')'],['Block 1, pCDT<' num2str(tthresh{tthresh_idx})]});
            elseif fig_idx==2
                tt = title({['corr. BOLD to FD (' corr_type{corr_idx} ')'],['Block 3, pCDT<' num2str(tthresh{tthresh_idx})]});                
            elseif fig_idx==3
                tt = title({['corr. BOLD to FD (' corr_type{corr_idx} ')'],['Block 3 - Block 1, pCDT<' num2str(tthresh{tthresh_idx})]});                
            end
            tt.Interpreter='none';
            colorbar;
            
            % Mark significant p-values
            for x=1:size(p_val(fig_idx).p,2)
                for y=1:size(p_val(fig_idx).p,1)
                    if p_val(fig_idx).p(y,x)<.05
                        xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                        line(xv,yv,'linewidth',2,'color',[0 0 0]);
                    end
                end
            end
            
            % print
            if fig_idx==1
                [annot, srcInfo] = docDataSrc(fig(fig_idx),outputDir,mfilename('fullpath'),logical(1))
                exportgraphics(fig(fig_idx),fullfile(outputDir,['CorrBOLDtoFD_Block1_T' tthresh{tthresh_idx} '_' corr_type{corr_idx} '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(outputDir,['CorrBOLDtoFD_Block1_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
            elseif fig_idx==2
                [annot, srcInfo] = docDataSrc(fig(fig_idx),outputDir,mfilename('fullpath'),logical(1))
                exportgraphics(fig(fig_idx),fullfile(outputDir,['CorrBOLDtoFD_Block3_T' tthresh{tthresh_idx} '_' corr_type{corr_idx} '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(outputDir,['CorrBOLDtoFD_Block3_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
            elseif fig_idx==3
                [annot, srcInfo] = docDataSrc(fig(fig_idx),outputDir,mfilename('fullpath'),logical(1))
                exportgraphics(fig(fig_idx),fullfile(outputDir,['CorrBOLDtoFD_Block3vs1_T' tthresh{tthresh_idx} '_' corr_type{corr_idx} '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(outputDir,['CorrBOLDtoFD_Block3vs1_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
            end           
        end
    end
end


    




