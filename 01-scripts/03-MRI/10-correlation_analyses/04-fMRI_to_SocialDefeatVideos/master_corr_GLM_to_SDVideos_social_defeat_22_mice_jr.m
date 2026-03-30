%% master_corr_GLM_to_SDVideos_social_defeat_22_mice_jr.m
% Reinwald, Jonathan; 01/2021

%% Preparation
clear all;
% close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

%% Load regressors of interest
% Social hierarchy with David's Score
% Scans: AM1 at D36 and D37
% Scans: AM2 at D29 and D30
% ExplVar(1).name = 'DavidsScore';

%% social defeat data
% Load data
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/05-Social_Defeat_Videos/BehavData_22ANIMALS.mat');

% define input
VarNames = T.Properties.VariableNames;
% VarNames = VarNames(~contains(VarNames,{'DS','Rank','Animal'}));
VarNames = VarNames(contains(VarNames,{'all','All','vid'}));
for idx = 1:size(T,1);
    Animal_Number(idx,1) = str2num(T.Animal_Number{1}(2:end));
end

for varIdx = 1:length(VarNames)
    ExplVar(varIdx).name = VarNames{varIdx};
    ExplVar(varIdx).values = T.(VarNames{varIdx});
    ExplVar(varIdx).AnimalNumb = Animal_Number;
    ExplVar(varIdx).ID = T.Animal_ID;
end

%% Predefinitions for GLM selection
workDir = spm_select(1,'dir','Select Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for varIdx = 1:length(ExplVar)
    %% 1. Create output directory
    outputDir_secondlevel = [workDir filesep 'secondlevel_' ExplVar(varIdx).name '_22_mice'];
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
    
    do_secondlevel_GLM_to_NoSeMaze_22_mice_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask,ExplVar(varIdx))
end











