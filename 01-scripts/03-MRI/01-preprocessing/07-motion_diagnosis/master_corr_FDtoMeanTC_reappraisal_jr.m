%% master_corr_FDtoMeanTC_reappraisal_jr.m
%% AIM: Compare pearson's correlation coefficients between FD and GS/regional signal under different nuisance regressors (different preprocessing methods)


% Define the different preprocessing methods for the comparison
preprocessing_names = {'RP12_CSF2','RP12_CSF2_scrub01','RP12_CSF2_WD','RP12_CSF2_AFNI_WD','RP12_CSF2_AFNI_WD_DVARSscrub'};
% use the folders from the mean TC construction in here (as the RPs are already included as covariates)
preprocessing_folders = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v99___COV_v1___ORTH_1___11-Jan-2022',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_med1000_msk_s6_scrub_0_1_lin_w___ROI_v99___COV_v1___ORTH_1___14-Jan-2022',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v99___COV_v1___ORTH_1___10-Jan-2022',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022',...
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_DVARSscrub_0_1_lin_wave_10cons_med1000_msk_wrst_a1_u_despiked_del5____ROI_v99___COV_v1___ORTH_1___09-Aug-2023',...
    };

% 
outputdir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/01-preprocessing/01-motion/FD_to_meanTC';

%% loop over preprocessing methods 
for ppm_idx = 1:length(preprocessing_names)
    
    % Get subject folders
    firstlevel_dir = fullfile(preprocessing_folders{ppm_idx},'firstlevel');
    [subject_folders] = spm_select('FPList',firstlevel_dir,'dir',['^ZI_M.*.'])
    
    %% loop over subjects
    for subj = 1:size(subject_folders,1)
        
        % clearing
        clear SPM.mat rp FD tc subj_abrev
        
        % 
        [subj_dir,subj_abrev,~] = fileparts(deblank(subject_folders(subj,:)));
        
        % load SPM.mat-file to get the realignment parameters and calculate the
        % FD
        load(fullfile(deblank(subject_folders(subj,:)),'SPM.mat'));
        rp = SPM.Sess.C.C(:,[1:6]);
        FD= SNiP_framewise_displacement(rp);
        FD_all(ppm_idx,subj,:)=FD;
        
        % load global mean time course
        tc = load(fullfile(deblank(subject_folders(subj,:)),['4D_residuals_' subj_abrev '_rDLtemplate_original_inPax_brainmask_tc.txt']));
        %         tc = load(fullfile(deblank(subject_folders(subj,:)),['4D_residuals_' subj_abrev '_RN_tc.txt']));
        tc_all(ppm_idx,subj,:)=tc;

        % fill in full array
        myArray.(preprocessing_names{ppm_idx}).subjects{subj}=subj_abrev;
        myArray.(preprocessing_names{ppm_idx}).corrFD.('GlobalSignal').rho(subj)=corr(FD,tc,'type','Pearson');
        myArray.(preprocessing_names{ppm_idx}).corrFD_spearman.('GlobalSignal').rho(subj)=corr(FD,tc,'type','Spearman');
        myArray.(preprocessing_names{ppm_idx}).FD.('GlobalSignal').value(subj,:)=FD;
    end
end

%% Plot
% figure
fig=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
% plot
subplot(1,2,1);
nb=notBoxPlot([myArray.RP12_CSF2.corrFD.GlobalSignal.rho',myArray.RP12_CSF2_scrub01.corrFD.GlobalSignal.rho',myArray.RP12_CSF2_WD.corrFD.GlobalSignal.rho',myArray.RP12_CSF2_AFNI_WD.corrFD.GlobalSignal.rho',myArray.RP12_CSF2_AFNI_WD_DVARSscrub.corrFD.GlobalSignal.rho']);
% axes
ax=gca;
set(gca,'TickLabelInterpreter','none');
ax.YLim=[-.4,.4];

ax.XTick=[1:length(preprocessing_names)];
ax.XTickLabel=preprocessing_names;
ax.FontSize=10;
rotateXLabels(ax,45);

% Title
tt = title({'Pearsons rho: FD to global signal','(based on meanTC after )'});
tt.Interpreter='none';

subplot(1,2,2);
nb=notBoxPlot([myArray.RP12_CSF2.corrFD_spearman.GlobalSignal.rho',myArray.RP12_CSF2_scrub01.corrFD_spearman.GlobalSignal.rho',myArray.RP12_CSF2_WD.corrFD_spearman.GlobalSignal.rho',myArray.RP12_CSF2_AFNI_WD.corrFD_spearman.GlobalSignal.rho',myArray.RP12_CSF2_AFNI_WD_DVARSscrub.corrFD_spearman.GlobalSignal.rho']);
% axes
ax=gca;
set(gca,'TickLabelInterpreter','none');
ax.YLim=[-.4,.4];

ax.XTick=[1:length(preprocessing_names)];
ax.XTickLabel=preprocessing_names;
ax.FontSize=10;
rotateXLabels(ax,45);

% Title
tt = title({'Spearmans rho: FD to global signal','(based on meanTC after )'});
tt.Interpreter='none';
        
% print
[annot, srcInfo] = docDataSrc(fig,outputdir,mfilename('fullpath'),logical(1))
exportgraphics(fig,fullfile(outputdir,['FD_to_meanTC.pdf']),'Resolution',300);
% print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');


