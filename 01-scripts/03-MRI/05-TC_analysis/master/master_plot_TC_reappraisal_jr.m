%% master_plot_TC_reappraisal_jr.m
% Script for plotting mean time courses
% Jonathan Reinwald, last update: 21.04.2023

% Info:
% - be sure to run master_TC_analysis_reappraisal_jr.m before !!!
%
% Two options:
% - either resulting from SPM12 residuals --> select: regionlist =
% dir([resultsDir filesep 'meanTC'])
% - or using the "real mean time course" (no SPM before, but also no
% covariates of no interest include) --> regionlist = dir([resultsDir
% filesep 'meanTC_noResid'])
% - one can also select to pool the data (not prefered)
%
% Four plots are created:
% Plot 1:

% clearing
clear all
close all
clc

% Selection of mean TC
resultsDir = spm_select(1,'dir','Select Directory with mean time courses',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/');

% List of regions
regionlist = dir([resultsDir filesep 'meanTC']); %% Option 1: Residuals from SPM12
% regionlist = dir([resultsDir filesep 'meanTC_noResid']); %% Option 2: "real mean time course"

% delete ./..
regionlist = regionlist(~contains({regionlist.name},'.'));

% pooled data (Yes/No)
pooled_data=0;

% smoothing
smoothing_kernel=5;

%% Loop over folders of regions (selection of regions to plot
for rx = [26]%57 = aIC; 63=S1; 86=PFC; 76=Amyg; 26=OB; 1=AON;
    % clearing
    clear tc_temp sd workDir ;
    
    % workdir
    workDir = [regionlist(rx).folder filesep regionlist(rx).name];
    
    % load tc file and FD file
    load([workDir filesep 'tc_matrsess_all_BINS6_TRsbefore2.mat']);
    load([workDir filesep 'FD_matrsess_all_BINS6_TRsbefore2.mat']);
    
    % Additional baseline normalization (if prefered), especially for the
    % _noResid (basic mean TC) necessary
    if contains({regionlist.folder},'noResid')
        for txx=1:size(tc_matrsess_all,1)
            for uxx=1:size(tc_matrsess_all,2)
                % Option 1: whole TC used for normalization
                %                 perc_values=((tc_matrsess_all(txx,uxx,:)-mean(tc_matrsess_all(txx,uxx,[1:10])))./(mean(tc_matrsess_all(txx,uxx,[1:10])))).*100;
                %                 tc_matrsess_all(txx,uxx,:)=perc_values;%mean(perc_values(1:2));
                %                 perc_values=((tc_matrsess_all_highres(txx,uxx,:)-nanmean(tc_matrsess_all_highres(txx,uxx,[1:60])))./(nanmean(tc_matrsess_all_highres(txx,uxx,[1:60])))).*100;
                %                 tc_matrsess_all_highres(txx,uxx,:)=perc_values;%nanmean(perc_values(1:12));
                %                 perc_values=((tc_matrsess_all_highres_lin(txx,uxx,:)-nanmean(tc_matrsess_all_highres_lin(txx,uxx,[1:60])))./(nanmean(tc_matrsess_all_highres_lin(txx,uxx,[1:60])))).*100;
                %                 tc_matrsess_all_highres_lin(txx,uxx,:)=perc_values;%nanmean(perc_values(1:12));
                %                 perc_values=((tc_matrsess_all_highres_spline(txx,uxx,:)-nanmean(tc_matrsess_all_highres_spline(txx,uxx,[1:60])))./(nanmean(tc_matrsess_all_highres_spline(txx,uxx,[1:60])))).*100;
                %                 tc_matrsess_all_highres_spline(txx,uxx,:)=perc_values;%nanmean(perc_values(1:12));
                % Option 2: first 2 TRs used for normalizationm
                perc_values=((tc_matrsess_all(txx,uxx,:)-mean(tc_matrsess_all(txx,uxx,[1:2])))./(mean(tc_matrsess_all(txx,uxx,[1:2])))).*100;
                tc_matrsess_all(txx,uxx,:)=perc_values;%mean(perc_values(1:2));
                perc_values=((tc_matrsess_all_highres(txx,uxx,:)-nanmean(tc_matrsess_all_highres(txx,uxx,[1:12])))./(nanmean(tc_matrsess_all_highres(txx,uxx,[1:12])))).*100;
                tc_matrsess_all_highres(txx,uxx,:)=perc_values;%nanmean(perc_values(1:12));
                perc_values=((tc_matrsess_all_highres_lin(txx,uxx,:)-nanmean(tc_matrsess_all_highres_lin(txx,uxx,[1:12])))./(nanmean(tc_matrsess_all_highres_lin(txx,uxx,[1:12])))).*100;
                tc_matrsess_all_highres_lin(txx,uxx,:)=perc_values;%nanmean(perc_values(1:12));
                perc_values=((tc_matrsess_all_highres_spline(txx,uxx,:)-nanmean(tc_matrsess_all_highres_spline(txx,uxx,[1:12])))./(nanmean(tc_matrsess_all_highres_spline(txx,uxx,[1:12])))).*100;
                tc_matrsess_all_highres_spline(txx,uxx,:)=perc_values;%nanmean(perc_values(1:12));
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% figure settings
    fig(rx)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.8]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% predefinition for subplots
    % 1:
    tp_covered{1,1}=[11:40];tp_color{1,1}=[204/255,51/255,204/255];
    tp_covered{1,2}='puff';tp_color{1,2}=[0.2,0.2,0.2];
    tp_covered{1,3}='nopuff';tp_color{1,3}=[0.5,0.5,0.5];
    tp_covered{1,4}=[81:120];tp_color{1,4}=[0/255,160/255,227/255];
    tp_covered{1,5}=[1:10];tp_color{1,5}=[1,0.5,0.5];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(1).mat = tc_matrsess_all_highres_lin; %.*lowFD_mat;%;
    tc_mat(1).name = 'highres,interpolation';
    myLegendNames{1}={'Tr.11-40.','Tr.41-80(Puff)','Tr.41-80(NoPuff)','Tr.81-120.','Tr.1-10'};
    
    % 2:
    tp_covered{2,1}=[11:40];tp_color{2,1}=[204/255,51/255,204/255];
    tp_covered{2,2}='puff';tp_color{2,2}=[0.2,0.2,0.2];
    tp_covered{2,3}='nopuff';tp_color{2,3}=[0.5,0.5,0.5];
    tp_covered{2,4}=[81:120];tp_color{2,4}=[0/255,160/255,227/255];
    tp_covered{2,5}=[1:10];tp_color{2,5}=[1,0.5,0.5];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(2).mat = tc_matrsess_all_highres; %.*lowFD_mat;%;
    tc_mat(2).name = 'highres';
    myLegendNames{2}={'Tr.11-40.','Tr.41-80(Puff)','Tr.41-80(NoPuff)','Tr.81-120.','Tr.1-10'};
    
    % 3:
    tp_covered{3,1}=[1:10];tp_color{3,1}=[1,0,0];
    tp_covered{3,2}=[11:20];tp_color{3,2}=[0.5,0.5,0];
    tp_covered{3,3}=[21:30];tp_color{3,3}=[0,0.5,0.5];
    tp_covered{3,4}=[31:40];tp_color{3,4}=[0,0,1];
    tp_covered{3,5}=[81:120];tp_color{3,5}=[0.5,0.5,0.5];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(3).mat = tc_matrsess_all_highres; %.*lowFD_mat;%;
    tc_mat(3).name = 'highres';
    myLegendNames{3}={'Tr.1-10.','Tr.11-20','Tr.21-30','Tr.31-40.','Tr.81-120'};
    
    % 4:
    tp_covered{4,1}=[11:40];tp_color{4,1}=[204/255,51/255,204/255];
    tp_covered{4,2}='puff';tp_color{4,2}=[0.2,0.2,0.2];
    tp_covered{4,3}='nopuff';tp_color{4,3}=[0.5,0.5,0.5];
    tp_covered{4,4}=[81:120];tp_color{4,4}=[0/255,160/255,227/255];
    tp_covered{4,5}=[1:10];tp_color{4,5}=[1,0.5,0.5];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(4).mat = tc_matrsess_all; %.*lowFD_mat;%;
    tc_mat(4).name = 'lowres';
    myLegendNames{4}={'Tr.11-40.','Tr.41-80(Puff)','Tr.41-80(NoPuff)','Tr.81-120.','Tr.1-10'};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Loop over subplots
    for subpl=1:size(tp_covered,1)
        
        % clearing
        clear tc_temp tc_temp_unsmoothed tc_temp_pooled
        
        % definition of the current matrix selected
        tc_mat_selected =  tc_mat(subpl).mat;
        
        % subplot
        subplot(2,2,subpl);
        %% Loop over 4 different shadedErrorBars (for different trials, 11:40,
        % 41:80 (Puff), 41:80 (noPuff), 81:120)
        for hx=1:size(tp_covered,2)
            % clearing
            
            % set counter
            counter=1;
            % define empty matrix for pooled data
            tc_temp_pooled{hx}=[];
            % Loop over animals
            for ix=1:24
                % puff selection --> replace 'puff' by the specific trials
                if strcmp(tp_covered{subpl,hx},'puff')
                    tp_selection{subpl,hx}=find(puff_matrsess_all(ix,:)==1);
                elseif strcmp(tp_covered{subpl,hx},'nopuff')
                    tp_selection{subpl,hx}=find(puff_matrsess_all(ix,:)==0);
                    tp_selection{subpl,hx}=tp_selection{subpl,hx}(tp_selection{subpl,hx}>40 & tp_selection{subpl,hx}<81);
                else
                    tp_selection{subpl,hx} = tp_covered{subpl,hx};
                end
                % Define temporary tc matrix
                if contains(tc_mat(subpl).name,'interpolation') || contains(tc_mat(subpl).name,'lowres')
                    tc_temp{hx}(counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_selection{subpl,hx},:),2));
                elseif ~contains(tc_mat(subpl).name,'interpolation') && ~contains(tc_mat(subpl).name,'lowres')
                    tc_temp{hx}(counter,:)=smooth(squeeze(nanmean(tc_mat_selected(ix,tp_selection{subpl,hx},:),2)),smoothing_kernel);
                    tc_temp_unsmoothed{hx}(counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_selection{subpl,hx},:),2));
                end
                % pooled data
                tc_temp_pooled{hx}=[tc_temp_pooled{hx};squeeze(tc_mat_selected(ix,tp_selection{subpl,hx},:))];
                % update counter
                counter=counter+1;
            end
            hold on;
            % Plot
            if pooled_data==1
                sd{hx}=shadedErrorBar([1:size(tc_mat_selected,3)],(nanmean(tc_temp_pooled{hx})),SEM_calc(tc_temp_pooled{hx}));
                % save source data for plot
                SourceData = array2table(tc_temp_pooled{hx});
                writetable(SourceData,fullfile(workDir,['SourceData_' regionlist(rx).name '_Pooled_TP' num2str(hx) '_Subpl' num2str(subpl) '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
            else
                sd{hx}=shadedErrorBar([1:size(tc_mat_selected,3)],(nanmean(tc_temp{hx})),SEM_calc(tc_temp{hx}));
                % save source data for plot
                SourceData = array2table(tc_temp{hx});
                writetable(SourceData,fullfile(workDir,['SourceData_' regionlist(rx).name '_TP' num2str(hx) '_Subpl' num2str(subpl) '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
            end
            % coloring
            sd{hx}.mainLine.Color=tp_color{subpl,hx};
            sd{hx}.patch.FaceColor=tp_color{subpl,hx};
            sd{hx}.edge(1).Color='none';
            sd{hx}.edge(2).Color='none';
            % Change LineStyles
            if subpl~=3 && hx==2 || subpl~=3 && hx==3
                sd{hx}.mainLine.LineStyle='--';sd{hx}.mainLine.LineWidth=1.5;
            else
                sd{hx}.mainLine.LineWidth=1.5;
            end
        end
        
        % Set axis
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        %     ax.YLim=[-0.5,1.5];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [s]';
        ax.XTick=[1:size(tc_mat_selected,3)/10:size(tc_mat_selected,3)]-.5;
        ax.XLim=[1,size(tc_mat_selected,3)];
        ax.XTickLabel=([1:size(tc_mat_selected,3)/10:size(tc_mat_selected,3)]-(2*(size(tc_mat_selected,3)/10)+1)).*(1.2/(size(tc_mat_selected,3)/10));
        ax.FontWeight='bold';
        ax.LineWidth=1.5;
        
        % Title
        tt = title(['Mean TC: ' regionlist(rx).name]);
        tt.Interpreter='none';
        
        % statistics
        clear h p
        if pooled_data==1
            [h,p]=ttest2(tc_temp_pooled{1},tc_temp_pooled{4});
        else
            [h,p]=ttest(tc_temp{1},tc_temp{4});
            clear p_values
            if size(tc_temp{1},2)==60
                if rx~=76
                    [~, p_values(1), ~, ~] = permutest(nanmean(tc_temp{1}(:,1:12),2)',nanmean(tc_temp{4}(:,1:12),2)',true,0.025, 10000,true);
                    [~, p_values(2), ~, ~] = permutest(nanmean(tc_temp{1}(:,20:25),2)',nanmean(tc_temp{4}(:,20:25),2)',true,0.025, 10000,true);
                    [~, p_values(3), ~, ~] = permutest(nanmean(tc_temp{1}(:,32:37),2)',nanmean(tc_temp{4}(:,32:37),2)',true,0.025, 10000,true);
                else
                    [~, p_values(1), ~, ~] = permutest(nanmean(tc_temp{3}(:,1:12),2)',nanmean(tc_temp{4}(:,1:12),2)',true,0.025, 10000,true);
                    [~, p_values(2), ~, ~] = permutest(nanmean(tc_temp{3}(:,20:25),2)',nanmean(tc_temp{4}(:,20:25),2)',true,0.025, 10000,true);
                    [~, p_values(3), ~, ~] = permutest(nanmean(tc_temp{3}(:,32:37),2)',nanmean(tc_temp{4}(:,32:37),2)',true,0.025, 10000,true);
                end
            else
                for perm_ix=1:size(tc_temp{1},2)
                    
                    if rx~=76
                        [~, p_values(1), ~, ~] = permutest(nanmean(tc_temp{1}(:,1:2),2)',nanmean(tc_temp{4}(:,1:2),2)',true,0.025, 10000,true);
                        [~, p_values(2), ~, ~] = permutest(nanmean(tc_temp{1}(:,5),2)',nanmean(tc_temp{4}(:,5),2)',true,0.025, 10000,true);
                        [~, p_values(3), ~, ~] = permutest(nanmean(tc_temp{1}(:,7),2)',nanmean(tc_temp{4}(:,7),2)',true,0.025, 10000,true);
                    else
                        [~, p_values(1), ~, ~] = permutest(nanmean(tc_temp{3}(:,1:2),2)',nanmean(tc_temp{4}(:,1:2),2)',true,0.025, 10000,true);
                        [~, p_values(2), ~, ~] = permutest(nanmean(tc_temp{3}(:,5),2)',nanmean(tc_temp{4}(:,5),2)',true,0.025, 10000,true);
                        [~, p_values(3), ~, ~] = permutest(nanmean(tc_temp{3}(:,7),2)',nanmean(tc_temp{4}(:,7),2)',true,0.025, 10000,true);
                    end
                end
            end
        end
        % plot asterisks for t-test
        for px=1:length(p)
            if p(px)<0.001
                text(px,ax.YLim(2)*0.95,'*');
                text(px,ax.YLim(2)*0.9,'*');
                text(px,ax.YLim(2)*0.85,'*');
            elseif p(px)<0.01
                text(px,ax.YLim(2)*0.95,'*');
                text(px,ax.YLim(2)*0.9,'*');
            elseif p(px)<0.05
                text(px,ax.YLim(2)*0.95,'*');
            end
        end
        % plot permutation values
        if p_values(1)<0.05
            text((size(tc_mat_selected,3)/10)*1,ax.YLim(1)+diff(ax.YLim)*0.15,['p_p=' num2str(round(p_values(1),4))]);
        end
        if p_values(2)<0.05
            text((size(tc_mat_selected,3)/10)*3.5,ax.YLim(1)+diff(ax.YLim)*0.1,['p_p=' num2str(round(p_values(2),4))]);
        end
        if p_values(3)<0.05
            text((size(tc_mat_selected,3)/10)*6,ax.YLim(1)+diff(ax.YLim)*0.05,['p_p=' num2str(round(p_values(3),4))]);
        end
        
        % add patch and line for odor and air puff
        hold on;
        curr_resolution = size(tc_mat_selected,3)/10;
        curr_onsetframe = 2*size(tc_mat_selected,3)/10+1-0.5;
        ax.YLim=ax.YLim;
        ll=line([curr_onsetframe+(2.5*curr_resolution)/1.2,curr_onsetframe+(2.5*curr_resolution)/1.2],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.2,0.2],'LineStyle','--','LineWidth',2);
        txl=text([(curr_onsetframe+(2.5*curr_resolution)/1.2)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff');
        txl.Color=[0.2,0.2,0.2];
        hold on;
        pt=patch([curr_onsetframe,curr_onsetframe+(2.4*curr_resolution)/1.2,curr_onsetframe+(2.4*curr_resolution)/1.2,curr_onsetframe],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text([(curr_onsetframe)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Odor');
        txp.Color=[0.2,0.2,0.2];
        
        % Legend
        lgd=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine],myLegendNames{subpl},'Location','northeast');
        lgd.FontSize=6;
        
    end
    % print
    [annot, srcInfo] = docDataSrc(fig(rx),workDir,mfilename('fullpath'),logical(1))
    exportgraphics(fig(rx),fullfile([workDir filesep],['meanTC_' regionlist(rx).name '_smooth' num2str(smoothing_kernel) '.pdf']),'Resolution',300);
    %     print('-dpsc',fullfile([workDir filesep],['meanTC_' regionlist(rx).name '_smooth' num2str(smoothing_kernel)]),'-painters','-r400');
    
    
    %     % save script in the current output folder
    %     FileNameAndLocation=[mfilename('fullpath')];
    %     [~,fname,~]=fileparts(FileNameAndLocation);
    %     newbackup=[workDir filesep fname '.m'];
    %     currentfile=strcat(FileNameAndLocation, '.m');
    %     if ~exist(newbackup)
    %         copyfile(currentfile,newbackup);
    %     end
    %     cd(workDir);
    
    close all
end


