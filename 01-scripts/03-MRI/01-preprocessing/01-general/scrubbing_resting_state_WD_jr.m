function [R,T,EPI]=scrubbing_resting_state_WD_jr(fdir,T,threshold,method,outpref)


prefix='wave_10cons_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';

EPI=spm_select('FPList',[fdir '/wavelet'],strcat('^',prefix,'.*_c1_c2t_wds.nii$'));
V=spm_vol(EPI);
mtx=spm_read_vols(V);
T=(T>threshold);
[R, T] = SNiP_scrubbing_jr(mtx, T, method,'keep');
R_nan=isnan(R);
R(R_nan)=mtx(R_nan);


outname=EPI; % predefining outname
Vi=spm_vol(outname);

%% added dy JR
if strcmp(method,'cut');
    ind=find(T~=1);
    Vi=Vi(ind);
end;
%% end: added dy JR

[fdir_EPI,fname_EPI,ext_EPI]= fileparts(EPI);
thresh_name = num2str(threshold);
outnew=[fdir_EPI filesep outpref '_' thresh_name(3:end) '_' method '_' fname_EPI '.nii'];

for n=1:length(Vi);
    Vo=Vi(n);
    Vo.n=[n 1];
    Vo.fname=outnew;
    spm_write_vol(Vo, squeeze(R(:,:,:,n)));
end;
    


