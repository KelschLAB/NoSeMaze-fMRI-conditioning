function res=wwf_fsl_cluster(Pstat,Pmask,T,p)
% function res=wwf_fsl_cluster(Pstat,Pmask,T,p)
% Function to apply cluster correction to a statistical map using fsl
% routines.
% INPUT:
% Pstat: Filename of statistical map (.nii or .nii.gz)
% Pmask: Name of Mask file e.g. brain mask (.nii or .nii.gz)
% T: T threshold for statistical significance (uncorrected)
%    either look up in table or use tinv(0.95,df) - onesided 
%    tinv(0.975,df) -twosided
% p: corrected p value (e.g. 0.05)
%
% OUTPUT:
% smoothest_[Pstat]_[Pmsak]_cluster_[T]_[p].txt:
%   Output of smoothenes estimation (DLH, Volume, RESELS)
% [Pstat]_[Pmsak]_clusterT_[T]_[p].nii:
%   Thresholded cluster corrected T-map
% [Pstat]_[Pmsak]_clusteri_[T]_[p].nii:
%   Image with the different cluster indezies
% [Pstat]_[Pmsak]_clusterT_[T]_[p]_log.txt:
%   textfile with cluster position table
% [Pstat]_[Pmsak]_clusterT_[T]_[p]_output.txt:
%   textfile with statistical Cluster information



if nargin < 1
    Pstat=spm_select(1,'any','Select statistical Image')
end
if nargin < 2
    Pmask=spm_select(1,'any','Select mask Image')
end

if nargin<3
    answer=inputdlg({'T-threshold','Corrected p'},'Input',1,{'1.721','0.05'});
    T=str2num(answer{1});
    p=str2num(answer{2});
end

[fpath, fname, ext]=fileparts(Pstat);
[mpath, mname, mext]=fileparts(Pmask);

Toutname=[fpath filesep fname '_' mname '_clusterT_' num2str(T) '_' num2str(p)];
ioutname=[fpath filesep fname '_' mname '_clusterI_' num2str(T) '_' num2str(p)];
smoothname=['smoothest_' fname '_' mname '_cluster_' num2str(T) '_' num2str(p) '.txt'];

% Pistat='/data2/jonathan/PsiAlc/analyses/functional_analyses/cormat/sigma_bilateral_atlas44_scrubFD05_ReoRes2/results/GlobConn/results/CorrToETOH/rho_sp.nii'
sysprompt=['smoothest -z ' Pstat ' -m ' Pmask ' > ' smoothname];
system(sysprompt);

 stxt=read_t2s(smoothname);
dlh=sscanf(stxt(1,:),'DLH %f');
vol=sscanf(stxt(2,:),'VOLUME %f');
% dlh=3;


sysprompt2=['cluster -i ' Pstat ' -t ' num2str(T) ' -p ' num2str(p) ' --dlh=' num2str(dlh) ' --minclustersize --volume=' num2str(vol) ...
    ' --oindex=' ioutname '.nii --othresh=' Toutname '.nii --mm --olmax=' Toutname '_log.txt > ' Toutname '_output.txt'];
%sysprompt2=['cluster -i ' Pstat ' -t ' num2str(T) ' -p ' num2str(p) ' --dlh=' num2str(dlh) ' --volume=' num2str(vol) ...
%    ' --oindex=testI.nii --othresh=test.nii --mm --olmax=' Toutname '_log.txt > ' Toutname '_output.txt'];
system(sysprompt2);


sysprompt2=['cluster -i ' Pstat ' -t ' num2str(-T) ' -p ' num2str(p) ' --dlh=' num2str(dlh) ' --volume=' num2str(vol) ...
    ' --oindex=' ioutname '_neg.nii --othresh=' Toutname '_neg.nii --mm --min --olmax=' Toutname '_neg_log.txt > ' Toutname '_neg_output.txt'];
%sysprompt2=['cluster -i ' Pstat ' -t ' num2str(T) ' -p ' num2str(p) ' --dlh=' num2str(dlh) ' --volume=' num2str(vol) ...
%    ' --oindex=testI.nii --othresh=test.nii --mm --olmax=' Toutname '_log.txt > ' Toutname '_output.txt'];
system(sysprompt2);

gunzip([ioutname '.nii.gz']);
delete([ioutname '.nii.gz']);
gunzip([ioutname '_neg.nii.gz']);
delete([ioutname '_neg.nii.gz']);
gunzip([Toutname '.nii.gz']);
delete([Toutname '.nii.gz']);
gunzip([Toutname '_neg.nii.gz']);
delete([Toutname '_neg.nii.gz']);

%smoothest -z dr_stage3_ic0008_tstat3.nii.gz -m ../../../atlas/3dMean_mask_func.nii > smoothest_tstat8_3.txt
