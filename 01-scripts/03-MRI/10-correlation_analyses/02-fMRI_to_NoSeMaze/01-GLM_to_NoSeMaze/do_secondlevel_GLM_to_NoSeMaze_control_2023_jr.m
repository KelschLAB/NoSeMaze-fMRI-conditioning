function do_secondlevel_GLM_to_NoSeMaze_control_2023_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar)

%% Loop over contrasts
for ix = 1:length(contrast_info)
    % clearing
    clear matlabbatch input

    % load predefined job
    job_secondlevel_GLM_to_NoSeMaze_jr
    
    % 1. define output directory for secondlevel
    outputdir = [outputDir_secondlevel filesep contrast_info{ix}.names];
    mkdir(outputdir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {(outputdir)};
    
    % 2. Define input files
    if contrast_info{ix}.test == 'fcon';
        input = spm_select('ExtFPListRec',firstlevelDir,['^ess_000' num2str(ix)],1);
    elseif contrast_info{ix}.test == 'tcon' & ix<10;
        input = spm_select('ExtFPListRec',firstlevelDir,['^con_000' num2str(ix)],1)
    elseif contrast_info{ix}.test == 'tcon' & ix>=10;
        input = spm_select('ExtFPListRec',firstlevelDir,['^con_00' num2str(ix)],1)        
    end
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(input);
    
    % 3. Define mask
    matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);
    
       
    % Define input
    matlabbatch{1}.spm.stats.factorial_design.cov.c = ExplVar.values;% sorting has already been done
    matlabbatch{1}.spm.stats.factorial_design.cov.cname = ExplVar.name;
    matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1; % Interaction: 2 = with Factor 1
    matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1; % Meaning: 2 = with Factor 1
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    
    % 5. Contrast definition
    numbVar = length(ExplVar)+1;
    counter=1;
    matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

    for jx=1:numbVar
        % positive (+) contrast
        if jx==1
            matlabbatch{3}.spm.stats.con.consess{counter}.tcon.name = 'mean+';
        else
            matlabbatch{3}.spm.stats.con.consess{counter}.tcon.name = [ExplVar((jx-1)).name '+'];
        end
        tempVar = zeros(1,(length(ExplVar)+1));
        tempVar(1,jx) = 1;
        matlabbatch{3}.spm.stats.con.consess{counter}.tcon.weights = tempVar;
        matlabbatch{3}.spm.stats.con.consess{counter}.tcon.sessrep = 'none';
        counter=counter+1;
        % positive (-) contrast
%                 matlabbatch{3}.spm.stats.con.spmmat(counter) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        if jx==1
            matlabbatch{3}.spm.stats.con.consess{counter}.tcon.name = 'mean-';
        else
            matlabbatch{3}.spm.stats.con.consess{counter}.tcon.name = [ExplVar((jx-1)).name '-'];
        end
        tempVar = zeros(1,(length(ExplVar)+1));
        tempVar(1,jx) = -1;
        matlabbatch{3}.spm.stats.con.consess{counter}.tcon.weights = tempVar;
        matlabbatch{3}.spm.stats.con.consess{counter}.tcon.sessrep = 'none';
        counter=counter+1;
    end
    matlabbatch{3}.spm.stats.con.delete = 1;
    spm_jobman('run',matlabbatch)
end