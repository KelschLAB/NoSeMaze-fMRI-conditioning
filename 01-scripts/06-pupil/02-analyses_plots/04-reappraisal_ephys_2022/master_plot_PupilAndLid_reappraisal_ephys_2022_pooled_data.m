%% master_plot_PupilAndLid_reappraisal_ephys_2022_pooled_data.m
% 07/2022 Reinwald, Jonathan
% Script for plotting pupil and eye-lid data for ephys task and 160Neroli
% Task in comparison

clear all
close all
clc

% Load pupil and lid data from reappraisal task
load('/zi-flstorage/data/jonathan/ICON_Autonomouse/02-raw-data/04-pupil/04_reappraisal_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
% load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/04-pupil/10-reappraisal_NoSeMaze_Danae_2023/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp = summary_all;

% Load pupil and lid data from control task with neroli
load('/zi-flstorage/data/jonathan/ICON_Autonomouse/02-raw-data/04-pupil/06-160TrialsNeroli_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
summary_all_con = summary_all;
summary_all_con(2)=[];

% Output directory
outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/04-pupil/04_reappraisal_ephys_2022/pooled_data/';
mkdir(outputDir);

% set ranges
range{1}=[11:40]; range{2}=[41:80]; range{3}=[81:120]; range{4}=[121:160];

% Set smoothing kernel
smoothing_kernel = 119*3;

% Set colors
color_scheme{1}=[0 0.5 0.5]; color_scheme{2}=[0.5 0.5 0.5]; color_scheme{3}=[0.75 0.5 0.25]; color_scheme{4}=[0.25 0.5 0.75];

% naming scheme
naming_scheme={'Reapp.(Lav)','1h-post(Lav)','24h-post(Lav)','Con.(Ner)'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pooled plot: PUPIL
if 1==1
    %% Control condition
    % clearing of data matrix before concatenation
    clear data_con
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_con{jx,1}=[];
        % Loop over sessions
        for ix=1:length(summary_all_con)
            %% Data for each range (=blocks)
            data_con{jx}=[data_con{jx};summary_all_con(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:)];
            %% Data for the whole session
            if jx==1
                clear transposed_data
                transposed_data = summary_all_con(ix).PupilDiameterMatrix';
                data_long_con(ix,:)=transposed_data(:)';
                %                 data_long_con_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
            end
        end
    end
    
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    %% Loop over ranges
    for jx=1:length(range)
        %% Loop over Sessions (1=rp, 2=1h after, 3=24h after)
        for kx=1:3
            data_rp{jx,kx}=[];
            % set counter
            counter=1;
            % Loop over animals (CAVE: only every third sessions in this
            % struct is a reappraisal session)
            for ix=kx:3:length(summary_all_rp)
                
                if kx==1
                    %% Data for each range (=blocks)
                    data_rp{jx,kx}=[data_rp{jx,kx};summary_all_rp(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:)];
                    %% Data for the whole session
                    if jx==1
                        clear transposed_data
                        transposed_data = summary_all_rp(ix).PupilDiameterMatrix';
                        data_long_rp{kx}(counter,:)=transposed_data(:)';
                    end
                elseif kx>1 && jx<3
                    data_rp{jx,kx}=[data_rp{jx,kx};summary_all_rp(ix).PupilBaseDiameterMatrix_Corrected(range{jx},:)];
                    %% Data for the whole session
                    if jx==1
                        clear transposed_data
                        transposed_data = summary_all_rp(ix).PupilDiameterMatrix';
                        data_long_rp{kx}(counter,:)=transposed_data(:)';
                    end
                end
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
        
        %% Subplot for Control condition (Neroli)
        subplot(1,4,jx);
        sd1=shadedErrorBar([1:size(data_con{jx,1},2)],nanmean(data_con{jx,1}),SEM_calc(data_con{jx,1}));
        sd1.mainLine.Color=[0.5 0.25 0];
        sd1.mainLine.LineWidth=1.5;
        sd1.patch.FaceColor=[0.5 0.25 0];
        sd1.patch.EdgeColor='none';
        sd1.edge(1).Color='none';
        sd1.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        sd2=shadedErrorBar([1:size(data_rp{jx,1},2)],nanmean(data_rp{jx,1}),SEM_calc(data_rp{jx,1}));
        sd2.patch.EdgeColor='none';
        sd2.mainLine.Color=[0 0.5 0.5];
        sd2.mainLine.LineWidth=1.5;
        sd2.patch.FaceColor=[0 0.5 0.5];
        sd2.edge(1).Color='none';sd2.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        if jx<3
            sd3=shadedErrorBar([1:size(data_rp{jx,2},2)],nanmean(data_rp{jx,2}),SEM_calc(data_rp{jx,2}));
            sd3.patch.EdgeColor='none';
            sd3.mainLine.Color=[0.75 0.25 0.5];
            sd3.mainLine.LineWidth=1.5;
            sd3.mainLine.LineStyle='-';
            sd3.patch.FaceColor=[0.75 0.25 0.5];
            sd3.edge(1).Color='none';sd3.edge(2).Color='none';
            
            sd4=shadedErrorBar([1:size(data_rp{jx,3},2)],nanmean(data_rp{jx,3}),SEM_calc(data_rp{jx,3}));
            sd4.patch.EdgeColor='none';
            sd4.mainLine.Color=[0 0.25 0.5];
            sd4.mainLine.LineWidth=1.5;
            sd4.mainLine.LineStyle='-';
            sd4.patch.FaceColor=[0 0.25 0.5];
            sd4.edge(1).Color='none';sd4.edge(2).Color='none';
        end
        
        
        
        % axes
        ax=gca;
        ax.YLim=[0.8,1.6];
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
        
        % Sign. *
        %         clear h p
        [h,p]=ttest2(data_rp{jx,1},data_con{jx,1});
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
        if jx==1;
            ll=legend([sd1.mainLine,sd2.mainLine,sd3.mainLine,sd4.mainLine],'Con.(Ner)','Reapp.(Lav)','1h-post(Lav)','24h-post(Lav)','Location','South');
        end
        
        % Title
        tt=title(['Tr. ' num2str(range{jx}(1)) '-' num2str(range{jx}(end))]);
    end
    
    % Super title
    sp=suptitle('pupil data (pooled)');
    
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Pupil_intratrial_reappraisal_ephys_2022_withControls']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Pupil_intratrial_reappraisal_ephys_2022_withControls']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig12=figure(12);
    fig12.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1,1},2)],nanmean(data_rp{1,1}),SEM_calc(data_rp{1}));
    sd1.mainLine.Color=[1 0.5 0.5];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[1 0.5 0.5];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3,1},2)],nanmean(data_rp{3,1}),SEM_calc(data_rp{3,1}));
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
    reappraisal_all = summary_all_rp(1:3:end);
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
    
    %% Mean stats for the range:
%     starter=[25,49]; starter_range=[10,5]%starts at 600ms
    starter=[25,50]; starter_range=[10,5]%starts at 600ms
    for rrx=1:length(starter)
        clear myPupil
        for iix=1:starter_range(rrx);
            myPupil(:,iix)=myTable(starter(rrx)+iix).input.pupil; 
        end
        myTableMean = myTable(1).input;
        myTableMean.pupil = nanmean(myPupil')';
        lme = fitlme(myTableMean,'pupil ~ 1 + block + (1|animal)');
        % p values
        p_intercept_range(rrx)=double(lme.Coefficients(1,6));
        p_block_range(rrx)=double(lme.Coefficients(2,6));
        % betas
        beta_intercept_range(rrx)=double(lme.Coefficients(1,2));
        beta_block_range(rrx)=double(lme.Coefficients(2,2));
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
    print('-dpsc',fullfile(outputDir,['Plots_Pupil_intratrial_reappraisal_ephys_2022_bl3vsbl1']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Pupil_intratrial_reappraisal_ephys_2022_bl3vsbl1']),'-painters','-r400');
    
    %% Subplot 2: Session-Plot
    %% Figure 13/4: Session Plot
    fig13=figure(13);
    fig13.Position = [100 100 840 1000];
    
    %% Subplot for reappraisal condition (Lavender)
    clear sd
    for jx=1:length(data_long_rp)+1
        
        hold on;
        subplot(4,5,(1:3)+(jx-1)*5);
        if jx<4
            sd{jx}=shadedErrorBar([1:size(data_long_rp{jx},2)],smooth(nanmean(data_long_rp{jx}),smoothing_kernel),smooth(SEM_calc(data_long_rp{jx}),smoothing_kernel));
        elseif jx==4
            sd{jx}=shadedErrorBar([1:size(data_long_con,2)],smooth(nanmean(data_long_con),smoothing_kernel),smooth(SEM_calc(data_long_con),smoothing_kernel));
        end
        sd{jx}.patch.EdgeColor='none';
        sd{jx}.mainLine.Color=color_scheme{jx};
        sd{jx}.mainLine.LineWidth=1.5;
        sd{jx}.patch.FaceColor=color_scheme{jx};
        sd{jx}.edge(1).Color='none';
        sd{jx}.edge(2).Color='none';
        
        % axes
        ax=gca;
        if jx<4
            ax.YLim=[nanmean(nanmean(data_long_rp{jx}))-3*nanmean(nanstd(data_long_rp{jx})),nanmean(nanmean(data_long_rp{jx}))+3*nanmean(nanstd(data_long_rp{jx}))];
            ax.XTick=[0:1200:size(data_long_rp{jx},2)];
            ax.XTickLabel=[0:2:size(data_long_rp{jx},2)/600];
        elseif jx==4
            ax.YLim=[nanmean(nanmean(data_long_con))-3*nanmean(nanstd(data_long_con)),nanmean(nanmean(data_long_con))+3*nanmean(nanstd(data_long_con))];
            ax.XTick=[0:1200:size(data_long_con,2)];
            ax.XTickLabel=[0:2:size(data_long_con,2)/600];
        end
        ax.YLabel.String='A.U.';
        ax.XLabel.String='time [min]';
        ax.FontWeight='bold';
        ax.LineWidth=1;
        
        % plot odor
        if jx==1 || jx==4
            hold on;
            pt=patch([size(data_long_rp{1},2)/4+1,(size(data_long_rp{1},2)*2)/4,(size(data_long_rp{1},2)*2)/4,size(data_long_rp{1},2)/4+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
            pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
            txp=text(size(data_long_rp{1},2)/4+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
            txp.Color=[0.2,0.2,0.2];
        end
        
        % legend
        ll=legend([sd{jx}.mainLine],naming_scheme{jx});
        
        % title
        tt=title(['pupil data smoothed (' num2str(smoothing_kernel) ' kernel)']);
        
        
        %% subplot mean-val
        hold on;
        subplot(4,5,(4:5)+(jx-1)*5);
        
        if jx==1
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,10*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2),nanmean(data_long_rp{jx}(:,120*119+1:160*119),2)])
        elseif jx>1 && jx<4
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,10*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2)])
        elseif jx==4
            notBoxPlot_modified_pupilANDlid([nanmean(data_long_con(:,10*119+1:40*119),2),nanmean(data_long_con(:,40*119+1:80*119),2),nanmean(data_long_con(:,80*119+1:120*119),2),nanmean(data_long_con(:,120*119+1:160*119),2)])
        end
        
        
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
        
        %%
        if jx==1 || jx==4
            clear myData
            if jx==1
                for sx=1:4
                    myData(:,sx)=nanmean(data_long_rp{1}(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2);
                end
            elseif jx==4
                for sx=1:4
                    myData(:,sx)=nanmean(data_long_con(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2);
                end
            end
            t = table(myData(:,1),myData(:,2),myData(:,3),myData(:,4),...
                'VariableNames',{'meas1','meas2','meas3','meas4'});
            Meas = table([1 2 3]','VariableNames',{'Measurements'});
            rm = fitrm(t,'meas1-meas3~1','WithinDesign',Meas);
            multcompare(rm,'Measurements');
        end
        
        % %         % Sign. *
        %% Mixed effects model
        pupil_data=[];
        block_data=[];
        animal_ID=[];
        if jx==1
            for block=1:4
                for animal=1:size(data_long_rp{1},1)
                    pupil_data=[pupil_data,data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                    animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                    block_data=[block_data,block.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                end
            end
        elseif jx>1 && jx<4
            for block=1:2
                for animal=1:size(data_long_rp{1},1)
                    pupil_data=[pupil_data,data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                    animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                    block_data=[block_data,block.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                end
            end
        elseif jx==4
            for block=1:4
                for animal=1:size(data_long_con,1)
                    pupil_data=[pupil_data,data_long_con(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                    animal_ID=[animal_ID,animal.*ones(1,length(data_long_con(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                    block_data=[block_data,block.*ones(1,length(data_long_con(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                end
            end
        end
        
        myInputTable = table(block_data',animal_ID',pupil_data','VariableNames',{'block','animal','pupil'});
        myInputTable.animal = categorical(myInputTable.animal);
        myInputTable.block = categorical(myInputTable.block);
        % fit linear mixed effects model
        %             lme = fitlme(myTable(curr_bin).input,'pupil ~ 1 + block + puff + (1|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
        lme = fitlme(myInputTable,'pupil ~ 1 + block + (block|animal)');
        
        
        
        
        clear h p
        if jx==1
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
        end
        
    end
    % print
    print('-dpsc',fullfile(outputDir,['Plots_Pupil_intrasession_reappraisal_fMRI_2022']),'-painters','-r400','-append');
    print('-dpdf',fullfile(outputDir,['Plots_Pupil_intrasession_reappraisal_fMRI_2022']),'-painters','-r400');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pooled plot: LID
if 1==0
    %% Control condition
    % clearing of data matrix before concatenation
    clear data_con
    % concatenate data for each range
    % Loop over ranges
    for jx=1:length(range)
        data_con{jx,1}=[];
        % Loop over sessions
        for ix=1:length(summary_all_con)
            %% Data for each range (=blocks)
            data_con{jx}=[data_con{jx};summary_all_con(ix).LidBaseDiameterMatrix_Corrected(range{jx},:)];
            %% Data for the whole session
            if jx==1
                clear transposed_data
                transposed_data = summary_all_con(ix).LidDiameterMatrix';
                data_long_con(ix,:)=transposed_data(:)';
                %                 data_long_con_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
            end
        end
    end
    
    %% Reappraisal condition
    % clearing of data matrix before concatenation
    clear data_rp
    % concatenate data for each range
    %% Loop over ranges
    for jx=1:length(range)
        %% Loop over Sessions (1=rp, 2=1h after, 3=24h after)
        for kx=1:3
            data_rp{jx,kx}=[];
            % set counter
            counter=1;
            % Loop over animals (CAVE: only every third sessions in this
            % struct is a reappraisal session)
            for ix=kx:3:length(summary_all_rp)
                
                if kx==1
                    %% Data for each range (=blocks)
                    data_rp{jx,kx}=[data_rp{jx,kx};summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:)];
                    %% Data for the whole session
                    if jx==1
                        clear transposed_data
                        transposed_data = summary_all_rp(ix).LidDiameterMatrix';
                        data_long_rp{kx}(counter,:)=transposed_data(:)';
                        %                         data_long_rp_smoothed{kx}(counter,:)=smooth(transposed_data(:)',smoothing_kernel);
                    end
                elseif kx>1 && jx<3
                    data_rp{jx,kx}=[data_rp{jx,kx};summary_all_rp(ix).LidBaseDiameterMatrix_Corrected(range{jx},:)];
                    %% Data for the whole session
                    if jx==1
                        clear transposed_data
                        transposed_data = summary_all_rp(ix).LidDiameterMatrix';
                        data_long_rp{kx}(counter,:)=transposed_data(:)';
                        %                         data_long_rp_smoothed{kx}(counter,:)=smooth(transposed_data(:)',smoothing_kernel);
                    end
                end
                counter=counter+1;
            end
        end
    end
    
    %% Figure 11: Intra-Trial Plot
    fig15=figure(15);
    fig15.Position = [100 100 840 600];
    
    %% Plot
    % Loop over range
    for jx=1:length(range)
        
        %% Subplot for Control condition (Neroli)
        subplot(1,4,jx);
        sd1=shadedErrorBar([1:size(data_con{jx,1},2)],nanmean(data_con{jx,1}),SEM_calc(data_con{jx,1}));
        sd1.mainLine.Color=[0.5 0.25 0];
        sd1.mainLine.LineWidth=1.5;
        sd1.patch.FaceColor=[0.5 0.25 0];
        sd1.patch.EdgeColor='none';
        sd1.edge(1).Color='none';
        sd1.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        sd2=shadedErrorBar([1:size(data_rp{jx,1},2)],nanmean(data_rp{jx,1}),SEM_calc(data_rp{jx,1}));
        sd2.patch.EdgeColor='none';
        sd2.mainLine.Color=[0 0.5 0.5];
        sd2.mainLine.LineWidth=1.5;
        sd2.patch.FaceColor=[0 0.5 0.5];
        sd2.edge(1).Color='none';sd2.edge(2).Color='none';
        
        %% Subplot for reappraisal condition (Lavender)
        if jx<3
            sd3=shadedErrorBar([1:size(data_rp{jx,2},2)],nanmean(data_rp{jx,2}),SEM_calc(data_rp{jx,2}));
            sd3.patch.EdgeColor='none';
            sd3.mainLine.Color=[0.75 0.25 0.5];
            sd3.mainLine.LineWidth=1.5;
            sd3.mainLine.LineStyle='-';
            sd3.patch.FaceColor=[0.75 0.25 0.5];
            sd3.edge(1).Color='none';sd3.edge(2).Color='none';
            
            sd4=shadedErrorBar([1:size(data_rp{jx,3},2)],nanmean(data_rp{jx,3}),SEM_calc(data_rp{jx,3}));
            sd4.patch.EdgeColor='none';
            sd4.mainLine.Color=[0 0.25 0.5];
            sd4.mainLine.LineWidth=1.5;
            sd4.mainLine.LineStyle='-';
            sd4.patch.FaceColor=[0 0.25 0.5];
            sd4.edge(1).Color='none';sd4.edge(2).Color='none';
        end
        
        
        
        % axes
        ax=gca;
        ax.YLim=[0.6,1.2];
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
        
        %         % Sign. *
        %         %         clear h p
        %         reappraisal_all = summary_all_rp(1:3:end);
        %         % Loop over time bins per trial
        %         for curr_bin=1:size(reappraisal_all(1).LidBaseDiameterMatrix_Corrected,2)
        %             % set counter
        %             counter=1;
        %             % animal ID
        %             for animal_ID=1:length(reappraisal_all)
        %                 % trial
        %                 for tr=1:120
        %                     % restriction: only consider block 1 and 3
        %                     if tr>10 && tr<41 | tr>80 && tr<121
        %                         % block
        %                         if tr>10 && tr<41
        %                             block(counter)=-1;
        %                         elseif tr>80 && tr<121
        %                             block(counter)=1;
        %                         else
        %                             block(counter)=0;
        %                         end
        %
        %                         % puff
        %                         % puff(counter)=reappraisal_all(animal_ID).puff_or_not(tr);
        %
        %                         % time point
        %                         % timepoint(counter)=tr;
        %
        %                         % animal
        %                         animal(counter)=animal_ID;
        %
        %                         % lid
        %                         lid(counter)=reappraisal_all(animal_ID).LidBaseDiameterMatrix_Corrected(tr,curr_bin);
        %
        %                         % counter update
        %                         counter=counter+1;
        %                     end
        %                 end
        %             end
        %             % create the input table
        %             myTable(curr_bin).input = table(block',animal',lid','VariableNames',{'block','animal','lid'});
        %             myTable(curr_bin).input.animal = categorical(myTable(curr_bin).input.animal);
        %             myTable(curr_bin).input.block = categorical(myTable(curr_bin).input.block);
        %             % fit linear mixed effects model
        %             lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + (1|animal)');
        %             % p values
        %             p_intercept(curr_bin)=double(lme.Coefficients(1,6));
        %             p_block(curr_bin)=double(lme.Coefficients(2,6));
        %             % betas
        %             beta_intercept(curr_bin)=double(lme.Coefficients(1,2));
        %             beta_block(curr_bin)=double(lme.Coefficients(2,2));
        %         end
        %
        %         % Plotting of sign-stars
        %         p=p_block;
        %         for px=1:length(p)
        %             if p(px)<0.001
        %                 text(px,ax.YLim(2)*0.99,'*');
        %                 text(px,ax.YLim(2)*0.98,'*');
        %                 text(px,ax.YLim(2)*0.97,'*');
        %             elseif p(px)<0.01
        %                 text(px,ax.YLim(2)*0.99,'*');
        %                 text(px,ax.YLim(2)*0.98,'*');
        %             elseif p(px)<0.05
        %                 text(px,ax.YLim(2)*0.99,'*');
        %             end
        %         end
        
        % legend
        if jx==1
            ll=legend([sd1.mainLine,sd2.mainLine,sd3.mainLine,sd4.mainLine],'Con.(Ner)','Reapp.(Lav)','1h-post(Lav)','24h-post(Lav)','Location','South');
        end
        
        % Title
        tt=title(['Tr. ' num2str(range{jx}(1)) '-' num2str(range{jx}(end))]);
    end
    
    % Super title
    sp=suptitle('lid data (pooled)');
    
    % print
%     print('-dpsc',fullfile(outputDir,['Plots_Lid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
%     print('-dpdf',fullfile(outputDir,['Plots_Lid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
    
    %% Additional figure: Comparison between Reappraisal block 1 and block 3
    % figure
    fig16=figure(16);
    fig16.Position = [100 100 440 400];
    
    %% Subplot for Reappraisal Block 1
    sd1=shadedErrorBar([1:size(data_rp{1,1},2)],nanmean(data_rp{1,1}),SEM_calc(data_rp{1}));
    sd1.mainLine.Color=[0.7 0.25 0];
    sd1.mainLine.LineWidth=1.5;
    sd1.patch.FaceColor=[0.7 0.25 0];
    sd1.patch.EdgeColor='none';
    sd1.edge(1).Color='none';
    sd1.edge(2).Color='none';
    
    %% Subplot for Reappraisal Block 3
    hold on;
    sd2=shadedErrorBar([1:size(data_rp{3,1},2)],nanmean(data_rp{3,1}),SEM_calc(data_rp{3,1}));
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
    % CAVE: Include the random slope (block|animal) or not (1|animal)
    % changes the results !!! -->
    % Oberauer K. The Importance of Random Slopes in Mixed Models for Bayesian Hypothesis Testing. Psychol Sci. 2022 Apr;33(4):648-665. doi: 10.1177/09567976211046884. Epub 2022 Mar 31. PMID: 35357978.
    clear h p
    reappraisal_all = summary_all_rp(1:3:end);
    % Loop over time bins per trial
    for curr_bin=1:size(reappraisal_all(1).LidBaseDiameterMatrix_Corrected,2)
        % set counter
        counter=1;
        % animal ID
        for animal_ID=1:length(reappraisal_all)
            % trial
            for tr=1:160
                % restriction: only consider block 1 and 3
                if tr>10 && tr<41 | tr>80 && tr<121
                    % block
                    if tr>10 && tr<41
                        block(counter)=1;
                    elseif tr>80 && tr<121
                        block(counter)=3;
                    elseif tr<11
                        block(counter)=0;
                    elseif tr>40 && tr<81
                        block(counter)=2;
                    elseif tr>120
                        block(counter)=4;
                    end
                    
                    % puff
                    puff(counter)=reappraisal_all(animal_ID).puff_or_not(tr);
                    
                    % time point
                    % timepoint(counter)=tr;
                    
                    % animal
                    animal(counter)=animal_ID;
                    
                    % lid
                    lid(counter)=reappraisal_all(animal_ID).LidBaseDiameterMatrix_Corrected(tr,curr_bin);
                    
                    % counter update
                    counter=counter+1;
                end
            end
        end
        % create the input table
        %             myTable(curr_bin).input = table(block',animal',lid','VariableNames',{'block','animal','lid'});
        myTable(curr_bin).input = table(block',animal',lid',puff','VariableNames',{'block','animal','lid','puff'});
        
        myTable(curr_bin).input.animal = categorical(myTable(curr_bin).input.animal);
        myTable(curr_bin).input.block = categorical(myTable(curr_bin).input.block);
        % fit linear mixed effects model
        lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + (1|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
        %         lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + (block|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
        % % % % %% for e.g. robust r-models:
        %%%%%%% https://cran.r-project.org/web/packages/robustlmm/robustlmm.pdf
        % % % % # fit a mixed model
        % % % % model <- lmer(lid ~ block+(1|animal), data=dataset)
        % % % % # fit the robust equivalent
        % % % % robust.model <- rlmer(lid ~ block+(1|animal), data=dataset)
        % % % % # get coefficients from non-robust model to extract Satterthwaite approximated DFs
        % % % % coefs <- data.frame(coef(summary(model)))
        % % % % # get coefficients from robust model to extract t-values
        % % % % coefs.robust <- coef(summary(robust.model))
        % % % % # calculate p-values based on robust t-values and non-robust approx. DFs
        % % % % p.values <- 2*pt(abs(coefs.robust[,3]), coefs$df, lower=FALSE)
        % % % % p.values
        % CoefTest
        %             [PVAL,F,DF1,DF2] = coefTest(lme,[0,-1,0,1,0,0]);
        [PVAL,F,DF1,DF2] = coefTest(lme,[0,1]);
        p_contrast(curr_bin)=PVAL;
        
        % AIC/BIC
        AIC(curr_bin)=double(lme.ModelCriterion(1,1));
        BIC(curr_bin)=double(lme.ModelCriterion(1,2));
        
        % p values
                    p_intercept(curr_bin)=double(lme.Coefficients(1,6));
                    p_block(curr_bin)=double(lme.Coefficients(2,6));
%                     p_puff(curr_bin)=double(lme.Coefficients(3,6));
        p_all(:,curr_bin)=double(lme.Coefficients(:,6));
        
        % betas
                    beta_intercept(curr_bin)=double(lme.Coefficients(1,2));
                    beta_block(curr_bin)=double(lme.Coefficients(2,2));
%                     beta_puff(curr_bin)=double(lme.Coefficients(3,6));
        beta_all(:,curr_bin)=double(lme.Coefficients(:,2));
        
    end
    
    %% 
    starter=[25,45]; starter_range=[10,10]%starts at 600ms
    for rrx=1:length(starter)
        clear myPupil
        for iix=1:starter_range(rrx);
            myLid(:,iix)=myTable(starter(rrx)+iix).input.lid; 
        end
        myTableMean = myTable(1).input;
        myTableMean.lid = nanmean(myLid')';
        lme = fitlme(myTableMean,'lid ~ 1 + block + (1|animal)');
        % p values
        p_intercept_range(rrx)=double(lme.Coefficients(1,6));
        p_block_range(rrx)=double(lme.Coefficients(2,6));
        % betas
        beta_intercept_range(rrx)=double(lme.Coefficients(1,2));
        beta_block_range(rrx)=double(lme.Coefficients(2,2));
    end
    
    % Plotting of sign-stars
    p=p_contrast;
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
%     print('-dpsc',fullfile(outputDir,['Plots_Lid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
%     print('-dpdf',fullfile(outputDir,['Plots_Lid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
    
    %% Subplot 2: Session-Plot
    for ix=1:2
        %% Figure 13/4: Session Plot
        if ix==1
            fig17=figure(17);
            fig17.Position = [100 100 840 1000];
        elseif ix==2
            fig18=figure(18);
            fig18.Position = [100 100 840 1000];
        end
        
        %% Subplot for reappraisal condition (Lavender)
        clear sd
        for jx=1:length(data_long_rp)+1
            
            hold on;
            subplot(4,5,(1:3)+(jx-1)*5);
            if ix==1 && jx<4
                sd{jx}=shadedErrorBar([1:size(data_long_rp{jx},2)],nanmean(data_long_rp{jx}),SEM_calc(data_long_rp{jx}));
            elseif ix==1 && jx==4
                sd{jx}=shadedErrorBar([1:size(data_long_con,2)],nanmean(data_long_con),SEM_calc(data_long_con));
            elseif ix==2 && jx<4
                sd{jx}=shadedErrorBar([1:size(data_long_rp_smoothed{jx},2)],nanmean(data_long_rp_smoothed{jx}),SEM_calc(data_long_rp_smoothed{jx}));
            elseif ix==2 && jx==4
                sd{jx}=shadedErrorBar([1:size(data_long_con_smoothed,2)],nanmean(data_long_con_smoothed),SEM_calc(data_long_con_smoothed));
            end
            sd{jx}.patch.EdgeColor='none';
            sd{jx}.mainLine.Color=color_scheme{jx};
            sd{jx}.mainLine.LineWidth=1.5;
            sd{jx}.patch.FaceColor=color_scheme{jx};
            sd{jx}.edge(1).Color='none';
            sd{jx}.edge(2).Color='none';
            
            % axes
            ax=gca;
            if jx<4
                ax.YLim=[nanmean(nanmean(data_long_rp{jx}))-3*nanmean(nanstd(data_long_rp{jx})),nanmean(nanmean(data_long_rp{jx}))+3*nanmean(nanstd(data_long_rp{jx}))];
                ax.XTick=[0:1200:size(data_long_rp{jx},2)];
                ax.XTickLabel=[0:2:size(data_long_rp{jx},2)/600];
            elseif jx==4
                ax.YLim=[nanmean(nanmean(data_long_con))-3*nanmean(nanstd(data_long_con)),nanmean(nanmean(data_long_con))+3*nanmean(nanstd(data_long_con))];
                ax.XTick=[0:1200:size(data_long_con,2)];
                ax.XTickLabel=[0:2:size(data_long_con,2)/600];
            end
            ax.YLabel.String='A.U.';
            ax.XLabel.String='time [min]';
            ax.FontWeight='bold';
            ax.LineWidth=1;
            
            %% Mixed effects model
            lid_data=[];
            block_data=[];
            animal_ID=[];
            for block=1:4
                for animal=1:9
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
            
            % plot odor
            if jx==1 || jx==4
                hold on;
                pt=patch([size(data_long_rp{1},2)/4+1,(size(data_long_rp{1},2)*2)/4,(size(data_long_rp{1},2)*2)/4,size(data_long_rp{1},2)/4+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
                pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
                txp=text(size(data_long_rp{1},2)/4+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
                txp.Color=[0.2,0.2,0.2];
            end
            
            % legend
            ll=legend([sd{jx}.mainLine],naming_scheme{jx});
            
            % title
            if ix==1 && jx==1
                tt=title('lid data unsmoothed');
            elseif ix==2 && jx==1
                tt=title(['lid data smoothed (' num2str(smoothing_kernel) ' kernel)']);
            end
            
            %% subplot mean-val
            hold on;
            subplot(4,5,(4:5)+(jx-1)*5);
            
            if jx==1
                notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2),nanmean(data_long_rp{jx}(:,120*119+1:160*119),2)])
            elseif jx>1 && jx<4
                notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2)])
            elseif jx==4
                notBoxPlot_modified_pupilANDlid([nanmean(data_long_con(:,0*119+1:40*119),2),nanmean(data_long_con(:,40*119+1:80*119),2),nanmean(data_long_con(:,80*119+1:120*119),2),nanmean(data_long_con(:,120*119+1:160*119),2)])
            end
            
            
            
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
            
            %%
            if jx==1 || jx==4
                clear myData
                if jx==1
                    for sx=1:4
                        myData(:,sx)=nanmean(data_long_rp{1}(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2);
                    end
                elseif jx==4
                    for sx=1:4
                        myData(:,sx)=nanmean(data_long_con(:,(range{sx}(1)-1)*119+1:range{sx}(end)*119),2);
                    end
                end
                t = table(myData(:,1),myData(:,2),myData(:,3),myData(:,4),...
                    'VariableNames',{'meas1','meas2','meas3','meas4'});
                Meas = table([1 2 3]','VariableNames',{'Measurements'});
                rm = fitrm(t,'meas1-meas3~1','WithinDesign',Meas);
                multcompare(rm,'Measurements');
            end
            
            % %         % Sign. *
            %% Mixed effects model
            lid_dia=[];
            block_data=[];
            animal_ID=[];
            if jx==1
                for block=1:4
                    for animal=1:size(data_long_rp{1},1)
                        lid_dia=[lid_dia,data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                        animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                        block_data=[block_data,block.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                    end
                end
            elseif jx>1 && jx<4
                for block=1:2
                    for animal=1:size(data_long_rp{1},1)
                        lid_dia=[lid_dia,data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                        animal_ID=[animal_ID,animal.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                        block_data=[block_data,block.*ones(1,length(data_long_rp{jx}(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                    end
                end
            elseif jx==4
                for block=1:4
                    for animal=1:size(data_long_con,1)
                        lid_dia=[lid_dia,data_long_con(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)];
                        animal_ID=[animal_ID,animal.*ones(1,length(data_long_con(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                        block_data=[block_data,block.*ones(1,length(data_long_con(animal,(range{block}(1)-1)*119+1:range{block}(end)*119)))];
                    end
                end
            end
            
            myInputTable = table(block_data',animal_ID',lid_dia','VariableNames',{'block','animal','lid'});
            myInputTable.animal = categorical(myInputTable.animal);
            myInputTable.block = categorical(myInputTable.block);
            % fit linear mixed effects model
            %             lme = fitlme(myTable(curr_bin).input,'pupil ~ 1 + block + puff + (1|animal)'); % CAVE: block|animal makes the results less significant, only few data points around the TP of puff would survive
            lme = fitlme(myInputTable,'lid ~ 1 + block + (block|animal)');
            
            
            
            
            clear h p
            if jx==1
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
            end
            
            
            % print
%             print('-dpsc',fullfile(outputDir,['Plots_Intrasession_Lid_reappraisal_fMRI_2022']),'-painters','-r400','-append');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Pooled plot: PupilMovement
    if 1==0
        %% Control condition
        % clearing of data matrix before concatenation
        clear data_con
        % concatenate data for each range
        % Loop over ranges
        for jx=1:length(range)
            data_con{jx,1}=[];
            % Loop over sessions
            for ix=1:length(summary_all_con)
                %% Data for each range (=blocks)
                data_con{jx}=[data_con{jx};summary_all_con(ix).PupilBaseMovementMatrix_Corrected(range{jx},:)];
                %% Data for the whole session
                if jx==1
                    clear transposed_data
                    transposed_data = summary_all_con(ix).PupilMovementMatrix';
                    data_long_con(ix,:)=transposed_data(:)';
                    %                 data_long_con_smoothed(ix,:)=smooth(transposed_data(:)',smoothing_kernel);
                end
            end
        end
        
        %% Reappraisal condition
        % clearing of data matrix before concatenation
        clear data_rp
        % concatenate data for each range
        %% Loop over ranges
        for jx=1:length(range)
            %% Loop over Sessions (1=rp, 2=1h after, 3=24h after)
            for kx=1:3
                data_rp{jx,kx}=[];
                % set counter
                counter=1;
                % Loop over animals (CAVE: only every third sessions in this
                % struct is a reappraisal session)
                for ix=kx:3:length(summary_all_rp)
                    
                    if kx==1
                        %% Data for each range (=blocks)
                        data_rp{jx,kx}=[data_rp{jx,kx};summary_all_rp(ix).PupilBaseMovementMatrix_Corrected(range{jx},:)];
                        %% Data for the whole session
                        if jx==1
                            clear transposed_data
                            transposed_data = summary_all_rp(ix).PupilMovementMatrix';
                            data_long_rp{kx}(counter,:)=transposed_data(:)';
                            %                         data_long_rp_smoothed{kx}(counter,:)=smooth(transposed_data(:)',smoothing_kernel);
                        end
                    elseif kx>1 && jx<3
                        data_rp{jx,kx}=[data_rp{jx,kx};summary_all_rp(ix).PupilBaseMovementMatrix_Corrected(range{jx},:)];
                        %% Data for the whole session
                        if jx==1
                            clear transposed_data
                            transposed_data = summary_all_rp(ix).PupilMovementMatrix';
                            data_long_rp{kx}(counter,:)=transposed_data(:)';
                            %                         data_long_rp_smoothed{kx}(counter,:)=smooth(transposed_data(:)',smoothing_kernel);
                        end
                    end
                    counter=counter+1;
                end
            end
        end
        
        %% Figure 11: Intra-Trial Plot
        fig15=figure(15);
        fig15.Position = [100 100 840 600];
        
        %% Plot
        % Loop over range
        for jx=1:length(range)
            
            %% Subplot for Control condition (Neroli)
            subplot(1,4,jx);
            sd1=shadedErrorBar([1:size(data_con{jx,1},2)],nanmean(data_con{jx,1}),SEM_calc(data_con{jx,1}));
            sd1.mainLine.Color=[0.5 0.25 0];
            sd1.mainLine.LineWidth=1.5;
            sd1.patch.FaceColor=[0.5 0.25 0];
            sd1.patch.EdgeColor='none';
            sd1.edge(1).Color='none';
            sd1.edge(2).Color='none';
            
            %% Subplot for reappraisal condition (Lavender)
            sd2=shadedErrorBar([1:size(data_rp{jx,1},2)],nanmean(data_rp{jx,1}),SEM_calc(data_rp{jx,1}));
            sd2.patch.EdgeColor='none';
            sd2.mainLine.Color=[0 0.5 0.5];
            sd2.mainLine.LineWidth=1.5;
            sd2.patch.FaceColor=[0 0.5 0.5];
            sd2.edge(1).Color='none';sd2.edge(2).Color='none';
            
            %% Subplot for reappraisal condition (Lavender)
            if jx<3
                sd3=shadedErrorBar([1:size(data_rp{jx,2},2)],nanmean(data_rp{jx,2}),SEM_calc(data_rp{jx,2}));
                sd3.patch.EdgeColor='none';
                sd3.mainLine.Color=[0.75 0.25 0.5];
                sd3.mainLine.LineWidth=1.5;
                sd3.mainLine.LineStyle='-';
                sd3.patch.FaceColor=[0.75 0.25 0.5];
                sd3.edge(1).Color='none';sd3.edge(2).Color='none';
                
                sd4=shadedErrorBar([1:size(data_rp{jx,3},2)],nanmean(data_rp{jx,3}),SEM_calc(data_rp{jx,3}));
                sd4.patch.EdgeColor='none';
                sd4.mainLine.Color=[0 0.25 0.5];
                sd4.mainLine.LineWidth=1.5;
                sd4.mainLine.LineStyle='-';
                sd4.patch.FaceColor=[0 0.25 0.5];
                sd4.edge(1).Color='none';sd4.edge(2).Color='none';
            end
            
            
            
            % axes
            ax=gca;
            ax.YLim=[0,5];
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
            
            % Sign. *
            %         clear h p
            [h,p]=ttest2(data_rp{jx,1},data_con{jx,1});
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
            if jx==1
                ll=legend([sd1.mainLine,sd2.mainLine,sd3.mainLine,sd4.mainLine],'Con.(Ner)','Reapp.(Lav)','1h-post(Lav)','24h-post(Lav)','Location','South');
            end
            
            % Title
            tt=title(['Tr. ' num2str(range{jx}(1)) '-' num2str(range{jx}(end))]);
        end
        
        % Super title
        sp=suptitle('lid data (pooled)');
        
        % print
        print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
        print('-dpdf',fullfile(outputDir,['Plots_LID_1_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
        
        %% Additional figure: Comparison between Reappraisal block 1 and block 3
        % figure
        fig16=figure(16);
        fig16.Position = [100 100 440 400];
        
        %% Subplot for Reappraisal Block 1
        sd1=shadedErrorBar([1:size(data_rp{1,1},2)],nanmean(data_rp{1,1}),SEM_calc(data_rp{1}));
        sd1.mainLine.Color=[0.7 0.25 0];
        sd1.mainLine.LineWidth=1.5;
        sd1.patch.FaceColor=[0.7 0.25 0];
        sd1.patch.EdgeColor='none';
        sd1.edge(1).Color='none';
        sd1.edge(2).Color='none';
        
        %% Subplot for Reappraisal Block 3
        hold on;
        sd2=shadedErrorBar([1:size(data_rp{3,1},2)],nanmean(data_rp{3,1}),SEM_calc(data_rp{3,1}));
        sd2.patch.EdgeColor='none';
        sd2.mainLine.Color=[0 0.5 0.7];
        sd2.mainLine.LineWidth=1.5;
        sd2.patch.FaceColor=[0 0.5 0.7];
        sd2.edge(1).Color='none';sd2.edge(2).Color='none';
        
        % axes
        ax=gca;
        ax.YLim=[0,5];
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
        [h,p]=ttest2(data_rp{1,1},data_rp{3,1});
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
        print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400','-append');
        print('-dpdf',fullfile(outputDir,['Plots_LID_2_PupilAndLid_reappraisal_ephys_2022_VS_160TrialsNeroli']),'-painters','-r400');
        
        %% Subplot 2: Session-Plot
        for ix=1:2
            %% Figure 13/4: Session Plot
            if ix==1
                fig17=figure(17);
                fig17.Position = [100 100 840 1000];
            elseif ix==2
                fig18=figure(18);
                fig18.Position = [100 100 840 1000];
            end
            
            %% Subplot for reappraisal condition (Lavender)
            clear sd
            for jx=1:length(data_long_rp)+1
                
                hold on;
                subplot(4,5,(1:3)+(jx-1)*5);
                if ix==1 && jx<4
                    sd{jx}=shadedErrorBar([1:size(data_long_rp{jx},2)],nanmean(data_long_rp{jx}),SEM_calc(data_long_rp{jx}));
                elseif ix==1 && jx==4
                    sd{jx}=shadedErrorBar([1:size(data_long_con,2)],nanmean(data_long_con),SEM_calc(data_long_con));
                elseif ix==2 && jx<4
                    sd{jx}=shadedErrorBar([1:size(data_long_rp_smoothed{jx},2)],nanmean(data_long_rp_smoothed{jx}),SEM_calc(data_long_rp_smoothed{jx}));
                elseif ix==2 && jx==4
                    sd{jx}=shadedErrorBar([1:size(data_long_con_smoothed,2)],nanmean(data_long_con_smoothed),SEM_calc(data_long_con_smoothed));
                end
                sd{jx}.patch.EdgeColor='none';
                sd{jx}.mainLine.Color=color_scheme{jx};
                sd{jx}.mainLine.LineWidth=1.5;
                sd{jx}.patch.FaceColor=color_scheme{jx};
                sd{jx}.edge(1).Color='none';
                sd{jx}.edge(2).Color='none';
                
                % axes
                ax=gca;
                if jx<4
                    ax.YLim=[nanmean(nanmean(data_long_rp{jx}))-3*nanmean(nanstd(data_long_rp{jx})),nanmean(nanmean(data_long_rp{jx}))+3*nanmean(nanstd(data_long_rp{jx}))];
                    ax.XTick=[0:1200:size(data_long_rp{jx},2)];
                    ax.XTickLabel=[0:2:size(data_long_rp{jx},2)/600];
                elseif jx==4
                    ax.YLim=[nanmean(nanmean(data_long_con))-3*nanmean(nanstd(data_long_con)),nanmean(nanmean(data_long_con))+3*nanmean(nanstd(data_long_con))];
                    ax.XTick=[0:1200:size(data_long_con,2)];
                    ax.XTickLabel=[0:2:size(data_long_con,2)/600];
                end
                ax.YLabel.String='A.U.';
                ax.XLabel.String='time [min]';
                ax.FontWeight='bold';
                ax.LineWidth=1;
                
                % plot odor
                if jx==1 || jx==4
                    hold on;
                    pt=patch([size(data_long_rp{1},2)/4+1,(size(data_long_rp{1},2)*2)/4,(size(data_long_rp{1},2)*2)/4,size(data_long_rp{1},2)/4+1],[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],[0.2,0.2,0.2]);
                    pt.FaceAlpha=0.2; pt.EdgeAlpha=0;
                    txp=text(size(data_long_rp{1},2)/4+100,[ax.YLim(1)+(ax.YLim(2)-ax.YLim(1))*0.1],'Puff-Block');
                    txp.Color=[0.2,0.2,0.2];
                end
                
                % legend
                ll=legend([sd{jx}.mainLine],naming_scheme{jx});
                
                % title
                if ix==1 && jx==1
                    tt=title('lid data unsmoothed');
                elseif ix==2 && jx==1
                    tt=title(['lid data smoothed (' num2str(smoothing_kernel) ' kernel)']);
                end
                
                %% subplot mean-val
                hold on;
                subplot(4,5,(4:5)+(jx-1)*5);
                if ix==1
                    if jx==1
                        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2),nanmean(data_long_rp{jx}(:,120*119+1:160*119),2)])
                    elseif jx>1 && jx<4
                        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,40*119+1:80*119),2)])
                    elseif jx==4
                        notBoxPlot_modified_pupilANDlid([nanmean(data_long_con(:,0*119+1:40*119),2),nanmean(data_long_con(:,40*119+1:80*119),2),nanmean(data_long_con(:,80*119+1:120*119),2),nanmean(data_long_con(:,120*119+1:160*119),2)])
                    end
                elseif ix==2
                    if jx==1
                        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp_smoothed{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed{jx}(:,40*119+1:80*119),2),nanmean(data_long_rp_smoothed{jx}(:,80*119+1:120*119),2),nanmean(data_long_rp_smoothed{jx}(:,120*119+1:160*119),2)])
                    elseif jx>1 && jx<4
                        notBoxPlot_modified_pupilANDlid([nanmean(data_long_rp_smoothed{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed{jx}(:,40*119+1:80*119),2)])
                    elseif jx==4
                        notBoxPlot_modified_pupilANDlid([nanmean(data_long_con_smoothed(:,0*119+1:40*119),2),nanmean(data_long_con_smoothed(:,40*119+1:80*119),2),nanmean(data_long_con_smoothed(:,80*119+1:120*119),2),nanmean(data_long_con_smoothed(:,120*119+1:160*119),2)])
                    end
                end
                
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
                
                % Sign. *
                if jx==1
                    clear h p
                    if ix==1
                        [p,h]=signrank(nanmean(data_long_rp{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp{jx}(:,80*119+1:120*119),2));
                    elseif ix==2
                        [p,h]=signrank(nanmean(data_long_rp_smoothed{jx}(:,0*119+1:40*119),2),nanmean(data_long_rp_smoothed{jx}(:,80*119+1:120*119),2));
                    end
                    for px=1:length(p)
                        if p(px)<0.001
                            sigstar({{'1','3'}},0.001,0,20)
                        elseif p(px)<0.01
                            sigstar({{'1','3'}},0.01,0,20)
                        elseif p(px)<0.05
                            sigstar({{'1','3'}},0.05,0,20)
                        end
                    end
                end
            end
        end
        % print
        print('-dpsc',fullfile(outputDir,['Plots_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400','-append');
        if ix==1
            print('-dpdf',fullfile(outputDir,['Plots_LID_INTRASESSION_UMSMOOTHED_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400');
        elseif ix==2
            print('-dpdf',fullfile(outputDir,['Plots_LID_INTRASESSION_SMOOTHED_PupilAndLid_reappraisal_fMRI_2022']),'-painters','-r400');
        end
    end
end
