function addExtractBrain
%% get the location of this file
d = fileparts(which(mfilename)); % mfilename returns the name (including path) of this function
% add the path
p = [d filesep 'ms_extractBrain'];
fprintf('Adding path %s\n', p);
addpath(p)