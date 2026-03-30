function d = combine_single_animals(pati)
%% combines single animal .mat-files, rename some fields and add phase-information
% copied from Carla/Sarahs scripts at /zi-flstorage/data/David/NoSeMazeScript

cd(pati);
pato=pati;

dumi=dir([pati,filesep,'000*.mat']);

for i=1:numel(dumi)
    dat=load(dumi(i).name);
    oldnames = char(fields(load(dumi(i).name)));  %%%%preliminary step to rename new fields
    newnames=strcat('events');
    auxd{i}.(newnames)=dat.(oldnames);
end
clear oldnames newnames
dd=auxd{1};
for i=1:numel(auxd)-1
    dd=[dd;auxd{i+1}];    %%%% "copy struct" as input function
end
 
%%%%% new d struct with reorganized data
d = gng_reor_fun(dd,pato);
%% final check sarahs script
%%%%% Double check to make sure that the original 
for i=1:numel(d)
    error_count(i)=0;
    for j=1:numel(d(i).events)
        if d(i).events(j).ant_lick_count<2 && d(i).events(j).reward==1 && d(i).events(j).drop_or_not==1
        error_count(i)=error_count(i)+1;
        if (error_count(i)~=0)
        indi{i}(error_count(i),1)=j;
        end
        end
        
    end
    
end





% file_list = dir(processed_data_path);
% file_list([file_list.isdir]) = [];
% 
% d = [];
% 
% for fl = 1:numel(file_list)
%     
%     load(fullfile(file_list(fl).folder,file_list(fl).name));
%     
%     for tr = 1:numel(events)
%         
%         % parse and rename
%         d(fl).events(tr).ID = events(tr).ID;        
%         d(fl).events(tr).date = events(tr).date;
%         d(fl).events(tr).time_StartTrial = events(tr).time_StartTrial;
%         d(fl).events(tr).curr_odor_num = events(tr).curr_odor_num;
%         d(fl).events(tr).reward = events(tr).reward;
%         d(fl).events(tr).fv_on = events(tr).fv_on;
%         d(fl).events(tr).fv_off = events(tr).fv_off;
%         d(fl).events(tr).rew_delay = events(tr).reward_given_after;
%         d(fl).events(tr).licks_bef_od = events(tr).licks_before_odor_aligned;
%         d(fl).events(tr).licks_aft_od = events(tr).licks_after_odor_aligned;
%         d(fl).events(tr).drop_or_not = events(tr).drop_or_not;
%         d(fl).events(tr).false_alarm = strcmp(events(tr).licked_at_the_false_odor,'True');
% 
%         % add phase information
%         
%         
%         
%     end
% end

end