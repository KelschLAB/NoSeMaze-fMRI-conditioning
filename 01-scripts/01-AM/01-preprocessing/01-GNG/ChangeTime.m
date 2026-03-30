function[Diff]=ChangeTime(StartTime,LickTime)
%StartTime='13:56:39.976294'
%LickTime='13:56:40.007294'

%convert string to number 
StartTime=replace(StartTime,':','');
StartTime=replace(StartTime,'.','');
StartTime=replace(StartTime,'|',' ');
StartTimeN=str2num(StartTime);

%extract the hours and change them in Seconds 
StartTimeH=StartTimeN/10000000000;
StartTimeH=fix(StartTimeH);
StartTimeH2s=StartTimeH*3600;

%extract the minutes and change them in Seconds
StartTimeM=StartTimeN-StartTimeH*10000000000;
StartTimeM=StartTimeM/100000000;
StartTimeM=fix(StartTimeM);
StartTimeM2s=StartTimeM*60;

%extract the seconds
StartTimeS=StartTimeN-StartTimeH*10000000000-StartTimeM*100000000;
StartTimeS=StartTimeS/1000000;

%sum up hours, minutes and seconds 
StartTimeSek=StartTimeH2s+StartTimeM2s+StartTimeS;


%convert string to number
LickTime=replace(LickTime,':','');
LickTime=replace(LickTime,'.','');
LickTime=replace(LickTime,'|',' ')
LickTimeN=str2num(LickTime);

%extract the hours and change them to seconds 
LickTimeH=LickTimeN/10000000000;
LickTimeH=fix(LickTimeH);
LickTimeH2s=LickTimeH*3600;

%extract the minutes and change them to seconds 
LickTimeM=LickTimeN-LickTimeH*10000000000;
LickTimeM=LickTimeM/100000000;
LickTimeM=fix(LickTimeM);
LickTimeM2s=LickTimeM*60;

%extract the seconds
LickTimeS=LickTimeN-LickTimeH*10000000000-LickTimeM*100000000;
LickTimeS=LickTimeS/1000000;

%sum up hours, minutes and seconds 
LickTimeSek=LickTimeH2s+LickTimeM2s+LickTimeS;

%calculate the difference between StartTime and LickTime 
Diff=LickTimeSek-StartTimeSek;
end %function
