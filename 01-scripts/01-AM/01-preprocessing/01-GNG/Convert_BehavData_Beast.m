  function [events] = Convert_BehavData_Beast(excelpath, savedir)

%% LW/SG in 04/2020: 
% "Convert_BehavData_Beast" converts beast output files in which behavioral data
% is saved (csv-file) into files compatible to data structure established
% by MS/LW (mat-file; "events"-variable). Therefore, data saved in 

% Input
    % excelpath - path belonging to beast output file (csv-file) 
    % savedir   - directory in which output (mat file) is saved 
    
% Output 
    % multiple mat-files (one for each animal taking part in current
    % experiment)
        % "events" variable saved in each mat-file: mat structure including
        % all information about trials performed in the beast ... 

        
        
%% 
    if nargin < 2 % in case there is no input ... 
       % define excelpath ...  
      [filename, pathname, filterindex] = uigetfile('*.csv','Select beast output file (csv)...');
      excelpath = [pathname filename];
       % define savedir ... 
       savedir = 'D:\Sarah\MatLabData\Scripts'; 
    end 
    

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% GETTING STARTED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    

%% 1. read beast output and load it into matlab -> RawOutput_beast

   [~,~,RawOutput_beast]=xlsread(excelpath);
 %  RawOutput_beast=importdata(excelpath)
    
    % info: RawOutput_beast
        % column 1 = ID 
        % column 2 = timestamp
        % column 3 = num licks 
        % ...
        % column 5 = reward delivrery + current trial type 

    
%% 2. get list/number of animals in current experiment (prep animal loop) 
% info: ID = 'default' means that an unambiguous assignment was not
% possible in the current trial ... 

    % create list of all  animals ...
    animal_ID_list_long    = RawOutput_beast(:,1); % = first column of csv file ...   
    animal_ID_list_unique  = unique(RawOutput_beast(2:end,1)); % column titles cut ... 
    % remove 'default' from 'animal_ID_list_unique' ... 
    animal_ID_list_unique(find(strcmp(animal_ID_list_unique,'default') == 1)) = []; 
    % get number of animals in current experiment ... 
    NumAnimals = numel(animal_ID_list_unique);
    
    
%% 3. LOOP OVER ANIMALS STARTS HERE !!!

    for animal_cur = 1:NumAnimals;
        
        % get ID of current animal ... 
        IDcur = animal_ID_list_unique{animal_cur}; 
        
        % select all trials performed by current animal ... 
        TrialIndex_cur= find(strcmp(animal_ID_list_long, IDcur) == 1);
        TrialNum_cur = numel(TrialIndex_cur); 
        
        % LOOP OVER TRIALS
        for trial_cur = 1:TrialNum_cur;
            
            % get row in which current trial data is saved ...
            row_cur = TrialIndex_cur(trial_cur); 
            
            %extract all information of interest from beast data and save
            %it in 'events' variable (structure) ... 
                % ID
                events(trial_cur).ID = IDcur; 
                
                % date (year.month.day)
                timestampLong_cur = RawOutput_beast{row_cur,2};                 
                events(trial_cur).date = replace(timestampLong_cur(1:(strfind(timestampLong_cur,' ')-1)),'-','');
                
                % time_StartTrial
             
                time_Start=replace(timestampLong_cur(strfind(timestampLong_cur,' ')+1:end),'.',''); % remove . 
                StartTrial= replace(time_Start,':',''); % remove : 
                StartTrial=str2num(StartTrial);
                
                xx = str2num(timestampLong_cur(end-5:end)); 
                xx_round = round(xx/10000);
                timestampLong_round = [timestampLong_cur(1:end-6) num2str(xx_round)];
                
                StartTrial_round = round(StartTrial/1000);
                events(trial_cur).time_StartTrial= timestampLong_cur((strfind(timestampLong_cur,' ')+1:end))
                

                % curr_odor_num
                events(trial_cur).curr_odor_num = str2num(RawOutput_beast{row_cur,5}(end)); 
                
                % reward_active 
                events(trial_cur).reward=str2num(RawOutput_beast{row_cur,5}(1));
               
           
                % fv_on
                events(trial_cur).fv_on=0.5;
                
                % fv_off 
                events(trial_cur).fv_off=2.5;
                
                % reward_given_after 
                events(trial_cur).reward_given_after=2.5;
                
                %licks_before_odor
                licksbo=RawOutput_beast{row_cur,12};
                %licksbo=replace(licksbo,'not licked','0');
               licksbo(find(strcmp(licksbo,'not licked') == 1)) = [];
                licksbo=replace(licksbo,':','');
               licksbo=replace(licksbo,'.','');
               licksbo=replace(licksbo,'|',' ');
               licksbo=str2num(licksbo);
                
          
                %licks_before_odor_aligned
                StartTime=replace(timestampLong_cur(strfind(timestampLong_cur,' ')+1:end),'.','');
               LickTime=licksbo;
               diff_cur=LicksAligned(StartTime,LickTime);
                events(trial_cur).licks_before_odor_aligned=diff_cur;
            
                
                
                % licks_after_odor 
                licks=RawOutput_beast{row_cur,14};
                %licks=replace(licks,'not licked','0');
                licks(find(strcmp(licks,'not licked') == 1)) = [];
                licks=replace(licks,':','');
                licks=replace(licks,'.','');
                licks=replace(licks,'|',' ');
                licks=str2num(licks);
                %events(trial_cur).licks_after_odor=licks;
              
                %%licks_after_odor aligned%%
                StartTime=replace(timestampLong_cur(strfind(timestampLong_cur,' ')+1:end),'.','');
                LickTime=licks;
                diff_cur=LicksAligned(StartTime,LickTime);
                events(trial_cur).licks_after_odor_aligned=diff_cur;  
                
                
                
               
              %%drop_or_not%% 
              ant_licks_count(trial_cur)=length(find(events(trial_cur).licks_after_odor_aligned <= events(trial_cur).reward_given_after));
              
              if events(trial_cur).reward==1     
              events(trial_cur).drop_or_not='Drop'; 
              else 
              events(trial_cur).drop_or_not='No Drop';
              end
           
              if ant_licks_count(trial_cur)<=1
              events(trial_cur).drop_or_not='No Drop';
              end
                
              events(trial_cur).drop_or_not=replace(events(trial_cur).drop_or_not,'No Drop','0'); 
              events(trial_cur).drop_or_not=replace(events(trial_cur).drop_or_not,'Drop','1');
              events(trial_cur).drop_or_not=str2num(events(trial_cur).drop_or_not);
                
                
                %%licked_at_the_false_odor%%
               events(trial_cur).licked_at_the_false_odor=RawOutput_beast{row_cur,11};
               % events(trial_cur).licked_at_the_false_odor=replace(events(trial_cur).licked_at_the_false_odor,'TRUE','1');
              %  events(trial_cur).licked_at_the_false_odor=replace(events(trial_cur).licked_at_the_false_odor,'FALSE','0');
               % events(trial_cur).licked_at_the_false_odor=str2num(events(trial_cur).licked_at_the_false_odor);
                
        end % of trial loop   
        
        %%save 'events' in mat-file%%
        filename_csv_short = filename(1:end-4); 
        savestring_cur = [savedir filesep IDcur '_' filename_csv_short '.mat']; 
        save(savestring_cur, 'events');
        
        %%clear variables for next loop run%%
        clear ID date time_StartTrial curr_odor_num events
        
    end % of animal loop 
    
    


end % function



