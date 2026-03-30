function [session_bundle, rhd_path] = BundleSession(rhd_files, rhd_path)
% rhd-files have to be in the same path. files get bundled as a session (a
% cell struct in a cell of a cell struct) if they are from the same animal
% and same day (so only one session per day!)

if nargin == 0
    rawDataDir_start = 'D:\ms';
    [rhd_files, rhd_path, ~] = uigetfile('*.rhd','Select an RHD2000 Data File', rawDataDir_start, 'MultiSelect', 'on');
end

if iscell(rhd_files)
else
    rhd_files={rhd_files};
end

session_files=cellfun(@(x) (x(1:10)), rhd_files, 'UniformOutput', false);
[~,~, session_map]=unique(session_files);

for i=1:length(unique(session_map))

    session_bundle{i}= rhd_files(session_map==i);
    
end

end