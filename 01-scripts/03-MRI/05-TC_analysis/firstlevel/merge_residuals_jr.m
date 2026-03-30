function merge_residuals_jr(outputdir)
% Jonathan Reinwald 06/2021 based on script by Laurens Winkelmeier
% "MergeNiftis_LW" concatenates single 3D nifti files
% needed for residual analysis!

%% Selection of firstlevel directory ...
cd(outputdir);
firstleveldir=spm_select(1,'dir','Select directory including firstlevel_residuals directory!');

%% Get number of sessions included in firstlevel ...
dirlist = dir(firstleveldir);
dirlist = dirlist(contains({dirlist.name},'ZI_M'));

% number sessions in current firstleveldir ...
numbersess = numel(dirlist);

% start SPM
spm fmri

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over sessions
for sess = 1:numbersess;
    
    %% select all niftis you want to merge ...
    % get sessiondir ...
    sessiondir = [firstleveldir filesep dirlist(sess).name];
       
    % select ...
    P = spm_select('ExtFPlistrec',sessiondir,'Res_.*');
    
    try
        % merge ...
        
        matlabbatch{1}.spm.util.cat.vols = cellstr(P);
        matlabbatch{1}.spm.util.cat.name = ['4D_residuals_' dirlist(sess).name '.nii'];
        matlabbatch{1}.spm.util.cat.dtype = 0;  % 0 = SAME ...
        % run batch ...
        spm_jobman('run',matlabbatch);
        
        % delete old files ...
        cd(sessiondir); %cd('rp_der');
        delete 'ResI_*'
        delete 'Res_*'
    catch
    end
end