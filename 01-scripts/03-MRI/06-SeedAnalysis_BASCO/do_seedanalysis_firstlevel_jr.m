function do_seedanalysis_firstlevel_jr(Pseed, Pfunc_unsmoothed, Pfunc_smoothedandmasked, Pdir, threshold, Pmsk)
% Script for firstlevel seedbased analysis:
% mandatory subscripts:
% -
% /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/06-SeedAnalysis_BASCO/wwf_roi_tcours.m
% --> creates seed mean time course in Pdir/tc/
% - /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/06-SeedAnalysis_BASCO/wwf_calc_ccimg.m
% --> calculates correlation coefficiant images (for
% Pfunc_smoothedandmasked with mean time course)
% Input variables:
% - Pseed: path(es) of seedmask-files, e.g. a ROI, an activation mask...
% - Pfunc_unsmoothed: (normally) unsmoothed functional images as a
% character array (n x m), n is the number of animals/sessions
% - Pfunc_smoothedandmaske: (normally) smoothed and masked functional images as a
% character array (n x m), n is the number of animals/sessions (here:
% identical for the BASCO seedbased analysis)
% - Pdir: output directory
% - threshold: a threshold set by the scripts of WWF
% - Pmsk: general brain (or regional) mask
%
% Output:
% - in "Pdir"/tc/ --> in "Pdir"/tc/ --> *SEEDNAME_roidata.mat; *SEEDNAME_tc.txt;
% *SEEDNAME_tc_sv.txt; *_mask.nii;
% - 
%__________________________________________________________________________
% Jonathan Reinwald, 19.01.2022
% Central Institute of Mental Health, J5, 68159 Mannheim
% jonathan.reinwald@zi-mannheim.de

%% STEP 1: Calculation of the mean timecourses for the seed
% in folder Pdir/tc/ in "Pdir"/tc/ --> *SEEDNAME_roidata.mat (roidata information with time courses of all voxels); *SEEDNAME_tc.txt (mean time course);
% *SEEDNAME_tc_sv.txt (time courses of all voxels); *_mask.nii;

% define current input (unsmoothed data for ROI mean time course)
Pfunc_cur=Pfunc_unsmoothed
% make folder
mkdir(Pdir,'tc')
Pdir_cur=[Pdir filesep 'tc' filesep]

if 1==1
    nsubs=size(Pfunc_cur,1)    
    % Loop over subjects
    for n=1:nsubs
        % Creation of (mean) time course
        [tc{n} roidata{n}]=wwf_roi_tcours(Pseed,deblank(Pfunc_cur(n,:)),Pdir_cur);
    end
end
%% STEP 2: Calculation of the individual CC/fCC maps
% selection of mean time course
Ptc=spm_select('FPList',Pdir_cur,'.*.tc.txt');
% define current input (whole-brain smoothed functional data)
Pfunc_cur=Pfunc_smoothedandmasked;
% make output folders
mkdir(Pdir,'fCC');
mkdir(Pdir,'CC');
Pdir_saveCC=[Pdir filesep 'CC' filesep];
Pdir_savefCC=[Pdir filesep 'fCC' filesep];

if 1==1
    % Calculate correlation coefficiant images for P with timecourse Ptc
    wwf_calc_ccimg(Pfunc_cur, Ptc, threshold, Pdir_saveCC, Pdir_savefCC);
end
    
    
