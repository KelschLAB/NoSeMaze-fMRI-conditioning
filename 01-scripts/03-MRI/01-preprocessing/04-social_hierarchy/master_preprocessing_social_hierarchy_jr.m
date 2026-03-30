%% master_preprocessing_social_hierarchy_jr.m
% PREPROCESSING MOUSE DATA, PARAVISION 6 DIR-STRUCTURE

% Jonathan Reinwald 11/2020
% Main preprocessing script for fMRI data (EPIs and 3Ds) including:
% - path definition
% - pv-conversion
% - reading scanlist/filelist creation
% - deletion of dummies
% - afni desiking
% - 3D brain extraction
% - fieldmap correction
% - realignment and unwarping
% - motiondiagnosis
% - slice-time correction
% - coreg. Func to 3D, then template
% - bias correction and normalization
% - smoothing

%% CAVE: Add scripts to path specifically, if possible ! (e.g., several issues with MarsBar)

%% set MATLAB-path for script-folders and -subfolders
clear all
close all
clc

addpath(genpath('/home/jonathan.reinwald/MATLAB_jr'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))

%% ------------------ Predefinition of pathes ----------------------------%

% Predefine main working directory
rawdir='/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/03-MRI/03-social_hierarchy/01-fMRI_data';
procdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing';
cd(procdir)

% Predefine path of scanlist
scans='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/scanlist_social_hierarchy_jr.csv';%path of scan list as a csv

% Predefine path for mouse brain atlas (3D and mask)
Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brainmask_rs1x1x1_polish.nii';

%% ------------------ Converting of original files -----------------------%
if 1==0
    % Reading of csv-file
    [subj_long,subj_ID,subj_name,study,examn,series,image_comm]=textread(scans,'%s %s %u %s %s %u %s','delimiter',',','headerlines',1); % type
    
    % Gives you the unique animal-names (ZI_M...) based on the csv-file
    [regu,IA,IC]=unique(subj_ID);
    % Gives you the corresponding animal-number (PD..)
    subu=subj_name(IA);
end
% % CAVE: first unzip files
% % Unzipping will create folders named PDXX_NAME_...._PvDatasets_FILES, in
% % which the folder ZI_M... contains the files we're interested
% if 1==0
%     for ix=1:size(regu,1)
%         % find and copy folder in PD.._ZI_M_...._PvDatasets_FILES and
%         % copies it to the rawData folder
%         syscmd=['find ' studydir filesep 'rawData -type d -name ' regu{ix} '*' ' -exec cp -r ''{}'' ' studydir filesep 'rawData' ' \;'];
%         system(syscmd)
%     end
% end

% Conversion of files using pvconv
if 1==0
    % set path for pvconv
    addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/01-toolboxes/postproc_v1.0_r987'))
    for ix=1:size(regu,1)
        % makes dir with ZI_M.._PD.. in studydir
        syscmd=['mkdir ' procdir filesep regu{ix}];
        system(syscmd);
        % real conversion of the data-files to niftis(.nii)/matfiles(.mat)/brukerheader(.brkhdr) in the dir we created the step before
        do_pvconv_jr([rawdir filesep],[procdir filesep regu{ix}], regu{ix})       % pvconv will create SPM compatible files (.mat, .brkhdr, .nii ...); lw
    end
end

%% ------------------ 3D, FM, EPI READING FROM SCAN list -----------------%

% replace subsequent lines that are absolute identical by double
if 1==0
    for ix=1:(size(subj_ID,1)-1);
        if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+1))));
            examn{ix+1}='double';
            if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+2))));
                examn{ix+2}='triple';
                if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+3))));
                    examn{ix+3}='quadruple';
                end
            end
        end
    end
end

if 1==0
    path_all=spm_select('ExtFPListRec', procdir, '^ZI.*reorient.nii');
    path_all=cellstr(path_all);
    
    for jscan=1:size(subj_ID,1)                                                                           % strcmp -> contains; 171216; strcmp for EPIs due to EPI tests in the scan list
        episcan_social_hierarchy(jscan)=strcmp(deblank(char(examn(jscan))),'EPI_social_hierarchy');                                % strcmp goes through examination column, each cell with input 'EPI 1300' gets the logical 1% strcmp goes through examination column, each cell with input 'EPI 1300' gets the logical 1
        scan3d_1(jscan)=contains(deblank(char(examn(jscan))),'TurboRARE3D_1');
        scan3d_2(jscan)=contains(deblank(char(examn(jscan))),'TurboRARE3D_2');
        fmapscan_1(jscan)=strcmp(deblank(char(examn(jscan))),'Fieldmap_1');
        fmapscan_2(jscan)=strcmp(deblank(char(examn(jscan))),'Fieldmap_2');
    end
    
    epiind=find(episcan_social_hierarchy);                                                                               % returns a vector containing the linear indices of each nonzero element in array episcan; lw
    for jepi=1:numel(epiind)
        indc=regexp(path_all,[char(subj_ID(epiind(jepi))),'.*/', num2str(series(epiind(jepi))),'/']);
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                Pfunc_social_hierarchy(jepi)=path_all(jscan);                                                            %Pfunc contains the pathes of the EPIs; lw
            end
        end
    end
    
    
    ind3d=find(scan3d_1);
    for j3d=1:numel(ind3d)
        indc=regexp(path_all,[char(subj_ID(ind3d(j3d))),'.*/', num2str(series(ind3d(j3d))),'/']);
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                P3d_1(j3d)=path_all(jscan);
            end
        end
    end
    
    ind3d=find(scan3d_2);
    for j3d=1:numel(ind3d)
        indc=regexp(path_all,[char(subj_ID(ind3d(j3d))),'.*/', num2str(series(ind3d(j3d))),'/']);
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                P3d_2(j3d)=path_all(jscan);
            end
        end
    end
    
    fmapind=find(fmapscan_1);
    for jmap=1:numel(fmapind)
        indc=regexp(path_all,[char(subj_ID(fmapind(jmap))),'.*/', num2str(series(fmapind(jmap))),'/Z']);  %%% CAVE: Z is added to not find the file in the folder p2
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                [path, file, ext]=fileparts(char(path_all(jscan)));
                Pdmap_1{jmap}=path; %Pmap{jmap}=path_all(jscan);
            end
        end
    end
    
    fmapind=find(fmapscan_2);
    for jmap=1:numel(fmapind)
        indc=regexp(path_all,[char(subj_ID(fmapind(jmap))),'.*/', num2str(series(fmapind(jmap))),'/Z']);  %%% CAVE: Z is added to not find the file in the folder p2
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                [path, file, ext]=fileparts(char(path_all(jscan)));
                Pdmap_2{jmap}=path; %Pmap{jmap}=path_all(jscan);
            end
        end
    end
    
    for jphy=1:length(Pfunc_social_hierarchy);
        [fpath,~,~]=fileparts(Pfunc_social_hierarchy{jphy});
        [fpath,fname,~]=fileparts(fpath);
        if length(fname)==1
            Pphysio_social_hierarchy(jphy,:)=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/04-physio/' num2str(fpath(end-1:end)) '-#0' num2str(fname) '.txt'];            
        elseif length(fname)==2
            Pphysio_social_hierarchy(jphy,:)=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/04-physio/' num2str(fpath(end-1:end)) '-#' num2str(fname) '.txt'];
        end
    end
    
    save('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat','P3d_1','Pdmap_1','Pdmap_2','P3d_2','Pfunc_social_hierarchy','Pphysio_social_hierarchy')
    
end

%% -------------------- Load filelist ------------------------------------%
%
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')
end

%% -------------------- Check Scans for matching position ----------------%
% if scans are not in the same position, e.g. because between EPI and 3D
% the animal was moved, use coregister (estimate) to get them into the same
% position CAVE: be sure to do this for all ... EPI volumes

if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2);
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^ZI_.*._reorient.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fpath,['^ZI_.*._reorient.nii'],400);
        fdir=Pdmap_1{ix};
        Pfdm_1=spm_select('ExtFPList',fdir,['^ZI_.*.acq0_reorient.nii'],1);
        fdir=Pdmap_2{ix};
        Pfdm_2=spm_select('ExtFPList',fdir,['^ZI_.*.acq0_reorient.nii'],1);
        char_all=char([Pfunc_cur;Pfunc_cur1;P3d_1(ix);P3d_2(ix);Pfdm_1;Pfdm_2]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% --------------- Delete first scans (not enough dummies) ---------------%

% Objective: Deletion of first scans (if necessary) since scanner needs
% time to reach equilibrium.
if 1==0
    Pfunc = Pfunc_social_hierarchy;
    % Show mean tc without deletion to judge quality
    if 1==0
        syscmd=['mkdir data_cor_hist'];
        system(syscmd);
        cd('data_cor_hist')%lw
        for ix=1:size(Pfunc,2);
            wwf_voxcor_lw(Pfunc{ix},'cor_hist',1.2); % TR = 1.3;
        end
        cd(procdir)
    end
    
    % Deletion of first 5 scans:
    if 1==0
        for ix=1:size(Pfunc,2);
            Pcur=deblank(Pfunc{ix});
            [fdir, fname, ext]=fileparts(Pcur);
            Pdo=spm_select('ExtFPList',fdir,['^' fname '.nii'],1);
            wwf_del_vol(Pdo,5);
        end
    end
    
    % Show corrected mean tc after deletion of dummies
    if 1==0
        syscmd=['mkdir data_cor_hist_del5'];
        system(syscmd);
        cd('data_cor_hist_del5')%lw
        
        for ix=1:size(Pfunc,2);
            [fdir, fname, ext]=fileparts(Pfunc{ix});
            Pcur=[fdir filesep 'del5_' fname ext];
            wwf_voxcor_lw(Pcur,'cor_hist_del5',1.2);
        end
        cd(procdir)
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d_2,2);
        [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^del5_' fname '.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fdir,['^del5_' fname '.nii'],str2num(Pfunc_social_hierarchy{ix}(end-3:end))-5);
        char_all=char([P3d_2(ix);Pfunc_cur;Pfunc_cur1]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------------------- AFNI despiking ------------------------------%
if 1==0
    for ix=1:length(Pfunc_social_hierarchy)
        % Application on reappraisal data
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('FpList', fpath , ['^del5_' fname '.nii']);
        Poutput=fullfile(fpath,['despiked_del5_' fname '.nii']);
        sysprompt=(['3dDespike -nomask -prefix ' Poutput ' ' Pcur]);
        system(sysprompt)
    end
end

%% ------------------------ Fieldmap Correction --------------------------%
%-------------------- Fieldmap "Filling" and "Masking" -------------------%
% - fieldmap_2 is used
% - preparation of the FM including dilation and filling of empty voxels
if 1==0
    for ix=1:size(Pdmap_1,2)
        % Creation of fpm_.._acq0_reorient_spm2.img
        wwf_FieldMap_rat_jr(Pdmap_1{ix});
        % Dilatation of fieldmap and filling of empty voxels in the edges of the fieldmap
        fdir=Pdmap_1{ix};
        clear Pfm
        Pfm=spm_select('FPList',fdir,['^fpm_ZI.*._acq0_reorient_spm2.img']);
        fieldmap_fill_dilate_jr(Pfm);
        clear Pfm
    end
end

% first application of fieldmap (only on first image) to create u-file
if 1==0
    addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/01-preprocessing/01-general/fieldmap'));
    spm fmri
    for ix=1:size(Pdmap_1,2)
        % Application on social_hierarchy data
        [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        wwf_appl_fieldmap(Pdmap_1{ix},Pfunc_cur,P3d_2{ix});      
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d_2,2);
        [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fdir,['^udespiked_del5_' fname '.nii'],1);
        Pfunc_cur2=spm_select('ExtFPList',fdir,['^udel5_' fname '.nii'],1);
        char_all=char([P3d_2(ix);Pfunc_cur;Pfunc_cur1;Pfunc_cur2]);
        spm_check_registration(char_all)
        input('weiter');
    end
end


%% --------------------- Realignment and Unwarping -----------------------%
% Registration to first image was recommended by Wolfgang:
% Control before running in do_unwarp_jr:
% 1. Select your preferred PB0map (vdm-map), e.g. ^vdm5_full_fpm_Z.*_spm2.img'
% 2. Choose registration to first or mean
% (matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm; 0=first; 1=mean).

if 1==0
    spm fmri
    for ix=1:size(Pdmap_1,2)
        % social_hierarchy
        Pcur=deblank(Pfunc_social_hierarchy{ix});
        [fdir, fname, ext]=fileparts(Pcur);
        Pfunc_cur=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        do_unwarp_jr(char(Pdmap_1(ix)),Pfunc_cur);
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d_2,2);
        Pdmap5=spm_select('ExtFPList',Pdmap_1{ix},['^vdm5_full_fpm_Z.*_spm2.img'],1);
        [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^u_despiked_del5__' fname '.nii'],1);
        Pfunc_cur3=spm_select('ExtFPList',fdir,['^u_despiked_del5_' fname '.nii'],str2num(Pfunc_social_hierarchy{ix}(end-3:end))-10);
        Pfunc_cur4=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        Pfunc_cur5=spm_select('ExtFPList',fdir,['^' fname '.nii'],str2num(Pfunc_social_hierarchy{ix}(end-3:end))-10);
        Pfunc_cur6=spm_select('ExtFPList',fdir,['^' fname '.nii'],1);
        char_all=char([P3d_2(ix);Pfunc_cur;Pfunc_cur3;Pfunc_cur4;Pfunc_cur5;Pfunc_cur6;Pdmap5]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------------------ Checking of physio data ------------------------%
if 1==0
    mkdir(procdir,'physiodiagnosis')
    cd([procdir filesep 'physiodiagnosis'])
    for ix=1:size(Pfunc_social_hierarchy,2)    
        ndel_dummies=5;
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pinput=spm_select('FPList',fpath, ['^u_despiked_del5_.*' fname  '.nii']);
        cc_check_physio_dummy(Pinput,Pphysio_social_hierarchy(ix,:),ndel_dummies)
    end
end

%% --------------------- AZTEC (Preparation and Run) ----------------------
%------------------- loading the filter file ------------------------------
% First run with std_filt and readout the borders for cardiac and
% respiration data from the figures.

% std_filt= [3 14 9 15];
% rsfilt = load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/physiodiagnosis/rs_filt_social_hierarchy.txt')

%--------------------------- physio script --------------------------------
if 1==0
    cd([procdir filesep 'physiodiagnosis'])
    for ix=1:length(Pfunc_social_hierarchy);
        filter=std_filt
%         filtnum=find(rsfilt(:,1)==ix);
%         if ~isempty(filtnum)
%             filter=rsfilt(filtnum,2:end);
%         else
%             filter=std_filt;
%         end
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pinput=spm_select('FPList',fpath, ['^u_despiked_del5_.*' fname  '.nii']);
        [fpath, fname, ext]=fileparts(deblank(Pphysio_social_hierarchy(ix,:)));
        Pphysio_input=fullfile(fpath,[fname '_rep' ext]);
        do_script_physio(Pphysio_input,Pinput,filter)
    end
end

if 1==0
    cd([procdir filesep 'physiodiagnosis'])
    rb_print_physio_ffts_jr(Pfunc_social_hierarchy,Pphysio_social_hierarchy,'physio_overview_repaired')
end

%------------------------------- AZTEC -----------------------------------%
if 1==0
    for ix=1:length(Pfunc_social_hierarchy);
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPList',fpath,['^u_del5.*' fname  '.nii'],1);
        do_aztec_awake_jr(Pcur);
    end
end


%% ---------------- Preliminary Motiondiagnosis ------------------------- %
threshold=0.05;
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2);
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        rp=spm_load(spm_select('FPList',fpath,'^rp_despiked_del5_.*')) ;
        % detrending
        for i=1:size(rp,2)
            [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
            tr=polyval(p,1:size(rp,1),[],mu);
            rp(:,i)=rp(:,i)-tr';
        end
        [FD] = SNiP_framewise_displacement(rp);
        figure;
        plot([(FD)]);hold on; plot(repmat(mean(FD),size(FD)),'-k');
        xlimv=get(gca,'xlim');
        plot(repmat(threshold,size(FD)),'--k'),xlim(xlimv),ylim([0 3]);
        plot(repmat(0.05,size(FD)),'--k');
        set(gca,'ytick',([min(ylim):0.5:max(ylim)]),'fontsize',6);
        ylabel('FD (mm)');
        mkdir(fullfile([procdir filesep 'motiondiagnosis']))
        print('-dpsc',fullfile([procdir filesep 'motiondiagnosis'],'FWD.ps') ,'-r400','-append')
        close(figure(10));
        FD_mean(ix)=mean(FD);
    end
end

%% ---------------------- Slice-time correction ------------------------- %
if 1==0

    for ix=1:size(Pfunc_social_hierarchy,2);
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPList',fpath,['^u_despiked_del5.*' fname  '.nii'],1);
        do_slice_time_reappraisal_jr(Pcur);
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d_2,2);
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^a1_u_despiked_del5.*' fname  '.nii'],str2num(Pfunc_social_hierarchy{ix}(end-3:end))-5);
        Pfdm=spm_select('ExtFPList',Pdmap_1{ix},['^ZI_.*.acq0_reorient_c2.nii'],1);
        char_all=char([Pfunc_cur;Pfunc_social_hierarchy(ix);P3d_2(ix);Pfdm]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ----------------- Coregistration of Func to 3D ------------------------%
% E.g. if func and 3d are not completely in the same position (which is
% quite often the case in this dataset), this coregistration will help
% bringing them to the same position using NMI
if 1==0
    for ix=1:size(P3d_2,2);
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^a1_u_despiked_del5.*' fname  '.nii'],1);
        
        do_coreg_func23d_lw(P3d_2{ix},Pfunc_cur)
    end
end

% Rename and Resave coregistered files, as I am doing a manual correction
% after that.
if 1==0
    for ix=1:size(Pdmap,2);
        Pcur=deblank(Pfunc{ix});
        [fdir, fname, ext]=fileparts(Pcur);
        cd(fdir);
        Pcur1=(['a_u_del5_' fname '_c1.nii']);
        Pcur2=(['orig_a_u_del5_' fname '_c1.nii']);
        syscmd=['cp ' Pcur1 ' ' Pcur2 ];
        system(syscmd)
    end
end

% Manual correction can be done in here.
if 1==0;
    for ix=1:size(Pfunc_social_hierarchy,2);
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_old=spm_select('ExtFPList',fpath,['^a1_u_del5_.*' fname  '.nii'],1);
        Pfunc_cur=spm_select('ExtFPList',fpath,['^a1_u_del5_.*' fname  '_c1.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fpath,['^a1_u_del5_.*' fname  '_c1.nii'],str2num(Pfunc_social_hierarchy{ix}(end-3:end))-5);
        char_all=char([Pfunc_cur;P3d_2(ix);Pfunc_old;Pfunc_cur1]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ----------------------- 3D Brain Extraction -------------------------- %
if 1==0
    for ix=1:size(P3d_2,2)
        Pcur=deblank(P3d_2{ix});
        [fdir fname ext]=fileparts(Pcur);
        Pex=spm_select('FPList',fdir,['^' fname '.nii']);
        ms_PCNN3D_v2(Pex,[350, 600]*1000);
    end
end

% Visual control and correction by choosing a more accurate iteration use ms_gui_checkBrainMasks.m
if 1==0
    ms_gui_checkBrainMasks
end

%% --------------- Shifting of 3D and Func onto the template ------------ %
% Shift image to make coregistration (to temp) work (needs overlap).
% Brain extracted 3d is used in do_shift_auto_brain.
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2);
        [fpath fname1 ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('FPlist',fpath,['^a1_u_despiked_del5_' fname1 '_c1.nii']);
        [fpath fname2 ext]=fileparts(P3d_2{ix});
        P3dcur=spm_select('FPlist',fpath,['^' fname2 '.nii$']);
        Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';       
        do_shift_auto_brain_jr_lw(P3dcur,Pcur,Ptemp);
    end
end

% Visual control:
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d_2,2);
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^st_' fname '_brain.nii'],1); %prefix depends on norm!
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_coreg=spm_select('ExtFPList',fpath,['st_a1_u_despiked_del5_' fname '_c1.nii'],1); %prefix depends on norm!
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(Pfunc_coreg)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------ Coregistration of 3D and Func data to template ---------- %
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2)
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^st_a1_u_despiked_del5_' fname '_c1.nii'],1);
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        P3dcur=spm_select('ExtFPlist',fpath,['^st_' fname '_brain.nii']);
        P3d_whole_cur=spm_select('FPlist',fpath,['^st_' fname '.nii']);
        Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
        
        do_coreg_all2temp_pain_lw(P3dcur,P3d_whole_cur,Pcur,Ptemp)
    end
end

% Visual Control
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d_2,2);
        
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^st_' fname '_brain_c2t.nii'],1); %prefix depends on norm!
        
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_coreg=spm_select('ExtFPList',fpath,['^st_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1); %prefix depends on norm!
        
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_coreg1=spm_select('ExtFPList',fpath,['^st_a1_u_despiked_del5_' fname '_c1.nii'],1); %prefix depends on norm!
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(Pfunc_coreg);cellstr(Pfunc_coreg1)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------------------ Bias Correction of 3D ----------------------- %

if 1==0
    for ix=1:size(P3d_2,2);
        [fdir fname ext]=fileparts(P3d_2{ix});
        Porig=spm_select('FPList',fdir,['^st_' fname '_c2t.nii']);
        Pex=spm_select('FPList',fdir,['^st_' fname '_brain_c2t.nii']);
        wwf_do_bias_jr(Pex,Porig);
    end
end

%% ---------------- Segmentation to create new template -------------------%
if 1==0
    templates={
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sGM_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sWM_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sCSF_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sBackground_template_markus_msk.nii'
        };
    for ix=1:size(P3d_2,2)
        [fpath fname ext]=fileparts(P3d_2{ix});
        Pcur=spm_select('ExtFPList',fpath,['^bc_st_' fname '_c2t.nii'],1);
        jr_do_segmentation(Pcur,templates);
    end
end

%% ---------------- DARTEL - initial import -------------------------------%
% reslicing of the c1bc_*_c1.nii; c2bc_*_c1.nii; c3bc_*_c1.nii;
% input: bc_.*._c1_seg_sn.mat
% output: in defined folder --> rc1bc_*_c1.nii; rc2bc_*_c1.nii; rc3bc_*_c1.nii;

% create input Pcur list and Pdir
if 1==0
    clear Pcur
    for ix=[1:size(P3d_2,2)]
        [fpath fname ext]=fileparts(P3d_2{ix});
        Pcur{ix}=spm_select('FPList',fpath,['^bc_st_' fname '_c2t_seg_sn.mat']);
    end
end

Pdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/';
if 1==0
    [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{1});
    P=spm_select('FPlist',fpath,['^st_a1_u_del5_' fname '_c1_c2t.nii']);
    V=spm_vol(P);
    [BB,vx] = spm_get_bbox(V);
    vox=2.65625
    jr_do_DARTEL_inital_import(Pcur,Pdir,vox)
end

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d_2,2);
        [fpath fname ext]=fileparts(P3d_2{ix});
        Pfdm=spm_select('ExtFPList',fpath,['^c1bc_st_.*_c2t.nii'],1);
        Pfdm1=spm_select('ExtFPList',fpath,['^bc_st_.*_c2t.nii'],1);
        Pfdm2=spm_select('FPList','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/',['^rc1bc_st_.*_c2t.nii']);
        char_all=char([cellstr(Pfdm);cellstr(Pfdm2);cellstr(Ptemp);'/home/jonathan.reinwald/Output/2016_12_TTA/Oatp1c1_Mct8_dko/VBM/VBM_templates_markus/sGM_template_markus_inPax_msk_norm.nii']);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- Reslice of EPI to in-plane voxel size -----------------%
if 1==0
    for ix=1:length(Pfunc_social_hierarchy)
        %% Pfunc social_hierarchy
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^st_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1:16000);
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        % Important: This is a reference image which was later created by
        % jr_do_DARTEL_inital_import.m with isotropic voxel-size
        Pref=spm_select('ExtFPlist','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/',['^rc1bc_st_' fname '_c2t.nii'],1);
        Pinput=[cellstr(Pref);cellstr(Pcur)]
        do_reslice(Pinput,4);
    end
end

%% --------------- DARTEL - Run DARTEL (create Templates)------------------%
% create templates as a mean of all input files and the u_* files with the
% information about warping
% input: all rc1coreg_st5_*.nii and all rc2coreg_st5_*.nii;
% output: in Pwdir u_rc1coreg_st5_*.ni, template_1.nii to template_6.nii;

if 1==0
    clear Pcur1 Pcur2
    Pwdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/';
    Pcur1=spm_select('ExtFPList',Pwdir,['^rc1bc_st_.*_c2t.nii'],1);
    Pcur2=spm_select('ExtFPList',Pwdir,['^rc2bc_st_.*_c2t.nii'],1);
    jr_do_DARTEL_create_templates(Pcur1,Pcur2);
end

%% --------------- DARTEL - Normalize to MNI (3D) ------------------------%
% Idea: normalization of our template_6.nii to atlas template and warping
% of our inputs using the information from the flowfields (corresponding to
% the old warping)
% CAVE: spm_dartel_norm_fun_***_jr uses our template information --> be sure to
% have the correct one (rat/mouse)

% Output:
% modulated: smwc1bc_.*._c1.nii, smwc2bc_.*._c1.nii, smwc3bc_.*._c1.nii
% only warped: swc1bc_.*._c1.nii, swc2bc_.*._c1.nii, swc3bc_.*._c1.nii

if 1==1
    for ix = 1:length(P3d_2);
        clear job
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        job.template = {'/zi-flstorage/data/jonathan/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/zi-flstorage/data/jonathan/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '_c2t_Template.nii'])};
        fpath(strfind(fpath,'/home/jonathan.reinwald'):length('/home/jonathan.reinwald'))=[];
        fpath=['/zi-flstorage/data/jonathan',fpath];
        job.data.subj.images = {
            spm_select('FPlist',fpath,['^mbc_st_' fname '_c2t.nii'])...
            };
        job.vox = [NaN NaN NaN];
        job.bb = [NaN NaN NaN; NaN NaN NaN];
        job.fwhm = [3 3 3];
        for jx=[0,1];
            job.preserve = jx;
            spm_dartel_norm_fun_mice_jr(job);
        end;
    end
end

if 1==0
    for ix = 1:length(P3d_2);
        clear job
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        job.template = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '_c2t_Template.nii'])};
        job.data.subj.images = {
            spm_select('FPlist',fpath,['^c1bc_st_' fname '_c2t.nii'])...
            spm_select('FPlist',fpath,['^c2bc_st_' fname '_c2t.nii'])...
            spm_select('FPlist',fpath,['^c3bc_st_' fname '_c2t.nii'])...
            };
        job.vox = [NaN NaN NaN];
        job.bb = [NaN NaN NaN; NaN NaN NaN];
        job.fwhm = [0 0 0];
        for jx=[0,1];
            job.preserve = jx;
            spm_dartel_norm_fun_mice_jr(job);
        end
    end
end

%% -------------- DARTEL - Normalize to MNI (EPI) ----------------------- %
% Idea: normalization of our template_6.nii to atlas template and warping
% of our inputs using the information from the flowfields (corresponding to
% the old warping)
% CAVE: spm_dartel_norm_fun_***_jr uses our template information --> be sure to
% have the correct one (rat/mouse)

% Output:
% modulated: smwc1bc_.*._c1.nii, smwc2bc_.*._c1.nii, smwc3bc_.*._c1.nii
% only warped: swc1bc_.*._c1.nii, swc2bc_.*._c1.nii, swc3bc_.*._c1.nii

if 1==0
    for ix =1:length(Pfunc_social_hierarchy);
        clear job
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        job.template = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '_c2t_Template.nii'])};
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        clear input_images
        input_images = {...
            spm_select('FPlist',fpath,['^rst_a1_u_despiked_del5_' fname '_c1_c2t.nii']);...
            };
        P=spm_select('FPlist',fpath,['^rst_a1_u_despiked_del5_' fname '_c1_c2t.nii']);...
            V=spm_vol(P);
        [BB,vx] = spm_get_bbox(V);
        
        job.data.subj.images = cellstr(input_images{1});
        job.vox = [NaN NaN NaN];
        job.bb = BB;
        job.fwhm = [0 0 0];
        job.preserve = 0;
        spm_dartel_norm_fun_mice_jr(job);
    end
end

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:length(Pfunc_social_hierarchy);
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc1=spm_select('ExtFPlist',fpath,['^rst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1);
        Pfunc2=spm_select('ExtFPlist',fpath,['^st_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1);
        Pfunc3=spm_select('ExtFPlist',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1);
        [fpath fname ext]=fileparts(P3d_2{ix});
        P3d_cur = spm_select('FPlist',fpath,['^smwc1bc_st_' fname '_c2t.nii'])        
        char_all=strvcat(Pfunc1,Pfunc2,Pfunc3,P3d_cur,Ptemp);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% OPTIONAL: CSF filtering and Regression of realignment parameters ----- %
% CSF filtering and regression of realign parameters, depending on the
% selection also with global signal regression or derivatives of the
% realignment parameters
% Prefix: regfilt_
% Regression of realignment parameters/CSF/derivatives...
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2)
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('FPlist',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii$']);
        [fpath, fname, ext]=fileparts(P3d_2{ix});
        P3d_csf=spm_select('FPlist',fpath,['^wc3bc_st_' fname '_c2t.nii$']);
        P_GM_mask=spm_select('FPlist',fpath,['^wc1bc_st_' fname '_c2t.nii$']);
        qmcsf=0.9;
        execution=0;
        acl_regfilt_motcsf_awake_despiked_jr(Pfunc_cur,P3d_csf,P_GM_mask,Pmask,qmcsf,execution);
    end
end

%% ---------------- Motion assessment: 2nd realignment ------------------ %

if 1==0
    for ix=1:length(Pfunc_social_hierarchy);
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunc_cur=spm_select('FPlist',fpath,['^wst_a1_u_del5_' fname '_c1_c2t.nii$']);
        do_realign_est(Pfunc_cur);
    end
end

%% ---------------------- Motion Regressors ----------------------------- %
% creates a multiple regressor including standard rps, its derivatives,
% shifted derivatives -2, -1, +1 (for first level)

if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2)
        %% Social Hierarchy
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        rp=spm_load(spm_select('FPlist',fpath,'^rp_del5.*.txt'));
        rp_diff=[zeros(1,size(rp,2)); diff(rp)];
        rp_diff_minus2=[rp_diff([3:(str2num(Pfunc_social_hierarchy{ix}(end-3:end))-5)],:); zeros(2,size(rp_diff,2))];
        rp_diff_minus1=[rp_diff([2:(str2num(Pfunc_social_hierarchy{ix}(end-3:end))-5)],:); zeros(1,size(rp_diff,2))];
        rp_diff_plus1=[zeros(1,size(rp_diff,2));rp_diff([1:(str2num(Pfunc_social_hierarchy{ix}(end-3:end))-6)],:)];
        regressors_mot_der_shiftder_m2m1p1=[rp rp_diff rp_diff_minus2 rp_diff_minus1 rp_diff_plus1];
        dlmwrite(fullfile(fpath,strcat('regressors_mot_der_shiftder_m2m1p1.txt')),regressors_mot_der_shiftder_m2m1p1,'delimiter','\t','precision','%.6f')
    end
end

%% ------------ Create mask of DARTEL templates ------------------------- %
if 1==0
    P_template='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/Template_6.nii';
    master_create_mask_of_DARTELtemplate(P_template);
end

%% ------------ Motiondiagnosis Alex: DVARS and plots ------------------- %
if 1==0
    motiondir=[procdir filesep 'motiondiagnosis'];
    mkdir(motiondir);
    
    for ix=1:size(Pfunc_social_hierarchy,2);
        %% social_hierarchy
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        EPI=spm_select('ExtFPlist',fpath,['^wrst_a1_u_del5_' fname '_c1_c2t.nii']);
        thres=0.10;
        mask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/mask_template_6_polished.nii';
        outputdir=motiondir;
        acl_motiondiagnosis_jr_lw(EPI,thres,mask,outputdir,fname);
    end
end

%% --------- Smoothing (without band-pass filtering afterwards) ----------%
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2)
        %% social_hierarchy
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii$'],1);
        fwhm_cur=[6 6 12];
        do_smooth_lw(Pcur,fwhm_cur);
    end
end

%% --------- Smoothing (without band-pass filtering afterwards) ----------%
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2)
        %% social_defeat
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii$'],1);
        fwhm_cur=[6 6 6];
        do_smooth_lw(Pcur,fwhm_cur);
    end
end

%% ---------------------- Visual Check ---------------------------------- %
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d_1,2);
        
        [fpath, fname, ext]=fileparts(P3d_1{ix});
        P3d_norm=spm_select('ExtFPlist',fpath,['^wbc_st_' fname '_brain_c2t.nii'],1);
        
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_norm=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1);
        
        Pfunc_smooth=spm_select('ExtFPList',fpath,['^s6_wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1);
        
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_norm);cellstr(Pfunc_norm); cellstr(Pfunc_smooth)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end



%% -------------------- Wavelet Despiking ---------------------------------
%% -------------------- WD1: masking of EPIs ------------------------------
% Create folder for every animal and copy file to respective folder
if 1==1
%     Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/mask_template_6.nii';
    Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    Vmask=spm_vol(Pmask);
    mask=spm_read_vols(Vmask);
    
    mask(isnan(mask))=0;
    for ix=1:size(Pfunc_social_hierarchy,2)
        %% Social Defeat
        if 1==1
            Pcur=deblank(Pfunc_social_hierarchy{ix});
            [fpath, fname, ext]=fileparts(Pcur);
            P=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],[1:3000]);
            nimg=size(P,1);
            Vi=spm_vol(P);
            img_mtx=spm_read_vols(Vi);
            Vnew=Vi;
            for jx=1:nimg
                Vnew(jx).fname=[fpath '/msk_wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii']
                spm_write_vol(Vnew(jx),squeeze(img_mtx(:,:,:,jx)).*mask);
            end
        end
    end
end

%% -------------- WD2: Intensity Normalization to 1000 --------------------
% --> is this really necessary???
if 1==1
    for ix=1:size(Pfunc_social_hierarchy,2)
        %% Reappraisal
        [fpath fname ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pfunccur=spm_select('FPlist',fpath,['^msk_wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii']);
        intensity_normalization(Pfunccur);
    end
end


%% ---------------------- WD3: Actual WaveletDespiking --------------------
if 1==1
    % set path
    addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/wavelet_despiking/'))
    
    for wdthresh=[10]%[10,20,30,50]%[30 50 70 100 20 40]
        for ix=1:size(Pfunc_social_hierarchy,2)
            %% Reappraisal
            [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
            newdir=[fpath '/wavelet/'];
            mkdir(newdir);
            cd(newdir)
            
            %fpath='/home/laurens.winkelmeier/awake/all_awake_MAIN/MRI/TEST_waveletDespiking/'
            %       Pcur=spm_select('FpList', fpath , ['^msk_s_wst5_a_u_del5_' fname '_c1_c2t_icaden25.nii']); % CC 190918 instead of: Pcur=spm_select('FpList', fpath , ['^wst5_a_u_del5_' fname '_c1_c2t.nii']);
            Pcur=spm_select('FpList', fpath , ['^med1000_msk_wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii']);
            
            [fpath, fname, ext]=fileparts(Pcur);
            
            threshold = wdthresh;
            prefix = ['wave_' num2str(threshold) 'cons_'];
            WaveletDespike(Pcur,[prefix fname],'threshold',threshold,'chsearch','conservative','verbose',1,'LimitRAM',80);

            gunzip([newdir prefix fname '_wds.nii.gz']);
            delete([newdir prefix fname '_wds.nii.gz']);
            
            gunzip([newdir prefix fname '_noise.nii.gz']);
            delete([newdir prefix fname '_noise.nii.gz']);
            
            gunzip([newdir prefix fname '_EDOF.nii.gz']);
            delete([newdir prefix fname '_EDOF.nii.gz']);
                    end
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Appendix ICA!
% Create folder for every animal and copy file to respective folder
if 1==0
    Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    Vmask=spm_vol(Pmask);
    mask=spm_read_vols(Vmask);
    
    mask(isnan(mask))=0;
    for ix=1:size(Pfunc_social_hierarchy,2)
        %% social_hierarchy
        Pcur=deblank(Pfunc_social_hierarchy{ix});
        [fpath, fname, ext]=fileparts(Pcur);
        P=spm_select('ExtFPList',fpath,['^s_wrst_a1_u_del5_' fname '_c1_c2t.nii'],[1:3000]);
        nimg=size(P,1);
        Vi=spm_vol(P);
        img_mtx=spm_read_vols(Vi);
        Vnew=Vi;
        for jx=1:nimg
            Vnew(jx).fname=[fpath '/msk_s_wrst_a1_u_del5_' fname '_c1_c2t.nii']
            spm_write_vol(Vnew(jx),squeeze(img_mtx(:,:,:,jx)).*mask);
        end
    end
end

% Create folder for every animal and copy file to respective folder
if 1==0
    for ix=1:size(Pfunc_social_hierarchy,2);
        %% social_hierarchy
        Pcur=deblank(Pfunc_social_hierarchy{ix});
        [fpath, fname, ext]=fileparts(Pcur);
        ICA_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing/ICA';
        mkdir(ICA_dir);
        mkdir([ICA_dir filesep 'social_hierarchy' filesep fname]);
        Pcur1=spm_select('FPList',fpath,['^msk_s_wrst_a1_u_del5_' fname '_c1_c2t.nii']);
        Pcur2=([ICA_dir filesep 'social_hierarchy' filesep fname]);
        syscmd=['cp ' Pcur1 ' ' Pcur2 ]
        %alternativly: ['find -name ' Pcur1 ' -exec cp {} ' Pcur2 ' \;'];
        system(syscmd)
    end
end



if 1==0;
    for ix=1%:size(Pfunc,2);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        
        EPI=spm_select('FPList',fdir,['^s_wst5_a_u_del5_' fname '_c1_c2t.nii']);
        Pmask='/home/laurens.winkelmeier/Awake/helpers/atlas/rDLtemplate_brainmask_rs1x1x1_polish.nii';%resliced 2 norm EPI; binary of template
        
        acl_ICADenoising_decomposition_jr_lw(fdir,EPI,Pmask)
    end
end



%---------------------- BET FUNC -----------------------------------------%

%result= *ic.nii (robert's function, not ext_brain)
if 1==0
    for ix=1:size(Pfunc,2)
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('FpList', fpath , ['^s_wst5_a_u_del5_' fname '_c1_c2t.nii']);
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3dmask='/home/laurens.winkelmeier/Awake/helpers/atlas/rDLtemplate_brainmask_rs1x1x1_polish.nii';%resliced 2 norm EPI; binary of template
        Vo=rb_extfunc_3dmsk(Pcur,P3dmask);
    end
end



%-------------------------------------------------------------------------%
% filtered EPI for DVARS approach:

if 1==0
    for ix=1:numel(Pfunc);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('ExtFPList',fdir,['^wst5_a_u_del5_' fname '_c1_c2t.nii'],1);
        
        do_regfilt_lw(Pcur)
    end
end



%% WAVELET DESPIKING!

if 1==0
    for ix=2:size(Pfunc,2)
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        newdir=[fpath '/wavelet/'];
        mkdir(newdir);
        cd(newdir)
        
        
        %fpath='/home/laurens.winkelmeier/awake/all_awake_MAIN/MRI/TEST_waveletDespiking/'
        
        
        Pcur=spm_select('FpList', fpath , ['^wst5_a_u_del5_' fname '_c1_c2t.nii']);
        [fpath, fname, ext]=fileparts(Pcur);
        
        
        WaveletDespike(Pcur,['wave_' fname]);
        
        gunzip([newdir 'wave_' fname '_wds.nii.gz']);
        delete([newdir 'wave_' fname '_wds.nii.gz']);
        
        gunzip([newdir 'wave_' fname '_noise.nii.gz']);
        delete([newdir 'wave_' fname '_noise.nii.gz']);
        
        gunzip([newdir 'wave_' fname '_EDOF.nii.gz']);
        delete([newdir 'wave_' fname '_EDOF.nii.gz']);
        
    end
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Motion diagnosis old:

% MOTIONDIAGNOSIS %

%------------------------------ Motiondiagnosis --------------------------%
% %framewise displacement: mouse brainsize, detrended rp
% if 1==0
%     motiondir=[studydir filesep 'motiondir'];
%     syscmd=['mkdir ' motiondir];
%     system(syscmd)
%
%     for ix=1:size(Pfunc,2);
%         [fpath, fname, ext]=fileparts(Pfunc{ix});
%         EPI=spm_select('ExtFPlist',fpath,['^wst5_a_u_del5_' fname '_c1_c2t.nii']);
%         thres=0.10;
%         mask='/home/laurens.winkelmeier/Awake/helpers/atlas/rDLtemplate_brainmask_rs1x1x1_polish.nii';
%         outputdir=[studydir filesep 'motiondir']%'/home/laurens.winkelmeier/awake/sanity_check/MRI/motiondir';
%         [FD]=acl_motiondiagnosis_jr_lw(EPI,thres,mask,outputdir);
%         FD_all(:,ix)=FD>thres;
%
%
%
% end
%
% % Scrubbing:
% if 1==0;
%     load '/home/laurens.winkelmeier/awake/sanity_check/MRI/motiondir/FD_all_10_mouse_detr.mat'
%     for ix=1:size(Pfunc,2);
%         [fpath, fname, ext]=fileparts(Pfunc{ix});
%         T=FD_all(:,ix);
%         threshold=0.10;
%         method='lin';
%         [R,T,EPI]=scrubbing_jr(fpath,T,threshold,method);
%     end
% end
%
% %---------- Smoothing (without band-pass filtering afterwards) -----------%
% % prefix = 's_'
% if 1==0
%     for ix=1:size(Pfunc,2);
%     [fpath fname ext]=fileparts(Pfunc{ix});
%
%     %Pcur=spm_select('ExtFPList',fpath,['^scrub_0.1_lin_wst5_a_u_del5_' fname '_c1_c2t.nii$'],1); %censoring!
%     Pcur=spm_select('ExtFPList',fpath,['^wst5_a_u_del5_' fname '_c1_c2t.nii$'],1);
%     %Pcur=spm_select('ExtFPList',fpath,['^wst5_a_u_del5_' fname '_c1_c2t.nii$'],1); %no censoring
%
%     fwhm_cur=[6 6 6];
%
%     do_smooth_lw(Pcur,fwhm_cur);
%     end
% end
%
%
%
%


%old version MOTIONDIAGNOSIS:

% thres=0.05; % define!!!
% motiondir=[studydir filesep 'motiondir'];
% syscmd=['mkdir ' motiondir];
% system(syscmd)
%
% if 1==0 % acl's script for visualising
%     syscmd=['rm ' motiondir filesep 'DVARS_FWD_0.03_0.05_csffilt.ps'];
%     system(syscmd)
%     for ix=1%:size(Pfunc,2);
%             [fpath fname ext]=fileparts(deblank(Pfunc{ix}));
%             Pcur=spm_select('FPList',fpath,['^wst5_a_u_del5_' fname '_c1_c2t.nii$']);
%             Pcur1=spm_select('ExtFPList',fpath,['^wst5_a_u_del5_' fname '_c1_c2t.nii$'],1);
%             Vi=spm_vol(Pcur1);
%             Vo=Vi;
%             Vo.fname=[fpath filesep 'wst5_a_u_del5_' fname '_bin.nii'];
%             spm_imcalc(Vi,Vo,'i1>0',{0 0 0});
%
%             %[FD_all(ix,:)]=acl_motiondiagnosis_jr(fdir,Pmsk,motiondir);
%             acl_motiondiagnosis_jr_cc(Pcur,Vo,motiondir,thres);%
%     end
% end
%
%

% if 1==0
%     syscmd=['rm ' motiondir filesep 'FDoverview.ps ' motiondir filesep 'FD_all.mat'];
%     system(syscmd)
%     FD_all=cell(size(Pfunc,2),3);
%     badfrac_all=NaN(size(Pfunc,2),1);
%     for ix=1:size(Pfunc,2)
%         [fpath fname ext]=fileparts(deblank(Pfunc{ix}));
%         T=SNiP_framewise_displacement_jr(dlmread([fpath filesep 'rp_' fname '.txt']));
%         FD_all{ix,3}=mean(T);
%         FD_all{ix,2}=ix;
%         tix=strfind(fname,'_M17');
%         lbl=fname(tix+2:tix+8);
%         FD_all{ix,1}=lbl;
%         if 9==0
%             Pcur=spm_select('FPList',fpath,['^u' fname '.nii$']); %wst5_aaztec_or0_filt_u % _c22_ic
%             [R,~,EPI,badfrac]=scrubbing_jr(Pcur,T,thres);%CAVE spline vs. linear
%             badfrac_all(ix,1)=badfrac;
%         end
%     end
%     save([motiondir filesep 'FD_all'], 'FD_all')
%     if 9==0
%         display(badfrac_all)
%         min_badfrac=min(min(badfrac_all))
%         max_badfrac=max(max(badfrac_all))
%     end
%     figure(31)
%     plot(cell2mat(FD_all(:,2)),cell2mat(FD_all(:,3)))
%     a1=gca;
%     a1.XTick=[1:size(Pfunc,2)];
%     a1.XTickLabel=FD_all(:,1);
%     a1.XTickLabelRotation=45;
%     title('mean framewise displacement per session')
%     print('-bestfit','-dpsc',fullfile(motiondir,'FDoverview.ps') ,'-r400','-append')
%     close(figure(31))
% end

% % OTHER APPROACH NORMALIZATION
% %-----------------------   Normalization OLD ---------------------------------%
% %Normalization of 3d to atlas:
% if 1==0
%     for ix=2:size(P3d,2);
%         [fpath, fname, ext]=fileparts(P3d{ix});
%         P3dcur=spm_select('ExtFPlist',fpath,['^st5_bc_' fname '_brain_c2t.nii'],1);
%
%         do_norm3d2atlas_lw(P3dcur, Ptemp)
%     end
% end
%
% %Normalization of func to atlas:
% if 1==0
%     for ix=2:size(P3d,2);
%         [fpath, fname, ext]=fileparts(Pfunc{ix});
%         Pcur=spm_select('ExtFPlist',fpath,['^st5_a_u_del5_' fname '_c1_c2t.nii'],1);
%         [fpath, fname, ext]=fileparts(P3d{ix});
%         P3dcur=spm_select('ExtFPlist',fpath,['^st5_bc_' fname '_brain_c2t.nii'],1);
%         P3dsn=spm_select('FPlist',fpath,['^st5_bc_' fname '_brain_c2t_sn.mat']);
%
%         do_normfunc2atlas_lw(P3dcur,Pcur,P3dsn);
%     end
% end

% %---------------------------- Band-pass filter----------------------------%
% if 1==0
%     Pmask_func='/home/laurens.winkelmeier/Awake/helpers/atlas/resliced_brainmask_func.nii';
%     for ix=2%:size(Pfunc,2);
%         [fpath, fname, ext]=fileparts(Pfunc{ix});
%         Pcur=spm_select('FPlist',fpath,['^regfilt_wst5_a_filt_u_del5_' fname '_c1_c2t.nii$']);
%
%         rb_bp_mask(Pcur,1.3,0.01,0.3)
%         %wwf_bandpass(Pcur,1.3,0.01,0.3,Pmask_func);
%     end
% end
%
% %---------------- Smoothing (band-pass filtered data) --------------------%
% % smoothing (added by CC)
% % prefix = 's_'
% if 1==0
%     for ix=1:size(Pfunc,2);
%     [fpath fname ext]=fileparts(Pfunc{ix});
%     Pcur=spm_select('ExtFPList',fpath,['^bp_0.01_0.3_regfilt_wst5_a_filt_u_del5_' fname '_c1_c2t.nii$'],1);
%     fwhm_cur=[6 6 6];
%
%     do_smooth_lw(Pcur,fwhm_cur);
%     end
%
% end
%
% %ULTIMATE CHECK!!!
% if 1==0
%     Ptemp='/home/laurens.winkelmeier/Awake/helpers/atlas/DLtemplate_brain_rs1x1x1.nii';
%     for ix=1:size(P3d,2);
%
%         [fpath, fname, ext]=fileparts(P3d{ix});
%         P3d_norm=spm_select('ExtFPlist',fpath,['^wst5_bc_' fname '_brain_c2t.nii'],1);
%
%         [fpath fname ext]=fileparts(Pfunc{ix});
%         Pfunc_norm=spm_select('ExtFPList',fpath,['^wst5_a_filt_u_del5_' fname '_c1_c2t.nii'],1);
%
%         Pfunc_filt=spm_select('ExtFPList',fpath,['^s_wst5_a_filt_u_del5_' fname '_c1_c2t.nii'],1);
%
%         char_all=char([cellstr(Ptemp);cellstr(P3d_norm);cellstr(Pfunc_norm); cellstr(Pfunc_filt)]);
%         %char_all=char([cellstr(Ptemp);cellstr(P3d_norm);cellstr(Pfunc_norm);cellstr(P3d_c3)]);
%         spm_check_registration(char_all)
%         input('weiter');
%     end
% end

% %---------------------------- REGRESSION -------------------------------%
% regression of realign parameters is now included in CSF Filtering!
% prefix: filt_

% if 1==0
%     for ix=2%:numel(Pfunc);
%         [fdir, fname, ext]=fileparts(Pfunc{ix});
%         Pcur=spm_select('ExtFPList',fdir,['^wst5_a_filt_u_del5_' fname '_c1_c2t.nii'],1); %input depends on which Normalization approach!
%
%         do_regfilt_lw(Pcur)
%     end
% end
%
% % visual control:
% if 1==0
% for ix=1:size(Pfunc,2);
%     [fpath fname ext]=fileparts(Pfunc{ix});
%     Pfunc_cur=spm_select('ExtFPList',fpath,['^wst5_a_u_del5_' fname '_c1_c2t.nii'],1);
%     Pfunc_filt=spm_select('ExtFPList',fpath,['^filt_wst5_a_u_del5_' fname '_c1_c2t.nii$'],1);
%     char_all=char([cellstr(Pfunc_cur);cellstr(Pfunc_filt)]);
%     spm_check_registration(char_all)
%     input('weiter');
%     end
% end


%-------------------- Global timecourse regression -----------------------%
%BET FUNCTIONAL DATA

% %3D binary mask creation:
% if 1==0
%   for ix=1%:size(P3d,2);
%        [fpath, fname, ext]=fileparts(P3d{ix});
%
%        P3d_binary_mask=spm_select('FPlist',fpath,['^st5_bc_' fname '_brain_c2t.nii$']);
%        do_ext3dmsk(P3d_binary_mask)
%    end
% end

% %result= *ic.nii (robert's function, not ext_brain)
% if 1==0
%   for ix=1:size(Pfunc,2)
%        [fpath, fname, ext]=fileparts(Pfunc{ix});
%        Pcur=spm_select('FpList', fpath , ['^wst5_a_u_del5_' fname '_c1_c2t.nii']);
%        [fpath, fname, ext]=fileparts(P3d{ix});
%        P3dmask='/home/laurens.winkelmeier/Awake/helpers/atlas/rDLtemplate_brainmask_rs1x1x1_polish.nii';%resliced 2 norm EPI; binary of template
%        Vo=rb_extfunc_3dmsk(Pcur,P3dmask);
%    end
% end
%
% %
% if 1==0
%     for ix=1%:size(Pfunc,2);
%         Pcur=deblank(Pfunc{ix});
%         [fdir, fname, ext]=fileparts(Pcur);
%         Pfunc_cur=spm_select('ExtFPList',fdir,['^wst5_a_u_del5_.*' fname  '_c1_c2t_ic.nii'],1);
%         bgthr=500; % bgthr = threshold defining voxels to take into account
%
%         rb_get_global_tc_lw(Pfunc_cur,bgthr);
%     end
% end

% %-------------------- CREATE REGRESSOR TXT-FILE --------------------------%
% % % + derivatives of motion, csf, global
% % result: regressor list with 16 columns (regr_all.txt)
% if 1==0
%
%         rb_make_regtxt_lw(Pfunc);
%
% end
%
%
