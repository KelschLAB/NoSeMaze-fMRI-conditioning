function acl_regfilt_motcsf_awake_jr(EPI,csf,GM_mask,Pmask,qmcsf,a)
%qmcsf is the threshold of "brightness" of the CSF voxels, e.g. 0.95 for
%the 5% brightest voxels of the CSF-mask
% EPI (all volumes?)
 
% if nargin==1
%     qmcsf=0;
%     prefix='au';
% elseif nargin==2
%     qmcsf=0;
% end
%  
V=spm_vol(EPI);
%  
% if ~isempty(strfind(prefix,'w'))
%     csf=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'^CSF.nii');
%     mask=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'^mask.nii');
%     try
%         param=spm_select('FPList',fullfile(fdir,'Anatomical'),'^*sn.mat');
%  
%         matlabbatch{1}.spm.tools.oldnorm.write.subj.matname = cellstr(param);
%         matlabbatch{1}.spm.tools.oldnorm.write.subj.resample = cellstr(strvcat(csf,mask));
%         matlabbatch{1}.spm.tools.oldnorm.write.roptions.preserve = 0;
%         matlabbatch{1}.spm.tools.oldnorm.write.roptions.bb = nan(2,3);
%         matlabbatch{1}.spm.tools.oldnorm.write.roptions.vox = [3.65 3.65 3.65];
%         matlabbatch{1}.spm.tools.oldnorm.write.roptions.interp = 0;
%         matlabbatch{1}.spm.tools.oldnorm.write.roptions.wrap = [0 0 0];
%         matlabbatch{1}.spm.tools.oldnorm.write.roptions.prefix = 'w';
%         spm_jobman('run',matlabbatch);clear matlabbatch;
%     end
%     csf=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'^wCSF.nii');
%     mask=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'^wmask.nii');
% else
%     csf=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'^CSF.nii');
%     mask=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'^mask.nii');
% end

% mask=spm_select('FPList','Templates','func_mask.nii'); % normalized brain mask
 
Vcsf=spm_vol(csf);
csf=spm_read_vols(Vcsf);
csf=csf>0.8; %ADDED by JR for only using voxels with high probability of belonging to CSF

Vmask=spm_vol(GM_mask);
mask=spm_read_vols(Vmask);
 
mtx=spm_read_vols(V);
 
meanmtx=mean(mtx,4);
qm=quantile(mtx(find(csf)),qmcsf);
 
csf=csf.*(meanmtx>=qm);
[fdir fname ext]=fileparts(EPI)
Vcsf.fname=fullfile(fdir,'CSFreg.nii');
spm_write_vol(Vcsf,csf);
 
mtxsz=size(mtx);
 
mtx=reshape(mtx,prod(mtxsz(1:3)),prod(mtxsz(4)));
 
data=mtx;
 
datamean=mean(data,2);
datastd=std(data,[],2);
 
datanorm=(data-repmat(datamean,1,mtxsz(4)))./repmat(datastd,1,mtxsz(4));

%rp0=[spm_load(spm_select('FPList',fdir,'^rp.*.reorient.txt')) nanmean(datanorm(find(csf),:))' nanmean(datanorm(find(mask),:))'];
rp_only=[spm_load(spm_select('FPList',fdir,'^rp.*.reorient.txt'))];
rp_only_diff=[rp_only [zeros(1,size(rp_only,2)); diff(rp_only)]];

rp0=[spm_load(spm_select('FPList',fdir,'^rp.*.reorient.txt')) nanmean(datanorm(find(csf),:))'];
rp1=[rp0 [zeros(1,size(rp0,2)); diff(rp0)]];



% not detrended rp:
dlmwrite(fullfile(fdir,strcat('regressors_mot_der.txt')),rp_only_diff,'delimiter','\t','precision','%.6f')

dlmwrite(fullfile(fdir,strcat('regressors_motcsf.txt')),rp0,'delimiter','\t','precision','%.6f')
dlmwrite(fullfile(fdir,strcat('regressors_motcsf_der.txt')),rp1,'delimiter','\t','precision','%.6f')

%--------------------------------------------------------------------------
% create versions with detrendet data
% detrending
% 
rp=spm_load(spm_select('FPList',fdir,'^rp.*.reorient.txt')) ;

for i=1:size(rp,2)
    [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
    tr=polyval(p,1:size(rp,1),[],mu);
    
    rp(:,i)=rp(:,i)-tr'; 
end

rp2=[rp nanmean(datanorm(find(csf),:))'];
rp3=[rp nanmean(datanorm(find(csf),:))' nanmean(datanorm(find(mask),:))'];
rp4=[rp3 [zeros(1,size(rp3,2)); diff(rp3)]];
rp5=[rp2 [zeros(1,size(rp2,2)); diff(rp2)] ];

dlmwrite(fullfile(fdir,strcat('regressors_detrmot_csf.txt')),rp2,'delimiter','\t','precision','%.6f')
dlmwrite(fullfile(fdir,strcat('regressors_detrmot_csfgs.txt')),rp3,'delimiter','\t','precision','%.6f')
dlmwrite(fullfile(fdir,strcat('regressors_detrmot_csfgs_der.txt')),rp4,'delimiter','\t','precision','%.6f')
dlmwrite(fullfile(fdir,strcat('regressors_detrmot_csf_der.txt')),rp5,'delimiter','\t','precision','%.6f')


%% Regression:

if 1==a
    rpfile=fullfile(fdir,strcat('regressors_motcsf_der.txt'));

    [pathstr,name,ext]=fileparts(EPI);

    outfile=fullfile(pathstr,strcat('regfilt_motcsfder_',name,ext))

    s=num2str(1:10);
    s=strrep(s, '   ', ',')

    sysprompt=(['fsl_regfilt '  ' -i ' EPI     ' -o ' outfile  ' -m ' Pmask   ' -d ' rpfile '  '  ' -f 1,2,3,4,5,6,7,8,9,10,11,12,13,14']);
    system(sysprompt)

    sysprompt=(['fslchfiletype NIFTI ' outfile ]);
    system(sysprompt)
end
