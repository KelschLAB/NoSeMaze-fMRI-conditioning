function d = pupil_in2_d(pupil_dia_cut, pupil_dia_corr_cut,sessions_of_interest,align_info,filt_info,FrameRate_defined,d)%outlier_trial_idx

filtering = isfield(pupil_dia_corr_cut,'d_mean_lp');
filters_applied = fieldnames(filt_info);

pup2trial = false; % true if separation fo pupil trace into trialtrace should be done in this script (old), false if done elsewhere (new: pupil2trialtrace.m)
% -> modified MA 210601

for soi = 1:numel(sessions_of_interest)
    ses = sessions_of_interest(soi).idx;
        
    ref = align_info(soi).intan_Time2Delete;
    length_puptrace = length(pupil_dia_cut(soi).d_mean); %raw
    
    
    % load original dchannels to get LED trigger time
    if ~isfield(d.info(ses),'proc_path')
        [proc_path,~] = getCompatibleProcAndVidPath(sessions_of_interest(soi));
    else
        if isunix
            error('procpath transformation on linux not yet implemented')
        else
            proc_path = d.info(ses).proc_path;
        end
    end
    load(fullfile(cell2mat(proc_path),[d.info(ses).ID,'_digital.mat']),'dchannels','sample_rate');
               
        
         %%
        % initialize pupil-trace with NaN for whole length and then 
        d.pupil(ses).raw_trace = nan(round(length(dchannels(:,1))/sample_rate*10),1);
        d.pupil(ses).scrub_trace = nan(round(length(dchannels(:,1))/sample_rate*10),1);  
        d.pupil(ses).raw_trace(round(ref*FrameRate_defined):round(ref*FrameRate_defined)+length_puptrace-1,1) = pupil_dia_cut(soi).d_mean; %raw %(VOI_Info.FrameBegin:end); %parse to right time
        d.pupil(ses).scrub_trace(round(ref*FrameRate_defined):round(ref*FrameRate_defined)+length_puptrace-1,1) = pupil_dia_corr_cut(soi).d_mean; % only scrubbed
        
        if filtering
            d.pupil(ses).lp_trace = nan(round(length(dchannels(:,1))/sample_rate*10),1);
            d.pupil(ses).bp_trace = nan(round(length(dchannels(:,1))/sample_rate*10),1);     
            d.pupil(ses).lp_trace(round(ref*10):round(ref*10)+length_puptrace-1,1) = pupil_dia_corr_cut(soi).d_mean_lp; %scrubbed, lp-filtered;%(VOI_Info.FrameBegin:end);
            d.pupil(ses).bp_trace(round(ref*10):round(ref*10)+length_puptrace-1,1) = pupil_dia_corr_cut(soi).d_mean_bp; %scrubbed, bp-filtered;%(VOI_Info.FrameBegin:end);
            for f = 1:numel(filt_info)
                d.pupil(ses).info.(filters_applied{f}) = filt_info.(filters_applied{f});
            end
        end   
        
        d.pupil(ses).timevector = 'tobeimplemented';
        d.pupil(ses).info.samplerate = FrameRate_defined;
        d.pupil(ses).info.intanalign = align_info(soi).intan_Time2Delete;
        filters_applied = fieldnames(filt_info);
        d.pupil(ses).info.StartEndFrames = align_info(soi).video_startTILend;
        
        d.info(ses).pupil_n_er = pupil_dia_cut(soi).numb_outliers;
        if (pupil_dia_cut(soi).numb_outliers/pupil_dia_cut(soi).length) < .05 %if less than 5 percent outlier frames
            d.info(ses).pupil_exclude = 0;
        else
            d.info(ses).pupil_exclude = 1;
        end
        
        d = pupil2trialtrace(d,ses);        

end



%% subfunctions

%% OLD, not used anymore
%% Separate Pupiltrace into trial parts
function pup2trial
        % load original dchannels to get LED trigger time
        load(fullfile(d.info(ses).proc_path,[d.info(ses).ID,'_digital.mat']),'dchannels','sample_rate');

        
        
        trials = numel(d.events{ses});
        fv_on_odorcue = [d.events{ses}.fv_on_odorcue];
        fv_off_odorcue = [d.events{ses}.fv_off_odorcue];
        fv_on_rewcue = [d.events{ses}.fv_on_rewcue];
        fv_off_rewcue = [d.events{ses}.fv_off_rewcue];
        jitter = [d.events{ses}.jitter_OC_RC];
        reward_time = {d.events{ses}.reward_time};
        
if d.info(ses).lick == 1    
        licks = [d.events{ses}.lick];
end
        %% finally align events to INTAN_Info.start_vid ... loop necessary for licks
        % timepoints are aligned but not saved to prevent redundancy in d 
        
        for trial = 1:trials
            fv_on_odorcue(trial) = fv_on_odorcue(trial) - ref;
            fv_off_odorcue(trial) = fv_off_odorcue(trial) - ref;
            fv_on_rewcue(trial) = fv_on_rewcue(trial) - ref;
            fv_off_rewcue(trial) = fv_off_rewcue(trial) - ref;   
            if d.info(ses).lick == 1 
                licks{trial} = licks{trial} - ref;
            end
        end
        
        % reward ..
        ix=1;
        for i=1:trials
            if ~isempty(reward_time{i})
            drops(i) = reward_time{i};
            dist(ix) = drops(i)-fv_off_rewcue(i);
            ix = ix + 1; 
            else
                drops(i)=NaN;
            end
        end
        MeanDist=mean(dist);  %%%% mean dist btw rewcue and reward (in this task stable)
        
        %%%% add fake drops for non rewarded trials
        for i=1:length(drops)
            if isnan(drops(i))
                drops(i)=fv_off_rewcue(i)+MeanDist;   
            end
        end
%         
%         for trial = 1:length(drops)
%             
%             drops(trial) = drops(trial) - Time2Delete;
%             
%             
%         end
        
        %3. get diameter values of interest
        %     Path_diameter = getAllFiles(Videolist{vid}, 'rw*diameter.mat',1);
        PupilDiameter = pupil_dia_corr_cut(soi).d_mean;
        PupilDiameter_LP = pupil_dia_corr_cut(soi).d_mean_lp;
%         PupilDiameter_HP = pupil_dia_corr_cut(vid).d_mean_hp;
%         PupilDiameter_BP = pupil_dia_corr_cut(vid).d_mean_bp;
        
        % extract those values which are situated in "cropped" vid ...
%         index_FramesOfInterest = VOI_Info.FrameBegin-(pretrig*FrameRate_defined):1:VOI_Info.FrameEnd;
%         PupilDiameter = PupilDiameter(index_FramesOfInterest);
%         PupilDiameter_LP = PupilDiameter_LP(index_FramesOfInterest);
%         PupilDiameter_HP = PupilDiameter_HP(index_FramesOfInterest);
%         PupilDiameter_BP = PupilDiameter_BP(index_FramesOfInterest);
        
        
        %4. visual control to see whether diameters and fvonsets, licks are well
        % aligned to each other ...
%         plot_VisualControlment_ParadigmPupil_JR(events,VOI_Info,PupilDiameter,PupilDiameter_LP,licks,fv_on, drops,savedir,Vidname_short)
        
        
        %5. assign fv_onsets to video frames (= OdorFrames)...
        % -> find vieo frame which is nearest to current fv_onset
        FrameDur = 1/FrameRate_defined;
        for trial = 1:trials
            % get current onset and offset...
            fv_on_odorcue_cur = fv_on_odorcue(trial);
            fv_off_odorcue_cur = fv_off_odorcue(trial);
            fv_on_rewcue_cur = fv_on_rewcue(trial);
            fv_off_rewcue_cur = fv_off_rewcue(trial);
            drops_cur = drops(trial);
            
            % find correspondent frame in vid ...
            OdorcueOnFrames(trial).Time = round(fv_on_odorcue_cur/FrameDur)*FrameDur;
            OdorcueOnFrames(trial).Loc_Frames = OdorcueOnFrames(trial).Time/FrameDur;
            OdorcueOffFrames(trial).Time = round(fv_off_odorcue_cur/FrameDur)*FrameDur;
            OdorcueOffFrames(trial).Loc_Frames = OdorcueOffFrames(trial).Time/FrameDur;
            RewcueOnFrames(trial).Time = round(fv_on_rewcue_cur/FrameDur)*FrameDur;
            RewcueOnFrames(trial).Loc_Frames = RewcueOnFrames(trial).Time/FrameDur;
            RewcueOffFrames(trial).Time = round(fv_off_rewcue_cur/FrameDur)*FrameDur;
            RewcueOffFrames(trial).Loc_Frames = RewcueOffFrames(trial).Time/FrameDur;
            DropsFrames(trial).Time = round(drops_cur/FrameDur)*FrameDur;
            DropsFrames(trial).Loc_Frames = DropsFrames(trial).Time/FrameDur;
        end
        
        %% Create TrialDiameterMatrix ...
        % TrialDiameterMatrix is a matrix containing all diameter data aligned to
        % fv_onsets / for all trials / different event types parsed later ...
        % rows = trials ...
        % columns = frames ...
        % values = corresponding diameters ...
        
        % define window of interest for pupil analysis
        pre = 1; % in s; number of seconds plotted before odor stim
        post = 2; % in s; number of seconds plotted after odor stim
        window_index = [-pre:(1/FrameRate_defined):post-(1/FrameRate_defined)];
        
        %saving diametervalues for whole trial
        pret = 2.5;% same as for deconvolution    4; % in s; number of seconds plotted before odor stim
        postt = 9;% same as for deconvolution 12; % in s; number of seconds plotted after odor stim
        window_indext = [-pret:(1/FrameRate_defined):postt-1/FrameRate_defined];
        
        % create matrix ...
        for trial = 1:trials
            
            % get FrameOfInterest which is exactly "pre" seconds before odor stim
            OdorcueOnFrameCur = OdorcueOnFrames(trial).Loc_Frames;
            FramePreOdorcue = OdorcueOnFrameCur - (pre*FrameRate_defined);
            RewcueOnFrameCur = RewcueOnFrames(trial).Loc_Frames;
            FramePreRewcue = RewcueOnFrameCur - (pre*FrameRate_defined);
            DropsFrameCur = DropsFrames(trial).Loc_Frames;
            FramePreDrops = DropsFrameCur - (pre*FrameRate_defined);            
            
            TrialFrameCur = OdorcueOnFrames(trial).Loc_Frames;
            FramePreTrial = TrialFrameCur - (pret*FrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFramesOC = [FramePreOdorcue:1:(FramePreOdorcue+numel(window_index)-1)];
            index_locFramesRC = [FramePreRewcue:1:(FramePreRewcue+numel(window_index)-1)];
            index_locFramesD = [FramePreDrops:1:(FramePreDrops+numel(window_index)-1)];
            
            index_locFramesT = [FramePreTrial :1:(FramePreTrial +numel(window_indext)-1)];
            
            
            % write rows in matrix ...
            % PupilDiameter_LP = lowpass filtered data ...
            % alternative: DiameterMatrix(trial,[1:numel(window_index)]) = PupilDiameter_LP(index_locFrames);
            % i would have preferred this single line, but there is a problem
            % in the data format -> quick solution: round incides ...
%             for i = 1:numel(window_index)
%                 DiameterMatrixOC(trial,i) = PupilDiameter_LP(round(index_locFramesOC(i)));
%                 DiameterMatrixRC(trial,i) = PupilDiameter_LP(round(index_locFramesRC(i)));
%                 DiameterMatrixD(trial,i) = PupilDiameter_LP(round(index_locFramesD(i)));
%             end
                first =1;
                for i = 1:numel(window_indext)
                    if index_locFramesT(i) > numel(PupilDiameter) && trial == trials
                        DiameterMatrixT(trial,i) = NaN;
                        DiameterMatrixT_LP(trial,i) = NaN;
                        if first
                        disp(['video with soi_idx: ' num2str(ses) ' was cut ' num2str(160-i) ' frames before end of last trial window!']);
                        first=0;
                        end
                    else
                        DiameterMatrixT(trial,i) = PupilDiameter(round(index_locFramesT(i)));
                        DiameterMatrixT_LP(trial,i) = PupilDiameter_LP(round(index_locFramesT(i)));
                    end
                        
            end
        end
        
        %% 2. Percentage Change throughout trial (values from csv file, no normalization)
        % idea: perform normalization to trial-by-trial baseline (prestim_window) ...
        
        % define window for baseline calculation ...
        baseshift = 1; % in s; baseline is calculated with frame all frames situated in window -baseshift : 0dorOnset (=0); til 2004 4.5
        basewindow = 1;               % 20200414MA
        % calculate baseline -> mean of all bins in baseline_window
        % -> first trial discarded, only 1s between IR trigger and OC onset
        for trial = 1:trials
            
            % get FrameOfInterest which is exactly "baseline" seconds before odor stim
            OdorcueOnFrameCur = OdorcueOnFrames(trial).Loc_Frames;
            FrameBaseStart = OdorcueOnFrameCur - (baseshift*FrameRate_defined);
            
            % get loc index for frames of current trial ...
            index_locFrames_baseline = [FrameBaseStart:1:(FrameBaseStart+((basewindow)*FrameRate_defined)-1)];
            

            % calculate baseline for current trial ...
            % loop to avoid strange format problem ...
            for i = 1:numel(index_locFrames_baseline)
                BaselineValues(i) = PupilDiameter(round(index_locFrames_baseline(i)));
                BaselineValues_LP(i) = PupilDiameter_LP(round(index_locFrames_baseline(i)));
            end
            
            BaseValMatrix(trial,:) = BaselineValues;
            BaselineDiameter(trial) = mean(BaselineValues);
            BaseValMatrix_LP(trial,:) = BaselineValues_LP;
            BaselineDiameter_LP(trial) = mean(BaselineValues_LP);
%             BaselineDiameterSTD(trial) = std(BaselineValues);
            
            % % % % %
            % matrix containg baseline-normalized pupil diameter values ...
%             BaseDiameterMatrixOC(trial,:) = (DiameterMatrixOC(trial,:))./BaselineDiameter(trial);
%             BaseDiameterMatrixRC(trial,:) = (DiameterMatrixRC(trial,:))./BaselineDiameter(trial);
%             BaseDiameterMatrixD(trial,:) = (DiameterMatrixD(trial,:))./BaselineDiameter(trial);
            BaseDiameterMatrixT(trial,:) = (DiameterMatrixT(trial,:))./BaselineDiameter(trial);
            BaseDiameterMatrixT_LP(trial,:) = (DiameterMatrixT_LP(trial,:))./BaselineDiameter_LP(trial);
            
        end
              
        
        d.pupil(ses).trialparts.baseline_raw = BaseValMatrix ;
        d.pupil(ses).trialparts.baseline_lp = BaseValMatrix_LP;
        d.pupil(ses).trialparts.trialtrace_raw = DiameterMatrixT;
        d.pupil(ses).trialparts.trialtrace_lp = DiameterMatrixT_LP;
        d.pupil(ses).trialparts.trialtrace_raw_base = BaseDiameterMatrixT;
        d.pupil(ses).trialparts.trialtrace_lp_base = BaseDiameterMatrixT_LP;
        
        d.pupil(ses).trialpartindices.info = '[pre post] fv_odorcue_on in seconds';
        d.pupil(ses).trialpartindices.trialtrace = [pret postt];
        d.pupil(ses).trialpartindices.baseline = [baseshift baseshift-basewindow];

