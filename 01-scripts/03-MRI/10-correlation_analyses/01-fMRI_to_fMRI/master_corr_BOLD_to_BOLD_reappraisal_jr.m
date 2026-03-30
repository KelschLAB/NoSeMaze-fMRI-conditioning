%% master_corr_BOLD_to_BOLD_reappraisal_jr.m
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
corr_type{1}='Pearson';
corr_type{2}='Spearman';

% output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/07-correlation_analyses_fMRI_to_fMRI/02-BOLD_to_BOLD';

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
        myBetas.(['T' tthresh{tthresh_idx}]).beta_table = table(resINS.mean_betaNeg',resINS.mean_betaPos',resINS.mean_betaPos'-resINS.mean_betaNeg',...
            resPFC.mean_betaNeg',resPFC.mean_betaPos',resPFC.mean_betaPos'-resPFC.mean_betaNeg',...
            resS1.mean_betaNeg',resS1.mean_betaPos',resS1.mean_betaPos'-resS1.mean_betaNeg',...
            'VariableNames',{'TP_INS_bl1','TP_INS_bl3','TP_INS_bl3-bl1','OD_PFC_bl1','OD_PFC_bl3','OD_PFC_bl3-bl1','OD_S1_bl1','OD_S1_bl3','OD_S1_bl3-bl1'});
        
        %% correlation analysis
        [rho,p]=corr(table2array(myBetas.(['T' tthresh{tthresh_idx}]).beta_table),'type',corr_type{corr_idx});
        
        % plot correlation matrix
        fig1=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
        imagesc(rho);%.*(p<.05));
        set(gca,'dataAspectRatio',[1 1 1])
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        crameri vik;
        ax.YTick=1:length(rho);
        ax.YTickLabel=myBetas.(['T' tthresh{tthresh_idx}]).beta_table.Properties.VariableNames;
        ax.XTick=1:length(rho);
        ax.XTickLabel=myBetas.(['T' tthresh{tthresh_idx}]).beta_table.Properties.VariableNames;
        rotateXLabels(ax,90);
        ax.FontSize=10;
        
        % Title
        tt = title({['corr. BOLD (' corr_type{corr_idx} ')'],['(CDT: p<0.' tthresh{tthresh_idx} ')']});
        tt.Interpreter='none';
        colorbar;
        
        % Mark significant p-values
        for x=1:size(p,1)
            for y=1:size(p,2)
                if (x == y)
                    xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
                    patch(xv,yv,[1 1 1])
                end
                if p(y,x)<.05
                    xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                    line(xv,yv,'linewidth',2,'color',[0 0 0]);
                end
            end
        end
        
        % print
        [annot, srcInfo] = docDataSrc(fig1,outputDir,mfilename('fullpath'),logical(1))
        exportgraphics(fig1,fullfile(outputDir,['CorrBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx} '.pdf']),'Resolution',300);
        print('-dpsc',fullfile(outputDir,['CorrBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
        
        %% Scatter plot for correlation at odor
        % plot correlation matrix
        fig3=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.5]);
        sc(1)=scatter(table2array(myBetas.(['T' tthresh{tthresh_idx}]).beta_table(:,6)),table2array(myBetas.(['T' tthresh{tthresh_idx}]).beta_table(:,9)));
        sc(1).MarkerFaceAlpha=1; sc(1).SizeData=50;
        sc(1).MarkerFaceColor=[.8 .4 .4];
        sc(1).MarkerEdgeAlpha=1;
        sc(1).MarkerEdgeColor='none';
        % axes definition
        ax=gca;
        ax.XLabel.String = myBetas.(['T' tthresh{tthresh_idx}]).beta_table.Properties.VariableNames{6};
        ax.YLabel.String = myBetas.(['T' tthresh{tthresh_idx}]).beta_table.Properties.VariableNames{9};
        ax.XLabel.Interpreter='none';
        ax.YLabel.Interpreter='none';
        ax.LineWidth = 1.5;
        ax.YLim=[-1,1];
        ax.XLim=[-1.5,1.5];
        % line
        ll=lsline;
        ll.LineWidth=1.5;
        ll.Color=[.8 .4 .4];
        ll.LineStyle='--';
        % title
        tt = title({['corr. BOLD (' corr_type{corr_idx} ')'],['(CDT: p<0.' tthresh{tthresh_idx} ')']});
        tt.Interpreter='none';
        % text
        tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.1,['p=' num2str(p(6,9))]);
        tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.2,['rho=' num2str(rho(6,9))]);
        
        % print
        [annot, srcInfo] = docDataSrc(fig3,outputDir,mfilename('fullpath'),logical(1))
        exportgraphics(fig3,fullfile(outputDir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx} '.pdf']),'Resolution',300);
        print('-dpsc',fullfile(outputDir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
    end
end


    




