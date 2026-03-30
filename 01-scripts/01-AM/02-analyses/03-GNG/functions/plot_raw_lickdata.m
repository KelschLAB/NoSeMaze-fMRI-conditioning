function plot_raw_lickdata(d,save_dir)

% %% für die Phasen jeweils getrennt
for animal_idx = 1:size(d,1)
    
    cur_animal_id = d(animal_idx).events(1).ID;
    
    for phase_idx = 1:numel(unique([d(animal_idx).events.phase]))
        % für ein Tier als Beispiel:
        phase_indx = [d(animal_idx).events.phase]==phase_idx;
        first_trial_in_phase = find(phase_indx,1,'first');
        cur_odors = [d(animal_idx).events(phase_indx).reward];
        cur_odors(cur_odors==0) = 2;
        unique_odors = unique(cur_odors);

        cur_trialtimes = 1:5:numel(cur_odors)*5;
        licktimes_reindexed = [];

        for tr = 1:numel(cur_trialtimes)
            licktimes_reindexed = cat(2,licktimes_reindexed,[d(animal_idx).events(tr+first_trial_in_phase-1).licks_bef_od]+cur_trialtimes(tr),[d(animal_idx).events(tr+first_trial_in_phase-1).licks_aft_od]+cur_trialtimes(tr));
        end

        f = plot_PSTH(licktimes_reindexed,cur_trialtimes,cur_odors, 'pre', 0,'post',3500,'binsize',50);
        sgtitle({cur_animal_id,['Phase ',num2str(phase_idx)]},'Interpreter','none');
        exportgraphics(f,fullfile(save_dir,[cur_animal_id,'_ph',num2str(phase_idx),'.pdf']),'ContentType','vector','BackgroundColor','none')
        close all;
    end
end

%% für alle Phasen zusammen

for animal_idx = 1:size(d,1)
    
    cur_animal_id = d(animal_idx).events(1).ID;
    cur_odors = [d(animal_idx).events.reward];
    cur_odors(cur_odors==0) = 2;
    unique_odors = unique(cur_odors);

    cur_trialtimes = 1:5:numel(cur_odors)*5;
    licktimes_reindexed = [];

    for tr = 1:numel(cur_trialtimes)
        licktimes_reindexed = cat(2,licktimes_reindexed,[d(animal_idx).events(tr).licks_bef_od]+cur_trialtimes(tr),[d(animal_idx).events(tr).licks_aft_od]+cur_trialtimes(tr));
    end

    f = plot_PSTH(licktimes_reindexed,cur_trialtimes,cur_odors, 'pre', 0,'post',3500,'binsize',50);
    sgtitle({cur_animal_id,'all Phases'},'Interpreter','none');
    exportgraphics(f,fullfile(save_dir,[cur_animal_id,'_allphases.pdf']),'ContentType','vector','BackgroundColor','none')
    close all;
end
    
%% filtered mit min-licktimediff = 50 ms
for animal_idx = 1:size(d,1)

    gng_data = d(animal_idx).events; 
    for tr = 1:numel(gng_data)

       all_trial_licks = cat(2, gng_data(tr).licks_bef_od, gng_data(tr).licks_aft_od);
    %    for lc = 1:numel(all_trial_licks)
       lc = 1;
       while lc<=numel(all_trial_licks)
          curr_diff = all_trial_licks-all_trial_licks(lc);
          all_trial_licks = all_trial_licks(~(curr_diff>0 & curr_diff<0.05));
          lc=lc+1;
       end

       gng_data(tr).licks_bef_od = all_trial_licks(all_trial_licks<0.5);
       gng_data(tr).licks_aft_od = all_trial_licks(all_trial_licks>=0.5);

    end

    cur_animal_id = d(animal_idx).events(1).ID;
    cur_odors = [d(animal_idx).events.reward];
    cur_odors(cur_odors==0) = 2;
    unique_odors = unique(cur_odors);

    cur_trialtimes = 1:5:numel(cur_odors)*5;
    licktimes_reindexed = [];

    for tr = 1:numel(cur_trialtimes)
        licktimes_reindexed = cat(2,licktimes_reindexed,[gng_data(tr).licks_bef_od]+cur_trialtimes(tr),[gng_data(tr).licks_aft_od]+cur_trialtimes(tr));
    end

    f = plot_PSTH(licktimes_reindexed,cur_trialtimes,cur_odors, 'pre', 0,'post',3500,'binsize',50);
    sgtitle({cur_animal_id,'all Phases (filtered)'},'Interpreter','none');
    exportgraphics(f,fullfile(save_dir,[cur_animal_id,'_allphases_filtered.pdf']),'ContentType','vector','BackgroundColor','none')
    close all;
end
end
