function meanTimeCourseAnalysis_JR

% Jonathan Reinwald 02/2019 based on script by LW
% "meanTimeCourseAnalysis_JR" calculates the mean Timecourse for a
% specified region of interest (ROI), calculates means frame by frame for the different trials (sessionwise)
% and  then creates means throughout all sessions ...
% reults are plotted in the end ...


%% PREP

clear all; close all;

%% LOAD VARIABLES/STRUCTS ...

studydir='/data2/jonathan/Awake/fmri_data/'; cd(studydir)
outputdir='/data2/jonathan/Awake/TimeCourse_analysis/RESIDUALS_12RPs_framesCeiled_thresh0';

% for loop over all sessions ...
load([studydir filesep 'filelist_awake_MAIN_JR.mat'], 'Pfunc');

% valid sessions - criterion: behavorial performance ...
array_valid_sessions= [1:83]%paradigm.performance_check.valid_sessions;


%% GET YOUR BINARY MASK FOR DEFINING YOUR ROI ...
% select as many masks as you want ... LOOP over all masks selected ...
cd('/data2/jonathan/Awake/atlas/REGIONS OF INTEREST/');
[Pmsk,~]=spm_select(Inf,'any','Select Mask',[],pwd,'.*..nii');




%% LOOP OVER MASKS SELECTED
for Nmask = 1:size(Pmsk,1)
    
    % get MASKname ...
    Pmsk_cur = Pmsk(Nmask,:);
    [~, fname_mask, ~]=fileparts(Pmsk_cur);
    fname_mask = strrep(fname_mask,'_',' ');
    
    % for analysis of residuals ...
    firstleveldir = '/data2/jonathan/Awake/stats_FirstLevel/FirstLevelResiduals_RP';
    dirlist = dir(firstleveldir);
    dirlist = dirlist(contains({dirlist.name},'PD'));
    numbersess = numel(dirlist);
    
            %% SAVE PLOTS ...
            newdir = [outputdir filesep fname_mask];
            mkdir(newdir);
            addon = ' - 12 rps '
            
    %%  LET'S GETTING STARTED ...
    counter = 1; % create counter to avoid emtpy rows occuring when just using ix as index ...
    array_valid_sessions(74)=[];
    
    for ix=array_valid_sessions(1:end)
        
        ix
        run = counter
        
        %% PREP current session
        % get EPI path ...
        % [fdir, fname, ext]=fileparts(Pfunc{ix});
        % Pcur=spm_select('FpList', fdir , ['^s_wst_a_u_del5_' fname '_c1_c2t.nii']);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        
        % for analysis of residuals ...
        % info fmri sess
        
        subject = fdir(53:56);
        date = fname(5:10);
        % get sessiondir ...
        a = contains({dirlist.name}, date) & contains({dirlist.name}, [num2str(subject)]);
        dir_residuals = dirlist(find(a ==1)).name;
        sessiondir = [firstleveldir filesep dir_residuals filesep 'rp_der'];
        
        % select ...
        Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_' dir_residuals '.nii']);
        
        
        %% get meanTc of current session ...
        
        [tc roidata]=wwf_roi_tcours_old(Pmsk_cur,Pcur);
        
        
        %% modify tc ...
        
        % detrend data ...
        tc_detr = detrend(tc);
        
        % normalize data ..
        tc_detr_norm = zscore(tc_detr);
        
        %% parse different odors
        
        % get volumes in which odor exposition takes place ...
        % new approach: ceil ...
        TR = 1.2;
        
        load(['/data2/jonathan/Awake/behavioral_data/MRTprediction/fMRI_new_mat_sorted/' fname(1:11) '_' fdir(53:56) '_protocol_new.mat']);

        % define number of frames you want to add to the odor volume for analysis per trial ...
        Nfr = 6;
        
        %% Using all rewarded/non-rewarded trials independent of post-licks
        % tc values are saved in matrix_nonrew and matrix_rew;
        % rows = trials, columns = frames
        selected_nonrew=find([events.drop_or_not]==0);
        odoronset_nonrew = ceil([events(selected_nonrew).fv_on_del5]/TR);
        
        selected_rew=find([events.drop_or_not]==1);
        odoronset_rew = ceil([events(selected_rew).fv_on_del5]/TR);
        
        matrix_nonrew = []; % clear variable ...
       
        for i = 1:numel(odoronset_nonrew)
            OnsetFrame_cur = odoronset_nonrew(i); % frame of odor exposition
            if OnsetFrame_cur <= 1 % occured in onse sess ...
                OnsetFrame_cur = 2;
            end
            Index_frames_cur = (OnsetFrame_cur-1):1:(OnsetFrame_cur+Nfr); % index
            
            % write tc values for current trial to matrix ...
            matrix_nonrew(i,:) = tc_detr_norm(Index_frames_cur);
        end
        
        % means of sessions are saved in "mean_matrix_100" ...
        mean_matrix_nonrew(counter,:) = mean(matrix_nonrew);
        
        
        matrix_rew = []; % clear variable ...
        
        for i = 1:numel(odoronset_rew)
            OnsetFrame_cur = odoronset_rew(i); % frame of odor exposition
            if OnsetFrame_cur <= 1 % occured in onse sess ...
                OnsetFrame_cur = 2;
            end
            Index_frames_cur = (OnsetFrame_cur-1):1:(OnsetFrame_cur+Nfr); % index
            
            % write tc values for current trial to matrix ...
            matrix_rew(i,:) = tc_detr_norm(Index_frames_cur);
        end
        
        % means of sessions are saved in "mean_matrix_100" ...
        mean_matrix_rew(counter,:) = mean(matrix_rew);
               
        % Figure for every single animal:
        x_vals = -0.5:1:Nfr+0.5;
        f1 = figure(10);
        set(f1,'Units','Inches');
        set(f1,'Position',[0 0 6 6]);
        p1 = errorbar(x_vals,mean(matrix_rew),std(matrix_rew)/sqrt(size(matrix_rew,1)),'Color','r','LineWidth',1);
        hold on
        p2 = errorbar(x_vals,mean(matrix_nonrew),std(matrix_nonrew)/sqrt(size(matrix_nonrew,1)),'Color','b','LineWidth',1);
        hold on
        title(['Rew - NonRew' fname_mask]);
        tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
        tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
        tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
        
        xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
        xlabel('Time (x1.2 s)');ylabel('BOLD SIGNAL [%]');
        fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
        fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
        
        legend({'rew','nonrew'});
        title([fname(1:11) '_' fdir(53:56)]);
        
        print(gcf,'-dpsc2','-append',[newdir filesep 'Rew - NonRew - Trials' fname_mask]);
        
        close(figure(10));
        
        %% Using only rewarded/non-rewarded trials with a post-lick
        for kx=1:length(events); 
            kx
            if ~isempty(events(kx).licks_del5) && sum((events(kx).licks_del5 < events(kx).fv_off_del5+1.7+2*1.2) & (events(kx).licks_del5 > events(kx).fv_off_del5+1.7))>0;
                events(kx).licks_post2TR=1;
            else
                events(kx).licks_post2TR=0;
            end;
        end;
        
        clear selected_nonrew odoronset_nonrew selected_rew odoronset_rew
        
        % Select only rewarded/non-rewarded trials with a post-lick
        % ([events.licks_post2TR]==1)
        selected_nonrew=find([events.drop_or_not]==0 & [events.licks_post2TR]==1);
        odoronset_nonrew = ceil([events(selected_nonrew).fv_on_del5]/TR);
        
        selected_rew=find([events.drop_or_not]==1 & [events.licks_post2TR]==1);
        odoronset_rew = ceil([events(selected_rew).fv_on_del5]/TR);
        
        matrix_nonrew = []; % clear variable ...
       
        for i = 1:numel(odoronset_nonrew)
            OnsetFrame_cur = odoronset_nonrew(i); % frame of odor exposition
            if OnsetFrame_cur <= 1 % occured in onse sess ...
                OnsetFrame_cur = 2;
            end
            Index_frames_cur = (OnsetFrame_cur-1):1:(OnsetFrame_cur+Nfr); % index
            
            % write tc values for current trial to matrix ...
            matrix_nonrew(i,:) = tc_detr_norm(Index_frames_cur);
        end
        
        % means of sessions are saved in "mean_matrix_100" ...
        mean_matrix_nonrew_2(counter,:) = mean(matrix_nonrew);
        
        
        matrix_rew = []; % clear variable ...
        
        for i = 1:numel(odoronset_rew)
            OnsetFrame_cur = odoronset_rew(i); % frame of odor exposition
            if OnsetFrame_cur <= 1 % occured in onse sess ...
                OnsetFrame_cur = 2;
            end
            Index_frames_cur = (OnsetFrame_cur-1):1:(OnsetFrame_cur+Nfr); % index
            
            % write tc values for current trial to matrix ...
            matrix_rew(i,:) = tc_detr_norm(Index_frames_cur);
        end
        
        % means of sessions are saved in "mean_matrix_100" ...
        mean_matrix_rew_2(counter,:) = mean(matrix_rew);
        
        
        x_vals = -0.5:1:Nfr+0.5;
        f1 = figure(10);
        set(f1,'Units','Inches');
        set(f1,'Position',[0 0 6 6]);
        p1 = errorbar(x_vals,mean(matrix_rew),std(matrix_rew)/sqrt(size(matrix_rew,1)),'Color','r','LineWidth',1);
        hold on
        p2 = errorbar(x_vals,mean(matrix_nonrew),std(matrix_nonrew)/sqrt(size(matrix_nonrew,1)),'Color','b','LineWidth',1);
        hold on
        title(['Rew - NonRew' fname_mask]);
        tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
        tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
        tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
        
        xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
        xlabel('Time (x1.2 s)');ylabel('BOLD SIGNAL [%]');
        fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
        fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
        
        legend({'rew','nonrew'});
        title([fname(1:11) '_' fdir(53:56)]);
        
        print(gcf,'-dpsc2','-append',[newdir filesep 'RewReceived - RewFrust ' fname_mask]);
        %     print(f2,'-dpdf',[newdir filesep '50 - ' fname_mask addon]);
        %     print(f3,'-dpdf',[newdir filesep '0 - ' fname_mask addon]);
        %     print(f4,'-dpdf',[newdir filesep 'AllOdors - ' fname_mask addon]);
        
        close(figure(10));
        
        %% add 1 to counter ...
        counter = counter +1;
    end
    
    
    
    
    %% CALCULATE TOTAL MEANS (THROUGHOUT ALL SESSIONS INCLUDED IN ANALYSIS)
    mean_matrix_rew=reshape(mean_matrix_rew(~isnan(mean_matrix_rew)),size(mean_matrix_rew,1)-sum(isnan(mean_matrix_rew(:,1))),size(mean_matrix_rew,2))
    mean_matrix_nonrew=reshape(mean_matrix_nonrew(~isnan(mean_matrix_nonrew)),size(mean_matrix_nonrew,1)-sum(isnan(mean_matrix_nonrew(:,1))),size(mean_matrix_nonrew,2))
    mean_matrix_rew_2=reshape(mean_matrix_rew_2(~isnan(mean_matrix_rew_2)),size(mean_matrix_rew_2,1)-sum(isnan(mean_matrix_rew_2(:,1))),size(mean_matrix_rew_2,2))
    mean_matrix_nonrew_2=reshape(mean_matrix_nonrew_2(~isnan(mean_matrix_nonrew_2)),size(mean_matrix_nonrew_2,1)-sum(isnan(mean_matrix_nonrew_2(:,1))),size(mean_matrix_nonrew_2,2))
    
    TOTALmean_rew = mean(mean_matrix_rew);
    TOTALmean_nonrew = mean(mean_matrix_nonrew);
    TOTALmean_rew_2 = mean(mean_matrix_rew_2);
    TOTALmean_nonrew_2 = mean(mean_matrix_nonrew_2);
    % % TOTALmean_50all = mean(mean_matrix_50all);
    % % TOTALmean_0 = mean(mean_matrix_0);
    
    %
    % TOTALmean_50rew = mean(mean_matrix_50rew);
    % TOTALmean_50unrew = mean(mean_matrix_50unrew);
    
    %% CALCULATE STANDARD DEVIATION
    STD_rew = std(mean_matrix_rew)/sqrt(numel(array_valid_sessions));
    STD_nonrew = std(mean_matrix_nonrew)/sqrt(numel(array_valid_sessions));
    STD_rew_2 = std(mean_matrix_rew_2)/sqrt(numel(array_valid_sessions));
    STD_nonrew_2 = std(mean_matrix_nonrew_2)/sqrt(numel(array_valid_sessions));
    
    % STD_50all = std(mean_matrix_50all)/sqrt(numel(array_valid_sessions));
    % STD_0 = std(mean_matrix_0)/sqrt(numel(array_valid_sessions));
    %
    % %
    % STD_50rew = std(mean_matrix_50rew)/sqrt(numel(array_valid_sessions));
    % STD_50unrew = std(mean_matrix_50unrew)/sqrt(numel(array_valid_sessions));
    
    
    %% PLOT RESULTS ...
    
    % PREP ...
    x_vals = -0.5:1:Nfr+0.5;  %x time scale in seconds ...
    
    
    % 100
    f1 = figure(1)
    set(f1,'Units','Inches');
    set(f1,'Position',[0 0 8.5 11]);
    %p1 = plot(x_vals,TOTALmean_100,'Color','k','LineWidth',1);
    subplot(2,1,1);
    p1 = errorbar(x_vals,TOTALmean_rew,STD_rew,'Color','r','LineWidth',1);
    hold on
    p2 = errorbar(x_vals,TOTALmean_nonrew,STD_nonrew,'Color','b','LineWidth',1);
    hold on
    title(['Rew - NonRew' fname_mask]);
    tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
    tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
    tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
    
    xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
    xlabel('Time (x1.2 s)');ylabel('BOLD SIGNAL [%]');
    fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    
    legend({'rew','nonrew'});
    
    subplot(2,1,2);
    p1 = errorbar(x_vals,TOTALmean_rew_2,STD_rew_2,'Color','r','LineWidth',1);
    hold on
    p2 = errorbar(x_vals,TOTALmean_nonrew_2,STD_nonrew_2,'Color','b','LineWidth',1);
    hold on
    title(['Rew - NonRew' fname_mask]);
    tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
    tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
    tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
    
    xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
    xlabel('Time (x1.2 s)');ylabel('BOLD SIGNAL [%]');
    fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    
    legend({'rew','nonrew'});
    
    
    %     % 50
    %     f2 = figure(2)
    %     set(f2,'Units','Inches');
    %     set(f2,'Position',[0 0 8.5 11]);
    %     %p2 = plot(x_vals,TOTALmean_50);
    %     p2 = errorbar(x_vals,TOTALmean_50all,STD_50all,'Color','k','LineWidth',1);
    %     hold on
    %     p4 = errorbar(x_vals,TOTALmean_50rew,STD_50rew,'Color','g','LineWidth',1);
    %     p5 = errorbar(x_vals,TOTALmean_50unrew,STD_50unrew,'Color','r','LineWidth',1);
    %     title(['50% - ' fname_mask]);
    %     tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
    %     tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
    %     tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
    %
    %     xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
    %     xlabel('Time (x1.3 s)');ylabel('BOLD SIGNAL [%]');
    %     fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    %     fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    %
    %     legend('50all','50rew','50unrew');
    %
    %
    %     % 0
    %     f3 = figure(3)
    %     set(f3,'Units','Inches');
    %     set(f3,'Position',[0 0 8.5 11]);
    %     %p3 = plot(x_vals,TOTALmean_0);
    %     p3 = errorbar(x_vals,TOTALmean_0,STD_0,'Color','k','LineWidth',1);
    %     hold on
    %     title(['0% - ' fname_mask]);
    %     tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
    %     tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
    %     tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
    %
    %     xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
    %     xlabel('Time (x1.3 s)');ylabel('BOLD SIGNAL [%]');
    %     fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    %     fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    %
    %     legend('0');
    %
    %
    %
    %     % whole in one ...
    %     f4 = figure(4)
    %     set(f4,'Units','Inches');
    %     set(f4,'Position',[0 0 8.5 11]);
    %     p1 = errorbar(x_vals,TOTALmean_100,STD_100,'Color','b','LineWidth',1);
    %     hold on
    %     p4 = errorbar(x_vals,TOTALmean_50rew,STD_50rew,'Color','g','LineWidth',1);
    %     p5 = errorbar(x_vals,TOTALmean_50unrew,STD_50unrew,'Color','r','LineWidth',1);
    %     p3 = errorbar(x_vals,TOTALmean_0,STD_0,'Color','m','LineWidth',1);
    %     title(['Comparison 100/50/0 - ' fname_mask]);
    %     tt = text(0.5,1,'ODOR','HorizontalAlignment','center','FontWeight','bold');
    %     tt = text(1.5,1,'DELAY','HorizontalAlignment','center','FontWeight','bold');
    %     tt = text(2.5,1,'REWARD','HorizontalAlignment','center','FontWeight','bold');
    %
    %     xlim([-1 Nfr+1]); ylim([-0.8 1.2]);
    %     xlabel('Time (x1.3 s)');ylabel('BOLD SIGNAL [%]');
    %     fill([0 0 1 1],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    %     fill([2 2 3 3],[-0.8 1.2 1.2 -0.8],[0.5 0.5 0.5],'FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.1,'EdgeAlpha',0)
    %
    %     legend('100%','50rew','50unrew','0');
    %
    %
    %
    %
    print(f1,'-dpdf',[newdir filesep 'Rew - ' fname_mask addon]);
    %     print(f2,'-dpdf',[newdir filesep '50 - ' fname_mask addon]);
    %     print(f3,'-dpdf',[newdir filesep '0 - ' fname_mask addon]);
    %     print(f4,'-dpdf',[newdir filesep 'AllOdors - ' fname_mask addon]);
    
    close all;
    
    
end % mask loop ....














end