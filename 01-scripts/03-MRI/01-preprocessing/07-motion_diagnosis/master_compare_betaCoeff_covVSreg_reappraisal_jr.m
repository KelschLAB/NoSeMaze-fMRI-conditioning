%% master_compare_betaCoeff_covVSreg_reappraisal_jr.m
%% Preparation
clear all;
% close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% outputdir
outputdir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/01-preprocessing/01-motion/BetaComparison_RegressorsVSCovariates';

% start SPM fmri
spm('CreateMenuWin','off');
spm('CreateIntWin','off');


%% Calculation of beta values for covariates and regressors of interest
if 1==0
    % select GLM directory on which to calculate the beta values
    GLM_dir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results');
    
    for subj = 1:length(Pfunc_reappraisal)
        
        
        % define subject abbreviation
        [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
        subjAbrev = fname(1:6);
        
        myBetaValuesCovariates(subj).subject=subj;
        
        for ix=1:14
            % define SPM.mat
            P=[GLM_dir filesep 'firstlevel' filesep subjAbrev filesep 'beta_00' num2str(10+ix) '.nii'];
            V=spm_vol(P);
            img=spm_read_vols(V);
            myBetaValuesCovariates(subj).beta_coeff(ix,:)=img(:);
            if ix<13
                myBetaValuesCovariates(subj).beta_name{ix}=['rp' num2str(ix)]
            else
                myBetaValuesCovariates(subj).beta_name{ix}=['csf' num2str(ix-12)]
            end
        end
        
        for ix=1:10
            % define SPM.mat
            if ix<10
                P=[GLM_dir filesep 'firstlevel' filesep subjAbrev filesep 'beta_000' num2str(ix) '.nii'];
            else
                P=[GLM_dir filesep 'firstlevel' filesep subjAbrev filesep 'beta_00' num2str(ix) '.nii'];
            end
            V=spm_vol(P);
            img=spm_read_vols(V);
            myBetaValuesRegressors(subj).beta_coeff(ix,:)=img(:);
            myBetaValuesRegressors(subj).beta_name{ix}=['regressor' num2str(ix)]
        end
    end
    save([GLM_dir filesep 'beta_coefficients_covariates.mat'],'myBetaValuesCovariates')
    save([GLM_dir filesep 'beta_coefficients_regressors.mat'],'myBetaValuesRegressors')
end


preprocessing_directories = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v22___COV_v2___ORTH_1___DERDISP0___07-Aug-2023/',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___29-Mar-2023/',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___09-Aug-2023',...
    };

preprocessing_names = {'RP12_CSF2','RP12_CSF2_WD','RP12_CSF2_AFNI','RP12_CSF2_AFNI_WD10','RP12_CSF2_AFNI_WD10_DVARSscrub','RP12_CSF2_WD10_DVARSscrub'};

%% Loop over different preprocessing types
for pp_idx = 1:length(preprocessing_names)
    
    % load beta values of covariates
    load(fullfile(preprocessing_directories{pp_idx},'beta_coefficients_covariates.mat'));
    BetaValuesCovariates.(preprocessing_names{pp_idx}).values = [myBetaValuesCovariates(:).beta_coeff];
    BetaValuesCovariates.(preprocessing_names{pp_idx}).names = myBetaValuesCovariates(1).beta_name;
    
    myBetaValuesCovariates_all(pp_idx).myBetaValuesCovariates = myBetaValuesCovariates;
    
    % load beta values of regressors of interest
    load(fullfile(preprocessing_directories{pp_idx},'beta_coefficients_regressors.mat'));
    BetaValuesRegressors.(preprocessing_names{pp_idx}).values = [myBetaValuesRegressors(:).beta_coeff];
    BetaValuesRegressors.(preprocessing_names{pp_idx}).names = myBetaValuesRegressors(1).beta_name;
    
    myBetaValuesRegressors_all(pp_idx).myBetaValuesRegressors = myBetaValuesRegressors;
    
    % calculate fractions
    for subj = 1:length(myBetaValuesCovariates)
        Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).allFraction(subj,:,:) = ((myBetaValuesCovariates_all(pp_idx).myBetaValuesCovariates(subj).beta_coeff)./(myBetaValuesCovariates_all(1).myBetaValuesCovariates(subj).beta_coeff));
        Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj,:) = nanmean(((myBetaValuesCovariates_all(pp_idx).myBetaValuesCovariates(subj).beta_coeff)./(myBetaValuesCovariates_all(1).myBetaValuesCovariates(subj).beta_coeff))');
        Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj,:) = nanmedian(((myBetaValuesCovariates_all(pp_idx).myBetaValuesCovariates(subj).beta_coeff)./(myBetaValuesCovariates_all(1).myBetaValuesCovariates(subj).beta_coeff))');
        Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj,:) = nanstd(((myBetaValuesCovariates_all(pp_idx).myBetaValuesCovariates(subj).beta_coeff)./(myBetaValuesCovariates_all(1).myBetaValuesCovariates(subj).beta_coeff))');
        
        Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).allFraction(subj,:,:) = ((myBetaValuesRegressors_all(pp_idx).myBetaValuesRegressors(subj).beta_coeff)./(myBetaValuesRegressors_all(1).myBetaValuesRegressors(subj).beta_coeff));
        Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj,:) = nanmean(((myBetaValuesRegressors_all(pp_idx).myBetaValuesRegressors(subj).beta_coeff)./(myBetaValuesRegressors_all(1).myBetaValuesRegressors(subj).beta_coeff))');
        Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj,:) = nanmedian(((myBetaValuesRegressors_all(pp_idx).myBetaValuesRegressors(subj).beta_coeff)./(myBetaValuesRegressors_all(1).myBetaValuesRegressors(subj).beta_coeff))');
        Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj,:) = nanstd(((myBetaValuesRegressors_all(pp_idx).myBetaValuesRegressors(subj).beta_coeff)./(myBetaValuesRegressors_all(1).myBetaValuesRegressors(subj).beta_coeff))');
        
        Fraction_BetaValuesRegressorsVsCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj) = mean(Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj,[2,5,7,10]))./mean(Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj,:));
        Fraction_BetaValuesRegressorsVsCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj) = median(Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj,[2,5,7,10]))./median(Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj,:));
        Fraction_BetaValuesRegressorsVsCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj) = median(Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj,[2,5,7,10]))./median(Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj,:));
        
        %         Fraction_BetaValuesRegressorsVsCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj) = mean(Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj,:))./mean(Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).meanFraction(subj,:));
        %         Fraction_BetaValuesRegressorsVsCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj) = median(Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj,:))./median(Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).medianFraction(subj,:));
        %         Fraction_BetaValuesRegressorsVsCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj) = mean(Fraction_BetaValuesRegressors.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj,:))./mean(Fraction_BetaValuesCovariates.([preprocessing_names{pp_idx} '_to_' preprocessing_names{1}]).stdFraction(subj,:));
        
    end
end


%% Plots
% Fraction beta to beta, once for ROIs, once for COVs
if 1==0
    figure(1);
    myFieldNames = fieldnames(Fraction_BetaValuesCovariates);
    for field_ix = 1:length(myFieldNames)
        subplot(3,2,field_ix); notBoxPlot(Fraction_BetaValuesCovariates.(myFieldNames{field_ix}).medianFraction);ax=gca; ax.YLim=[-1.2,1.2];
        tt=title(preprocessing_names{field_ix});
        tt.Interpreter='none';
    end
    suptitle('Covariates');
    figure(2);
    for field_ix = 1:length(myFieldNames)
        subplot(3,2,field_ix); notBoxPlot(Fraction_BetaValuesRegressors.(myFieldNames{field_ix}).medianFraction);ax=gca; ax.YLim=[-1.2,1.2];
        tt=title(preprocessing_names{field_ix});
        tt.Interpreter='none';
    end
    suptitle('Regressors');
end

% Fraction beta to beta compared between ROIs and COVs
% set figure
fig(3)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
notBoxPlot([Fraction_BetaValuesRegressorsVsCovariates.RP12_CSF2_to_RP12_CSF2.medianFraction',Fraction_BetaValuesRegressorsVsCovariates.RP12_CSF2_WD_to_RP12_CSF2.medianFraction',Fraction_BetaValuesRegressorsVsCovariates.RP12_CSF2_AFNI_to_RP12_CSF2.medianFraction',Fraction_BetaValuesRegressorsVsCovariates.RP12_CSF2_AFNI_WD10_to_RP12_CSF2.medianFraction',Fraction_BetaValuesRegressorsVsCovariates.RP12_CSF2_AFNI_WD10_DVARSscrub_to_RP12_CSF2.medianFraction',Fraction_BetaValuesRegressorsVsCovariates.RP12_CSF2_WD10_DVARSscrub_to_RP12_CSF2.medianFraction']);
% axes
ax=gca;
set(gca,'TickLabelInterpreter','none');
ax.XTickLabel = preprocessing_names;
rotateXLabels(ax,45);
set(ax, 'TickLabelInterpreter', 'none');
% title
tt = title({'Ratio: median beta fraction regr./median beta fraction cov.','(only ROIs of interest (bl.1, tr. 11-40, and bl. 3)'});
tt.Interpreter='none';
% print
[annot, srcInfo] = docDataSrc(fig(3),outputdir,mfilename('fullpath'),logical(1))
exportgraphics(fig(3),fullfile(outputdir,['BetaFractionComparison_ROIs_VS_COVs.pdf']),'Resolution',300);
% print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');

%% histograms
% color definition
histogram_color={[1 0 0];[1 0.5 0];[0 0 0];[0 0.5 0];[0 0 0.5];[0 0.5 1]};


fig(4)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
% loop over rps
for rp_idx = 1:length(BetaValuesCovariates.(preprocessing_names{pp_idx}).names)
    % subplot
    subplot(4,4,rp_idx);
    % loop over preprocessing types
    for pp_idx = 1:length(preprocessing_names)
        
        % Calculate the optimal bin width using the Freedman-Diaconis rule
        if pp_idx==1;
            data_range = range(BetaValuesCovariates.(preprocessing_names{pp_idx}).values(rp_idx,:));
            iqr_value = iqr(BetaValuesCovariates.(preprocessing_names{pp_idx}).values(rp_idx,:));
            bin_width = 2 * iqr_value / (length(BetaValuesCovariates.(preprocessing_names{pp_idx}).values(rp_idx,:))^(1/3));
        end
        
        % histograms
        hh(pp_idx)=histogram(BetaValuesCovariates.(preprocessing_names{pp_idx}).values(rp_idx,:),'BinWidth',bin_width);
        % color definition
        hh(pp_idx).EdgeColor='none';
        hh(pp_idx).FaceColor=histogram_color{pp_idx};
        hh(pp_idx).FaceAlpha=0;
        hold on;
        hh2(pp_idx)=histogram(BetaValuesCovariates.(preprocessing_names{pp_idx}).values(rp_idx,:),'BinWidth',bin_width,'DisplayStyle','stairs');
        hh2(pp_idx).EdgeColor=histogram_color{pp_idx};
        hh2(pp_idx).LineWidth=.5;
                
        
        % Calculate the midpoint values of each bin
        binEdges = hh(pp_idx).BinEdges;
        binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;
        
        % Calculate the area under the curve using numerical integration (trapz)
        binCounts = hh(pp_idx).Values;
        %         areas_cov(pp_idx, rp_idx) = trapz(binCenters, binCounts);
        values_cov(pp_idx, rp_idx) = sum(abs(binCenters).*binCounts);
    end
    % title
    title(BetaValuesCovariates.(preprocessing_names{1}).names{rp_idx});
    % legend
    if rp_idx==1
        ll=legend([hh2(1),hh2(2),hh2(3),hh2(4),hh2(5),hh2(6)],preprocessing_names(1:end),'Position',[0.6,0.1,0.2,0.1]);
        ll.Interpreter='none';
        ll.FontSize = 6;
    end
end
% print
[annot, srcInfo] = docDataSrc(fig(4),outputdir,mfilename('fullpath'),logical(1))
exportgraphics(fig(4),fullfile(outputdir,['Histograms_Covariates.pdf']),'Resolution',300);
% print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');


fig(5)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
% loop over rps
for rp_idx = 1:length(BetaValuesRegressors.(preprocessing_names{pp_idx}).names)
    % subplot
    subplot(4,4,rp_idx);
    % loop over preprocessing types
    for pp_idx = 1:length(preprocessing_names)
        
        % Calculate the optimal bin width using the Freedman-Diaconis rule
        if pp_idx==1;
            data_range = range(BetaValuesRegressors.(preprocessing_names{pp_idx}).values(rp_idx,:));
            iqr_value = iqr(BetaValuesRegressors.(preprocessing_names{pp_idx}).values(rp_idx,:));
            bin_width = 2 * iqr_value / (length(BetaValuesRegressors.(preprocessing_names{pp_idx}).values(rp_idx,:))^(1/3));
        end
        
        % histograms
        hh(pp_idx)=histogram(BetaValuesRegressors.(preprocessing_names{pp_idx}).values(rp_idx,:),'BinWidth',bin_width);
        % color definition
        hh(pp_idx).EdgeColor='none';
        hh(pp_idx).FaceColor=histogram_color{pp_idx};
        hh(pp_idx).FaceAlpha=0;
        hold on;
        hh2(pp_idx)=histogram(BetaValuesRegressors.(preprocessing_names{pp_idx}).values(rp_idx,:),'BinWidth',bin_width,'DisplayStyle','stairs');
        hh2(pp_idx).EdgeColor=histogram_color{pp_idx};
        hh2(pp_idx).LineWidth=.5;
                
        
        % Calculate the midpoint values of each bin
        binEdges = hh(pp_idx).BinEdges;
        binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;
        
        % Calculate the area under the curve using numerical integration (trapz)
        binCounts = hh(pp_idx).Values;
        %         areas_cov(pp_idx, rp_idx) = trapz(binCenters, binCounts);
        values_reg(pp_idx, rp_idx) = sum(abs(binCenters).*binCounts);
    end
    % title
    title(BetaValuesRegressors.(preprocessing_names{1}).names{rp_idx});
    % legend
    if rp_idx==1
        ll=legend([hh2(1),hh2(2),hh2(3),hh2(4),hh2(5),hh2(6)],preprocessing_names(1:end),'Position',[0.6,0.1,0.2,0.1]); % Position: left, bottom, width, height
        ll.Interpreter='none';
        ll.FontSize = 6;
    end
end
% print
[annot, srcInfo] = docDataSrc(fig(5),outputdir,mfilename('fullpath'),logical(1))
exportgraphics(fig(5),fullfile(outputdir,['Histograms_Regressors.pdf']),'Resolution',300);
% print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');

% figure
% set figure
fig(6)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);

subplot(1,2,1);
hold on; 
for ix=1:(length(preprocessing_names)-1) 
    pp(ix) = plot(values_cov(ix+1,:)./values_cov(1,:),'Color',histogram_color{ix},'LineWidth',1.5); 
end
tt=title({'fraction of beta for covariates','(compared to preprocessing with RP12_CSF2)'});
ax=gca; ax.YLim=[0,1.4];
ax.XTick=[1:size(values_cov,2)];
ax.XTickLabel=BetaValuesCovariates.(preprocessing_names{1}).names;
rotateXLabels(ax,60);
ll=legend([pp(1),pp(2),pp(3),pp(4),pp(5)],preprocessing_names(2:end),'Location','north');
ll.Interpreter='none';

subplot(1,2,2);
hold on; 
for ix=1:(length(preprocessing_names)-1) 
    pp(ix) = plot(values_reg(ix+1,:)./values_reg(1,:),'Color',histogram_color{ix},'LineStyle','--','LineWidth',1.5); 
end
tt=title({'relative histogram diff','(compared to preprocessing with RP12_CSF2)'});
ax=gca; ax.YLim=[0,1.4];
ax.XTickLabel=BetaValuesRegressors.(preprocessing_names{1}).names;
ax.XTick=[1:size(values_reg,2)];
rotateXLabels(ax,60);
ll=legend([pp(1),pp(2),pp(3),pp(4),pp(5)],preprocessing_names(2:end),'Location','north');
ll.Interpreter='none';
% print
[annot, srcInfo] = docDataSrc(fig(6),outputdir,mfilename('fullpath'),logical(1))
exportgraphics(fig(6),fullfile(outputdir,['Histogram_Difference_Quantification.pdf']),'Resolution',300);
% print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');

