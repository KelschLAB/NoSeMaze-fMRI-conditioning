function res=do_firstlevel_jr(Pfuncall,ROI,COV,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
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
if DerDisp==[0 0]
    ROI_size = length(ROI);
    if isfield(ROI,'PM')
        PM_size = length([ROI.PM]);
    else
        PM_size=0;
    end
elseif DerDisp==[1 1]
    ROI_size = length(ROI).*3;
    if isfield(ROI,'PM')
        PM_size = length([ROI.PM]).*3;
    else
        PM_size=0;
    end
end

if ~isempty(COV)
    load(COV);
    numberREG_rp = sum(contains(names,'rp'));
    numberREG_csf = sum(contains(names,'csf') | contains(names,'FD'));
    job_firstlevel_covariates_jr
elseif isempty(COV)
    job_firstlevel_no_covariates_jr
end

%% DEFINITIONS

% length of already integrated contrasts
numb_contrasts_job = length(matlabbatch{3}.spm.stats.con.consess);

% define EPI input
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(Pfuncall);

% define regressors of interest
if ~isempty(ROI)
    for ix=1:length(ROI)
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).name = ROI(ix).name;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).onset = ROI(ix).values;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).duration = ROI(ix).duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).tmod = 0;
        if ~isfield(ROI(ix),'PM')
            matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).orth = orth;
        elseif isfield(ROI(ix),'PM')
            % define parametric modulation
            for jx=1:length(ROI(ix).PM)
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod(jx).name = ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name];
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod(jx).param = ROI(ix).PM(jx).vector;
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod(jx).poly = 1;
                matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).orth = orth;
            end
        end
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

% define contrasts for ROIs
counter = 1;
if isfield(ROI,'PM')
    if DerDisp==[0 0]
        zero_mat=zeros((length(ROI)+length([ROI.PM])),1);
    elseif DerDisp==[1 1]
        zero_mat=zeros((length(ROI)+length([ROI.PM]))*3,1);
    end
else
    if DerDisp==[0 0]
        zero_mat=zeros(length(ROI),1);
    elseif DerDisp==[1 1]
        zero_mat=zeros(length(ROI)*3,1);
    end
end

if DerDisp==[0 0]
    for ix=1:size(ROI,2)
        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ROI(ix).name;
        clear help_mat;
        help_mat=zero_mat;
        help_mat(counter)=1;
        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
        counter=counter+1;
        if isfield(ROI(ix),'PM')
            % define contrasts for PM
            for jx=1:length(ROI(ix).PM)
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name];
                clear help_mat;
                help_mat=zero_mat;
                help_mat(counter)=1;
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
                counter=counter+1;
            end
        end
    end
end

if DerDisp==[1 1]
    for ix=1:size(ROI,2)
        for jx=1:3
            if jx==1
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ROI(ix).name;
            elseif jx==2
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = [ROI(ix).name '_Deriv'];
            elseif jx==3
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = [ROI(ix).name '_Disp'];
            end
            clear help_mat;
            help_mat=zero_mat;
            help_mat(counter)=1;
            matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
            matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
            counter=counter+1;
        end
        if isfield(ROI(ix),'PM')
            % define contrasts for PM
            for jx=1:length(ROI(ix).PM)
                for kx=1:3
                    if kx==1
                        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name];
                    elseif kx==2
                        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name '_Deriv'];
                    elseif kx==3
                        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name '_Disp'];
                    end
                    clear help_mat;
                    help_mat=zero_mat;
                    help_mat(counter)=1;
                    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
                    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
                    counter=counter+1;
                end
            end
        end
    end
end

% % additional contrasts
% counter = 1;
% for sx =1:(length(ROI)-1)
%     matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)}.tcon.name = [ROI(sx).name 'vs' ROI(sx+1).name];
%     help_mat = [zeros(1,length(ROI)),zeros(1,length(PM))];
%     help_mat(counter)=1;
%     for
%     help_mat
%     if
%     help_mat(counter+length(PM(sx))+1)=-1;
%     counter = counter + length(PM(sx)) +1;
%     matlabbatch{3}.spm.stats.con.consess{kx+numb_contrasts_job+PM_counter}.tcon.weights = help_mat;
%     matlabbatch{3}.spm.stats.con.consess{kx+numb_contrasts_job+PM_counter}.tcon.sessrep = 'none';
% end
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+1}.tcon.name = [ROI(1).name 'vs' ROI(2).name];
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+1}.tcon.weights = [1 -1];
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+1}.tcon.sessrep = 'none';

% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+2}.tcon.name = [ROI(1).name 'vs' ROI(3).name];
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+2}.tcon.weights = [1 0 -1];
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+2}.tcon.sessrep = 'none';
% %
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+3}.tcon.name = [ROI(2).name 'vs' ROI(3).name];
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+3}.tcon.weights = [0 1 -1];
% matlabbatch{3}.spm.stats.con.consess{size(ROI,2)+numb_contrasts_job+size(PM,2)+3}.tcon.sessrep = 'none';

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

spm_jobman('run',matlabbatch);
1==1;