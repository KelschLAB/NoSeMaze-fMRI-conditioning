% LOAD input.mat FIRST!
% This function sums up the calculation of the mean timecourses, the
% calculation of the CC and fCC maps and the estimation of the final
% SPM.mat-file which you can use to control your results.
% The following parameters should be predefined an saved in a mat-file,
% which you should load before:
% - Pmsk: a list with the paths of all the nii-files of your ROIs (i.e./home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/ROI_masks_new_hres/hr_Acb.nii,   
% /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/ROI_masks_new_hres/hr_Amyg.nii,
% /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/ROI_masks_new_hres/hr_Au.nii,
% etc. ); use spm_select for creating it
% - Pfunc_unsmoothed: a list with the paths of all unsmoothed EPIs for the calculation of the mean timecourses (i.e. /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/unsmoothed_EPIs/bpm_csffilt_wst5_aaztec_or0_filt_uZI_R160208A_1_1_20160208_100056_07_reorient_c1_c2.nii
% /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/unsmoothed_EPIs/bpm_csffilt_wst5_aaztec_or0_filt_uZI_R160208B_1_1_20160208_111429_07_reorient_c1_c2.nii
% /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/unsmoothed_EPIs/bpm_csffilt_wst5_aaztec_or0_filt_uZI_R160208C_1_1_20160208_122207_07_reorient_c1_c2.nii,
% etc.); use spm_select for creating it
% - Pfunc_smoothedandmasked: a list with the paths of all smoothed ((and masked) EPIs for the calculation of CC and fCC maps (i.e. /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/smoothed_and_masked_EPIs/msbpm_csffilt_wst5_aaztec_or0_filt_uZI_R160208A_1_1_20160208_100056_07_reorient_c1_c2.nii
% /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/smoothed_and_masked_EPIs/msbpm_csffilt_wst5_aaztec_or0_filt_uZI_R160208B_1_1_20160208_111429_07_reorient_c1_c2.nii
% /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Input/smoothed_and_masked_EPIs/msbpm_csffilt_wst5_aaztec_or0_filt_uZI_R160208C_1_1_20160208_122207_07_reorient_c1_c2.nii
% etc.); use spm_select for creating it
% - Pdir: directory for your output (i.e. /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/seedbased_analysis/Output_ROIs/)
% - threshold: threshold for the calculation of the CC and fCC maps to
% diminish noise, i.e. 1 means 1% of the maximum t-value 
% - Pmsk_general: masking for the factorial design stap, use a mask of your
% 3d, (i.e. /home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/Atlas_Schwarz_new_template/3dMean_mask_func_res.nii)
% - gr1: group 1 i.e. control group, [1:2:12] or [1 3 5 7 ...]
% - gr2: group 2 i.e. control group, [2:2:12] or [2 4 6 8 ...]
% - name_contr1: name of first contrast, i.e. name_contr1='Control>PWSI'
% - name_contr2: name of second contrast, i.e. name_contr2='Control<PWSI'
% - value_contr1: definition of the contrast 1 i.e. value_contr1=[1 -1]
% - value_contr2: definition of the contrast 2 i.e. value_contr2=[-1 1]
% You will get the following output:
% - in your Pdir, a folder with the name of the ROI will be created, i.e.
% hr_acb
% - in this folder you get 3 subfolders: 
%       - tc (containing the _mask.nii (functional mask of the region), _hr_HcAD_roidata.mat, _hr_HcAD_tc.txt, _tc_sv.txt for every animal)
%       - fCC (containing the fCC (Fisher cluster coefficient maps) for every animal 
%       - CC (containing the CC (cluster coefficient maps) for every animal 
% - in this folder you also get: 
%       - beta_0001.hdr (images containing beta values headers/images)
%       - beta_0001.img 
%       - beta_0002.hdr 
%       - beta_0002.img
%       - mask.hdr 
%       - mask.img
%       - ResMS.hdr
%       - ResMS.img
%       - RPV.hdr
%       - RPV.img
%       - con_0001.hdr (images containing weighted parameter estimates)
%       - con_0001.img
%       - con_0002.hdr
%       - con_0002.img
%       - SPM.mat --> MAt-file to use for your results later
%       - spmT_0001.hdr (iamges with T-statistics)
%       - spmT_0001.img
%       - spmT_0002.hdr
%       - spmT_0002.img

% 
function jr_do_seedanalysis(Pmsk, Pfunc_unsmoothed, Pfunc_smoothedandmasked, Pdir, threshold, Pmsk_general, gr1, gr2, name_contr1, name_contr2, value_contr1, value_contr2)

%% copying of files
if 1==0;
    load('/home/jonathan.reinwald/Output/CNV_jr/functional/preprocessing/pathlist_CNV.mat')
    dir='/home/jonathan.reinwald/Output/CNV_jr/seedanalyses/Pfunc_smoothedandmasked/'
    for ix=1:size(Pfunc,2);
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('FPlist',fpath,['^s6bpm_0.01_0.1_scrub_X2_lin_regfilt_motcsf_wold_st_aaztec_or0_ufullmsk' fname '_c3.nii']);
        copyfile(Pcur,dir)
    end;
end;

for ix=1:size(Pmsk,1);
    Pmsk_cur=deblank(Pmsk(ix,:));
    [fdir fname ext]=fileparts(Pmsk_cur);
    mkdir(Pdir,fname)
    Pdir_msk=[Pdir fname '/']
    % ----------------- Calculation of the mean timecourses (per animal)---
    % Pmsk_cur
    % Pfunc_unsmoothed
    % Pdirtc
    Pfunc_cur=Pfunc_unsmoothed
    mkdir(Pdir_msk,'tc')
    Pdir_cur=[Pdir_msk 'tc' '/']
    
    if 1==1
        nsubs=size(Pfunc_cur,1)
        
        for n=1:nsubs
            [tc{n} roidata{n}]=wwf_roi_tcours(Pmsk_cur,deblank(Pfunc_cur(n,:)),Pdir_cur);
        end
    end
    % --------------- Calculation of the CC/fCC maps (per animal) ---------
    
    Ptc=spm_select('FPList',Pdir_cur,'.*.tc.txt');
    Pfunc_cur=Pfunc_smoothedandmasked;
    mkdir(Pdir_msk,'fCC');
    mkdir(Pdir_msk,'CC');
    Pdir_saveCC=[Pdir_msk 'CC' '/'];
    Pdir_savefCC=[Pdir_msk 'fCC' '/'];
    
    if 1==1
        wwf_calc_ccimg(Pfunc_cur, Ptc, threshold, Pdir_saveCC, Pdir_savefCC);
    end
    
    % --------------- Calculation of the t-statistic (SPM.mat and so on) ---
    
    Pfccscans=spm_select('FPList',Pdir_savefCC,'^fCC.*.nii');
    
    if 1==0
        job_factorialdesign_estimate_con
               
        matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(Pdir_msk);
        matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = cellstr(Pfccscans(gr1,:));
        matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = cellstr(Pfccscans(gr2,:));
        matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;
        matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(Pmsk_general);
        
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = name_contr1;
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = value_contr1;
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = name_contr2;
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = value_contr2;
        
        spm_jobman('run',matlabbatch);
    end
end