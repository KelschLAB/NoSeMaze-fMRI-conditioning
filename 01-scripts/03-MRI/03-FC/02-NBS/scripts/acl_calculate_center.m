function [C, Cmm,  D] = acl_calculate_center(Patlas)
% C Center in voxels
% Cmm Center in mm in native space
% D Euclidean Distance
C=[];
Cmm=[];
D=[];
for i=1:size(Patlas,1)
    V=spm_vol(Patlas(i,:));
    atlas=spm_read_vols(V);
    s=unique(atlas(:));
    C=cat(3,C,zeros(numel(s)-1,3));
    Center=0*atlas;
    for j=2:numel(s)
        ROI=atlas==s(j);
        n=numel(find(ROI));
        BW=ROI;
        while n>1
            BW2 = bwperim(BW,8);
            n=numel(find(BW-BW2));
            if n==0
                break;
            end
            BW=BW-BW2;
        end
        n=numel(find(BW));
        
        [X1,X2,X3]=ind2sub(size(BW),find(BW));
        
        C(j-1,:,i)=mean([X1 X2 X3],1);
        Center(round(C(j-1,1,i)),round(C(j-1,2,i)),round(C(j-1,3,i)))=j;
    end
    
    
    M=spm_get_space(Patlas(i,:));
    Xmm=M*[C(:,:,i) ones(size(C,1),1)]';
    d=squareform(pdist(Xmm(1:3,:)', 'euclidean'));
    Cmm=cat(3,Cmm,Xmm(1:3,:)');
    D=cat(3,D,d);
    
    [p,f,e]=fileparts(Patlas(i,:));
    save(fullfile(p,strcat('eucdist_',f,'.mat')),'d')
    V.fname=fullfile(p,strcat('CentersROIS.nii'));
    spm_write_vol(V,Center)
end


