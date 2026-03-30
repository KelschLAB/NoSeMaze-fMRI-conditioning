function [INTAN_Info] = Extract_IntanTriggersPupil(DigMat_cur,parStartEnd,plotButton)

% extract triggers (infrared light) -> start/end of video ...
% channel 3 in dchannels ... 
% start = first TTL, infrared turned off 
% end   = last TTL, infrared turned on ... 

% problem 1: when turning on TTL, the digital signal is not perfectly stable.
% The signal is flickering (+++ when turning on). 
% Question: how to find right right TrigOFF for starting 
% problem 2: it is possible to habe artefacts throughout the session ->
% makes finding the end more difficult 




load(DigMat_cur{1}); 
TriggerTrace = dchannels(:,4); 
% TriggerTrace = -1*TriggerTrace; 
%find TrigON/TrigOFF
DiffTriggerTrace = diff(TriggerTrace); 
TrigON = find(DiffTriggerTrace == 1); 
TrigOFF  = find(DiffTriggerTrace == -1); 

%% find start_vid ... 
% idea: first TrigOFF without any signal in the following 30 s ... 
interval_dur = sample_rate*60; % 60s ... 
% array including all onsets/offsets 
events_pooled = sort([TrigON; TrigOFF]);
diff_events_pooled = diff(events_pooled); 

% find start ... 
if numel(TrigOFF)>1%(diff_events_pooled)>1
%     index = find(diff_events_pooled > interval_dur);
    diffReal = abs(TrigOFF-parStartEnd(1)*sample_rate);
    index = find(diffReal == min(diffReal));
elseif numel(TrigOFF)==1%(diff_events_pooled)==1 % at the start of the recordings there was only one IR trigger to mark the beginning of the experiment     
    index = 1;%2;
end

% select first match ... further matches are highly suspicious +++ artefact
start_vid = TrigOFF(index);% events_pooled(index(1)); 
if start_vid > parStartEnd(1)*sample_rate% find(diff(dchannels),1)
    warning('video start/IR trigger after start of the first trial!')
    keyboard
end
% control whether start is an offset ... 
if sum(TrigOFF == start_vid) ~= 1
   error('start is not detected as an TrigOFF. CHECK!'); 
end



%% find end_vid ... 
% same approach: find LAST TrigON with no event in the last 60 s before ... 
% LAST since there can be artefacts thrpughout the session ... last event
% fitting the criterion should be less than 60s before end ... 
if numel(TrigON)>1% (diff_events_pooled)>1
% select first match ... further matches are highly suspicious +++ artefact
diffReal = abs(TrigON-parStartEnd(2)*sample_rate);
    index = find(diffReal == min(diffReal));
end_vid = TrigON(index);% events_pooled(index(1)+1); % +1 normally, +3 if additional IR trig during session
% control whether end is an onset ... 
if sum(TrigON == end_vid) ~= 1
   error('end is not detected as an TrigON. CHECK!'); 
end
else % only one IR trigger
    end_vid = [];
end



%% calculate length of recording from trigOn to trigOff ... 
LengthIntan = (end_vid - start_vid)/sample_rate; 


%% create structure INTAN_Info = output ... 

INTAN_Info.start_vid = start_vid; 
INTAN_Info.end_vid = end_vid; 
INTAN_Info.LengthIntan = LengthIntan; 










%%
if 1 == plotButton 
% plot rawtrace/derivative  for visual control ...

% raw
f1 = figure(1);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

p(1,1) = plot(TriggerTrace,'m');
hold on 
p(1,2) = plot(start_vid,0,'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','y');
p(1,2) = plot(end_vid,0,'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','y');
for i = 1:numel(TrigON)
p(1,3) = plot(TrigON(i),0.75,'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','g');
end
for i = 1:numel(TrigOFF)
p(1,4) = plot(TrigOFF(i),0.25,'*','MarkerSize',12,'MarkerFaceColor','r','MarkerEdgeColor','r');
end
ll = legend(p, 'RawTrace', 'Start/End', 'ON', 'OFF', 'Location','northeastoutside'); 

% derivative
f2 = figure(2);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

p(1,1) = plot(DiffTriggerTrace,'b'); 
hold on 
p(1,2) = plot(start_vid,0,'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','y');
p(1,2) = plot(end_vid,0,'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','y');
for i = 1:numel(TrigON)
p(1,3) =  plot(TrigON(i),0.75,'*','MarkerSize',12,'MarkerFaceColor','g','MarkerEdgeColor','g');
end
for i = 1:numel(TrigOFF)
p(1,4) =  plot(TrigOFF(i),0.25,'*','MarkerSize',12,'MarkerFaceColor','r','MarkerEdgeColor','r');
end
ll = legend(p, 'RawTraceDerivative', 'Start/End', 'ON', 'OFF', 'Location','northeastoutside'); 
end 





end % function 