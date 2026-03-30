function [VOI_Info] = Find_StartFrame(VideoBaseDir,VideoPathFull,FrameRate_defined,control_button_vid,print_button,ProtocolPathFull)
% Reinwald, Jonathan 07/2022

% "Find_StartFrame" determines the first frame of our VOI (video of interest) which can
% be aligned with our INTAN DATA.

% cut current video for alignment to INTAN DATA
% our videos contain two triggers in form of an overexposure by an infrared
% lamp - one in the beginning before starting our paradigm, one after the paradigm is finished
% for defining an end point. The cropped video can be aligned to INTAN!

% Approach: get mean intensity values for the red spectrum for each frame
% in the first 60 seconds of the video. Both infrared lamp
% triggers (start/end) are definetly captured by these time windows.
% start/end of our VOI (video of interest) are detected by using the
% derivative of this mean intensity signal...

%% PREP
% multimedia file.
v=VideoReader(char(VideoPathFull));

%% START DETECTION

%% read first minute of current video ...
% prep
framecounter=1; % for creating "bright1" variable ...
dur = 60; % in s; v.CurrentTime is in s ...

while v.CurrentTime < dur % read first minute
    % read predefined frames
    video = readFrame(v);
    
    % bright1 = variable containing mean intesity values frame by frame ...
    bright1(framecounter) = mean(mean(video(:,:,1)));
    
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
% plot the intensity values for visual control ...
if print_button
    fig1=figure(1);
    
    subplot(1,2,1);
    pl1=plot(bright1); hold on;
    pl2=plot(gca,FrameBegin,bright1(FrameBegin),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
    ax=gca;
    ax.XLim=[0,1000];
    ax.XTick=[0:100:1000];
    ax.XTickLabel=[0:10:100];
    ax.XLabel.String='[s]';
    tx=text(FrameBegin+10,bright1(FrameBegin)-(diff(ax.YLim)/10),['Start: ' num2str(FrameBegin/FrameRate_defined) 's']);
    tx.Color=[1,0,0];
    title('brightness')
    
    subplot(1,2,2);
    pl1=plot(diff_bright1);hold on;
    pl2=plot(gca,FrameBegin,diff_bright1(FrameBegin),'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','r');
    ax=gca;
    ax.XLim=[0,1000];
    ax.XTick=[0:100:1000];
    ax.XTickLabel=[0:10:100];
    ax.XLabel.String='[s]';
    tx=text(FrameBegin+10,bright1(FrameBegin)-(diff(ax.YLim)/10),['Start: ' num2str(FrameBegin/FrameRate_defined) 's']);
    tx.Color=[1,0,0];
    title('diff brightness');
    
    [~,title_name,~]=fileparts(ProtocolPathFull);
    sp=suptitle(title_name);
    sp.Interpreter='none';
    
    print('-dpsc',fullfile(VideoBaseDir,['Video_StartingPoint.ps']) ,'-r200','-append');
end


close all;
%% assign time in s to FrameBegin/FrameEnd ...
% REVIEW needed ... round, framerate, ...
% frame indices for the first 100 s
TimeFrameIndexALL = [0:1/FrameRate_defined:100];
TimeBegin = TimeFrameIndexALL(FrameBegin);
%
fprintf("Time Begin: %0.3f;", TimeBegin)
fprintf("Fram Begin: %0.3f;", FrameBegin)

VOI_Info.TimeBegin = TimeBegin;
VOI_Info.FrameBegin = FrameBegin;

%% VISUAL CONTROL FRAME BY FRAME

if control_button_vid
    
    % START - first trigger ...
    % click  ok button to start visual control starting point  ...
    uiwait(msgbox('Click OK to check starting point'));
    
    pre = 0.5; % in s; pre defines the amount of seconds you want to shift back from TimeBegin ...
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
end



end