%% master_corr_globalGA_to_NoSeMazeSH_reappraisal_control_2023_jr.m
% Reinwald, Jonathan; 08/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate
% - run XXX BEFORE

%% Preparation
clear all;
close all;

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[11];
maxthr_ind_range=[41];

% comparison selection
comparison_names={'TPnoPuff11to40VSTPnoPuff81to120','Odor11to40VSOdor81to120'};

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

% load Pfunc for sorting
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat')
Pfunc_reappraisal_sorted = flip(Pfunc_reappraisal',1);

%% Load regressors of interest
%% For each animal, social hierarchy is used based on the 14 days before the scans
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/05-AM_Danae_cohort1/social_hierarchy_Danae_control_2023.xlsx','Sheet',1,'ReadVariableNames', true);

ExplVar(1).name = 'DavidsScore';
ExplVar(1).values = T.Davids_score;
ExplVar(1).ID = T.scan_ID;
ExplVar(1).AnimalNumb = T.scan_ID;

ExplVar(2).name = 'Rank';
ExplVar(2).values = T.social_rank;
ExplVar(2).ID = T.scan_ID;
ExplVar(2).AnimalNumb = T.scan_ID;

% % % ExplVar(3).name = 'DavidsScore_zscored';
% % % ExplVar(3).values = T.social_rank;
% % % ExplVar(3).ID = T.scan_ID;
% % % ExplVar(3).AnimalNumb = T.scan_ID;

%% Predefinitions for GA selection
workDir = spm_select(1,'dir','Select Graph Analytical Result Directory (including subfolders, e.g., max_connected)',{},'/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/');
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ------------------------ CORRELATION ANALYSIS  ---------------------- %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for compIdx = 1:length(comparison_names)
        for varIdx = 2:length(ExplVar)
            %% 1. Create output directory
            outputDir_comparison = [outputDir filesep comparison_names{compIdx} filesep ExplVar(varIdx).name ];
            if ~exist(outputDir_comparison)
                mkdir(outputDir_comparison)
            end
            
            %% 2. Load global graph analytical results
            load([workDir filesep comparison_names{compIdx} filesep ['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)] filesep 'res_auc_struc_global.mat'],'res_auc_struc');
            % Commment: The graph analytical results are derived from the cormat. The cormat is created loaading the files in the sorted order of the animals (ZI_M230906A to ZI_M230908H) 
            
            %% 3. NoSeMaze input (sorted by animal name)
            NoSeMaze_input = ExplVar(varIdx).values;
            
            %% beta values instead of NoSeMaze input
            % INS
            %         load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_activation_v22_Bl3vsBl1_T01.mat');
            %         NoSeMaze_input = [res.mean_beta_TP_Puff_Bl3-res.mean_beta_TP_Puff_Bl1_11to40]';
            % vHC
            %         load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel_Rank_own/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_deactivation_corrRank_own_T01.mat');
            %         NoSeMaze_input = [res.mean_betaPos-res.mean_betaNeg
            global_metrics = fieldnames(res_auc_struc);
            
            %% Loop over global metrics
            for gaIdx = 16:length(global_metrics)
                
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
                ax2=gca;
                ax2.YLabel.String=global_metrics{gaIdx};
                ax2.XLabel.String=ExplVar(varIdx).name;
                if contains(ExplVar(varIdx).name,'Rank')
                    ax2.XLim=[0,13];
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
                ax=gca;
                ax.YLabel.String={global_metrics{gaIdx},'bl. 3 - bl. 1'};
                ax.XLabel.String=ExplVar(varIdx).name;
                if contains(ExplVar(varIdx).name,'Rank');
                    ax.XLim=[0,13];
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
                
                %
                close all
                %             end
            end
        end
    end
end