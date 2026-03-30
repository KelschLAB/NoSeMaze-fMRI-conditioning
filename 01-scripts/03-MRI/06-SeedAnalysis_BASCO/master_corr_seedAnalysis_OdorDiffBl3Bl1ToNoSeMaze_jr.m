path_seed = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40'
% path_seed = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40';


% explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished_refined.nii';


% path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_RankOwn_Bl3vsBl1_T01/firstlevel/TPnoPuff11to40/fCC';
% path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_Bl3vsBl1_T01/firstlevel/TPnoPuff11to40/fCC';
% path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_OdorBl3vsBl1_T01/firstlevel/Odor11to40/fCC';
path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v11_smoothed_cormat_v9/mask_activation_v22_OdorBl3vsBl1_T01/firstlevel/Odor11to40/fCC';

P1 = spm_select('FPList',path_dir,'^fCC_ZI*');
% path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_RankOwn_Bl3vsBl1_T01/firstlevel/TPnoPuff81to120/fCC';
% path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_Bl3vsBl1_T01/firstlevel/TPnoPuff81to120/fCC';
% path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_OdorBl3vsBl1_T01/firstlevel/Odor81to120/fCC';
path_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v11_smoothed_cormat_v9/mask_activation_v22_OdorBl3vsBl1_T01/firstlevel/Odor81to120/fCC';

P2 = spm_select('FPList',path_dir,'^fCC_ZI*');
% output_dir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_RankOwn_Bl3vsBl1_T01/firstlevel','diffBl3vsBl1');
% output_dir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_OdorBl3vsBl1_T01/firstlevel','diffBl3vsBl1');
output_dir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v11_smoothed_cormat_v9/mask_activation_v22_OdorBl3vsBl1_T01/firstlevel','diffBl3vsBl1');

mkdir(output_dir);

for ix=1:size(P1,1) 
    V1=spm_vol(P1(ix,:)); 
    img1=spm_read_vols(V1); 
    V2=spm_vol(P2(ix,:)); 
    img2=spm_read_vols(V2); 
    
    img_diff=img2-img1; 
    
    [~,fname,~]=fileparts(V2.fname);
    V_out = V2;
    V_out.fname = fullfile(output_dir,[fname(1:22),'_diffBl3vsBl1.nii']);
    spm_write_vol(V_out,img_diff); 
end

P_diff = spm_select('FPList',output_dir,'^fCC_ZI*');

% output_dir_secondlevel = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_RankOwn_Bl3vsBl1_T01','secondlevel','diffBl3vsBl1');
% output_dir_secondlevel = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v10_smoothed_cormat_v8/mask_activation_v24_OdorBl3vsBl1_T01/','secondlevel','diffBl3vsBl1');
output_dir_secondlevel = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/unsmoothed_cormat_v11_smoothed_cormat_v9/mask_activation_v22_OdorBl3vsBl1_T01/','secondlevel','diffBl3vsBl1');

mkdir(output_dir_secondlevel);
cd(output_dir_secondlevel);

load(fullfile(path_seed,'SPM.mat'))

matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(output_dir_secondlevel);
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(P_diff);
% Define input
matlabbatch{1}.spm.stats.factorial_design.cov.c = SPM.xC.rc;
matlabbatch{1}.spm.stats.factorial_design.cov.cname = SPM.xC.rcname;
matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1; % Interaction: 2 = with Factor 1
matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1; % Meaning: 2 = with Factor 1
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'COVactivation';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{3}.spm.stats.con.spmmat(2) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'COVdeactivation';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

spm_jobman('run',matlabbatch);