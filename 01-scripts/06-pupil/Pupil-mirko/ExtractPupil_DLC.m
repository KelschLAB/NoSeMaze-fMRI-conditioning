%% This is meant to be a basic script to extract pupil diameter, perform intan alignment and buffer the resultsfor further analysis in separate scripts fitting the respective project
% Take CSVs created by DLC, calculate diameter perform filtering and scrubbing, align with Intan 
% --> derived from ExtractPupil_DLC_jr_CF_MA.mat

clear all;

%% PREP .. 

%set directories
maindir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\TD19\DATA\VidShortcut'; %'\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\Videos\20200130_TD19_EPhys'; if ~isdir(maindir), mkdir(maindir); end% all videos in maindir get processed ...
savedir = maindir; %'F:\david\pupil\oxt12_190725_155407\short\';%'E:\DATA\TD\20200130_TD19_EPhys'; if ~isdir(savedir), mkdir(savedir); end
csv_dir = maindir; %'F:\david\pupil\oxt12_190725_155407\short\';%'\\zifnas\entwbio\Carla\csv_files';
videodir= maindir;
DigDir= 'F:\Mirko\DATA\DONE'; %'E:\DATA\TD\20200130_TD19_EPhys';
NewDir= DigDir; %'E:\DATA\TD\20200130_TD19_EPhys';
addpath(cd);
% a. get all video files saved in maindir ...
Videolist_csv = getAllFiles(csv_dir,'*td*.csv',1);
cd(savedir);

%buttons
    % STEP 1: Read frames, label location and likelihood of csv-files out, plot them and create pupil_dia file
    step1 = 1; 
    % STEP 2: Cut end of too long videos
    step2 = 1;
    % STEP 3: Scrubbing of pupil data
    step3 = 1;
    % STEP 4: Aligning of videos and intans
    step4 = 1;

    %-> plotting can be deactivated within steps
    
% parameters to be set
    %scrubbing

    %filtering
        %lowpass
        N = 2;
        F3dB = 0.15; % [pi*rad/sample] (pi*rad==1/2cycle => Frequency/[sample_rate/2] == F3dB)
    % framerate
    FrameRate_defined=10; % CAVE: Important --> WMV uses 20 fps, but claims 30 Frames per second in its header --> conversion to avi shortens the videos...

%% LOOP OVER VIDEOS STARTS HERE ...

% STEP 1: Read frames, label location and likelihood of csv-files out, plot them and create pupil_dia file

if step1
    for vid = 1:numel(Videolist_csv)
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
        for tx=1:size(lh_all,2)
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
        for sx=1:length(outlier_frames)
            line([outlier_frames(sx),outlier_frames(sx)],[0,500],'color','r');
        end
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
     save pupil_dia.mat pupil_dia;
end


load([savedir filesep 'pupil_dia.mat']);

%%
% STEP 2: Cut end of too long videos

if step2
    for vid = 1:numel(Videolist_csv)
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
        % threshold for numb of outliers to
        
        if pupil_dia(vid).numb_outliers > 1000
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
        end
        
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
    save pupil_dia_cut.mat pupil_dia_cut;
    save pupil_dia.mat pupil_dia;
end

load([savedir filesep 'pupil_dia.mat']);
load([savedir filesep 'pupil_dia_cut.mat']);

%%
% STEP 3: Scrubbing of pupil data

if step3
    pupil_dia_cut_corr=pupil_dia_cut;

    for vid = 1:numel(Videolist_csv)
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
        
        % threshold for numb of outliers to
        clear X T S
        X=pupil_dia_cut(vid).d_mean;
        if isempty(pupil_dia_cut(vid).ipoints)
            T=zeros(length(pupil_dia_cut(vid).d_mean),1);
        elseif ~isempty(pupil_dia_cut(vid).ipoints)
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
                         
        % lowpass filter
        h = fdesign.lowpass('N,F3dB',N,F3dB);
        d1 = design(h,'butter');
        pupil_dia_cut_corr(vid).d_mean_lp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_cut_corr(vid).d_mean); % low pass filter ...

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
    save pupil_dia_cut_corr.mat pupil_dia_cut_corr;
end
LP_params = ['fdesign.lowpass(N,F3dB,' num2str(N) ',' num2str(F3dB) ') d1 = design(h,butter)']; 
%%
% STEP 4: Aligning of videos and intans

load([savedir filesep 'pupil_dia_cut_corr.mat']);

%%
if step4
    for vid = 1:numel(Videolist_csv)
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
        [INTAN_Info] = Extract_IntanTriggersPupil(DigMat_cur, plotButton);
        
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

    [VOI_Info] = Find_StartEndFrame(VideoPathFull,FrameRate_defined, control_button, pupil_dia(vid).ipoints);

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
        

        vid_info(vid).Time2Delete = Time2Delete;
        vid_info(vid).Vidname_short = Vidname_short;
        vid_info(vid).Vidname_short1 = Vidname_short1;
        vid_info(vid).subjcur =subjcur;
        vid_info(vid).date = date;
        vid_info(vid).VideoPathFull = VideoPathFull;
        vid_info(vid).LP_params = LP_params; 
        %% end of general script move over to project/paradigm specific analysis
        %Pupil analysis individual animal
        if 1
            
            % call function for resopective paradigm to 
            
        end

        

    end
save vid_info.mat vid_info;
end
      
















