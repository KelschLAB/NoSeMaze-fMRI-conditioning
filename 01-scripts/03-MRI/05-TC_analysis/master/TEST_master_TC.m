%% master_plot_TC_reappraisal_jr.m


% Selection of mean TC 
resultsDir = spm_select(1,'dir','Select Directory with mean time courses',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/');

% List of regions
regionlist = dir([resultsDir filesep 'meanTC']);
% delete ./..
regionlist = regionlist(~contains({regionlist.name},'.'));

%% Loop over folders of regions
for rx = 1:length(regionlist)
    % clearing
    clear tc_temp sd workDir ;
    
    % workdir
    workDir = [regionlist(rx).folder filesep regionlist(rx).name];
    
    % load 
    load([workDir filesep 'tc_matrsess_all_BINS6_TRsbefore2.mat']);
    load([workDir filesep 'FD_matrsess_all_BINS6_TRsbefore2.mat']);
   
    % figure
    fig=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
        
    tc_mat_selected = tc_matrsess_all_highres_lin;
    
    %% Actual Plot
    subplot(2,2,1);
    % Loop over 4 different shadedErrorBars (for different trials, 11:40,
    % 41:80 (Puff), 41:80 (noPuff), 81:120)
    for hx=1:4
        % set counter
        counter=1;
        % Loop over animals
        for ix=1:24
            % Define: 
            % Trials 11:40
            tp_covered{1}{ix}=[11:40]; tp_color{1}=[0,0,0.8];
            % Trials 41:80 with Puff
            tp_covered{2}{ix}=find(puff_matrsess_all(ix,:)==1); tp_color{2}=[0.2,0.2,0.2];
            % Trials 41:80 without Puff
            tp_covered{3}{ix}=find(puff_matrsess_all(ix,:)==0); tp_color{3}=[0.5,0.5,0.5];
            % Trials 81:120
            tp_covered{4}{ix}=[81:120];tp_color{4}=[0.8,0,0];
            
            % Define temporary tc matrix
            tc_temp{hx}(counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_covered{hx}{ix},:),2));
            % update counter
            counter=counter+1;
        end
        
        hold on;
        % Plot 
        sd{hx}=shadedErrorBar([1:size(tc_mat_selected,3)],smooth(nanmean(tc_temp{hx})),SEM_calc(tc_temp{hx}));
        sd{hx}.mainLine.Color=tp_color{hx};
        sd{hx}.patch.FaceColor=tp_color{hx};
        sd{hx}.edge(1).Color='none';
        sd{hx}.edge(2).Color='none';
        % Change LineStyles
        if hx==2 | hx==3
            sd{hx}.mainLine.LineStyle='--';sd{hx}.mainLine.LineWidth=0.7;
        else
            sd{hx}.mainLine.LineWidth=1;
        end
    end
    
    % Set axis
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    ax.YLim=[-0.5,1];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[1:6:size(tc_matrsess_all_highres_lin,3)];
    ax.XTickLabel=([1:6:size(tc_matrsess_all_highres_lin,3)]-13).*(1.2/6);
    
    % Add Patch and Line for Odor and Puff
    hold on; 
    ll=line([tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
    txl=text([(tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff');
    txl.Color=[0.2,0.6,0.2];
    hold on;
    pt=patch([tc_matrsess_info.OnsetFrame,tc_matrsess_info.OnsetFrame+(2.4*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame+(2.4*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.6,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text([(tc_matrsess_info.OnsetFrame)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Odor');
    txp.Color=[0.2,0.6,0.2];
    
    % Title
    tt = title(['Mean TC: ' regionlist(rx).name]);
    tt.Interpreter='none';
    
    % Legend
    lgd=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine],{'Tr.11-40.','Tr.41-80(Puff)','Tr.41-80(NoPuff)','Tr.81-120.'},'Location','northeast');
    lgd.FontSize=6;
    
    % Sign. *
    clear h p
    [h,p]=ttest(tc_temp{1},tc_temp{4});
    for px=1:length(p)
        if p(px)<0.001
            text(px-1,ax.YLim(2)*0.95,'*');
            text(px-1,ax.YLim(2)*0.9,'*');
            text(px-1,ax.YLim(2)*0.85,'*');
        elseif p(px)<0.01
            text(px-1,ax.YLim(2)*0.95,'*');
            text(px-1,ax.YLim(2)*0.9,'*');
        elseif p(px)<0.05
            text(px-1,ax.YLim(2)*0.95,'*');
        end
    end

    %% Actual Plot    
    subplot(2,2,3);
    % Loop over 5 different shadedErrorBars (for different trials, 81:90,
    % 91:100, 101:110, 111:120; 81:120)
    for hx=1:5
        % set counter
        counter=1;
        % Loop over animals
        for ix=1:24
            % Define: 
            % Trials 11:40
            tp_covered{1}{ix}=[81:90];tp_color{1}=[0,0,1];
            tp_covered{2}{ix}=[91:100];tp_color{2}=[0,0,0.5];
            tp_covered{3}{ix}=[101:110];tp_color{3}=[0,0.5,0];
            tp_covered{4}{ix}=[111:120];tp_color{4}=[0,1,0];
            tp_covered{5}{ix}=[81:120];tp_color{5}=[0.8,0,0];            
            
            % Define temporary tc matrix
            tc_temp{hx}(counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_covered{hx}{ix},:),2));
            % update counter
            counter=counter+1;
        end
        
        hold on;
        % Plot 
        sd{hx}=shadedErrorBar([1:size(tc_mat_selected,3)],smooth(nanmean(tc_temp{hx})),SEM_calc(tc_temp{hx}));
        sd{hx}.mainLine.Color=tp_color{hx};
        sd{hx}.patch.FaceColor=tp_color{hx};
        sd{hx}.edge(1).Color='none';
        sd{hx}.edge(2).Color='none';
        % Change LineStyles
        if hx~=5
            sd{hx}.mainLine.LineStyle='--';sd{hx}.mainLine.LineWidth=0.7;
        else
            sd{hx}.mainLine.LineWidth=1;
        end
    end
    
    % Set axis
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    ax.YLim=[-0.5,1];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[1:6:size(tc_matrsess_all_highres_lin,3)];
    ax.XTickLabel=([1:6:size(tc_matrsess_all_highres_lin,3)]-13).*(1.2/6);
    
    % Add Patch and Line for Odor and Puff
    hold on; 
    ll=line([tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
    txl=text([(tc_matrsess_info.OnsetFrame+(2.5*tc_matrsess_info.highres)/1.2)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff');
    txl.Color=[0.2,0.6,0.2];
    hold on;
    pt=patch([tc_matrsess_info.OnsetFrame,tc_matrsess_info.OnsetFrame+(2.4*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame+(2.4*tc_matrsess_info.highres)/1.2,tc_matrsess_info.OnsetFrame],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.6,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text([(tc_matrsess_info.OnsetFrame)*1.05],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Odor');
    txp.Color=[0.2,0.6,0.2];
    
    % Title
    tt = title(['Mean TC: ' regionlist(rx).name]);
    tt.Interpreter='none';
    
    % Legend
    lgd=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine],{'Tr.81-90.','Tr.91-100','Tr.101-110.','Tr.111-120','FULL Bl.3'},'Location','northeast');
    lgd.FontSize=6;
    
% %     % Sign. *
% %     clear h p
% %     [h,p]=ttest(tc_temp{1},tc_temp{4});
% %     for px=1:length(p)
% %         if p(px)<0.001
% %             text(px-1,ax.YLim(2)*0.95,'*');
% %             text(px-1,ax.YLim(2)*0.9,'*');
% %             text(px-1,ax.YLim(2)*0.85,'*');
% %         elseif p(px)<0.01
% %             text(px-1,ax.YLim(2)*0.95,'*');
% %             text(px-1,ax.YLim(2)*0.9,'*');
% %         elseif p(px)<0.05
% %             text(px-1,ax.YLim(2)*0.95,'*');
% %         end
% %     end

    % Save
    if 1==1
        print('-dpsc',fullfile([workDir filesep],[regionlist(rx).name '.ps']) ,'-r400')
    end
end


