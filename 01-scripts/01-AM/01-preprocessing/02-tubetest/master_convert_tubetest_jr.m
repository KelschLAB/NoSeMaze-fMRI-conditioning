%% master_convert_tubetest_jr.m
% 11/2020 Jonathan Reinwald

%% define MATLAB-path
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts'));

% path of rawdata
raw_path{1} = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/01-AM/01-AM1/04-tubetest';
raw_path{2} = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/02-raw-data/01-AM/02-AM2/04-tubetest';

% path for processed data
proc_path{1} = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/01-AM1/01-tubetest';
proc_path{2} = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/02-AM2/01-tubetest';

% Loop over AM1 and AM2
for i_path=1:length(proc_path);
    % select files in raw data path
    tubefiles = getAllFiles(raw_path{i_path},'*.csv*',1);

    % Loop over tubefiles
    for i_tube = 1:length(tubefiles)
        
        filepath = tubefiles{i_tube};
        TubeTestData = Convert_TubeTest_Data_JR(filepath);
        
        [fpath,fname,ext]=fileparts(filepath);
        save([proc_path filesep 'tubetestdata_' fname(1:3) '.mat'],'TubeTestData');
    end
end