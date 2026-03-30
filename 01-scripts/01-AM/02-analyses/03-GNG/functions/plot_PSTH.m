function f = plot_PSTH(spxtimes,trialtimes,case_num,varargin)
%%
%
%
%% Set defaults
pre     = 1000;
post    = 4000;
binsize = 100;
smoothing = 1;

%% Inputs
if nargin
    for i=1:2:size(varargin,2)
        switch varargin{i}
            case 'pre'
                pre = varargin{i+1};
            case 'post'
                post = varargin{i+1};
            case 'binsize'
                binsize = varargin{i+1};
            case 'smoothing'
                smoothing = varargin{i+1};
        end
    end
end

%%% unique case list numbers of odors used
odor_num = unique(case_num); 


%% PSTH and Raster

f = figure;
set(gcf, 'Position', get(0, 'Screensize'));

%Loop through cases
for oc = 1:numel(odor_num)
        
    curr_trialtimes = trialtimes(case_num == odor_num(oc));
    x=numel(odor_num);
    %         y=ceil(numel(odor_num)/2);
    p(1)=2;
    p(2)=x;      
    [~, ~, plotaxes(oc)]=mpsth_pj_x(spxtimes,curr_trialtimes,'pre', pre, 'post',post , 'binsz',...
        binsize, 'tb', 1, 'chart', 2,'fr',1, 'smoothing', smoothing,...
        'subplots',[p(1), p(2),oc+x; p(1), p(2),oc]);%'subplots', [4,3,4 ; 4,3,1]

    %Raster Plot
    hold on
    subplot(p(1),p(2),oc);
end
    
    ylima=get([plotaxes],'YLim');
    if x>1
        ylim([plotaxes(1)],[0 max(cellfun(@(x)max(x(:)),ylima))+5]);
        linkaxes([plotaxes(:)],'y');
    end
 
  
end


function [psth, trialspx, plotaxes] = mpsth_pj_x(spxtimes,trigtimes,varargin)
% [psth trialspx] = mpsth(spxtimes,trigtimes,varargin)
% function generates a peri-stimulus time histogram (psth) with time base in column 1 and histogram in column 2
% in addition, function returns spike timestamps relative to trigger times
% IMPORTANT: all timestamp inputs (spxtimes, trigtimes) must be seconds and will be converted to ms in the script!
%
% MANDATORY INPUTS
% spxtimes      vector with timestamps (seconds) of spike events
% trigtimes     vector with timestamps (seconds) of trigger events
%
% OPTIONAL INPUTS
% pre           time before trigger to include in psth (default 1000 ms)
% post          time after trigger to include in psth (default 1000 ms)
% fr            if '1', normalizes to firing rate (Hz); if '0', does nothing (default)
% tb            if '1', function returns timebase in the first column (default); if '0', no time base - output is a single column
% binsz         bin size of psth (default: 1 ms)
% chart         if '0' (default), no plot will be generated
%               if '1', a PSTH will be generated
%               if '2', a PSTH together with a raster plot will be generated
%
% EXAMPLES
% psth = mpsth(chan9.timings(chan9.markers(:,1)==1),chan32.timings(chan32.markers(:,1)==105))
%               generates a psth (time base in first column, psth in second column) from marker 1 in channel 9 for event 105
%
% [psth trialspx] = mpsth(chan9.timings(chan9.markers(:,1)==1),chan32.timings(chan32.markers(:,1)==105),'pre',3000,'post',3000,'fr',1);
%               same, but PSTH extends from -3 to +3 s around event (rather than -1 to +1 s, which is the default)
%               scales to firing rate ('fr' set to 1)
%
% HISTORY
% sep 12, 2013   minor bug detected; in preallocation, it previously read "psth = zeros(pre/binsz+post/binsz,2)", which
%                could result in mismatches of matrix size
% july 30, 2013  minor changes to comments above
% feb 23, 2012   changed conversion of spike counts into firing rate -> bug eliminated
% august 12      changed argument name 'ntb' to 'tb' for consistency
% april 18       debugged bin size argument, added optional raster display
% april 16       added bin size as argument
% feb 16, 2011   added examples
%
% by Maik C. Stüttgen, Feb 2011
%% define and override defaults
%lxtimes   = lxtimes*1000;
spxtimes  = spxtimes*1000;
trigtimes = trigtimes*1000;

pre   = 1000;
post  = 1000;
fr    = 0;
tb    = 1;
binsz = 1;
chart = 0;
if nargin
    for i=1:2:size(varargin,2)
        switch varargin{i}
            case 'pre'
                pre = varargin{i+1};
            case 'post'
                post = varargin{i+1};
            case 'fr'
                fr = varargin{i+1};
            case 'tb'
                tb = varargin{i+1};
            case 'binsz'
                binsz = varargin{i+1};
            case 'chart'
                chart = varargin{i+1};
            case 'smoothing'
                smoothing = varargin{i+1};
            case 'subplots'
                
                m(1)=varargin{i+1}(1,1);
                m(2)=varargin{i+1}(2,1);
                
                n(1)=varargin{i+1}(1,2);
                n(2)=varargin{i+1}(2,2);
                
                p(1)=varargin{i+1}(1,3);
                p(2)=varargin{i+1}(2,3);
                
                
            otherwise
                errordlg('unknown argument')
        end
    end
else
end
%% pre-allocate for speed
if binsz>1
    psth = zeros(ceil(pre/binsz+post/binsz),2);         % one extra chan for timebase
    psth (:,1) = (-1*pre:binsz:post-1);           % time base
elseif binsz==1
    % in this case, pre+post+1 bins are generate (ranging from pre:1:post)
    psth = zeros(pre+post+1,2);
    psth (:,1) = (-1*pre:1:post);       % time base
end
%% construct psth & trialspx & triallx
trialspx = cell(numel(trigtimes),1);
%triallx = cell(numel(trigtimes),1);
for i = 1:numel(trigtimes)
    clear licks
    clear spikes
    spikes = spxtimes - trigtimes(i);                           % all spikes relative to current trigtime
    %licks = lxtimes - trigtimes(i);
    trialspx{i} = round(spikes(spikes>=-pre & spikes<=post));   % spikes close to current trigtime
    %triallx{i} = round(licks(licks>=-pre & licks<=post));   % spikes close to current trigtime
    if binsz==1 % just to make sure...
        psth(trialspx{i}+pre+1,2) = psth(trialspx{i}+pre+1,2)+1;    % markers just add up
        % previous line works fine as long as not more than one spike occurs in the same ms bin
        % in the same trial - else it's omitted
        if smoothing
        end
    elseif binsz>1
        try
            for j = 1:numel(trialspx{i})
                psth(floor(trialspx{i}(j)/binsz+pre/binsz+1),2) = psth(floor(trialspx{i}(j)/binsz+pre/binsz+1),2)+1;
            end
        end
        
        if smoothing
            psth(:,2) = movmean(psth(:,2),smoothing);            
        end
    end
end
%% normalize to firing rate if desired
if fr==1
    psth (:,2) = (1/binsz)*1000*psth(:,2)/numel(trigtimes);
end
%% remove time base
if tb==0
    psth(:,1) = [];
end
%% plot
if chart==1
    figure('name','peri-stimulus time histogram','units','normalized','position',[0.3 0.4 0.4 0.2])
    bar(psth(:,1)+binsz,psth(:,2),'k','BarWidth',1)
    hrespb=gca;
    axes(hrespb);
    set(hrespb, 'tickdir','out');
    axis([min(psth(:,1)) max(psth(:,1)) 0 max(psth(:,2))+10])
    %xlabel('peri-stimulus time'),ylabel([Firing Rate (Hz)'])
elseif chart==2
    %     figure('name','peri-stimulus time histogram','units','normalized','position',[0.3 0.3 0.4 0.3])
    plotaxes=subplot(m(1),n(1),p(1));
    bar((psth(:,1)+binsz)./1000,psth(:,2),'k','BarWidth',1)
    box off
    hrespb=gca;
    o=gca();
    axes(hrespb);
    set(hrespb, 'tickdir','out');
    ax = gca; % current axes
    ax.XLim = [min(psth(:,1))/1000 max(psth(:,1))/1000];
    %axis([min(psth(:,1)) max(psth(:,1)) 0 max(psth(:,2))+10])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% y max! here
    %axis([min(psth(:,1))-10 max(psth(:,1))+10 0 25])
    ylabel('firing rate (Hz)', 'FontSize', 6)
    
%     set_fonts();
    
    
    subplot(m(2),n(2),p(2))
    
    [rastmat, timevec] = mraster(trialspx,pre,post);
    %[lastmat, ~]       = mraster(triallx, pre, post);
    [rrastmat, crastmat] = size(rastmat);
    %[rlastmat, clastmat] = size(lastmat);
    rasterplot_pj_ver1(find(rastmat'), rrastmat,crastmat)
    % for i = 1:numel(trialspx)
    
    %  plot([timevec; timevec] ,[rastmatNaN(i,:)*i-0.5; rastmatNaN(i,:)*i+0.5],'Color','k'),hold on
    
    %end
    %axis([-pre+10 post+10 0.5 numel(trialspx)+0.5])
    %xlabel('time (ms)'),
    ylabel('trials', 'FontSize', 6)
    box('off')
%     set_fonts();
    %xlabel('peri-stimulus time (ms)')
end

end
function [rastmat timevec] = mraster(trialspx,pre,post,varargin)
% function [rastmat timevec] = mraster(trialspx,pre,post,varargin)
% 
% function generates matrix for raster plot from cell array 'trialspx' generated by mpsth.m
% works with ms resolution
% 
% IMPORTANT: pre and post must be as large or larger than pre and post used to construct the PSTH w/ mpsth!!!
% 
% chart     if set, plots a raster
% 
% EXAMPLE
% [rastmat,timevec] = mraster(trialspx,1000,1000,'chart')       generates a raster display from -1000
%                                                               to +1000 ms and plots it
% 
% by Maik C. Stüttgen, Feb 2011
%% read varargin
chart=0;
if nargin>3
  if strcmp(varargin{1},'chart')
    chart = 1;
  end
end
%% preallocate
rastmat = zeros(numel(trialspx),pre+1+post);
timevec = -pre:1:post;  
%% generate raster
for i = 1:numel(trialspx)
  rastmat(i,trialspx{i}+pre+1) = 1;
end
%% plot raster
if chart==1
  figure('name','peri-stimulus time histogram','units','normalized','position',[0.3 0.4 0.4 0.2])
  for i = 1:numel(trialspx)
    % plot rastmat(i,rastmat(i,:)~=0) rather than rastmat(i,:) so that zero entries are not plotted, too
    plot(timevec(rastmat(i,:)~=0),rastmat(i,rastmat(i,:)~=0)*i,'k.','MarkerSize',4),hold on
  end
  axis([-pre+10 post+10 0.5 numel(trialspx)+0.5])
  xlabel('time (ms)'),ylabel('trials')
end
end

function rasterplot_pj_ver1(times,numtrials,triallen, varargin)

nin=nargin;

%%%%%%%%%%%%%% Plot variables %%%%%%%%%%%%%%
plotwidth=1;     % spike thickness
plotcolor='k';   % spike color
trialgap=1.0;    % distance between trials
defaultfs=1000;  % default sampling rate
showtimescale=0; % display timescale
showlabels=1;    % display x and y labels

%%%%%%%%% Code Begins %%%%%%%%%%%%
switch nin
    case 3 %no handle so plot in a separate figure
        
        hresp=gca;
        fs=defaultfs;
    case 4 %handle supplied
        hresp=varargin{1};
        if (~ishandle(hresp))
            error('Invalid handle');
        end
        fs=defaultfs;
    case 5 %fs supplied
        hresp=varargin{1};
        if (~ishandle(hresp))
            error('Invalid handle');
        end
        fs = varargin{2};
    otherwise
        error ('Invalid Arguments');
end



% plot spikes

trials=ceil(times/triallen);
reltimes=mod(times,triallen);
reltimes(~reltimes)=triallen;
numspikes=length(times);
xx=ones(3*numspikes,1)*nan;
yy=ones(3*numspikes,1)*nan;

yy(1:3:3*numspikes)=(trials-1)*trialgap;
yy(2:3:3*numspikes)=yy(1:3:3*numspikes)+1;

%scale the time axis to ms
xx(1:3:3*numspikes)=reltimes*1000/fs;
xx(2:3:3*numspikes)=reltimes*1000/fs;
xlim=[1,triallen*1000/fs];

axes(hresp);
plot(xx, yy, plotcolor, 'linewidth',plotwidth);
axis ([xlim,0,(numtrials)*trialgap]);





if (showlabels)
    set(hresp,'xtick',[]);
    %ylabel('Trial Nr.', 'FontSize', 8);
    %set(hresp, 'xtick', [1:numtrials],'tickdir','out');
end

end
