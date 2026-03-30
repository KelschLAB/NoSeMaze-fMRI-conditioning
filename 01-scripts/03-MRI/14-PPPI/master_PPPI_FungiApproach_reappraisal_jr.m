%% master_PPPI_FungiApproach_reappraisal_jr.m
% Reinwald, Jonathan, 06.07.2023

% master script for running PPPI analyses
% citation
% subscripts
% ...


%% Preparation
clear all;
close all;

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
HRF_name = ['HRF' HRF_TCbased '_' HRF_infopath];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_'; % No smoothing before cormat creation
epiSuffix = '_c1_c2t_wds';

%% Set pathes for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/PPPIv13.1'));

% GLM dir
GLM_dir = spm_select(1,'dir','Select GLM Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results');
filelist = spm_select('FPList',[GLM_dir filesep 'firstlevel'],'dir',['^ZI_M.*.']);

% selection of VOI
myVOIs{1}=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T001.nii'];
myVOIs{2}='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_T001.nii';

% start SPM fmri
spm('CreateMenuWin','off');
spm('CreateIntWin','off');

%% Loop over animal folders
for animal_idx = 1:size(filelist,1)
    
    %% Loop over VOIs
    for voi_idx = 1:length(myVOIs)
        
        %% PPI step-by-step
        % PPIs are based on regression models, and therefore a direction of
        % influence is chosend based on the model --> effective
        % connectivity.
        % ...
        % The interaction between the source region and experimental context (or two source regions)
        % can be interpreted in 2 different ways: 1) as demonstrating how the contribution of one region
        % to another is altered by the experimental context or task, or 2) as an example of how an area's
        % response to an experimental context is modulated by input from
        % another region. (https://www.fil.ion.ucl.ac.uk/spm/doc/spm12_manual.pdf, p.340)
        % 1.) Standard GLM analysis
        % 2.) Extracting BOLD signal from a source region identified in the
        % GLM analysis (our VOIs)
        % 3.) Forming the interaction term (source signal x experimental
        % treatment)
        % 4.) Performing a second GLM analysis that includes the
        % interaction term, the source region's extracted signal and the
        % experimental vector in the design
        
        % 1.) Standard GLM analysis (already performed in
        % master_GLM_reappraisal_jr.m)
        
        % 2.) Extracting BOLD signal from source region
        % batch definition
        clear matlabbatch subject_name
        [~,subject_name,~]=fileparts(filelist(animal_idx,:));
        subject_1stlevel_directory=[GLM_dir filesep 'firstlevel' filesep subject_name];
        matlabbatch{1}.spm.util.voi.spmmat = {fullfile(subject_1stlevel_directory,'SPM.mat')};
        matlabbatch{1}.spm.util.voi.adjust = 0; % adjustment: 0=no, NaN=yes; CAVE: counterintuitively vice-versa in SPM! --> check
        matlabbatch{1}.spm.util.voi.session = 1; % session number
        [~,voi_name,~]=fileparts(myVOIs{voi_idx});
        matlabbatch{1}.spm.util.voi.name = voi_name;
        matlabbatch{1}.spm.util.voi.roi{1}.mask.image = myVOIs(voi_idx);
        matlabbatch{1}.spm.util.voi.roi{1}.mask.threshold = 0.5;
        matlabbatch{1}.spm.util.voi.expression = 'i1';
        % run batch
        % start SPM fmri
        spm('CreateMenuWin','off');
        spm('CreateIntWin','off');
        spm_jobman('run',matlabbatch);
        
        % 3.) Forming of the interaction terms for all conditions
        % !!! Check correct HRF selection !!!
        display(['You are using the following HRF: ' which('spm_hrf')]);
        % batch definition
        clear matlabbatch SPM.mat
        matlabbatch{1}.spm.stats.ppi.spmmat = {fullfile(subject_1stlevel_directory,'SPM.mat')};
        matlabbatch{1}.spm.stats.ppi.type.ppi.voi = {fullfile(subject_1stlevel_directory,['VOI_' voi_name '_1.mat'])};
        % Conditions
        load(fullfile(subject_1stlevel_directory,'SPM.mat'));
        if 1==1
            %% Loop over conditions
            for cond_idx = 1:length(SPM.Sess.U)
                matlabbatch{1}.spm.stats.ppi.type.ppi.u = [cond_idx 1 1];
                matlabbatch{1}.spm.stats.ppi.name = SPM.Sess.U(cond_idx).name{1};
                matlabbatch{1}.spm.stats.ppi.disp = 0;
                % run batch
                spm_jobman('run',matlabbatch);
            end
        end
        
        % 4.) Performing a second GLM analysis
        clear matlabbatch
        % make directory
        output_directory = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/14-PPI_traditionalSPM12',[voi_name '_' date],'firstlevel',subject_name);
        mkdir(output_directory)
        %% ----------------------SPM first-level --------------------------
        % output directory
        matlabbatch{1}.spm.stats.fmri_spec.dir = {output_directory};
        % define by scans, not by seconds (as normally done in our GLMs)
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
        % TR
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.2;
        % define microtime resolution (fmri_t) and microtime onset (fmri_t0)
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 22;
        % define EPI input
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(SPM.xY.P);
        % no conditions, all conditions go into the regressor term and are
        % not HRF convolved
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
        % define regressors of interest
        % 1. Main effects and PPI
        PPI_files = spm_select('FPlist',subject_1stlevel_directory,['^PPI.*.mat']);
        for ROI_idx=1:size(PPI_files,1)
            % load file
            load(deblank(PPI_files(ROI_idx,:)));
            % main effect
            matlabbatch{1}.spm.stats.fmri_spec.sess.regress(ROI_idx).name = PPI.name;
            matlabbatch{1}.spm.stats.fmri_spec.sess.regress(ROI_idx).val = PPI.P;
            % PPI effect
            matlabbatch{1}.spm.stats.fmri_spec.sess.regress(ROI_idx+size(PPI_files,1)).name = ['PPI_' PPI.name];
            matlabbatch{1}.spm.stats.fmri_spec.sess.regress(ROI_idx+size(PPI_files,1)).val = PPI.ppi;
        end
        % 2. VOI
        load(fullfile(subject_1stlevel_directory,['VOI_' voi_name '_1.mat']));
        ROI_idx=length(matlabbatch{1}.spm.stats.fmri_spec.sess.regress)+1;
        % VOI mean tc
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress(ROI_idx).name = ['VOI_' voi_name '_meanTC'];
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress(ROI_idx).val = xY.u;
        % 3. Motion and CSF regressors
        R = [SPM.Sess.C.C];
        names = SPM.Sess.C.name;
        save([output_directory filesep 'cov.mat'],'R','names')
        COV = [output_directory filesep 'cov.mat'];
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(COV);
        %
        matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        % no derivs
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        % define masking threshold
        matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
        % mask
        matlabbatch{1}.spm.stats.fmri_spec.mask = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii'};
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        
        
        %% --------------------- model estimation -------------------------
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        %% --------------------- contrasts -------------------------
        matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = [matlabbatch{1}.spm.stats.fmri_spec.sess.regress(20).name 'vs' matlabbatch{1}.spm.stats.fmri_spec.sess.regress(16).name];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [zeros(1,15) -1 zeros(1,3) 1];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
       
        % 
        spm_jobman('run',matlabbatch);
    end
end

