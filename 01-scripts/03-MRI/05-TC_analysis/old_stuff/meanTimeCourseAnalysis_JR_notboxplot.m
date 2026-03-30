function meanTimeCourseAnalysis_JR

% Jonathan Reinwald 02/2019 based on script by LW
% "meanTimeCourseAnalysis_JR" calculates the mean Timecourse for a
% specified region of interest (ROI), calculates means frame by frame for the different trials (sessionwise)
% and  then creates means throughout all sessions ...
% reults are plotted in the end ...


%% PREP

clear all; close all;

%% LOAD VARIABLES/STRUCTS ...

studydir='/home/jonathan.reinwald/Awake/data/fmri_data/'; cd(studydir)
outputdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__12regr_6rp_deriv__Licks__MASK_0';

% for loop over all sessions ...
load([studydir filesep 'filelist_awake_MAIN_JR.mat'], 'Pfunc');

% valid sessions - criterion: behavorial performance ...
array_valid_sessions= [1:83]%paradigm.performance_check.valid_sessions;


%% GET YOUR BINARY MASK FOR DEFINING YOUR ROI ...
% select as many masks as you want ... LOOP over all masks selected ...
cd('/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/');
% [Pmsk,~]=spm_select(Inf,'any','Select Mask',[],pwd,'.*..nii');
% Pmsk_all={'/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/AON_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/APC_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/NAc_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/OB_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/olf_tubercle_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/PPC_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/somatomotor_areas_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/ventral_striatum_inPax.nii','/home/jonathan.reinwald/Awake/atlas/REGIONS OF INTEREST/dorsal_striatum/dorsal_striatum_inPax.nii','/home/jonathan.reinwald/Awake/atlas/REGIONS OF INTEREST/Ectorhinal_area.nii','/home/jonathan.reinwald/Awake/atlas/REGIONS OF INTEREST/Perirhinal_area.nii'};
Pmsk_all={'/home/jonathan.reinwald/Awake/helpers/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/olf_tubercle_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/PPC_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/somatomotor_areas_inPax.nii','/home/jonathan.reinwald/Awake/atlas/Templates_Renee/Mouse_ROIs/unsmoothed/ventral_striatum_inPax.nii','/home/jonathan.reinwald/Awake/atlas/REGIONS OF INTEREST/dorsal_striatum/dorsal_striatum_inPax.nii','/home/jonathan.reinwald/Awake/atlas/REGIONS OF INTEREST/Ectorhinal_area.nii','/home/jonathan.reinwald/Awake/atlas/REGIONS OF INTEREST/Perirhinal_area.nii'};

Pmsk=char(Pmsk_all);

%% LOOP OVER MASKS SELECTED
for Nmask = 1:size(Pmsk,1)
    
    % get MASKname ...
    Pmsk_cur = Pmsk(Nmask,:);
    [~, fname_mask, ~]=fileparts(Pmsk_cur);
    fname_mask = strrep(fname_mask,'_',' ');
    
    % for analysis of residuals ...
    firstleveldir = '/home/jonathan.reinwald/Awake/stats_FirstLevel/FirstLevelResiduals__16regr_6rp_csf_FD_deriv__icaden25_16-Feb-2020__Licks__MASK_0';
    dirlist = dir(firstleveldir);
    dirlist = dirlist(contains({dirlist.name},'PD'));
    numbersess = numel(dirlist);
    
    %% SAVE PLOTS ...
    newdir = [outputdir filesep fname_mask];
    mkdir(newdir);
    addon = ' - 12 rps '
    
    %%  LET'S GETTING STARTED ...
    counter = 1; % create counter to avoid emtpy rows occuring when just using ix as index ...
    array_valid_sessions(74)=[];
    
    for ix=array_valid_sessions(1:end)
        
        ix
        run = counter
        
        %% PREP current session
        % get EPI path ...
        % [fdir, fname, ext]=fileparts(Pfunc{ix});
        % Pcur=spm_select('FpList', fdir , ['^s_wst_a_u_del5_' fname '_c1_c2t.nii']);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        
        % for analysis of residuals ...
        % info fmri sess
        
        subject = fdir(58:61);
        date = fname(5:10);
        % get sessiondir ...
        a = contains({dirlist.name}, date) & contains({dirlist.name}, [num2str(subject)]);
        dir_residuals = dirlist(find(a ==1)).name;
        sessiondir = [firstleveldir filesep dir_residuals filesep 'rp_der'];
        
        % select ...
        Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_' dir_residuals '.nii']);
%         Pcur=spm_select('FPlist',fdir,['^s_rwst_a1_u_del5_' fname '_c1_c2t_icaden25_16-Feb-2020.nii$']);
        
        %% get meanTc of current session ...
        
        [tc roidata]=wwf_roi_tcours_old(Pmsk_cur,Pcur);
        
        
        %% modify tc ...
        
        % detrend data ...
        tc_detr = detrend(tc);
        
        % normalize data ..
        tc_detr_norm = zscore(tc_detr);
        
        %% parse different odors
        
        % get volumes in which odor exposition takes place ...
        % new approach: ceil ...
        TR = 1.2;
        
        load(['/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fMRI_new_mat_sorted/' fname(1:11) '_' fdir(58:61) '_protocol_new.mat']);
        
        % define number of frames you want to add to the odor volume for analysis per trial ...
        Nfr = 6;
        
        %% Using all rewarded/non-rewarded trials independent of post-licks
        % tc values are saved in matrix_nonrew and matrix_rew;
        % rows = trials, columns = frames
        odoronset_rew = ceil([events.fv_on_del5]/(TR));
        odoronset_rew_precise = ([events.fv_on_del5]/(TR));
        
        matrix_tc = []; % clear variable ...
        
        for i = 1:numel(odoronset_rew)
            OnsetFrame_cur = odoronset_rew(i); % frame of odor exposition
            if OnsetFrame_cur <= 1 % occured in onse sess ...
                OnsetFrame_cur = 2;
            end
            Index_frames_cur = (OnsetFrame_cur-1):1:(OnsetFrame_cur+Nfr); % index
            
            % write tc values for current trial to matrix ...
            matrix_tc(i,:) = tc_detr_norm(Index_frames_cur);
        end
        
        load(['/home/jonathan.reinwald/Awake/RLModel/fMRI_data/MLE_Pav_Gauss_Hybrid_bc/RLM_OdorID_' num2str(ix) '.mat']);
        
        clear vector_expectation var_allexp
        
        if median(median(model.logdata(1:40,5))>0.5);
            varhigh=[model.logdata(1:40,5);model.logdata(41:80,6);model.logdata(81:120,5);model.logdata(121:160,6)];
            varhighsel=[(model.logdata(1:40,3)==1);(model.logdata(41:80,3)==2);(model.logdata(81:120,3)==1);(model.logdata(121:160,3)==2)];
            varlow=[model.logdata(1:40,6);model.logdata(41:80,5);model.logdata(81:120,6);model.logdata(121:160,5)];
            varlowsel=[(model.logdata(1:40,3)==2);(model.logdata(41:80,3)==1);(model.logdata(81:120,3)==2);(model.logdata(121:160,3)==1)];
        elseif median(median(model.logdata(1:40,6))>0.5);
            varhigh=[model.logdata(1:40,6);model.logdata(41:80,5);model.logdata(81:120,6);model.logdata(121:160,5)];
            varhighsel=[(model.logdata(1:40,3)==2);(model.logdata(41:80,3)==1);(model.logdata(81:120,3)==2);(model.logdata(121:160,3)==1)];
            varlow=[model.logdata(1:40,5);model.logdata(41:80,6);model.logdata(81:120,5);model.logdata(121:160,6)];
            varlowsel=[(model.logdata(1:40,3)==1);(model.logdata(41:80,3)==2);(model.logdata(81:120,3)==1);(model.logdata(121:160,3)==2)];
        end
        
        for jx=2:length(varhighsel);
            if varhighsel(jx)==1;
                var_allexp(jx)=varhigh(jx);
            elseif varlowsel(jx)==1;
                var_allexp(jx)=varlow(jx);
            end
        end
        
        for zx=1:8;
            [coef_RPE(ix,zx),pval_RPE(ix,zx)]=corr(matrix_tc(:,zx),model.logdata(:,8));
            [coef_dropornot(ix,zx),pval_dropornot(ix,zx)]=corr(matrix_tc(:,zx),[events.drop_or_not]');
            [coef_expect(ix,zx),pval_expect(ix,zx)]=corr(matrix_tc(:,zx),var_allexp');
        end;
        tc_matrix_all(ix,:,:)=matrix_tc;
        
        
        counter = counter +1;
    end
    
    mkdir([outputdir filesep fname_mask]);
    cd([outputdir filesep fname_mask]);
    save correlation_tc_to_event_output.mat coef_dropornot coef_RPE pval_dropornot pval_RPE tc_matrix_all coef_expect pval_expect
    
    f1=figure;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    
    
    subplot(1,3,1);
    ax=gca;
    ax.YLim=[-0.2 0.2];
    vfill([2-0.083,2.75],[0.8 0.9 0.9],'edgecolor',[0.9 0.9 0.9],'linestyle','--');
    ll=line([3.7 3.7],[-0.2 0.2]);
    ll.LineWidth=2;
    ll.Color=[0 0.5 0.5];
    text(3.8,-0.15,'Reward','Color',[0 0.5 0.5],'FontSize',14);
    text(2.8,-0.1,'Odor','Color',[0.6 0.7 0.7],'FontSize',14);
    
    title(['correlation: ' fname_mask ' to RPE'])
    [val,ind]=max(mean(coef_RPE));
    for kx=1:size(coef_RPE,2);
        [h_tt(kx),p_tt(kx),ci_tt{kx},stats_tt{kx}]=ttest2(coef_RPE(:,kx),coef_RPE(:,ind));
    end;
    
    h=notBoxPlot(coef_RPE);
    for sz=1:8;
        h(sz).data.MarkerSize=2;
    end;
    hold on;
    plot(nanmean(coef_RPE,1),'Color',[0 0 0],'LineWidth',2);
    ax.XLabel.String='[s], time bin: TR';
    ax.XLim=[1.5 8.5];
    ax.XTick=[0.5:1:8.5];
    ax.XTickLabel=[-1.2:1.2:8.4];
    ax.YLabel.String='correlation coefficient per time bin';
    
    for kx=1:size(coef_RPE,2);
        if p_tt(kx)<0.001;
            text(kx,val+0.1,'***');
        elseif p_tt(kx)<0.01;
            text(kx,val+0.1,'**');
        elseif p_tt(kx)<0.05;
            text(kx,val+0.1,'*');
        end;
    end;
    
    
    subplot(1,3,2);
    ax=gca;
    ax.YLim=[-0.5 0.5];
    vfill([2-0.083,2.75],[0.8 0.9 0.9],'edgecolor',[0.9 0.9 0.9],'linestyle','--');
    ll=line([3.7 3.7],[-0.5 0.5]);
    ll.LineWidth=2;
    ll.Color=[0 0.5 0.5];
    text(3.8,-0.15,'Reward','Color',[0 0.5 0.5],'FontSize',10);
    text(2.8,-0.1,'Odor','Color',[0.6 0.7 0.7],'FontSize',14);
    
    title(['mean BOLD ' fname_mask]);
    clear mean_tc_cur
    mean_tc_cur=squeeze(mean(tc_matrix_all,2))
    
    [val,ind]=max(mean(mean_tc_cur));
    for kx=1:size(mean_tc_cur,2);
        [h_tt(kx),p_tt(kx),ci_tt{kx},stats_tt{kx}]=ttest2(mean_tc_cur(:,kx),mean_tc_cur(:,ind));
    end;
    
    h=notBoxPlot(mean_tc_cur);
    for sz=1:8;
        h(sz).data.MarkerSize=2;
    end;
    hold on;
    plot(nanmean(mean_tc_cur,1),'Color',[0 0 0],'LineWidth',2);
    ax.XLabel.String='[s], time bin: TR';
    ax.XLim=[1.5 8.5];
    ax.XTick=[0.5:1:8.5];
    ax.XTickLabel=[-1.2:1.2:8.4];
    ax.YLabel.String='BOLD per time bin';
    
    for kx=1:size(mean_tc_cur,2);
        if p_tt(kx)<0.001;
            text(kx,val+0.3,'***');
        elseif p_tt(kx)<0.01;
            text(kx,val+0.3,'**');
        elseif p_tt(kx)<0.05;
            text(kx,val+0.3,'*');
        end;
    end;
    
    subplot(1,3,3);
    ax=gca;
    ax.YLim=[-0.4 0.4];
    vfill([2-0.083,2.75],[0.8 0.9 0.9],'edgecolor',[0.9 0.9 0.9],'linestyle','--');
    ll=line([3.7 3.7],[-0.4 0.4]);
    ll.LineWidth=2;
    ll.Color=[0 0.5 0.5];
    text(3.8,-0.3,'Reward','Color',[0 0.5 0.5],'FontSize',10);
    text(2.8,-0.25,'Odor','Color',[0.6 0.7 0.7],'FontSize',14);
    
    title(['correlation: ' fname_mask ' to expect(all)'])
    [val,ind]=max(mean(coef_dropornot));
    for kx=1:size(coef_dropornot,2);
        [h_tt(kx),p_tt(kx),ci_tt{kx},stats_tt{kx}]=ttest2(coef_dropornot(:,kx),coef_dropornot(:,ind));
    end;
    
    h=notBoxPlot(coef_dropornot);
    for sz=1:8;
        h(sz).data.MarkerSize=2;
    end;
    hold on;
    plot(nanmean(coef_dropornot,1),'Color',[0 0 0],'LineWidth',2);
    ax.XLabel.String='[s], time bin: TR';
    ax.XLim=[1.5 8.5];
    ax.XTick=[0.5:1:8.5];
    ax.XTickLabel=[-1.2:1.2:8.4];
    ax.YLabel.String='correlation coefficient per time bin';
    
    for kx=1:size(coef_dropornot,2);
        if p_tt(kx)<0.001;
            text(kx,val+0.3,'***');
        elseif p_tt(kx)<0.01;
            text(kx,val+0.3,'**');
        elseif p_tt(kx)<0.05;
            text(kx,val+0.3,'*');
        end;
    end;
    
    
    
    
    
    saveas(f1,[outputdir filesep fname_mask filesep 'correlation_' fname_mask '_resid.tiff']);
    close all;
end

