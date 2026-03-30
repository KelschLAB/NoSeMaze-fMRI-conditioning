function d = load_pupil_dia(sessions_of_interest,vid_path_list,d)
%% Loads DLC output and performs ellipse fit, then aligns to Intan and stores to d

%%
sessions_of_interest(cellfun(@isempty,{sessions_of_interest.vid_path})) = [];

if ~isfield(d.clust_params,'proc_path')
    [proc_path_list,vid_path_list] = getCompatibleProcAndVidPath(sessions_of_interest);
else
    if isunix
        error('procpath transformation on linux not yet implemented')
    else
        proc_path_list = {sessions_of_interest.proc_path};
    end
end
%%
Videolist_csv = [];
Videolist = [];
Diglist = [];
h5list = [];
plot_button = 0;
filtering = 1;

for vid = 1:numel(vid_path_list)
    csv_curr = getAllFiles(vid_path_list{vid},'*.csv',1);
    %     csv_curr((contains(csv_curr,'filtered') | contains(csv_curr,'short'))) = [];
    Videolist_csv = [Videolist_csv;csv_curr];
    
    video_curr = getAllFiles(vid_path_list{vid},'*.wmv',1);
    %     video_curr(contains(video_curr,'short')) = [];
    Videolist = [Videolist;video_curr];
    
    h5_curr = getAllFiles(vid_path_list{vid},'*.h5',1);
    %     video_curr(contains(video_curr,'short')) = [];
    h5list = [h5list;h5_curr];
    
    dig_current = getAllFiles(proc_path_list{vid},'*digital.mat',1);
    Diglist = [Diglist; dig_current];
    if isempty(dig_current)
        warningMsg = ['->missing:' proc_path_list{vid}];
        waitfor(msgbox(warningMsg));
    end
end
%%
% Videolist_csv((contains(Videolist_csv,'filtered') | contains(Videolist_csv,'short') | contains(Videolist_csv,'it-0-3') | contains(Videolist_csv,'8point'))) = [];
Videolist_csv((contains(Videolist_csv,'filtered') | contains(Videolist_csv,'short') | contains(Videolist_csv,'it-0-3') | contains(Videolist_csv,'td19'))) = [];
Videolist(contains(Videolist,'short') | contains(Videolist,'plot-poses')) = [];
checkVidPathLists(Videolist,Videolist_csv,Diglist)

savedir = [];%'\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\TD19\DATA\Videos\DLC'; if ~isdir(savedir), mkdir(savedir); end
% csv_dir = 'F:\Mirko\Pupil\eightpoint_refined';
% vid_dir = '\\zi\flstorage\dep_psychiatrie_psychotherapie\group_entwbio\data\Mirko\TD19\DATA\VidShortCut2';
% dig_dir = 'F:\Mirko\\DATA\DONE';
% Videolist_csv = getAllFiles(csv_dir,'td*.csv',1);
% Videolist_csv = Videolist_csv(~contains(Videolist_csv,{'short' 'filtered'})); %getAllFiles(csv_dir,'td*.csv',1);

% cd(csv_dir)
% Videolist_csv1 = dir('A00*.csv');
% cd(savedir);


%% loop
for vx = 1:numel(Videolist)
    try
        %% Load DLC-output data and calculate diameters.
        likelihood_threshold = 0.95;
        %8point
        pupil_dia = pupil_load_and_get_diameter(Videolist_csv(vx), likelihood_threshold, savedir); %pupil_load_and_fit_ellipse(Videolist_csv, likelihood_threshold, savedir);
        %4point
        % pupil_dia = pupil_load_and_get_diameter_4point(Videolist_csv, likelihood_threshold, savedir,plot_button);
        %% cut video to session length indicated by IR-triggers
        % ##!! does not work..
        pupil_dia.ipoints=[];
        % save workspace.mat;
        % max_outlier = 1000.000;
        % [pupil_dia_cut, pupil_dia] = pupil_cut(Videolist_csv,pupil_dia,max_outlier);
        
        % ### from here:
        % CHECK take frame_idx out of align_info to cut dia and outliers
        % CHECK put pupil_dia_cut and pupil_dia_cut_corr together
        % - CAVE when cut, idx for oulier_frames might be wrong... --> should be no problem, as outlier idx isnt saved anyways
        
        %% remove clipping outliers that are biologically absurd but
        % were not assigned with a low probability in deep lab cut
        [pupil_dia.d_mean,pupil_dia.outliers,pupil_dia.numb_outliers] = cut_clip_peaks(pupil_dia.d_mean,pupil_dia.outliers,sessions_of_interest(vx),plot_button);
        
        %% Scrub and filter
        % no differrence between scripts concerning 4 or 8point, but 4point script
        % also performs highpass an bandpass filter
        %8point
        % [pupil_dia_corr,N,F3dB] = pupil_scrubbing(Videolist_csv, pupil_dia, savedir,plot_button);
        %4point
        [pupil_dia_corr,filt_info] = pupil_scrubbing_4point(Videolist_csv(vx), pupil_dia, savedir,plot_button,filtering);
        
        % save workspace.mat;
        %% Intan Align
        % get saved [fvon(1) fvoff(last)] for videos
        for vxx = 1:numel(vx)
           parStartEnd(vxx,1) = d.events{sessions_of_interest(vx(vxx)).idx}(1).fv_on_odorcue;
           parStartEnd(vxx,2) = d.events{sessions_of_interest(vx(vxx)).idx}(end).reward_time;
        end
        FrameRate_defined = 10;
        align_info = VidIntanAlign(Videolist(vx),Diglist(vx),pupil_dia,vid_path_list,FrameRate_defined,parStartEnd,plot_button);%,align_info);
        
        
        % check if video end is at least 6s after last reward time. Relevant for sessions with only 1 IR trigger
        vidEnd = align_info.intan_Time2Delete+diff(align_info.video_startTILend)/FrameRate_defined;
        parEnd = d.events{sessions_of_interest(vx).idx}(end).reward_time+6;
        if vidEnd < parEnd
            warning('Video ends to soon! We change video end to cover last trial as well')
            align_info.video_startTILend(2) = align_info.video_startTILend(2)+ ceil(diff(vidEnd,parEnd)/FrameRate_defined);
        end
        
        
        %% cut to session_window
        [pupil_dia_cut, pupil_dia_corr_cut] = pupil_cut2exp(pupil_dia,pupil_dia_corr,align_info);
        % save workspace.mat;
        %% get outlier trials where pupil diameter exceeds +/- 3-4std of trial mean diameter
        % % outlier_trial_idx =
        % get_pupil_outlier_trials(pupil_dia_corr_cut,sessions_of_interest,plot_button,d);
        % ### Not yet finished
        %% for every sessio parse pupil information into d-struct
        d = pupil_in2_d(pupil_dia_cut, pupil_dia_corr_cut,sessions_of_interest(vx),align_info,filt_info,FrameRate_defined,d); %outlier_trial_idx
        % save workspace.mat;
        %% save pupil_dias in respective video folder
        info = save_dias(Videolist_csv(vx),pupil_dia,pupil_dia_corr,pupil_dia_cut,pupil_dia_corr_cut);
        disp(info);
    catch err        
        disp(getReport(err,'extended'));
        warning([Videolist{vx} ' failed!'])
    end
end
    
    %% subfunctions
    
    function checkVidPathLists(Videolist,Videolist_csv,Diglist)
        %% sanity check between lists
        if ~(length(Diglist)==length(Videolist) && length(Videolist)==length(Videolist_csv))
            warning('missmatch between file list lengths!')
            keyboard
        end
        
        for vx = 275:numel(Videolist)
            splitStr = strsplit(Diglist{vx},filesep);
            splitStr = strsplit(splitStr{end},'_');
            animal = splitStr{1};
            
            if ~(contains(Videolist{vx},animal) && contains(Videolist_csv{vx},animal))
                warning('Missmatch between files')
                keyboard
            end
        end
        
        
        
        for vx = 1:numel(Videolist)
            splitStr = strsplit(Videolist{vx},filesep);
            df = splitStr{8};
            animal = splitStr{9};
            
            if ~(contains(Videolist_csv{vx},df) & contains(Videolist_csv{vx},animal))
                Videolist{vx}
                warning('Pathlists missaligned')
                keyboard
            end
        end
    
    %% depreacted stuff
    
    
    % function [proc_path_list,vid_path_list] = getProcAndVidPath(vid_path_list,sessions_of_interest)
    % pthPre=getPre; %(1)
    %
    % for vx = 1:numel(vid_path_list)
    % splitStr = strsplit(vid_path_list{vx},'\');
    %
    % f_ = strfind(splitStr{end-1},'_');
    % date = splitStr{end-1}(1:f_(1)-1);
    % tag = 'TD19_EPhys';
    % vidTag = splitStr{end-1}(f_(1)+1:end);
    % if isunix
    %     vid_path_list{vx} = [pthPre{1} splitStr{end-4} filesep splitStr{end-3} filesep splitStr{end-2} filesep splitStr{end-1} filesep splitStr{end}];
    %     proc_path_list{vx} = [pthPre{1} 'TD19' filesep 'DATA' filesep 'DONE_KS3_auto' filesep tag filesep sessions_of_interest(vx).ID];
    % end
    %
    %
    % end
