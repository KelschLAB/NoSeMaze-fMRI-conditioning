function [VOI_Info] = Find_StartEndFrame(VideoPathFull,FrameRate_defined,control_button_vid,changepoint)
% --> originally Find_StartEndFrame_JR.mat
control_button = 0; % -> plots do not show correctly with MS plot defaults, find start end frame is as informative 
% FEBRUARY 2019
% "Find_StartEndFrame_LW" determines the first and the last frame of our VOI (video of interest) which can
% be aligned with our INTAN DATA.

% cut current video for alignment to INTAN DATA
% our videos contain two triggers in form of an overexposure by an infrared
% lamp - one in the beginning before starting our paradigm, one after the paradigm is finished
% for defining an end point. The cropped video can be aligned to INTAN!

% Approach: get mean intensity values for the red spectrum for each frame
% in the first and in the last 60 seconds of the video. Both infrared lamp
% triggers (start/end) are definetly captured by these time windows.
% start/end of our VOI (video of interest) are detected by using the
% derivative of this mean intensity signal...


% see attachted to this script ...
% visual control frame by frame !!!

% 02/2020 MA: change trigger detection -> find first trigger in the first
% 1min of video, look for second trigger x min later while x = duration of
% paradigm

%% PREP

% construct a multimedia reader object, that can read in video data from a
% multimedia file.
v=VideoReader(char(VideoPathFull));
para_dur=120*14;
% if contains(VideoPathFull,'03TD19_EPhys')
%     para_dur = 14*60; %150trials TD19
% elseif contains(VideoPathFull,'06TD19_EPhys')
%     para_dur = 28*60; %150trials TD19
% elseif contains(VideoPathFull,'TD19_EPhys')
%     para_dur = 42*60; %150trials TD19
% else
%     warning(['Paradigm not yet implemented. Folder name: ' VideoPathFull])
%     keyboard
% end
% data format  mismatch: ask Mathias;
% PROBLEM: videos are recorded in wmv.format. Both the information in
% windows and the multimedia reader object (v in our case) indicate that
% thre frame rate is 30/s. However, after processing, there are only 20
% frames per second. DOWNSAMPLING? WHAT ABOUT QUALITY?
% first version: define new framerate, but this potential problem has to be followed up ...

% FrameRate_defined = 20;



%% START DETECTION

%% read first minute of current video ...
% prep
framecounter=1; % for creating "bright1" variable ...
dur = 100; % in s; v.CurrentTime is in s ...
% dur = 40; %before, changed to 100 to capture late LED-Triggers
if control_button==1;
    f3=figure(3);
    suptitle('PLOT - FIND FIRST TRIGGER OFFSET');
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
end;
while v.CurrentTime < dur % read first minute
    % read predefined frames
    video = readFrame(v);
    
    % bright1 = variable containing mean intesity values frame by frame ...
    bright1(framecounter) = mean(mean(video(:,:,1)));
    
    % plot the intensity values for visual control ...
    if control_button
        plot(gca, bright1);
    end
    
    % modify counter ...
    framecounter=framecounter+1;
end

% find frame in which first infrared light trigger is turned off ...
diff_bright1 = diff(bright1);
% pk = Yvalues of all peaks found; lc = indices  at which the peaks occur
[Yvalues_pks,Xvalues_pks] =findpeaks(diff_bright1*(-1),'MinPeakDistance',10); % multiplied by (-1) to invert signal for peak detection ...

% find highest peak = frame in which light is turned off = start! last value after sorting ...
[~,Index] = sort(Yvalues_pks);
tmp=Xvalues_pks(Index); % get location of peaks (sorted) ...

FrameBegin = tmp(end); % location of last peak which corresponds to the location of the highest peak after sorting ...
% visual control
% hold on
% plot(gca,FrameBegin,bright1(FrameBegin),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');


%% read current video after para_dur...
% prep
framecounter=1; % for creating "bright2" variable ...
dur = 200; % in s; v.CurrentTime is in s ...
if control_button==1;
    f4=figure(4);
    suptitle('PLOT - FIND SECOND TRIGGER ONSET');
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
end
% set v.CurrentTime to end of video ...
if isempty(changepoint)
    v.CurrentTime= para_dur + (FrameBegin/10) - (dur/2);%v.Duration-dur;
elseif ~isempty(changepoint);
    v.CurrentTime=(changepoint/FrameRate_defined)-dur;
end

while hasFrame(v) && framecounter < FrameRate_defined*dur % added by JR to not run the vid till the end
    % read predefined frames
    video = readFrame(v);
    
    % bright2 = variable containing mean intesity values frame by frame ...
    bright2(framecounter) = mean(mean(video(:,:,1)));
    
    % plot the intensity values for visual control ...
    if control_button
        plot(gca, bright2);
    end
    
    % modify counter ...
    framecounter=framecounter+1;
end

% DOES THIS MAKE SENSE? make negativ values artificially to median
bright2(find(bright2<median(bright2)))=median(bright2);


% find frame in which first infrared light trigger is turned off ...
diff_bright2 = diff(bright2);
% pk = Yvalues of all peaks found; lc = indices  at which the peaks occur
[Yvalues_pks,Xvalues_pks] =findpeaks(diff_bright2,'MinPeakDistance',10);

% find highest peak = frame in which light is turned off = start! last value after sorting ...
[~,Index] = sort(Yvalues_pks);
tmp=Xvalues_pks(Index); % get location of peaks (sorted) ...

FrameEnd_prelim = tmp(end); % prelim -> for cropped window so far, value needs to be adapted for whole session
if isempty(changepoint);
%     FrameEnd = round(v.Duration*FrameRate_defined -
%     (length(bright2)-FrameEnd_prelim)); % round = problem mismtach framerate / v.duration 

    % LW + MA Feb 2020: 
    FrameEnd = round(v.CurrentTime*FrameRate_defined - (length(bright2)-FrameEnd_prelim)); % round = problem mismtach framerate / v.duration
    
elseif ~isempty(changepoint);
    FrameEnd = round((changepoint/FrameRate_defined)*FrameRate_defined - (length(bright2)-FrameEnd_prelim)); % round = problem mismtach framerate / v.duration
end
% v.Duration (=length of video in s);
% length(bright2) (=frames in cropped window);

% visual control
% figure(10)
% hold on
% plot(gca,FrameEnd_prelim,bright2(FrameEnd_prelim),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
   
figure(30); 
subplot(2,2,1); plot(bright1); hold on; plot(diff_bright1);hold on;plot(gca,FrameBegin,bright1(FrameBegin),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
subplot(2,2,2); plot(bright2); hold on; plot(diff_bright2);hold on;plot(gca,FrameEnd_prelim,bright2(FrameEnd_prelim),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
% input('weiter');
close all;
%% assign time in s to FrameBegin/FrameEnd ...
% REVIEW needed ... round, framerate, ...

% get duration of entire video ... round -> mismatch framerate /v.Duration
% hier wird auf 0.05 gerundet wegen der framerate ...
if isempty(changepoint);
    LengthVidAll = round(v.Duration/(1/FrameRate_defined))/FrameRate_defined;
elseif ~isempty(changepoint);
    LengthVidAll = round((changepoint/FrameRate_defined)/(1/FrameRate_defined))/FrameRate_defined;
end


LengthVidCropped = (FrameEnd-FrameBegin)*(1/FrameRate_defined);
% LengthVid or v.Duration? what is more precise?

TimeFrameIndexALL = [0:1/FrameRate_defined:LengthVidAll];
TimeFrameIndexCropped = [0:1/FrameRate_defined:LengthVidCropped];
TimeBegin = TimeFrameIndexALL(FrameBegin);
TimeEnd = TimeFrameIndexALL(FrameEnd); % problem = data format ...
%TimeEnd = v.Duration -(length(bright2)-FrameEnd_prelim)/FrameRate_defined;

%
fprintf("Time Begin: %0.3f; Time End: %0.3f\n", TimeBegin, TimeEnd)


%% create structure VOI_Info = output ...

VOI_Info.TimeBeginInVid = TimeBegin;
VOI_Info.TimeEndInVid = TimeEnd;
VOI_Info.FrameBegin = FrameBegin;
VOI_Info.FrameEnd = FrameEnd;
VOI_Info.TimeFrameIndexCropped = TimeFrameIndexCropped;
VOI_Info.LengthVidCropped = LengthVidCropped;



%% VISUAL CONTROL FRAME BY FRAME

if control_button_vid
    
    % START - first trigger ...
    % click  ok button to start visual control starting point  ...
    uiwait(msgbox('Click OK to check starting point'));
    
    pre = 0.2; % in s; pre defines the amount of seconds you want to shift back from TimeBegin ...
    v.CurrentTime = TimeBegin - pre;
    NumFrames2check = pre*FrameRate_defined+5;
    
    % to display current frame in title ...
    FrameCounterStart = FrameBegin - (pre*FrameRate_defined);
    
    f5 = figure(5);
    for i=1:NumFrames2check
        imagesc(readFrame(v));
        tt = title(['CALCULATED FRAME = ' num2str(FrameBegin) '; CURRENT FRAME = ' num2str(FrameCounterStart)]);
        
        if FrameCounterStart == FrameBegin || FrameCounterStart == FrameBegin -1 || FrameCounterStart == FrameBegin +1
            pause(1.5);
        else
            pause(0.5);
        end
        
        FrameCounterStart = FrameCounterStart +1;
    end
    close(figure(5));
    
    
    
    % end - second trigger ...
    % click  ok button to start visual control starting point  ...
    uiwait(msgbox('Click OK to check ending point'));
    
    pre = 0.5; % in s; pre defines the amount of seconds you want to shift back from TimeBegin ...
    v.CurrentTime = TimeEnd - pre;
    NumFrames2check = pre*FrameRate_defined+5;
    
    % to display current frame in title ...
    FrameCounterStart = FrameEnd - (pre*FrameRate_defined);
    
    f5 = figure(5);
    for i=1:NumFrames2check
        imagesc(readFrame(v));
        tt = title(['CALCULATED FRAME = ' num2str(FrameEnd) '; CURRENT FRAME = ' num2str(FrameCounterStart)]);
        
        if FrameCounterStart == FrameEnd || FrameCounterStart == FrameEnd -1 || FrameCounterStart == FrameEnd +1
            pause(1.5);
        else
            pause(0.5);
        end
        
        FrameCounterStart = FrameCounterStart +1;
    end
    close(figure(5));
    
end



end