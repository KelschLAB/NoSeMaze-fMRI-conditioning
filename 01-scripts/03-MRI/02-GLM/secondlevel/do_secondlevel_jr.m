function do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)

%% Loop over contrasts
for ix = 1:length(contrast_info.names)
    % clearing
    clear matlabbatch input
    
    % load predefined job
    job_secondlevel_jr
    
    % 1. define output directory for secondlevel
    outputdir = [outputDir_secondlevel filesep contrast_info.names{ix}];
    if ~exist(outputdir)
        mkdir(outputdir);
        matlabbatch{1}.spm.stats.factorial_design.dir = {(outputdir)};
        
        % 2. Define input files
        if contrast_info.test{ix} == 'fcon';
            myInput = spm_select('ExtFPListRec',firstlevelDir,['ess_000' num2str(ix)],1);
        elseif contrast_info.test{ix} == 'tcon'
            %             input = spm_select('ExtFPListRec',firstlevelDir,['con_000' num2str(ix)],1)
            subDir = dir(firstlevelDir);
            subDir = subDir(contains({subDir.name},'ZI_M'));
            counter=1;
            for subj_num=1:length(subDir)
                load(fullfile(subDir(subj_num).folder,subDir(subj_num).name,'SPM.mat'));
                if sum(ismember({SPM.xCon.name},contrast_info.names{ix}))
                    if find(ismember({SPM.xCon.name},contrast_info.names{ix}))<10
                        input{counter}=fullfile(subDir(subj_num).folder,subDir(subj_num).name,['con_000' num2str(find(ismember({SPM.xCon.name},contrast_info.names{ix}))) '.nii']);
                    elseif find(ismember({SPM.xCon.name},contrast_info.names{ix}))>=10
                        input{counter}=fullfile(subDir(subj_num).folder,subDir(subj_num).name,['con_00' num2str(find(ismember({SPM.xCon.name},contrast_info.names{ix}))) '.nii']);
                    end
                    counter=counter+1;
                end
            end
            myInput=char(input)
        end
        
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(myInput);
        % (logical(1-[1,0,0,0,1,0,1,1,0,1,0,0,1,1,0,0,1,1,0,1,1,1,0,0]),:)
        
        % 3. Define mask
        matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);
        
        spm_jobman('run',matlabbatch)
    end
end