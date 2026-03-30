function [cormat subj]=wwf_covmat_hres(Ptxt,P,Patlas)

if nargin <3
    [Patlas,sts]=spm_select(1,'image','Select Atlas (merged)',[],pwd,'.*.nii');
   % atlas='/home/lcmodel/Natalia/Masks/lowres/atlas_merged.nii';
end
   atlas=Patlas;


if nargin<1
	[Ptxt,sts]=spm_select(1,'any','Select Textfile',[],pwd,'.*.txt');
end

if nargin<2
	[P,sts]=spm_select(inf,'image','Select Images');
end

nsubs=size(P,1);
regfile=read_t2s(Ptxt);
nreg=size(regfile,1);

% creating a struct array (region) with the number and name of the regions
for lnum=1:nreg
     tline=regfile(lnum,:); % line from txt-file
     cix=findstr(',',tline); % find the comma in tline and save the position as cix
     region(lnum).name=deblank(tline(cix(end)+1:end)); % struct array: region(1).name is the name of the region defined in the txt
     eval(['nums=[' tline(1:cix(end)-1) '];']); %eval evaluates the matlab code in the expression 
     region(lnum).nums=nums; % struct array: region(1).nums is the number of the region defined in the txt
end


%Create atlas image in space of image:
for ns=1:nsubs;
    Pcur=deblank(P(ns,:));
    [fpath fname ext]=fileparts(Pcur);
    subj(ns).name=Pcur;
    V1=spm_vol(Pcur);
    V2=spm_vol(atlas);
    Vi=[V1 V2];
    Vo=V1;
    Vo.fname=[fpath filesep 'atlas_func.nii'];
        %change dimensions of atlas to epi
    Vatlas=spm_imcalc(Vi,Vo,'i2',{0, 0, 0});
    Vcur=spm_vol([fpath filesep fname '.nii']);
    nimg=size(Vcur,1);
    tcourse=zeros(nreg,nimg);
%       load Vcurufull.mat
%     for ix=1:400; 
%         Vcur(ix).mat=Vcurufull(ix).mat;
%     end;
%     
    mtx_func=spm_read_vols(Vcur);
  
    funcsize=size(mtx_func);
    mtx_func=reshape(mtx_func,prod(funcsize(1:3)),funcsize(4));
    mtx_atl=spm_read_vols(Vatlas);
    clear V1 V2 Vcur
    fprintf('%s: ',fname);
    for nr=1:nreg
        fprintf('%d ',nr);
         mask=ismember(mtx_atl,region(nr).nums);
         Vout=Vatlas;
         Vout.fname=[region(nr).name '.nii'];
         spm_write_vol(Vout,mask);
         indx=find(mask);
         size(indx,1);
         roidat=mtx_func(indx,:);
         
         nanIndex = any( isnan( roidat ), 2 );
         
%          meantime=squeeze(mean(roidat));
         %if isnan(meantime); keyboard;end
        meantime = squeeze( mean( roidat(~nanIndex, :) ) );

         subj(ns).roi(nr).tcourse=meantime;
         subj(ns).roi(nr).name=region(nr).name;
         subj(ns).roi(nr).size=length(indx);
         clear roidat;
    end
    tc_mat=zeros(nimg,nreg);
    for ix=1:nreg; tc_mat(:,ix)=subj(ns).roi(ix).tcourse';end
    
    for ix=1:nreg 
        % Calculate mean and standard deviation
        mean_beta = mean(subj(ns).roi(ix).tcourse');
        std_beta = std(subj(ns).roi(ix).tcourse');

        % Standardize the data
        standardized_beta = (subj(ns).roi(ix).tcourse' - mean_beta) / std_beta;

        tc_mat_norm(:,ix)=standardized_beta;
    end
    
    fprintf('\n');
     cormat{ns}=corrcoef(tc_mat, 'rows', 'pairwise' );
     cormat_norm{ns}=corrcoef(tc_mat_norm, 'rows', 'pairwise' );
   % save roidata subj
     %R= corrcoef(X)
     
     disp( ns )
     disp( any( isnan( tc_mat(:) ) ) )
     disp( any( isnan( cormat{ns}(:) ) ) )
end
fnames={subj(1).roi.name}
 %save roidata subj
 %save cormat cormat names

% plots matrices and saves a ps and jpg file 
%rb_mtxplot2file(cormat{1, 1},names,'/home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/covmat/covcor_all',Pcur)

