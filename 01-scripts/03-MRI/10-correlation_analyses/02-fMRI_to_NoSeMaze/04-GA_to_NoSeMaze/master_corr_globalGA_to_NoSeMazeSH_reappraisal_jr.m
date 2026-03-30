%% master_corr_globalGA_to_NoSeMazeSH_reappraisal_jr.m
% Reinwald, Jonathan; 08/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate
% - run before:
%   1.) /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/01-AM/02-analyses/03-chasing/extract_chasing_from_full_hierarchy_v2_jr.m
%   2.) /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/01-AM/02-analyses/01-hierarchy/compute_hierarchy_AM2_jr.m
%   3.) /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/01-AM/02-analyses/01-hierarchy/compute_hierarchy_AM1_jr.m

%% Preparation
% clear all;
% close all;

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36,31,1];
maxthr_ind_range=[41,41,41];

% comparison selection
comparison_names={'TPnoPuff11to40VSTPnoPuff81to120'}%,'Odor11to40VSOdor81to120'};

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

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
            clear wins losses
            wins = sum(DS_info1_3to16.match_matrix');
            losses = sum(DS_info1_3to16.match_matrix);
            info.tube_wins(counter)=wins(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            info.tube_losses(counter)=losses(strcmp(DS_info1_3to16.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_3to16.DS(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_3to16.Rank(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_3to16.DSzscored(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            clear wins losses
            wins = sum(DSchasing_info1_3to16.match_matrix');
            losses = sum(DSchasing_info1_3to16.match_matrix);
            info.chase_wins(counter)=wins(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
            info.chase_losses(counter)=losses(strcmp(DSchasing_info1_3to16.ID,info.ID_own{counter}));
        elseif contains(T.DaysToConsider{idxT},'21')
            % tube hierarchy
            info.DS_own(counter)=DS_info1_8to21.DS(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_own(counter)=DS_info1_8to21.Rank(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_own(counter)=DS_info1_8to21.DSzscored(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            clear wins losses
            wins = sum(DS_info1_8to21.match_matrix');
            losses = sum(DS_info1_8to21.match_matrix);
            info.tube_wins(counter)=wins(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            info.tube_losses(counter)=losses(strcmp(DS_info1_8to21.ID,info.ID_own{counter}));
            % chasing
            info.DS_chasing(counter)=DSchasing_info1_8to21.DS(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.Rank_chasing(counter)=DSchasing_info1_8to21.Rank(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.DSzscored_chasing(counter)=DSchasing_info1_8to21.DSzscored(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            clear wins losses
            wins = sum(DSchasing_info1_8to21.match_matrix');
            losses = sum(DSchasing_info1_8to21.match_matrix);
            info.chase_wins(counter)=wins(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
            info.chase_losses(counter)=losses(strcmp(DSchasing_info1_8to21.ID,info.ID_own{counter}));
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
        clear wins losses
        wins = sum(DS_info2.match_matrix');
        losses = sum(DS_info2.match_matrix);
        info.tube_wins(counter)=wins(strcmp(DS_info2.ID,info.ID_own{counter}));
        info.tube_losses(counter)=losses(strcmp(DS_info2.ID,info.ID_own{counter}));
        % chasing
        info.DS_chasing(counter)=DSchasing_info2.DS(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.Rank_chasing(counter)=DSchasing_info2.Rank(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.DSzscored_chasing(counter)=DSchasing_info2.DSzscored(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        clear wins losses
        wins = sum(DSchasing_info2.match_matrix');
        losses = sum(DSchasing_info2.match_matrix);
        info.chase_wins(counter)=wins(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
        info.chase_losses(counter)=losses(strcmp(DSchasing_info2.ID,info.ID_own{counter}));
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
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Load FD
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/tc_matrsess_all_BINS6_TRsbefore2.mat')
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/AON/FD_matrsess_all_BINS6_TRsbefore2.mat')

meanFD_block1 = squeeze(mean(FD_matrsess_all(:,[11:40],:),2));
meanFD_block3 = squeeze(mean(FD_matrsess_all(:,[81:120],:),2));
meanFD = squeeze(mean(FD_matrsess_all(:,[1:120],:),2));

[FD_AnimalNumb,sortingIdx_FD]=sort(tc_matrsess_info.AnimalNumb,'ascend');
meanFD_block1_sorted=meanFD_block1(sortingIdx_FD,:);
meanFD_block3_sorted=meanFD_block3(sortingIdx_FD,:);
meanFD_sorted=meanFD(sortingIdx_FD,:);


%% Predefinitions for GA selection
workDir = spm_select(1,'dir','Select Graph Analytical Result Directory',{},'/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/');
% workDir = spm_select(1,'dir','Select Graph Analytical Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/');
outputDir_main = fullfile(workDir,'corr_SocialHierarchy');

%% Loop over threshold ranges
for mx = 1:length(minthr_ind_range)
    
    %% current thresholds
    minthr_ind = minthr_ind_range(mx)
    maxthr_ind = maxthr_ind_range(mx)
    
    % outputDir
    outputDir = fullfile(outputDir_main,[num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
    if exist(outputDir)~=7
        mkdir(outputDir);
    end
    cd(outputDir);
    
    % %% plots
    for ix=1:length(ExplVar)
        f = plot_David_score_in_group(ExplVar(ix),ExplVar(ix).ID);
        exportgraphics(f, fullfile(outputDir,['rank_plot_day_' ExplVar(ix).name '.pdf']),'ContentType','vector','BackgroundColor','none');
        close all;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ------------------------ CORRELATION ANALYSIS  ---------------------- %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for compIdx = 1:length(comparison_names)
        for varIdx = 1:length(ExplVar)
            %% 1. Create output directory
            outputDir_comparison = [outputDir filesep comparison_names{compIdx} filesep ExplVar(varIdx).name ];
            if ~exist(outputDir_comparison)
                mkdir(outputDir_comparison)
            end
            
            if exist(fullfile(outputDir_comparison,'GA_global.ps'))
                delete(fullfile(outputDir_comparison,'GA_global.ps'));
            end
            %% 2. Load global graph analytical results
            load([workDir filesep comparison_names{compIdx} filesep ['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)] filesep 'res_auc_struc_global.mat'],'res_auc_struc');
            
            %% 3. Sort NoSeMaze variable
            [~,sortIdx]=sort(ExplVar(varIdx).AnimalNumb);
            NoSeMaze_input = ExplVar(varIdx).values(sortIdx);
            
            %% beta values instead of NoSeMaze input
            % INS
            %         load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T01.mat');
            %         NoSeMaze_input = [res.mean_beta_TP_Puff_Bl3-res.mean_beta_TP_Puff_Bl1_11to40]';
            % vHC
            %         load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_T01.mat');
            %         NoSeMaze_input = [res.mean_betaPos-res.mean_betaNeg]';
            
            global_metrics = fieldnames(res_auc_struc);
            for gaIdx = 1:length(global_metrics)
                
                %% 4. Plot
                % comparison names
                find_ = strfind(comparison_names{compIdx},'VS');
                comp1 = comparison_names{compIdx}(1:find_-1);
                comp2 = comparison_names{compIdx}(find_+2:end);
                
                %             find_ = strfind(comparison_names{compIdx+1},'VS');
                %             comp3 = comparison_names{compIdx+1}(1:find_-1);
                %             comp4 = comparison_names{compIdx+1}(find_+2:end);
                
                % correlation test
                [rr(1),pp(1)]=corr(NoSeMaze_input,res_auc_struc.(global_metrics{gaIdx}).(comp1));
                [rr(2),pp(2)]=corr(NoSeMaze_input,res_auc_struc.(global_metrics{gaIdx}).(comp2));
                [rr(3),pp(3)]=corr(NoSeMaze_input,[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)]);
                [rr(4),pp(4)]=corr(NoSeMaze_input,[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)],'type','Spearman');
                
                [rrFD(1,:),ppFD(1,:)]=corr(meanFD_sorted,res_auc_struc.(global_metrics{gaIdx}).(comp1));
                [rrFD(2,:),ppFD(2,:)]=corr(meanFD_sorted,res_auc_struc.(global_metrics{gaIdx}).(comp2));
                [rrFD(3,:),ppFD(3,:)]=corr(meanFD_sorted,[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)]);
                [rrFD(4,:),ppFD(4,:)]=corr(meanFD_sorted,[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)],'type','Spearman');
                % plot only, if correlation is lower than trend level
                %             if pp(3)<0.1
                
                %% figure
                fig=figure('visible', 'off');
                set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
                
                
                %% subplot
                subplot(2,3,1);
                % boxplot
                bb=notBoxPlot_modified([res_auc_struc.(global_metrics{gaIdx}).(comp1),res_auc_struc.(global_metrics{gaIdx}).(comp2)]);
                for ib=1:length(bb)
                    bb(ib).data.MarkerSize=4;
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
                ax1.YLabel.String=global_metrics{gaIdx};
                ax1.XTickLabel={'Bl. 1','Bl. 3'};
                ax1.XLim=[.5,2.5];
                if contains(global_metrics{gaIdx},'delta')
                    ax1.YLim(1)=0;
                end
                ax1.FontSize=10;
                ax1.FontWeight='bold';
                ax1.LineWidth=1;
                %     rotateXLabels(ax1,45);
                
                % significance test
                [h,p]=ttest(res_auc_struc.(global_metrics{gaIdx}).(comp1),res_auc_struc.(global_metrics{gaIdx}).(comp2));
                [clusters, p_values, t_sums, permutation_distribution ] = permutest(res_auc_struc.(global_metrics{gaIdx}).(comp1)',res_auc_struc.(global_metrics{gaIdx}).(comp2)',true,0.05,10000,true);
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
                sc(1)=scatter(NoSeMaze_input,res_auc_struc.(global_metrics{gaIdx}).(comp1)); hold on;
                sc(2)=scatter(NoSeMaze_input,res_auc_struc.(global_metrics{gaIdx}).(comp2));
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
                axis square
                ax2=gca;
                ax2.YLabel.String=global_metrics{gaIdx};
                ax2.XLabel.String=ExplVar(varIdx).name;
                if contains(ExplVar(varIdx).name,'Rank')
                    ax2.XLim=[1,12];
                    ax2.XTick=[1:1:12];
                    ax2.XTickLabel=[1:1:12];
                end
                if contains(global_metrics{gaIdx},'delta')
                    ax2.YLim(1)=0;
                end
                ax2.YLim(2)=ax1.YLim(2);
                ax2.FontSize=10;
                ax2.FontWeight='bold';
                ax2.LineWidth=1;
                
                % plot correlation lines
                ll = lsline;
                ll(1).Color=[0 160/255 227/255];
                ll(1).LineWidth=1;
                ll(2).Color=[204/255 51/255 204/255];
                ll(2).LineWidth=1;
                
                % plot permutation result
                tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['p=' num2str(round(pp(1),3))]);
                tx.Color=[204/255 51/255 204/255];
                tx.FontWeight='bold';
                tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['p=' num2str(round(pp(2),3))]);
                tx.Color=[0 160/255 227/255];
                tx.FontWeight='bold';
                tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['rho=' num2str(round(rr(1),3))]);
                tx.Color=[204/255 51/255 204/255];
                tx.FontWeight='bold';
                tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['rho=' num2str(round(rr(2),3))]);
                tx.Color=[0 160/255 227/255];
                tx.FontWeight='bold';
                
                %% subplot
                subplot(2,3,[5,6]);
                % boxplot
                sc=scatter(NoSeMaze_input,[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)]);
                sc.SizeData=40;
                sc.MarkerEdgeColor='none';
                
                % color definitions
                sc.MarkerFaceColor= ([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                
                % axis
                box('off');
                axis square
                ax=gca;
                ax.YLabel.String={global_metrics{gaIdx},'bl. 3 - bl. 1'};
                ax.XLabel.String=ExplVar(varIdx).name;
                if contains(ExplVar(varIdx).name,'Rank')
                    ax.XLim=[1,12];
                    ax.XTick=[1:1:12];
                    ax.XTickLabel=[1:1:12];
                end
                ax.FontSize=10;
                ax.FontWeight='bold';
                ax.LineWidth=1;
                
                % plot correlation lines
                ll = lsline;
                ll.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                ll.LineWidth=1;
                
                % plot permutation result
                tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['p=' num2str(round(pp(3),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['rho=' num2str(round(rr(3),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_s_p=' num2str(round(pp(4),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx.Interpreter='tex';
                tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['rho_s_p=' num2str(round(rr(4),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx.Interpreter='tex';
                
                % title
                supt=suptitle({global_metrics{gaIdx};[comp1 ' vs ' comp2]});
                supt.Interpreter='none';
                
                % print
                [annot, srcInfo] = docDataSrc(fig,fullfile(outputDir_comparison),mfilename('fullpath'),logical(1));
                exportgraphics(fig,fullfile(outputDir_comparison,['GA_global_' global_metrics{gaIdx} '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(outputDir_comparison,['GA_global']),'-painters','-r400','-append');
                
                % save source data in csv
                SourceData = array2table([NoSeMaze_input,res_auc_struc.(global_metrics{gaIdx}).(comp1),res_auc_struc.(global_metrics{gaIdx}).(comp2),[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)]],'VariableNames',{ExplVar(varIdx).name,comp1,comp2,'diff'});
                writetable(SourceData,fullfile(outputDir_comparison,['SourceData_Correlation_GA_global_' global_metrics{gaIdx} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
                
                %
                close all
                %             end
            end
        end
    end
end