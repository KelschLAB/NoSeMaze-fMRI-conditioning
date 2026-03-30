%% master_process_pupil_160TrialsRose.m
% Reinwald, Jonathan 07/2022
%

% Before running the script:
% - preprocess the videos with DeepLabCut to get the csv-files (and rest)
% for the ellipsoid --> for further information, see:
% /home/jonathan.reinwald/ICON_Autonomouse/08-README/07-Pupil_processing.odt
% and run it on taweret (or other GPU server)
% - preprocess the protocol.mat-files with /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/06-pupil/01-preprocessing/02-reappraisal/master_preprocess_protocol__reappraisal__pupil.m
% - create video and protocol_pathlist with /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/06-pupil/01-preprocessing/02-reappraisal/create_vid_and_protocol_pathlist_reappraisal_jr.m

% Info:


% clearing
clear all
clc
% close all

% Predefine folders for processed videos and protocol files
vid_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/04-pupil/05-160TrialsRose_Ephys/02-processed_videos';
protocol_mainDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/04-pupil/05-160TrialsRose_Ephys/01-processed_protocol_files';

% Load video pathlist and protocol pathlist
load(fullfile(vid_mainDir,'vid_pathlist_160TrialsRose.mat'),'vid_path_list');
load(fullfile(protocol_mainDir,'protocol_pathlist_160TrialsRose.mat'),'protocol_path_list');

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

for vid = 1:numel(vid_path_list)
    csv_curr = getAllFiles(vid_path_list{vid},'*.csv',1);
    csv_curr((contains(csv_curr,'filtered') | contains(csv_curr,'short'))) = [];
    Videolist_csv = [Videolist_csv;csv_curr];
    
    video_curr = getAllFiles(vid_path_list{vid},'*.wmv',1);
    video_curr(contains(video_curr,'short')) = [];
    Videolist = [Videolist;video_curr];
    
    h5_curr = getAllFiles(vid_path_list{vid},'*.h5',1);
    h5_curr(contains(h5_curr,'short')) = [];
    h5_curr(contains(h5_curr,'filtered')) = [];
    h5list = [h5list;h5_curr];
    
end

%%
Videolist_csv((contains(Videolist_csv,'filtered') | contains(Videolist_csv,'short') | contains(Videolist_csv,'it-0-3') | contains(Videolist_csv,'td19'))) = [];
Videolist(contains(Videolist,'short') | contains(Videolist,'plot-poses') | contains(Videolist,' - ')) = [];

%% Sanity check of pathlist and csv-list
[Videolist_csv,protocol_path_list,vid_path_list,h5list,Videolist]=checkPathLists(Videolist_csv,protocol_path_list,vid_path_list,h5list,Videolist);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 1: Fit ellipse and save in pupil_dia file
if 1==0
    likelihood_threshold = 0.95;
    pupil_dia = pupil_load_and_fit_ellipse(Videolist_csv, likelihood_threshold, vid_mainDir, plot_button);
    save(fullfile(vid_mainDir,'pupil_dia.mat'),'pupil_dia');
end
load(fullfile(vid_mainDir,'pupil_dia.mat'),'pupil_dia');
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
    save(fullfile(vid_mainDir,'pupil_dia.mat'),'pupil_dia');
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

if 1==0
    for vid=1:length(Videolist)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1. Find Starting point of the video
        [VOI_Info] = Find_StartFrame(vid_mainDir,Videolist{vid},VideoFrameRate_defined, control_button_vid, plot_button, protocol_path_list{vid});
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 2. Align all events (fv_onsets, licks) to trigTime_off
        load(protocol_path_list{vid});
        
        % trigger.trigTime_off is the off-signal from the LED
        Time2Delete=trigger.trigTimeStart_off;
        
        % load corresponding NewMat + get events ...
        fv_on = [events.fv_on];
        fv_off = [events.fv_off];
%         puff_time = [events.puff_time];
%         puff_or_not = [events.puff_or_not];
        
        % finally align events to INTAN_Info.start_vid ... loop necessary for
        % licks
        for trial = 1:numel(events)
            fv_on_align(trial) = fv_on(trial) - Time2Delete;
            fv_off_align(trial) = fv_off(trial) - Time2Delete;
%             puff_time_align(trial) = puff_time(trial) - Time2Delete;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 3. Add endpoint of the video
        VOI_Info.TimeEnd=VOI_Info.TimeBegin+sum([events.ITI_rand]);
        VOI_Info.FrameEnd=VOI_Info.FrameBegin+ceil(sum([events.ITI_rand]).*VideoFrameRate_defined)+60*10+1*10;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 4. get diameter values of interest
        %     Path_diameter = getAllFiles(Videolist{vid}, 'rw*diameter.mat',1);
        PupilDiameter = pupil_dia(vid).d_mean;
        %         PupilDiameter_scrubbed = pupil_dia_scrubbed(vid).d_mean;
        
        % extract those values which are situated in "cropped" vid ...
        index_FramesOfInterest = VOI_Info.FrameBegin:1:length(PupilDiameter);%VOI_Info.FrameEnd;%
        PupilDiameter = PupilDiameter(index_FramesOfInterest);
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
        post = 9.9; % in s; number of seconds plotted after odor stim
        window_index = [-pre:(1/VideoFrameRate_defined):post];
        
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
                DiameterMatrix(trial,i) = PupilDiameter(round(index_locFrames(i)));
                %                 DiameterMatrix_LP(trial,i) = PupilDiameter_LP(round(index_locFrames(i)));
            end
        end
        
        %% 2. Percentage Change throughout trial (values from csv file, no normalization)
        % idea: perform normalization to trial-by-trial baseline (prestim_window) ...
        
        % define window for baseline calculation ...
        baseshift = 1.9; % in s; baseline is calculated with frame all frames situated in window -baseshift : 0dorOnset (=0)
        
        % calculate baseline -> mean of all bins in baseline_window
        for trial = 1:numel(events)
            
            % get FrameOfInterest which is exactly "baseline" seconds before odor stim
            OdorFrameCur = OdorFrames(trial).Loc_OdorFrames;
            FrameBaseStart = OdorFrameCur - (baseshift*VideoFrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFrames_baseline = [FrameBaseStart:1:(FrameBaseStart+(baseshift*VideoFrameRate_defined)-1)];
            
            % calculate baseline for current trial ...
            % loop to avoid strange format problem ...
            for i = 1:numel(index_locFrames_baseline)
                BaselineValues(i) = PupilDiameter(round(index_locFrames_baseline(i)));
                %                 BaselineValues_LP(i) = PupilDiameter_LP(round(index_locFrames_baseline(i)));
            end
            
            BaselineDiameter(trial) = mean(BaselineValues);
            %             BaselineDiameter_LP(trial) = mean(BaselineValues_LP);
            
            % % % % %
            % matrix containg baseline-normalized pupil diameter values ...
            BaseDiameterMatrixSub(trial,:) = (DiameterMatrix(trial,:)-BaselineDiameter(trial))./BaselineDiameter(trial);
            BaseDiameterMatrix(trial,:) = DiameterMatrix(trial,:)./BaselineDiameter(trial);
            
            %             BaseDiameterMatrixSub_LP(trial,:) = (DiameterMatrix_LP(trial,:)-BaselineDiameter_LP(trial))./BaselineDiameter_LP(trial);
            %             BaseDiameterMatrix_LP(trial,:) = DiameterMatrix_LP(trial,:)./BaselineDiameter_LP(trial);
        end
        
        clear M
        % Spike Removal from Walter
        M(1,:,:)=BaseDiameterMatrix';
        [M_corrected, Removed] = RemovePikes_NaN_jr(M, M, 3, 4, 0);
        BaseDiameterMatrix_Corrected=squeeze(M_corrected)';
        
        summary_all(vid).OdorFramesTime = [OdorFrames.Time];
        summary_all(vid).OdorFramesLoc = [OdorFrames.Loc_OdorFrames];
        summary_all(vid).PupilDiameter = PupilDiameter;
        %         summary_all(vid).PupilDiameter_LP = PupilDiameter_LP;
        summary_all(vid).BaseDiameterMatrixSub=BaseDiameterMatrixSub;
        summary_all(vid).BaseDiameterMatrix=BaseDiameterMatrix;
        summary_all(vid).BaseDiameterMatrix_Corrected=BaseDiameterMatrix_Corrected;
        summary_all(vid).RemovedFrames=Removed;
        %         summary_all(vid).BaseDiameterMatrixSub_LP=BaseDiameterMatrixSub_LP;
        %         summary_all(vid).BaseDiameterMatrix_LP=BaseDiameterMatrix_LP;
        summary_all(vid).DiameterMatrix=DiameterMatrix;
        %         summary_all(vid).DiameterMatrix_LP=DiameterMatrix_LP;
        summary_all(vid).odor_num=[events.odor_num]';
%         summary_all(vid).puff_or_not=[events.puff_or_not]';
        
        
    end
    save(fullfile(vid_mainDir,'pupil_summary_all.mat'),'summary_all');
    
end
load(fullfile(vid_mainDir,'pupil_summary_all.mat'),'summary_all');


if 1==1
    figure(11);
    all1=[];
    for ix=[1:10];
        all1=[all1;summary_all(ix).BaseDiameterMatrix_Corrected(11:40,:)];
    end
    
    all2=[];
    for ix=[1:10];
        all2=[all2;summary_all(ix).BaseDiameterMatrix_Corrected(41:80,:)];
    end
    
    all3=[];
    for ix=[1:10];
        all3=[all3;summary_all(ix).BaseDiameterMatrix_Corrected(81:120,:)];
    end
    
    all4=[];
    for ix=[1:10];
        all4=[all4;summary_all(ix).BaseDiameterMatrix_Corrected(121:160,:)];
    end
    
    sd1=shadedErrorBar([1:size(all1,2)],nanmean(all1),SEM_calc(all1))
    sd1.mainLine.Color=[0.5 0 0];
    sd1.patch.FaceColor=[0.5 0 0];
    sd1.patch.EdgeColor='none';
    
    sd2=shadedErrorBar([1:size(all2,2)],nanmean(all2),SEM_calc(all2))
    sd2.patch.EdgeColor='none';
    sd2.mainLine.Color=[0 0 0.5];
    sd2.patch.FaceColor=[0 0 0.5];
    
    sd3=shadedErrorBar([1:size(all3,2)],nanmean(all3),SEM_calc(all3))
    sd3.patch.EdgeColor='none';
    sd3.mainLine.Color=[0 0.5 0];
    sd3.patch.FaceColor=[0 0.5 0];
    
    sd4=shadedErrorBar([1:size(all4,2)],nanmean(all4),SEM_calc(all4))
    sd4.patch.EdgeColor='none';
    sd4.mainLine.Color=[0 0 0];
    sd4.patch.FaceColor=[0.5 0.5 0.5];
    
    
    
    ax=gca; ax.YLim=[0.95,1.4];
    
    title('Pooled Data');
end

if 1==1
    color{1}=[0.5,0,0];
    color{2}=[0,0.7,0];
    color{3}=[0,0.2,0];
    color{4}=[0,0,0.5];
    
    mid_selection=zeros([120,1]);
    mid_selection(41:80,1)=1;
    for ix=1:10;
        mean_val{1}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(11:40,:));
        mean_val{2}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(41:80,:));
        mean_val{3}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(81:120,:));
        mean_val{4}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(121:160,:));
    end
    figure(12);
    for ix=[1:4];
        hold on;
        sd{ix}=shadedErrorBar([1:size(mean_val{ix},2)],nanmean(mean_val{ix}([1:10],:)),SEM_calc(mean_val{ix}([1:10],:)));
        sd{ix}.patch.EdgeColor='none';
        sd{ix}.mainLine.Color=color{ix};
        sd{ix}.mainLine.LineWidth=1.5;
        sd{ix}.patch.FaceColor=color{ix};
    end
    ax=gca;
    ax.YLim=[0.95,1.4];
    title('unscrubbed');
    
    for ix=1:10;
        mean_val{1}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(11:40,:));
        mean_val{2}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(41:80,:));
        mean_val{3}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(81:120,:));
        mean_val{4}(ix,:)=nanmean(summary_all(ix).BaseDiameterMatrix_Corrected(121:160,:));
    end
    figure(13);
    for ix=[1:4];
        hold on;
        sd{ix}=shadedErrorBar([1:size(mean_val{ix},2)],nanmean(mean_val{ix}([1:10],:)),SEM_calc(mean_val{ix}([1:10],:)));
        sd{ix}.patch.EdgeColor='none';
        sd{ix}.mainLine.Color=color{ix};
        sd{ix}.mainLine.LineWidth=1.5;
        sd{ix}.patch.FaceColor=color{ix};
    end
%     [h,p]=ttest(mean_val{1}([1,3:23],:),mean_val{4}([1,3:23],:))
    ax=gca;
    ax.YLim=[0.95,1.4];
    title('scrubbed and filtered');
end


if 1==0
    figure(4);
    subplot(1,4,1)
    for ix=1:23;
        plot(mean_val{1}(ix,:))
        hold on;
    end
    ax=gca; ax.YLim=[-0.02,0.15];
    
    subplot(1,4,2)
    for ix=1:23;
        plot(mean_val{2}(ix,:))
        hold on;
    end
    ax=gca; ax.YLim=[-0.02,0.15];
    
    subplot(1,4,3)
    for ix=1:23;
        plot(mean_val{3}(ix,:))
        hold on;
    end
    ax=gca; ax.YLim=[-0.02,0.15];
    
    subplot(1,4,4)
    for ix=1:23;
        plot(mean_val{3}(ix,:)-mean_val{1}(ix,:))
        hold on;
    end
    ax=gca; ax.YLim=[-0.02,0.15];
end


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