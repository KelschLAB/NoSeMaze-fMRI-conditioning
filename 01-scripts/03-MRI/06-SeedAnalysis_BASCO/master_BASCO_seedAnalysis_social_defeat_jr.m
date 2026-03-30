%% master_BASCO_seedbasedAnalysis_social_defeat_jr.m
% Information:
%


%% Preparation
clear all;
close all;

%% Set pathes for scripts
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% Seed analysis path
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/06-SeedAnalysis_BASCO/'));

%% Preselection

% cormat
suffix_unsmoothed = 'v4'; % v2 (duration: 2.4s for all odors); v4 (duration: 0s for all odors)
cormat_selection_unsmoothed = ['cormat_' suffix_unsmoothed ];
suffix_smoothed = 'v3'; % v1 (duration: 2.4s for all odors); v3 (duration: 0s for all odors)
cormat_selection_smoothed = ['cormat_' suffix_smoothed ];

% general mask
Pmsk_general = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';

% select a high negative threshold NOT to exclude any data
threshold=-1000;

% Select seed region (e.g. masked activation from a 2nd-level GLM)
%% I:
if suffix_smoothed=='v1'
    mySuffix = 'v1';
elseif suffix_smoothed=='v3'
    mySuffix = 'v4';
end
P_seeds{1} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/cormat_v4/beta4D/combined_hemisphere/VP.nii';
P_seeds{2} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/cormat_v4/beta4D/separated_hemisphere/PallV_l.nii';
P_seeds{3} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/cormat_v4/beta4D/separated_hemisphere/PallV_r.nii';
P_seeds{4} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v10___COV_v1___ORTH_1___28-Apr-2023/secondlevel_Diff_Ranks_22_mice/CD1fam_Tr4to30/mask_corr_DiffRanksNeg_CD1fam4to30_T01.nii';
P_seeds{5} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v10___COV_v1___ORTH_1___28-Apr-2023/secondlevel_Diff_Ranks_22_mice/CD1fam_Tr4to30/mask_corr_DiffRanksNeg_CD1fam4to30_T001.nii';
P_seeds{6} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v10___COV_v1___ORTH_1___28-Apr-2023/secondlevel_Diff_Ranks_22_mice/CD1fam_Tr4to30_VS_CD1unk_Tr4to30/mask_corr_DiffRanksNeg_CD1famvsCD1unk4to30_T001.nii';
P_seeds{7} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v10___COV_v1___ORTH_1___28-Apr-2023/secondlevel_Diff_Ranks_22_mice/CD1fam_Tr4to30_VS_CD1unk_Tr4to30/mask_corr_DiffRanksNeg_CD1famvsCD1unk4to30_T01.nii';
P_seeds{8} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/cormat_v4/beta4D/separated_hemisphere/FundStr_l.nii';
P_seeds{9} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/cormat_v4/beta4D/separated_hemisphere/FundStr_r.nii';
% P_seeds{8} = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_' mySuffix '___COV_v1___ORTH_1___20-Jan-2023/secondlevel/CD1fam vs CD1unk/mask_activation_' mySuffix '_CD1famvsCD1unk_T01_extended.nii'];

%% I:
beta_selection_contains{1,1} = 'CD1-familiar_4to30'; beta_selection_contains{1,2} = '129-sv-female_4to30'; beta_selection_contains{1,3} = 'CD1-unknown_4to30';

%% Loop over seed regions
for ix=4:length(P_seeds)
    % clear
    clear beta_selection
    
    % Select beta-series suffix for comparison
    direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO' filesep cormat_selection_smoothed filesep 'beta4D'];
    [beta_list,~] = spm_select('FPListRec',direc,['^ZI_M11_betaseries_' suffix_smoothed '_.*.nii$']); % ZI_M11_ is just an exemplary animal to select the suffixes
    for jx=1:size(beta_list,1)
        find_idx = strfind(beta_list(jx,:),['betaseries_' suffix_smoothed '_']);
        start_idx = find_idx+length(['betaseries_' suffix_smoothed '_']);
        end_idx = strfind(beta_list(jx,:),'.nii')-1;
        beta_selection{jx} = beta_list(jx,start_idx:end_idx);
    end
    
    [~,seed_name,~]=fileparts(P_seeds{ix})
    
%     if ~isempty(beta_selection_contains{ix,2})
        beta_selection=beta_selection(strcmp(beta_selection,beta_selection_contains{1,1}) | strcmp(beta_selection,beta_selection_contains{1,2}) | strcmp(beta_selection,beta_selection_contains{1,3}));
%     elseif isempty(beta_selection_contains{ix,2})
%         beta_selection=beta_selection(contains(beta_selection,beta_selection_contains{1,1}));
%     end
    
    %% FIRSTLEVEL
    if 1==1
        %% Loop over beta selection
        for kx = 1:length(beta_selection)
            % Select beta-series
            direc_smoothed=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO' filesep cormat_selection_smoothed filesep 'beta4D'];
            P_betaseries_smoothed = spm_select('FPListRec',direc_smoothed,['^ZI_.*.' beta_selection{kx} '.nii$'])
            
            direc_unsmoothed=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO' filesep cormat_selection_unsmoothed filesep 'beta4D'];
            P_betaseries_unsmoothed = spm_select('FPListRec',direc_unsmoothed,['^ZI_.*.' beta_selection{kx} '.nii$'])
            
            P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'firstlevel' filesep beta_selection{kx} filesep ];
            if exist(P_outputdir_cur)~=7
                mkdir(P_outputdir_cur)
            end
            do_seedanalysis_firstlevel_jr(P_seeds{ix}, P_betaseries_unsmoothed, P_betaseries_smoothed, P_outputdir_cur, threshold, Pmsk_general)
        end
    end
    
    %% SECONDLEVEL
    if 1==1
        if length(beta_selection)>1
            %% Loop over beta selection
            for kx = 1:length(beta_selection)
                % Select beta-series suffix for comparison
                direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
                % Select beta-series Gr1
                P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{kx} '.nii$']);
                %
                if kx<length(beta_selection)
                    for hx=kx+1:length(beta_selection)
                        % Select beta-series suffix for comparison
                        direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
                        % Select beta-series Gr2 (for comparison)
                        P_betaseries_gr2 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{hx} '.nii$']);
                        
                        P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'secondlevel' filesep beta_selection{kx} '_VS_' beta_selection{hx}];
                        
                        % define contrasts
                        contrast.name{1} = [beta_selection{kx} ' > ' beta_selection{hx}];
                        contrast.val{1} = [1 -1];
                        contrast.name{2} = [beta_selection{kx} ' < ' beta_selection{hx}];
                        contrast.val{2} = [-1 1];
                        
                        % run 2nd level analysis
                        do_seedanalysis_secondlevel_jr(P_betaseries_gr1, P_betaseries_gr2, P_outputdir_cur, Pmsk_general, contrast)
                    end
                end
            end
        elseif length(beta_selection)==1
            direc=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep];
            % Select beta-series Gr1
            P_betaseries_gr1 = spm_select('FPListRec',direc,['^fCC_ZI.*.' beta_selection{kx} '.*.nii$']);
            
            P_outputdir_cur=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/09-seed_analysis' filesep 'unsmoothed_' cormat_selection_unsmoothed '_smoothed_' cormat_selection_smoothed filesep seed_name filesep 'secondlevel' filesep beta_selection{1}];
            if exist(P_outputdir_cur)~=7
                mkdir(P_outputdir_cur)
            end
            
            % define contrasts
            contrast.name{1} = [beta_selection{1} '_pos'];
            contrast.val{1} = [1];
            contrast.name{2} = [beta_selection{1} '_neg'];
            contrast.val{2} = [-1];
            contrast.name{3} = ['cov_pos'];
            contrast.val{3} = [0 1];
            contrast.name{4} = ['cov_neg'];
            contrast.val{4} = [0 -1];
            
            [seed_dir,~,~] = fileparts(P_seeds{ix-1});
            load(fullfile(seed_dir,'SPM.mat'))
            myCovariate.name = SPM.xC.rcname;
            myCovariate.val = SPM.xC.rc;
            
            % run 2nd level analysis
            do_seedanalysis_secondlevel_onewayTtestwithCov_jr(P_betaseries_gr1, P_outputdir_cur, Pmsk_general, contrast, myCovariate)
        end
    end
end














