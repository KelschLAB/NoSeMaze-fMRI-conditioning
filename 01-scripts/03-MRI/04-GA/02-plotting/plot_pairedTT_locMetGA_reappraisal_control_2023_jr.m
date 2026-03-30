% plot_pairedTT_locMetGA_reappraisal_control_2023_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Path setting
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));

%% Comparison selection
name_TP1='TPnoPuff11to40';
name_TP2='TPnoPuff81to120';
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[36];
maxthr_ind_range=[41];

% sorting
sorting= [4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11,32:33,29:31,34:35,38:41,45:52,22:23,36,37,44];

%% Selection of input
% cormat version
cormat_version = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';
% folder selection
if separated_hemisphere==1
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
    if separated_hemisphere==1
        outputDir = ['/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2];
    elseif separated_hemisphere==0
        outputDir = ['/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/' name_TP1 'VS' name_TP2];
    end
    outputDir = fullfile(outputDir,['local_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
    mkdir(outputDir);
    cd(outputDir);
    
    if exist(fullfile(outputDir,'GA_local.ps'))==2
        delete(fullfile(outputDir,'GA_local.ps'));
    end
    
    %% Load input data
    load(fullfile(inputDir,['auc_struc_' name_TP1 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP1 = auc_struc;
    load(fullfile(inputDir,['auc_struc_' name_TP2 '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
    auc_struc_TP2 = auc_struc;
    
    %% Selection of local metrics
    metricnames_all = fieldnames(auc_struc_TP1)
    local_metrics = metricnames_all(contains(fieldnames(auc_struc_TP1),'l_'))
    % throw out: null models, _JR (doubled), _clus,  _path (both for SWP)
    local_metrics=local_metrics(logical(~contains(local_metrics,'_cpl') .* ~contains(local_metrics,'_path') .* ~contains(local_metrics,'_null') .* ~contains(local_metrics,'_clus'))),
    
    %% Load regional names
    if separated_hemisphere==1
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version filesep 'beta4D/separated_hemisphere/roidata_' cormat_version(strfind(cormat_version,'v'):end) '_Odor81to120.mat']);
    elseif separated_hemisphere==0
        load(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version filesep 'beta4D/combined_hemisphere/roidata_' cormat_version(strfind(cormat_version,'v'):end) '_Odor81to120.mat']);
    end
    names = {subj(1).roi.name};
    
    % sorting
    names = names(sorting);
    
    if exist(fullfile(outputDir,'GA_local.ps'))==2
        delete(fullfile(outputDir,'GA_local.ps'));
    end
    
    %% Loop over local names for plotting
    for ig=1:length(local_metrics)
        clear h ax trial_group_1 trial_group_2
        
        %% T-test comparison of TP no Puff Bl.1 and Bl.3
        % ttest
        trial_group_1 = [auc_struc_TP1.(local_metrics{ig})]';
        trial_group_1 = trial_group_1(:,sorting);
        trial_group_2 = [auc_struc_TP2.(local_metrics{ig})]';
        trial_group_2 = trial_group_2(:,sorting);
        
        [h,p,ci,stats]=ttest(trial_group_1,trial_group_2);
        if 1==0
            for ix=1:size(trial_group_1,2)
                [clusters{ix}, p_values(ix), t_sums{ix}, permutation_distribution{ix}] = permutest(trial_group_1(:,ix)',trial_group_2(:,ix)',true,0.05,10000,true);
            end
            FDR_threshold_perm = FDR(p_values,0.05);
        end
        FDR_threshold = FDR(p,0.05);
        
        %% 1. Overview plot
        % figure
        fig(ig)=figure('visible','on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
        
        sp1=subplot(1,3,1)
        imagesc([p<0.05]');
        for ix=1:length(p)
            if p(ix)<=FDR_threshold
                tt=text(1,ix,'§');
                tt.FontSize=4;
                tt.FontWeight='bold';
                tt.Color=[1,0,0];
            end
        end
        ax=gca;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=names;
        ax.FontSize=4;
        colormap(sp1,gray)
        ax.CLim=[0,1];
        
        tx=text(0.2,130,'§ = p<0.05, FDR corrected');
        tx.Color=[1,0,0];
        
        sp2=subplot(1,3,2);
        H2=imagesc([stats.tstat]');
        for ix=1:length(p)
            if p(ix)<=FDR_threshold
                tt=text(1,ix,'§');
                tt.FontSize=4;
                tt.FontWeight='bold';
            end
        end
        ax2=gca;
        ax2.YTick=[1:length(names)];
        ax2.YTickLabel=names;
        ax2.FontSize=4;
        colormap(sp2,jet)
        ax2.CLim=[-5,5];
        colorbar
        
        % title
        tt=title(local_metrics{ig});
        tt.Interpreter='none';
        tt.FontSize=10;
        
        %
        clear local_metric_all_TP1 local_metric_all_TP2
        local_metric_all_TP1=[auc_struc_TP1.(local_metrics{ig})]';
        local_metric_all_TP2=[auc_struc_TP2.(local_metrics{ig})]';
        for hx=1:length(names)
            res_auc_struc.(local_metrics{ig}).(name_TP1).(names{hx}) = local_metric_all_TP1(:,hx);
            res_auc_struc.(local_metrics{ig}).(name_TP2).(names{hx}) = local_metric_all_TP2(:,hx);
        end
        
        sp3=subplot(1,3,3);
        H3=barh([1:length(names)],flip([stats.tstat]'));
        box('off');
        load('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers/myColormap_magentablue.mat');
        colorMap=myColormap;
        H3.CData=vals2colormap_jr(flip([stats.tstat]'), colorMap, [-5,5]);
        H3.FaceColor='Flat';
        H3.EdgeColor='none';
        for ix=1:length(p)
            if p(ix)<=FDR_threshold
                tt=text(1,length(names)+1-ix,'§');
                tt.FontSize=4;
                tt.FontWeight='bold';
            elseif p(ix)<=.05
                tt=text(1,length(names)+1-ix,'*');
                tt.FontSize=4;
                tt.FontWeight='bold';
            end
        end
        
        ax=gca;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=flip(names);
        %     ax.TickLabelInterpreter='none';
        ax.FontSize=4;
        ax.XTick=[-5:5];
        ax.XTickLabel=[-5:5];
        ax.XLabel.String={[name_TP2 ' vs ' name_TP1]};
        ax.XLim=[-1*ceil(max(abs([stats.tstat]'))),1*ceil(max(abs([stats.tstat]')))];
        
        l1=line([tinv(1-(1-.95)/2,24-1),tinv(1-(1-.95)/2,24-1)],[ax.YLim]);
        l1.LineStyle='--';
        if ~isempty(FDR_threshold)
            l2=line([tinv(1-(FDR_threshold/2),24-1),tinv(1-(FDR_threshold/2),24-1)],[ax.YLim]);
        end
        l3=line([tinv((1-.95)/2,24-1),tinv((1-.95)/2,24-1)],[ax.YLim]);
        l3.LineStyle='--';
        if ~isempty(FDR_threshold)
            l4=line([tinv(FDR_threshold/2,24-1),tinv(FDR_threshold/2,24-1)],[ax.YLim]);
        end
        
        % title
        tt=title(local_metrics{ig});
        tt.Interpreter='none';
        tt.FontSize=10;
        
        %
        clear local_metric_all_TP1 local_metric_all_TP2
        local_metric_all_TP1=[auc_struc_TP1.(local_metrics{ig})]';
        local_metric_all_TP2=[auc_struc_TP2.(local_metrics{ig})]';
        for hx=1:length(names)
            res_auc_struc.(local_metrics{ig}).(name_TP1).(names{hx}) = local_metric_all_TP1(:,hx);
            res_auc_struc.(local_metrics{ig}).(name_TP2).(names{hx}) = local_metric_all_TP2(:,hx);
        end
        
        % print
        [annot, srcInfo] = docDataSrc(fig(ig),fullfile(outputDir),mfilename('fullpath'),logical(1));
        exportgraphics(fig(ig),fullfile(outputDir,['GA_' local_metrics{ig} '_pairedTT.pdf']),'Resolution',300);
        print('-dpsc',fullfile(outputDir,['GA_local']),'-painters','-r400','-append');
        
        % save source data in csv
        SourceData = array2table(stats.tstat'.*-1,'VariableNames',local_metrics(ig),'RowNames',names);
        writetable(SourceData,fullfile(outputDir,['SourceData_GA_' local_metrics{ig} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
        
        % close
        close all;
        
    end
    save(fullfile(outputDir,'res_auc_struc_local.mat'),'res_auc_struc');
end
