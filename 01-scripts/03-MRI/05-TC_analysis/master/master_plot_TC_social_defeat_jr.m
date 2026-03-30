%% master_plot_TC_social_defeat_jr.m
% Script for plotting mean time courses
% Jonathan Reinwald, last update: 28.04.2023

% Info:
% - be sure to run master_TC_analysis_social_defeat_jr.m before !!!
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
% close all
clc

% Selection of mean TC
resultsDir = spm_select(1,'dir','Select Directory with mean time courses',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/08-TC_analysis/03-results/');

% List of regions
regionlist = dir([resultsDir filesep 'meanTC']); %% Option 1: Residuals from SPM12
% regionlist = dir([resultsDir filesep 'meanTC_noResid']); %% Option 2: "real mean time course"

% delete ./..
regionlist = regionlist(~contains({regionlist.name},'.'));

% pooled data (Yes/No)
pooled_data=0;

% smoothing
smoothing_kernel=5;

% % % % protocol directory
% % % protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/01-processed_protocol_files';
% % %
% % % % load filelist (needed for trial identity)
% % % load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')

%% Loop over folders of regions (selection of regions to plot
for rx = 1:length(regionlist)
    % clearing
    clear tc_temp sd workDir ;
    
    % workdir
    workDir = [regionlist(rx).folder filesep regionlist(rx).name];
    
    % load
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
    fig(rx)=figure('visible', 'off');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.25,0.8]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% predefinition for subplots
    % colors
    basic_colors{1,1}=[204/255,51/255,0/255]; %129sv
    basic_colors{1,2}=[0/255,160/255,227/255]; %CD1 defeat
    basic_colors{1,3}=[227/255,160/255,0/255]; %CD1 unknown
    
    % 1: High resolution with interpolation, all trials
    tp_covered{1,1}=[1:30];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(1).data = {tc_matrsess.mat_highres_lin}; %.*lowFD_mat;%;
    tc_mat(1).name = 'highres,interpolation';
    myLegendNames{1}={'129 sv','CD1 def.','CD1 unk.'}
    
    % 2: High resolution without interpolation, all trials
    tp_covered{2,1}=[1:30];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(2).data = {tc_matrsess.mat_highres}; %.*lowFD_mat;%;
    tc_mat(2).name = 'highres';
    myLegendNames{2}={'129 sv','CD1 def.','CD1 unk.'}
    
    % 3: High resolution with interpolation, trials split
    tp_covered{3,1}=[1:3];
    tp_covered{3,2}=[4:30];
    %     tp_covered{3,3}=[21:30];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(3).data = {tc_matrsess.mat_highres}; %.*lowFD_mat;%;
    tc_mat(3).name = 'highres';
    myLegendNames{3}={'129sv,tr.1-3','129sv,tr.4-30','CD1def.,tr.1-3','CD1def.,tr.4-30','CD1unk.,tr.1-3','CD1unk.,tr.4-30'}
    
    % 4: High resolution without interpolation, all trials
    tp_covered{4,1}=[1:30];
    % Option for integrating motion split
    %     lowFD_mat=double(FD_matrsess_all_highres<nanmedian(FD_matrsess_all_highres(:)));
    %     lowFD_mat(lowFD_mat==0)=nan;
    % predefinition of the current matrix selected (e.g., tc_matrsess_all_highres_lin = with
    % linear interpolation; tc_matrsess_all_highres = no interpolation; tc_matrsess_all = low resolution)
    tc_mat(4).data = {tc_matrsess.mat}; %.*lowFD_mat;%;
    tc_mat(4).name = 'lowres';
    myLegendNames{4}={'129 sv','CD1 def.','CD1 unk.'}
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Loop over subplots
    for subpl=1:length(tc_mat)
        
        
        % clearing
        clear tc_temp tc_temp_unsmoothed tc_temp_pooled sd
        
        % subplot
        subplot(2,2,subpl);
        
        % set hx counter
        tp_counter=1;
        
        %% Loop over 3 different shadedErrorBars (for different odors)
        for hx=1:length(tc_mat(subpl).data)
            
            % definition of the current matrix selected
            tc_mat_selected =  tc_mat(subpl).data{hx};
            
            % %             % define empty matrix for pooled data
            % %             tc_temp_pooled{tp_counter}=[];
            
            % Loop over time pointy
            for kx=1:size(tp_covered,2)
                if ~isempty(tp_covered{subpl,kx})
                    % set animal counter
                    animal_counter=1;
                    % Loop over animals
                    for ix=1:24
                        
                        % Define temporary tc matrix
                        if contains(tc_mat(subpl).name,'interpolation') || contains(tc_mat(subpl).name,'lowres')
                            tc_temp{tp_counter}(animal_counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_covered{subpl,kx},:),2));
                        elseif ~contains(tc_mat(subpl).name,'interpolation') && ~contains(tc_mat(subpl).name,'lowres')
                            tc_temp{tp_counter}(animal_counter,:)=smooth(squeeze(nanmean(tc_mat_selected(ix,tp_covered{subpl,kx},:),2)),smoothing_kernel);
                            tc_temp_unsmoothed{tp_counter}(animal_counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_covered{subpl,kx},:),2));
                        end
                        % %                         % pooled data
                        % %                         tc_temp_pooled{tp_counter}=[tc_temp_pooled{tp_counter};squeeze(tc_mat_selected(ix,tp_covered{subpl,kx},:))];
                        % update counter
                        animal_counter=animal_counter+1;
                    end
                    %
                    hold on;
                    % Plot
                    % %                     if pooled_data==1
                    % %                         sd{tp_counter}=shadedErrorBar([1:size(tc_mat_selected,3)],(nanmean(tc_temp_pooled{tp_counter})),SEM_calc(tc_temp_pooled{tp_counter}));
                    % %                     else
                    sd{tp_counter}=shadedErrorBar([1:size(tc_mat_selected,3)],(nanmean(tc_temp{tp_counter})),SEM_calc(tc_temp{tp_counter}));
                    % %                     end
                    % coloring
                    sd{tp_counter}.mainLine.Color=basic_colors{1,hx};
                    sd{tp_counter}.patch.FaceColor=basic_colors{1,hx};
                    sd{tp_counter}.edge(1).Color='none';
                    sd{tp_counter}.edge(2).Color='none';
                    % Change LineStyles
                    if subpl==3 && kx==2
                        sd{tp_counter}.mainLine.LineStyle=':';sd{tp_counter}.mainLine.LineWidth=1.5;
                    elseif subpl==3 && kx==3
                        sd{tp_counter}.mainLine.LineStyle='--';sd{tp_counter}.mainLine.LineWidth=1.5;
                    else
                        sd{tp_counter}.mainLine.LineWidth=1.5;
                    end
                    %
                    tp_counter=tp_counter+1;
                end
            end
        end
        
        % Set axis
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        %     ax.YLim=[-0.5,1.5];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [s]';
        ax.XTick=[1:size(tc_mat_selected,3)/10:size(tc_mat_selected,3)];
        ax.XLim=[1,size(tc_mat_selected,3)];
        ax.XTickLabel=([1:size(tc_mat_selected,3)/10:size(tc_mat_selected,3)]-(2*(size(tc_mat_selected,3)/10)+1)).*(1.2/(size(tc_mat_selected,3)/10));
        ax.FontWeight='bold';
        ax.LineWidth=1.5;
        
        % Title
        tt = title(['Mean TC: ' regionlist(rx).name]);
        tt.Interpreter='none';
        
        % statistics
        clear h p
        if ~isempty(tp_covered{subpl,end})
            subplot_factor=size(tp_covered,2);
        else
            subplot_factor=1;
        end
        [h(1,:),p(1,:)]=ttest(tc_temp{1*subplot_factor},tc_temp{2*subplot_factor});
        [h(2,:),p(2,:)]=ttest(tc_temp{1*subplot_factor},tc_temp{3*subplot_factor});
        [h(3,:),p(3,:)]=ttest(tc_temp{2*subplot_factor},tc_temp{3*subplot_factor});
        clear p_values
        % %         if size(tc_temp{1},2)==60
        % %             [~, p_values(1), ~, ~] = permutest(nanmean(tc_temp{2*subplot_factor}(:,1:12),2)',nanmean(tc_temp{3*subplot_factor}(:,1:12),2)',true,0.025, 10000,true);
        % %             [~, p_values(2), ~, ~] = permutest(nanmean(tc_temp{2*subplot_factor}(:,22:27),2)',nanmean(tc_temp{3*subplot_factor}(:,22:27),2)',true,0.025, 10000,true);
        % %             [~, p_values(3), ~, ~] = permutest(nanmean(tc_temp{2*subplot_factor}(:,33:38),2)',nanmean(tc_temp{3*subplot_factor}(:,33:38),2)',true,0.025, 10000,true);
        % %         else
        % %             for perm_ix=1:size(tc_temp{1},2)
        % %                 [~, p_values(1), ~, ~] = permutest(nanmean(tc_temp{2*subplot_factor}(:,1:2),2)',nanmean(tc_temp{3*subplot_factor}(:,1:2),2)',true,0.025, 10000,true);
        % %                 [~, p_values(2), ~, ~] = permutest(nanmean(tc_temp{2*subplot_factor}(:,5),2)',nanmean(tc_temp{3*subplot_factor}(:,5),2)',true,0.025, 10000,true);
        % %                 [~, p_values(3), ~, ~] = permutest(nanmean(tc_temp{2*subplot_factor}(:,7),2)',nanmean(tc_temp{3*subplot_factor}(:,7),2)',true,0.025, 10000,true);
        % %             end
        % %         end
        % plot asterisks for t-test
        
        for ppx=1:size(p,1)
            for px=1:size(p,2)
                if p(ppx,px)<0.001
                    text(px,ax.YLim(2)*(0.97-(ppx-1)*0.08),'*');
                    text(px,ax.YLim(2)*(0.95-(ppx-1)*0.08),'*');
                    text(px,ax.YLim(2)*(0.93-(ppx-1)*0.08),'*');
                elseif p(ppx,px)<0.01
                    text(px,ax.YLim(2)*(0.96-(ppx-1)*0.08),'*');
                    text(px,ax.YLim(2)*(0.94-(ppx-1)*0.08),'*');
                elseif p(ppx,px)<0.05
                    text(px,ax.YLim(2)*(0.95-(ppx-1)*0.08),'*');
                end
            end
        end
        % %         % plot permutation values
        % %         if p_values(1)<0.05
        % %             text((size(tc_mat_selected,3)/10)*1,ax.YLim(1)+diff(ax.YLim)*0.15,['p_p=' num2str(round(p_values(1),4))]);
        % %         end
        % %         if p_values(2)<0.05
        % %             text((size(tc_mat_selected,3)/10)*3.5,ax.YLim(1)+diff(ax.YLim)*0.1,['p_p=' num2str(round(p_values(2),4))]);
        % %         end
        % %         if p_values(3)<0.05
        % %             text((size(tc_mat_selected,3)/10)*6,ax.YLim(1)+diff(ax.YLim)*0.05,['p_p=' num2str(round(p_values(3),4))]);
        % %         end
        
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
        legend_input=[];for i=1:length(sd); legend_input=[legend_input,sd{i}.mainLine]; end
        lgd=legend(legend_input,myLegendNames{subpl},'Location','southeast');
        lgd.FontSize=6;
        
        % asterisk description
        tx=text(1,ax.YLim(2)*(0.95),'129sv-CD1def','FontSize',6);
        tx=text(1,ax.YLim(2)*(0.95-0.08*1),'129sv-CD1unk','FontSize',6);
        tx=text(1,ax.YLim(2)*(0.95-0.08*2),'CD1def-CD1def','FontSize',6);
        
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
