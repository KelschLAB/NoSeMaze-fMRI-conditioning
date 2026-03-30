%% master_GLM_residuals.m
% Jonathan Reinwald 06/2021


%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts/toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts/MRTPrediction/fMRI/GLM'))

clear all;

% define paths...
studydir='/home/jonathan.reinwald/Awake/fmri_data/'; cd(studydir);

outputdir='/home/jonathan.reinwald/Awake/stats_FirstLevel/'; % folder including firstlevel results

% define new directory for outcome ...
mask.threshold=0
dirname = ['FirstLevelResiduals__16regr_6rp_csf_FD_deriv__icaden25_16-Feb-2020__Licks__MASK_' num2str(mask.threshold)];
newdir=[outputdir filesep dirname]; % subdir in which results for current session gets saved ....
mkdir(newdir); 

% load ...
load([studydir filesep 'filelist_awake_MAIN_JR.mat'], 'Pfunc'); % filelist PREPROCESSING

%% CREATE IX_LIST /SUBJ_SESS
% matfile  -> subj_sess; becomes ix_list later (WHY?! cant remember) ...
% including ix, subject, ratnumber, measnumb
% IMPORTANT FOR SWE (subject factor)

if 1==1
    
    for ix=1:length(Pfunc);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        ix_list(ix).ix=ix;
        ix_list(ix).subj=fdir(53:56);
        ix_list(ix).ratnumber=sscanf(fdir(53:56),'PD%d');
    end
    
    
    % subject_overview:
    for i=1:length(Pfunc)              %array_valid_sessions
        subj_list{i,1}= ix_list(i).subj;
        %subj_list=subj_list(~cellfun(@isempty,subj_list));
    end
    
    subj_ov_all=unique(subj_list);
    
    for d=1:length(subj_ov_all)
        subj_cur=subj_ov_all(d);
        
        regressor_all_subjects(:,d)= contains(subj_list,subj_cur)';
        
        subj_ov_all{d,2}= find(regressor_all_subjects(:,d) ==1);
        
        subj_ov_all{d,3}= length(subj_ov_all{d,2});
    end
    
    
    for n=1:length(subj_ov_all) % = number of animals which have at least 1 valid session!
        for n2=1:length(subj_ov_all{n,2})
            ix_list(subj_ov_all{n,2}(n2)).measnum=n2;
        end
    end
    
    
    % list needs to be adapted to the behavioral performance:
    array_valid_sessions= [1:83];% NO ODOR
    %paradigm.performance_check.valid_sessions;
    ix_list_valid=ix_list(array_valid_sessions);
    
    
    subj_sess.subj_ov_all=subj_ov_all;
    subj_sess.ix_list=ix_list;
    subj_sess.ix_list_valid=ix_list_valid;
    
    %cd(outputdir); save ix_list_valid.mat ix_list_valid;
    cd(newdir); save subj_sess.mat subj_sess
    
    
    
    % regressors_valid_subjects:
    
    for i=array_valid_sessions
        subj_list_valid{i,1}= ix_list(i).subj;
        subj_list_Vdeblanked=subj_list_valid(~cellfun(@isempty,subj_list_valid));
    end
    
    % get rid of the empty cells in subj_list_valid
    for ii=1:length(Pfunc)
        if isempty(subj_list_valid{ii}) == 1
            subj_list_valid{ii} = 'invalid session';
        end
    end
    
    % get a list of all subjects with at least 1 valid session:
    subj_ov_valid=unique(subj_list_Vdeblanked);
    
    %overview valid sessions
    for d=1:length(subj_ov_valid)
        subj_cur=subj_ov_valid(d);
        
        regressor_valid_subjects(:,d)= contains(subj_list_valid,subj_cur)';
        
        subj_ov_valid{d,2}= find(regressor_valid_subjects(:,d) ==1);
        
        subj_ov_valid{d,3}= length(subj_ov_valid{d,2});
        
    end
    
    subj_sess.subj_ov_valid=subj_ov_valid;
    
    % these regressors are adapted to our Pfunclist/valid sessions. Due to the
    % fact that we are changing the order by adding the subject name to the
    % first level results directory, we need modified regressors (created in 2nd
    % level part)
    % cd(outputdir); dlmwrite(fullfile(outputdir,'regressors_valid_subjects.txt'),regressor_valid_subjects,'delimiter','\t','precision','%.6f')
    
    cd(newdir); save subj_sess.mat subj_sess
    
    
end






%%  FIRST LEVEL
% Loop over all (valid) sessions ...
% all 3 odors modeled separately -> 3 ROI for the odors ...


if 1==1
    
    % load ix_list_valid:
    cd(newdir); load subj_sess.mat
    ix_list=subj_sess.ix_list; % for nomenclature folders ...
    
    
    %MODEL SPECIFICATION:
    
    % select explicit mask ...
    cd('/home/jonathan.reinwald/Awake/atlas/Dorr_atlas/');   % atlas folder
    %explicit_mask=spm_select(1,'image','Select explicit mask!');        %
    explicit_mask='/home/jonathan.reinwald/Dorr_Atlas_Template_Renee/rDLtemplate_original_inPax_brainmask.nii';
    
    % CHOOSE ONLY SESSIONS IN WHICH ANIMALS PERFORMED WELL
    % array needs to be adapted:
    array_valid_sessions= [1:83];%paradigm.performance_check.valid_sessions;
    
    %% Switch SPM-version
    % this step is needed to use the correct SPM-version, in which the
    % residuals will not be automatically deleted
    spm12switch_residuals_JR
    
    
    %% Loop over sessions starts here ...
    
    for ix=array_valid_sessions(1:end)
        ix
        
        %% prep in loop
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        
        % make directories for first level analysis:
        % S = Subject; M = number of measurement; a = subject number
        a=num2str(ix_list(ix).ratnumber);
        if length(a) == 1; a=[num2str(0) a]; end % for nomenclature ...
        
        % maindir for this analysis ...
        newdir=[outputdir filesep dirname filesep ['PD' a '_M' num2str(ix_list(ix).measnum) '_' ...
            fname(1:11)] filesep 'rp_der']; % subdir in which results for current session gets saved ....
        
        mkdir(newdir); dircur=newdir;
        
        
        
        %% functional data:
        Pfuncall{ix}=spm_select('ExtFPlist',fdir,['^s_rwst_a1_u_del5_' fname '_c1_c2t_icaden25_16-Feb-2020.nii'],[1:2500]);
                
        %% BEHAVORIAL DATA:
        % create variables for licks and motion regressors and load them
        % into SPM batch ...
        
        %% load ...paradigm_new.mat-file:
        
        load(['/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fMRI_new_mat_sorted/' fname(1:11) '_' fdir(53:56) '_protocol_new.mat']);
                         
        %% licks
        licks=vertcat(events(:).licks_del5);


        %% motion regressors
        % nuisance regressors ...

        [fdir, fname, ext]=fileparts(Pfunc{ix});
        regressors{ix}=spm_select('FPlist',fdir,['^regressors_motcsf_der.txt']);
        
        parameters=spm_load(regressors{ix});
        [FD] = SNiP_framewise_displacement(parameters(:,1:6));
        FD_deriv=[0; diff(FD)];
        dlmwrite(fullfile(fdir,'regressors_motcsfFD_der.txt'),[parameters(:,1:7),FD,parameters(:,8:14),FD_deriv],'delimiter','\t','precision','%.6f');
        regressors_new{ix}=spm_select('FPlist',fdir,['^regressors_motcsfFD_der.txt']);
        numberREG=size(spm_load(regressors_new{ix}),2);
        
        %% SPM ... let's getting started!
        if ix==1;
            spm fmri;
            addpath /home/jonathan.reinwald/matlab/HRF;
            %HRF: derivative and dispersion
            DerDisp=[0 0];
        end;
        
        %% DO FIRST LEVEL ANALYSIS !
        % Depending on your idea either choose:
        % do_first_level_residuals_JR --> include licks
        % do_first_level_residuals_JR_no_licks --> no licks included
        if 1 == 1

            % do_first_level_residuals_JR(Pfuncall{ix},licks,regressors{ix},explicit_mask,dircur,DerDisp)
            do_first_level_residuals_JR(Pfuncall{ix},licks,regressors_new{ix},explicit_mask,dircur,DerDisp,mask.threshold)
            
        end
    end;
end;
        
%% Merge residuals:
MergeNiftis_JR

