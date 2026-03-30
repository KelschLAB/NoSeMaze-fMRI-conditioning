function do_seedanalysis_secondlevel_RS_jr(P_fcc, P_outputdir, Pmsk_general, contrast)

% Factorial Design Specification
matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(P_outputdir);
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(P_fcc);
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; % threshold masking (off)
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0; % implicit mask
matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(Pmsk_general); % explicit mask
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1; % global calculation (only PET/VBM);
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1; % overall grand mean scaling (only PET/VBM);
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1; % normalisation (only PET/VBM);
% Model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
% Contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
for tx = 1:length(contrast.name)
    matlabbatch{3}.spm.stats.con.consess{tx}.tcon.name = contrast.name{tx};
    matlabbatch{3}.spm.stats.con.consess{tx}.tcon.convec = contrast.val{tx};
    matlabbatch{3}.spm.stats.con.consess{tx}.tcon.sessrep = 'none';%'bothsc';
end
matlabbatch{3}.spm.stats.con.delete = 0;
% run
spm_jobman('run',matlabbatch);
