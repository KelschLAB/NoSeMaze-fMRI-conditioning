function [pupil_dia_cut, pupil_dia_corr_cut] = pupil_cut2exp(pupil_dia,pupil_dia_corr,align_info)

pupil_dia_cut = pupil_dia;
pupil_dia_corr_cut = pupil_dia_corr;

for vid = 1:numel(pupil_dia)
    vidStart = align_info(vid).video_startTILend(1);
    vidEnd = align_info(vid).video_startTILend(2);
    
    pupil_dia_cut(vid).d_mean = pupil_dia(vid).d_mean(vidStart:vidEnd);
    pupil_dia_cut(vid).length = vidEnd - vidStart +1;
    
    pupil_dia_cut(vid).outliers = pupil_dia(vid).outliers(pupil_dia(vid).outliers >= vidStart & pupil_dia(vid).outliers <= vidEnd);
    pupil_dia_cut(vid).numb_outliers = numel(pupil_dia_cut(vid).outliers); 
    
    pupil_dia_corr_cut(vid).d_mean = pupil_dia_corr(vid).d_mean(vidStart:vidEnd);
    if isfield(pupil_dia_corr_cut,'d_mean_lp')
    pupil_dia_corr_cut(vid).d_mean_lp = pupil_dia_corr(vid).d_mean_lp(vidStart:vidEnd); 
    pupil_dia_corr_cut(vid).d_mean_bp = pupil_dia_corr(vid).d_mean_bp(vidStart:vidEnd); 
    end
end