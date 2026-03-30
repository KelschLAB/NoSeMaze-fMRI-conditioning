
%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-TC_analysis'))

% select input
inputDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC';
subDir = dir(inputDir);
subDir(strcmp({subDir.name},'.')) = [];
subDir(strcmp({subDir.name},'..')) = [];



%% Loop over subdirectories (regions of interest)
for subReg = 1:length(subDir)
    
    % Load input:
    % FD:
    % - FD_matrsess_all_highres.mat
    % - FD_matrsess_all.mat
    load(fullfile(subDir(subReg).folder,subDir(subReg).name,'FD_matrsess_all_BINS6_TRsbefore2.mat'));
    
    % BOLD data:
    % - tc_matrsess_all.mat
    % - tc_matrsess_all_highres.mat
    % - tc_matrsess_all_highres_lin.mat
    % - tc_matrsess_all_highres_spline.mat
    % - tc_matrsess_info, puff_matrsess_all.mat
    load(fullfile(subDir(subReg).folder,subDir(subReg).name,'tc_matrsess_all_BINS6_TRsbefore2.mat'));
    
    % sort data:
    % first 40 trials, then puff (28 trials), then no puff (12 trials),
    % then last 40 trials
    for subj = 1:size(tc_matrsess_all_highres_lin,1)
        puff_trials(subj,:,:)=tc_matrsess_all_highres_lin(subj,logical(puff_matrsess_all(subj,:)),:);
    end
    
    %% Plot
    % figure
    fig1=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);
    
    % Loop over subplots
    for subpl = 1:4
        
        % clearing
        clear h p myMat myMat_s
        
        % subplot
        subplot(2,2,subpl)
        
        % matrix
        if subpl==1
            myMat = squeeze(nanmedian(tc_matrsess_all_highres_lin,1));
        elseif subpl==2
            
        elseif subpl==3
            
        elseif subpl==4
            
        end
        
        % smoothing
        for ix=1:size(myMat,2)
            myMat_s(:,ix)=smooth(myMat(:,ix),3);
        end
        
        % plot
        imagesc(myMat_s(:,:));
        
        % axes
        %         set(gca,'dataAspectRatio',[1 1 1])
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        colorbar;
        
        ax.XTick=[1:6:size(myMat_s,2)];
        ax.XTickLabel=[-2.4:1.2:8.4];
        ax.YLabel.String='time [s]';
        
        ax.YTick=[1:10:size(myMat_s,1)];
        ax.YTickLabel=[1:10:size(myMat_s,1)];
        ax.YLabel.String='trials';
        
        % plot puff and odor
        hold on;
        ll=line([tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
        txl=text([(tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff');
        txl.Color=[0.2,0.6,0.2];
        hold on;
        pt=patch([tc_matrsess_info.OnsetFrame,tc_matrsess_info.OnsetFrame+(2.4*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame+(2.4*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.6,0.2]);
        pt.FaceAlpha=0.3; pt.EdgeAlpha=0;
        txp=text([(tc_matrsess_info.OnsetFrame)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Odor');
        txp.Color=[0.2,0.6,0.2];
        
        % statistics
        for ix=1:10;
            [pperm(2,ix), observeddifference(2,ix), effectsize(2,ix)] = permutationTest(myMat(1:30,ix), myMat(71:110,ix), 10000);
        end
        
        
        
        
        
        suptitle(subDir(subReg).name);
        % Statistics
    end
end
