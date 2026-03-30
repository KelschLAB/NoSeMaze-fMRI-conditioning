function[Diff]=LicksAligned(StartTime,LickTime);

%StartTime='14:46:39.742656';
%LickTime=[1.446402691280000e+11,1.446403341280000e+11,1.446403881280000e+11,1.446405681280000e+11,1.446413351280000e+11,1.446413901280000e+11,1.446415061280000e+11,1.446426811280000e+11,1.446430611280000e+11,1.446431601280000e+11];

%%convert string to number%% 
StartTime=replace(StartTime,':','');
StartTime=replace(StartTime,'.','');
StartTime=replace(StartTime,'|',' ');
StartTimeN=str2num(StartTime);

%%extract the hours and change them in Seconds%% 
StartTimeH=StartTimeN/10000000000;
StartTimeH=fix(StartTimeH);
StartTimeH2s=StartTimeH*3600;

%%extract the minutes and change them in Seconds%%
StartTimeM=StartTimeN-StartTimeH*10000000000;
StartTimeM=StartTimeM/100000000;
StartTimeM=fix(StartTimeM);
StartTimeM2s=StartTimeM*60;

%%extract the seconds%%
StartTimeS=StartTimeN-StartTimeH*10000000000-StartTimeM*100000000;
StartTimeS=StartTimeS/1000000;

%%sum up hours, minutes and seconds%% 
StartTimeSek=StartTimeH2s+StartTimeM2s+StartTimeS;

%%extract the hours and change them to seconds%% 
LickTimeH=LickTime/10000000000;
LickTimeH=fix(LickTimeH);
LickTimeH2s=LickTimeH*3600;

%%extract the minutes and change them to seconds%% 
LickTimeM=LickTime-LickTimeH*10000000000;
LickTimeM=LickTimeM/100000000;
LickTimeM=fix(LickTimeM);
LickTimeM2s=LickTimeM*60;

%%extract the seconds%%
LickTimeS=LickTime-LickTimeH*10000000000-LickTimeM*100000000;
LickTimeS=LickTimeS/1000000;

%%sum up hours, minutes and seconds%% 
LickTimeSek=LickTimeH2s+LickTimeM2s+LickTimeS;

%%calculate the difference between StartTime and LickTime%% 
Diff=LickTimeSek-StartTimeSek;
end %of function
