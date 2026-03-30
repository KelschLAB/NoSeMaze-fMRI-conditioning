
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
% inputDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_med1000_msk_s6_wrst_a1_u_del5____ROI_v99___COV_v1___ORTH_1___11-Jan-2022/meanTC';
subDir = dir(inputDir);
subDir(strcmp({subDir.name},'.')) = [];
subDir(strcmp({subDir.name},'..')) = [];
subDir(contains({subDir.name},'info_')) = [];


%% Loop over subdirectories (regions of interest)
for subReg = 57%1:length(subDir) 57=maskactivationv22Bl3vsBl1T01; 60=maskactivationv22Odor11to40T001; 83=maskdeactivationv22Odor11to40T001;
    
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
    clear tc_matrsess tc_matrsess tc_matrsess_highres tc_matrsess_highres tc_matrsess_highres_lin tc_matrsess_highres_lin tc_matrsess_highres_spline tc_matrsess_highres_spline
    for subj = 1:size(tc_matrsess_all_highres_lin,1)
        tc_matrsess(subj,[41:68],:)=tc_matrsess_all(subj,logical(puff_matrsess_all(subj,:)),:);
        tc_matrsess(subj,[1:40,69:120],:)=tc_matrsess_all(subj,logical(~puff_matrsess_all(subj,:)),:);
        tc_matrsess_highres(subj,[41:68],:)=tc_matrsess_all_highres(subj,logical(puff_matrsess_all(subj,:)),:);
        tc_matrsess_highres(subj,[1:40,69:120],:)=tc_matrsess_all_highres(subj,logical(~puff_matrsess_all(subj,:)),:);
        tc_matrsess_highres_lin(subj,[41:68],:)=tc_matrsess_all_highres_lin(subj,logical(puff_matrsess_all(subj,:)),:);
        tc_matrsess_highres_lin(subj,[1:40,69:120],:)=tc_matrsess_all_highres_lin(subj,logical(~puff_matrsess_all(subj,:)),:);
        tc_matrsess_highres_spline(subj,[41:68],:)=tc_matrsess_all_highres_spline(subj,logical(puff_matrsess_all(subj,:)),:);
        tc_matrsess_highres_spline(subj,[1:40,69:120],:)=tc_matrsess_all_highres_spline(subj,logical(~puff_matrsess_all(subj,:)),:);
        FD_matrsess(subj,[41:68],:)=FD_matrsess_all(subj,logical(puff_matrsess_all(subj,:)),:);
        FD_matrsess(subj,[1:40,69:120],:)=FD_matrsess_all(subj,logical(~puff_matrsess_all(subj,:)),:);
    end
    
    % FD low/high
    FDmedian=squeeze(nanmedian(nanmedian(nanmedian(FD_matrsess_all))));
    for ix=1:size(FD_matrsess_all,2)
        FD_matrsess_low(:,ix,:) = double(FD_matrsess_all(:,ix,:)<FDmedian);
    end
    for ix=1:size(FD_matrsess_all,2)
        FD_matrsess_high(:,ix,:) = double(FD_matrsess_all(:,ix,:)>FDmedian);
    end
    FD_matrsess_high(FD_matrsess_high==0)=nan;
    FD_matrsess_low(FD_matrsess_low==0)=nan;
    
    %% Plot
    % figure
    fig(1)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.9]);
    
    
    % Loop over subplots
    for subpl = 1:4
        
        % clearing
        clear h p myMat myMat_s
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% subplot 1
        subplot(2,2,subpl)
        
        % matrix
        if subpl==1
            myMat = squeeze(nanmedian(tc_matrsess_highres_lin,1));
        elseif subpl==2
            myMat = squeeze(nanmedian(tc_matrsess,1));
        elseif subpl==3
            myMat = squeeze(nanmedian(tc_matrsess.*FD_matrsess_low,1));
        elseif subpl==4
            myMat = squeeze(nanmedian(tc_matrsess.*FD_matrsess_high,1));
        end
        
        % smoothing
        for ix=1:size(myMat,2)
            myMat_s(:,ix)=smooth(myMat(:,ix),3);
        end
%         if subpl>1
%             for jx=1:size(myMat_s,1)
%                 myMat_s(jx,:)=smooth(myMat_s(jx,:),3);
%             end
%         end

        % plot
        imagesc(myMat_s(:,:));
        
        % save source data for plot
        clear SourceData
        SourceData = array2table(myMat_s);
        writetable(SourceData,fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_' subDir(subReg).name '_subplot' num2str(subpl) '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
        
        
        % axes
        % define resolution and onset frame
        if subpl==1
            resolution = tc_matrsess_info.highres;
            onset = tc_matrsess_info.OnsetFrame;
        else
            resolution = 1;
            onset = 3;
        end
        ax=gca;
        box(ax,'off');
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        cbar = colorbar;
        cbar.Label.String=['BOLD [A.U., zscored]'];
        
        ax.XTick=[1:resolution:size(myMat_s,2)]-.5;
        ax.XTickLabel=[-2.4:1.2:8.4];
        ax.XLabel.String='time [s]';
%         ax.XLim=[12.5,48.5];
        
        ax.YTick=[0:10:size(myMat_s,1)];
        ax.YTickLabel=[0:10:size(myMat_s,1)];
        ax.YLabel.String='trials';
        rotateXLabels(ax,30);
        
        % plot puff and odor
        % add patch and line for odor and air puff
        hold on;
        curr_resolution = size(myMat_s,2)/10;
        curr_onsetframe = 2*size(myMat_s,2)/10+1-0.5;
        ax.YLim=ax.YLim;
        ll=line([curr_onsetframe+(2.5*curr_resolution)/1.2,curr_onsetframe+(2.5*curr_resolution)/1.2],[40.5,68.5],'color',[1 1 1],'LineStyle','--','LineWidth',2);
        txl=text([(curr_onsetframe+(2.5*curr_resolution)/1.2)*1.05],[40.5+(68.5-40.5)*0.2],'Puff');
        txl.Color=[1 1 1];
        txl.FontWeight='bold';
        hold on;
        pt=patch([curr_onsetframe,curr_onsetframe+(2.4*curr_resolution)/1.2,curr_onsetframe+(2.4*curr_resolution)/1.2,curr_onsetframe],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text([(curr_onsetframe)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.2],'Odor');
        txp.Color=[0.2,0.2,0.2];
               
        % adaptation period
        pt=patch([ax.XLim(1),ax.XLim(2),ax.XLim(2),ax.XLim(1)],[ax.YLim(1),ax.YLim(1),10.5,10.5],[0,0,0]);
        pt.FaceAlpha=0.6; pt.EdgeAlpha=0;
        txp=text([(onset)*2.5],[ax.YLim(1)+5],'Adaptation');
        txp.Color=[0,0,0];
        txp.FontSize=8;
        txp.FontAngle='italic';
        
        % lines
        ll=line([ax.XLim(1),ax.XLim(2)],[40.5,40.5],'color',[0.2,0.2,0.2],'LineStyle',':','LineWidth',1.5);
        ll=line([ax.XLim(1),ax.XLim(2)],[68.5,68.5],'color',[0.2,0.2,0.2],'LineStyle',':','LineWidth',1.5);
        ll=line([ax.XLim(1),ax.XLim(2)],[80.5,80.5],'color',[0.2,0.2,0.2],'LineStyle',':','LineWidth',1.5);
        
        % statistics
        for ix=1:size(myMat,2)
            [pperm(ix), observeddifference(ix), effectsize(ix)] = permutationTest(myMat(11:40,ix), myMat(81:120,ix), 10000);
            if pperm(ix)<0.001
                tx=text(ix,ax.YLim(end)-1,'*');
                tx.FontSize=10;
                tx=text(ix,ax.YLim(end)-4,'*');
                tx.FontSize=10;
                tx=text(ix,ax.YLim(end)-7,'*');
                tx.FontSize=10;
            elseif pperm(ix)<0.01
                tx=text(ix,ax.YLim(end)-1,'*');
                tx.FontSize=10;
                tx=text(ix,ax.YLim(end)-4,'*');
                tx.FontSize=10;
            elseif pperm(ix)<0.05
                tx=text(ix,ax.YLim(end)-1,'*');
                tx.FontSize=10;
            end
        end
        % for selected mean values
        if subpl==1
            [pval_range, observeddifference_range, effectsize_range] = permutationTest(mean(myMat(11:40,32:37),2)',mean(myMat(81:120,32:37),2)', 10000);
        end
        
        % title
        if subpl==1
            title('high res.')
        elseif subpl==2
            title('low res.')
        elseif subpl==3
            title('low res., low motion')
        elseif subpl==4
            title('low res., high motion')
        end
        
    end
    % super title
    suptitle(subDir(subReg).name);

    % print
    [annot, srcInfo] = docDataSrc(fig(1),fullfile(subDir(subReg).folder,subDir(subReg).name),mfilename('fullpath'),logical(1))
    exportgraphics(fig(1),fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_' subDir(subReg).name '.pdf']),'Resolution',300);
    print('-dpsc',fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_' subDir(subReg).name]),'-painters','-r400','-bestfit');
end
