%% master_convert_GNG_test_jr.m
% 11/2020 Jonathan Reinwald

%% define MATLAB-path
addpath(genpath('/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/01-scripts'));

% path of rawdata
raw_path{1} = '/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/02-raw-data/01-AM/01-AM1/05-GNG_task';
raw_path{2} = '/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/02-raw-data/01-AM/01-AM2/05-GNG_task';

% path for processed data
proc_path{1} = '/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/01-AM1/02-GNG_task/';
proc_path{2} = '/zi/flstorage/group_entwbio/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/01-AM2/02-GNG_task/';

% Loop over AM1 and AM2
for i_path = 1:length(proc_path);
    % select files in raw data path
    GNG_files = getAllFiles(raw_path{i_path},'*_IDreplaced.xlsx*',1);

    % Loop over tubefiles
    for i_tube = 1:length(GNG_files)
        
        filepath = GNG_files{i_tube};
        savedir = [proc_path{i_path}]
        Convert_BehavData_Beast(filepath,savedir);
        
        %     save([proc_path filesep 'tubetestdata_' fname(1:3) '.mat'],'TubeTestData');
    end
end