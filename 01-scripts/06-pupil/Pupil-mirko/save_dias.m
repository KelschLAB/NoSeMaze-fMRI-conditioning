function info = save_dias(Videolist_csv,pupil_dia,pupil_dia_corr,pupil_dia_cut,pupil_dia_corr_cut)

for sesh = 1:numel(Videolist_csv)
    dia.pupil_dia = pupil_dia(sesh);
    dia.pupil_dia_corr = pupil_dia_corr(sesh);
    dia.pupil_dia_cut = pupil_dia_cut(sesh);
    dia.pupil_dia_corr_cut = pupil_dia_corr_cut(sesh);
    
    csv_curr = Videolist_csv{sesh};
    find_filesep = strfind(csv_curr,filesep);
    savepath = csv_curr(1:find_filesep(end));
    filename = csv_curr(find_filesep(end)+1:end-4);
    
    save([savepath 'dia_' filename '.mat'], 'dia');
    clear dia;
end
info = [num2str(sesh) 'session diameters are saved'];

end