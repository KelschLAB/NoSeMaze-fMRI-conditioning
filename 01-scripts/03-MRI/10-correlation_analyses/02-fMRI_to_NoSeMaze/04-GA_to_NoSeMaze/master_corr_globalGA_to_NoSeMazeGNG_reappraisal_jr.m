%% master_corr_globalGA_to_NoSeMazeGNG_reappraisal_jr.m
% Reinwald, Jonathan; 08/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate
% - run before:
%   1.) /zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/03-GNG/extract_impulsivity_jr.m

%% Preparation
clear all;
close all;

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36,1]%,1,31];
maxthr_ind_range=[41,41];

% comparison selection
comparison_names={'TPnoPuff11to40VSTPnoPuff81to120','Odor11to40VSOdor81to120'};

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

%% Load regressors of interest
%% Option 1: "short" regressors (only including the first 4 switches, phase 1-5)
% read table for info on animals ID and pairing
T = readtable('/home/jonathan.reinwald/ICON_Autonomouse/07-recording_documentation/01_General_Overview.xlsx','Sheet',9,'ReadVariableNames', true);

% load different hierarchies
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/covariates_short_jr.mat');
covariates_short = readtable('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/impulsivity_150trials.xlsx','Sheet',1,'ReadVariableNames', true);

% clearing
clear info

% variable names in the covariate file from David
VarNames = covariates_short.Properties.VariableNames;
% selection of variables in which we are interested
VarSelection = {'cs_minus_pc1','cs_minus_pc2','correct_rejection','cs_minus_pc1_base','cs_minus_pc2_base','baseline_rate_CSminus_mean_omitfirst'};
% set variable counter
var_counter=1;
% Loop over variables
for idxV = 1:length(VarSelection)
    
    animal_counter=1;
    for idxT = 1:size(T,1)
        % add info on IDs
        info.ID_own{animal_counter}=T.AnimalIDCombined{idxT};
        % add infos on animal number
        info.AnimalNumb(animal_counter)=T.AnimalNumber(idxT);
        % add infos on covariates
        info.(VarSelection{idxV})(animal_counter)=covariates_short.(VarSelection{idxV})(strcmp(covariates_short.ID,info.ID_own{animal_counter}));
        animal_counter=animal_counter+1;
    end
    
    ExplVar(idxV).name = VarSelection{idxV};
    ExplVar(idxV).values = info.(VarSelection{idxV})';
    ExplVar(idxV).ID = info.ID_own;
end

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% Predefinitions for GLM selection
% workDir = spm_select(1,'dir','Select Graph Analytical Result Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/');
workDir = spm_select(1,'dir','Select Graph Analytical Result Directory',{},'/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/');
outputDir_main = fullfile(workDir,'corr_GNG_short');

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
    
    %
    clear VarNames toSave
    
    % %% plots
    for ix=1:length(ExplVar)
        fig(ix)=figure('visible','off');
        subplot(1,2,1);
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
        [sortedData,sortingIdx]=sort(ExplVar(ix).values);
        H3=barh([1:length(ExplVar(ix).values)],flip(sortedData));
        box('off');
%         colorMap = [[linspace(0,1,128)';linspace(1,102/128,128)'],[linspace(80/128,1,128)';linspace(1,25/128,128)'],[linspace(114/128,1,128)';linspace(1,102/128,128)']];
%         H3.CData=vals2colormap_jr(flip([stats.tstat]'), colorMap, [-5,5]);
        H3.FaceColor='Flat';
        H3.EdgeColor='none';
        ax=gca;
        ax.YTick=[1:length(ExplVar(ix).ID)];
        ax.YTickLabel=flip(ExplVar(ix).ID(sortingIdx));
        %     ax.TickLabelInterpreter='none';
        ax.FontSize=10;
        ax.XLabel.String=ExplVar(ix).name;
        ax.XLabel.Interpreter='none';
        %         ax.XTickLabel=[-5:5];
        subplot(1,2,2);
        nb = notBoxPlot(ExplVar(ix).values);
        nb(1).sdPtch.EdgeColor='none';nb(1).semPtch.EdgeColor='none';nb(1).data.MarkerEdgeColor='none';
        ax=gca;
        ax.XLim=[.5,1.5];
        ax.YLabel.String='CS- PC1';
        exportgraphics(fig(ix), fullfile(outputDir,['Data_' ExplVar(ix).name '.pdf']),'ContentType','vector','BackgroundColor','none');
        % save source data in csv
        toSave(:,ix)=sortedData;
        VarNames{ix}=ExplVar(ix).name;
               
        close all;
    end
    % save source data in csv
    SourceData = array2table(toSave,'VariableNames',VarNames);
    writetable(SourceData,fullfile(outputDir,['SourceData_ExplVariables.csv']),'WriteVariableNames',true,'WriteRowNames',true)
    
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
            
            if ~exist(fullfile(outputDir_comparison,'GA_global_all.ps'))
                delete(fullfile(outputDir_comparison,'GA_global_all.ps'))
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
            for gaIdx = [15:17]%1:length(global_metrics)
                
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
                axis square
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
                axis square;
                ax2=gca;
                ax2.YLabel.String=global_metrics{gaIdx};
                ax2.XLabel.String=ExplVar(varIdx).name;
                if contains(ExplVar(varIdx).name,'Rank')
                    ax2.XLim=[0,12];
                    ax2.XTick=[0:1:12];
                    ax2.XTickLabel=[0:1:12];
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
                axis square;
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
                
                % save source data in csv
                SourceData = array2table([NoSeMaze_input,res_auc_struc.(global_metrics{gaIdx}).(comp1),res_auc_struc.(global_metrics{gaIdx}).(comp2),[res_auc_struc.(global_metrics{gaIdx}).(comp2)-res_auc_struc.(global_metrics{gaIdx}).(comp1)]],'VariableNames',{ExplVar(varIdx).name,comp1,comp2,'diff'});
                writetable(SourceData,fullfile(outputDir_comparison,['SourceData_Correlation_GA_global_' global_metrics{gaIdx} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
                
                
                % print
                [annot, srcInfo] = docDataSrc(fig,fullfile(outputDir_comparison),mfilename('fullpath'),logical(1));
                exportgraphics(fig,fullfile(outputDir_comparison,['GA_global_' global_metrics{gaIdx} '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(outputDir_comparison,['GA_global_all']),'-painters','-r400','-append');
                
                %
                close all
                %             end
            end
        end
    end
end
