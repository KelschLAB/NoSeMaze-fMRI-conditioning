%% master_corr_GLM_to_NoSeMazeSH_social_hierarchy_jr.m
% Reinwald, Jonathan; 01/2021

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

%% Load regressors of interest
%% Option 1: Normal Davids Score
% % Social hierarchy with David's Score
% ExplVar(1).name = 'DavidsScore';
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day1to43.mat','DS_info');
% DS_info1 = DS_info;
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to43.mat','DS_info');
% DS_info2 = DS_info;
% ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
% ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
%
% ExplVar(2).name = 'DavidsScore_Zscored';
% ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
% ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];

%% Option 2: Difference between Davids Score before social hierarchy task (10 days)
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',8,'ReadVariableNames', true);

% load different hierarchies
% animals in AM1 were scanned at different days (either D45 or D51)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day35to44.mat','DS_info');
DS_info1_35to44 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_35to44.DS]);
[~,Rank]=sort(Idx);
DS_info1_35to44.Rank = Rank;

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day41to50.mat','DS_info');
DS_info1_41to50 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_41to50.DS]);
[~,Rank]=sort(Idx);
DS_info1_41to50.Rank = Rank;

% animals in AM2 were scanned at D44 and D45
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day34to43.mat','DS_info');
DS_info2 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info2.DS]);
[~,Rank]=sort(Idx);
DS_info2.Rank = Rank;


clear info 
counter=1;
for idxT = 1:size(T,1)
    % add info on IDs
    if ~isempty(T.PairingHigh{idxT})
        info.ID_own{counter}=T.AnimalIDCombined{idxT};
        info.ID_highPair{counter}=T.PairingHigh{idxT};
        info.ID_lowPair{counter}=T.PairingLow{idxT};
        % add infos on Davids Score and Rank for NoSeMaze 1
        if T.Autonomouse(idxT)==1
            info.NoSeMaze(counter)=1;
            info.AnimalNumb(counter)=T.AnimalNumber(idxT);
            if contains(T.DaysToConsider{idxT},'44')
                info.DS_own(counter)=DS_info1_35to44.DS(strcmp(DS_info1_35to44.ID,info.ID_own{counter}));
                info.DS_highPair(counter)=DS_info1_35to44.DS(strcmp(DS_info1_35to44.ID,info.ID_highPair{counter}));
                info.DS_lowPair(counter)=DS_info1_35to44.DS(strcmp(DS_info1_35to44.ID,info.ID_lowPair{counter}));   
                info.Rank_own(counter)=DS_info1_35to44.Rank(strcmp(DS_info1_35to44.ID,info.ID_own{counter}));
                info.Rank_highPair(counter)=DS_info1_35to44.Rank(strcmp(DS_info1_35to44.ID,info.ID_highPair{counter}));
                info.Rank_lowPair(counter)=DS_info1_35to44.Rank(strcmp(DS_info1_35to44.ID,info.ID_lowPair{counter}));
            elseif contains(T.DaysToConsider{idxT},'50')
                info.DS_own(counter)=DS_info1_41to50.DS(strcmp(DS_info1_41to50.ID,info.ID_own{counter}));
                info.DS_highPair(counter)=DS_info1_41to50.DS(strcmp(DS_info1_41to50.ID,info.ID_highPair{counter}));
                info.DS_lowPair(counter)=DS_info1_41to50.DS(strcmp(DS_info1_41to50.ID,info.ID_lowPair{counter}));
                info.Rank_own(counter)=DS_info1_41to50.Rank(strcmp(DS_info1_41to50.ID,info.ID_own{counter}));
                info.Rank_highPair(counter)=DS_info1_41to50.Rank(strcmp(DS_info1_41to50.ID,info.ID_highPair{counter}));
                info.Rank_lowPair(counter)=DS_info1_41to50.Rank(strcmp(DS_info1_41to50.ID,info.ID_lowPair{counter}));
            end
            info.DS_DiffHigh(counter)=info.DS_highPair(counter)-info.DS_own(counter);
            info.DS_DiffLow(counter)=info.DS_lowPair(counter)-info.DS_own(counter);
            info.Rank_DiffHigh(counter)=info.Rank_highPair(counter)-info.Rank_own(counter);
            info.Rank_DiffLow(counter)=info.Rank_lowPair(counter)-info.Rank_own(counter);
            counter=counter+1;
            % add infos on Davids Score and Rank for NoSeMaze 2
        elseif T.Autonomouse(idxT)==2
            info.NoSeMaze(counter)=2;
            info.AnimalNumb(counter)=T.AnimalNumber(idxT);
            info.DS_own(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_own{counter}));
            info.DS_highPair(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_highPair{counter}));
            info.DS_lowPair(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_lowPair{counter}));
            info.Rank_own(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_own{counter}));
            info.Rank_highPair(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_highPair{counter}));
            info.Rank_lowPair(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_lowPair{counter}));
            info.DS_DiffHigh(counter)=info.DS_highPair(counter)-info.DS_own(counter);
            info.DS_DiffLow(counter)=info.DS_lowPair(counter)-info.DS_own(counter);
            info.Rank_DiffHigh(counter)=info.Rank_highPair(counter)-info.Rank_own(counter);
            info.Rank_DiffLow(counter)=info.Rank_lowPair(counter)-info.Rank_own(counter);
            counter=counter+1;
        end
    end
end

ExplVar(1).name = 'DS_highPair';
ExplVar(1).values = info.DS_highPair';
ExplVar(1).ID = info.ID_own;

ExplVar(2).name = 'DS_lowPair';
ExplVar(2).values = info.DS_lowPair';
ExplVar(2).ID = info.ID_own;

ExplVar(3).name = 'DS_highPair_vs_DS_lowPair';
ExplVar(3).values = info.DS_highPair'-info.DS_lowPair';
ExplVar(3).ID = info.ID_own;

ExplVar(4).name = 'DS_DiffHighPair';
ExplVar(4).values = info.DS_DiffHigh';
ExplVar(4).ID = info.ID_own;

ExplVar(5).name = 'DS_DiffLowPair';
ExplVar(5).values = info.DS_DiffLow';
ExplVar(5).ID = info.ID_own;

ExplVar(6).name = 'DS_own';
ExplVar(6).values = info.DS_own';
ExplVar(6).ID = info.ID_own;

ExplVar(7).name = 'Rank_highPair';
ExplVar(7).values = info.Rank_highPair';
ExplVar(7).ID = info.ID_own;

ExplVar(8).name = 'Rank_lowPair';
ExplVar(8).values = info.Rank_lowPair';
ExplVar(8).ID = info.ID_own;

ExplVar(9).name = 'Rank_highPair_vs_Rank_lowPair';
ExplVar(9).values = info.Rank_highPair'-info.Rank_lowPair';
ExplVar(9).ID = info.ID_own;

ExplVar(10).name = 'Rank_DiffHighPair';
ExplVar(10).values = info.Rank_DiffHigh';
ExplVar(10).ID = info.ID_own;

ExplVar(11).name = 'Rank_DiffLowPair';
ExplVar(11).values = info.Rank_DiffLow';
ExplVar(11).ID = info.ID_own;

ExplVar(12).name = 'Rank_own';
ExplVar(12).values = info.Rank_own';
ExplVar(12).ID = info.ID_own;



%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/03-results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = [6,12]%1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [workDir filesep 'secondlevel_' ExplVar(varIdx).name ];
    if ~exist(outputDir_secondlevel)
        mkdir(outputDir_secondlevel)
    end
    
    %% 2. Load contrast_names.mat
    load([workDir filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
    
    %% 3. Explicit mask
    %     explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6.nii';
    explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
    
    
    %% 4. Define firstlevel-result directory
    firstlevelDir = [workDir filesep 'firstlevel'];
    
    do_secondlevel_GLM_to_NoSeMaze_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))
end











