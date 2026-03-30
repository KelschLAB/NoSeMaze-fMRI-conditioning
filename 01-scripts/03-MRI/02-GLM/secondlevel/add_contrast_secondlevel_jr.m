function add_contrast_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)



%% Loop over contrasts
for ix = 1:length(contrast_info)
    % clearing
    clear matlabbatch input

    % load predefined job
    job_secondlevel_jr
    
    % 1. define output directory for secondlevel
    outputdir = [outputDir_secondlevel filesep contrast_info{ix}.names];
    mkdir(outputdir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {(outputdir)};
    
    % 2. Define input files
    if contrast_info{ix}.test == 'fcon';
        input = spm_select('ExtFPListRec',firstlevelDir,['ess_000' num2str(ix)],1);
    elseif contrast_info{ix}.test == 'tcon' & ix<10;
        input = spm_select('ExtFPListRec',firstlevelDir,['con_000' num2str(ix)],1)
    elseif contrast_info{ix}.test == 'tcon' & ix>=10;
        input = spm_select('ExtFPListRec',firstlevelDir,['con_00' num2str(ix)],1)        
    end
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(input);
    
    % 3. Define mask
    matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);
    
    spm_jobman('run',matlabbatch)
end