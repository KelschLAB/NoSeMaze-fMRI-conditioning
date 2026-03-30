function cc_do_reslice_rMNI(Pcur)

[fdir fname ext]=fileparts(Pcur);
Pcurn=spm_select('ExtFPlist',fdir,['^' fname '.nii$'],[1:5000]);

job_reslice_rMNI

matlabbatch{1}.spm.spatial.coreg.write.source = cellstr(Pcurn);

spm_jobman('initcfg');
spm_jobman('run',matlabbatch);