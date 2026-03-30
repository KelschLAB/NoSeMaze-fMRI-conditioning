function res=cc_check_physio_dummy(Pfunc,Ptxtall,ndel_dummies,TrVar)
% - Pfunc: char array containing paths and file names of EPI data (these EPI files should include any dummy scans to be later deleted)
% - Ptxtall: char array containing paths and file names of physio txt files
% to test and repair (must be in the same order as Pfunc!!)
% - TrVar (optional): tolerance for distance between adjacent triggers (Default 50)

% Notes:
% This script looks for "time losses" in the physiological data, which must
% include the trigger data.

% Christian Clemm 2015, 2020
% Changes by wwf: Read bruker header to include Dummy scans
%               Some changes in Graphics output.

if nargin < 4
    TrVar=50; %Allowed variance in TR
end

close all
trigThreshold=100;
outps=['physio_signal_check_figs_' date '.ps'];
outtxt=['physio_signal_check_' date '.txt']; 
% syscmd=['rm ' outps];
% system(syscmd);
% syscmd=['rm ' outtxt];
% system(syscmd);
% plot_ix=1; %two plots per page % CC ???????????????????????????????

basedir=pwd;

if size(Pfunc,1)~=size(Ptxtall,1)
    error('physio and func filelists do not match in size!')
end

for nscan=1:size(Pfunc,1) %CC
    Ptxtcur=strtrim(Ptxtall(nscan,:));
    [fpath fname ext]=fileparts(Ptxtcur);
    
    % get number of images (i.e. time points) per session
    Pfcur=strtrim(Pfunc(nscan,:));
    [fpath2 fname2 ext2]=fileparts(Pfcur);
    Pfcurall=spm_select('ExtFPList',fpath2,['^' fname2 '.nii'],1:3000);   
    %Get the number of dummies out of the header
    brkhdr=spm_select('FPLIST',fpath2,'.*.brkhdr');
    hdr=readBrukerParamFile(brkhdr);
    TR=hdr.PVM_RepetitionTime;
    DumScans=hdr.PVM_DummyScans;
    nRep=hdr.PVM_NRepetitions;
    nVolume=nRep+DumScans-ndel_dummies;
    
    %volumeV = spm_vol( Pfcurall );
    %nVolume = length( volumeV );
            
    % get the physio data
    [trigData, respData, cardData, timeFreq] = ppt_read_physio_txt( Ptxtcur );
    
    % extract trigger time points and intervals
    trigBinary = trigData < trigThreshold;
    trigDiff = diff( trigBinary );
    trigX = find( trigDiff == 1 );
    trigI = diff( trigX);
    trigIOrg=trigI;
    %%% if there are adjustments, get rid of the adjustment triggers
    % this is done such that the last unusually large trigger gap is taken
    % as a starting point:
    if ~isempty(find(trigI>340,1))
        trigStartIx=find(trigI>340,1,'last')+ndel_dummies; % 3.4 is arbitrary, but was chosen because it is unlikely that the distance between two regular EPI triggers (as opposed to adjustment triggers) will be more than 3.4 (this could only happen if there are at least 2 adjacent gaps in the data each taking away a trigger)
        trigStart=trigX(trigStartIx+1);
        trigData=trigData(trigStart-5:end); % "-5" just to add a little more physiological data before first regular trigger
        respData=respData(trigStart-5:end);
        cardData=cardData(trigStart-5:end);

        trigBinaryRed = trigData < trigThreshold;
        trigDiffRed = diff( trigBinaryRed );
        trigX = find( trigDiffRed == 1 );
    else
        trigStartIx=1
    end
    %%%
    
    fid=fopen(outtxt,'a+'); %CC
    fprintf(fid,'%s (session # %d)\n',fname,nscan); %CC
    %first check if enough Triggers
    if length(trigX) >= nVolume
        volumeX = trigX(end + (-nVolume + 1:0)); % counting backwards from the last trigger % This is for discarding excess triggers (e.g. adjustment triggers that might have been close to the first "real" trigger and therefore still present)
        trignMess=sprintf('There are enough trigger signals :-)');
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess);
    else
        trignMess=sprintf('Not enough trigger signals: %d missing.', nVolume - length(trigX));
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess); %CC
        volumeX = trigX;
    end
    
        
    % trigger intervals
    volumeI=diff( volumeX );
    trigI = diff( trigX);
    trigMedian = median( volumeI ); % for computation of median, use only Volumes Trigger Data
    
    figure(25);
    clf
    axes
    hold on
    plot(trigIOrg*100, 'c' )
    plot([zeros(trigStartIx-1,1); trigX], 'b' )
    title(Ptxtcur)
  
    plot( (length( trigI ) - nVolume +2+trigStartIx) * [1, 1], [0, 1000 * trigMedian], 'k' ) % CC added the "+2", because previously the vertical black line ("volume start") was incorrectly placed on the x axis
    plot( (length( trigI ) - nRep +2+trigStartIx) * [1, 1], [0, 1000 * trigMedian], 'r' ) % CC added the "+2", because previously the vertical black line ("volume start") was incorrectly placed on the x axis
    legend( {'Trigger shift', 'Trigger interval * 100', 'Dummy start', 'Volume start'}, ...
        'Location', 'Best')
    title( {[fname ': trigger median: ' num2str( trigMedian )], ...
        ['number of volumes: ' num2str( nVolume)]} )
    print(gcf,'-dpsc2','-append',outps) % make postcript file
    %work on within Volumes Trigger data only now
    trigI=volumeI;
    trigX=volumeX;
    TR=trigMedian;
    
    % detection of wrong trigger distances, and writing into text file "physio signal check"
    TR_diff=trigI-TR; %CC: vector of the deviations of the trigger intervals from the "normal" TR
    trigdis_err=find(abs(TR_diff) > TrVar/10); % "/10" because the resolution is 10ms
    if ~isempty(trigdis_err)
        fid=fopen(outtxt,'a+');
        fprintf(fid,'\t%d trigger distance irregularities.\n',length(trigdis_err));
    else
       fid=fopen(outtxt,'a+');
       fprintf(fid,'\tNo trigger distance irregularities.\n'); 
    end
    if 1==0 % if I want to write each trigger problem individually into the output text file
        for ernum=1:length(trigdis_err)
            fid=fopen(outtxt,'a+'); %CC
            fprintf(fid,'\t Trigger Distance Irregular at Pulse %d with TRdiff= %d ms\n',...
            trigdis_err(ernum), TR_diff(trigdis_err(ernum))*10);
        end
    end
    
    if 1==1
    %repair
    trigDataNew=trigData;
    respDataNew=respData;
    cardDataNew=cardData;
    trigXNew=trigX; 
    trigdis_errNew=trigdis_err;
    gapTPList=zeros(length(trigdis_err),1);
    gapTPlocList=zeros(length(trigdis_err),1);
    misstimeList=zeros(length(trigdis_err),1);
    addtime=0;
%     countMissTrig=0;
    for ernum=1:length(trigdis_err)
        trigTPLast=trigX(trigdis_err(ernum))+addtime;
        trigTPNext=trigX(trigdis_err(ernum)+1)+addtime;
        triggersBelow=trigXNew(trigXNew<=trigTPLast);
        triggersAbove=trigXNew(trigXNew>trigTPLast);
        trigDif=trigTPNext-trigTPLast;
        
        % finding the break, fill in the missing data
        if trigDif<TR
            misstime=TR-trigDif;
            rdatloc=respDataNew(trigTPLast:trigTPNext);
            cdatloc=cardDataNew(trigTPLast:trigTPNext);
            rd=abs((diff(rdatloc)));
            cd=abs((diff(cdatloc)));
            rd2=abs(diff(diff(rdatloc)));
            cd2=abs(diff(diff(cdatloc)));
            dsum=rd(2:end-1)+rd2(1:end-1)+rd2(2:end)+cd(2:end-1)+cd2(1:end-1)+cd2(2:end); % this is the break! (steep slope of the curve (1st deviation) and two sharp bents (2nd deviation)
%             sumdif=rd2+cd2;
            maxval=max(dsum);
            gapTPloctemp=find(dsum==maxval,1,'first'); % this is the location of the break counting from the start of rdatloc
            gapTPloc=gapTPloctemp; % this is the location of the break counting from the last trigger
            gapTP=gapTPloc+trigTPLast;
            gapTPlocList(ernum,1)=gapTPloc;
            gapTPList(ernum,1)=gapTP;
            trigXNew=[triggersBelow; (triggersAbove+misstime)];
            trigInsert=zeros(misstime,1)+215;
        elseif trigDif>TR
%             countMissTrig=countMissTrig+1;
            misstime=2*TR-trigDif;
            rdatloc=respDataNew(trigTPLast+TR-misstime:trigTPLast+TR); 
            % explanation: in order to "catch" the missing trigger, the gap
            % must start after trigTPLast+TR-misstime and before trigTPLast+TR
            cdatloc=cardDataNew(trigTPLast+TR-misstime:trigTPLast+TR); 
            rd=abs((diff(rdatloc)));
            cd=abs((diff(cdatloc)));
            rd2=abs(diff(diff(rdatloc)));
            cd2=abs(diff(diff(cdatloc)));
            dsum=rd(2:end-1)+rd2(1:end-1)+rd2(2:end)+cd(2:end-1)+cd2(1:end-1)+cd2(2:end);% this is the break! (steep slope of the curve (1st deviation) and two sharp bents (2nd deviation)
%             sumdif=rd2+cd2;
            maxval=max(dsum);
            gapTPloctemp=find(dsum==maxval,1,'first'); % this is the location of the break counting from the start of rdatloc
            gapTPloc=gapTPloctemp+TR-misstime; % this is the location of the break counting from the last trigger
            gapTP=gapTPloc+trigTPLast;
            gapTPlocList(ernum,1)=gapTPloc;
            gapTPList(ernum,1)=gapTP;
            trigXNew=[triggersBelow; (trigTPLast+TR); (triggersAbove+misstime)];
            trigdis_errNew=[trigdis_errNew(1:ernum); (trigdis_errNew(ernum+1:end)+1)];
            trigInsert=zeros(misstime,1)+215;
            if (TR-gapTPloc+3)>length(trigInsert)
                trigInsert((TR-gapTPloc):length(trigInsert))=0;
            else
                trigInsert((TR-gapTPloc):(TR-gapTPloc+3))=0;
            end
        elseif trigDif>=2*TR
            error('More than two triggers missing in one place!')
        end
        addtime=addtime+misstime;
        misstimeList(ernum,1)=misstime;
                
        % filling in the missing trig data
        
        if (TR-gapTPloc+3)>length(trigInsert)
            trigDataNew=[trigDataNew(1:gapTP); trigInsert; trigDataNew(gapTP+1:end)];
            trigDataNew(gapTP+length(trigInsert)+1:(gapTP+length(trigInsert)+(TR-gapTPloc+3)-length(trigInsert)))=0;
        else
            trigDataNew=[trigDataNew(1:gapTP); trigInsert; trigDataNew(gapTP+1:end)];
        end
        
        
        % filling in the missing resp data
        respLast=respDataNew(gapTP);
        respNext=respDataNew(gapTP+1);
        respInsert=(linspace(respLast,respNext,misstime))';
        respDataNew=[respDataNew(1:gapTP); respInsert; respDataNew(gapTP+1:end)];
        
        % filling in the missing card data
        cardLast=cardDataNew(gapTP);
        cardNext=cardDataNew(gapTP+1);
        cardInsert=(linspace(cardLast,cardNext,misstime))';
        cardDataNew=[cardDataNew(1:gapTP); cardInsert; cardDataNew(gapTP+1:end)];
    end
    nTrigsAdded=length(trigXNew)-length(trigX);
    if nTrigsAdded>0
        nTrigsAddedMess=sprintf('Repair: %d triggers added.',nTrigsAdded);
        fid=fopen(outtxt,'a+'); 
        fprintf(fid,'\t%s\n', nTrigsAddedMess); 
    end
    diffnTrig=length(trigXNew)-nVolume;
    if diffnTrig>0
        diffnTrigMess=sprintf('!!!!! After repair: TOO MANY triggers have been added (now %d more triggers than volumes).',diffnTrig);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n', diffnTrigMess); %CC
        fprintf(1,'%s (session # %d)\n',fname,nscan); %CC
        fprintf(1,'\t%s\n', diffnTrigMess); %CC
    elseif diffnTrig<0
        diffnTrigMess=sprintf('!!!!! After repair: NOT ENOUGH triggers have been added (still %d less triggers (n=%d) than volumes (n=%d)).',(-1)*diffnTrig,length(trigXNew),nVolume);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n', diffnTrigMess); %CC
        fprintf(1,'%s (session # %d)\n',fname,nscan); %CC
        fprintf(1,'\t%s\n', diffnTrigMess); %CC
    end
    
    countcol=(1:1:(length(trigDataNew)))';
    physioNew=[countcol respDataNew trigDataNew cardDataNew];
  
    % read header
    PtxtOld=deblank(Ptxtall(1,:));
    fid=fopen(PtxtOld,'r+t'); % t means: open file in text mode
    hdr=[];
    for l=1:12
        pline=fgetl(fid);
        hdr=char(hdr,pline);
    end
    hdr=hdr(2:13,:);
    % write new physio txt file
    PtxtNew=[fpath filesep fname '_rep' ext];
    fid=fopen(PtxtNew,'w+t'); % CC w+ instead of r+
    for l=1:12
        pline=hdr(l,:);
        fprintf(fid,'%s\n',pline); % write header
    end
    for l=1:size(physioNew,1)
        fprintf(fid,'%d\t%d\t%d\t%d\t0\t0.0\t0.0\t0.0\t0.0\t0.0\n',physioNew(l,:));
    end
 
  %%% do the resp and card filtering (only for display)
  
  % cardiac filtering (this was copied and modified from ppt_physio_cc, section "filter
  % cardia data" (lines 766 bis 783)
    firFs = timeFreq;           % Sampling Frequency
    firN    = 128; %cardFirOrder;     % Order
    firFc1  = 2; %cardFreqLow;      % First Cutoff Frequency
    firFc2  = 4; %cardFreqHigh;     % Second Cutoff Frequency
    firFlag = 'scale';          % Sampling Flag
    % Create the window vector for the design algorithm.
    firWin = hamming( firN + 1 );
    % Calculate the coefficients using the FIR1 function.
            firB = fir1( firN, [firFc1, firFc2]/(firFs/2), 'bandpass', firWin, firFlag );
    % Returns a discrete-time filter object.
    firHd = dfilt.dffir( firB );
    cardFilt = filtfilt( firHd.Numerator, 1,  cardDataNew );  
    
  % resp filtering (this was copied and modified from ppt_physio_cc, section "function showRespFilt" (lines 662-665)
    freqFilt=[0.8 1.3];
    scaleFactor=2000;
    respSmooth =  respDataNew; %wwf took out: filtfilt( ones( 1, smoothSize ) / smoothSize, 1, respData );
    respSmooth = (respSmooth - mean( respDataNew )) / (max( respDataNew ) - min( respDataNew )) * scaleFactor;
    respvec=respSmooth;
    HR=b_filter(freqFilt(1),freqFilt(2));
    %HD=ham_highpass;
    resp_f=filtfilt(HR.numerator,1,respvec);
    respFilt=(resp_f - mean( resp_f )) / (max( resp_f ) - min( resp_f )) * scaleFactor; 
    
  ntrigadd=0;
  addtime=0;
  for ernum=1:length(trigdis_err)
        % plot the original data       
        rdat=respData(trigX(trigdis_err(ernum))-10:trigX(trigdis_err(ernum))+350);
        cdat=cardData(trigX(trigdis_err(ernum))-10:trigX(trigdis_err(ernum))+350);
        trigdif_cur=trigX(trigdis_err(ernum)+1)-trigX(trigdis_err(ernum));
        
        % plotting the physio data at the trigger problem sections
        figure(30+ernum);
%         set(h,'Position',[100,100,1049,895]);
        subplot(3,1,1);plot(rdat,'k');hold on;plot(cdat,'c');
        xlim([0 360]);
        titlecur=sprintf('%s: Trigger Distance Problem %d of %d (trigger No. %d), before repair', fname, ernum, length(trigdis_err), trigdis_err(ernum) );
        title(titlecur);
        line( [10, 10], [0, max(rdat)+10 ]); % corresponds to first trigger in this time bin
        line( [trigdif_cur+10,trigdif_cur+10], [0, max(rdat)+10] ); % corresponds to second trigger in this time bin
        line( [10+TR, 10+TR], [0, max(rdat)+10] ,'Color','r'); % corresponds to "correct" second trigger in this time bin
        line( [10+gapTPlocList(ernum,1), 10+gapTPlocList(ernum,1)], [0, 25] ,'Color','m'); % corresponds to identified "break" in physio signal
        legend('resp data','cardiac data','first trigger','second trigger','correct second trigger','timepoint of missing data')
        legend('Location','eastoutside')
        hold off
        subplot(3,1,2);plot(diff(rdat)+ max(rdat)/2,'r');hold on;plot(diff(cdat)+ max(cdat)/2,'g');
        xlim([0 360]);
        line( [10, 10], [0, max(rdat)+10 ]);
        line( [trigdif_cur+10,trigdif_cur+10], [0, max(rdat)+10] ); 
        line( [10+TR, 10+TR], [0, max(rdat)+10] ,'Color','r');
        legend ('first derivative cardiac','first derivative resp')
        legend('Location','eastoutside')
        % line( [10+gapTPlocList(ernum,1), 10+gapTPlocList(ernum,1)], [0, 25] ,'Color','m'); % corresponds to identified "break" in physio signal
        hold off;
        subplot(3,1,3);plot(diff(diff(rdat))+ max(rdat)/2,'r');hold on;plot(diff(diff(cdat))+ max(cdat)/2,'g');
        xlim([0 360]);
        line( [10, 10], [0, max(rdat)+10 ]);
        line( [trigdif_cur+10,trigdif_cur+10], [0, max(rdat)+10] ); 
        line( [10+TR, 10+TR], [0, max(rdat)+10] ,'Color','r');
        legend ('second derivative cardiac','second derivative resp')
        legend('Location','eastoutside')
        % line( [10+gapTPlocList(ernum,1), 10+gapTPlocList(ernum,1)], [0, 25] ,'Color','m'); % corresponds to identified "break" in physio signal
        hold off;
        print(gcf,'-dpsc2','-append',outps)
  % plot the corrected data
        trigTPLast=trigX(trigdis_err(ernum))+addtime;
        trigTPNext=trigX(trigdis_err(ernum)+1)+addtime;
        trigDif=trigTPNext-trigTPLast;
        tt0=trigXNew(trigdis_err(ernum)+ntrigadd); % trigger time point 1
        tt1=trigXNew(trigdis_err(ernum)+ntrigadd+1); % trigger time point 2
        tt2=trigXNew(trigdis_err(ernum)+ntrigadd+2); % trigger time point 3
        
        figure(60+ernum);
        subplot(3,1,1);plot(rdat,'k');hold on;plot(cdat,'c');
        xlim([0 360]);
        line( [10, 10], [0, max(rdat)+10 ]); % corresponds to first trigger in this time bin
        line( [trigdif_cur+10,trigdif_cur+10], [0, max(rdat)+10] ); % corresponds to second trigger in this time bin
        line( [10+TR, 10+TR], [0, max(rdat)+10] ,'Color','r'); % corresponds to "correct" second trigger in this time bin
        line( [10+gapTPlocList(ernum,1), 10+gapTPlocList(ernum,1)], [0, 25] ,'Color','m'); % corresponds to identified "break" in physio signal
        legend('resp data','cardiac data','first trigger','misplaced second trigger','correct second trigger','timepoint of missing data')
        legend('Location','eastoutside')
        hold off
        subplot(3,1,2);plot(respDataNew,'k');hold on;plot(cardDataNew,'c'); 
        xlim([tt0-10 tt2+10]);
        titlecur=sprintf('%s: Trigger Distance Problem %d of %d (trigger No. %d), after repair', fname, ernum, length(trigdis_errNew), trigdis_errNew(ernum) );
        title(titlecur);
        line( [tt0, tt0], [0, max(rdat)+10]); % corresponds to first trigger in this time bin
        line( [tt1, tt1], [0, max(rdat)+10] ); % second trigger, perhaps the added one
        line( [tt2, tt2], [0, max(rdat)+10] ); % third trigger
        line( [gapTPList(ernum), gapTPList(ernum)], [0, max(rdat)+10], 'Color','g'); % beginning of filled-in data
        line( [gapTPList(ernum)+misstimeList(ernum), gapTPList(ernum)+misstimeList(ernum)], [0, max(rdat)+10], 'Color','g'); % end of filled-in data
        legend('resp data','cardiac data','first trigger','second trigger (perhaps added)','third trigger','beginning of filled-in data','end of filled-in data')
        legend('Location','eastoutside')
        hold off
        subplot(3,1,3);plot(respFilt,'k');hold on;plot(30*cardFilt,'c'); % "*30" just to scale cardiac amplitude to resp amplitude
        xlim([tt0-10 tt2+10]);
        titlecur2='after repair and filtering';
        title(titlecur2)
        line( [tt0, tt0], [-3*max(rdat), 3*max(rdat)] ); % corresponds to first trigger in this time bin
        line( [tt1, tt1], [-3*max(rdat), 3*max(rdat)] ); % second trigger, perhaps the added one
        line( [tt2, tt2], [-3*max(rdat), 3*max(rdat)] ); % third trigger
        line( [gapTPList(ernum), gapTPList(ernum)], [-3*max(rdat), 3*max(rdat)], 'Color','g'); % beginning of filled-in data
        line( [gapTPList(ernum)+misstimeList(ernum), gapTPList(ernum)+misstimeList(ernum)], [-3*max(rdat), 3*max(rdat)], 'Color','g'); % end of filled-in data
        legend('filt resp data','filt cardiac data','first trigger','second trigger (perhaps added)','third trigger','beginning of filled-in data','end of filled-in data')
        legend('Location','eastoutside')
        hold off
        print(gcf,'-dpsc2','-append',outps)
        
        if trigDif<TR
                misstime=TR-trigDif;
        elseif trigDif>TR
                misstime=2*TR-trigDif;
                ntrigadd=ntrigadd+1;
        end
        addtime=addtime+misstime;
  end
    
    if 1==0 % if I want to repair the physio data by adding a sinus curve rather than a straight line
        % this still needs editing and testing!!!
        % resp
        respvec=respSmooth; % WWF said: I should not use smooth but Filtered!!!
        temp=diff(sign(respSmooth));
        zerocrossUp=find(temp>0);
        %problem if respSmooth=0!!!!!!!!!!!
        zerosBelow=zerocrossUp<=gaptp;
        lowerZero1=zerosBelow(end);
        lowerZero2=zerosBelow(end-1);
        lowerZero3=zerosBelow(end-2);
        zerosAbove=f0>gaptp;
        upperZero=zerosAbove(1);
        periodLength=(lowerZero3-lowerZero1)/2; % averaged over 2 periods to reduce noise (n=2 is arbitrary!)
        nMissPeriods=ceil(misstime/periodLength);
        
        lastMax=max(respSmooth(lowerZero2:lowerZero1));
        lastMin=min(respSmooth(lowerZero2:lowerZero1));
        lastAmpl=lastMax-lastMin;
        
        % add the "artificial" data
        respSmoothRepair=[respSmooth(1:lowerZero1) zeros(misstime) respSmooth(upperZero:max(respSmooth))];
        respSmoothRepair(lowerZero1:upperZero)=0.5*lastAmpl*sin(0:periodLength:2*pi);
        
        % card
        % ... should be analogous to resp
    end
    end
   
end
end

function Hd = b_filter(Fc1,Fc2) % this was copied from ppt_physio_cc.
%B_FILTER Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.9 and the Signal Processing Toolbox 6.12.
%
% Generated on: 17-May-2011 17:26:40
%

% FIR Window Bandpass filter designed using the FIR1 function.

% All frequency values are in Hz.
Fs = 100;  % Sampling Frequency

N    = 128;     % Order
if nargin < 2
    Fc1  = 2;      % First Cutoff Frequency
    Fc2  = 5% 10;       % Second Cutoff Frequency
end
flag = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = hamming(N+1);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
Hd = dfilt.dffir(b);
end

% future improvements? (CC 150415)
% - look for breaks in resp or card data (e.g. Where does abs(diff(diff) exceed its standard deviation*7) 
% this could find instances where e.g. a section is missing that happens to have length of 1 TR. 


