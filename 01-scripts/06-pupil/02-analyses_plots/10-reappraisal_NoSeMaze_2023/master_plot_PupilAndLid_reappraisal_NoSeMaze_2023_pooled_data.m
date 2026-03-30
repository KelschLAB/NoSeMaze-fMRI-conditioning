%% master_plot_PupilAndLid_reappraisal_NoSeMaze_2023_pooled_data.m
% 07/2022 Reinwald, Jonathan
% Script for plotting pupil and eye-lid data for ephys task and 160Neroli
% Task in comparison

clear all
close all
clc

% Load pupil and lid data from reappraisal task
load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/04-pupil/10-reappraisal_NoSeMaze_Danae_2023/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp = summary_all;

% Output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/10-reappraisal_NoSeMaze_Danae_2023/pooled_data/';
mkdir(outputDir);

% set ranges
range{1}=[11:40]; range{2}=[41:80]; range{3}=[81:120];

% Set smoothing kernel
smoothing_kernel = 119*3;

% Set colors
color_scheme{1}=[0 0.5 0.5]; color_scheme{2}=[0.5 0.5 0.5]; color_scheme{3}=[0.75 0.5 0.25];

% naming scheme
naming_scheme={'Reapp.(Lav)'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pooled plot: PUPIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==0
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    %% Loop over ranges
    for jx=1:length(range)
        
        data_rp{jx}=[];
        
        % set counter
        counter=1;
        % Loop over animals 
        for ix=1:length(summary_all_rp)
            

            %% Data for each range (=blocks)
            data_rp{jx}=[data_rp{jx};summary_all_rp(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:)];
%             data_rp{jx}=[data_rp{jx};summary_all_rp(ix).PupilDiameterMatrix(range{jx},:)];
            %% Data for the whole session
            if jx==1
                clear transposed_data
                transposed_data = summary_all_rp(ix).PupilDiameterMatrix';
                data_long_rp{1}(counter,:)=transposed_data(:)';
                counter=counter+1;
            end            
        end
    end
    
    %% Figure 11: Intra-Trial Plot
    fig11=figure(11);
    fig11.Position = [100 100 840 600];
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
               
        %% Subplot for reappraisal condition (Lavender)
        sd(jx)=shadedErrorBar([1:size(data_rp{jx},2)],nanmean(data_rp{jx}),SEM_calc(data_rp{jx}));
        sd(jx).patch.EdgeColor='none';
        sd(jx).mainLine.Color=color_scheme{jx};
        sd(jx).mainLine.LineWidth=1.5;
        sd(jx).patch.FaceColor=color_scheme{jx};
        sd(jx).edge(1).Color='none';sd(jx).edge(2).Color='none';      
        
        % axes
        ax=gca;
         ax.YLim=[0.8,1.4];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [s]';
        ax.XTick=[0:20:size(data_rp{1},2)];
        ax.XTickLabel=([-2:2:10]);
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
        txp.Color=[0.2,0.2,0.2];
        
        %
        if jx==2
            hold on;
            ll=line([45,45],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
            txl=text([46],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
            txl.Color=[0.2,0.6,0.2];
        end 
    end
    
    % legend
    ll=legend([sd(1).mainLine,sd(2).mainLine,sd(3).mainLine],'block 1','block 2','block 3','Location','South');
    
    % Super title
    sp=suptitle('pupil data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Pupil_allblocks_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Pupil_allblocks_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1},2)],nanmean(data_rp{1}),SEM_calc(data_rp{1}));
    sd1.mainLine.Color=[1 0.5 0.5];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[1 0.5 0.5];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3},2)],nanmean(data_rp{3}),SEM_calc(data_rp{3}));
    sd2.patch.EdgeColor='none';
    sd2.mainLine.Color=[0 0.5 0.7];
    sd2.mainLine.LineWidth=1.5;
    sd2.patch.FaceColor=[0 0.5 0.7];
    sd2.edge(1).Color='none';sd2.edge(2).Color='none';
    
    % axes
    ax=gca;
    ax.YLim=[0.8,1.4];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % plot odor
    hold on;
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.06],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % Sign. *
    clear h p
    reappraisal_all = summary_all_rp;
    % Loop over time bins per trial
    for curr_bin=1:size(reappraisal_all(1).LidBaseDiameterMatrix_Corrected,2)
        % set counter
        counter=1;
        % animal ID
        for animal_ID=1:length(reappraisal_all)
            % trial
            for tr=1:120
                % restriction: only consider block 1 and 3
                if tr>10 && tr<41 | tr>80 && tr<121
                    % block
                    if tr>10 && tr<41
                        block(counter)=-1;
                    elseif tr>80 && tr<121
                        block(counter)=1;
                    else
                        block(counter)=0;
                    end
                    
                    % puff
                    % puff(counter)=reappraisal_all(animal_ID).puff_or_not(tr);
                    
                    % time point
                    % timepoint(counter)=tr;
                    
                    % animal
                    animal(counter)=animal_ID;
                    
                    % lid
                    pupil(counter)=reappraisal_all(animal_ID).PupilBaseDiameterMatrix_Corrected(tr,curr_bin);
%                     pupil(counter)=reappraisal_all(animal_ID).PupilDiameterMatrix(tr,curr_bin);
                    % counter update
                    counter=counter+1;
                end
            end
        end
        % create the input table
        myTable(curr_bin).input = table(block',animal',pupil','VariableNames',{'block','animal','pupil'});
        myTable(curr_bin).input.animal = categorical(myTable(curr_bin).input.animal);
        myTable(curr_bin).input.block = categorical(myTable(curr_bin).input.block);
        % fit linear mixed effects model (% choosing between individual
        % slopes for all animals (block|animal) or on slope (1|animal),
        % see also:
        % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
        % ( The Importance of Random Slopes in Mixed Models for Bayesian
        % Hypothesis Testing, Klaus Oberauer)
        lme = fitlme(myTable(curr_bin).input,'pupil ~ 1 + block + (1|animal)');
        % CAVE: robust linear models are implemented in R and might
        % ameliorate some results (robustlmm)
        % p values
        p_intercept(curr_bin)=double(lme.Coefficients(1,6));
        p_block(curr_bin)=double(lme.Coefficients(2,6));
        % betas
        beta_intercept(curr_bin)=double(lme.Coefficients(1,2));
        beta_block(curr_bin)=double(lme.Coefficients(2,2));
    end
    
    % Plotting of sign-stars
    p=p_block;
    for px=1:length(p)
        if p(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd1.mainLine,sd2.mainLine],'Bl. 1','Bl. 3');
    
    % Title
    tt=title({'pupil data (pooled)','Bl1 vs. Bl3'});
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Pupil_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Pupil_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    
    %% Subplot 2: Session-Plot
    %% Figure 13/3: Session Plot
    fig13=figure(13);
    fig13.Position = [100 100 840 1000];
    
    %% Subplot for reappraisal condition (Lavender)
    clear sd
    for jx=1:length(data_long_rp)
        
        hold on;
        subplot(4,5,(1:3)+(jx-1)*5);
        sd{jx}=shadedErrorBar([1:size(data_long_rp{jx},2)],smooth(nanmean(data_long_rp{jx}),smoothing_kernel),smooth(SEM_calc(data_long_rp{jx}),smoothing_kernel));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
        
        % axes
        ax=gca;
        ax.YLim=[nanmean(nanmean(data_long_rp{jx}))-3*nanmean(nanstd(data_long_rp{jx})),nanmean(nanmean(data_long_rp{jx}))+3*nanmean(nanstd(data_long_rp{jx}))];
        ax.XTick=[0:1200:size(data_long_rp{jx},2)];
        ax.XTickLabel=[0:2:size(data_long_rp{jx},2)/600];

        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [min]';
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([size(data_long_rp{1},2)/3+1,(size(data_long_rp{1},2)*2)/3,(size(data_long_rp{1},2)*2)/3,size(data_long_rp{1},2)/3+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(size(data_long_rp{1},2)/3+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
        txp.Color=[0.2,0.2,0.2];
        
        % legend
        ll=legend([sd{jx}.mainLine],naming_scheme{jx});
        
        % title
        tt=title(['pupil data smoothed (' num2str(smoothing_kernel) ' kernel)']);
        
        
        %% subplot mean-val
        hold on;
        subplot(2,5,(4:5)+(jx-1)*5);
        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2)])

        
        % axes
        ax=gca;
        %         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='Blocks';
        if jx==1 || jx==4
            ax.XTick=[1:1:4];
            ax.XTickLabel={'1','2','3','4'};
        else
            ax.XTick=[1:1:2];
            ax.XTickLabel={'1','2'};
        end
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
%         % 
%         for sx=1:4; myData(:,sx)=nanmean(data_long_rp{1}(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2); end
%         t = table(myData(:,1),myData(:,2),myData(:,3),...
%             'VariableNames',{'meas1','meas2','meas3'});
%         rm = fitrm(t,'meas1-meas3~1','WithinDesign',Meas);
%         multcompare(rm,'Measurements');
        % Sign. *
        %% Mixed effects model
        pupil_data=[];
        block_data=[];
        animal_ID=[];
        for block=1:3
            for animal=1:30
                pupil_data=[pupil_data,data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                block_data=[block_data,block.*ones(1,length(data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
            end
        end
        myInputTable = table(block_data',animal_ID',pupil_data','VariableNames',{'block','animal','lid'});
        myInputTable.animal = categorical(myInputTable.animal);
        myInputTable.block = categorical(myInputTable.block);
        % fit linear mixed effects model
        %             lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + puff + (1|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
        lme = fitlme(myInputTable,'lid ~ 1 + block + (block|animal)');
            
            
        
        
        clear h p
        [p,h]=signrank(nanmean(data_long_rp{jx}(:,10*119+1:40*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2));

        for px=1:length(p)
            if p(px)<0.001
                sigstar({{'1','3'}},0.001,0,20)
            elseif p(px)<0.01
                sigstar({{'1','3'}},0.01,0,20)
            elseif p(px)<0.05
                sigstar({{'1','3'}},0.05,0,20)
            end
        end       
        
        % print
        print('-dpsc',fullfile(outputDir,['Plots_Pupil_intrasession_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
        print('-dpdf',fullfile(outputDir,['Plots_Pupil_intrasession_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    end
end

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pooled plot: LID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==1
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    %% Loop over ranges
    for jx=1:length(range)
        
        data_rp{jx}=[];
        
        % set counter
        counter=1;
        % Loop over animals 
        for ix=1:length(summary_all_rp)
            

            %% Data for each range (=blocks)
            data_rp{jx}=[data_rp{jx};summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:)];
%             data_rp{jx}=[data_rp{jx};summary_all_rp(ix).LidDiameterMatrix(range{jx},:)];
            %% Data for the whole session
            if jx==1
                clear transposed_data
                transposed_data = summary_all_rp(ix).LidDiameterMatrix';
                data_long_rp{1}(counter,:)=transposed_data(:)';
                counter=counter+1;
            end            
        end
    end
    
    %% Figure 11: Intra-Trial Plot
    fig11=figure(11);
    fig11.Position = [100 100 840 600];
    
    clear sd
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
               
        %% Subplot for reappraisal condition (Lavender)
        sd(jx)=shadedErrorBar([1:size(data_rp{jx},2)],nanmean(data_rp{jx}),SEM_calc(data_rp{jx}));
        sd(jx).patch.EdgeColor='none';
        sd(jx).mainLine.Color=color_scheme{jx};
        sd(jx).mainLine.LineWidth=1.5;
        sd(jx).patch.FaceColor=color_scheme{jx};
        sd(jx).edge(1).Color='none';
        sd(jx).edge(2).Color='none';      
        
        % axes
        ax=gca;
        ax.YLim=[0.9,1.15];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [s]';
        ax.XTick=[0:20:size(data_rp{1},2)];
        ax.XTickLabel=([-2:2:10]);
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
        txp.Color=[0.2,0.2,0.2];
        
        %
        if jx==2
            hold on;
            ll=line([45,45],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
            txl=text([46],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
            txl.Color=[0.2,0.6,0.2];
        end  
    end
    
    % legend
    ll=legend([sd(1).mainLine,sd(2).mainLine,sd(3).mainLine],'block 1','block 2','block 3','Location','South');
    
    % Super title
    sp=suptitle('lid data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Lid_allblocks_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Lid_allblocks_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1},2)],nanmean(data_rp{1}),SEM_calc(data_rp{1}));
    sd1.mainLine.Color=[1 0.5 0.5];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[1 0.5 0.5];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3},2)],nanmean(data_rp{3}),SEM_calc(data_rp{3}));
    sd2.patch.EdgeColor='none';
    sd2.mainLine.Color=[0 0.5 0.7];
    sd2.mainLine.LineWidth=1.5;
    sd2.patch.FaceColor=[0 0.5 0.7];
    sd2.edge(1).Color='none';sd2.edge(2).Color='none';
    
    % axes
    ax=gca;
    ax.YLim=[0.9,1.15];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % plot odor
    hold on;
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.06],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % Sign. *
    clear h p
    reappraisal_all = summary_all_rp;
    % Loop over time bins per trial
    for curr_bin=1:size(reappraisal_all(1).LidBaseDiameterMatrix_Corrected,2)
        % set counter
        counter=1;
        % animal ID
        for animal_ID=1:length(reappraisal_all)
            % trial
            for tr=1:120
                % restriction: only consider block 1 and 3
                if tr>10 && tr<41 | tr>80 && tr<121
                    % block
                    if tr>10 && tr<41
                        block(counter)=-1;
                    elseif tr>80 && tr<121
                        block(counter)=1;
                    else
                        block(counter)=0;
                    end
                    
                    % puff
                    % puff(counter)=reappraisal_all(animal_ID).puff_or_not(tr);
                    
                    % time point
                    % timepoint(counter)=tr;
                    
                    % animal
                    animal(counter)=animal_ID;
                    
                    % lid
                    lid(counter)=reappraisal_all(animal_ID).LidBaseDiameterMatrix_Corrected(tr,curr_bin);
%                     lid(counter)=reappraisal_all(animal_ID).LidDiameterMatrix(tr,curr_bin);
                    % counter update
                    counter=counter+1;
                end
            end
        end
        % create the input table
        myTable(curr_bin).input = table(block',animal',lid','VariableNames',{'block','animal','lid'});
        myTable(curr_bin).input.animal = categorical(myTable(curr_bin).input.animal);
        myTable(curr_bin).input.block = categorical(myTable(curr_bin).input.block);
        % fit linear mixed effects model (% choosing between individual
        % slopes for all animals (block|animal) or on slope (1|animal),
        % see also:
        % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
        % ( The Importance of Random Slopes in Mixed Models for Bayesian
        % Hypothesis Testing, Klaus Oberauer)
        lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + (1|animal)');
        % CAVE: robust linear models are implemented in R and might
        % ameliorate some results (robustlmm)
        % p values
        p_intercept(curr_bin)=double(lme.Coefficients(1,6));
        p_block(curr_bin)=double(lme.Coefficients(2,6));
        % betas
        beta_intercept(curr_bin)=double(lme.Coefficients(1,2));
        beta_block(curr_bin)=double(lme.Coefficients(2,2));
    end
    
    % Plotting of sign-stars
    p=p_block;
    for px=1:length(p)
        if p(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd1.mainLine,sd2.mainLine],'Bl. 1','Bl. 3');
    
    % Title
    tt=title({'lid data (pooled)','Bl1 vs. Bl3'});
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Lid_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Lid_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    
    %% Subplot 2: Session-Plot
    %% Figure 13/3: Session Plot
    fig13=figure(13);
    fig13.Position = [100 100 840 1000];
    
    %% Subplot for reappraisal condition (Lavender)
    clear sd
    for jx=1:length(data_long_rp)
        
        hold on;
        subplot(2,5,(1:3)+(jx-1)*5);
        sd{jx}=shadedErrorBar([1:size(data_long_rp{jx},2)],smooth(nanmean(data_long_rp{jx}),smoothing_kernel),smooth(SEM_calc(data_long_rp{jx}),smoothing_kernel));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
        
        % axes
        ax=gca;
        ax.YLim=[nanmean(nanmean(data_long_rp{jx}))-3*nanmean(nanstd(data_long_rp{jx})),nanmean(nanmean(data_long_rp{jx}))+3*nanmean(nanstd(data_long_rp{jx}))];
        ax.XTick=[0:1200:size(data_long_rp{jx},2)];
        ax.XTickLabel=[0:2:size(data_long_rp{jx},2)/600];

        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [min]';
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([size(data_long_rp{1},2)/3+1,(size(data_long_rp{1},2)*2)/3,(size(data_long_rp{1},2)*2)/3,size(data_long_rp{1},2)/3+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(size(data_long_rp{1},2)/3+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
        txp.Color=[0.2,0.2,0.2];
        
        % legend
        ll=legend([sd{jx}.mainLine],naming_scheme{jx});
        
        % title
        tt=title(['lid data smoothed (' num2str(smoothing_kernel) ' kernel)']);
        
        
        %% subplot mean-val
        hold on;
        subplot(2,5,(4:5)+(jx-1)*5);
        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2)])

        
        % axes
        ax=gca;
        %         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='Blocks';
        if jx==1 || jx==4
            ax.XTick=[1:1:4];
            ax.XTickLabel={'1','2','3','4'};
        else
            ax.XTick=[1:1:2];
            ax.XTickLabel={'1','2'};
        end
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
%         % 
%         for sx=1:4; myData(:,sx)=nanmean(data_long_rp{1}(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2); end
%         t = table(myData(:,1),myData(:,2),myData(:,3),...
%             'VariableNames',{'meas1','meas2','meas3'});
%         rm = fitrm(t,'meas1-meas3~1','WithinDesign',Meas);
%         multcompare(rm,'Measurements');
        % Sign. *
        %% Mixed effects model
        lid_data=[];
        block_data=[];
        animal_ID=[];
        for block=1:3
            for animal=1:30
                lid_data=[lid_data,data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                block_data=[block_data,block.*ones(1,length(data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
            end
        end
        myInputTable = table(block_data',animal_ID',lid_data','VariableNames',{'block','animal','lid'});
        myInputTable.animal = categorical(myInputTable.animal);
        myInputTable.block = categorical(myInputTable.block);
        % fit linear mixed effects model
        %             lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + puff + (1|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
        lme = fitlme(myInputTable,'lid ~ 1 + block + (block|animal)');
            
            
        
        
        clear h p
        [p,h]=signrank(nanmean(data_long_rp{jx}(:,10*119+1:40*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2));

        for px=1:length(p)
            if p(px)<0.001
                sigstar({{'1','3'}},0.001,0,20)
            elseif p(px)<0.01
                sigstar({{'1','3'}},0.01,0,20)
            elseif p(px)<0.05
                sigstar({{'1','3'}},0.05,0,20)
            end
        end       
        
        % print
        print('-dpsc',fullfile(outputDir,['Plots_Lid_intrasession_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
        print('-dpdf',fullfile(outputDir,['Plots_Lid_intrasession_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    end
end

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pooled plot: PUPIL MOVEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1==1
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    %% Loop over ranges
    for jx=1:length(range)
        
        data_rp{jx}=[];
        
        % set counter
        counter=1;
        % Loop over animals 
        for ix=1:length(summary_all_rp)
            

            %% Data for each range (=blocks)
            data_rp{jx}=[data_rp{jx};summary_all_rp(ix).PupilMovementMatrix_Corrected(range{jx},:)];
%             data_rp{jx}=[data_rp{jx};summary_all_rp(ix).LidDiameterMatrix(range{jx},:)];
            %% Data for the whole session
            if jx==1
                clear transposed_data
                transposed_data = summary_all_rp(ix).PupilMovementMatrix';
                data_long_rp{1}(counter,:)=transposed_data(:)';
                counter=counter+1;
            end            
        end
    end
    
    %% Figure 11: Intra-Trial Plot
    fig11=figure(11);
    fig11.Position = [100 100 840 600];
    
    clear sd
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
               
        %% Subplot for reappraisal condition (Lavender)
        sd(jx)=shadedErrorBar([1:size(data_rp{jx},2)],nanmean(data_rp{jx}),SEM_calc(data_rp{jx}));
        sd(jx).patch.EdgeColor='none';
        sd(jx).mainLine.Color=color_scheme{jx};
        sd(jx).mainLine.LineWidth=1.5;
        sd(jx).patch.FaceColor=color_scheme{jx};
        sd(jx).edge(1).Color='none';
        sd(jx).edge(2).Color='none';      
        
        % axes
        ax=gca;
%         ax.YLim=[0.9,1.15];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [s]';
        ax.XTick=[0:20:size(data_rp{1},2)];
        ax.XTickLabel=([-2:2:10]);
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.9],'Odor');
        txp.Color=[0.2,0.2,0.2];
        
        %
        if jx==2
            hold on;
            ll=line([45,45],[ax.YLim(1),ax.YLim(2)],'color',[0.2,0.6,0.2],'LineStyle','--','LineWidth',2);
            txl=text([46],[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.12],'Puff');
            txl.Color=[0.2,0.6,0.2];
        end  
    end
    
    % legend
    ll=legend([sd(1).mainLine,sd(2).mainLine,sd(3).mainLine],'block 1','block 2','block 3','Location','South');
    
    % Super title
    sp=suptitle('pupil movement data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilMovement_allblocks_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_PupilMovement_allblocks_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1},2)],nanmean(data_rp{1}),SEM_calc(data_rp{1}));
    sd1.mainLine.Color=[1 0.5 0.5];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[1 0.5 0.5];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3},2)],nanmean(data_rp{3}),SEM_calc(data_rp{3}));
    sd2.patch.EdgeColor='none';
    sd2.mainLine.Color=[0 0.5 0.7];
    sd2.mainLine.LineWidth=1.5;
    sd2.patch.FaceColor=[0 0.5 0.7];
    sd2.edge(1).Color='none';sd2.edge(2).Color='none';
    
    % axes
    ax=gca;
%     ax.YLim=[0.9,1.15];
    ax.YLabel.String='A.U.';
    ax.XLabel.String='time [s]';
    ax.XTick=[0:20:size(data_rp{1},2)];
    ax.XTickLabel=([-2:2:10]);
    ax.FontWeight='bold';
    ax.LineWidth=1;
    
    % plot odor
    hold on;
    pt=patch([20,44,44,20],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
    txp=text(21,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.06],'Odor');
    txp.Color=[0.2,0.2,0.2];
    
    % Sign. *
    clear h p
    reappraisal_all = summary_all_rp;
    % Loop over time bins per trial
    for curr_bin=1:size(reappraisal_all(1).PupilMovementMatrix_Corrected,2)
        % set counter
        counter=1;
        % animal ID
        for animal_ID=1:length(reappraisal_all)
            % trial
            for tr=1:120
                % restriction: only consider block 1 and 3
                if tr>10 && tr<41 | tr>80 && tr<121
                    % block
                    if tr>10 && tr<41
                        block(counter)=-1;
                    elseif tr>80 && tr<121
                        block(counter)=1;
                    else
                        block(counter)=0;
                    end
                    
                    % puff
                    % puff(counter)=reappraisal_all(animal_ID).puff_or_not(tr);
                    
                    % time point
                    % timepoint(counter)=tr;
                    
                    % animal
                    animal(counter)=animal_ID;
                    
                    % lid
                    pupilmovement(counter)=reappraisal_all(animal_ID).PupilMovementMatrix_Corrected(tr,curr_bin);
%                     lid(counter)=reappraisal_all(animal_ID).LidDiameterMatrix(tr,curr_bin);
                    % counter update
                    counter=counter+1;
                end
            end
        end
        % create the input table
        myTable(curr_bin).input = table(block',animal',pupilmovement','VariableNames',{'block','animal','pupilmovement'});
        myTable(curr_bin).input.animal = categorical(myTable(curr_bin).input.animal);
        myTable(curr_bin).input.block = categorical(myTable(curr_bin).input.block);
        % fit linear mixed effects model (% choosing between individual
        % slopes for all animals (block|animal) or on slope (1|animal),
        % see also:
        % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
        % ( The Importance of Random Slopes in Mixed Models for Bayesian
        % Hypothesis Testing, Klaus Oberauer)
        lme = fitlme(myTable(curr_bin).input,'pupilmovement ~ 1 + block + (1|animal)');
        % CAVE: robust linear models are implemented in R and might
        % ameliorate some results (robustlmm)
        % p values
        p_intercept(curr_bin)=double(lme.Coefficients(1,6));
        p_block(curr_bin)=double(lme.Coefficients(2,6));
        % betas
        beta_intercept(curr_bin)=double(lme.Coefficients(1,2));
        beta_block(curr_bin)=double(lme.Coefficients(2,2));
    end
    
    % Plotting of sign-stars
    p=p_block;
    for px=1:length(p)
        if p(px)<0.001
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
            text(px,ax.YLim(2)*0.97,'*');
        elseif p(px)<0.01
            text(px,ax.YLim(2)*0.99,'*');
            text(px,ax.YLim(2)*0.98,'*');
        elseif p(px)<0.05
            text(px,ax.YLim(2)*0.99,'*');
        end
    end
    
    % legend
    ll=legend([sd1.mainLine,sd2.mainLine],'Bl. 1','Bl. 3');
    
    % Title
    tt=title({'pupil movement data (pooled)','Bl1 vs. Bl3'});
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_PupilMovement_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_PupilMovement_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    
    %% Subplot 2: Session-Plot
    %% Figure 13/3: Session Plot
    fig13=figure(13);
    fig13.Position = [100 100 840 1000];
    
    %% Subplot for reappraisal condition (Lavender)
    clear sd
    for jx=1:length(data_long_rp)
        
        hold on;
        subplot(2,5,(1:3)+(jx-1)*5);
        sd{jx}=shadedErrorBar([1:size(data_long_rp{jx},2)],smooth(nanmean(data_long_rp{jx}),smoothing_kernel),smooth(SEM_calc(data_long_rp{jx}),smoothing_kernel));
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
        
        % axes
        ax=gca;
        ax.YLim=[nanmean(nanmean(data_long_rp{jx}))-3*nanmean(nanstd(data_long_rp{jx})),nanmean(nanmean(data_long_rp{jx}))+3*nanmean(nanstd(data_long_rp{jx}))];
        ax.XTick=[0:1200:size(data_long_rp{jx},2)];
        ax.XTickLabel=[0:2:size(data_long_rp{jx},2)/600];

        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [min]';
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        hold on;
        pt=patch([size(data_long_rp{1},2)/3+1,(size(data_long_rp{1},2)*2)/3,(size(data_long_rp{1},2)*2)/3,size(data_long_rp{1},2)/3+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
        pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
        txp=text(size(data_long_rp{1},2)/3+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
        txp.Color=[0.2,0.2,0.2];
        
        % legend
        ll=legend([sd{jx}.mainLine],naming_scheme{jx});
        
        % title
        tt=title(['pupilmovement data smoothed (' num2str(smoothing_kernel) ' kernel)']);
        
        
        %% subplot mean-val
        hold on;
        subplot(2,5,(4:5)+(jx-1)*5);
        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2)])

        
        % axes
        ax=gca;
        %         ax.YLim=[nanmean(nanmean(data_long_rp))-nanmean(nanstd(data_long_rp)),nanmean(nanmean(data_long_rp))+nanmean(nanstd(data_long_rp))];
        ax.YLabel.String='A.U.';
        ax.XLabel.String='Blocks';
        if jx==1 || jx==4
            ax.XTick=[1:1:4];
            ax.XTickLabel={'1','2','3','4'};
        else
            ax.XTick=[1:1:2];
            ax.XTickLabel={'1','2'};
        end
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
%         % 
%         for sx=1:4; myData(:,sx)=nanmean(data_long_rp{1}(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2); end
%         t = table(myData(:,1),myData(:,2),myData(:,3),...
%             'VariableNames',{'meas1','meas2','meas3'});
%         rm = fitrm(t,'meas1-meas3~1','WithinDesign',Meas);
%         multcompare(rm,'Measurements');
        % Sign. *
        %% Mixed effects model
        pupilmovement_data=[];
        block_data=[];
        animal_ID=[];
        for block=1:3
            for animal=1:30
                pupilmovement_data=[pupilmovement_data,data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                block_data=[block_data,block.*ones(1,length(data_long_rp{1}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
            end
        end
        myInputTable = table(block_data',animal_ID',pupilmovement_data','VariableNames',{'block','animal','pupilmovement'});
        myInputTable.animal = categorical(myInputTable.animal);
        myInputTable.block = categorical(myInputTable.block);
        % fit linear mixed effects model
        %             lme = fitlme(myTable(curr_bin).input,'pupilmovement ~ 1 + block + puff + (1|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
        lme = fitlme(myInputTable,'pupilmovement ~ 1 + block + (block|animal)');
            
            
        
        
        clear h p
        [p,h]=signrank(nanmean(data_long_rp{jx}(:,10*119+1:40*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2));

        for px=1:length(p)
            if p(px)<0.001
                sigstar({{'1','3'}},0.001,0,20)
            elseif p(px)<0.01
                sigstar({{'1','3'}},0.01,0,20)
            elseif p(px)<0.05
                sigstar({{'1','3'}},0.05,0,20)
            end
        end       
        
        % print
        print('-dpsc',fullfile(outputDir,['Plots_PupilMovement_intrasession_reappraisal_NoSeMaze_2023']),'-painters','-r400','-append');
        print('-dpdf',fullfile(outputDir,['Plots_PupilMovement_intrasession_reappraisal_NoSeMaze_2023']),'-painters','-r400');
    end
end
