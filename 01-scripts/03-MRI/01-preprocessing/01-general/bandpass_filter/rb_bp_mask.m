function [res]= rb_bp_mask(P,TR,lowfq,highfq,Pmask)
%function [res]= wwf_bandpath(P,TR,lowfq,highfq);

if nargin < 1
    P=spm_select(1,'any','Select data to filter', [],pwd, '.*.nii');
end

if nargin <3 
    prompt=inputdlg({'TR','Low Frequency','High Frequency'},'',1, {'1.7','0.01','0.1'});
    TR=str2num(prompt{1});
    lowfq=str2num(prompt{2});
    highfq=str2num(prompt{3});
end

% tmpname='wwf_bp_tmp.nii';
% nimg=size(P,1);
% Vi=spm_vol(P);
% Vo=Vi;
% for n=1:nimg;
%     Vo(n).fname=tmpname;
%     Vo(n).private.timing.toffset=0;
%     Vo(n).private.timing.tspace=1.7;
%     Vo(n)=spm_write_vol(Vo(n),spm_read_vols(Vi(n)));
% end

%3dBandpass
prefix='BP_temp';
% from Roberts version:
% if nargin <5
%     syscmd=sprintf('3dBandpass -dt %f -prefix %s -despike -blur 4 %f %f %s  ',TR,prefix,lowfq,highfq,P);
% else
%     syscmd=sprintf('3dBandpass -dt %f -mask %s -prefix %s %f %f %s',TR,Pmask,prefix,lowfq,highfq,P);
% end

% from ancient version from Wolfgang:
if nargin <5
    syscmd=sprintf('3dBandpass -nodetrend -dt %f -prefix %s %f %f %s',TR,prefix,lowfq,highfq,P);
else
    syscmd=sprintf('3dBandpass -dt %f -mask %s -prefix %s %f %f %s',TR,Pmask,prefix,lowfq,highfq,P);
end
system(syscmd)


[fpath fname fext]=fileparts(P);

%nind=findstr(fnameorig, '_');
%fname=fnameorig(nind(1)+1:end);

outname=[fpath filesep 'bp_' num2str(lowfq) '_' num2str(highfq) '_' fname];
afniname=[pwd filesep prefix '+tlrc'];
% afniname=[pwd filesep prefix '+orig'];
syscmd=sprintf('3dAFNItoNIFTI -prefix %s %s',outname, afniname);
system(syscmd);
%Remove temp files
delete([afniname '*']);
% Create mean image
display('Creating mean image');
Vi=spm_vol(P);
Vo=Vi(1);
outmean=[fpath filesep 'mean_temp.nii'];
Vo.fname=outmean;
flags={1,0,0};
Vmean=spm_imcalc(Vi,Vo,'mean(X)',flags);
% Add mean to filtered data
display('Adding mean image');
Vi=spm_vol([outname fext]);
mean_mtx=spm_read_vols(Vmean);
immtx=spm_read_vols(Vi);
outnew=[fpath filesep 'bpm_'  num2str(lowfq) '_' num2str(highfq) '_' fname fext];
for n=1:length(Vi);
    Vo=Vi(n);
    Vo.fname=outnew;
    spm_write_vol(Vo, squeeze(immtx(:,:,:,n))+mean_mtx);
end
res=Vo.fname



