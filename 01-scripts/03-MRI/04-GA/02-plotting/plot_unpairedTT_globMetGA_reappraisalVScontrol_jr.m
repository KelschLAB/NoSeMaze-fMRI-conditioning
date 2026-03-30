%% plot_unpairedTT_globMetGA_reappraisalVScontrol_jr.m
% compare GA from reappraisal task to control

%% clearing
close all
clear all
clc

%% Selection of input
% cormat version
% cormat_selection_control = 'cormat_v6';
% cormat_selection_task = 'cormat_v11'
% with scrubbing
cormat_selection_control = 'cormat_v7';
cormat_selection_task = 'cormat_v14'
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness_val = 'connected';

% comparison selection
comparison_names={'TPnoPuff11to40VSTPnoPuff81to120','Odor11to40VSOdor81to120'};

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36,1]%[1,31,36];
maxthr_ind_range=[41,41];

%% Loop over comparison names
for compIdx = 1:length(comparison_names)
    
    %% define directories
    if separated_hemisphere == 1
        controlDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_selection_control '/separated_hemisphere/' binarization_method '_' connectedness_val filesep comparison_names{compIdx}];
        taskDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_selection_task '/separated_hemisphere/' binarization_method '_' connectedness_val filesep comparison_names{compIdx}];
    else
        controlDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_selection_control '/combined_hemisphere/' binarization_method '_' connectedness_val filesep comparison_names{compIdx}];
        taskDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_selection_task '/combined_hemisphere/' binarization_method '_' connectedness_val filesep comparison_names{compIdx}];
    end
    
    %% Loop over threshold ranges
    for mx = 1:length(minthr_ind_range)
        
        %% current thresholds
        minthr_ind = minthr_ind_range(mx)
        maxthr_ind = maxthr_ind_range(mx)
        
        % output directory
        outputDir = fullfile(taskDir,['global_compTaskVsControl_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
        if exist(outputDir)~=7
            mkdir(outputDir);
        end
        cd(outputDir);
        
        if exist(fullfile(outputDir,'GA_globalALL_comp_reappraisalVScontrol.ps'))
            delete(fullfile(outputDir,'GA_globalALL_comp_reappraisalVScontrol.ps'))
        end
        
        %% load data
        load(fullfile(controlDir,['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)],'res_auc_struc_global.mat'));
        res_auc_struc_con = res_auc_struc;
        load(fullfile(taskDir,['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)],'res_auc_struc_global.mat'));
        res_auc_struc_task = res_auc_struc;
        
        % global metric names
        global_metrics=fieldnames(res_auc_struc_task);
        
        %% Loop over global metrics
        for gl_idx = 1:length(global_metrics)
            % diff calculation
            findVS = strfind(comparison_names{compIdx},'VS');
            gm_con_diff = [res_auc_struc_con.(global_metrics{gl_idx}).(comparison_names{compIdx}(findVS+2:end))-res_auc_struc_con.(global_metrics{gl_idx}).(comparison_names{compIdx}(1:findVS-1))];
            gm_puff_diff = [res_auc_struc_task.(global_metrics{gl_idx}).(comparison_names{compIdx}(findVS+2:end))-res_auc_struc_task.(global_metrics{gl_idx}).(comparison_names{compIdx}(1:findVS-1))];
            % ttest statistic
            [h(gl_idx),p(gl_idx)]=ttest2(gm_puff_diff,gm_con_diff);
            
            % Plot
            fig(gl_idx)=figure('visible', 'off');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
            
            bb=notBoxPlot([gm_puff_diff,gm_con_diff]);
            for ib=1:length(bb)
                bb(ib).data.MarkerSize=8;
                bb(ib).data.MarkerEdgeColor='none';
                bb(ib).semPtch.EdgeColor='none';
                bb(ib).sdPtch.EdgeColor='none';
            end
            % color definitions
            bb(1).data.MarkerFaceColor= [0/255 128/255 128/255];
            bb(1).mu.Color= [0/255 128/255 128/255];
            bb(1).semPtch.FaceColor= [102/255 200/255 200/255];
            bb(1).sdPtch.FaceColor= [204/255 230/255 230/255];
            % color definitions
            %     bb(2).data.MarkerFaceColor= [0 160/255 227/255];
            %     bb(2).mu.Color= [0 160/255 227/255];
            %     bb(2).semPtch.FaceColor= [75/255 207/255 227/255];
            %     bb(2).sdPtch.FaceColor= [150/255 255/255 227/255];
            bb(2).data.MarkerFaceColor= [75/255 75/255 75/255];
            bb(2).mu.Color= [75/255 75/255 75/255];
            bb(2).semPtch.FaceColor= [125/255 125/255 125/255];
            bb(2).sdPtch.FaceColor= [175/255 175/255 175/255];
            
            % axis
            box('off');
            ax=gca;
            ax.YLabel.String='diff: bl.3-bl.1';
            ax.XTickLabel={'TASK','CON'};
            ax.XLim=[.5,2.5];
            ax.FontSize=18;
            ax.FontWeight='bold';
            ax.LineWidth=2;
            %     rotateXLabels(ax,45);
            % title
            sup=suptitle({global_metrics{gl_idx},['p=' num2str(p(gl_idx))]});
            sup.Interpreter='none';
            
            % print
            [annot, srcInfo] = docDataSrc(fig(gl_idx),fullfile(outputDir),mfilename('fullpath'),logical(1));
            exportgraphics(fig(gl_idx),fullfile(outputDir,[global_metrics{gl_idx} '_comp_reappraisalVScontrol.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['GA_globalALL_comp_reappraisalVScontrol']),'-painters','-r400','-append');
        end
    end
end