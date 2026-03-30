function merge_residuals_jr
% Jonathan Reinwald 06/2021 based on script by Laurens Winkelmeier 
% "MergeNiftis_LW" concatenates single 3D nifti files 
% needed for residual analysis! 


%% Preparation 
clear all; 

%% Selection of firstlevel directory ...
cd('/home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/TC_analysis/results/');
firstleveldir=spm_select(1,'dir','Select directory including firstlevel residual results!');
    
%% get number of sessions included in firstlevel ...
dirlist = dir(firstleveldir);
dirlist = dirlist(contains({dirlist.name},'PD'));
    
    % number sessions in current firstleveldir ... 
    numbersess = numel(dirlist); 
    
    
    
    %% LOOP OVER SESSIONS IN FIRSTLEVELDIR ... 
    
    for sess = 1:numbersess
    
    %% select all niftis you want to merge ... 
        
    % get sessiondir ... 
    sessiondir = [firstleveldir filesep dirlist(sess).name]; 
    
    % select ... 
    P = spm_select('ExtFPlistrec',sessiondir,'ResI_*');
     
    try
    % merge ... 
    spm fmri
    matlabbatch{1}.spm.util.cat.vols = cellstr(P);
    matlabbatch{1}.spm.util.cat.name = ['4D_residuals_' dirlist(sess).name '.nii'];
    matlabbatch{1}.spm.util.cat.dtype = 0;  % 0 = SAME ... 
    % run batch ... 
    spm_jobman('run',matlabbatch);
%     spm_jobman('interactive',matlabbatch);
    
    % delete old files ... 
    cd(sessiondir); cd('rp_der');
    delete 'ResI_*'
    catch 
    end
     

    end
   

















end