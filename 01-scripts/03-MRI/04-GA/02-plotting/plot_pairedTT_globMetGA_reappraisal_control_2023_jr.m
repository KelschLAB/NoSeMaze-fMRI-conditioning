%% plot_pairedTT_globMetGA_reappraisal_control_2023_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Comparison selection

% name_TP1='Odor11to40';
% name_TP2='Odor81to120';
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36,1];
maxthr_ind_range=[41,41];

%% Selection of input
% cormat version
cormat_version = 'cormat_v7';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';
% folder selection
if separated_hemisphere==2
    inputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness];
elseif separated_hemisphere==1
    inputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
elseif separated_hemisphere==0
    inputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
end

%% Loop over threshold ranges
for mx = 1:length(minthr_ind_range)
    
    %% current thresholds
    minthr_ind = minthr_ind_range(mx)
    maxthr_ind = maxthr_ind_range(mx)
    
    %% Output directory
    if separated_hemisphere==2
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2];
    elseif separated_hemisphere==1
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2];
    elseif separated_hemisphere==0
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2];
    end
    outputDir = fullfile(outputDir,['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
    mkdir(outputDir);
    cd(outputDir);
    
    if exist(fullfile(outputDir,'GA_global.ps'))==2
        delete(fullfile(outputDir,'GA_global.ps'));
    end
    
    %% Load input data
    load(fullfile(inputDir,['auc_struc_' name_TP1 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP1 = auc_struc;
    load(fullfile(inputDir,['auc_struc_' name_TP2 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP2 = auc_struc;
    
    %% Selection of global metrics
    metricnames_all = fieldnames(auc_struc_TP1)
    global_metrics = metricnames_all(contains(fieldnames(auc_struc_TP1),'g_'))
    % throw out: null models, _JR (doubled), _clus,  _path (both for SWP)
    global_metrics=global_metrics(logical(~contains(global_metrics,'_null'))),
%     global_metrics=global_metrics(logical(~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
    % global_metrics=global_metrics(logical(~contains(global_metrics,'_JR') .* ~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
    % global_metrics=global_metrics(logical(~contains(global_metrics,'_norm') .* ~contains(global_metrics,'_cpl') .* ~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
    
    if strcmp(binarization_method,'max')
        global_metrics(7)=[];
    end
    
    %% Loop over global names for plotting
    for ig=1:length(global_metrics)
        clear h ax
        
        if 1==1
            % figure
            fig(ig)=figure('visible', 'off');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
            % boxplot
            bb=notBoxPlot_modified([[auc_struc_TP1.(global_metrics{ig})]',[auc_struc_TP2.(global_metrics{ig})]']);
            for ib=1:length(bb)
                bb(ib).data.MarkerSize=8;
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
            ax=gca;
            %     ax.YLim=[axlimit{ig}];
            ax.YLabel.String='A.U.';
            ax.XTickLabel={'Bl. 1','Bl. 3'};
            ax.XLim=[.5,2.5];
            ax.FontSize=18;
            ax.FontWeight='bold';
            ax.LineWidth=2;
            %     rotateXLabels(ax,45);
            % title
            tt=title({global_metrics{ig};[name_TP1 ' vs ' name_TP2]});
            tt.Interpreter='none';
            
            % significance test
            [h,p]=ttest([auc_struc_TP1.(global_metrics{ig})]',[auc_struc_TP2.(global_metrics{ig})]');
            [clusters, p_values, t_sums, permutation_distribution ] = permutest([auc_struc_TP1.(global_metrics{ig})],[auc_struc_TP2.(global_metrics{ig})],true,0.05,10000,true);
            % sign. star
            if p_values<0.05
                H=sigstar({[1,2]},p_values,0,30);
            end
            % plot permutation result
            tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_p_e_r_m=' num2str(p_values)]);
            
            % print
            [annot, srcInfo] = docDataSrc(fig(ig),fullfile(outputDir),mfilename('fullpath'),logical(1));
            exportgraphics(fig(ig),fullfile(outputDir,['GA_global_' global_metrics{ig} '.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['GA_global']),'-painters','-r400','-append');
            
            % close
            close all;
        end
        
        % results for saving
        res_auc_struc.(global_metrics{ig}).(name_TP1) = [auc_struc_TP1.(global_metrics{ig})]';
        res_auc_struc.(global_metrics{ig}).(name_TP2) = [auc_struc_TP2.(global_metrics{ig})]';
    end
    % save data
    save(fullfile(outputDir,['res_auc_struc_global.mat']),'res_auc_struc');
end