function align_info = VidIntanAlign(Videolist,Diglist,pupil_dia,vid_path_list,FrameRate_defined,parStartEnd,plot_button)%,align_info)

control_button = plot_button;
plot_button = 0; % -> plots do not show correctly with MS plot defaults, find start end frame is as informative 

for vid = 1:numel(Videolist)

        [Vdir,Vidname,~]=fileparts(Videolist{vid});
        
        %% get general info about current video ...
        find_ = strfind(Vidname,'_');             %%%%%% Jonathan
        Vidname_short = Vidname(1:find_(2)-1);
        Vidname_short1 = [Vidname(1:find_(1)) Vidname((find_(1)+3):(find_(2)-1))] ;
        subjcur = Vidname(1:find_(1)-1);
        date = Vidname_short(find_(1)+1:end);
        
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
        % control_button = 0; % for visual control frame-by-frame ... 1 = on, 0 = off ...
        
        [VOI_Info] = Find_StartEndFrame(Videolist{vid},FrameRate_defined, control_button, []);
        
        %% Alignment INTAN - VIDEO ...
        pretrig = 3; %4 % meant to make baseline calculation possible in first trial when delay between IR-trigger and first fv is short
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
        
        align_info(vid).intan_Time2Delete = Time2Delete;  
        align_info(vid).video_startTILend = [VOI_Info.FrameBegin-(pretrig*FrameRate_defined), VOI_Info.FrameEnd];

%         vid_info(vid).Time2Delete = Time2Delete;
%         vid_info(vid).Vidname_short = Vidname_short;
%         vid_info(vid).Vidname_short1 = Vidname_short1;
%         vid_info(vid).subjcur =subjcur;
%         vid_info(vid).date = date;
%         vid_info(vid).VideoPathFull = VideoPathFull;
%         vid_info(vid).LP_params = LP_params; 
end