%% DLC-Pupil analysis for 8-point ellipse tracking
% 06,2020 David Wolf


%% set directories
% maindir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\Videos\20200130_TD19_EPhys'; if ~isdir(maindir), mkdir(maindir); end% all videos in maindir get processed ...
% videodir= maindir;
% DigDir='E:\DATA\TD\20200130_TD19_EPhys';
% NewDir='E:\DATA\TD\20200130_TD19_EPhys';
% addpath(cd);
% a. get all video files saved in maindir ...

savedir = 'E:\DATA\TD\20200130_TD19_EPhys'; if ~isdir(savedir), mkdir(savedir); end
csv_dir = '\\zifnas\entwbio\Carla\csv_files';
Videolist_csv = getAllFiles(csv_dir,'td*.csv',1);
% cd(csv_dir)
% Videolist_csv1 = dir('A00*.csv');
% cd(savedir);

%% Load DLC-output data and fit ellipse to the pupil to estimate area.
likelihood_threshold = 0.95;
pupil_dia = pupil_load_and_fit_ellipse(Videolist_csv, likelihood_threshold, savedir);

%% Scrub (interpolate) data where missing because of low likelihood pose estimation
pupil_dia_scrubbed = pupil_scrubbing(pupil_dia);

%% Align to Intan by finding LED sync stims


