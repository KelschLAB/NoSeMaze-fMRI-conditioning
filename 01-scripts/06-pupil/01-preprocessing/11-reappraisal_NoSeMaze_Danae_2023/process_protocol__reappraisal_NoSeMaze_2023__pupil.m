function  process_protocol__reappraisal_NoSeMaze_2023__pupil(protocollist,rhdlist,outputdir,rootdir) % [events, info, licks] =

%% get all rhds and mats, create pairs of corresponding files, ...

for ii=1:length(protocollist)
    [path,protocolname] = fileparts(protocollist{ii});
    find_=strfind(protocolname,'_'); % find all _ in string
    
    %   MAT=protocolname(1:(find_(1)+1));
    MAT=protocolname(1:(find_(2)-1));
    
    RHD=find(contains(rhdlist, MAT));
    
    if ~isempty(RHD)
        pairs{1,ii}=protocollist{ii};
        pairs{2,ii}=rhdlist(RHD)';
    else
        error(['No intan recording found for ' num2str(MAT)])
    end
end

% % extract date of all sessions to be processed...
% date = protocolname(find_(1)+1:find_(2)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% LOOP STARTS HERE
for ii=1:size(pairs,2)
    ii
    % PREP: define all paths, subject(s), ...
    
    %matprotocol
    [pathstr,name,ext] = fileparts(pairs{1,ii});
    protocolfile = [name ext];
    protocolpath = [pathstr filesep];
    
    
    %intan
    % write intan files in a specific cell structure - important for RHDtoMat
    intan_files_fullpath = pairs{2,ii};
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
        subject{1} = protocolfile(1:find_(2)-1); mkdir([outputdir filesep subject{1}]);
    end
    %
    load([protocolpath protocolfile]);
    
    
    %% takes ADC, Ditial protocols, extracts timing of odorant, reward, licks, saves in protocol.
    
    % takes into account if first event on digital channels is bug-like. after
    % that it parses timings up to last trial in protocolfile.
    
    
    %% conversion RHD to Mat
    
    % wraps all rhd files (if present) and creates an ADC.mat + digital.mat
    % extracts sample_rate
    [~,recording_params] = RhdToMat_lw(intanpath,intan_files,rootdir); % sample_rate = freq;
    %     RhdToMat_lw_old(intanpath,intan_files,rootdir); % sample_rate = freq;
    freq = recording_params.frequency_parameters.amplifier_sample_rate;
    %     freq=30000
    
    %% load ADCs, Digitals + mat protocol
    
    ADCs=(getAllFiles(rootdir, '*adc.mat',1))'; load(ADCs{1});
    DIGs=(getAllFiles(rootdir, '*digital.mat',1))'; load(DIGs{1});
    
    % move ADCs, Digitals to separate folder...
    ADCDIGdir=[outputdir filesep 'ANALOGS+DIGITALS'];
    mkdir(ADCDIGdir);
    movefile(ADCs{1},ADCDIGdir);
    movefile(DIGs{1},ADCDIGdir);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% I. Extraction of final valve timing (Odor trace)
    % recorded on channel 1
    
    % read fv trace of dchannel 1
    fvtrace=dchannels(:,2);
    
    % detect fv_on and fv_off
    fv_on=find(diff(fvtrace)==1)/freq;
    fv_off=find(diff(fvtrace)==-1)/freq;
    
    % calculate fv_dur (duration)
    fv_dur=fv_off-fv_on;
    
    % in case you start matlab protocol twice in one intan recording
    if length(find(fv_dur > 9)) > 1
        limits=find(fv_dur>9);
        fv_on([limits(1):1:limits(2)])= [];
        fv_off([limits(1):1:limits(2)])= [];
        fv_dur([limits(1):1:limits(2)])= [];
    end
    
    % remove false signals detected (e.g. at the end or at the beginning) by controlling the
    % fv_dur (here: 2.4 s)
    ToDelete= find( fv_dur > 2.45 | fv_dur < 2.35); %%% CAVE: CHANGE BACK AFTER FIRST SESSIONS
    
    if ~isempty(ToDelete)
        % Case 1: False signals at the end
        if ToDelete(1) > length(session.trialmatrix) && ToDelete(end) > length(session.trialmatrix)
            fv_on(ToDelete(1):ToDelete(end))= [];
            fv_off(ToDelete(1):ToDelete(end))= [];
            fv_dur(ToDelete(1):ToDelete(end))= [];
            % Case 2: False signals at the start
        elseif ToDelete(1) < 20 && ToDelete(end) < 20
            fv_on(1:ToDelete(end))= [];
            fv_off(1:ToDelete(end))= [];
            fv_dur(1:ToDelete(end))= [];
            % Case 3: False signals in the middle, but very short
        elseif length(ToDelete) == 1 && ToDelete(1) > 1 && ToDelete(end) < length(session.trialmatrix) && fv_dur(ToDelete(1)) < 0.001
            fv_on(ToDelete(1))= [];
            fv_off(ToDelete(1))= [];
            fv_dur(ToDelete(1))= [];
        else
            error(['Check false fv_onsets manually (~=MaxTrialNum) in ' protocolfile '.mat'])
        end
    end
    
    % CONTROL: detected number of fv onsets equal to trials passed?
    MaxTrialNum = length(session.trialmatrix);
    if length(fv_on) ~= MaxTrialNum
        error(['incorrect number of fv_onsets (~=MaxTrialNum) in ' protocolfile '.mat'])
    end
    
    % CONTROL: same number of fv ons and offs...
    if length(fv_on)~=length(fv_off)
        error(['unequal number of fv_on and fv_off in ' protocolfile '.mat'])
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% II. Extraction of valve timing for air-puff
    % recorded on channel 2
    
    % read puff trace of dchannel 2
    pufftrace=dchannels(:,1);
    
    % detect puff_on and puff_off
    puff_on=find(diff(pufftrace)==1)/freq;
    puff_off=find(diff(pufftrace)==-1)/freq;
    
    % calculate puff_dur (duration)
    puff_dur=puff_off-puff_on;
    
    % remove false signals detected (e.g. at the end) by controlling the
    % fv_dur (here: 0.1 s)
    ToDelete= find( puff_dur >0.15 | puff_dur < 0.05);
    
    puff_on(ToDelete)= [];
    puff_off(ToDelete)= [];
    puff_dur(ToDelete)= [];
    
    % CONTROL: detected number of fv onsets equal to trials passed?
    MaxPuffNum = sum([session.trialmatrix.air_lat]'~=0);
    if length(puff_on) ~= MaxPuffNum
        error(['incorrect number of fv_onsets (~=MaxTrialNum) in ' protocolfile '.mat'])
    end
    
    % CONTROL: same number of fv ons and offs...
    if length(puff_on)~=length(puff_off)
        error(['unequal number of fv_on and fv_off in ' protocolfile '.mat'])
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% III. Extraction of Laser-trigger
    % recorded on channel 4
    % baseline is at 0,
    
    % read trig trace of dchannel 4
    trigData=dchannels(:,7); % trigger scanner LW
    
    trigDatadiff=diff(trigData);
    trigNum=numel(find(trigDatadiff == 1));
    % We define trigTime as the onset of the trigger
    trigTime=find(trigDatadiff==1)/freq;
    
    trigTime_on=find(trigDatadiff==1)/freq;
    trigTime_off=find(trigDatadiff==-1)/freq;
    
    %     % Sometimes the trig signal starts at the wrong baseline and changes
    %     % within the first milli-seconds, therefore check the size of
    %     % trigTime_on and trigTime_off and correct it, if necessary
    %     if size(trigTime_off,1)>size(trigTime_on,1);
    %         trigTime_off(1)=[];
    %         display(['First trigTime incorrect']);
    %     end;
    
    % estimation of intertrigger distance (trigDurTotal) based on trigger duration
    % (trigDur) and time between triggers (trigDurInter)
    trigDur=trigTime_off-trigTime_on;
    
    %     for zx=1:(size(trigTime_off,1)-1);
    %         trigDurInter(zx)=trigTime_on(zx+1)-trigTime_off(zx);
    %         trigDurTotal(zx)=trigDur(zx)+trigDurInter(zx);
    %         trigDurTotalOrig=trigDurTotal;
    %         if trigDurTotal(zx) < 1.19
    %             display(['trigDur of # ' num2str(zx) 'to small in' protocolfile '.mat']);
    %         end;
    %     end;
    
    if length(trigTime_on)>2
        display(['more than two laser triger in ' protocolfile '.mat - please check the file!']);
    end
    
    if length(trigTime_on)==2 
        trigger.trigTimeStart_on=trigTime_on(1);
        trigger.trigTimeStart_off=trigTime_off(1);
        trigger.trigTimeEnd_on=trigTime_on(2);
        trigger.trigTimeEnd_off=trigTime_off(2);
        trigger.trigDur=trigDur;
        
    % case: additional triggers only after the end of the paradigm
    elseif length(trigTime_on)>1 && trigTime_on(2) > fv_off(end)
        trigger.trigTime_on=trigTime_on(1);
        trigger.trigTime_off=trigTime_off(1);
        trigger.trigDur=trigDur(1);
        
    % case: additional triggers in the paradigm, but after the first trigger and very short
    elseif length(trigTime_on)>1 && trigTime_on(2) < fv_off(end) && (sum(trigDur(:))-trigDur(1)) < 0.005
        trigger.trigTime_on=trigTime_on(1);
        trigger.trigTime_off=trigTime_off(1);
        trigger.trigDur=trigDur(1);

    % case: additional triggers in the paradigm, but very short (< 1 ms)
    elseif length(trigTime_on)>1 && trigTime_on(2) < fv_off(end) 
        trigDur_original=trigDur;
        trigDur(trigDur_original<0.001)=[];
        trigTime_on(trigDur_original<0.001)=[];
        trigTime_off(trigDur_original<0.001)=[];
        trigger.trigTime_on=trigTime_on(1);
        trigger.trigTime_off=trigTime_off(1);
        trigger.trigDur=trigDur(1);
        
    elseif length(trigTime_on)>1 && trigTime_on(2) < fv_off(end)
        error(['unclear second laser trigger in ' protocolfile '.mat']);
    end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% parse timing in table
    
    % PREPARATION:
    events=session.trialmatrix;
    
    % TRIAL 1 - 119
    for i=1:length(fv_on)-1
        
        % ODOR
        events(i).fv_on=fv_on(i);
        events(i).fv_off=fv_off(i);
        events(i).fv_dur=fv_dur(i);
        
        % PUFF
        if any(puff_on>fv_on(i) & puff_on<fv_on(i+1))
            events(i).puff_time=puff_on(find(puff_on>fv_on(i) & puff_on<fv_on(i+1)));
            events(i).puff_or_not=1;
        elseif ~any(puff_on>fv_on(i) & puff_on<fv_on(i+1))
            events(i).puff_time=fv_on(i)+3.2;
            events(i).puff_or_not=0;
        end
    end
    
    % LAST TRIAL - treated separately
    i=length(fv_on);
    
    %ODORS
    events(i).fv_on=fv_on(i);
    events(i).fv_off=fv_off(i);
    events(i).fv_dur=fv_dur(i);
    
    % PUFF
    if any(puff_on>fv_on(i) & puff_on<(fv_on(i)+events(i).ITI+2))
        events(i).puff_time=puff_on(find(puff_on>fv_on(i) & puff_on<(fv_on(i)+events(i).ITI+2)));
        events(i).puff_or_not=1;
    elseif ~any(puff_on>fv_on(i) & puff_on<(fv_on(i)+events(i).ITI+2))
        events(i).puff_time=fv_on(i)+3.2;
        events(i).puff_or_not=0;
    end
    
    %% create info
    
    if animals==1 % single sessions
        newname=protocolfile(1:end-4);
        info.ID=intanfile;
        info.animal=subject;
    end
    
    k=strfind(intanfile,'_23'); % CC (in order to get the proper date
    info.date=intanfile(k(1)+1:k(1)+6); % CC
    
    info.laserStart_on=trigger.trigTimeStart_on;
    info.laserStart_off=trigger.trigTimeStart_off;
    info.laserEnd_on=trigger.trigTimeEnd_on;
    info.laserEnd_off=trigger.trigTimeEnd_off;
    info.laser_dur=trigger.trigDur;
    %% save updated protocol
    
    %save in subjdir...
    save([outputdir filesep subject{1} filesep newname '_new.mat'], 'events', 'info',  'session', 'freq', 'trigger');
    
    clear events info session intan_files intanpath
    
end