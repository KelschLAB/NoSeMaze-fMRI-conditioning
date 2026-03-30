function res=do_firstlevel_2sessions_jr(Pfuncall_1,Pfuncall_2,ROI_1,ROI_2,COV_1,COV_2,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
% % %% If not enough input
% % if nargin <1
% %     Pfuncall=spm_select;
% % end
% % 
% % if nargin <2
% %     ROI=[];
% % end
% % 
% % if nargin <3
% %     COV='';
% % end
% % 
% % if nargin <4
% %     DerDisp=[0 0];
% % end
% % 
% % if nargin <5
% %     explicit_mask='';
% % end

%% Clearing
clear matlabbatch

%% LOAD JOB
ROI_size = length(ROI_1);
if isfield(ROI_1,'PM')
    PM_size = length([ROI_1.PM]);
else
    PM_size=0;
end

if ~isempty(COV_1)
    load(COV_1);
    numberREG_rp = sum(contains(names,'rp'));
    numberREG_csf = sum(contains(names,'csf'));
    job_firstlevel_covariates_jr
elseif isempty(COV_1)
    job_firstlevel_no_covariates_jr
end

%% DEFINITIONS

% length of already integrated contrasts
numb_contrasts_job = length(matlabbatch{3}.spm.stats.con.consess);

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

% define contrasts for ROIs
counter = 1;
if isfield(ROI_1,'PM')
    zero_mat=zeros((length(ROI_1)+length([ROI_1.PM])+length(ROI_2)+length([ROI_2.PM])),1);
else
    zero_mat=zeros((length(ROI_1)+length(ROI_2)),1);
end

for ix=1:size(ROI_1,2)
    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ROI_1(ix).name;
    clear help_mat;
    help_mat=zero_mat;
    help_mat(counter)=1;
    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
    counter=counter+1;
end

for ix=1:size(ROI_2,2)
    load(COV_1);
    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ROI_2(ix).name;
    clear help_mat;
    help_mat=zero_mat;
    help_mat(counter+size(R,2))=1;
    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
    counter=counter+1;
end


matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

% contrast_names
for names=1:length(matlabbatch{3}.spm.stats.con.consess)
    if isfield(matlabbatch{3}.spm.stats.con.consess{names},'fcon')
        contrast_info.names{names} = matlabbatch{3}.spm.stats.con.consess{names}.fcon.name;
        contrast_info.test{names} = 'fcon';
    elseif isfield(matlabbatch{3}.spm.stats.con.consess{names},'tcon')
        contrast_info.names{names} = matlabbatch{3}.spm.stats.con.consess{names}.tcon.name;
        contrast_info.test{names} = 'tcon';
    end
end

[fdir,~,~]=fileparts(outputDir);
save([fdir filesep 'contrast_info.mat'],'contrast_info');

% spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);

1==1;