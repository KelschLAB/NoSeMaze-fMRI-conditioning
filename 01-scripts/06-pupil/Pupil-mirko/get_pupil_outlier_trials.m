% function to find trials with more than max_consec_outlier == NaN values
% in raw trace
% Input:
% - d struct (d)
% - sessions of interest struct (soi)
% - plot button (pb)
% Output:
% - outlier_trial_idx as cell {session idx}(trial number)
function outlier_trial_idx = get_pupil_outlier_trials(soi,pb,d)
% first used for pupil_data already loaded into d struct
% then integrate into load_pupil_dia.m
max_consec_outlier = 2;

for s = 1:numel(soi)
    idx = soi(s).idx;
    sr = d.pupil(idx).info.samplerate;
    events= d.events{idx};
    pupil = d.pupil(idx).raw_trace;
    outlier_trial_idx{s} = zeros(numel(events),1); 
%     s_meandia = nanmean(pupil);
%     s_stddia = std(pupil,'omitnan');
    for t = 1:numel(events)
       trial_window = round(sr*events(t).fv_on_odorcue)-1*sr:round(sr*events(t).fv_off_rewcue)+2.4*sr;
%        t_meandia = mean(pupil(trial_window));
%        t_stddia = std(pupil(trial_window));
       if any(isnan(pupil(trial_window)))
           trial_outlier = isnan(pupil(trial_window))';
           diff_outlier = diff([0 trial_outlier 0]);
           first = find(diff_outlier==1);
           consec_outlier = find(diff_outlier==-1)-first; 
           if ~isempty(find(consec_outlier>max_consec_outlier)) || isempty(consec_outlier) %find(pupil(trial_window)>s_meandia+xstd*s_stddia)      
               outlier_trial_idx{s}(t)=1;
               if pb
                  f_ol = figure;
                  hold on;
                  plot(pupil(trial_window),'k');
                  plot(d.pupil(idx).lp_trace(trial_window),'b');
                  plot(find(trial_outlier),d.pupil(idx).lp_trace(trial_window(find(trial_outlier))),'r*');
                  close(f_ol);
               end
           end
       end
    end
    if 0
        outliers = find(outlier_trial_idx{s});
        if outliers
            f=figure('Position',[1 1 120 25],'Name',d.info(idx).ID);
            hold on;
            plot(pupil,'k'); 
            plot(d.pupil(idx).raw_trace,'b')
            for ot = outliers
            plot([round(sr*events(ot).fv_on_odorcue)-1*sr  round(sr*events(ot).fv_off_rewcue)+4.4*sr],[2 2],'r');
            end
            end
    end
end
end