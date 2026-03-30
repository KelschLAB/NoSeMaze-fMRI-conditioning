function extractDigitalTrialInformation(inputDir)
%% Converts rhd to digital and re-references trialtimes to first collected volume
% input rootdir should be \\*\session-dir\Intan\
if nargin == 0
    inputDir = uigetdir;
    inputDir = [inputDir,'\'];
end

%% get all rhds and mats
protocollist=getAllFiles(inputDir, '*protocol.mat', 1);
diglist=getAllFiles(inputDir, '*digital.mat',1);

% if there is no digital file, convert from .rhd
if isempty(diglist) || isempty(protocollist)
    error('Please select a directory that contains the protocol-file and the already converted digital.mat files');
end

load(protocollist{1,1});
load(diglist{1,1});

%% get trialinformation

% trial-onsets
try
    % parse Trial start time
    trial_on=find(diff(dchannels(:,3))==1)/sample_rate;
    trial_off=find(diff(dchannels(:,3))==-1)/sample_rate;
    trial_dur=trial_off-trial_on;
    % remove wrong timepoints
    ToDelete= find( trial_dur < 2);
    trial_on(ToDelete)= [];
    trial_off(ToDelete)= [];
    %sanity checks
    if numel(trial_on) ~= numel(trial_off)
        error('Unequal number of trial on and off');
    elseif numel(trial_on) ~= size(session.trialmatrix,2)
        error('Unequal number of trials and trial on');
    end
    % parse event-times info to trialmatrix
    for t = 1:size(session.trialmatrix,2)
        session.trialmatrix(t).trial_on = trial_on(t);
        session.trialmatrix(t).trial_off = trial_off(t);
    end
catch
   warning('Some problem with trial_onset extraction'); 
end

% if laser-cases
if any([session.trialmatrix.laser_pattern] ~= 0)
   laser_on = round(find(diff(dchannels(:,1)) == 1)/sample_rate*1000,1); %in msec    
   laser_off = round(find(diff(dchannels(:,1)) == -1)/sample_rate*1000,1); %in msec
   laser_dur = round(laser_off-laser_on);
   
   % remove wrong signals
   ToDelete= find( laser_dur > 5.5 | laser_dur < 4.5);
   laser_on(ToDelete)= [];
   laser_off(ToDelete)= [];
   
   % sanity-check if laser stims are divisible by 60
   if mod(numel(laser_on),60) ~= 0 || mod(numel(laser_off),60) ~= 0
       warning('something is wrong with laser trials');
   end
   
   % parse referenced time info to trialmatrix
   for t = 1:nnz([session.trialmatrix.laser_pattern] == 1)
      session.trialmatrix(t).trial_onset_ref = laser_on(2+60*(t-1))/1000-ref;
      session.trialmatrix(t).first_volume_after_trial_on = floor(session.trialmatrix(t).trial_onset_ref/TR);
   end
   
end

% if odor cases
if any([session.trialmatrix.odor_num] > 0)
    fv_on=find(diff(dchannels(:,2))==1)/sample_rate;
    fv_off=find(diff(dchannels(:,2))==-1)/sample_rate;
    fv_dur=fv_off-fv_on;
    
    % remove false signals detected..
    ToDelete= find( fv_dur >1.05 | fv_dur < 0.95);
    fv_on(ToDelete)= [];
    fv_off(ToDelete)= [];
    fv_dur(ToDelete)= [];
        
    %sanity checks
    if numel(fv_on) ~= numel(fv_off)
        error('Unequal number of final valve on and off');
    elseif numel(fv_on) ~= nnz([session.trialmatrix.odor_num]>0)
        error('Unequal number of final valve and odor-trials');
    end
    
    % parse event-times info to trialmatrix
    for t = 1:nnz([session.trialmatrix.odor_num] > 1)
        session.trialmatrix(t).fv_on = fv_on(t);
        session.trialmatrix(t).fv_off = fv_off(t);
    end
    
end

save(protocollist{1,1},'session');


end

function fileList = getAllFiles(dirName, fileExtension, appendFullPath)

  dirData = dir([dirName '/' fileExtension]);      %# Get the data for the current directory
  dirWithSubFolders = dir(dirName);
  dirIndex = [dirWithSubFolders.isdir];  %# Find the index for directories
  fileList = {dirData.name}';  %'# Get a list of the files
  if ~isempty(fileList)
    if appendFullPath
      fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
    end
  end
  subDirs = {dirWithSubFolders(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir, fileExtension, appendFullPath)];  %# Recursively call getAllFiles
  end

end
