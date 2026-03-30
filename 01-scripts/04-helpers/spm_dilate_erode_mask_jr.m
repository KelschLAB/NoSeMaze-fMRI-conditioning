%P='/home/jonathan.reinwald/Output/Atlas/WhiteMatter_Atlas_18042018/WM_Atlas_18042018_inPax.nii'
%P='/home/jonathan.reinwald/Output/2016_12_TTA/Dorr_atlas/DLtemplate_brainmask_rs1x1x1.nii'

P='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_atlas_func_noBSnoCereb.nii'
V=spm_vol(P);
n_dilate=7;
n_erode=5;

img=spm_read_vols(V);
[path,fname,ext]=fileparts(P);
V.fname=fullfile(path, ['dilate_' num2str(n_dilate) 'erode_' num2str(n_erode) , fname, '.nii']);
for jx=1:n_dilate
    img = spm_dilate(img);
end
for jx=1:n_erode
    img = spm_erode(img);
end

spm_write_vol(V,img);
