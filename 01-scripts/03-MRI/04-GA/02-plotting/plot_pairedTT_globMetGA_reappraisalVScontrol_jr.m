%% plot_pairedTT_globMetGA_reappraisalVScontrol_jr.m% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

%% Comparison selection
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36];
maxthr_ind_range=[41];

%% Selection of input
% cormat version
cormat_version_task = 'cormat_v11';
cormat_version_control = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';
% folder selection
if separated_hemisphere==2
    inputDirTask = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness];
    inputDirControl = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness];
elseif separated_hemisphere==1
    inputDirTask = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
    inputDirControl = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
elseif separated_hemisphere==0
    inputDirTask = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    inputDirControl = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
end

%% Loop over threshold ranges
for mx = 1:length(minthr_ind_range)
    
    %% current thresholds
    minthr_ind = minthr_ind_range(mx)
    maxthr_ind = maxthr_ind_range(mx)
    
    %% Output directory
    if separated_hemisphere==2
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version_task filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '_taskVScontrol'];
    elseif separated_hemisphere==1
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version_task filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '_taskVScontrol'];
    elseif separated_hemisphere==0
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version_task filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2 '_taskVScontrol'];
    end
    outputDir = fullfile(outputDir,['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
    mkdir(outputDir);
    cd(outputDir);
    if exist(fullfile(outputDir,'GA_global.ps'))==2
        delete(fullfile(outputDir,'GA_global.ps'));
    end
    
    %% Load input data
    load(fullfile(inputDirTask,['auc_struc_' name_TP1 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP1_task = auc_struc;
    load(fullfile(inputDirTask,['auc_struc_' name_TP2 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP2_task = auc_struc;
    load(fullfile(inputDirControl,['auc_struc_' name_TP1 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP1_control = auc_struc;
    load(fullfile(inputDirControl,['auc_struc_' name_TP2 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP2_control = auc_struc;
    
    %% Selection of global metrics
    metricnames_all = fieldnames(auc_struc_TP1_task);
    global_metrics_task = metricnames_all(contains(fieldnames(auc_struc_TP1_task),'g_'));
    global_metrics_control = metricnames_all(contains(fieldnames(auc_struc_TP1_control),'g_'));
    global_metrics = global_metrics_task(strcmp(global_metrics_task,global_metrics_control));
    % throw out: null models, _JR (doubled), _clus,  _path (both for SWP)
    global_metrics=global_metrics(logical(~contains(global_metrics,'_null') .* ~contains(global_metrics,'swi_norm')));
%     global_metrics=global_metrics(logical(~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
    % global_metrics=global_metrics(logical(~contains(global_metrics,'_norm') .* ~contains(global_metrics,'_cpl') .* ~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
%     if strcmp(binarization_method,'max')
%         global_metrics(7)=[];
%     end
    
    %% Loop over global names for plotting
    for ig=[1:3,15:17]%:length(global_metrics)
        clear h ax
        
        if 1==1
            % figure
            fig(ig)=figure('visible', 'off');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.6]);
            
            % Loop: 
            for subpl_idx = 1:3
                subplot(1,3,subpl_idx);
                % boxplot
                if subpl_idx==1
                    bb{subpl_idx}=notBoxPlot_modified([[auc_struc_TP1_task.(global_metrics{ig})]',[auc_struc_TP2_task.(global_metrics{ig})]']);
                elseif subpl_idx==2
                    bb{subpl_idx}=notBoxPlot_modified([[auc_struc_TP1_control.(global_metrics{ig})]',[auc_struc_TP2_control.(global_metrics{ig})]']);                    
                elseif subpl_idx==3
                    bb{subpl_idx}=notBoxPlot_modified([[auc_struc_TP2_task.(global_metrics{ig})]'-[auc_struc_TP1_task.(global_metrics{ig})]',[auc_struc_TP2_control.(global_metrics{ig})]'-[auc_struc_TP1_control.(global_metrics{ig})]']);                  
                end

                
                
                for ib=1:length(bb{subpl_idx})
                    bb{subpl_idx}(ib).data.MarkerSize=8;
                    bb{subpl_idx}(ib).data.MarkerEdgeColor='none';
                    bb{subpl_idx}(ib).semPtch.EdgeColor='none';
                    bb{subpl_idx}(ib).sdPtch.EdgeColor='none';
                end
                
                if subpl_idx==1 || subpl_idx==2
                    % color definitions
                    bb{subpl_idx}(1).data.MarkerFaceColor= [204/255 51/255 204/255];
                    bb{subpl_idx}(1).mu.Color= [204/255 51/255 204/255];
                    bb{subpl_idx}(1).semPtch.FaceColor= [221/255 118/255 221/255];
                    bb{subpl_idx}(1).sdPtch.FaceColor= [247/255 221/255 247/255];
                    % color definitions
                    bb{subpl_idx}(2).data.MarkerFaceColor= [0 160/255 227/255];
                    bb{subpl_idx}(2).mu.Color= [0 160/255 227/255];
                    bb{subpl_idx}(2).semPtch.FaceColor= [90/255 194/255 237/255];
                    bb{subpl_idx}(2).sdPtch.FaceColor= [211/255 239/255 250/255];
                else
                    % color definitions
                    bb{subpl_idx}(1).data.MarkerFaceColor= [0/255 83/255 83/255];
                    bb{subpl_idx}(1).mu.Color= [0/255 83/255 83/255];
                    bb{subpl_idx}(1).semPtch.FaceColor= [104/255 154/255 154/255];
                    bb{subpl_idx}(1).sdPtch.FaceColor= [209/255 224/255 224/255];
                    bb{subpl_idx}(2).data.MarkerFaceColor= [122/255 46/255 84/255];
                    bb{subpl_idx}(2).mu.Color= [122/255 46/255 84/255];
                    bb{subpl_idx}(2).semPtch.FaceColor= [182/255 140/255 161/255];
                    bb{subpl_idx}(2).sdPtch.FaceColor= [222/255 202/255 213/255];
                end
                
                % axis
                box('off');
                ax(subpl_idx)=gca;
                ax(subpl_idx).YLabel.String='A.U.';
                if subpl_idx~=3
                    ax(subpl_idx).XTickLabel={'Bl. 1','Bl. 3'};
                elseif subpl_idx==3
                    ax(subpl_idx).XTickLabel={'task','con'};                    
                end
                ax(subpl_idx).XLim=[.5,2.5];
                ax(subpl_idx).FontSize=20;
                ax(subpl_idx).FontWeight='bold';
                ax(subpl_idx).LineWidth=4;
                
                % title
                if subpl_idx==1
                    tt=title('task');
                elseif subpl_idx==2
                    tt=title('control');
                elseif subpl_idx==3
                    tt=title('task vs control');
                end
                tt.Interpreter='none';
                                
                % significance test
                if subpl_idx==1
                    [h,p]=ttest([auc_struc_TP1_task.(global_metrics{ig})]',[auc_struc_TP2_task.(global_metrics{ig})]');
                    [clusters, p_values, t_sums, permutation_distribution ] = permutest([auc_struc_TP1_task.(global_metrics{ig})],[auc_struc_TP2_task.(global_metrics{ig})],true,0.05,10000,true);
                elseif subpl_idx==2
                    [h,p]=ttest([auc_struc_TP1_control.(global_metrics{ig})]',[auc_struc_TP2_control.(global_metrics{ig})]');
                    [clusters, p_values, t_sums, permutation_distribution ] = permutest([auc_struc_TP1_control.(global_metrics{ig})],[auc_struc_TP2_control.(global_metrics{ig})],true,0.05,10000,true);
                elseif subpl_idx==3
                    [h,p]=ttest2([auc_struc_TP2_task.(global_metrics{ig})]'-[auc_struc_TP1_task.(global_metrics{ig})]',[auc_struc_TP2_control.(global_metrics{ig})]'-[auc_struc_TP1_control.(global_metrics{ig})]');
                    [clusters, p_values, t_sums, permutation_distribution ] = permutest([auc_struc_TP2_task.(global_metrics{ig})]-[auc_struc_TP1_task.(global_metrics{ig})],[auc_struc_TP2_control.(global_metrics{ig})]-[auc_struc_TP1_control.(global_metrics{ig})],false,0.05,10000,true);
                end
                % sign. star
                if p_values<0.05
                    H=sigstar({[1,2]},p_values,0,30);
                end
                % plot permutation result
                tx=text(ax(subpl_idx).XLim(1)+.1*(diff(ax(subpl_idx).XLim)),ax(subpl_idx).YLim(1)+.2*(diff(ax(subpl_idx).YLim)),['p_p_e_r_m=' num2str(p_values)]);
                
                % ax limits
                if subpl_idx==2
                    ax(1).YLim = [min([ax(1).YLim,ax(2).YLim]),round(max([ax(1).YLim,ax(2).YLim]),1)+0.05];
                    ax(2).YLim = ax(1).YLim;
                end
            end
            % suptitle
            suptt=suptitle({global_metrics{ig};[name_TP1 ' vs ' name_TP2]});
            suptt.Interpreter='none';
            
            % print
            [annot, srcInfo] = docDataSrc(fig(ig),fullfile(outputDir),mfilename('fullpath'),logical(1));
            exportgraphics(fig(ig),fullfile(outputDir,['GA_global_' global_metrics{ig} '.pdf']),'Resolution',300);
            print('-dpsc',fullfile(outputDir,['GA_global']),'-painters','-r400','-bestfit','-append');
            
            % save source data in csv
            SourceData = array2table([[auc_struc_TP1_task.(global_metrics{ig})]',[auc_struc_TP2_task.(global_metrics{ig})]',[auc_struc_TP1_control.(global_metrics{ig})]',[auc_struc_TP2_control.(global_metrics{ig})]',[auc_struc_TP2_task.(global_metrics{ig})]'-[auc_struc_TP1_task.(global_metrics{ig})]',[auc_struc_TP2_control.(global_metrics{ig})]'-[auc_struc_TP1_control.(global_metrics{ig})]'],'VariableNames',{'pre_task','test_task','pre_con','test_con','diff_task','diff_con'});
            writetable(SourceData,fullfile(outputDir,['SourceData_GA_global_' global_metrics{ig} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
            
            % close
            close all;
        end
        
        % results for saving
        res_auc_struc.(global_metrics{ig}).task.(name_TP1) = [auc_struc_TP1_task.(global_metrics{ig})]';
        res_auc_struc.(global_metrics{ig}).task.(name_TP2) = [auc_struc_TP2_task.(global_metrics{ig})]';
        res_auc_struc.(global_metrics{ig}).control.(name_TP1) = [auc_struc_TP1_control.(global_metrics{ig})]';
        res_auc_struc.(global_metrics{ig}).control.(name_TP2) = [auc_struc_TP2_control.(global_metrics{ig})]';
    end
    % save data
    save(fullfile(outputDir,['res_auc_struc_global.mat']),'res_auc_struc');
end