function res=do_aztec_awake_jr(Pfunc)
start=pwd;

if nargin < 1
    Pfunc=spm_select(inf, 'image', 'Functional data');
end

[fdir fname ext]=fileparts(Pfunc)

filter=['.*_aztec_data.log']

logfile=spm_select('FPList',fdir,filter )

Pfuncall=spm_select('ExtFPlist',fdir,['^' fname '.nii'],[1:1800]);

 %executeInner(logfile, funcfiles, FS_Phys, TR, only_retroicor, 1 / 128, output_dir);
 
 
 aztec_onlyHR(logfile,cellstr(Pfuncall),100,1.2, 0, 1/128, fdir);
 