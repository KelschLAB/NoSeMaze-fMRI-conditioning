function [pupil_dia_cut, pupil_dia] = pupil_cut(Videolist_csv,pupil_dia,max_outlier)
    for vid = 1:numel(Videolist_csv)
%         [fdir,fname,fext]=fileparts(Videolist_csv{vid});
        % threshold for numb of outliers to
        
        if pupil_dia(vid).numb_outliers > max_outlier
            [pupil_dia(vid).ipoints, residual] = findchangepts(pupil_dia(vid).d_mean,'MaxNumChanges',1,'Statistic','mean');
            pupil_dia_cut(vid)=pupil_dia(vid);
            pupil_dia_cut(vid)=pupil_dia(vid);
            pupil_dia_cut(vid).d_mean=pupil_dia(vid).d_mean(1:pupil_dia(vid).ipoints);
            pupil_dia_cut(vid).length=length(pupil_dia_cut(vid).d_mean);
            pupil_dia_cut(vid).outliers=pupil_dia(vid).outliers(pupil_dia(vid).outliers<pupil_dia(vid).ipoints);
            pupil_dia_cut(vid).numb_outliers=length(pupil_dia_cut(vid).outliers);
        else
            pupil_dia(vid).ipoints=[];
            pupil_dia_cut(vid)=pupil_dia(vid);
        end
    end