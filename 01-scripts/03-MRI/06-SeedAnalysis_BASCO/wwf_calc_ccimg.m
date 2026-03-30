function wwf_calc_ccimg(P, Ptc, threshold, PdirCC, PdirfCC)
%function wwf_calc_ccimg(P, Ptc, threshold)
% Calculate correlation coefficiant images for P with timecourse Ptc
% Same number of functional Images (1st image of each 4D) and Timecouse
% text files must be selected.
% Optional argument threshold (default 10%) will mask images at %maxval
% CC Images are saved as CC_[fname] 
% Fisher Z transformed images as fCC_[fname]

if nargin<3
    threshold=10;
end

if nargin<2
    [Ptc,sts]=spm_select(inf,'any','Select Time Course Textfile',[],pwd,'.*.txt');
end

if nargin<1
    [P,sts]=spm_select(inf,'image','Select Images (first of each Func)');
end


nsubs=size(P,1);
if size(Ptc,1)~=nsubs
    error(4,'Files for tc and func do not match');
end

h=waitbar(0,['Calculating 1/' num2str(nsubs)]);
for ns=1:nsubs
    [fdir ,fname, fext]=fileparts(deblank(P(ns,:)));
    V=spm_vol([fdir filesep fname '.nii']);
    fmat=spm_read_vols(V); 
    maxval=max(max(max(max(fmat))));
    thres=threshold/100*maxval;
    tc_roi=spm_load(deblank(Ptc(ns,:)));
    corrmat=zeros(size(fmat(:,:,:,1)));
    for ix=1:size(fmat,1);
        for iy=1:size(fmat,2);
            for iz=1:size(fmat,3);
                tc=squeeze(fmat(ix ,iy, iz,:));
                if mean(tc)>thres
                    cc=corrcoef(tc, tc_roi);
                    corrmat(ix,iy,iz)=cc(1,2);
                else
                     corrmat(ix,iy,iz)=nan;
                end
            end
        end
        waitbar(ix/size(fmat,1),h,['Calculating ' num2str(ns) '/' num2str(nsubs)]);
        %fprintf(1,'%d ',ix);
    end
    %Write out file
    [tcdir, tcname, tcext]=fileparts(deblank(Ptc(ns,:)));
    prefix= tcname(findstr(' ',tcname)+1:end);
    Vo=V(1); 
    Vo.fname=[PdirCC 'CC_' prefix fname '.nii'];
    fprintf(1,'Writing %s\n',Vo.fname);
    spm_write_vol(Vo,corrmat);
    %Fisher z transform
    fcorrmat=0.5*log((1+corrmat)./(1-corrmat));
    fcorrmat(isinf(fcorrmat))=1;
    Vo.fname=[PdirfCC 'fCC_' prefix fname '.nii'];
    fprintf(1,'Writing %s\n',Vo.fname);
    spm_write_vol(Vo,fcorrmat);
end
close(h);