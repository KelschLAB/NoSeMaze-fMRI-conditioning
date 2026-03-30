%%
% outlier threshhold changed to 10.000
%MA20200422: script transferred to Github repository, new versions can be
%found there
%MA20200414: Baseshift set to 4, BaseLine window OCon-4s:OCon-1s; 
%before baseshift=3, BLwindow OCon-3s-OCon


clear all;

%% PREP ..

% define directories ...
% maindir = '/home/jonathan.reinwald/Awake/pupil_analysis_JR/videodir/'; mkdir(maindir);% all videos in maindir get processed ...
% savedir = '/home/jonathan.reinwald/Awake/pupil_analysis_JR/results/preprocessing'; mkdir(savedir)
% cd(savedir);
% csv_dir='/home/jonathan.reinwald/Awake/pupil_analysis_JR/Jonathan DLC/Videos/csv-files/'


maindir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\Videos\20200130_TD19_EPhys'; if ~isdir(maindir), mkdir(maindir); end% all videos in maindir get processed ...
savedir = 'E:\DATA\TD\20200130_TD19_EPhys'; if ~isdir(savedir), mkdir(savedir); end
csv_dir = '\\zifnas\entwbio\Carla\csv_files';
videodir= maindir;
DigDir='E:\DATA\TD\20200130_TD19_EPhys';
NewDir='E:\DATA\TD\20200130_TD19_EPhys';
addpath(cd);
% a. get all video files saved in maindir ...
Videolist_csv = getAllFiles(csv_dir,'td*.csv',1);
% cd(csv_dir)
% Videolist_csv1 = dir('A00*.csv');
cd(savedir);
%% LOOP OVER VIDEOS STARTS HERE ...

% STEP 1: Read frames, label location and likelihood of csv-files out, plot them and
% create pupil_dia file

if 1==0
    for vid = 1:numel(Videolist_csv);
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
%         fdir=Videolist_csv1(vid).folder;
%         [~,fname,fext]=fileparts(Videolist_csv1(vid).name);
        % abreviations: tp = timepoint, up = upper, r = right, lo = lower, l =
        % left, x = x-value, y = y-value, lh = likelihood;
        [tp,x_up,y_up,lh_up,x_r,y_r,lh_r,x_lo,y_lo,lh_lo,x_l,y_l,lh_l]=textread(Videolist_csv{vid},'%n %n %n %n %n %n %n %n %n %n %n %n %n','delimiter',',','headerlines',3);
        
        % d_v is vertical distance
        d_v=sqrt((x_up-x_lo).^2+(y_up-y_lo).^2);
        % d_h is horizontal distance
        d_h=sqrt((x_r-x_l).^2+(y_r-y_l).^2);
        % mean between d_h and d_v
        d_mean=(d_h+d_v)./2;
        
        
        % use loglikelikelihood (lh_XXX) to find outlier frames
        % outliers exist in all four labels --> create lh_all and build the
        % help_var with size lh_XX x 4
        lh_all=[lh_up,lh_r,lh_lo,lh_l];
        help_var_all=[];
        for tx=1:size(lh_all,2);
            clear help_var;
            help_var=find(lh_all(:,tx)<0.95);
            help_var_all=[help_var_all;help_var];
        end;
        
        % help_var_all includes all the frames with a loglikelihood < 0.95
        help_var_all=sort(help_var_all);
        
        % outlier_frames as unique vector
        outlier_frames=unique(help_var_all);
        
        % plot:
        figure(1);
        for sx=1:length(outlier_frames);
            line([outlier_frames(sx),outlier_frames(sx)],[0,500],'color','r');
        end;
        hold on;
        plot(d_mean);
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [30 fps]';
        legend('Outlier Frames','Location','NorthEast')
        title(fname,'Interpreter','none')
        
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_uncorrected.ps']) ,'-r200','-append');
        close all;
        
        % create pupil_dia string array
        pupil_dia(vid).name = fname;
        pupil_dia(vid).length = length(d_mean);
        pupil_dia(vid).d_mean = d_mean;
        pupil_dia(vid).outliers = outlier_frames;
        pupil_dia(vid).numb_outliers = length(outlier_frames);
    end
     save pupil_dia.mat pupil_dia
end


load([savedir filesep 'pupil_dia.mat']);

%%
% STEP 2: Cut end of too long videos
if 1==0
    for vid = 1:numel(Videolist_csv);
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
        % threshold for numb of outliers to
        
        if pupil_dia(vid).numb_outliers > 10000
            [pupil_dia(vid).ipoints, residual] = findchangepts(pupil_dia(vid).d_mean,'MaxNumChanges',1,'Statistic','mean');
            pupil_dia_cut(vid)=pupil_dia(vid);
            pupil_dia_cut(vid)=pupil_dia(vid);
            pupil_dia_cut(vid).d_mean=pupil_dia(vid).d_mean(1:pupil_dia(vid).ipoints);
            pupil_dia_cut(vid).length=length(pupil_dia_cut(vid).d_mean);
            pupil_dia_cut(vid).outliers=pupil_dia(vid).outliers(pupil_dia(vid).outliers<pupil_dia(vid).ipoints);
            pupil_dia_cut(vid).numb_outliers=length(pupil_dia_cut(vid).outliers);
        else
            pupil_dia(vid).ipoints=[];
            pupil_dia_cut(vid)=pupil_dia(vid);
        end;
        
        figure(1);
        if ~isempty(pupil_dia(vid).ipoints)
            line([pupil_dia(vid).ipoints, pupil_dia(vid).ipoints],[0,500],'color','g','LineWidth',1);
        end
        hold on;
        plot(pupil_dia(vid).d_mean);
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [30 fps]';
        legend('Changepoint','Location','NorthEast')
        title(fname,'Interpreter','none')
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_changepoint_analysis.ps']) ,'-r200','-append');
        close all
    end
    save pupil_dia_cut.mat pupil_dia_cut
    save pupil_dia.mat pupil_dia
end

load([savedir filesep 'pupil_dia.mat']);
load([savedir filesep 'pupil_dia_cut.mat']);

%%
% STEP 3: Scrubbing of pupil data
if 1==0
    pupil_dia_cut_corr=pupil_dia_cut;

    for vid = 1:numel(Videolist_csv);
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
        
        % threshold for numb of outliers to
        clear X T S
        X=pupil_dia_cut(vid).d_mean;
        if isempty(pupil_dia_cut(vid).ipoints);
            T=zeros(length(pupil_dia_cut(vid).d_mean),1);
        elseif ~isempty(pupil_dia_cut(vid).ipoints);
            T=zeros(pupil_dia_cut(vid).ipoints,1);
        end
        T(pupil_dia_cut(vid).outliers)=1;
        
        % manual correction of unregcognized outlier in #7
%         if vid==7;
%             T(17355)=1;
%         elseif vid==30;
%             T(32920:32950)=0;
%         end
        
        % scrubbing
        [S, T] = SNiP_scrubbing(X, T, 'spline');
        pupil_dia_cut_corr(vid).d_mean=S;
                
        % highpass filter
        h = fdesign.highpass('N,F3dB',2,0.005);
        d1 = design(h,'butter');
        pupil_dia_cut_corr(vid).d_mean_hp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_cut_corr(vid).d_mean); % high pass filter ...
        
        % bandpass filter
        h = fdesign.bandpass('N,F3dB1,F3dB2',2,0.005,0.15);
        d1 = design(h,'butter');
        pupil_dia_cut_corr(vid).d_mean_bp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_cut_corr(vid).d_mean); % band pass filter ...
                         
        % lowpass filter
        N = 2;
        F3dB = 0.15; % [pi*rad/sample] (pi*rad==1/2cycle => Frequency/[sample_rate/2] == F3dB)
        LP_params = ['fdesign.lowpass(N,F3dB,' N ',' F3dB ') d1 = design(h,butter)'];  
        
        h = fdesign.lowpass('N,F3dB',N,F3dB);%N = 12 before
        d1 = design(h,'butter');
        pupil_dia_cut_corr(vid).d_mean_lp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_cut_corr(vid).d_mean); % low pass filter ...

        LP_params = ['fdesign.lowpass(N,F3dB,' num2str(N) ',' num2str(F3dB) ') d1 = design(h,butter)']; 

        % plot
        figure(1);
        subplot(2,1,1);
        plot(pupil_dia(vid).d_mean);
        hold on;
        plot(pupil_dia_cut_corr(vid).d_mean);
        
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [20 fps]';
        legend('to scrub','Location','NorthEast')
        title(fname,'Interpreter','none')
                
        subplot(2,1,2);
        plot(pupil_dia_cut_corr(vid).d_mean);
        hold on;
        plot(pupil_dia_cut_corr(vid).d_mean_lp,'r');
        
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [20 fps]';
        legend('LowPassfiltered','Location','NorthEast')
        title(fname,'Interpreter','none')
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_scrubbing_and_lowpassfiltering.ps']) ,'-r200','-append');
        close all
    end
    save pupil_dia_cut_corr.mat pupil_dia_cut_corr
end
%%
% STEP 4: Aligning of videos and intans
FrameRate_defined=10; % CAVE: Important --> WMV uses 20 fps, but claims 30 Frames per second in its header --> conversion to avi shortens the videos...


load([savedir filesep 'pupil_dia_cut_corr.mat']);

%% Debugging:
% median method helps for: # 4,15,29,35,43,46,49,66 --> mostly due to too
% long videos
% still problematic: # 14,23,51,18 --> infrared issue --> temporarily
% excluded
        N = 2;
        F3dB = 0.15;
        LP_params = ['fdesign.lowpass(N,F3dB,' num2str(N) ',' num2str(F3dB) ') d1 = design(h,butter)']; 
%%
if 1==1
    for vid = 1:numel(Videolist_csv);
        [Vdir,Vidname,~]=fileparts(Videolist_csv{vid});
        %% get general info about current video ...
        find_ = strfind(Vidname,'_');             %%%%%% Jonathan
        Vidname_short = Vidname(1:find_(2)-1);
        Vidname_short1 = [Vidname(1:find_(1)) Vidname((find_(1)+3):(find_(2)-1))] ;
        subjcur = Vidname(1:find_(1)-1);
        date = Vidname_short(find_(1)+1:end);
        VideoPathFull =  getAllFiles([videodir filesep subjcur],'*.wmv',1);%[videodir filesep Vidname_short '.wmv'];
%         VideoPathFull =  getAllFiles(videodir,[Vidname_short '*.wmv'],1);%[videodir filesep Vidname_short '.wmv'];

%         
% %    [Vdir,Vidname,~] = fileparts(Videolist{vid});     %%%%%%% Laurens
% %     VideoPathFull = Videolist{vid};
% %     find_ = strfind(Vidname,'_'); 
% %     Vidname_short = Vidname(1:end-14);
% %     subjcur = Vidname(1:find_(1)-1);
% %     date = Vidname(find_(1)+1:end); 
% %     
% %     savedir = Vdir; 
% %  
       
        
        %% select corresponding digital.mat to extract triggers for start/end of the video ...
        DigMat_cur = getAllFiles(DigDir, [Vidname_short1 '*_digital.mat'],1);
%         if isempty(DigMat_cur);
%             DigMat_cur = {spm_select('FPList',DigDir,[Vidname_short(1:find_(1)-1) '\+.*.' Vidname_short(find_(1):find_(2)-1) '_digital.mat'])};
%         end;
%         DigMat_all(vid)=DigMat_cur
%         Vidname_short = Vidname(1:find_(2)-1);
        % check
        if numel(DigMat_cur) ~= 1
            error('Too many or no digital mats found. CHECK DATA!')
        end

        %% extract triggers from INTAN DATA (infrared light) -> start/end of video ...
        % channel 3 in dchannels ...
        % start = first TTL, infrared turned off
        % end   = last TTL, infrared turned on ...
        
        % problem 1: when turning on TTL, the digital signal is not perfectly stable.
        % The signal is flickering (+++ when turning on).
        % Question: how to find right right TrigOFF for starting
        % problem 2: it is possible to habe artefacts throughout the session ->
        % makes finding the end more difficult
        
        plotButton = 0; % 1 = get plots for control, 0 = no plots ...
        [INTAN_Info] = Extract_IntanTriggersPupil_LW(DigMat_cur, plotButton);
        
        %% cut current video for alignment to INTAN DATA
        % our videos contain two triggers in form of an overexposure by an infrared
        % lamp - one in the beginning before starting our paradigm, one after the paradigm is finished
        % for defining an end point. The cropped video can be aligned to INTAN!
        
        % Approach: get mean intensity values for the red spectrum for each frame
        % in the first and in the last 60 seconds of the video. Both infrared lamp
        % triggers (start/end) are definetly captured by these time windows.
        % start/end of our VOI (video of interest) are detected by using the
        % derivative of this mean intensity signal...
        
        % visual control frame by frame integrated ...
        control_button = 0; % for visual control frame-by-frame ... 1 = on, 0 = off ...

    [VOI_Info] = Find_StartEndFrame_JR(VideoPathFull,FrameRate_defined, control_button, pupil_dia(vid).ipoints);

        %% Alignment INTAN - VIDEO ...
        pretrig = 4; 
        %1. Check if Length of cropped Intan and cropped Video are identical
        %(tolerance range needs to be discussed)!
        Diff_Length = abs(VOI_Info.LengthVidCropped - INTAN_Info.LengthIntan);
        tol_range = 0.35;
        if Diff_Length > tol_range
            error('MISMATCH length Intan - length Video! CHECK DATA!')
        end
               
        %2. Align all events (fv_onsets, licks) to INTAN_Info.start_vid ...
        % transform sample number into seconds ...
        load(DigMat_cur{1},'sample_rate'); % get sample rate ...
        Time2Delete = (INTAN_Info.start_vid / sample_rate)-pretrig;% for sessions with short distance infrared-trigger - first fv_on
        
        % load corresponding NewMat + get events ...
        NewMat_cur = getAllFiles(NewDir, ['*' Vidname_short1 '*_protocol_new.mat'],1);
        load(NewMat_cur{1}); % -> get events trialmatrix ...
        

        
        %%
        fv_on_odorcue = [events.fv_on_odorcue];
        fv_off_odorcue = [events.fv_off_odorcue];
        fv_on_rewcue = [events.fv_on_rewcue];
        fv_off_rewcue = [events.fv_off_rewcue];
        jitter = [events.jitter_OC_RC];
%         licks = {events.licks};
        
        % finally align events to INTAN_Info.start_vid ... loop necessary for
        % licks
        for trial = 1:numel(events)
            fv_on_odorcue_align(trial) = fv_on_odorcue(trial) - Time2Delete;
            fv_off_odorcue_align(trial) = fv_off_odorcue(trial) - Time2Delete;
            fv_on_rewcue_align(trial) = fv_on_rewcue(trial) - Time2Delete;
            fv_off_rewcue_align(trial) = fv_off_rewcue(trial) - Time2Delete;            
%             licks_align{trial} = licks{trial} - Time2Delete;
        end
        
        % reward ..
        ix=1;
        for i=1:numel(events)
            if ~isempty(events(i).reward_time)
            drops(i) = events(i).reward_time;
            dist(ix)=drops(i)-fv_off_rewcue(i);
            ix = ix + 1; 
            else drops(i)=NaN; 
            end
        end
        MeanDist=mean(dist);  %%%% mean dist btw rewcue and reward (in this task stable)
        
        for i=1:length(drops)
            if isnan(drops(i))
                drops(i)=fv_off_rewcue(i)+MeanDist;   %%%% fake drops for non rewarded trials
            end
        end
        
        for trial = 1:length(drops)
            
            drops_align(trial) = drops(trial) - Time2Delete;
            
            
        end
        
        %3. get diameter values of interest
        %     Path_diameter = getAllFiles(Videolist{vid}, 'rw*diameter.mat',1);
        PupilDiameter = pupil_dia_cut_corr(vid).d_mean;
        PupilDiameter_LP = pupil_dia_cut_corr(vid).d_mean_lp;
        PupilDiameter_HP = pupil_dia_cut_corr(vid).d_mean_hp;
        PupilDiameter_BP = pupil_dia_cut_corr(vid).d_mean_bp;
        
        % extract those values which are situated in "cropped" vid ...
        index_FramesOfInterest = VOI_Info.FrameBegin-(pretrig*FrameRate_defined):1:VOI_Info.FrameEnd;
        PupilDiameter = PupilDiameter(index_FramesOfInterest);
        PupilDiameter_LP = PupilDiameter_LP(index_FramesOfInterest);
        PupilDiameter_HP = PupilDiameter_HP(index_FramesOfInterest);
        PupilDiameter_BP = PupilDiameter_BP(index_FramesOfInterest);
        
        
        %4. visual control to see whether diameters and fvonsets, licks are well
        % aligned to each other ...
%         plot_VisualControl_Alignment_ParadigmPupil_JR(events,VOI_Info,PupilDiameter,PupilDiameter_LP,licks_align,fv_on_align, drops_align,savedir,Vidname_short)
        
        
        %5. assign fv_onsets to video frames (= OdorFrames)...
        % -> find vieo frame which is nearest to current fv_onset
        FrameDur = 1/FrameRate_defined;
        for trial = 1:numel(events)
            % get current onset and offset...
            fv_on_odorcue_align_cur = fv_on_odorcue_align(trial);
            fv_off_odorcue_align_cur = fv_off_odorcue_align(trial);
            fv_on_rewcue_align_cur = fv_on_rewcue_align(trial);
            fv_off_rewcue_align_cur = fv_off_rewcue_align(trial);
            drops_align_cur = drops_align(trial);
            
            % find correspondent frame in vid ...
            OdorcueOnFrames(trial).Time = round(fv_on_odorcue_align_cur/FrameDur)*FrameDur;
            OdorcueOnFrames(trial).Loc_Frames = OdorcueOnFrames(trial).Time/FrameDur;
            OdorcueOffFrames(trial).Time = round(fv_off_odorcue_align_cur/FrameDur)*FrameDur;
            OdorcueOffFrames(trial).Loc_Frames = OdorcueOffFrames(trial).Time/FrameDur;
            RewcueOnFrames(trial).Time = round(fv_on_rewcue_align_cur/FrameDur)*FrameDur;
            RewcueOnFrames(trial).Loc_Frames = RewcueOnFrames(trial).Time/FrameDur;
            RewcueOffFrames(trial).Time = round(fv_off_rewcue_align_cur/FrameDur)*FrameDur;
            RewcueOffFrames(trial).Loc_Frames = RewcueOffFrames(trial).Time/FrameDur;
            DropsFrames(trial).Time = round(drops_align_cur/FrameDur)*FrameDur;
            DropsFrames(trial).Loc_Frames = DropsFrames(trial).Time/FrameDur;
        end
        
        
        %% Pupil analysis individual animal
        if 1==0;
            
            do_PupilAnalysis_jr(PupilDiameter, PupilDiameter_LP, OdorFrames, events, FrameRate_defined, Vidname_short, savedir);
            
        end

        
        %% Create TrialDiameterMatrix ...
        % TrialDiameterMatrix is a matrix containing all diameter data aligned to
        % fv_onsets / for all trials / different event types parsed later ...
        % rows = trials ...
        % columns = frames ...
        % values = corresponding diameters ...
        
        % define window of interest for pupil analysis
        pre = 1; % in s; number of seconds plotted before odor stim
        post = 2; % in s; number of seconds plotted after odor stim
        window_index = [-pre:(1/FrameRate_defined):post-(1/FrameRate_defined)];
        
        %saving diametervalues for whole trial
        pret = 4; % in s; number of seconds plotted before odor stim
        postt = 12; % in s; number of seconds plotted after odor stim
        window_indext = [-pret:(1/FrameRate_defined):postt-1/FrameRate_defined];
        
        % create matrix ...
        for trial = 1:numel(events)
            
            % get FrameOfInterest which is exactly "pre" seconds before odor stim
            OdorcueOnFrameCur = OdorcueOnFrames(trial).Loc_Frames;
            FramePreOdorcue = OdorcueOnFrameCur - (pre*FrameRate_defined);
            RewcueOnFrameCur = RewcueOnFrames(trial).Loc_Frames;
            FramePreRewcue = RewcueOnFrameCur - (pre*FrameRate_defined);
            DropsFrameCur = DropsFrames(trial).Loc_Frames;
            FramePreDrops = DropsFrameCur - (pre*FrameRate_defined);            
            
            TrialFrameCur = OdorcueOnFrames(trial).Loc_Frames;
            FramePreTrial = TrialFrameCur - (pret*FrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFramesOC = [FramePreOdorcue:1:(FramePreOdorcue+numel(window_index)-1)];
            index_locFramesRC = [FramePreRewcue:1:(FramePreRewcue+numel(window_index)-1)];
            index_locFramesD = [FramePreDrops:1:(FramePreDrops+numel(window_index)-1)];
            
            index_locFramesT = [FramePreTrial :1:(FramePreTrial +numel(window_indext)-1)];
            
            
            % write rows in matrix ...
            % PupilDiameter_LP = lowpass filtered data ...
            % alternative: DiameterMatrix(trial,[1:numel(window_index)]) = PupilDiameter_LP(index_locFrames);
            % i would have preferred this single line, but there is a problem
            % in the data format -> quick solution: round incides ...
%             for i = 1:numel(window_index)
%                 DiameterMatrixOC(trial,i) = PupilDiameter_LP(round(index_locFramesOC(i)));
%                 DiameterMatrixRC(trial,i) = PupilDiameter_LP(round(index_locFramesRC(i)));
%                 DiameterMatrixD(trial,i) = PupilDiameter_LP(round(index_locFramesD(i)));
%             end
                for i = 1:numel(window_indext)
                DiameterMatrixT(trial,i) = PupilDiameter(round(index_locFramesT(i)));
                DiameterMatrixT_LP(trial,i) = PupilDiameter_LP(round(index_locFramesT(i)));
            end
        end
        
        %% 2. Percentage Change throughout trial (values from csv file, no normalization)
        % idea: perform normalization to trial-by-trial baseline (prestim_window) ...
        
        % define window for baseline calculation ...
        baseshift = 1; % in s; baseline is calculated with frame all frames situated in window -baseshift : 0dorOnset (=0); til 2004 4.5
        basewindow = 1;               % 20200414MA
        % calculate baseline -> mean of all bins in baseline_window
        % -> first trial discarded, only 1s between IR trigger and OC onset
        for trial = 1:numel(events)
            
            % get FrameOfInterest which is exactly "baseline" seconds before odor stim
            OdorcueOnFrameCur = OdorcueOnFrames(trial).Loc_Frames;
            FrameBaseStart = OdorcueOnFrameCur - (baseshift*FrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFrames_baseline = [FrameBaseStart:1:(FrameBaseStart+((basewindow)*FrameRate_defined)-1)];
            

            % calculate baseline for current trial ...
            % loop to avoid strange format problem ...
            for i = 1:numel(index_locFrames_baseline)
                BaselineValues(i) = PupilDiameter(round(index_locFrames_baseline(i)));
                BaselineValues_LP(i) = PupilDiameter_LP(round(index_locFrames_baseline(i)));
            end
            
            BaseValMatrix(trial,:) = BaselineValues;
            BaselineDiameter(trial) = mean(BaselineValues);
            BaseValMatrix_LP(trial,:) = BaselineValues_LP;
            BaselineDiameter_LP(trial) = mean(BaselineValues_LP);
%             BaselineDiameterSTD(trial) = std(BaselineValues);
            
            % % % % %
            % matrix containg baseline-normalized pupil diameter values ...
%             BaseDiameterMatrixOC(trial,:) = (DiameterMatrixOC(trial,:))./BaselineDiameter(trial);
%             BaseDiameterMatrixRC(trial,:) = (DiameterMatrixRC(trial,:))./BaselineDiameter(trial);
%             BaseDiameterMatrixD(trial,:) = (DiameterMatrixD(trial,:))./BaselineDiameter(trial);
            BaseDiameterMatrixT(trial,:) = (DiameterMatrixT(trial,:))./BaselineDiameter(trial);
            BaseDiameterMatrixT_LP(trial,:) = (DiameterMatrixT_LP(trial,:))./BaselineDiameter_LP(trial);
            
        end
            % save infos
            info.name = [Vidname_short];
            info.pupil_amalysis.baseline = ['fv_odorcue_on-' num2str(baseshift) ':fv_odorcue_on-' num2str(baseshift-basewindow)];
            info.pupil_amalysis.trialFOI = ['fv_odorcue_on-' num2str(pret) ':fv_odorcue_on+' num2str(postt)];
            % ...
   %% test d-struct
            for tr=1:size(events,2)
            events(tr).fv_on_odorcue_align=fv_on_odorcue_align(tr);
            events(tr).fv_off_odorcue_align=fv_off_odorcue_align(tr);
            events(tr).fv_on_rewcue_align=fv_on_rewcue_align(tr);
            events(tr).fv_off_rewcue_align=fv_off_rewcue_align(tr);
            events(tr).drops_align=drops_align(tr);
%             events(tr).licks_align= cell2mat(licks_align(tr));
            end
     
   
            d.events{vid} = events;
%             d.licks{vid} = licks;
            d.info(vid).meta = session;
            d.info(vid).tag = info.tag;
            d.info(vid).box = info.box;
            d.info(vid).superflex_parameters = info.superflex_parameters;
            d.info(vid).animal = info.animal{1};
            d.info(vid).date_time = session.header_file(end-19:end-9);

        
            
            pupil.rawtrace = PupilDiameter;
            pupil.lptrace = PupilDiameter_LP;
            pupil.timevector = ['tobeimplemented']; ... % in seconds ############? how to implement ? #############
            pupil.info.samplerate = FrameRate_defined;
            pupil.info.intanalign = Time2Delete;
            pupil.info.LP_params = LP_params;

            pupil.trialparts.baseline_raw = BaseValMatrix ;
            pupil.trialparts.baseline_lp = BaseValMatrix_LP;
            pupil.trialparts.trialtrace_raw = DiameterMatrixT;
            pupil.trialparts.trialtrace_lp = DiameterMatrixT_LP;
            pupil.trialparts.trialtrace_raw_base = BaseDiameterMatrixT;
            pupil.trialparts.trialtrace_lp_base = BaseDiameterMatrixT_LP;
            pupil.trialpartindices.info = '[pre post] fv_odorcue_on in seconds';
            pupil.trialpartindices.trialtrace = [pret postt];
            pupil.trialpartindices.baseline = [baseshift baseshift-basewindow];       

% possible way of chunk analysis indexing via fieldnames, to be continued
% another day...

% if 1==0
%             trialpart_labels = fieldnames(pupil.trialparts);
% 
%             for tx=1:length(trialparts_labels)
%             fieldname = trialparts_labels{tx};
%             pupil.means.(fieldname) = mean(pupil.trialparts.(fieldname); % and normalisation and stuff
% 
%             % plotfunction...
%             title(fieldname)
%             end
% end


            d.pupil(vid) = pupil;
        
        %% old structure in summary_all
       if 1 == 0     
        
        summary_all(vid).AllDiaRaw=PupilDiameter;
        summary_all(vid).AllDiaHP=PupilDiameter_HP;
        summary_all(vid).AllDiaBP=PupilDiameter_BP;
        summary_all(vid).BaseValMatrixHP=BaseValMatrix_HP;
        summary_all(vid).BaseValMatrixBP=BaseValMatrix_BP;
%         summary_all(vid).BaselineDiameter=BaselineDiameter;
%         summary_all(vid).BaselineDiameterSTD=BaselineDiameterSTD;
%         summary_all(vid).BaseDiameterMatrixOC=BaseDiameterMatrixOC;
%         summary_all(vid).BaseDiameterMatrixRC=BaseDiameterMatrixRC;
%         summary_all(vid).BaseDiameterMatrixD=BaseDiameterMatrixD;
        summary_all(vid).BaseDiameterMatrixT_HP=BaseDiameterMatrixT_HP;
        summary_all(vid).BaseDiameterMatrixT_BP=BaseDiameterMatrixT_BP;
%         summary_all(vid).DiameterMatrixOC=DiameterMatrixOC;
%         summary_all(vid).DiameterMatrixRC=DiameterMatrixRC;
%         summary_all(vid).DiameterMatrixD=DiameterMatrixD;
        summary_all(vid).DiameterMatrixT_HP=DiameterMatrixT_HP;
        summary_all(vid).DiameterMatrixT_BP=DiameterMatrixT_BP;
        summary_all(vid).curr_trialtype=[events.curr_trialtype]';
        summary_all(vid).curr_odorcue_num=[events.curr_odorcue_odor_num]';
        summary_all(vid).curr_rewcue_num=[events.curr_rewardcue_odor_num]';
        summary_all(vid).drop_or_not=[events.drop_or_not]';
        
        
        
        summary_all(vid).fv_on_odorcue_align=[fv_on_odorcue_align]';
        summary_all(vid).fv_off_odorcue_align=[fv_off_odorcue_align]';
        summary_all(vid).fv_on_rewcue_align=[fv_on_rewcue_align]';
        summary_all(vid).fv_off_rewcue_align=[fv_off_rewcue_align]';
        summary_all(vid).drops_align=[drops_align]';  %%% drops contains also fake reward times
%         summary_all(vid).licks_align=[licks_align]';
        summary_all(vid).jitter=jitter;
        summary_all(vid).info=info;
       end
    end
    save d.mat d;
    if 1 == 0
        save summary_all.mat summary_all
    end
end
      
















