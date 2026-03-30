% load filelist
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')
end



for subj=1:length(Pfunc_reappraisal);
    %% Clearing
    clear FD
    
    %% Load RP and calculate FD
    [fpath, fname, ext]=fileparts(Pfunc_reappraisal{subj});
    rp=spm_load(spm_select('FPList',fpath,'^rp_del.*')) ;
    % detrending
    for i=1:size(rp,2)
        [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
        tr=polyval(p,1:size(rp,1),[],mu);
        rp(:,i)=rp(:,i)-tr';
    end
    [FD] = SNiP_framewise_displacement(rp);
    
    %% Selection of EPI
    epiPrefsubj{1} = 'med1000_msk_s6_wrst_a1_u_del5_';
    epiSuffsubj{1} = '_c1_c2t';
    epiPrefsubj{2} = 'wave_40cons_med1000_msk_s6_wrst_a1_u_del5_';
    epiSuffsubj{2} = '_c1_c2t_wds';
    epiPrefsubj{3} = 'wave_40cons_med1000_msk_s6_wrst_a1_u_del5_';
    epiSuffsubj{3} = '_c1_c2t_noise';
    saveSuffsubj{1} = 'original';
    saveSuffsubj{2} = 'wds';
    saveSuffsubj{3} = 'noise';
    
    %% Load SP (spike percentage)
    [fpath, fname, ext]=fileparts(Pfunc_reappraisal{subj});
    SP = load([fpath filesep 'wavelet' filesep epiPrefsubj{2} fname epiSuffsubj{1} '_SP.txt']);
    
    %% ----------- Preparation of input within loop -----------------------
    [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
    subjAbrev = fname(1:6)
    saveDir = [fdir filesep 'wavelet' filesep 'assessment'];
    if ~exist(saveDir)
        mkdir(saveDir);
    end    
    
    for epi_select = 1:length(epiPrefsubj);
              
        %% 1. Load functional data
        if contains(epiPrefsubj{epi_select},'wave');
            Pfuncall = spm_select('ExtFPlist',[fdir filesep 'wavelet'],['^' epiPrefsubj{epi_select} fname epiSuffsubj{epi_select} '.nii'],[1:2500]);
        elseif ~contains(epiPrefsubj{epi_select},'wave');
            Pfuncall = spm_select('ExtFPlist',fdir,['^' epiPrefsubj{epi_select} fname epiSuffsubj{epi_select} '.nii'],[1:2500]);
        end
        
        %% 2. Load image
        V=spm_vol(Pfuncall);
        img=spm_read_vols(V);
        
        % Timecours (per voxel)
        tc=reshape(img,size(img,1)*size(img,2)*size(img,3),size(img,4));
        
        %% 3. STD calculation (of tc per voxel) and writing into new image
        tc_std=std(tc');
        img_new=reshape(tc_std,size(img,1),size(img,2),size(img,3));
        V_new=V(1);
        if contains(epiPrefsubj{epi_select},'wave');
            [~, name, ext]=fileparts(V_new.fname);
            V_new.fname=[saveDir filesep 'STD_' saveSuffsubj{epi_select} '_' name '.nii'];
        elseif ~contains(epiPrefsubj{epi_select},'wave');
            [~, name, ext]=fileparts(V_new.fname);
            V_new.fname=[saveDir filesep 'STD_' saveSuffsubj{epi_select} '_' name '.nii'];        
        end  
        spm_write_vol(V_new,img_new);
        
        %% 4. FD correlation
        img_corr_FD=reshape(corr(tc',FD,'type','Pearson')*100,size(img,1),size(img,2),size(img,3));
        V_corr=V(1);
        if contains(epiPrefsubj{epi_select},'wave');
            [~, name, ext]=fileparts(V_corr.fname);
            V_corr.fname=[saveDir filesep 'FDcorr_' saveSuffsubj{epi_select} '_' name '.nii'];
        elseif ~contains(epiPrefsubj{epi_select},'wave');
            [~, name, ext]=fileparts(V_corr.fname);
            V_corr.fname=[saveDir filesep 'FDcorr_' saveSuffsubj{epi_select} '_' name '.nii'];        
        end  
        spm_write_vol(V_corr,img_corr_FD);
        
%         %% 4.1 Subgroup FD correlation
%         % 4.1.1 find and load processed protocol file
%         protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/processed_protocol_files';
%         [fpath,fname,ext]=fileparts(Pfunc_reappraisal{subj});
%         protocol_file = dir([protocol_dir filesep 'animal_' fname(5:6) filesep 'animal_' fname(5:6) '*.*']);
%         load([protocol_file.folder filesep protocol_file.name]);
%         
%         % border definition
%         border40 = ceil(events(41).fv_on_del5/1.2)-1;
%         
%         % 
%         img_corr_FD2=reshape(corr(tc(:,1:border40)',FD(1:border40),'type','Pearson')*100,size(img,1),size(img,2),size(img,3));
%         V_corr2=V(1);
%         if contains(epiPrefsubj{epi_select},'wave');
%             [~, name, ext]=fileparts(V_corr2.fname);
%             V_corr2.fname=[saveDir filesep 'FD1to40corr_' saveSuffsubj{epi_select} '_' name '.nii'];
%         elseif ~contains(epiPrefsubj{epi_select},'wave');
%             [~, name, ext]=fileparts(V_corr2.fname);
%             V_corr2.fname=[saveDir filesep 'FD1to40corr_' saveSuffsubj{epi_select} '_' name '.nii'];        
%         end          
%         spm_write_vol(V_corr2,img_corr_FD2);
%         
%         % border definition
%         border80 = ceil(events(81).fv_on_del5/1.2)-1;
% 
%         img_corr_FD3=reshape(corr(tc(:,(border40+1):border80)',FD((border40+1):border80),'type','Pearson')*100,size(img,1),size(img,2),size(img,3));
%         V_corr3=V(1);
%         if contains(epiPrefsubj{epi_select},'wave');
%             [~, name, ext]=fileparts(V_corr3.fname);
%             V_corr3.fname=[saveDir filesep 'FD41to80corr_' saveSuffsubj{epi_select} '_' name '.nii'];
%         elseif ~contains(epiPrefsubj{epi_select},'wave');
%             [~, name, ext]=fileparts(V_corr3.fname);
%             V_corr3.fname=[saveDir filesep 'FD41to80corr_' saveSuffsubj{epi_select} '_' name '.nii'];
%         end
%         spm_write_vol(V_corr3,img_corr_FD3);
        
        %% 5. SP correlation
        img_corr_SP=reshape(corr(tc',SP,'type','Pearson')*100,size(img,1),size(img,2),size(img,3));
        V_corr=V(1);
        if contains(epiPrefsubj{epi_select},'wave');
            [~, name, ext]=fileparts(V_corr.fname);
            V_corr.fname=[saveDir filesep 'SPcorr_' saveSuffsubj{epi_select} '_' name '.nii'];
        elseif ~contains(epiPrefsubj{epi_select},'wave');
            [~, name, ext]=fileparts(V_corr.fname);
            V_corr.fname=[saveDir filesep 'SPcorr_' saveSuffsubj{epi_select} '_' name '.nii'];        
        end  
        spm_write_vol(V_corr,img_corr_SP);
        
        %% Write meantc
        tc(tc==0)=nan;
        meantc.(saveSuffsubj{epi_select}) = nanmean(tc);
        meancorr.(saveSuffsubj{epi_select}).FD(subj) = nanmean(img_corr_FD(:));
        meancorr.(saveSuffsubj{epi_select}).SP(subj) = nanmean(img_corr_SP(:));        
% 
%         mask='/home/jonathan.reinwald/ICON_Autonomouse/data/reappraisal/fMRI/preprocessing/DARTEL/mask_template_6_polished.nii';
%         V_mask = spm_vol(mask);
%         img_mask = spm_read_vols(V_mask)
%         mask_mtx=reshape(img_mask,size(img,1)*size(img,2)*size(img,3),1);
%         
%         mtxfunc=tc(find(mask_mtx),:);
%         [VV,Stat]=DSEvars(mtxfunc,'scale',1/100,'verbose',1);
%         [DVARS,DVARS_Stat]=DVARSCalc(mtxfunc,'scale',1/100,'VarType','hIQR','TestMethod','X2','TransPower',1/3,'RDVARS','verbose',1);
%         
%         meantc.DVARS.(saveSuffsubj{epi_select})=[0 DVARS];
    end
    
    figure(2);
    subplot(2,3,2);
    plot(meantc.original,'Color',[0 0 0],'LineWidth',1); 
    ax=gca;
    ax.XLabel.String = 'Frames [TR = 1.2s]';
    ax.YLabel.String = 'normalized BOLD';
    ax.YLim = [900 ,1050];
    ax.XLim = [0,length(meantc.original)];
    title('Core Image (preprocessing only)');        
    
    subplot(2,3,4);
    plot(meantc.wds,'Color',[1 0 0],'LineWidth',1); 
    ax=gca;
    ax.XLabel.String = 'Frames [TR = 1.2s]';
    ax.YLabel.String = 'normalized BOLD';
    ax.YLim = [900 ,1050];
    ax.XLim = [0,length(meantc.original)];
    title('Wavelet-Despiked Image');        
    
    subplot(2,3,6);
    plot(meantc.noise,'Color',[0 0 1],'LineWidth',1);  
    ax=gca;
    ax.XLabel.String = 'Frames [TR = 1.2s]';
    ax.YLabel.String = 'normalized BOLD';
    ax.YLim = [900 ,1050];
    ax.XLim = [0,length(meantc.original)];
    title('Noise Image');     
    
    subplot(2,3,3);
    plot(FD,'Color',[0 0 0],'LineWidth',1);
    ax=gca;
    ax.XLabel.String = 'Frames [TR = 1.2s]';
    ax.YLabel.String = 'FD [mm]';
    ax.XLim = [0,length(meantc.original)];
    title('Framewise Displacement');        

    tt=suptitle(fname);
    tt.Interpreter='none';
    print('-dpsc',fullfile([saveDir filesep],'MeanTC_all.ps') ,'-r400','-append')

    %% Might be helpful to look on correlations between e.g. DVARS or FD and the meantc.original, meantc.wds, meantc.noise...
    
end    
    

    
    