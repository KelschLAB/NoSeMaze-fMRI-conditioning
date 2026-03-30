% clear all
% close all
% clc

% Load pupil and lid data from reappraisal task
load('/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/04_reappraisal_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
summary_all_rp = summary_all;

% Load pupil and lid data from control task with neroli
load('/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/04-pupil/06-160TrialsNeroli_ephys_2022/03-videos_pupil/pupil_summary_all.mat');
summary_all_con = summary_all;


reappraisal_all = summary_all_rp(1:3:end);


% bins
for curr_bin=47:119
    counter=1;
    
    % animal ID
    for animal_ID=1:length(reappraisal_all)
        
        % time point in task
        for tp=1:120
            
            if tp>10 && tp<41 | tp>80 && tp<121
                % block
                if tp>10 && tp<41
                    block(counter)=-1;
                elseif tp>80 && tp<121
                    block(counter)=1;
                else
                    block(counter)=0;
                end
                
                % puff
                puff(counter)=reappraisal_all(animal_ID).puff_or_not(tp);
                
                % time point
%                 timepoint(counter)=tp;
                
                % animal
                animal(counter)=animal_ID;
                
                % lid
                lid(counter)=reappraisal_all(animal_ID).LidBaseDiameterMatrix_Corrected(tp,curr_bin);
                
                % counter update
                counter=counter+1;
            end
        end
    end
    % create the input table
    %     myTable(curr_bin).input = table(block',timepoint',animal',puff',lid','VariableNames',{'block','timepoint','animal','puff','lid'});
    
    myTable(curr_bin).input = table(block',animal',lid','VariableNames',{'block','animal','lid'});
    
    %
%     myTable(curr_bin).input.animal = categorical(myTable(curr_bin).input.animal);
%     myTable(curr_bin).input.block = categorical(myTable(curr_bin).input.block);
    
    lme = fitlme(myTable(curr_bin).input,'lid ~ 1 + block + (1|animal)');
    
    p_intercept(curr_bin)=double(lme.Coefficients(1,6));
    p_block(curr_bin)=double(lme.Coefficients(2,6));
%     p_timepoint(curr_bin)=double(lme.Coefficients(3,6));
%     p_puff(curr_bin)=double(lme.Coefficients(3,6));

    beta_intercept(curr_bin)=double(lme.Coefficients(1,2));
    beta_block(curr_bin)=double(lme.Coefficients(2,2));
%     beta_timepoint(curr_bin)=double(lme.Coefficients(3,2));
%     beta_puff(curr_bin)=double(lme.Coefficients(3,2));
    %     p_timepointBYblock(curr_bin)=double(lme.Coefficients(4,6));
    
    %     p_animal(curr_bin)=double(lme.Coefficients(4,6));
end