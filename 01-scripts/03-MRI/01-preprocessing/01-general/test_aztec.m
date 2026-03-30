if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/data/social_hierarchy/fMRI/filelists/filelist_ICON_social_hierarchy_jr.mat')
end;

%% ------------------------ Checking of physio data ------------------------%
if 1==1
    ndel_dummies=5;
    [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{18});
    Pinput=spm_select('FPList',fpath, ['^u_del5.*' fname  '.nii']);
    cc_check_physio_dummy(Pinput,Pphysio_social_hierarchy(18,:),ndel_dummies)
end
%

%------------------- loading the filter file ------------------------------
% First run with std_filt and readout the borders for cardiac and
% respiration data from the figures.

std_filt= [3 14 3 14];

%--------------------------- physio script --------------------------------
if 1==1
    for ix=1:5%length(Pfunc_social_hierarchy);
        filter=std_filt
%         filtnum=find(rsfilt(:,1)==ix);
%         if ~isempty(filtnum)
%             filter=rsfilt(filtnum,2:end);
%         else
%             filter=std_filt;
%         end
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pinput=spm_select('FPList',fpath, ['^u_del5.*' fname  '.nii']);
        [fpath, fname, ext]=fileparts(deblank(Pphysio_social_hierarchy(ix,:)));
        Pphysio_input=fullfile(fpath,[fname '_rep' ext]);
        do_script_physio(Pphysio_input,Pinput,filter)
    end
end


if 1==0
    rb_print_physio_ffts_jr(Pfunc,Pphysio,'physio_overview_repaired')
end;

%------------------------------- AZTEC -----------------------------------%
if 1==1
    for ix=1:5%length(Pfunc_social_hierarchy);
        [fpath, fname, ext]=fileparts(Pfunc_social_hierarchy{ix});
        Pcur=spm_select('ExtFPList',fpath,['^u_del5.*' fname  '.nii'],1);
        do_aztec(Pcur);
    end
end