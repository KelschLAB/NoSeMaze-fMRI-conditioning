%% master_TC_analysis_jr
% Reinwald, Jonathan 06/2021
% "master_TC_analysis_jr" calculates the mean timecourse for specified regions
% of interest (ROIs)

% Preparation:
% Run master_GLM_residuals_jr.m before to create the residual nii-files

%% Preparation
clear all;
% close all;
clc;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts/toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts/MRTPrediction/fMRI/GLM'))
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts/MRTPrediction/fMRI/TC_analysis'))
addpath(genpath('/home/jonathan.reinwald/ICON_RPE/scripts/MRTPrediction/fMRI/preprocessing/EPI/general/framewise_displacement'))

% define paths and regressors/covariates ...
regressorsSuffix = '_v98.mat';
orth = 1;
covarSuffix = '_v2.mat';

% selection of EPI
epiPrefix = 'msk_s_rwst_a1_u_del5_';
% epiPrefix = 's_rwst_a1_u_del5_';
% epiPrefix = 's6_wave_10cons_med1000_msk_rwst_a1_u_del5_';
epiSuffix = '_c1_c2t';
% epiSuffix = '_c1_c2t_icaden25_16-Feb-2020';
% epiSuffix = '_c1_c2t_wds';

% general result directory
resultsDir = '/home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/TC_analysis/results';
% outputDirName
if contains(epiSuffix,'noise')
    outputDirName = [epiSuffix(end-4:end) '_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '____Orth_' num2str(orth)];
elseif contains(epiSuffix,'ica')
    outputDirName = ['EPI_ICA_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___Orth_' num2str(orth)];
elseif contains(epiPrefix,'wave')
    outputDirName = ['EPI_WD_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '____Orth_' num2str(orth)];
elseif ~contains(epiSuffix,'noise')
    outputDirName = ['EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '____Orth_' num2str(orth)];
end
% firstlevel directory
firstleveldir = [resultsDir filesep outputDirName filesep 'firstlevel_residuals'];
% CAVE: We need a second firstleveldir for v2 to get the RPs (not integrated in
% the covariate)
if contains(covarSuffix,'v2') | contains(covarSuffix,'v0')
    covarSuffix_help = '_v1.mat';
    if contains(epiSuffix,'noise')
        outputDirName_help = [epiSuffix(end-4:end) '_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix_help(2:3) '____Orth_' num2str(orth)];
    elseif contains(epiSuffix,'ica')
        outputDirName_help = ['EPI_ICA_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix_help(2:3) '___Orth_' num2str(orth)];
    elseif contains(epiPrefix,'wave')
        outputDirName_help = ['EPI_WD_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix_help(2:3) '____Orth_' num2str(orth)];
    elseif ~contains(epiSuffix,'noise')
        outputDirName_help = ['EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix_help(2:3) '____Orth_' num2str(orth)];
    end
    firstleveldir_help = [resultsDir filesep outputDirName_help filesep 'firstlevel_residuals'];
end

% protocol directory
protocol_dir = '/zi-flstorage/data/Jonathan/ICON_RPE/data/MRTPrediction/fMRI/preprocessing/fMRI_new_mat_sorted';

% sessect selection
sessions = [1:83];

% define odor delay
odor_delay = 0.5;

% definition of highresolution
highres_val = 6;

% load filelist and dstruct
load('/home/jonathan.reinwald/ICON_RPE/data/MRTPrediction/fMRI/filelists/filelist_awake_MAIN_JR.mat');
load('/home/jonathan.reinwald/ICON_RPE/data/MRTPrediction/fMRI/d_struct/dstruct_fMRI_MRTPrediction_22-Apr-2021.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------- FIRST-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select your binary masks for ROI-definitions
% select as many masks as you want
% cd('/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral');
% [Pmsk,~]=spm_select(Inf,'any','Select Mask',[],pwd,'.*..nii');
Pmsk_all={    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/olf_bulb_inPax_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/AON_inPax_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/APC_inPax_reduced.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/olf_tubercle_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/NAc_inPax_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/I_ventr.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/I_dors.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/PL.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/IL.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Atlas_Renee/rDLtemplate_original_inPax_brainmask.nii',....
    };
Pmsk=char(Pmsk_all);

%% Loop over selected masks
for Nmask = 4:(size(Pmsk,1)+1)
    % clearing
    clear tc_matrsess_all tc_matrsess_all_highres FD_matrsess_all FD_matrsess_all_highres CSF_matrsess_all CSF_matrsess_all_highres CSF_matrsess_all_highres_lin CSF_matrsess_all_highres_spline
    
    % Get mask name ... (for csf mask, this is done in the session loop)
    if Nmask <= size(Pmsk,1)
        Pmsk_cur = Pmsk(Nmask,:);
        [~, fname_mask, ~]=fileparts(Pmsk_cur);
        fname_mask = strrep(fname_mask,'_','');
    end
    
    % Define session path ...
    dirlist = dir(firstleveldir);
    dirlist = dirlist(contains({dirlist.name},'ZI_M'));
    numbersess = numel(dirlist);
    
    % Save directory ...
    if Nmask <= size(Pmsk,1)
        newdir = [resultsDir filesep outputDirName filesep 'meanTC' filesep fname_mask];
        mkdir(newdir);
    end
    % addon = ' - 12 rps '
    
    %%  LET'S GETTING STARTED ...
    for sess=sessions
        
        %% Preparation of current session
        % get sessiondir ...
        sessiondir = [firstleveldir filesep dirlist(sess).name];
        % get sessiondr_help if necessary (since v2 and v0 do not have RP,
        % which we need to calculate FD)
        if contains(covarSuffix,'v2') | contains(covarSuffix,'v0')
            sessiondir_help = [firstleveldir_help filesep dirlist(sess).name];
        end
        
        % select ...
        Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_' dirlist(sess).name '.nii']);
        
        Pcur='/home/jonathan.reinwald/ICON_RPE/analyses/MRTPrediction/fMRI/GLM/results/EPI_msk_s_rwst_a1_u___ROI_v1___COV_v1___14-Jun-2021/firstlevel/ZI_M181102A/beta_0018.nii'
        %/home/jonathan.reinwald/ICON_RPE/data/MRTPrediction/fMRI/preprocessing/fMRI_data/ZI_M181102A_PD01/8/regfilt_motcsfder_rwst_a1_u_del5_ZI_M181102A_1_1_20181102_083722_08_reorient_c1_c2t.nii';
        %% For CSF masks after (!) filtering (4D residuals after regression of CSF)
        % Get mask name ...
        if Nmask == size(Pmsk,1)+1
            [fdir, fname, ext]=fileparts(Pfunc{sess});
            % change pathes (/home to /zi-flstorage
            dir_name = '/home/jonathan.reinwald';
            fdir(1:length(dir_name)) = [];
            fdir = ['/zi-flstorage/data/Jonathan' fdir];
            % select mask
            Pmsk_cur=spm_select('FpList', fdir ,['^CSFreg.nii']);
            [~, fname_mask, ~]=fileparts(Pmsk_cur);
            fname_mask = strrep(fname_mask,'_','');
            
            newdir = [resultsDir filesep outputDirName filesep 'meanTC' filesep fname_mask];
            if exist(newdir) ~= 7
                mkdir(newdir);
            end
        end
        
        %% Get meanTc of current session ...
        
        [tc roidata]=wwf_roi_tcours_old(Pmsk_cur,Pcur);
        
        
        %% Modify tc ...
        
        % detrend data ...
        tc_detr = detrend(tc);
        
        % normalize data ..
        tc_detr_norm = tc;%zscore(tc_detr);
        
        %% Parse different odors
        % 1. find and load processed protocol file
        [fpath,fname,ext]=fileparts(Pfunc{sess});
        protocol_file = dir([protocol_dir filesep fname(1:11) '*_new.mat']);
        load([protocol_file.folder filesep protocol_file.name]);
        
        % 2. TR definition
        TR = 1.2;
        
        % 3. Define number of frames you want to add to the odor volume for analysis per trial ...
        TRs_after = 7;
        TRs_before = 2;
        
        %% Using all rewarded/non-rewarded trials independent of post-licks
        % tc values are saved in matrsess_nonrew and matrsess_rew;
        % rows = trials, columns = frames
        odoronset_rew = ceil(([events.fv_on_del5] + odor_delay)/(TR));
        odoronset_rew_precise = (([events.fv_on_del5] + odor_delay)/(TR));
        
        % highres
        odoronset_rew_highres = ceil(([events.fv_on_del5] + odor_delay)/(TR/highres_val));
        odoronset_rew_highres_precise = (([events.fv_on_del5] + odor_delay)/(TR/highres_val));
        
        licks_rew = ceil((vertcat(events.licks_del5))/(TR));
        licks_rew_precise = ((vertcat(events.licks_del5))/(TR));
        licks_rew_highres = ceil((vertcat(events.licks_del5))/(TR/highres_val));
        licks_rew_highres_precise = ((vertcat(events.licks_del5))/(TR/highres_val));
        
        tc_detr_norm_highres = nan(1,length(tc_detr_norm)*highres_val);
        tc_detr_norm_highres(1,1:highres_val:(length(tc_detr_norm)*highres_val)) = tc_detr_norm;
        
        matrsess_tc = []; % clear variable ...
        matrsess_FD_highres = [];
        
        % create FD matrix
        clear SPM rp_xX csf_xX
        if contains(covarSuffix,'v1')
            load([sessiondir filesep 'SPM.mat']);
            rp_xX = contains(SPM.xX.name,'rp') & ~contains(SPM.xX.name,'deriv');
            rp = SPM.xX.X(:,rp_xX);
            FD = SNiP_framewise_displacement(rp);
            csf_xX = contains(SPM.xX.name,'csf') & ~contains(SPM.xX.name,'deriv');
            csf = SPM.xX.X(:,csf_xX);
        elseif contains(covarSuffix,'v2') | contains(covarSuffix,'v0')
            load([sessiondir_help filesep 'SPM.mat']);
            rp_xX = contains(SPM.xX.name,'rp') & ~contains(SPM.xX.name,'deriv');
            rp = SPM.xX.X(:,rp_xX);
            FD = SNiP_framewise_displacement(rp);
            csf_xX = contains(SPM.xX.name,'csf') & ~contains(SPM.xX.name,'deriv');
            csf = SPM.xX.X(:,csf_xX);
        end
        
        % FD highres
        FD_highres = nan(1,length(FD)*highres_val);
        FD_highres(1,1:highres_val:(length(FD)*highres_val)) = FD;
        
        % csf highres
        csf_highres = nan(1,length(csf)*highres_val);
        csf_highres(1,1:highres_val:(length(csf)*highres_val)) = csf;
        
        matrsess_FD = []; % clear variable ...
        matrsess_FD_highres = [];
        
        matrsess_csf = []; % clear variable ...
        matrsess_csf_highres = [];
        
        for i = 1:numel(odoronset_rew)
            OnsetFrame_cur = odoronset_rew(i); % frame of odor exposition
            OnsetFrame_cur_highres = odoronset_rew_highres(i); % frame of odor exposition
            
            if OnsetFrame_cur <= 1 % occured in one sess ...
                OnsetFrame_cur = 2;
            end
            Index_frames_cur = (OnsetFrame_cur-TRs_before):1:(OnsetFrame_cur+TRs_after); % index
            %             Index_frames_cur = OnsetFrame_cur:1:(OnsetFrame_cur+Nfr);
            Index_frames_cur_highres = (OnsetFrame_cur_highres-(TRs_before*highres_val):1:(OnsetFrame_cur_highres+(highres_val-1)+TRs_after*highres_val)); % index
            %             Index_frames_cur_highres = OnsetFrame_cur_highres:1:(OnsetFrame_cur_highres+Nfr*highres_val); % index
            
            % find and write licks for current trial to matrsess ..
            for k = 1:length(Index_frames_cur)
                matrsess_licks(i,k)=sum(licks_rew==Index_frames_cur(k));
            end
            for k = 1:length(Index_frames_cur_highres)
                matrsess_licks_highres(i,k)=sum(licks_rew_highres==Index_frames_cur_highres(k));
            end
            
            % write tc values for current trial to matrsess ...
            matrsess_tc(i,:) = tc_detr_norm(Index_frames_cur);
            matrsess_tc_highres(i,:)=tc_detr_norm_highres(Index_frames_cur_highres);
            
            
            clear x y xx yy
            x = find(~isnan(tc_detr_norm_highres));
            y = tc_detr_norm_highres(x);
            xx = [1:1:size(tc_detr_norm_highres,2)];
            yy = spline(x,y,xx);
            matrsess_tc_highres_spline(i,:)=yy(Index_frames_cur_highres);
            yy2 = interp1q(x',y',xx');
            matrsess_tc_highres_lin(i,:)=yy2(Index_frames_cur_highres)';
            
            x = find(~isnan(csf_highres));
            y = csf_highres(x);
            xx = [1:1:size(csf_highres,2)];
            yy = spline(x,y,xx);
            matrsess_csf_highres_spline(i,:)=yy(Index_frames_cur_highres);
            yy2 = interp1q(x',y',xx');
            matrsess_csf_highres_lin(i,:)=yy2(Index_frames_cur_highres)';
            
            %             clear x y xx yy
            %
            %             x = find(~isnan(matrsess_tc_highres(i,:)));
            %             y = matrsess_tc_highres(i,x);
            %             xx = [1:1:size(matrsess_tc_highres,2)];
            %             yy = spline(x,y,xx);
            %             matrsess_tc_highres_spline2(i,:)=yy;
            %             yy2 = interp1q(x',y',xx');
            %             matrsess_tc_highres_lin2(i,:)=yy2';
            
            
            matrsess_FD(i,:) = FD(Index_frames_cur);
            matrsess_FD_highres(i,:)=FD_highres(Index_frames_cur_highres);
            
            matrsess_csf(i,:) = csf(Index_frames_cur);
            matrsess_csf_highres(i,:)=csf_highres(Index_frames_cur_highres);
        end
        
        tc_matrsess_all(sess,:,:)=matrsess_tc;
        tc_matrsess_all_highres(sess,:,:)=matrsess_tc_highres;
        tc_matrsess_all_highres_spline(sess,:,:)=matrsess_tc_highres_spline;
        tc_matrsess_all_highres_lin(sess,:,:)=matrsess_tc_highres_lin;
        tc_matrsess_info.highres = highres_val;
        tc_matrsess_info.TRs_before = TRs_before;
        tc_matrsess_info.TRs_after = TRs_after;
        tc_matrsess_info.OnsetFrame = TRs_before*highres_val+1;
        
        licks_matrsess_all(sess,:,:)=matrsess_licks;
        licks_matrsess_all_highres(sess,:,:)=matrsess_licks_highres;
        
        FD_matrsess_all(sess,:,:)=matrsess_FD;
        FD_matrsess_all_highres(sess,:,:)=matrsess_FD_highres;
        
        CSF_matrsess_all(sess,:,:)=matrsess_csf;
        CSF_matrsess_all_highres(sess,:,:)=matrsess_csf_highres;
        CSF_matrsess_all_highres_lin(sess,:,:)=matrsess_csf_highres_lin;
        CSF_matrsess_all_highres_spline(sess,:,:)=matrsess_csf_highres_spline;
    end
    
    save([newdir filesep 'tc_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'tc_matrsess_all','tc_matrsess_all_highres','tc_matrsess_all_highres_spline','tc_matrsess_all_highres_lin','tc_matrsess_info');
    save([newdir filesep 'FD_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'FD_matrsess_all','FD_matrsess_all_highres');
    save([newdir filesep 'licks_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'licks_matrsess_all','licks_matrsess_all_highres');
    save([newdir filesep 'csf_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'CSF_matrsess_all','CSF_matrsess_all_highres','CSF_matrsess_all_highres_lin','CSF_matrsess_all_highres_spline');
    
    newdir_rew = [resultsDir filesep outputDirName filesep 'meanTC_reward' filesep fname_mask];
    mkdir(newdir_rew);
    save([newdir_rew filesep 'tc_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'tc_matrsess_all','tc_matrsess_all_highres','tc_matrsess_all_highres_spline','tc_matrsess_all_highres_lin','tc_matrsess_info');
    save([newdir_rew filesep 'FD_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'FD_matrsess_all','FD_matrsess_all_highres');
    save([newdir_rew filesep 'licks_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'licks_matrsess_all','licks_matrsess_all_highres');
    save([newdir_rew filesep 'csf_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'CSF_matrsess_all','CSF_matrsess_all_highres','CSF_matrsess_all_highres_lin','CSF_matrsess_all_highres_spline');
    
    newdir_val = [resultsDir filesep outputDirName filesep 'meanTC_value' filesep fname_mask];
    mkdir(newdir_val);
    save([newdir_val filesep 'tc_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'tc_matrsess_all','tc_matrsess_all_highres','tc_matrsess_all_highres_spline','tc_matrsess_all_highres_lin','tc_matrsess_info');
    save([newdir_val filesep 'FD_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'FD_matrsess_all','FD_matrsess_all_highres');
    save([newdir_val filesep 'licks_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'licks_matrsess_all','licks_matrsess_all_highres');
    save([newdir_val filesep 'csf_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'CSF_matrsess_all','CSF_matrsess_all_highres','CSF_matrsess_all_highres_lin','CSF_matrsess_all_highres_spline');
end

