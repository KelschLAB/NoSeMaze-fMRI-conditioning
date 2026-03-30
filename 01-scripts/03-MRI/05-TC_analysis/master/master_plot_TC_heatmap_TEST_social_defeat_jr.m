%% master_plot_TC_heatmap_social_defeat_jr.m
% Jonathan Reinwald, 01/2023
% Script for plotting heatmaps of BOLD signal (corrected for motion, CSF,
% ...)

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-TC_analysis'))

% select input
inputDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/08-TC_analysis/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v99___COV_v1___ORTH_1___25-Jan-2023/meanTC';
subDir = dir(inputDir);
subDir(strcmp({subDir.name},'.')) = [];
subDir(strcmp({subDir.name},'..')) = [];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')

%% Option 1: Normal Davids Score
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day1to35.mat','DS_info');
% DS_info1 = DS_info;

% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to28.mat','DS_info');
% DS_info2 = DS_info;

% ExplVar(1).name = 'DavidsScore';
% ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
% ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
%
% ExplVar(2).name = 'DavidsScore_Zscored';
% ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
% ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];

%% Option 2: Difference between Davids Score before and after social defeat (10 days)
clear DS_before DS_after DS_info1
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day26to35.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day38to47.mat','DS_info');
DS_after = DS_info;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info1.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info1.DS_before = DS_before.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS]);
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS]);
            [~,Rank_before]=sort(Idx_before);
            DS_info1.RankDiff = [Rank_after-Rank_before];
            DS_info1.RankBefore = Rank_before;
        end
    else
        DS_info1.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

clear DS_before DS_after DS_info2
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day19to28.mat','DS_info');
DS_before = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day31to40.mat','DS_info');
DS_after = DS_info;
myFieldnames = fieldnames(DS_after);
for fnIdx = 1:length(myFieldnames)
    if ~contains(myFieldnames{fnIdx},'ID')
        DS_info2.(myFieldnames{fnIdx}) = [DS_after.(myFieldnames{fnIdx})]-[DS_before.(myFieldnames{fnIdx})];
        DS_info2.DS_before = DS_before.DS;
        if fnIdx==1
            [~,Idx_after]=sort([DS_after.DS]);
            [~,Rank_after]=sort(Idx_after);
            [~,Idx_before]=sort([DS_before.DS]);
            [~,Rank_before]=sort(Idx_before);
            DS_info2.RankDiff = [Rank_after-Rank_before];
            DS_info2.RankBefore = Rank_before;
        end
    else
        DS_info2.(myFieldnames{fnIdx}) = DS_after.(myFieldnames{fnIdx});
    end
end

ExplVar(1).name = 'Diff_DavidsScore';
ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(1).values,'descend');
ExplVar(1).DS_sorted = myDS_sorted;
ExplVar(1).DS_sortedIndex = myDS_Idx;

ExplVar(2).name = 'Diff_DavidsScore_Zscored';
ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(2).values,'descend');
ExplVar(2).DS_sorted = myDS_sorted;
ExplVar(2).DS_sortedIndex = myDS_Idx;

ExplVar(3).name = 'Diff_DavidsScore_Ranks';
ExplVar(3).values = [[DS_info1.RankDiff]';[DS_info2.RankDiff]'];
ExplVar(3).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(3).values,'descend');
ExplVar(3).DS_sorted = myDS_sorted;
ExplVar(3).DS_sortedIndex = myDS_Idx;

ExplVar(4).name = 'DavidsScoreBefore';
ExplVar(4).values = [[DS_info1.DS_before]';[DS_info2.DS_before]'];
ExplVar(4).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(4).values,'descend');
ExplVar(4).DS_sorted = myDS_sorted;
ExplVar(4).DS_sortedIndex = myDS_Idx;

ExplVar(5).name = 'Ranks';
ExplVar(5).values = [[DS_info1.RankBefore]';[DS_info2.RankBefore]'];
ExplVar(5).ID = [[DS_info1.ID];[DS_info2.ID]];
[myDS_sorted,myDS_Idx]=sort(ExplVar(5).values,'descend');
ExplVar(5).DS_sorted = myDS_sorted;
ExplVar(5).DS_sortedIndex = myDS_Idx;

%% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

for ix=3%1:length(ExplVar)
    %% Loop over subdirectories (regions of interest)
    for subReg = 67:70%1:length(subDir)
        
        % delet ps file
        if exist(fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowResWithMotion.ps']))
            delete(fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowResWithMotion.ps']))
            delete(fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowRes.ps']))
        end
        
        
        % Load input: FD and TC are already sorted by animal number (see
        % tc_matrsess_info.AnimalNumb
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
        
        % Sorting of explanatory variable
        clear B Idx
        % Sort in order of animal numb (ascending)
        [AnimalNumb_sorted,Idx]=sort([ExplVar(ix).AnimalNumb],'ascend');
        % apply sorting index to sort ExplVar.values (e.g., Ranks,
        % DiffRank, etc.) in the order of animal numb
        ExplVar_sorted = [ExplVar(ix).values(Idx)];
        % resort the sorted hierarchy to get Idx_resorted (--> which can be
        % applied to TC/FD to bring the in order of ascending hierarchy)
        [ExplVar_resorted,Idx_resorted] =sort(ExplVar_sorted,'ascend');
        
        %% FD as overall median
        % FD low/high
%         FDmedian=squeeze(nanmedian(nanmedian(nanmedian(FD_matrsess_all))));
%         FD_matrsess_all_low = double(FD_matrsess_all<FDmedian);
%         for jx=1:length(FD_matrsess)
%             FD_matrsess_low(jx).mat = double(FD_matrsess(jx).mat<FDmedian);
%         end
%         FD_matrsess_all_high = double(FD_matrsess_all>FDmedian);
%         for jx=1:length(FD_matrsess)
%             FD_matrsess_high(jx).mat = double(FD_matrsess(jx).mat>FDmedian);
%         end
%         FD_matrsess_all_high(FD_matrsess_all_high==0)=nan;
%         FD_matrsess_all_low(FD_matrsess_all_low==0)=nan;
%         for jx=1:length(FD_matrsess)
%             FD_matrsess_high(jx).mat(FD_matrsess_high(jx).mat==0)=nan;
%             FD_matrsess_low(jx).mat(FD_matrsess_low(jx).mat==0)=nan;
%         end
        %% FD as median per animal and time bin
        FDmedian=squeeze(nanmedian(FD_matrsess_all,2));
        for kx=1:size(FDmedian,1)
            for lx=1:size(FDmedian,2)
                FD_matrsess_all_low(kx,:,lx) = double(FD_matrsess_all(kx,:,lx)<FDmedian(kx,lx));
                FD_matrsess_all_high(kx,:,lx) = double(FD_matrsess_all(kx,:,lx)>FDmedian(kx,lx));
            end
        end
        
        for jx=1:length(FD_matrsess)
            clear FDOdorMedian
            FDOdorMedian = squeeze(nanmedian(FD_matrsess(jx).mat,2));
            for kx=1:size(FDmedian,1)
                for lx=1:size(FDmedian,2)
                    FD_matrsess_low(jx).mat(kx,:,lx) = double(FD_matrsess(jx).mat(kx,:,lx)<FDOdorMedian(kx,lx));
                    FD_matrsess_high(jx).mat(kx,:,lx) = double(FD_matrsess(jx).mat(kx,:,lx)>FDOdorMedian(kx,lx));
                end
            end
        end

        FD_matrsess_all_high(FD_matrsess_all_high==0)=nan;
        FD_matrsess_all_low(FD_matrsess_all_low==0)=nan;
        for jx=1:length(FD_matrsess)
            FD_matrsess_high(jx).mat(FD_matrsess_high(jx).mat==0)=nan;
            FD_matrsess_low(jx).mat(FD_matrsess_low(jx).mat==0)=nan;
        end

        
        %% Plot
        
        for subfig=1:4
            % clearing
            clear h p myMat myMat_s
            
            % figure
            fig1=figure('visible', 'off');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.7,0.9]);
            
            % Loop over subplots
            for odor_num = 1:3
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% subplot 1
                subplot(2,2,odor_num)
                
                % matrix
                if subfig==1
                    myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat_highres_lin(Idx_resorted,:,:),2));
                elseif subfig==2
                    myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat(Idx_resorted,:,:),2));
                elseif subfig==3
                    myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat(Idx_resorted,:,:).*FD_matrsess_low(odor_num).mat(Idx_resorted,:,:),2));
                elseif subfig==4
                    myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat(Idx_resorted,:,:).*FD_matrsess_high(odor_num).mat(Idx_resorted,:,:),2));
                end
                
                % smoothing
                %                 for ix=1:size(myMat{odor_num},2)
                %                     myMat_s{odor_num}(:,ix)=smooth(myMat{odor_num}(:,ix),3);
                %                 end
                myMat_s=myMat;
                
                % plot
                imagesc(myMat{odor_num}(:,:));
                
                % axes
                % define resolution and onset frame
                if subfig==1
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
                
                ax.XTick=[1:resolution:size(myMat_s{odor_num},2)];
                ax.XTickLabel=[-2.4:1.2:8.4];
                ax.XLabel.String='time [s]';
                %         ax.XLim=[6.5,48.5];
                
                ax.YTick=[1:1:size(myMat_s{odor_num},1)];
                ax.YTickLabel=ExplVar_resorted;
                ax.YLabel.String=ExplVar(ix).name;
                rotateXLabels(ax,30);
                
                % plot puff and odor
                hold on;
                pt=patch([onset,onset+(2.4*resolution)/1.2,onset+(2.4*resolution)/1.2,onset],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.6,0.2]);
                pt.FaceAlpha=0.4; pt.EdgeAlpha=0;
                txp=text([(onset)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.15],'Odor');
                txp.Color=[0.1,0.6,0.1];
                txp.FontSize=10;
                txp.FontWeight='bold';
                
                % lines
                hold on;
                ll=line([ax.XLim(1),ax.XLim(2)],[40.5,40.5],'color',[0.2,0.2,0.2],'LineStyle',':','LineWidth',1.5);
                ll=line([ax.XLim(1),ax.XLim(2)],[68.5,68.5],'color',[0.2,0.2,0.2],'LineStyle',':','LineWidth',1.5);
                ll=line([ax.XLim(1),ax.XLim(2)],[80.5,80.5],'color',[0.2,0.2,0.2],'LineStyle',':','LineWidth',1.5);
                
                % title
                title(tc_matrsess(odor_num).odor)
                
                % statistics
                clear h p
                [h,p]=corr(ExplVar_resorted,myMat{odor_num});
                
                for px=1:length(p)
                    if p(1,px)<0.001
                        hold on;
                        text(px-0.3,size(myMat{odor_num},1)+0.4,'*');
                        hold on;
                        text(px-0.3,size(myMat{odor_num},1),'*');
                        hold on;
                        text(px-0.3,size(myMat{odor_num},1)-0.4,'*');
                    elseif p(1,px)<0.01
                        hold on;
                        text(px-0.3,size(myMat{odor_num},1)+0.2,'*');
                        hold on;
                        text(px-0.3,size(myMat{odor_num},1)-0.2,'*');
                    elseif p(1,px)<0.05
                        hold on;
                        text(px-0.3,size(myMat{odor_num},1),'*');
                    end
                end
                
            end
            
            % super title
            if subfig<3
                suptitle(subDir(subReg).name);
            elseif subfig==3
                suptitle([subDir(subReg).name ' ,low motion']);
            elseif subfig==4
                suptitle([subDir(subReg).name ' ,high motion']);
            end
            
            % print
            if subfig==1
                print('-dpsc',fullfile(subDir(subReg).folder,subDir(subReg).name,['CORRELATION_' ExplVar(ix).name  'HeatMaps_HighRes']),'-painters','-r400','-bestfit');
                print('-dpdf',fullfile(subDir(subReg).folder,subDir(subReg).name,['CORRELATION_' ExplVar(ix).name 'HeatMaps_HighRes']),'-painters','-r400','-bestfit');
            else
                print('-dpsc',fullfile(subDir(subReg).folder,subDir(subReg).name,['CORRELATION_' ExplVar(ix).name 'HeatMaps_LowResWithMotion']),'-painters','-r400','-bestfit','-append');
                if subfig==2
                    print('-dpdf',fullfile(subDir(subReg).folder,subDir(subReg).name,['CORRELATION_' ExplVar(ix).name 'HeatMaps_LowRes']),'-painters','-r400','-bestfit');
                end
            end
        end
    end
end
