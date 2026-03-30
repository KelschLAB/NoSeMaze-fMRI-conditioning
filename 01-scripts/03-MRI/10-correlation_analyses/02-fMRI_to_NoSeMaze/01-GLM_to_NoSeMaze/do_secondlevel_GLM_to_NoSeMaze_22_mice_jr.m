function do_secondlevel_GLM_to_NoSeMaze_22_mice_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar)

%% Loop over contrasts
for ix = 1:length(contrast_info.names)
    % clearing
    clear matlabbatch input
    
    % load predefined job
    job_secondlevel_GLM_to_NoSeMaze_jr
    
    % 1. define output directory for secondlevel
    outputdir = [outputDir_secondlevel filesep contrast_info.names{ix}];
    if ~exist(outputdir)
        mkdir(outputdir);
        matlabbatch{1}.spm.stats.factorial_design.dir = {(outputdir)};
        
        % 2. Define input files
        if contrast_info.test{ix} == 'fcon';
            input = spm_select('ExtFPListRec',firstlevelDir,['ess_000' num2str(ix)],1);
        elseif contrast_info.test{ix} == 'tcon' & ix<10;
            input = spm_select('ExtFPListRec',firstlevelDir,['con_000' num2str(ix)],1)
        elseif contrast_info.test{ix} == 'tcon' & ix>=10;
            input = spm_select('ExtFPListRec',firstlevelDir,['con_00' num2str(ix)],1)
        end
        
        % exclude ZI_M23 and ZI_M33
        input=input([1:9,11:17,19:end],:);
        
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = cellstr(input);
        
        % 3. Define mask
        matlabbatch{1}.spm.stats.factorial_design.masking.em = cellstr(explicit_mask);
        
        % 4. Define explanatory variable input
        % Sort in ascending order using the animal number
        [B,Idx]=sort([ExplVar.AnimalNumb],'ascend');
        input_table = table(B,[ExplVar.values(Idx)],'VariableNames',{'No.',ExplVar.name});
        % put in control
        for i = 1:size(input,1)
            str_ = strfind(input(i,:),'ZI_M');
            con_numb(i,1) = str2num(input(i,(str_+4:str_+5)));
        end
        if length(con_numb)~=length(ExplVar(1).AnimalNumb)
            disp('!!! WARNING !!! - The number of animals differ in explanatory variable and SPM input files!');
            disp('!!! WARNING !!! - The size of the explanatory variable is reduced to the size of the SPM input files.');
            
            myFieldnames = fieldnames(ExplVar);
            for fnIdx = 1:length(myFieldnames)
                if ~contains(myFieldnames{fnIdx},'name')
                    ExplVar.(myFieldnames{fnIdx})=ExplVar.(myFieldnames{fnIdx})(ismember(ExplVar.AnimalNumb,con_numb));
                end
            end
            % redo the sorting
            [B,Idx]=sort([ExplVar.AnimalNumb],'ascend');
            input_table = table(B,[ExplVar.values(Idx)],'VariableNames',{'No.','DavidsScore'});
        end
        %
        
        % Define input
        matlabbatch{1}.spm.stats.factorial_design.cov.c = [ExplVar.values(Idx)];
        matlabbatch{1}.spm.stats.factorial_design.cov.cname = ExplVar.name;
        matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1; % Interaction: 2 = with Factor 1
        matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1; % Meaning: 2 = with Factor 1
        matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
        
        % 5. Contrast definition
        numbVar = length(ExplVar)+1;
        counter=1;
        for jx=1:numbVar
            % positive (+) contrast
            matlabbatch{3}.spm.stats.con.spmmat(counter) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
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
            matlabbatch{3}.spm.stats.con.spmmat(counter) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
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
end