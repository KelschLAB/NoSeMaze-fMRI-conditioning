function do_secondlevel_jr(outputDir_secondlevel,contrast_info,contrast_new_temp,firstlevelDir,explicit_mask)

%% Loop over contrasts
% clearing
clear matlabbatch input

% load predefined job
job_secondlevel_pairedTT_jr

% change respective ...
% 1. define output directory for secondlevel
outputdir = [outputDir_secondlevel filesep contrast_new_temp.output_name];
mkdir(outputdir);
matlabbatch{1}.spm.stats.factorial_design.dir = {(outputdir)};

% 2. Select first scan:
clear con_indx con_sel
con_indx=find(strcmp([contrast_info.names],contrast_new_temp.con1_name));
if con_indx<10
    con_sel = ['con_000' num2str(con_indx) '.nii'];
elseif con_indx>=10
    con_sel = ['con_00' num2str(con_indx) '.nii'];
end
P_scan_con1 = spm_select('ExtFPListrec',firstlevelDir,con_sel,1)

% 3. Select second scan:
clear con_indx con_sel
con_indx=find(strcmp([contrast_info.names],contrast_new_temp.con2_name));
if con_indx<10
    con_sel = ['con_000' num2str(con_indx) '.nii'];
elseif con_indx>=10
    con_sel = ['con_00' num2str(con_indx) '.nii'];
end
P_scan_con2 = spm_select('ExtFPListrec',firstlevelDir,con_sel,1)

for p_ix = 1:size(P_scan_con1,1)
    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(p_ix).scans = [cellstr(deblank(P_scan_con1(p_ix,:)));cellstr(deblank(P_scan_con2(p_ix,:)))]
end
matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

spm_jobman('run',matlabbatch)
