%% master_plot_TC_social_hierarchy_jr.m


% Selection of mean TC 
resultsDir = spm_select(1,'dir','Select Directory with mean time courses',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/08-TC_analysis/03-results/');

% List of regions
regionlist = dir([resultsDir filesep 'meanTC']);
% delete ./..
regionlist = regionlist(~contains({regionlist.name},'.'));

% protocol directory
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/01-processed_protocol_files';

% load filelist (needed for trial identity)
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')

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
    fig=figure('visible', 'off');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
        
    tc_mat_selected = tc_matrsess_all_highres_lin;
    
    %% Actual Plot
    subplot(2,2,1);
    % Loop over 4 different shadedErrorBars (for different trials)
    for hx=1:3
        % set counter
        counter=1;
        % Loop over animals
        for ix=1:length(Pfunc_social_hierarchy)
               
            % Load protocol file
            [fpath,fname,ext]=fileparts(Pfunc_social_hierarchy{ix});
            protocol_file = dir([protocol_dir filesep 'animal_' fname(5:6) filesep '*_new.mat']);
            load([protocol_file.folder filesep protocol_file.name]);

            % All Trials 
            tp_covered{1}{ix}=logical(ones(1,length(events))); tp_color{1}=[0.5,0.5,0.5];    
            % Trials high
            tp_covered{2}{ix}=strcmp({events.case_name},'C57Bl6 high'); tp_color{2}=[0.6,0,0];
            % Trials low
            tp_covered{3}{ix}=strcmp({events.case_name},'C57Bl6 low'); tp_color{3}=[0,0,0.6];
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
        if hx==1
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
    ax.FontWeight='bold';
    ax.LineWidth=1;
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
    lgd=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine],{'All','High','Low'},'Location','NorthEast');
    lgd.FontSize=4;
    
    % Sign. *
    clear h p
    [h,p]=ttest(tc_temp{2},tc_temp{3});
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
    tc_mat_selected = tc_matrsess_all_highres;

    subplot(2,2,2);
    % Loop over 4 different shadedErrorBars (for different trials, 11:40,
    % 41:80 (Puff), 41:80 (noPuff), 81:120)
    for hx=1:3
        % set counter
        counter=1;
        % Loop over animals
        for ix=1:length(Pfunc_social_hierarchy)
               
            % Load protocol file
            [fpath,fname,ext]=fileparts(Pfunc_social_hierarchy{ix});
            protocol_file = dir([protocol_dir filesep 'animal_' fname(5:6) filesep '*_new.mat']);
            load([protocol_file.folder filesep protocol_file.name]);
    
            % Define: 
            % Trials 129 sv

            % All Trials 
            tp_covered{1}{ix}=logical(ones(1,length(events))); tp_color{1}=[0.5,0.5,0.5];    
            % Trials high
            tp_covered{2}{ix}=strcmp({events.case_name},'C57Bl6 high'); tp_color{2}=[0.6,0,0];
            % Trials low
            tp_covered{3}{ix}=strcmp({events.case_name},'C57Bl6 low'); tp_color{3}=[0,0,0.6];
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
        if hx==1
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
    ax.FontWeight='bold';
    ax.LineWidth=1;
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
    lgd=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine],{'All','High','Low'},'Location','NorthEast');
    lgd.FontSize=4;
    
    % Sign. *
    clear h p
    [h,p]=ttest(tc_temp{2},tc_temp{3});
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
    tc_mat_selected = tc_matrsess_all_highres_lin;

    subplot(2,2,3);
    % Loop over 5 different shadedErrorBars (for different trials, 81:90,
    % 91:100, 101:110, 111:120; 81:120)
    for hx=1:6
        % set counter
        counter=1;
        % Loop over animals
        for ix=1:length(Pfunc_social_hierarchy)
               
            % Load protocol file
            [fpath,fname,ext]=fileparts(Pfunc_social_hierarchy{ix});
            protocol_file = dir([protocol_dir filesep 'animal_' fname(5:6) filesep '*_new.mat']);
            load([protocol_file.folder filesep protocol_file.name]);
    
            % Define: 
            % Trials 129 sv

                       
            % Trials CD1 fam
            find_vec = find(strcmp({events.case_name},'C57Bl6 high'));
            
            tp_covered{1}{ix}=find_vec(1:10); tp_color{1}=[0.9,0,0];
            % Trials CD1 fam
            tp_covered{2}{ix}=find_vec(11:20); tp_color{2}=[0.9,0,0];
            % Trials CD1 fam
            tp_covered{3}{ix}=find_vec(21:30); tp_color{3}=[0.9,0,0];
            
            % Trials CD1 fam
            find_vec = find(strcmp({events.case_name},'C57Bl6 low'));
            
            tp_covered{4}{ix}=find_vec(1:10); tp_color{4}=[0,0,0.9];
            % Trials CD1 fam
            tp_covered{5}{ix}=find_vec(11:20); tp_color{5}=[0,0,0.9];
            % Trials CD1 fam
            tp_covered{6}{ix}=find_vec(21:30); tp_color{6}=[0,0,0.9];           
            
            
            tc_temp{hx}(counter,:)=squeeze(nanmean(tc_mat_selected(ix,tp_covered{hx}{ix},:),2));
            % update counter
            counter=counter+1;
        end
        
        hold on;
        % Plot 
        sd{hx}=shadedErrorBar([1:size(tc_mat_selected,3)],smooth(nanmean(tc_temp{hx})),SEM_calc(tc_temp{hx}));
        sd{hx}.mainLine.Color=tp_color{hx};
        sd{hx}.patch.FaceColor=tp_color{hx};
        sd{hx}.patch.FaceAlpha=0.05;
        sd{hx}.edge(1).Color='none';
        sd{hx}.edge(2).Color='none';
        % Change LineStyles
        if hx==1 | hx==4 | hx==7
            sd{hx}.mainLine.LineStyle='-';sd{hx}.mainLine.LineWidth=0.7;
        elseif hx==2 | hx==5 | hx==8
            sd{hx}.mainLine.LineStyle='--';sd{hx}.mainLine.LineWidth=0.7;
        elseif hx==3 | hx==6 | hx==9
            sd{hx}.mainLine.LineStyle=':';sd{hx}.mainLine.LineWidth=0.7;
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
    ax.FontWeight='bold';
    ax.LineWidth=1;
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
    lgd=legend([sd{1}.mainLine,sd{2}.mainLine,sd{3}.mainLine,sd{4}.mainLine,sd{5}.mainLine,sd{6}.mainLine],{'H1-10','H11-20','H21-30','L1-10','L11-20','L21-30'},'Location','NorthEast');
    lgd.FontSize=4;
    
%     % Sign. *
%     clear h p
%     [h,p]=ttest2(tc_temp{2},tc_temp{3});
%     for px=1:length(p)
%         if p(px)<0.001
%             text(px-1,ax.YLim(2)*0.95,'*');
%             text(px-1,ax.YLim(2)*0.9,'*');
%             text(px-1,ax.YLim(2)*0.85,'*');
%         elseif p(px)<0.01
%             text(px-1,ax.YLim(2)*0.95,'*');
%             text(px-1,ax.YLim(2)*0.9,'*');
%         elseif p(px)<0.05
%             text(px-1,ax.YLim(2)*0.95,'*');
%         end
%     end


    % Save
    if 1==1
        exportgraphics(gcf,fullfile([workDir filesep],[regionlist(rx).name '.pdf']),'ContentType','vector')
%         print('-dpsc',fullfile([workDir filesep],[regionlist(rx).name '.ps']) ,'-r400')
    end
end


