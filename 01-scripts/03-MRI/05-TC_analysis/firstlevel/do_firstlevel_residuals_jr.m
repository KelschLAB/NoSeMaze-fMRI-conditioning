function res=do_firstlevel_residuals_jr(Pfuncall,ROI,COV,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,PM,mask_thres,orth)
% Reinwald, Jonathan; 06/2021

%% If not enough input
if nargin <1
    Pfuncall=spm_select;
end

if nargin <2
    ROI=[];
end

if nargin <3
    COV='';
end

if nargin <4
    DerDisp=[0 0];
end

if nargin <5
    explicit_mask='';
end

%% Clearing
clear matlabbatch

%% LOAD JOB
ROI_size = length(ROI);
PM_size=length(PM);

if ~isempty(COV)
    load(COV);
    numberREG_rp = sum(contains(names,'rp'));
    numberREG_csf = sum(contains(names,'csf'));
    job_firstlevel_residuals_jr
else
    job_firstlevel_residuals_noREG_noCOV_jr
end

%% DEFINITIONS

% define EPI input
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(Pfuncall);

% define regressors of interest
if ~isempty(ROI)
    for ix=1:length(ROI);
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).name = ROI(ix).name;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).onset = ROI(ix).values;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).duration = ROI(ix).duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).orth = orth;
    end
end

% define covariates (regressors of no interest)
if ~isempty(COV)
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(COV);
end
% define higp-pass filter
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

% define usage of derivatives/disposition
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [DerDisp];

% define explicit mask
matlabbatch{1}.spm.stats.fmri_spec.mask = cellstr(explicit_mask);

% define microtime resolution (fmri_t) and microtime onset (fmri_t0)
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = fmri_t0;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = fmri_t;

% define TR
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;

% define outputDir
matlabbatch{1}.spm.stats.fmri_spec.dir = {outputDir};

% define masking threshold
matlabbatch{1}.spm.stats.fmri_spec.mthresh = mask_thres;

%% Run SPM 
spm_jobman('run',matlabbatch);
1==1









