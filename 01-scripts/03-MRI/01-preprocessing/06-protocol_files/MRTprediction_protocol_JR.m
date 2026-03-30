

function  MRTprediction_protocol_JR(rootdir,outputdir) % [events, info, licks] =

%% PREP: PAIR RHDS and MATS, CONSIDER MULTIPLE RHDS, ...
if nargin <1
    rootdir=uigetdir;
end

%% load acq_time file:
load('/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fMRI_new_mat/acq_time_EPI.mat'); 


%% get all rhds and mats, create pairs of corresponding files, ...

rhdlist=getAllFiles(rootdir, '*.rhd',1);
protocollist=getAllFiles(rootdir, '*protocol.mat', 1);

rhdlist=getAllFiles(rootdir, '*.rhd',1);
protocollist=getAllFiles(rootdir, '*protocol.mat', 1);

for i=1:length(protocollist)
    [path,protocolname] = fileparts(protocollist{i});
    find_=strfind(protocolname,'_'); % find all _ in string
    
    MAT=protocolname(1:(find_(2)));
    RHD=find(contains(rhdlist, MAT));
    
    if ~isempty(RHD)
        pairs{1,i}=protocollist{i};
        pairs{2,i}=rhdlist(RHD)';
    else
        error(['No intan recording found for ' num2str(MAT)])
    end
end

% extract date of all sessions to be processed...
date = protocolname(find_(1)+1:find_(2)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% LOOP STARTS HERE
for i=[1:size(pairs,2)]
    i
    % PREP: define all paths, subject(s), ...
    
    %matprotocol
    [pathstr,name,ext] = fileparts(pairs{1,i});
    protocolfile = [name ext];
    protocolpath = [pathstr filesep];
    
    
    %intan
    % write intan files in a specific cell structure - important for RHDtoMat
    intan_files_fullpath = pairs{2,i};
    Num_intan_files=numel(intan_files_fullpath);
    for rhd=1:Num_intan_files
        [~,name,ext]=fileparts(intan_files_fullpath{1,rhd});
        intan_files{1,rhd}=[name ext];
    end
    
    [pathstr,name,ext] = fileparts(intan_files_fullpath{1});
    intanfile = [name ext]; % kind of double information - not very elegant
    intanpath = [pathstr filesep];
    
    
    % -----
    % in case that we have to deal with double sessions (2 animals, same sess)
    % plus(+) in nomenclature marks double sessions!
    % example 'rw1+rw2'
    animals = any(strfind(protocolfile, '+'))+1;
    
    
    % subject(s) - double session or not?
    % + mkdir for every single subject in outputdir
    
    find_=strfind(protocolfile,'_'); % find all _ in string
    if animals > 1
        PosPlus = strfind(protocolfile,'+'); % indicator for double!
        subject{1} = protocolfile(1:(PosPlus(1)-1)); mkdir([outputdir filesep subject{1}]);
        subject{2} = protocolfile(PosPlus(1)+1:find_(1)-1); mkdir([outputdir filesep subject{2}]);
    else
        subject{1} = protocolfile(1:find_(1)-1); mkdir([outputdir filesep subject{1}]);
    end
    %
    % %ADDED BY MA FOR SESSIONS WITHOUT ODOR
    % find_=strfind(protocolfile,'_'); % find all _ in string
    % if animals > 1
    %    PosPlus = strfind(protocolfile,'+'); % indicator for double!
    %    subject{1} = protocolfile(1:(PosPlus(1)-1)); mkdir([outputdir filesep subject{1} '_NO']);
    %    subject{2} = protocolfile(PosPlus(1)+1:find_(1)-1); mkdir([outputdir filesep subject{2} '_NO']);
    % else
    %    subject{1} = protocolfile(1:find_(1)-1); mkdir([outputdir filesep subject{1} '_NO']);
    % end
    
    % %ADDED BY MA FOR fMRI SESSIONS
    % find_=strfind(protocolfile,'_'); % find all _ in string
    % if animals > 1
    %    PosPlus = strfind(protocolfile,'+'); % indicator for double!
    %    subject{1} = protocolfile(1:(PosPlus(1)-1)); mkdir([outputdir filesep subject{1} '_fMRI']);
    %    subject{2} = protocolfile(PosPlus(1)+1:find_(1)-1); mkdir([outputdir filesep subject{2} '_fMRI']);
    % else
    %    subject{1} = protocolfile(1:find_(1)-1); mkdir([outputdir filesep subject{1} '_fMRI']);
    % end
    
    % %ADDED BY MA FOR fMRI SESSIONS WITHOUT ODOR
    % find_=strfind(protocolfile,'_'); % find all _ in string
    % if animals > 1
    %    PosPlus = strfind(protocolfile,'+'); % indicator for double!
    %    subject{1} = protocolfile(1:(PosPlus(1)-1)); mkdir([outputdir filesep subject{1} '_fMRI_NO']);
    %    subject{2} = protocolfile(PosPlus(1)+1:find_(1)-1); mkdir([outputdir filesep subject{2} '_fMRI_NO']);
    % else
    %    subject{1} = protocolfile(1:find_(1)-1); mkdir([outputdir filesep subject{1} '_fMRI_NO']);
    % end
    
    % load protocol.mat: first time, second time in loop ...
    load([protocolpath protocolfile]);
    
    
    %% takes ADC, Ditial protocols, extracts timing of odorant, reward, licks, saves in protocol.
    
    % takes into account if first event on digital channels is bug-like. after
    % that it parses timings up to last trial in protocolfile.
    
    
    %% conversion RHD to Mat
    
    % wraps all rhd files (if present) and creates an ADC.mat + digital.mat
    % extracts sample_rate
    
    [~,recording_params] = RhdToMat_lw(intanpath,intan_files,rootdir); % sample_rate = freq;
    freq = recording_params.frequency_parameters.amplifier_sample_rate;
    
    %% load ADCs, Digitals + mat protocol
    
    ADCs=(getAllFiles(rootdir, '*adc.mat',1))'; load(ADCs{1});
    DIGs=(getAllFiles(rootdir, '*digital.mat',1))'; load(DIGs{1});
    
    % move ADCs, Digitals to separate folder...
    ADCDIGdir=[outputdir filesep 'ANALOGS+DIGITALS'];
    mkdir(ADCDIGdir);
    movefile(ADCs{1},ADCDIGdir); movefile(DIGs{1},ADCDIGdir);
    
    %% extract final valve timing
    
    % CAVE: CHOOSE RIGHT CHANNEL FOR FV!
    fvtrace=dchannels(:,1);
    
    fv_on=find(diff(fvtrace)==1)/freq;
    fv_off=find(diff(fvtrace)==-1)/freq;
    
    %fv_on(37) = []; fv_off(36) = [] % debug for one session -> PD12+PD11_181031_104959.rhd
    
    fv_dur=fv_off-fv_on;
    
    % ----
    
    % REMOVE SERIAL COMMUNICATION SIGNAL at the beginning / end
    % = REMOVE FALSE SIGNALS
    
    
    % in case you start matlab protocol twice in one intan recording
    if length(find(fv_dur > 9)) > 1
        limits=find(fv_dur>9);
        fv_on([limits(1):1:limits(2)])= [];
        fv_off([limits(1):1:limits(2)])= [];
        fv_dur([limits(1):1:limits(2)])= [];
    end
    
    % ----
    
    % remove false signals detected..
    ToDelete= find( fv_dur >1.05 | fv_dur < 0.95);
    
    fv_on(ToDelete)= [];
    fv_off(ToDelete)= [];
    fv_dur(ToDelete)= [];
    
    
    % ----
    
    % CONTROL: detected number of fv onsets equal to trials passed?
    MaxTrialNum = length(session.data.trials);
    if length(fv_on) ~= MaxTrialNum
        error(['incorrect number of fv_onsets (~=MaxTrialNum) in ' protocolfile '.mat'])
    end
    
    % CONTROL: same number of fv ons and offs...
    if length(fv_on)~=length(fv_off)
        error(['unequal number of fv_on and fv_off in ' protocolfile '.mat'])
    end
    
    
    %% trigger
    
    trigData=dchannels(:,3); % trigger scanner LW
    
    trigDatadiff=diff(trigData);
    trigNum=numel(find(trigDatadiff == -1));
    % We define trigTime as the onset of the trigger
    trigTime=find(trigDatadiff==-1)/freq;
    
    trigTime_on=find(trigDatadiff==-1)/freq;
    trigTime_off=find(trigDatadiff==1)/freq;
    
    % Sometimes the trig signal starts at the wrong baseline and changes
    % within the first milli-seconds, therefore check the size of
    % trigTime_on and trigTime_off and correct it, if necessary
    if size(trigTime_off,1)>size(trigTime_on,1);
        trigTime_off(1)=[];
        display(['First trigTime incorrect']);
    end;
    
    % estimation of intertrigger distance (trigDurTotal) based on trigger duration
    % (trigDur) and time between triggers (trigDurInter)
    trigDur=trigTime_off-trigTime_on;
    for zx=1:(size(trigTime_off,1)-1);
        trigDurInter(zx)=trigTime_on(zx+1)-trigTime_off(zx);
        trigDurTotal(zx)=trigDur(zx)+trigDurInter(zx);
        if trigDurTotal(zx) < 1.19 
            display(['trigDur of # ' num2str(zx) 'to small in' protocolfile '.mat']);
        end;
    end;
    
    % correction of uncorrect trigDur
    ToCorrect=find(trigDurTotal<1.19); 
    if ~isempty(ToCorrect);
        trigTime(ToCorrect(2))=[];
        trigTime_on(ToCorrect(2))=[];
        trigTime_off(ToCorrect(2))=[];
        display(['trigDur of # ' num2str(zx) 'corrected in' protocolfile '.mat']);
        trigDur=trigTime_off-trigTime_on;
        for zx=1:(size(trigTime_off,1)-1);
            trigDurInter(zx)=trigTime_on(zx+1)-trigTime_off(zx);
            trigDurTotal(zx)=trigDur(zx)+trigDurInter(zx);
            if trigDurTotal(zx) < 1.19 
                error(['trigDurTotal of # ' num2str(zx) 'to small/large in' protocolfile '.mat']);
            end;
        end;
    end;
    
    for zx=1:size(trigDur,1);
        if trigDur(zx) > 0.027 | trigDur(zx) < 0.023
            display(['CAVE: trigDur of # ' num2str(zx) 'to small/large in' protocolfile '.mat']);
        end;
    end;
    trigInter=diff(trigTime);
    
    % remove false signals detected..
    ToDelete= find( trigInter >1.21 | trigInter < 1.19);
    
    % This is added since sometime triggers at the end of the scan are
    % found:
    ToDelete=ToDelete(find(ToDelete<1550));
    
    if ~isempty(ToDelete);
        trigTime([1:ToDelete(end)])= [];
        trigInter([1:ToDelete(end)])= [];
    end;

    trigDuringDummy=numel(find(trigTime<fv_on(1)));
    
    trigger.trigDuringDummy=trigDuringDummy;
    trigger.trigTime=trigTime;
    trigger.trigTime_on=trigTime_on;
    trigger.trigTime_off=trigTime_off;
    trigger.trigDurTotal=trigDurTotal;
    trigger.trigDur=trigDur;
    trigger.trigDurInter=trigDurInter;
    
    % Loop for finding the acq_time of the EPI (from brkhdr), which we will
    % need later
    for ix=1:size(acq_time,2);
        if length(protocolfile)==29;
            index1=find(contains(acq_time(ix).name,[protocolfile(6:11)]));
        elseif length(protocolfile)==34;
            index1=find(contains(acq_time(ix).name,[protocolfile(11:16)]));
        end;
        index2=find(contains(acq_time(ix).name,[protocolfile(1:4)]));
        if ~isempty(index1) & ~isempty(index2);
            acq_time_EPI.start=acq_time(ix).start_seconds;
            acq_time_EPI.index=ix;
            acq_time_EPI.name=acq_time(ix).name;
        end;
    end;
    
    %     idx=find(trigDatadiff==-1,numb_of_volumes,'last'); % 2295 = number of volumes for sanity check; 1395 for main!
    scan_start_del5=trigTime(6); %tp when the aquisition of the 6th EPI starts LW
    
    %   info for plot: first and last odor signals are artefacts:
    figure(1); subplot(4,1,1);
    plot(dchannels(:,3)+1.2); hold on; plot(dchannels(:,1));
    hold on; h1=line([trigTime(1)*freq trigTime(1)*freq],[0 2.2]); h1.Color=[0 1 1];h1.LineStyle='--';h1.LineWidth=1;
    hold on; h2=line([trigTime(6)*freq trigTime(6)*freq],[0 2.2]); h2.Color=[0 1 0];h2.LineStyle='-.';h2.LineWidth=1;
    hold on; h3=line([fv_off(end)*freq fv_off(end)*freq],[0 2.2]); h3.Color=[1 0 0];h3.LineWidth=1;
    hold on; h4=line([fv_on(1)*freq fv_on(1)*freq],[0 2.2]); h4.Color=[1 1 0];h1.LineStyle='-';h4.LineWidth=1;
    title(cellstr(protocolfile),'Interpreter', 'none');
    if ~isempty(ToCorrect);
        text(0,3,['trigDur of # ' num2str(ToCorrect) 'to small/large in' protocolfile '.mat']);
    end;
    
    subplot(4,1,2);
    plot(dchannels(:,3)+1.2); hold on; plot(dchannels(:,1));
    ax=gca;
    ax.XLim=[0 (fv_on(2)*freq)];
    hold on; h1=line([trigTime(1)*freq trigTime(1)*freq],[0 2.2]); h1.Color=[0 1 0];h1.LineStyle='--';h1.LineWidth=1;
    hold on; h2=line([trigTime(6)*freq trigTime(6)*freq],[0 2.2]); h2.Color=[0 1 0];h2.LineStyle='-.';h2.LineWidth=1;
    hold on; h3=line([fv_off(end)*freq fv_off(end)*freq],[0 2.2]); h3.Color=[1 1 0];h3.LineWidth=1;
    hold on; h4=line([fv_on(1)*freq fv_on(1)*freq],[0 2.2]); h4.Color=[1 1 0];h1.LineStyle='-';h4.LineWidth=1;
    title(cellstr(protocolfile),'Interpreter', 'none');
    
    
    subplot(4,1,3);
    plot(dchannels(:,3)+1.2); hold on; plot(dchannels(:,1));
    ax=gca;
    ax.XLim=[fv_off(end-1)*freq-10000 trigTime(end)*freq+10000];
    hold on; h1=line([trigTime(1)*freq trigTime(1)*freq],[0 2.2]); h1.Color=[0 1 0];h1.LineStyle='--';h1.LineWidth=1;
    hold on; h2=line([trigTime(6)*freq trigTime(6)*freq],[0 2.2]); h2.Color=[0 1 0];h2.LineStyle='-.';h2.LineWidth=1;
    hold on; h3=line([fv_off(end)*freq fv_off(end)*freq],[0 2.2]); h3.Color=[1 0 0];h3.LineWidth=1;
    hold on; h4=line([fv_on(1)*freq fv_on(1)*freq],[0 2.2]); h4.Color=[1 1 0];h1.LineStyle='-';h4.LineWidth=1;
    title(cellstr(protocolfile),'Interpreter', 'none');
    l=legend('EPI-trigger','Odor-On/Off','EPI-START','EPI-del5START','Paradigm-END','Paradigm-START','Location','southeast');
    l.FontSize=7;
    
    EPIframes_per_sesscion=sum(trigTime > fv_on(1) & trigTime < fv_off(end));
    MyText{1}=string(['EPI volumes during whole paradigm: ' num2str(EPIframes_per_sesscion)]);
    MyText{2}=string(['Scan Start: ' num2str(scan_start_del5) 'ms']);
    MyText{3}=string(['Paradigm duration: ' num2str(fv_off(end)-fv_on(1)) 'ms']);
    MyText{4}=string(['Mean Trial duration: ' num2str((fv_off(end)-fv_on(1))/160) 'ms']);
    
    
    MyBox = uicontrol('style','text')
    set(MyBox,'String',MyText) 
    xpos=25 
    ypos=25
    xsize=300
    ysize=100
    set(MyBox,'Position',[xpos,ypos,xsize,ysize])
    today = datetime('today');
    DateString = datestr(today)


    print('-dpsc',fullfile(outputdir,['Start_and_End_Control_Paradim_plus_EPI_' DateString]) ,'-r400','-append')
    
    close(figure(1));   
    %% extract reward timing
    
    % CAVE: CHOOSE RIGHT CHANNEL FOR REWARD SIGNAL!
    droptrace=dchannels(:,2);
    
    % drop latency - depending on setup - CHECK!
    drop_latency=0;           %0.1;
    
    % find drops in derivative of digital trace...(+add drop latency)
    drops=find(diff(droptrace)==1)/freq + drop_latency;
    
    
    
    % ----
    
    % SERIAL COMMUNICATION SIGNAL causes artificial signal at the beginning / end
    % We just delete the first one, last one useful later (see below)
    
    drops(drops<fv_on(1))=[];
    %drops(drops>fv_on(end)+5)=[];
    
    % ADDITIONAL CONTROL: Deactivated...
    % for counter=2:length(drops)-1
    %     if drops(counter+1) - drops(counter) < 8 && drops(counter) - drops(counter-1) < 8
    %        drops_false(counter) = 1;
    %        drops_false(counter+1) = 1;
    %     end
    % end
    %drops(drops==1)=[];
    
    
    %% extract lick timing
    
    for ii=1:animals
        
        % load protocol.mat
        load([protocolpath protocolfile]);
        
        
        % CAVE: CHOOSE RIGHT ADC, LOOK FOR DOUBLE SESS
        licksignal=adcchannels(:,ii);
        
        % filtering analog licksignal...
        LowPass = 10; % in Hz
        HighPass = 1; % in Hz
        [c,d] = butter(2, [HighPass LowPass]/(freq/2));
        
        licksignal=smooth((licksignal-mean(licksignal))./std(licksignal),5);
        
        filtered_licksignal=filtfilt(c, d, licksignal);
        
        derivative = diff(filtered_licksignal);
        
        % detection thres: define multiply_factor!
        multiply_factor =10 ; % CAVE !!! %normal = 10; debug raw trace artefact = multiply factor 30 ...
        threshold=median(abs(derivative))*multiply_factor;
        
        if threshold < 0.01;
            threshold = 0.03;
        end;
        
        lickthr=derivative<-threshold; % only - !
        licks=find(diff(lickthr)==-1)/freq;
        
        
%         CONTROL: plot rawdata, derivative, thres, detected licks....
%         
        visualization_factor = 10; % only for better visualization in plot ...
        
        figure(20);
        plot(licksignal);
        hold on;
        plot(derivative*visualization_factor); %20)
        % line for thres
        line(xlim, [threshold threshold]*visualization_factor,'color','r');   % old 10
        line(xlim, [-threshold -threshold]*visualization_factor,'color','g');   % old 10
        
        plot(dchannels(:,1)+2);
        
        
        % plot licks:
        for b=1:length(licks);
            plot([licks(b)*freq licks(b)*freq],[-2 -1],'m');
        end;
        title(cellstr(protocolfile),'Interpreter', 'none');
        l=legend('Licksignal (normalized by mean and std)','Derivative Licksignal','Pos. Threshold','Neg. Threshold (ONLY this one is used for lick detection)','EPI-Triggers','Licks','Location','southeast');
        if threshold==0.03;
            text(1*10^6,2,'CAVE: Predefined Threshold');
        end;
        today = datetime('today');
        DateString = datestr(today);
        print('-dpsc',fullfile(outputdir,['Licksignal_' DateString]) ,'-r400','-append');
%         input('weiter');
        close(figure(20));
        
% %                     only for 100/50/0 ...
%         odor_code=[session.trialmatrix{1}.odor_num];
%         for a=1:length(fv_on)
%             code_cur=odor_code(a)
%             %100
%             if code_cur == 5
%                 plot([fv_on(a)*freq fv_on(a)*freq],[-1 1],'g')
%             end
%             %50
%             if code_cur == 9
%                 plot([fv_on(a)*freq fv_on(a)*freq],[-1 1],'y')
%             end
%             %0
%             if code_cur == 8
%                 plot([fv_on(a)*freq fv_on(a)*freq],[-1 1],'r')
%             end
%         end
%         
        
        %% del5-creation
        
        fv_on_del5=fv_on-scan_start_del5;
        if fv_on(1) < scan_start_del5;
            error(['first odor before end of dummies in ' protocolfile '.mat'])
        end;
        fv_off_del5=fv_off-scan_start_del5;    
        drops_del5=drops-scan_start_del5;
        licks_del5=licks-scan_start_del5;

        
        %% parse timing in table
        
        % PREPARATION:
        events=session.data.trials;
        events=rmfield(events,'rew_code'); %% delete first rew_code field in events
        
        
        % reward_active was deleted in some sessions by LW -> needed for plots
        % in other scripts!
        if isfield(events,'reward_active') == 0
            for ix=1:MaxTrialNum
                events(ix).reward_active = 1;
            end
        end
        
        % ------
        
        % add fv on / fv off / fv dur / reward time / licks to trialmatrix....
        
        % TRIAL 1 - 149
        for i=1:length(fv_on)-1
            
            % ODOR
            events(i).fv_on=fv_on(i);
            events(i).fv_off=fv_off(i);
            events(i).fv_dur=fv_dur(i);
            events(i).fv_on_del5=fv_on_del5(i);
            events(i).fv_off_del5=fv_off_del5(i);
            events(i).fv_dur_del5=fv_dur(i);
            
            
            % DROPS
            events(i).reward_time=drops(drops>fv_on(i) & drops<fv_on(i+1));
            events(i).reward_time_del5=drops_del5(drops_del5>fv_on_del5(i) & drops_del5<fv_on_del5(i+1));
            
            % CONTROL: check if there is only one drop in interval..
            if numel(drops(drops>fv_on(i) & drops<fv_on(i+1))) > 1
                
                events(i).reward_time = fv_off(i) + 1.7 + drop_latency; % DIRTY! LW
                
                %error(['Trial with more than one drop detected in ' protocolfile '.mat'])
            end
            % for removing an additional drop...
            %tmp=drops(drops>fv_on(i) & drops<fv_on(i+1)); if numel(tmp)>1; events(i).reward_time=tmp(1); else events(i).reward_time=tmp; end; % CC, because in some few cases there was more than one drop in this interval (which shouldn't be possible)
            
            % LICKS
            events(i).licks=licks(licks>fv_on(i) & licks<fv_on(i+1));
            events(i).licks_del5=licks_del5(licks_del5>fv_on_del5(i) & licks_del5<fv_on_del5(i+1));
        end
        
%         for z=1:length(trigTime);

%         end;
        
        
        % LAST TRIAL - treated separately
        i=length(fv_on);
        
        %ODORS
        events(i).fv_on=fv_on(i);
        events(i).fv_off=fv_off(i);
        events(i).fv_dur=fv_dur(i);
        
        events(i).fv_on_del5=fv_on_del5(i);
        events(i).fv_off_del5=fv_off_del5(i);
        events(i).fv_dur_del5=fv_dur(i);

        % temp = all drops after last fv onset..
        temp=drops(drops>fv_on(i));
        % DIFF_odor_drop = time between last fv on and first droptrace afterwards..
        DIFF_odor_drop=temp(1)-fv_on(i);
        
        % this if condition makes sure that the artificial dropsignal (occuring when
        % serial communication is closed) is not considered as a drop...
        if any(temp) & DIFF_odor_drop < 4
            events(i).reward_time=temp(1);
        end
        
                % temp = all drops after last fv onset..
        temp_del5=drops_del5(drops_del5>fv_on_del5(i));
        % DIFF_odor_drop = time between last fv on and first droptrace afterwards..
        DIFF_odor_drop_del5=temp_del5(1)-fv_on_del5(i);
        
        % this if condition makes sure that the artificial dropsignal (occuring when
        % serial communication is closed) is not considered as a drop...
        if any(temp_del5) & DIFF_odor_drop_del5 < 4
            events(i).reward_time_del5=temp_del5(1);
        end
        
        % licking for last trial:
        if length(fv_on) == MaxTrialNum
            events(i).licks=licks(licks>fv_on(i) & licks<(fv_on(i)+10));
            events(i).licks_del5=licks_del5(licks_del5>fv_on_del5(i) & licks_del5<(fv_on_del5(i)+10));
            
            % interval of 10 seconds for last trial
        else
            events(i+1).licks_del5=licks_del5(licks_del5>fv_on_del5(i) & licks_del5<(fv_on_del5(i)+10));
            % probably not necessary anymore...
        end
        
        
        %% compute reward/lick/oder_lick codes, parse in table
        
        % SCHEME FOR AWAKE PARADIGM LW
        % odor (1s) + drop_delay (1.7 + 0.1 (drop_latency)=1.8)
        
        odor_duration=session.chapter.odor_duration{1,1}/1000;
        dropdelay=session.chapter.reward_delay/1000;
        
        go_threshold_ante=3; %3 % no of licks in dropdelay that count as anticipatory licking
        go_threshold_post=3; %3 % no of licks in dropdelay that count as post licking
        
        % intervals for licking windows defining ante - post ...
        lickwin_ante=[0.5 1.8];
        lickwin_post=[1.8 3.1];
        
        
        %------
        
        
        %% ante criterion:
        
        for i=1:length(fv_on_del5)
            
            if sum(licks_del5>(fv_on_del5(i)+odor_duration+lickwin_ante(1)) & licks_del5<(fv_on_del5(i)+odor_duration+lickwin_ante(2)))>= go_threshold_ante
                
                events(i).lick_code_ante=1; % lick criterion fulfilled % CC added
                
                if events(i).reward_active
                    
                    events(i).rew_code_ante=1; % Hit
                    
                else
                    
                    events(i).rew_code_ante=2; % False Alarm
                    
                end
                
                %%% added by CC
                
                if events(i).curr_odor_num==5
                    
                    events(i).odor_lick_code_ante=51; % lick criterion fulfilled at odor 5
                    
                elseif events(i).curr_odor_num==9
                    
                    events(i).odor_lick_code_ante=91;% lick criterion fulfilled at odor 9
                    
                elseif events(i).curr_odor_num==8
                    
                    events(i).odor_lick_code_ante=81;% lick criterion fulfilled at odor 8
                    
                end
                
                %%%
                
            else % No-Go
                
                events(i).lick_code_ante=0; % lick criterion fulfilled % CC added
                
                if events(i).reward_active
                    
                    events(i).rew_code_ante=4; % Miss
                    
                else
                    
                    events(i).rew_code_ante=3; % Correct Rejection
                    
                end
                
                %%% added by CC
                
                if events(i).curr_odor_num==5
                    
                    events(i).odor_lick_code_ante=50; % lick criterion not fulfilled at odor 5
                    
                elseif events(i).curr_odor_num==9
                    
                    events(i).odor_lick_code_ante=91;% lick criterion not fulfilled at odor 5
                    
                elseif events(i).curr_odor_num==8
                    
                    events(i).odor_lick_code_ante=80;% lick criterion not fulfilled at odor 5
                    
                end
                
            end
            
            
            %% post criterion:
            
            if sum(licks_del5>(fv_on_del5(i)+odor_duration+lickwin_post(1)) & licks_del5<(fv_on_del5(i)+odor_duration+lickwin_post(2)))>= go_threshold_post % criterion for licking if mice have learnt that they can also wait for the drop
                
                events(i).lick_code_post=1; % lick criterion fulfilled % CC added
                
                if events(i).reward_active
                    
                    events(i).rew_code_post=1; % Hit
                    
                else
                    
                    events(i).rew_code_post=2; % False Alarm
                    
                end
                
                %%% added by CC
                
                if events(i).curr_odor_num==5
                    
                    events(i).odor_lick_code_post=511; % lick criterion fulfilled at odor 5
                    
                elseif events(i).curr_odor_num==9
                    
                    if events(i).drop_or_not==1
                        
                        events(i).odor_lick_code_post=911;% lick criterion fulfilled at odor 6, drop present
                        
                    else
                        
                        events(i).odor_lick_code_post=901;% lick criterion fulfilled at odor 6, drop absent
                        
                    end
                    
                elseif events(i).curr_odor_num==8
                    
                    events(i).odor_lick_code_post=801;% lick criterion fulfilled at odor 8
                    
                end
                
                
            else % No-Go
                
                events(i).lick_code_post=0; % lick criterion not fulfilled % CC added
                
                if events(i).reward_active
                    
                    events(i).rew_code_post=4; % Miss
                    
                else
                    
                    events(i).rew_code_post=3; % Correct Rejection
                    
                end
                
                %%% added by CC
                
                if events(i).curr_odor_num==5
                    
                    events(i).odor_lick_code_post=510; % lick criterion not fulfilled at odor 5
                    
                elseif events(i).curr_odor_num==9
                    
                    if events(i).drop_or_not==1
                        
                        events(i).odor_lick_code_post=910;% lick criterion not fulfilled at odor 6
                        
                    else
                        
                        events(i).odor_lick_code_post=900;% lick criterion not fulfilled at odor 6
                        
                    end
                    
                elseif events(i).curr_odor_num==8
                    
                    events(i).odor_lick_code_post=800;% lick criterion not fulfilled at odor 8
                    
                end
                
            end
            
        end
        
        
        %% create info
        
        if animals==1 % single sessions
            newname=protocolfile(1:end-4);
            info.ID=intanfile;
            info.animal=subject;
            
        elseif animals>1 % double sessions
            
            if ii == 1 % first animal of double session
                newname=[subject{ii} protocolfile(find_(1):end-4)];
                info.ID=intanfile;
                info.animal=subject{ii};
                
            else
                newname=[subject{ii} protocolfile(find_(1):end-4)];
                info.ID=intanfile;
                info.animal=subject{ii};
            end
        end
        
        k=strfind(intanfile,'_18'); % CC (in order to get the proper date
        info.date=intanfile(k(1)+1:k(1)+6); % CC
        
        info.tag=session.chapter.case;
        
        info.superflex_parameters=session.chapter;
        
        info.scan_start_del5=scan_start_del5;
        info.EPIframes_per_sesscion=sum(trigTime > fv_on(1) & trigTime < fv_off(end));

        %% save updated protocol
        
        %save in subjdir...
        save([outputdir filesep subject{ii} filesep newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq', 'trigger', 'acq_time_EPI');
        
        %save in dir for training day...
        % trainingdir=[outputdir filesep 'TrainingDays' filesep date '_training'];
        % mkdir(trainingdir);
        % save([trainingdir filesep newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        
        clear events info licks session
        
        % %FOR fMRI SESSIONS ADDED BY MA
        % %save in subjdir...
        % save([outputdir filesep subject{ii} '_fMRI' filesep 'fMRI' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % %save in dir for training day...
        % trainingdir=[outputdir filesep 'TrainingDays' filesep date '_training_fMRI'];
        % mkdir(trainingdir);
        % save([trainingdir filesep 'fMRI' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % clear events info licks session
        
        
        % %FOR fMRI SESSIONS WITHOUT ODOR ADDED BY MA
        % %save in subjdir...
        % save([outputdir filesep subject{ii} '_fMRI_NO' filesep 'fMRINO' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % %save in dir for training day...
        % trainingdir=[outputdir filesep 'TrainingDays' filesep date '_training_fMRI_NO'];
        % mkdir(trainingdir);
        % save([trainingdir filesep 'fMRINO' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % clear events info licks session
        
        
        % %%FOR SESSIONS WITHOUT ODOR ADDED BY MA
        % %save in subjdir...
        % save([outputdir filesep subject{ii} '_NO' filesep 'NO' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % %save in dir for training day...
        % trainingdir=[outputdir filesep 'TrainingDays' filesep date '_training_NO'];
        % mkdir(trainingdir);
        % save([trainingdir filesep 'NO' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % clear events info licks session
        
        % %%FOR SESSIONS UNCLEAR IF ODOR WAS THERE ADDED BY MA
        % %save in subjdir...
        % save([outputdir filesep subject{ii} '(NO)' filesep '(NO)' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % %save in dir for training day...
        % trainingdir=[outputdir filesep 'TrainingDays' filesep date '_training_(NO)'];
        % mkdir(trainingdir);
        % save([trainingdir filesep '(NO)' newname '_new.mat'], 'events', 'info', 'licks', 'session', 'freq');
        %
        % clear events info licks session
        
        
        
    end
    
end % SESSION LOOP