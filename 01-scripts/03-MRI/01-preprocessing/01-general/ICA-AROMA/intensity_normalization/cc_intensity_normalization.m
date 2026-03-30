% this is derived from cc_meanEPI_over_sessions.m

% the point is to normalize the intensity of a whole session (i.e. over all
% TRs and all voxels) to a median of 1000, as described in Patel's Wavelet
% Despiking Paper. According to that paper, it's done after smoothing.


clearvars
% wdthresh=30;
studydir='/home/laurens.winkelmeier/awake/all_awake_MAIN/MRI'; cd(studydir);
load([studydir filesep 'filelist_awake_MAIN.mat'], 'Pfunc'); % filelist PREPROCESSING
load('/home/laurens.winkelmeier/awake/all_awake_MAIN/MRI/behavior_rhd+mat/paradigm/paradigm.mat'); % behavior data -> paradigm.mat  
array_valid_sessions= paradigm.performance_check.valid_sessions;
cnt=0;
for ix= array_valid_sessions  
    ix
    cnt=cnt+1;
    immtx_allfr=NaN(63,33,75,1395);
    [fdir, fname, ext]=fileparts(Pfunc{ix});
    Pfunccur=spm_select('FPlist',fdir,['^s_wst5_a_u_del5_' fname '_c1_c2t.nii']); 
    Vi=spm_vol(Pfunccur);
    for iy=1:1395
        immtx=spm_read_vols(Vi(iy));
        immtx(immtx==0)=NaN;
        immtx_allfr(:,:,:,iy)=immtx;
    end
    n=numel(immtx_allfr);
    i_allfr_resh=reshape(immtx_allfr,[n,1]);
    med=nanmedian(i_allfr_resh);
    immtx_allfr_med1000=immtx_allfr-med+1000;
    %% test
    testmed=nanmedian(reshape(immtx_allfr_med1000,[n,1]));
    if testmed~=1000
        error('median not 1000!')
    end
    %%
    Vo=Vi;
    for iy=1:1395
        Vo(iy).fname=[fdir filesep 'med1000_s_wst5_a_u_del5_' fname '_c1_c2t.nii'];% NB: ",1" is not necessary
        spm_write_vol(Vo(iy),squeeze(immtx_allfr_med1000(:,:,:,iy)))
    end
end
    
   
