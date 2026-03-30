%% plot_histogram_MetricDistribution_jr.m

% Script for investigating local metrics
% Reinwald, 06/2022

% Before running the script calculate beta coefficients and global metrics:

% 1. run master_calculate_and_plot_mean_betas_jr.m to calculate and save
% beta coefficients in GLM folder (under respictive comparison, e.g.
% TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40) --> mask_activation_Ins_T3485_v24.mat

% 2. run plot_pairedTT_globMetGA_reappraisal_jr.m to calculate and save
% global graph metrics in
% /home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/cormat_v8/combined_hemisphere/bin_connected
% --> res_auc_struc.mat

%% Clearing
close all
clear all
clc

%% Comparison selection
name_TP{1}='TPnoPuff11to40';
name_TP{2}='TPnoPuff81to120';
name_TP{3}='Odor11to40';
name_TP{4}='Odor81to120';
% name_TP1='Odor11to40';
% name_TP2='TPnoPuff11to40';
% name_TP1='Odor81to120';
% name_TP2='TPnoPuff81to120';
% name_TP1='Odor11to40';
% name_TP2='Odor81to120';

%% Selection of input
% cormat version
cormat_version = 'cormat_v8';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness = 'connected';
% metric selection
local_metrics={'l_degree','l_strength','l_cc','l_bci','l_PI'};
binWidth_all = [1,1,0.01,10,0.01];

%% Load gstruc metrics (saved in plot_pairedTT_globMetGA_reappraisal_jr.m)
% res_auc_struc_global.mat -->  res_auc_struc
if separated_hemisphere==1
    cd(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness ]);
elseif separated_hemisphere==0
    cd(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness ]);
end
for ix=1:length(name_TP)
    load(['gstruc_' name_TP{ix} '_p.mat'])
    gstruc_all{ix}=gstruc;
end

%% Output directory
if separated_hemisphere==1
    outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/histograms'];
elseif separated_hemisphere==0
    outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/histograms'];
end
mkdir(outputDir);
cd(outputDir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for lx=1:length(local_metrics);
    clear d
    
    for tx=1:length(name_TP)
        for ix=1:size(gstruc_all{tx},1)
            for jx=1:size(gstruc_all{tx},2)
                d{tx}(ix,jx,:)=[gstruc_all{tx}(ix,jx).(local_metrics{lx})];
            end
        end
    end
    
    figure(1);
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    for ix=1:size(gstruc_all{1},1)
        subplot(4,3,ix);
        hh=histogram(d{1}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        hold on;
        hh=histogram(d{2}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        tt=title(['thres: ' num2str(gstruc(ix,1).o_cutoffs*100) '%']);
        % legend
        if ix==1
            ll=legend({name_TP{1},name_TP{2}},'Location','northeast');
        end
    end
    sp=suptitle([local_metrics{lx}(3:end) ' distribution']);
    sp.Interpreter='none';
    % print
    print('-dpsc',fullfile(outputDir,[local_metrics{lx}(3:end) '_distribution']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,[local_metrics{lx}(3:end) '1_distribution']),'-painters','-r400');    
    
    figure(2);
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    for ix=1:size(gstruc_all{1},1)
        subplot(4,3,ix);
        hh=histogram(d{3}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        hold on;
        hh=histogram(d{4}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        tt=title(['thres: ' num2str(gstruc(ix,1).o_cutoffs*100) '%']);
        % legend
        if ix==1
            ll=legend({name_TP{3},name_TP{4}},'Location','northeast');
        end
    end
    sp=suptitle([local_metrics{lx}(3:end) ' distribution']);
    sp.Interpreter='none';
    % print
    print('-dpsc',fullfile(outputDir,[local_metrics{lx}(3:end) '_distribution']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,[local_metrics{lx}(3:end) '2_distribution']),'-painters','-r400');    
    
    figure(3);
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    for ix=1:size(gstruc_all{1},1)
        subplot(4,3,ix);
        hh=histogram(d{3}(ix,:,:)-d{1}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        hold on;
        hh=histogram(d{4}(ix,:,:)-d{2}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        tt=title(['thres: ' num2str(gstruc(ix,1).o_cutoffs*100) '%']);
        % legend
        if ix==1
            ll=legend({[name_TP{3} '-' name_TP{1}],[name_TP{4} '-' name_TP{2}]},'Location','northeast');
        end
    end
    sp=suptitle([local_metrics{lx}(3:end) ' distribution']);
    sp.Interpreter='none';
    % print
    print('-dpsc',fullfile(outputDir,[local_metrics{lx}(3:end) '_distribution']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,[local_metrics{lx}(3:end) '3_distribution']),'-painters','-r400');    
    
    figure(4);
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    for ix=1:size(gstruc_all{1},1)
        subplot(4,3,ix);
        hh=histogram(d{1}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        hold on;
        hh=histogram(d{2}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        hold on;
        hh=histogram(d{3}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        hold on;
        hh=histogram(d{4}(ix,:,:),'BinWidth',binWidth_all(lx));
        hh.EdgeColor='none';
        tt=title(['thres: ' num2str(gstruc(ix,1).o_cutoffs*100) '%']);
        % legend
        if ix==1
            ll=legend({name_TP{1},name_TP{2},name_TP{3},name_TP{4}},'Location','northeast');
        end
    end
    sp=suptitle([local_metrics{lx}(3:end) ' distribution']);
    sp.Interpreter='none';
    % print
    print('-dpsc',fullfile(outputDir,[local_metrics{lx}(3:end) '_distribution']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,[local_metrics{lx}(3:end) '4_distribution']),'-painters','-r400');
    
    close all
end
