%% master_plot_TC_heatmap_social_hierarchy_jr.m
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
inputDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/08-TC_analysis/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v99___COV_v1___ORTH_1___25-Jan-2023/meanTC';
subDir = dir(inputDir);
subDir(strcmp({subDir.name},'.')) = [];
subDir(strcmp({subDir.name},'..')) = [];



%% Loop over subdirectories (regions of interest)
for subReg = 1:length(subDir)
    
    % delet ps file
    if exist(fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowResWithMotion.ps']))
        delete(fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowResWithMotion.ps']))
        delete(fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowRes.ps']))
    end

    
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
    
    % FD low/high
    FDmedian=squeeze(nanmedian(nanmedian(nanmedian(FD_matrsess_all))));
    FD_matrsess_all_low = double(FD_matrsess_all<FDmedian);
    for jx=1:length(FD_matrsess)
        FD_matrsess_low(jx).mat = double(FD_matrsess(jx).mat<FDmedian);
    end
    FD_matrsess_all_high = double(FD_matrsess_all>FDmedian);
    for jx=1:length(FD_matrsess)
        FD_matrsess_high(jx).mat = double(FD_matrsess(jx).mat>FDmedian);
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
        for odor_num = 1:2
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% subplot 1
            subplot(2,2,odor_num)
            
            % matrix
            if subfig==1
                myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat_highres_lin,1));
            elseif subfig==2
                myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat,1));
            elseif subfig==3
                myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat.*FD_matrsess_low(odor_num).mat,1));
            elseif subfig==4
                myMat{odor_num} = squeeze(nanmedian(tc_matrsess(odor_num).mat.*FD_matrsess_high(odor_num).mat,1));
            end
                
            % smoothing
            for ix=1:size(myMat{odor_num},2)
                myMat_s{odor_num}(:,ix)=smooth(myMat{odor_num}(:,ix),3);
            end
            %         if subpl>1
            %             for jx=1:size(myMat_s,1)
            %                 myMat_s(jx,:)=smooth(myMat_s(jx,:),3);
            %             end
            %         end
            
            % plot
            imagesc(myMat_s{odor_num}(:,:));
            
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
            
            ax.YTick=[0:10:size(myMat_s{odor_num},1)];
            ax.YTickLabel=[0:10:size(myMat_s{odor_num},1)];
            ax.YLabel.String='trials';
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
        end
        
        % statistics
        clear pperm observeddifference effectsize
        counter=1;
        for ix=1:size(myMat,2)
            for jx=ix+1:size(myMat,2)
                for kx=1:size(myMat{ix},2)
                    sample1 = myMat{ix}(:,kx);
                    sample2 = myMat{jx}(:,kx);
                    [pperm(counter,kx), observeddifference(counter,kx), effectsize(counter,kx)] = permutationTest(sample1(~isnan(sample1)), sample2(~isnan(sample2)), 10000);
                end
                counter=counter+1;
            end
        end
        
        % plot effect size
        subplot(2,2,4);
        
        imagesc(effectsize);
        ax=gca;
        box(ax,'off');
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        ax.Colormap=parula;
        cbar = colorbar;
        cbar.Label.String=['Effect Size'];
        
        ax.XTick=[1:resolution:size(myMat_s{odor_num},2)];
        ax.XTickLabel=[-2.4:1.2:8.4];
        ax.XLabel.String='time [s]';
        rotateXLabels(ax,30);

        ax.YTick=1;
        ax.YTickLabel={'Low-High'};
        ax.YTickLabelRotation=50;
        
        for ix=1:size(pperm,1)
            for jx=1:size(pperm,2)
                if pperm(ix,jx)<0.001
                    hold on;
                    text(jx-0.3,ix+0.2,'*');
                    hold on; 
                    text(jx-0.3,ix,'*');
                    hold on;
                    text(jx-0.3,ix-0.2,'*');
                elseif pperm(ix,jx)<0.01
                    hold on;
                    text(jx-0.3,ix+0.1,'*');
                    hold on;
                    text(jx-0.3,ix-0.1,'*');
                elseif pperm(ix,jx)<0.05
                    hold on;
                    text(jx-0.3,ix,'*');
                end
            end
        end
        
        title('group diff.')

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
            print('-dpsc',fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_HighRes']),'-painters','-r400','-bestfit');
            print('-dpdf',fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_HighRes']),'-painters','-r400','-bestfit');
        else
            print('-dpsc',fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowResWithMotion']),'-painters','-r400','-bestfit','-append');
            if subfig==2
                print('-dpdf',fullfile(subDir(subReg).folder,subDir(subReg).name,['HeatMaps_LowRes']),'-painters','-r400','-bestfit');
            end
        end
    end

end
