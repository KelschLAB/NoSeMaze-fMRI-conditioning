function res=do_first_level_residuals_JR_no_licks(Pfunc_all,licks,mult_regressors,spec_mask,dircur,DerDisp,mask_thres)



%% 
% "do_first_level_residuals" creates spm batch for an analysis of
% residuals. Therefore, we do not modelate odors, reward -> only licks.
% realignment parameters are included ... 

% INFO
% code is partially extracted from do_first_level_main_lw ... I was trying
% to simplify the code! 



%% LOAD BASIC FRAMEWORK FOR BATCH
job_residuals_JR



%% LOAD VARIABLES INTO FRAMEWORK ...
 
% load outputdir ... 
matlabbatch{1}.spm.stats.fmri_spec.dir = {dircur};
% load imaging data ... 
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(Pfunc_all); 

    % licks
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'licks';
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = licks;

matlabbatch{1}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    
% load nuissance regressors ... 
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(mult_regressors);
% load options for derivatives/dispersion ...
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [DerDisp]; 
% load mask ...
matlabbatch{1}.spm.stats.fmri_spec.mask = cellstr(spec_mask);
matlabbatch{1}.spm.stats.fmri_spec.mthresh = mask_thres;



%% SPM SPM SPM 
spm_jobman('run',matlabbatch);
%spm_jobman('interactive',matlabbatch);









