%% master_TC_analysis_social_hierarchy_jr.m
% Reinwald, Jonathan 06/2021
% "master_TC_analysis_social_hierarchy_jr" calculates the mean timecourse for specified regions
% of interest (ROIs)

% Preparation:
% Run master_GLM_residuals_social_hierarchy_jr.m before to create the residual nii-files

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-TC_analysis'))

%% Preparation
clear all;
% close all;

% general result directory
resultsDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/08-TC_analysis/03-results');

% covar suffix
covarSuffix = '_v1.mat';

% definition whether to use der or not
DerDisp=[0 0];

% subject selection
subjects = [1:22];
sessions = [1:22];

% firstlevel directory
firstleveldir = [resultsDir filesep 'firstlevel'];

% protocol directory
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/01-processed_protocol_files';

% define odor delay
odor_delay = 0.7;

% definition of highresolution
highres_val = 6;

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------- FIRST-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select your binary masks for ROI-definitions
% select as many masks as you want
if 1==1
%     Pmsk_all={'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v24.nii',...
%     '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v22.nii',...
    
Pmsk_all={'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v22.nii',........
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v24.nii',........
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/AON.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_dors.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_ventr.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_post.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/OB.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/OF.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/APC_inPax_reduced.nii',....   
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Amyg.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Aud.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/CA.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Cing.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Cl.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/CP.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/DG.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/DPA.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Ect.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Ent.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/FP.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Gust.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Hyp.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/IC.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/IL.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/M1.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/M2.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/MB.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Nacc.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/NclR.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Otu.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/PAG.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Pall.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/ParAss.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Perih.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Periv.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Pir.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/PL.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Pons.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/RN.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/RS.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/S1.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/S2.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/SC.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Sept.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/SN.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Sub.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Temp.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Th_PM.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Th_SM.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/TT.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/V.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Visc.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/VP.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/VTA.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/ZI.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Atlas_Renee/rDLtemplate_original_inPax_brainmask.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/I_ventr.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/I_dors.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/PL.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/IL.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Atlas_Renee/rDLtemplate_original_inPax_brainmask.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/olf_bulb_inPax_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/AON_inPax_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/olf_tubercle_smoothed.nii',....
    '/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral/NAc_inPax_smoothed.nii',....
        };   
    Pmsk=char(Pmsk_all);
    
    %% Loop over selected masks
    for Nmask = 1:(size(Pmsk,1)+1)
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
            newdir = [resultsDir filesep 'meanTC' filesep fname_mask];
            mkdir(newdir);
        end
        % addon = ' - 12 rps '
        
        %%  LET'S GETTING STARTED ...
        for sess=sessions
            
            %% Preparation of current session
            % get sessiondir ...
            [fpath,fname,ext]=fileparts(Pfunc_social_hierarchy{sess});
            sessiondir = [firstleveldir filesep 'ZI_M' fname(5:6)];
            % % %         % get sessiondr_help if necessary (since v2 and v0 do not have RP,
            % % %         % which we need to calculate FD)
            % % %         if contains(covarSuffix,'v2') | contains(covarSuffix,'v0')
            % % %             sessiondir_help = [firstleveldir_help filesep dirlist(sess).name];
            % % %         end
            
            % select ...
            Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_ZI_M' fname(5:6) '.nii']);
            
            %% For CSF masks after (!) filtering (4D residuals after regression of CSF)
            % Get mask name ...
            if Nmask == size(Pmsk,1)+1
                [fdir, fname, ext]=fileparts(Pfunc_social_hierarchy{sess});
                
                % select mask
                Pmsk_cur=spm_select('FpList', fdir ,['^CSFreg.nii']);
                [~, fname_mask, ~]=fileparts(Pmsk_cur);
                fname_mask = strrep(fname_mask,'_','');
                
                newdir = [resultsDir filesep 'meanTC' filesep fname_mask];
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
            tc_detr_norm = zscore(tc_detr);
            
            %% Parse different odors
            % 1. find and load processed protocol file
            [fpath,fname,ext]=fileparts(Pfunc_social_hierarchy{sess});
            protocol_file = dir([protocol_dir filesep 'animal_' fname(5:6) filesep '*_new.mat']);
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
                
                % write tc values for current trial to matrsess ...
                matrsess_tc(i,:) = tc_detr_norm(Index_frames_cur);% - mean(tc_detr_norm(Index_frames_cur(1:TRs_before+1)));
                matrsess_tc_highres(i,:)=tc_detr_norm_highres(Index_frames_cur_highres);%- nanmean(tc_detr_norm_highres(Index_frames_cur_highres(1:(TRs_before+1)*highres_val)));
                
                
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
            
            %         puff_matrsess_all(sess,:)=[events.puff_or_not];
            
            tc_matrsess_all(sess,:,:)=matrsess_tc;
            tc_matrsess_all_highres(sess,:,:)=matrsess_tc_highres;
            tc_matrsess_all_highres_spline(sess,:,:)=matrsess_tc_highres_spline;
            tc_matrsess_all_highres_lin(sess,:,:)=matrsess_tc_highres_lin;
            tc_matrsess_info.highres = highres_val;
            tc_matrsess_info.TRs_before = TRs_before;
            tc_matrsess_info.TRs_after = TRs_after;
            tc_matrsess_info.OnsetFrame = TRs_before*highres_val+1;
            
            tc_matrsess(1).mat(sess,:,:) = tc_matrsess_all(sess,contains({events.case_name},'C57Bl6 low'),:)
            tc_matrsess(1).mat_highres(sess,:,:) = tc_matrsess_all_highres(sess,contains({events.case_name},'C57Bl6 low'),:)
            tc_matrsess(1).mat_highres_spline(sess,:,:) = tc_matrsess_all_highres_spline(sess,contains({events.case_name},'C57Bl6 low'),:)
            tc_matrsess(1).mat_highres_lin(sess,:,:) = tc_matrsess_all_highres_lin(sess,contains({events.case_name},'C57Bl6 low'),:)
            tc_matrsess(1).odor = 'C57Bl6 low';
            
            tc_matrsess(2).mat(sess,:,:) = tc_matrsess_all(sess,contains({events.case_name},'C57Bl6 high'),:)
            tc_matrsess(2).mat_highres(sess,:,:) = tc_matrsess_all_highres(sess,contains({events.case_name},'C57Bl6 high'),:)
            tc_matrsess(2).mat_highres_spline(sess,:,:) = tc_matrsess_all_highres_spline(sess,contains({events.case_name},'C57Bl6 high'),:)
            tc_matrsess(2).mat_highres_lin(sess,:,:) = tc_matrsess_all_highres_lin(sess,contains({events.case_name},'C57Bl6 high'),:)
            tc_matrsess(2).odor = 'C57Bl6 high';
            
             % FD
            FD_matrsess_all(sess,:,:)=matrsess_FD;
            FD_matrsess_all_highres(sess,:,:)=matrsess_FD_highres;
            
            FD_matrsess(1).mat(sess,:,:) = FD_matrsess_all(sess,contains({events.case_name},'C57Bl6 low'),:)
            FD_matrsess(1).mat_highres(sess,:,:) = FD_matrsess_all_highres(sess,contains({events.case_name},'C57Bl6 low'),:)
            FD_matrsess(1).odor = 'C57Bl6low';
            
            FD_matrsess(2).mat(sess,:,:) = FD_matrsess_all(sess,contains({events.case_name},'C57Bl6 high'),:)
            FD_matrsess(2).mat_highres(sess,:,:) = FD_matrsess_all_highres(sess,contains({events.case_name},'C57Bl6 high'),:)
            FD_matrsess(2).odor = 'C57Bl6high';
            
            CSF_matrsess_all(sess,:,:)=matrsess_csf;
            CSF_matrsess_all_highres(sess,:,:)=matrsess_csf_highres;
            CSF_matrsess_all_highres_lin(sess,:,:)=matrsess_csf_highres_lin;
            CSF_matrsess_all_highres_spline(sess,:,:)=matrsess_csf_highres_spline;
        end
        
        save([newdir filesep 'tc_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'tc_matrsess','tc_matrsess_all','tc_matrsess_all_highres','tc_matrsess_all_highres_spline','tc_matrsess_all_highres_lin','tc_matrsess_info');
        save([newdir filesep 'FD_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'FD_matrsess','FD_matrsess_all','FD_matrsess_all_highres');
        save([newdir filesep 'csf_matrsess_all_BINS' num2str(highres_val) '_TRsbefore' num2str(TRs_before) '.mat'],'CSF_matrsess_all','CSF_matrsess_all_highres','CSF_matrsess_all_highres_lin','CSF_matrsess_all_highres_spline');
        
    end
end



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
