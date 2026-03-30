%% plot_unpairedTT_locMetGA_reappraisalVScontrol_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Path setting
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));

%% Selection of input
% cormat version
cormat_selection_control = 'cormat_v6';
cormat_selection_task = 'cormat_v11'
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness_val = 'connected';

% comparison selection
comparison_names={'TPnoPuff11to40VSTPnoPuff81to120'};%,'Odor11to40VSOdor81to120'};

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36];%,1,31];
maxthr_ind_range=[41];%,41,41];

% sorting
sorting= [4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11,32:33,29:31,34:35,38:41,45:52,22:23,36,37,44];

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
        outputDir = fullfile(taskDir,['local_compTaskVsControl_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
        if exist(outputDir)~=7
            mkdir(outputDir);
        end
        cd(outputDir);
        
        %% load data
        load(fullfile(controlDir,['local_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)],'res_auc_struc_local.mat'));
        l_con = res_auc_struc;
        load(fullfile(taskDir,['local_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)],'res_auc_struc_local.mat'));
        l_task = res_auc_struc;
        
        % local metric definition and region names
        local_metrics=fieldnames(l_task);
        findVS = strfind(comparison_names{compIdx},'VS');
        region_names=fieldnames(l_task.(local_metrics{1}).(comparison_names{compIdx}(findVS+2:end)));
        
        % sorting
        region_names = region_names(sorting);
        
        % Loop over local metrics
        for ix = 1:length(local_metrics)
            
            % loop over regions
            for rx=1:length(region_names)
                % calculate diff for task and con
                findVS = strfind(comparison_names{compIdx},'VS');
                l_task_diff =l_task.(local_metrics{ix}).(comparison_names{compIdx}(findVS+2:end)).(region_names{rx})-l_task.(local_metrics{ix}).(comparison_names{compIdx}(1:findVS-1)).(region_names{rx});
                l_con_diff =l_con.(local_metrics{ix}).(comparison_names{compIdx}(findVS+2:end)).(region_names{rx})-l_con.(local_metrics{ix}).(comparison_names{compIdx}(1:findVS-1)).(region_names{rx});                
                % t-statistics
                [h(ix,rx),p(ix,rx),~,t_temp]=ttest2(l_task_diff,l_con_diff);
                tval(ix,rx)=t_temp.tstat;
            end
            % FDR threshold
            FDR_threshold = FDR(p(ix,:),0.05);
            
            % figure
            fig(ix)=figure('visible','on');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
            
            H3=barh([1:length(region_names)],flip([-tval(ix,:)]'));
            box('off');
%             colorMap = [[linspace(0,1,128)';linspace(1,38/128,128)'],[linspace(64/128,1,128)';linspace(1,38/128,128)'],[linspace(64/128,1,128)';linspace(1,38/128,128)']];
            colorMap = [[linspace(0,1,128)';linspace(255/255,122/255,128)'],[linspace(42/128,1,128)';linspace(255/255,46/255,128)'],[linspace(42/128,1,128)';linspace(255/255,84/255,128)']];
            
            H3.CData=vals2colormap_jr(flip([-tval(ix,:)]'), colorMap, [-5,5]);
            H3.FaceColor='Flat';
            H3.EdgeColor='none';
            ax=gca;
            ax.YTick=[1:length(region_names)];
            ax.YTickLabel=flip(region_names);
            %     ax.TickLabelInterpreter='none';
            ax.FontSize=10;
            ax.XTick=[-5:5];
            ax.XTickLabel=[-5:5];
            ax.XLim=[-1*ceil(max(abs([tval(ix,:)]'))),1*ceil(max(abs([tval(ix,:)]')))];
            
            l1=line([tinv(1-(1-.95)/2,24-1),tinv(1-(1-.95)/2,24-1)],[ax.YLim]);
            l1.LineStyle='--';
            if ~isempty(FDR_threshold)
                l2=line([tinv(1-(FDR_threshold),24-1),tinv(1-(FDR_threshold),24-1)],[ax.YLim]);
            end
            l3=line([tinv((1-.95)/2,24-1),tinv((1-.95)/2,24-1)],[ax.YLim]);
            l3.LineStyle='--';
            if ~isempty(FDR_threshold)
                l4=line([tinv(FDR_threshold,24-1),tinv(FDR_threshold,24-1)],[ax.YLim]);
            end
            
            % title
            tt=title(local_metrics{ix});
            tt.Interpreter='none';
            tt.FontSize=14;
            
            % print
            [annot, srcInfo] = docDataSrc(fig(ix),fullfile(outputDir),mfilename('fullpath'),logical(1));
            exportgraphics(fig(ix),fullfile(outputDir,['GA_' local_metrics{ix} '_TaskVsCon.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['GA_local_TaskVsCon']),'-painters','-r400','-append');
            
            % save source data in csv
            SourceData = array2table(tval(ix,:)','VariableNames',local_metrics(ix),'RowNames',region_names);
            writetable(SourceData,fullfile(outputDir,['SourceData_GA_' local_metrics{ix} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
                        
            % close
            close all;
        end
    end
end
