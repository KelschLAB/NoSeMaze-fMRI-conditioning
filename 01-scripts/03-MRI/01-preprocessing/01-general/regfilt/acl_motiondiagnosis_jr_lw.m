function [FD]=acl_motiondiagnosis_jr(EPI,thres,mask,outputdir)

threshold=thres

%EPI=spm_select('FPList',fullfile(fdir,'7'),strcat('^',prefix,'.*_reorient.nii'));

V=spm_vol(EPI);

%mask=spm_select('FPList',fullfile(fdir,'EPI','Masks'),'mask.nii');
% mask=spm_select('FPList',fdir,strcat('^',prefix,'.*_c1_c2_mask.nii'));
%mask='/home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/Atlas_Schwarz_new_template/3dMean_mask_func_res_binary.nii'
% mask='/home/jonathan.reinwald/matlab/data/2016.02_Social_Isolation/pvconverted_Data/movement_parameter/output.img'
% mask=mk_vol_NaNto0(mask)

Vmask=spm_vol(mask);
mask=spm_read_vols(Vmask);

mtx=spm_read_vols(V);
mtxsz=size(mtx);

mtx=reshape(mtx,prod(mtxsz(1:3)),prod(mtxsz(4)));

meanmtx=mean(mtx,2);

mask(isnan(mask))=0;
mtxfunc=mtx(find(mask & reshape(meanmtx,mtxsz(1:3))>300),:);
% mtxfunc=mtx(find(mask & reshape(meanmtx,mtxsz(1:3))),:);

% mtxfunc=mtx;

[fdir, ~, ~]=fileparts(EPI(1,:));
rp=spm_load(spm_select('FPList',fdir,'^rp_del5.*.reorient.txt')) ;
% detrending
for i=1:size(rp,2)
    [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
    tr=polyval(p,1:size(rp,1),[],mu);
    
    rp(:,i)=rp(:,i)-tr'; 
end

rp_corr=spm_load(spm_select('FPList',fdir,'^rp_wst.*.txt')) ;
% detrending
for i=1:size(rp_corr,2)
    [p,s,mu]=polyfit(1:size(rp_corr,1),rp_corr(:,i)',2);
    tr=polyval(p,1:size(rp_corr,1),[],mu);
    
    rp_corr(:,i)=rp_corr(:,i)-tr'; 
end

% cfg.ts=mtxfunc;
cfg.ts=mtxfunc';
%cfg.motionparam=spm_select('FPList',fdir,'^rp.*.reorient.txt');

%detrended data:
%fdir2=[fdir filesep 'Motion_diagnosis'];
%cfg.motionparam=spm_select('FPList',fdir,'^detrended_rp_del5.txt');

cfg.prepro_suite = 'spm';
cfg.infile = '';
cfg.vol=[];
cfg.plot = 0;
cfg.mask='';
        
[dvars,~]=bramila_dvars(cfg);
% [fwd,~]=bramila_framewiseDisplacement(cfg);
parameters = rp%load(cfg.motionparam);
[FD] = SNiP_framewise_displacement(parameters);
parameters_corr = rp_corr%load(cfg.motionparam);
[FD_corr] = SNiP_framewise_displacement(parameters_corr);
%mkdir(fdir,'Motion_diagnosis');

%dlmwrite(fullfile(fdir,'detrended_rp.txt'),rp,'delimiter','\t','precision','%.6f')
%dlmwrite(fullfile(fdir,'FWD.txt'),[FD],'delimiter','\t','precision','%.6f');
dlmwrite(fullfile(fdir,'DVARS.txt'),[dvars],'delimiter','\t','precision','%.6f');
%dlmwrite(fullfile(fdir,'Motion_diagnosis','rp_DVARS_FWD.txt'),[rp dvars FD],'delimiter','\t','precision','%.6f');

figure(10); 
% subplot(3,2,6);imagesc([fwd'>=(mean(fwd)+2*std(fwd));dvars'>=(mean(dvars)+2*std(dvars))]); set(gca,'ytick',1:2,'YtickLabel',{'FD' 'DVARS'})
subplot(3,2,6);imagesc([FD'>=threshold;dvars'>=(mean(dvars)+2*std(dvars))]); set(gca,'ytick',[1:2],'YtickLabel',{'FD' 'DVARS'})
xlimv=get(gca,'xlim');
subplot(3,2,1);plot(rp(:,1:3)/10);ylabel('Displacement (mm)'),xlim(xlimv);
subplot(3,2,3);plot(rp(:,4:6));ylabel('Rotation (Radians)'),xlim(xlimv);

subplot(3,2,2);plot([(FD)]);hold on; plot(repmat(mean(FD),size(FD)),'-k');hold on; plot([(FD_corr)],'color','r');hold on; plot(repmat(mean(FD_corr),size(FD_corr)),'-k','color','r');
% plot(repmat(mean(fwd)+2*std(fwd),size(fwd)),'--k'),xlim(xlimv);
plot(repmat(threshold,size(FD)),'--k'),xlim(xlimv),ylim([0 1]);
plot(repmat(0.05,size(FD)),'--k');
set(gca,'ytick',([min(ylim):0.05:max(ylim)]),'fontsize',6);
ylabel('FD (mm)');


subplot(3,2,4);plot(dvars);hold on; plot(repmat(mean(dvars),size(dvars)),'-k');
plot(repmat(mean(dvars)+2*std(dvars),size(dvars)),'--k'),xlim(xlimv),ylim([0 20]);
ylabel('DVARS (%)')

dvars_new=dvars(2:length(EPI));
subplot(3,2,5);plot(dvars_new);hold on; plot(repmat(mean(dvars_new),size(dvars_new)),'-k');
plot(repmat(mean(dvars_new)+2*std(dvars_new),size(dvars_new)),'--k'),xlim(xlimv),ylim([0 20]);
ylabel('DVARS (%)')

print('-dpsc',fullfile(outputdir,'DVARS_FWD') ,'-r400','-append')
close(figure(10))





