function res=do_firstlevel_residuals_2sessions_jr(Pfuncall_1,Pfuncall_2,ROI_1,ROI_2,COV_1,COV_2,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
% Reinwald, Jonathan; 06/2021

%% Clearing
clear matlabbatch

%% LOAD JOB
ROI_size = length(ROI_1);

if ~isempty(COV_1)
    load(COV_1);
    numberREG_rp = sum(contains(names,'rp'));
    numberREG_csf = sum(contains(names,'csf'));
    job_firstlevel_residuals_jr
else
    job_firstlevel_residuals_noREG_noCOV_jr
end

%% DEFINITIONS

% define EPI input
matlabbatch{1}.spm.stats.fmri_spec.sess(1).scans = cellstr(Pfuncall_1);
matlabbatch{1}.spm.stats.fmri_spec.sess(2).scans = cellstr(Pfuncall_2);

% define regressors of interest
if ~isempty(ROI_1)
    for ix=1:length(ROI_1)
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).name = ROI_1(ix).name;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).onset = ROI_1(ix).values;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).duration = ROI_1(ix).duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).tmod = 0;
        if ~isfield(ROI_1(ix),'PM')
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).orth = orth;
        elseif isfield(ROI_1(ix),'PM')
            % define parametric modulation
            for jx=1:length(ROI_1(ix).PM)
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).pmod(jx).name = ['PM_' ROI_1(ix).name '_by_' ROI_1(ix).PM(jx).name];
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).pmod(jx).param = ROI_1(ix).PM(jx).vector;
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).pmod(jx).poly = 1;     
                matlabbatch{1}.spm.stats.fmri_spec.sess(1).cond(ix).orth = orth;
            end
        end
        
    end
end
% define regressors of interest
if ~isempty(ROI_2)
    for ix=1:length(ROI_2)
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).name = ROI_2(ix).name;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).onset = ROI_2(ix).values;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).duration = ROI_2(ix).duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).tmod = 0;
        if ~isfield(ROI_2(ix),'PM')
            matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).orth = orth;
        elseif isfield(ROI_2(ix),'PM')
            % define parametric modulation
            for jx=1:length(ROI_2(ix).PM)
                matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).pmod(jx).name = ['PM_' ROI_2(ix).name '_by_' ROI_2(ix).PM(jx).name];
                matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).pmod(jx).param = ROI_2(ix).PM(jx).vector;
                matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).pmod(jx).poly = 1;     
                matlabbatch{1}.spm.stats.fmri_spec.sess(2).cond(ix).orth = orth;
            end
        end
        
    end
end

% define covariates (regressors of no interest)
if ~isempty(COV_1)
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(1).multi_reg = cellstr(COV_1);
end
% define covariates (regressors of no interest)
if ~isempty(COV_2)
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(2).multi_reg = cellstr(COV_2);
end
% define higp-pass filter
matlabbatch{1}.spm.stats.fmri_spec.sess(1).hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.sess(2).hpf = 128;

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









