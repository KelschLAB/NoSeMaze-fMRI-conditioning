%% master_process_pupil_postVarenicline_ephys_2022.m
% Reinwald, Jonathan 07/2022
%

% Before running the script:
% - preprocess the videos with DeepLabCut to get the csv-files (and rest)
% for the ellipsoid --> for further information, see:
% /home/jonathan.reinwald/ICON_Autonomouse/08-README/07-Pupil_processing.odt
% and run it on taweret (or other GPU server)
% - preprocess the protocol.mat-files with /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/06-pupil/01-preprocessing/02-postVarenicline/master_preprocess_protocol__postVarenicline__pupil.m
% - create video and protocol_pathlist with /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/06-pupil/01-preprocessing/02-postVarenicline/create_vid_and_protocol_pathlist_postVarenicline_jr.m

% Info:


% clearing
clear all
clc
close all

% Predefine folders for processed videos and protocol files
vid_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/08-varenicline_ephys_2022/03-videos_pupil/post_varenicline';
protocol_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/04-pupil/08-varenicline_ephys_2022/01-processed_protocol_files/post_varenicline';

% Load video pathlist and protocol pathlist
load(fullfile(vid_mainDir,'vid_pathlist_postVarenicline_ephys_2022.mat'),'vid_path_list');
load(fullfile(protocol_mainDir,'protocol_pathlist_postVarenicline_ephys_2022.mat'),'protocol_path_list');

%
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/06-pupil/01-preprocessing'))


%% Create lists for csv/wmv and h5-files
Videolist_csv = [];
Videolist = [];
h5list = [];
plot_button = 0;
control_button_vid = 0;
filtering = 1;
VideoFrameRate_defined = 10;

% for vid = 1:numel(vid_path_list)
csv_curr = getAllFiles(vid_mainDir,'*.csv',1);
csv_curr((contains(csv_curr,'filtered') | contains(csv_curr,'short'))) = [];
Videolist_csv = [Videolist_csv;csv_curr];

video_curr = getAllFiles(vid_mainDir,'*.wmv',1);
video_curr(contains(video_curr,'short')) = [];
Videolist = [Videolist;video_curr];

h5_curr = getAllFiles(vid_mainDir,'*.h5',1);
h5_curr(contains(h5_curr,'short')) = [];
h5_curr(contains(h5_curr,'filtered')) = [];
h5list = [h5list;h5_curr];

% end

%%
Videolist_csv((contains(Videolist_csv,'filtered') | contains(Videolist_csv,'short') | contains(Videolist_csv,'it-0-3') | contains(Videolist_csv,'td19'))) = [];
Videolist(contains(Videolist,'short') | contains(Videolist,'plot-poses') | contains(Videolist,' - ')) = [];

%% Sanity check of pathlist and csv-list
% [Videolist_csv,protocol_path_list,vid_path_list,h5list,Videolist]=checkPathLists(Videolist_csv,protocol_path_list,vid_path_list,h5list,Videolist);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 1: Fit ellipse and save in pupil_dia file
if 1==0
    likelihood_threshold_pupil = 0.95;
    likelihood_threshold_lid = 0.8;
    [pupil_dia,lid_dia] = pupil_load_and_fit_ellipse_ephys_2022(Videolist_csv, Videolist, likelihood_threshold_pupil, likelihood_threshold_lid, vid_mainDir, plot_button);
    save(fullfile(vid_mainDir,'pupil_dia.mat'),'pupil_dia','lid_dia');
end
load(fullfile(vid_mainDir,'pupil_dia.mat'),'pupil_dia','lid_dia');
% % % STEP 1: Alternative from Mirko
if 1==0
    %% Load DLC-output data and calculate diameters.
    likelihood_threshold = 0.95;
    %8point
    pupil_dia_alt = pupil_load_and_get_diameter(Videolist_csv, likelihood_threshold, vid_mainDir); %pupil_load_and_fit_ellipse(Videolist_csv, likelihood_threshold, savedir);
    save(fullfile(vid_mainDir,'pupil_dia_alt.mat'),'pupil_dia_alt');
end
% % % load(fullfile(vid_mainDir,'pupil_dia_alt.mat'),'pupil_dia_alt');
if 1==0
    for ix=1:length(pupil_dia)
        idx=find(pupil_dia(ix).d_mean < (nanmean(pupil_dia(ix).d_mean)-3.*nanstd(pupil_dia(ix).d_mean)) | pupil_dia(ix).d_mean > (nanmean(pupil_dia(ix).d_mean)+3.*nanstd(pupil_dia(ix).d_mean)));
        [fdir,~,~]=fileparts(protocol_path_list{ix});[~,fname,~]=fileparts(fdir);
        disp(['For ' fname ' ' num2str(length(idx)) ' timepoints extended the range of mean +/- 3*STD and are set to NaN']);
        pupil_dia(ix).d_mean(idx)=NaN;
    end
    save(fullfile(vid_mainDir,'pupil_dia.mat'),'pupil_dia','lid_dia');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: Scrubbing of pupil_dia file
if 1==0
    plotter=0;
    pupil_dia_scrubbed = pupil_scrubbing(Videolist_csv, pupil_dia, vid_mainDir,plotter);
    save(fullfile(vid_mainDir,'pupil_dia_scrubbed.mat'),'pupil_dia_scrubbed');
end
% % % load(fullfile(vid_mainDir,'pupil_dia_scrubbed.mat'),'pupil_dia_scrubbed');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Alignment

if 1==1
    for vid=1:length(Videolist)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1. Find Starting point of the video
        [VOI_Info] = Find_StartFrame(vid_mainDir,Videolist{vid},VideoFrameRate_defined, control_button_vid, plot_button, protocol_path_list{vid});
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2. Align all events (fv_onsets, licks) to trigTime_off
        load(protocol_path_list{vid});
        
        % trigger.trigTime_off is the off-signal from the LED
        Time2Delete=trigger.trigTimeStart_off;
        
        clear fv_on fv_off fv_on_align fv_off_align laser_on laser_off laser_on_align laser_off_align
        % load corresponding NewMat + get events ...
        for trial = 1:numel(events)
            if isempty(events(trial).fv_on)
                events(trial).fv_on = nan;
                events(trial).fv_off = nan;
            end
            if isempty(events(trial).laser_on)
                events(trial).laser_on = nan;
                events(trial).laser_off = nan;
            end
        end
            
        fv_on = [events.fv_on];
        fv_off = [events.fv_off];
        laser_on = [events.laser_on];
        laser_off = [events.laser_off];
        %         puff_time = [events.puff_time];
        %         puff_or_not = [events.puff_or_not];
        
        % finally align events to INTAN_Info.start_vid ... loop necessary for
        % licks
        for trial = 1:numel(events)
            if ~isnan(fv_on(trial))
                fv_on_align(trial) = fv_on(trial) - Time2Delete;
                fv_off_align(trial) = fv_off(trial) - Time2Delete;
            elseif ~isnan(laser_on(trial))
                fv_on_align(trial) = laser_on(trial) - Time2Delete;
                fv_off_align(trial) = laser_off(trial) - Time2Delete;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 3. Add endpoint of the video
        VOI_Info.TimeEnd=VOI_Info.TimeBegin+sum([events.ITI_rand]);
        VOI_Info.FrameEnd=VOI_Info.FrameBegin+ceil(sum([events.ITI_rand]).*VideoFrameRate_defined)+60*10+1*10;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. get diameter values of interest
        %     Path_diameter = getAllFiles(Videolist{vid}, 'rw*diameter.mat',1);
        
        clear PupilDiameter LidDiameter index_FramesOfInterest
        PupilDiameter = pupil_dia(vid).d_mean;
        LidDiameter = lid_dia(vid).d_mean;
        PupilMovement = [0;sqrt((diff(pupil_dia(vid).d_X0)).^2 +  (diff(pupil_dia(vid).d_Y0)).^2)];

        %         PupilDiameter_scrubbed = pupil_dia_scrubbed(vid).d_mean;
        
        % extract those values which are situated in "cropped" vid ...
        index_FramesOfInterest = VOI_Info.FrameBegin:1:length(PupilDiameter);%VOI_Info.FrameEnd;%
        PupilDiameter = PupilDiameter(index_FramesOfInterest);
        LidDiameter = LidDiameter(index_FramesOfInterest);
        PupilMovement = PupilMovement(index_FramesOfInterest);
        %         PupilDiameter_scrubbed = PupilDiameter_scrubbed(index_FramesOfInterest);
        
        % %         % lowpass filter
        % %         N = 2;
        % %         F3dB = 0.15; % [pi*rad/sample] (pi*rad==1/2cycle => Frequency/[sample_rate/2] == F3dB)
        % %         % lowpass filter
        % %         h = fdesign.lowpass('N,F3dB',N,F3dB);
        % %         d1 = design(h,'butter');
        % %         addpath(genpath('/opt/matlab/R2020a/toolbox/signal/signal/'));
        % %         pupil_dia_scrubbed(vid).d_mean_lp = filtfilt(d1.sosMatrix,d1.ScaleValues,PupilDiameter_scrubbed); % low pass filter ...
        % %         LP_params = ['fdesign.lowpass(N,F3dB,' num2str(N) ',' num2str(F3dB) ') d1 = design(h,butter)'];
        % %         PupilDiameter_LP = pupil_dia_scrubbed(vid).d_mean_lp;
        
        % Despiking algorithm from https://de.mathworks.com/matlabcentral/fileexchange/15361-despiking
        % Input
        %   fi     : input data with dimension (n,1)
        %   i_plot : =9 plot results (optional)
        %   i_opt : = 0 or not specified  ; return spike noise as NaN
        %           = 1            ; remove spike noise and variable becomes shorter than input length
        %           = 2            ; interpolate NaN using cubic polynomial
        %         [PupilDiameter_LP, ip] = func_despike_phasespace3d( PupilDiameter, 0, 0);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 5. assign fv_onsets to video frames (= OdorFrames)...
        % -> find video frame which is nearest to current fv_onset
        clear fv_on_align_cur OdorFrames
        
        FrameDur = 1/VideoFrameRate_defined;
        for trial = 1:numel(events)
            % get current onset ...
            fv_on_align_cur = fv_on_align(trial);
            
            % find correspondent frame in vid ...
            OdorFrames(trial).Time = round(fv_on_align_cur/FrameDur)*FrameDur;
            OdorFrames(trial).Loc_OdorFrames = OdorFrames(trial).Time/FrameDur;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Create TrialDiameterMatrix ...
        % TrialDiameterMatrix is a matrix containing all diameter data aligned to
        % fv_onsets / for all trials / different event types parsed later ...
        % rows = trials ...
        % columns = frames ...
        % values = corresponding diameters ...
        
        % define window of interest for pupil analysis
        pre = 1.9; % in s; number of seconds plotted before odor stim
        post = 4.9; % in s; number of seconds plotted after odor stim
        window_index = [-pre:(1/VideoFrameRate_defined):post];
        
        clear OdorFrameCur FramePre index_locFrames PupilDiameterMatrix LidDiameterMatrix
        
        % create matrix ...
        for trial = 1:numel(events)
            
            % get FrameOfInterest which is exactly "pre" seconds before odor stim
            OdorFrameCur = OdorFrames(trial).Loc_OdorFrames;
            FramePre = OdorFrameCur - (pre*VideoFrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFrames = [FramePre:1:(FramePre+numel(window_index)-1)];
            
            % write rows in matrix ...
            % PupilDiameter_LP = lowpass filtered data ...
            % alternative: DiameterMatrix(trial,[1:numel(window_index)]) = PupilDiameter_LP(index_locFrames);
            % i would have preferred this single line, but there is a problem
            % in the data format -> quick solution: round incides ...
            for i = 1:numel(window_index)
                PupilDiameterMatrix(trial,i) = PupilDiameter(round(index_locFrames(i)));
                LidDiameterMatrix(trial,i) = LidDiameter(round(index_locFrames(i)));
                PupilMovementMatrix(trial,i) = PupilMovement(round(index_locFrames(i)));
                %                 DiameterMatrix_LP(trial,i) = PupilDiameter_LP(round(index_locFrames(i)));
            end
        end
        
        %% 2. Percentage Change throughout trial (values from csv file, no normalization)
        % idea: perform normalization to trial-by-trial baseline (prestim_window) ...
        
        % define window for baseline calculation ...
        baseshift = 1.9; % in s; baseline is calculated with frame all frames situated in window -baseshift : 0dorOnset (=0)
        
        % calculate baseline -> mean of all bins in baseline_window
        clear PupilBaseDiameterMatrixSub PupilBaseDiameterMatrix BaselineValues OdorFrameCur FrameBaseStart PupilBaseDiameterMatrix_Corrected

        for trial = 1:numel(events)
            
            % get FrameOfInterest which is exactly "baseline" seconds before odor stim
            OdorFrameCur = OdorFrames(trial).Loc_OdorFrames;
            FrameBaseStart = OdorFrameCur - (baseshift*VideoFrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFrames_baseline = [FrameBaseStart:1:(FrameBaseStart+(baseshift*VideoFrameRate_defined)-1)];
            
            % calculate baseline for current trial ...
            % loop to avoid strange format problem ...
            for i = 1:numel(index_locFrames_baseline)
                PupilBaselineValues(i) = PupilDiameter(round(index_locFrames_baseline(i)));
                LidBaselineValues(i) = LidDiameter(round(index_locFrames_baseline(i)));
                PupilMovementBaselineValues(i) = PupilMovement(round(index_locFrames_baseline(i)));                
            end
            
            PupilBaselineDiameter(trial) = mean(PupilBaselineValues);
            LidBaselineDiameter(trial) = mean(LidBaselineValues);
            PupilBaselineMovement(trial) = mean(PupilMovementBaselineValues);
            
            % % % % %
            % matrix containg baseline-normalized pupil diameter values ...
            PupilBaseDiameterMatrixSub(trial,:) = (PupilDiameterMatrix(trial,:)-PupilBaselineDiameter(trial))./PupilBaselineDiameter(trial);
            PupilBaseDiameterMatrix(trial,:) = PupilDiameterMatrix(trial,:)./PupilBaselineDiameter(trial);
            
            LidBaseDiameterMatrixSub(trial,:) = (LidDiameterMatrix(trial,:)-LidBaselineDiameter(trial))./LidBaselineDiameter(trial);
            LidBaseDiameterMatrix(trial,:) = LidDiameterMatrix(trial,:)./LidBaselineDiameter(trial);
            
            PupilBaseMovementMatrixSub(trial,:) = (PupilMovementMatrix(trial,:)-PupilBaselineMovement(trial))./PupilBaselineMovement(trial);
            PupilBaseMovementMatrix(trial,:) = PupilMovementMatrix(trial,:)./PupilBaselineMovement(trial);
        end
        
        clear M
        % Spike Removal from Walter
        abs_thresh=nan;
        M(1,:,:)=PupilBaseDiameterMatrix';
        [M_corrected, Removed_Pupil] = RemovePikes_NaN_jr(M, M, 3, 4, 0, abs_thresh);
        PupilBaseDiameterMatrix_Corrected=squeeze(M_corrected)';
        
        clear M
        % Spike Removal from Walter
        M(1,:,:)=LidBaseDiameterMatrix';
        [M_corrected, Removed_Lid] = RemovePikes_NaN_jr(M, M, 3, 4, 0, abs_thresh);
        LidBaseDiameterMatrix_Corrected=squeeze(M_corrected)';
        
        clear M
        % Spike Removal from Walter
        M(1,:,:)=PupilMovementMatrix';
        [M_corrected, Removed_PupilMovement] = RemovePikes_NaN_jr(M, M, 20, 4, 0, abs_thresh);
        PupilMovementMatrix_Corrected=squeeze(M_corrected)';
        
        clear M
        % Spike Removal from Walter
        M(1,:,:)=PupilBaseMovementMatrix';
        [M_corrected, Removed_PupilMovementBase] = RemovePikes_NaN_jr(M, M, 20, 4, 0, abs_thresh);
        PupilBaseMovementMatrix_Corrected=squeeze(M_corrected)';
        
        summary_all(vid).OdorFramesTime = [OdorFrames.Time];
        summary_all(vid).OdorFramesLoc = [OdorFrames.Loc_OdorFrames];
        summary_all(vid).PupilDiameter = PupilDiameter;
        summary_all(vid).LidDiameter = LidDiameter;

        %         summary_all(vid).PupilDiameter_LP = PupilDiameter_LP;
        summary_all(vid).PupilBaseDiameterMatrixSub=PupilBaseDiameterMatrixSub;
        summary_all(vid).PupilBaseDiameterMatrix=PupilBaseDiameterMatrix;
        summary_all(vid).PupilBaseDiameterMatrix_Corrected=PupilBaseDiameterMatrix_Corrected;

        summary_all(vid).LidBaseDiameterMatrixSub=LidBaseDiameterMatrixSub;
        summary_all(vid).LidBaseDiameterMatrix=LidBaseDiameterMatrix;
        summary_all(vid).LidBaseDiameterMatrix_Corrected=LidBaseDiameterMatrix_Corrected;
        
        summary_all(vid).PupilBaseMovementMatrixSub=PupilBaseMovementMatrixSub;
        summary_all(vid).PupilBaseMovementMatrix=PupilBaseMovementMatrix;
        summary_all(vid).PupilBaseMovementMatrix_Corrected=PupilBaseMovementMatrix_Corrected;

        summary_all(vid).RemovedFrames_Pupil=Removed_Pupil;
        summary_all(vid).RemovedFrames_Lid=Removed_Lid;

        summary_all(vid).PupilDiameterMatrix=PupilDiameterMatrix;
        summary_all(vid).LidDiameterMatrix=LidDiameterMatrix;
        summary_all(vid).PupilMovementMatrix=PupilMovementMatrix;
        summary_all(vid).PupilMovementMatrix_Corrected=PupilMovementMatrix_Corrected;

        summary_all(vid).odor_num=[events.odor_num]';
        %         summary_all(vid).puff_or_not=[events.puff_or_not]';
        
        
    end
    save(fullfile(vid_mainDir,'pupil_summary_all.mat'),'summary_all');
    
end
load(fullfile(vid_mainDir,'pupil_summary_all.mat'),'summary_all');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Videolist_csv,protocol_path_list,vid_path_list,h5list,Videolist]=checkPathLists(Videolist_csv,protocol_path_list,vid_path_list,h5list,Videolist)
%% Check length of vid and protocol pathlist
if length(Videolist_csv) < length(protocol_path_list)
    clear to_delete
    counter=1;
    for pid=1:length(protocol_path_list)
        idx_animal = strfind(protocol_path_list{pid},'d');
        animal_name = protocol_path_list{pid}(idx_animal:(idx_animal+length('d')+1));
        if sum(contains(Videolist_csv,animal_name)) == 1
            display(['-> correct: ' animal_name ' has been found in protocol_path_list and Videolist_csv']);
        elseif sum(contains(Videolist_csv,animal_name)) == 0
            display(['-> missing: ' animal_name ' in Videolist_csv is missing']);
            warningMsg = ['-> missing: ' animal_name ' in Videolist_csv is missing and will be deleted in protocol_path_list'];
            to_delete(counter)=pid;
            counter=counter+1;
            waitfor(msgbox(warningMsg));
        elseif sum(contains(Videolist_csv,animal_name)) > 1
            warningMsg = ['-> incorrect number: ' animal_name ' more than once in Videolist_csv'];
            waitfor(msgbox(warningMsg));
        end
    end
    if length(vid_path_list)==length(protocol_path_list)
        protocol_path_list(to_delete)=[];
        vid_path_list(to_delete)=[];
    else
        protocol_path_list(to_delete)=[];
    end
    
    if length(Videolist_csv) == length(protocol_path_list)
        warningMsg = ['length of videolist and pathlist are now correct'];
        waitfor(msgbox(warningMsg));
    else
        error(['ERROR: length of videolist and pathlist are incorrect'])
    end
    
elseif length(vid_path_list) > length(protocol_path_list)
    clear to_delete
    counter=1;
    for vid=1:length(Videolist_csv)
        idx_animal = strfind(Videolist_csv{vid},'animal_');
        animal_name = Videolist_csv{vid}(idx_animal:(idx_animal+length('animal_')+1));
        if sum(contains(protocol_path_list,animal_name)) == 1
            display(['-> correct: ' animal_name ' has been found in protocol_path_list and Videolist_csv']);
        elseif sum(contains(protocol_path_list,animal_name)) == 0
            display(['-> missing: ' animal_name ' in protocol_path_list is missing']);
            warningMsg = ['-> missing: ' animal_name ' in protocol_path_list is missing and now deleted in Videolist_csv'];
            Videolist_csv(vid)=[];
            waitfor(msgbox(warningMsg));
            to_delete(counter)=vid;
            counter=counter+1;
        elseif sum(contains(protocol_path_list,animal_name)) > 1
            warningMsg = ['-> incorrect number: ' animal_name ' more than once in protocol_path_list'];
            waitfor(msgbox(warningMsg));
        end
    end
    Videolist_csv(to_delete)=[];
    h5list(to_delete)=[];
    Videolist(to_delete)=[];
    if length(Videolist_csv) == length(protocol_path_list)
        warningMsg = ['length of videolist and pathlist are now correct'];
        waitfor(msgbox(warningMsg));
    else
        error(['ERROR: length of videolist and pathlist are incorrect'])
    end
end
end