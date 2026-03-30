%% master_corr_BOLD_to_globalGA_reappraisal_jr.m

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

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36]%,11,21,31];
maxthr_ind_range=[41]%,41,41,41,41];

%% Selection of input
% beta selection
beta_selection = 'corrdeltaC';%'OverlapDeltaLandSocialRank';%'corrdeltaL'; %'OverlapDeltaCandSocialRank';%'antINS';%  'vHC'
threshold_selection = 'T01';%V 'T001'

% cormat version
cormat_version = 'cormat_v11';%'cormat_v11';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';

%% Load beta coefficients (saved in script master_calculate_and_plot_mean_betas_jr.m)
% res.mat
if strcmp(cormat_version,'cormat_v11')
    if strcmp(beta_selection,'antINS')
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'vHC')
        %         load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_positiveCorrRank_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'OverlapDeltaLandSocialRank')
        %         load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_OverlapDeltaLandSocialRank_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'OverlapDeltaCandSocialRank')
        %         load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_OverlapDeltaCandSocialRank_' threshold_selection '.mat']);
    elseif strcmp(beta_selection,'corrdeltaC')
        %         load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_vHC_' threshold_selection '_corrdeltaC.mat']);
    elseif strcmp(beta_selection,'corrdeltaL')
        %         load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_' threshold_selection '.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_vHC_' threshold_selection '_corrdeltaL.mat']);   
    end
end

%% Loop over threshold ranges
for mx = 1:length(minthr_ind_range)
    clear myMetrics
    
    %% current thresholds
    minthr_ind = minthr_ind_range(mx)
    maxthr_ind = maxthr_ind_range(mx)
    
    %% Load global metrics (saved in plot_pairedTT_globMetGA_reappraisal_jr.m)
    % res_auc_struc_global.mat -->  res_auc_struc
    if separated_hemisphere==1
        %     load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version '/separated_hemisphere/' binarization_method '_' connectedness '/res_auc_struc.mat']);
        load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness filesep name_TP1 'VS' name_TP2 filesep 'global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) filesep  'res_auc_struc_global.mat']);
    elseif separated_hemisphere==0
        load(['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness filesep name_TP1 'VS' name_TP2 filesep 'global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) filesep 'res_auc_struc_global.mat']);
    end
    % define global metrics
    global_metrics = fieldnames(res_auc_struc);
    % pre-selection
    global_metrics = {'g_cc','g_cpl','g_swi','g_modularity','g_delta_C','g_delta_L','g_swp'}
    
    %% Output directory
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-BOLD_to_GA');
    if separated_hemisphere==1
        outputDir = fullfile('/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-BOLD_to_GA',cormat_version,'separated_hemisphere',[binarization_method '_' connectedness],[name_TP1 'VS' name_TP2],['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)],'mediation_moderation_analysis');
    elseif separated_hemisphere==0
        outputDir = fullfile('/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/','07-correlation_analyses_fMRI_to_fMRI','01-BOLD_to_GA',cormat_version,'combined_hemisphere',[binarization_method '_' connectedness],[name_TP1 'VS' name_TP2],['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)],'mediation_moderation_analysis');
    end
    mkdir(outputDir);
    cd(outputDir);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Loop over global metrics
    for ix=5:6%length(global_metrics)
        % figure
        fig(ix)=figure('visible', 'on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.8]);
        
        %% define beta and GA diff vectors
        beta_diff = [res.mean_betaPos]'-[res.mean_betaNeg]';
        GA_diff = [res_auc_struc.(global_metrics{ix}).TPnoPuff81to120]-[res_auc_struc.(global_metrics{ix}).TPnoPuff11to40];
        
        
        %% load social rank
        % old rank:
        % load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v11_smoothed_cormat_v9/mask_deactivation_v22_RankOwn_Bl3vsBl1_T01/secondlevel/diffBl3vsBl1/SPM.mat');
        % new rank:
        load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/corr_SocialHierarchy/secondlevel_Rank/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/SPM.mat');
        SocialRank = SPM.xC.rc;
        
        % plot input
        plot_data(1).input = SocialRank;plot_data(2).input = GA_diff; plot_data(3).input = beta_diff; 
        plot_data(1).name = 'social rank'; plot_data(2).name = {global_metrics{ix},'diff(test-pre)'};plot_data(3).name = {'BOLD','diff(test-pre)'}; 
        plot_data(1).axLims = [1,12]; plot_data(2).axLims = [-ceil(abs(min(GA_diff))*10)/10,ceil(max(GA_diff)*10)/10]; plot_data(3).axLims = [-ceil(abs(min(beta_diff))*10)/10,ceil(max(beta_diff)*10)/10];
        plot_data(1).axTicks = [1:12]; plot_data(2).axTicks = [-ceil(abs(min(GA_diff))*10)/10:0.2:ceil(max(GA_diff)*10)/10]; plot_data(3).axTicks = [-ceil(abs(min(beta_diff))*10)/10:0.2:ceil(max(beta_diff)*10)/10];
        plot_counter = 1;
        
        % save source data for plot
        clear SourceData
        SourceData = array2table([plot_data(1).input,plot_data(2).input,plot_data(3).input],'VariableNames',{'social_rank',global_metrics{ix},['BOLD_' beta_selection]});
        writetable(SourceData,fullfile(outputDir,['SourceData_Correlation_BOLD' beta_selection threshold_selection '_to_' global_metrics{ix} 'global' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_to_socialRank.csv']),'WriteVariableNames',true,'WriteRowNames',true)
 
        
        % loops for subplots:
        for jx=1:2
            for kx=jx+1:length(plot_data)
                
                % statistics: Pearson's correlation
                [r_p(plot_counter,1),p_p(plot_counter,1)]=corr(plot_data(jx).input,plot_data(kx).input,'type','Pearson');
                % subplot
                subplot(2,2,plot_counter);
                % scatter plot
                sc(1)=scatter(plot_data(jx).input,plot_data(kx).input);
                sc(1).MarkerFaceAlpha=1; sc(1).SizeData=20;
                sc(1).MarkerFaceColor=[.4 .4 .4];
                sc(1).MarkerEdgeAlpha=1;
                sc(1).MarkerEdgeColor='none';
                sc(1).SizeData=40;
                % axes definition
                box 'off';
                axis square;
                ax=gca;
                ax.XLabel.String = plot_data(jx).name;
                ax.YLabel.String = plot_data(kx).name;
                ax.LineWidth = 1.5;
                ax.FontSize = 14;
                ax.XLabel.Interpreter='none';
                ax.YLabel.Interpreter='none';
                ax.XLim = plot_data(jx).axLims;
                ax.YLim = plot_data(kx).axLims;
                ax.XTick = plot_data(jx).axTicks;
                ax.YTick = plot_data(kx).axTicks;
                % line
                ll=lsline;
                ll.LineWidth=1.5;
                ll.Color=[.4 .4 .4];
                ll.LineStyle='-';
                
                % text
                tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.9,['p=' num2str(round(p_p(plot_counter,1),3))]);
                tx=text(ax.XLim(1)+diff(ax.XLim)*0.1,ax.YLim(1)+diff(ax.YLim)*0.8,['rho=' num2str(round(r_p(plot_counter,1),3))]);
                
                % counter update
                plot_counter = plot_counter + 1;
            end
            % title
            sup=title([beta_selection '_' threshold_selection]);
            sup.Interpreter='none';
        end
        
        % print
        [annot, srcInfo] = docDataSrc(fig(ix),outputDir,mfilename('fullpath'),logical(1))
        exportgraphics(fig(ix),fullfile(outputDir,['Correlation_BOLD' beta_selection threshold_selection '_to_' global_metrics{ix} 'global' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_to_socialRank.pdf']),'Resolution',300);
        exportgraphics(fig(ix),fullfile(outputDir,['Correlation_BOLD' beta_selection threshold_selection '_to_' global_metrics{ix} 'global' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_to_socialRank.png']),'Resolution',300);
        
        %% Investigation of mediator/modulator effects
        % Mediation Analysis
%         SocialRank = SocialRank - mean(SocialRank);
%         GA_diff = GA_diff - mean(GA_diff);
%         beta_diff  = beta_diff - mean(beta_diff);
        % Step 1: Regress beta_diff on SocialRank
        mdl1 = fitlm(SocialRank, GA_diff,'VarNames',{'Social Rank',global_metrics{ix}});
        
        % Step 2: Regress GA_diff on SocialRank
        mdl2 = fitlm(GA_diff, beta_diff,'VarNames',{global_metrics{ix},'vHC BOLD (comb)'});
        
        % Step 3: Regress GA_diff on beta_diff (controlling for SocialRank)
        mdl3 = fitlm([SocialRank, GA_diff], beta_diff,'VarNames',{'Social Rank',global_metrics{ix},'vHC BOLD (comb)'});
        
        % Just for interest
        mdl4 = fitlm(SocialRank, beta_diff,'VarNames',{'Social Rank','vHC BOLD (comb)'});
        
        % Assess mediation
        mediation_coeff = mdl3.Coefficients.Estimate(3);
        p_value_mediation = mdl3.Coefficients.pValue(3);
        
        if p_value_mediation < 0.05
            disp('Mediation effect detected.');
            if mediation_coeff < 0
                disp('Mediator decreases the effect of social rank on beta_diff.');
                
            else
                disp('Mediator increases the effect of social rank on beta_diff.');
            end
        else
            disp('No significant mediation effect.');
        end
        
        % Moderator Analysis
        % Step 1: Create interaction term
        interaction_term = GA_diff .* SocialRank;
%         interaction_term = zscore(GA_diff).*(zscore(SocialRank));
        
        % Step 2: Include interaction term in regression model
        mdl_mod = fitlm([GA_diff, SocialRank, interaction_term], beta_diff);
        
        % Assess moderation
        interaction_coeff = mdl_mod.Coefficients.Estimate(4);
        p_value_interaction = mdl_mod.Coefficients.pValue(4);
        
        if p_value_interaction < 0.05
            disp('Moderator effect detected.');
            if interaction_coeff > 0
                disp('Moderator strengthens the effect of social_rank on beta_diff.');
            else
                disp('Moderator weakens the effect of social_rank on beta_diff.');
            end
        else
            disp('No significant moderator effect.');
        end
        
    end
    close all;
end