%% master_corr_meanSeedBasedFC_to_NoSeMazeSH_reappraisal_jr.m
% Reinwald, Jonathan
% last update: 02/2023
% Script for calculating and plotting of mean betas

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %%
% mask_*.nii-files are needed before for the definition of the region of interest, e.g., the "PAG blop"
% --> save them in your seed-based FC folders beforehand

% Preparation
clear all
clc
close all

% Select GLM analysis for FC calculation
GLMdir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/09-seed_analysis/'
workDir = spm_select(1,'dir','Select Directory with mask_*',{},GLMdir);
GLM2ndlevel_dir = fullfile(workDir,'secondlevel');
GLM1stlevel_dir = fullfile(workDir,'firstlevel');

% List of regions
contrastlist = dir(GLM2ndlevel_dir);
% delete ./..
contrastlist = contrastlist(~contains({contrastlist.name},'.'));

%% Load NoSeMaze input (social hierarchy and chasing data)
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% load different hierarchies
% animals in AM1 were scanned at different days (either D45 or D51)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day3to16_12mice_withChasing.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info1_3to16 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info1_3to16.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_3to16.Rank = Rank;
DS_info1_3to16.DSzscored = zscore([DS_info1_3to16.DS]);
% chasing
DSchasing_info1_3to16 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_3to16.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info1_3to16.Rank = Rank;
DSchasing_info1_3to16.DSzscored = zscore([DSchasing_info1_3to16.DS]);

load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day8to21_12mice_withChasing.mat','DS_info','DS_info_chasing');
DS_info1_8to21 = DS_info;
clear Idx Rank
% tube hierarchy
[~,Idx]=sort([DS_info1_8to21.DS],'descend');
[~,Rank]=sort(Idx);
DS_info1_8to21.Rank = Rank;
DS_info1_8to21.DSzscored = zscore([DS_info1_8to21.DS]);
% chasing
DSchasing_info1_8to21 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info1_8to21.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info1_8to21.Rank = Rank;
DSchasing_info1_8to21.DSzscored = zscore([DSchasing_info1_8to21.DS]);

% animals in AM1 were scanned at different days (either D44 and D45)
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14_12mice_withChasing.mat','DS_info','DS_info_chasing');
% tube hierarchy
DS_info2 = DS_info;
clear Idx Rank
[~,Idx]=sort([DS_info2.DS],'descend');
[~,Rank]=sort(Idx);
DS_info2.Rank = Rank;
DS_info2.DSzscored = zscore([DS_info2.DS]);
% chasing
DSchasing_info2 = DS_info_chasing;
clear Idx Rank
[~,Idx]=sort([DSchasing_info2.DS],'descend');
[~,Rank]=sort(Idx);
DSchasing_info2.Rank = Rank;
DSchasing_info2.DSzscored = zscore([DSchasing_info2.DS]);

clear info
counter=1;
for idxT = 1:size(T,1)
    % add info on IDs
    info.ID_own{counter}=T.AnimalIDCombined{idxT};
    % add infos on Davids Score and Rank for NoSeMaze 1
    if T.Autonomouse(idxT)==1
        info.NoSeMaze(counter)=1;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        if contains(T.DaysToConsider{idxT},'16')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_3to16.DS(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_3to16.Rank(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_3to16.DSzscored(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_3to16.DS(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_3to16.Rank(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_3to16.DSzscored(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
        elseif contains(T.DaysToConsider{idxT},'21')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_8to21.DS(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_8to21.Rank(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_8to21.DSzscored(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_8to21.DS(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_8to21.Rank(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_8to21.DSzscored(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
        end
        counter=counter+1;
        % add infos on Davids Score and Rank for NoSeMaze 2
    elseif T.Autonomouse(idxT)==2
        info.NoSeMaze(counter)=2;
        info.AnimalNumb(counter)=T.AnimalNumber(idxT);
        % tube hierarchy
        info.DS_own(counter)=DS_info2.DS(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.Rank_own(counter)=DS_info2.Rank(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.DSzscored_own(counter)=DS_info2.DSzscored(strcmp(DS_info2.ID,info.ID_own{counter}));
        % chasing
        info.DS_chasing(counter)=DSchasing_info2.DS(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.Rank_chasing(counter)=DSchasing_info2.Rank(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.DSzscored_chasing(counter)=DSchasing_info2.DSzscored(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        counter=counter+1;
    end
end

ExplVar(1).name = 'DavidsScore';
ExplVar(1).values = info.DS_own';
ExplVar(1).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_own','descend');
ExplVar(1).DS_sorted = DSv;
ExplVar(1).DS_sortedIndex = DSi;

ExplVar(2).name = 'Rank';
ExplVar(2).values = info.Rank_own';
ExplVar(2).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_own','descend');
ExplVar(2).DS_sorted = DSv;
ExplVar(2).DS_sortedIndex = DSi;

ExplVar(3).name = 'DavidsScore_zscored';
ExplVar(3).values = info.DSzscored_own';
ExplVar(3).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_own','descend');
ExplVar(3).DS_sorted = DSv;
ExplVar(3).DS_sortedIndex = DSi;

ExplVar(4).name = 'DavidsScoreChasing';
ExplVar(4).values = info.DS_chasing';
ExplVar(4).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DS_chasing','descend');
ExplVar(4).DS_sorted = DSv;
ExplVar(4).DS_sortedIndex = DSi;

ExplVar(5).name = 'RankChasing';
ExplVar(5).values = info.Rank_chasing';
ExplVar(5).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.Rank_chasing','descend');
ExplVar(5).DS_sorted = DSv;
ExplVar(5).DS_sortedIndex = DSi;

ExplVar(6).name = 'DavidsScoreChasing_zscored';
ExplVar(6).values = info.DSzscored_chasing';
ExplVar(6).ID = info.ID_own;
%%%%% David's score plot
[DSv,DSi]=sort(info.DSzscored_chasing','descend');
ExplVar(6).DS_sorted = DSv;
ExplVar(6).DS_sortedIndex = DSi;

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for varIdx=1:length(ExplVar)
    for jx=1:length(ExplVar(varIdx).ID)
        ExplVar(varIdx).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(varIdx).ID(jx))).AnimalNumb;
    end
end

%% Loop over contrasts
for cix = 1:length(contrastlist)
    
    % go to directory
    cd(fullfile(contrastlist(cix).folder,contrastlist(cix).name));
    
    %% 1. Check for pre-existing masks
    clear masklist
    % List of regions
    masklist = dir(fullfile(contrastlist(cix).folder,contrastlist(cix).name));
    % delete ./..
    masklist = masklist(contains({masklist.name},'mask_') & contains({masklist.name},'.nii'));
    
    %% Only if masks exists, the following is running!
    if ~isempty(masklist)
        
        % Loop over masks
        for mx = 1:length(masklist)
            
            % mask
            P_mask = fullfile(masklist(mx).folder,masklist(mx).name);
            
            % Calculation of mean values
            V_mask = spm_vol(P_mask);
            img_mask = spm_read_vols(V_mask);
            img_mask(img_mask==0)=nan;
            img_mask(img_mask>0)=1;
            
            %% Calculation is only performed if the image file (mask) contains values
            if nansum(nansum(nansum(img_mask)))>0
                load(fullfile(masklist(mx).folder,'SPM.mat'));
                
                % Option 1: Contrast without diff
                if ~contains(masklist(mx).folder,'diff')
                    
                    clear res
                    SPM_input_files = {SPM.xY.VY.fname};
                    [~,fname,~]=fileparts(masklist(mx).folder);
                    str_=strfind(fname,'_VS_');
                    contrast{1}=fname(1:(str_-1));
                    contrast{2}=fname((str_+4):end);
                    
                    SPM_input_files_contrast1 = SPM_input_files(contains(SPM_input_files,contrast{1}));
                    SPM_input_files_contrast2 = SPM_input_files(contains(SPM_input_files,contrast{2}));
                    
                    for subj = 1:length(SPM_input_files_contrast1)
                        
                        P=SPM_input_files_contrast1{subj};
                        V=spm_vol(P);
                        img1=spm_read_vols(V);
                        clear temp_img
                        temp_img = img1.*img_mask;
                        res.(['mean_FC_' contrast{1}])(subj) = nanmean(temp_img(:));
                        %                     res.mean_betaPos(ix) = nanmedian(nanmedian(nanmedian(img1.*img_mask)));
                        
                        P=SPM_input_files_contrast2{subj};
                        V=spm_vol(P);
                        img2=spm_read_vols(V);
                        clear temp_img
                        temp_img = img2.*img_mask;
                        res.(['mean_FC_' contrast{2}])(subj) = nanmean(temp_img(:));
                        %                     res.mean_betaPos(ix) = nanmedian(nanmedian(nanmedian(img2.*img_mask)));
                    end
                    
                    % Option 2: Contrast without diff
                elseif contains(masklist(mx).folder,'diff')
                    
                    clear res
                    SPM_input_files = {SPM.xY.VY.fname};
                    [~,fname,~]=fileparts(masklist(mx).folder);
                    
                    contrast{1} = 'TPnoPuff11to40';
                    contrast{2} = 'TPnoPuff81to120';
                    
                    fCC_block1_workDir = fullfile(GLM1stlevel_dir,contrast{1},'/fCC');
                    fCC_files_block1 = spm_select('ExtFPListRec', fCC_block1_workDir, '^fCC.*.nii');
                    
                    fCC_block3_workDir = fullfile(GLM1stlevel_dir,contrast{2},'/fCC');
                    fCC_files_block3 = spm_select('ExtFPListRec', fCC_block3_workDir, '^fCC.*.nii');
                    
                    SPM_input_files_contrast1 = cellstr(fCC_files_block1);
                    SPM_input_files_contrast2 = cellstr(fCC_files_block3);
                    
                    for subj = 1:length(SPM_input_files)
                        
                        P=SPM_input_files{subj};
                        V=spm_vol(P);
                        img=spm_read_vols(V);
                        clear temp_img
                        temp_img = nanmean(nanmean(nanmean(img.*img_mask)));
                        res.(['mean_FC_' fname])(subj) = nanmean(temp_img(:));
                        res.(['median_FC_' fname])(subj) = nanmedian(temp_img(:));
                        %                     res.mean_betaPos(ix) = nanmedian(nanmedian(nanmedian(img_pos.*img_mask)));
                        
                        P=SPM_input_files_contrast1{subj};
                        V=spm_vol(P);
                        img1=spm_read_vols(V);
                        clear temp_img1
                        temp_img1 = nanmean(nanmean(nanmean(img1.*img_mask)))
                        res.(['mean_FC_' contrast{1}])(subj) = nanmean(temp_img1(:));
                        res.(['median_FC_' contrast{1}])(subj) = nanmedian(temp_img1(:));
                        %                     res.mean_betaPos(ix) = nanmedian(nanmedian(nanmedian(img_pos.*img_mask)));
                        
                        P=SPM_input_files_contrast2{subj};
                        V=spm_vol(P);
                        img2=spm_read_vols(V);
                        clear temp_img2
                        temp_img2 = nanmean(nanmean(nanmean(img2.*img_mask)))
                        res.(['mean_FC_' contrast{2}])(subj) = nanmean(temp_img2(:));
                        res.(['median_FC_' contrast{2}])(subj) = nanmedian(temp_img2(:));
                    end
                end
                %% PLOTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% ANALYSIS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% Loop over ExplVar
                for varIdx = 1:length(ExplVar)
                    
                    %% Create output directory
                    [~,mask_name,~]=fileparts(masklist(mx).name);
                    outputDir = fullfile(workDir,'corr_SocialHierarchy',[contrast{1} 'VS' contrast{2}],[ExplVar(varIdx).name]);
                    if ~exist(outputDir)
                        mkdir(outputDir)
                    end
                    
                    % figure
                    fig(varIdx)=figure('visible', 'off');
                    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
                    
                    %% Load and calculate FC difference (BOLD)
                    FC_diff = [res.(['median_FC_' contrast{2}])]'-[res.(['mean_FC_' contrast{1}])]';
                    FC_bl1 = [res.(['median_FC_' contrast{1}])]';
                    FC_bl3 = [res.(['median_FC_' contrast{2}])]';
                    
                    
                    %% Sort NoSeMaze variable
                    [~,sortIdx]=sort(ExplVar(varIdx).AnimalNumb);
                    NoSeMaze_input = ExplVar(varIdx).values(sortIdx);
                    
                    % Correlations:
                    [rr(1),pp(1)]=corr(NoSeMaze_input,FC_bl1,'type','Pearson');
                    [rr(2),pp(2)]=corr(NoSeMaze_input,FC_bl1,'type','Spearman');
                    [rr(3),pp(3)]=corr(NoSeMaze_input,FC_bl3,'type','Pearson');
                    [rr(4),pp(4)]=corr(NoSeMaze_input,FC_bl3,'type','Spearman');
                    [rr(5),pp(5)]=corr(NoSeMaze_input,FC_diff,'type','Pearson');
                    [rr(6),pp(6)]=corr(NoSeMaze_input,FC_diff,'type','Spearman');
                    
                    %% subplot
                    subplot(2,3,1);
                    % boxplot
                    bb=notBoxPlot_modified([FC_bl1,FC_bl3]);
                    for ib=1:length(bb)
                        bb(ib).data.MarkerSize=6;
                        bb(ib).data.MarkerEdgeColor='none';
                        bb(ib).semPtch.EdgeColor='none';
                        bb(ib).sdPtch.EdgeColor='none';
                    end
                    % color definitions
                    bb(1).data.MarkerFaceColor= [204/255 51/255 204/255];
                    bb(1).mu.Color= [204/255 51/255 204/255];
                    bb(1).semPtch.FaceColor= [255/255 102/255 204/255];
                    bb(1).sdPtch.FaceColor= [255/255 204/255 204/255];
                    % color definitions
                    bb(2).data.MarkerFaceColor= [0 160/255 227/255];
                    bb(2).mu.Color= [0 160/255 227/255];
                    bb(2).semPtch.FaceColor= [75/255 207/255 227/255];
                    bb(2).sdPtch.FaceColor= [150/255 255/255 227/255];
                    
                    % axis
                    box('off');
                    ax1=gca;
                    %     ax1.YLim=[axlimit{ig}];
                    ax1.YLabel.String={'mean FC'};
                    ax1.XTickLabel={'Bl. 1','Bl. 3'};
                    ax1.FontSize=10;
                    ax1.FontWeight='bold';
                    ax1.LineWidth=1.5;
                    ax1.XLim=[.5,2.5];
                    %     rotateXLabels(ax1,45);
                    
                    % significance test
                    [h,p]=ttest(FC_bl1,FC_bl3);
                    [clusters, p_values, t_sums, permutation_distribution ] = permutest(FC_bl1',FC_bl3',true,0.05,10000,true);
                    % sign. star
                    if p_values<0.05
                        H=sigstar({[1,2]},p_values,0,10);
                    end
                    
                    % plot permutation result
                    tx=text(ax1.XLim(1)+.1*(diff(ax1.XLim)),ax1.YLim(1)+.2*(diff(ax1.YLim)),['p_p_e_r_m=' num2str(p_values)]);
                    tx.Interpreter='tex';
                    
                    %% subplot
                    subplot(2,3,[2,3]);
                    % boxplot
                    sc(1)=scatter(NoSeMaze_input,FC_bl1); hold on;
                    sc(2)=scatter(NoSeMaze_input,FC_bl3);
                    for isc=1:length(sc)
                        sc(isc).SizeData=40;
                        sc(isc).MarkerEdgeColor='none';
                    end
                    % color definitions
                    sc(1).MarkerFaceColor= [204/255 51/255 204/255];
                    % color definitions
                    sc(2).MarkerFaceColor= [0 160/255 227/255];
                    
                    % axis
                    box('off');
                    axis square;
                    ax2=gca;
                    ax2.YLabel.String={'mean FC'};
                    ax2.XLabel.String=ExplVar(varIdx).name;
                    if contains(ExplVar(varIdx).name,'Rank');
                        ax2.XLim=[1,12];
                        ax2.XTick=[1:12];
                        ax2.XTickLabel=[1:12];
                    end
                    ax2.YLim(2)=ax1.YLim(2);
                    ax2.FontSize=10;
                    ax2.FontWeight='bold';
                    ax2.LineWidth=1.5;
                    
                    % plot correlation lines
                    ll = lsline;
                    ll(1).Color=[0 160/255 227/255];
                    ll(1).LineWidth=1.5;
                    ll(2).Color=[204/255 51/255 204/255];
                    ll(2).LineWidth=1.5;
                    
                    % plot permutation result
                    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['p=' num2str(round(pp(1),3))]);
                    tx.Color=[204/255 51/255 204/255];
                    tx.FontWeight='bold';
                    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['p=' num2str(round(pp(3),3))]);
                    tx.Color=[0 160/255 227/255];
                    tx.FontWeight='bold';
                    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['rho=' num2str(round(rr(1),3))]);
                    tx.Color=[204/255 51/255 204/255];
                    tx.FontWeight='bold';
                    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['rho=' num2str(round(rr(3),3))]);
                    tx.Color=[0 160/255 227/255];
                    tx.FontWeight='bold';
                    
                    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.9*(diff(ax2.YLim)),['psp=' num2str(round(pp(2),3))]);
                    tx.Color=[204/255 51/255 204/255];
                    tx.FontWeight='bold';
                    tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.8*(diff(ax2.YLim)),['psp=' num2str(round(pp(4),3))]);
                    tx.Color=[0 160/255 227/255];
                    tx.FontWeight='bold';
                    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.9*(diff(ax2.YLim)),['rhosp=' num2str(round(rr(2),3))]);
                    tx.Color=[204/255 51/255 204/255];
                    tx.FontWeight='bold';
                    tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.8*(diff(ax2.YLim)),['rhosp=' num2str(round(rr(4),3))]);
                    tx.Color=[0 160/255 227/255];
                    tx.FontWeight='bold';
                    
                    %% subplot
                    subplot(2,3,[5,6]);
                    % boxplot
                    sc=scatter(NoSeMaze_input,[FC_bl3-FC_bl1]);
                    sc.SizeData=40;
                    sc.MarkerEdgeColor='none';
                    
                    % color definitions
                    sc.MarkerFaceColor= ([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                    
                    % axis
                    box('off');
                    axis square;
                    ax=gca;
                    ax.YLabel.String={'mean FC','(bl. 3 - bl. 1)'};
                    ax.XLabel.String=ExplVar(varIdx).name;
                    if contains(ExplVar(varIdx).name,'Rank');
                        ax.XLim=[1,12];
                        ax.XTick=[1:12];
                        ax.XTickLabel=[1:12];
                    end
                    ax.FontSize=10;
                    ax.FontWeight='bold';
                    ax.LineWidth=1.5;
                    
                    % plot correlation lines
                    ll = lsline;
                    ll.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                    ll.LineWidth=1.5;
                    
                    % plot permutation result
                    tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['p=' num2str(round(pp(5),3))]);
                    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                    tx.FontWeight='bold';
                    tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['rho=' num2str(round(rr(5),3))]);
                    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                    tx.FontWeight='bold';
                    tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_s_p=' num2str(round(pp(6),3))]);
                    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                    tx.FontWeight='bold';
                    tx.Interpreter='tex';
                    tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['rho_s_p=' num2str(round(rr(6),3))]);
                    tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                    tx.FontWeight='bold';
                    tx.Interpreter='tex';
                    
                    % title
                    supt=suptitle({[ExplVar(varIdx).name ' to ' mask_name]});
                    supt.Interpreter='none';
                    
                    %
                    ax1.YLim=ax2.YLim;
                    
                    % print
                    [annot, srcInfo] = docDataSrc(fig(varIdx),fullfile(outputDir),mfilename('fullpath'),logical(1));
                    exportgraphics(fig(varIdx),fullfile(outputDir,['Correlation_meanSeedBasedFC_to_' ExplVar(varIdx).name '_' mask_name '.pdf']),'Resolution',300);
                    %     print('-dpsc',fullfile(outputDir,['Correlation_BOLD_to_' ExplVar(varIdx).name]),'-painters','-r400','-append');
                    
                    % save source data in csv
                    SourceData = array2table([NoSeMaze_input,FC_bl1,FC_bl3,[FC_bl3-FC_bl1]],'VariableNames',{ExplVar(varIdx).name,'FC_block1','FC_block3','FCdiff'});
                    writetable(SourceData,fullfile(outputDir,['SourceData_Correlation_seebasedFC_to_' ExplVar(varIdx).name '_' mask_name '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
                    NoSeMaze_input,[FC_bl3-FC_bl1]
                    
                end
                
                
                save(fullfile(contrastlist(cix).folder,contrastlist(cix).name,[masklist(mx).name(1:end-4) '.mat']),'res');
                close all
            end
        end
    end
end