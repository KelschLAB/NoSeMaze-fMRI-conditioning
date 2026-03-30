function [tc roidata]=wwf_roi_tcours(Pmsk,Pdata,Pdir);

if nargin<1
    [Pmsk,sts]=spm_select(1,'any','Select Mask',[],pwd,'.*..nii');
end

if nargin<2
    [Pdata,sts]=spm_select(1,'image','Select Image');
end
%Create atlas image in space of image:
[fpath fname ext]=fileparts(Pdata);
%1=spm_vol(Pdata);
V2=spm_vol(Pmsk); % loading header of Pmsk (1x1 struct)
Vcur=spm_vol([fpath filesep fname '.nii']); % loading header of Pdata (340x1 struct)
V1=Vcur(1) % header info of first of 340 Vols
Vi=[V1 V2]; % header info of V1=Pdata first Vol V2=Pmsk
Vo=V1; % predefinition of output file
[fpath]=fileparts(Pdir)
Vo.fname=[fpath filesep fname '_mask.nii']; % naming of output file
Vmask_func=spm_imcalc(Vi,Vo,'i2',{0, 0, 0}); % calculation of functional mask using imcalc (based on the first EPI and the Pmsk)
nimg=size(Vcur,1);
mtx_func=spm_read_vols(Vcur); % loading the matrices of the functional EPI data (340 3D files)
funcsize=size(mtx_func);
mtx_func=reshape(mtx_func,prod(funcsize(1:3)),funcsize(4)); % reshaping the 4d matrix of the EPIs into a 2D one with indices for all 3D-numbers and the 340 EPIs
mtx_mask=spm_read_vols(Vmask_func); % loading the matrix of the functional mask which was created before (1 3D files)
mtx_mask(isnan(mtx_mask))=0; % zeroing of the NaN values of the functional mask
%clear V1 V2 Vcur
%fprintf('%s: ',fname);
indx=find(mtx_mask); % finding nonzero indices of the mask
%ize(indx,1);
roidat=mtx_func(indx,:); % using nonzero-indices of the mask to read out the EPI-values
nanIndex = any( isnan( roidat ), 2 );
%outima=mtx_func(:,1);
%outima(indx)=20000;
%outima=reshape(outima,funcsize(1:3));
%spm_write_vol(Vout,outima);

%          meantime=squeeze(mean(roidat));
%if isnan(meantime); keyboard;end
[x y z]=ind2sub(size(mtx_mask),indx); % creating 
pos=[x y z];
pos_mtx=[pos  ones(size(pos,1),1) ];
pos_mm=Vmask_func.mat*pos_mtx';
pos_mm=pos_mm(1:3,:);
meantime = squeeze( mean( roidat(~nanIndex, :) ) );
roidata.pos=pos(~nanIndex, :);
roidata.pos_mm=pos_mm;
roidata.tc=roidat(~nanIndex, :);
[dir mskname]=fileparts(Pmsk);
foutname=[fpath filesep fname '_' mskname '_tc.txt']
fout=fopen(foutname,'w+t');
fprintf(fout,'%10.4f\n',meantime);
fclose(fout);
matname=[fpath filesep fname '_' mskname '_roidata.mat']
save(matname,'roidata');
foutname=[fpath filesep fname '_' mskname '_tc_sv.txt']
fout=fopen(foutname,'w+t');
for ln=1:size(roidata.tc,2)
    fprintf(fout,'%10.4f ',roidata.tc(:,ln));
    fprintf(fout,'\n');
end
fclose(fout);
tc=meantime;

