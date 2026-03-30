function [helpers_classifier] = create_helpers_classifier_jr(d,anticipatory_window_definition,post_window_definition,baseline_window_definition)
%% create_helpers_classifier_jr.m
% 11/2020 Jonathan Reinwald
% input: d-struct, baseline-, anticipatory-, post-window definitions (as 1x2 vectors) 
% output: helpers_classifier including  information on
% ant-/post-/baseline-lickrates, rewards, odor, ...

%% Loop over sessions
for session = 1:length(d.info);
    %% Loop over trials
    for i_trial = 1:length(d.events{session});
        
        %% Baseline Lickrate
        % definition of baseline lickrate:
        % licks between fv_on+(baseline_window_definition(2)) and fv_on+(baseline_window_definition(1)) per second (example: licks(fv_on-4.5 to fv_on+0.5) / 5)
        baseline_lickrate(i_trial)=sum((vertcat(d.events{session}.licks)<(d.events{session}(i_trial).fv_on+baseline_window_definition(2))).*(vertcat(d.events{session}.licks)>(d.events{session}(i_trial).fv_on+baseline_window_definition(1))))/sum(abs(baseline_window_definition));
        
        %% Post-Lickrate
        % lick rate after reward-timepoint in non-rewarded trials
        post_lickrate(i_trial)=sum((vertcat(d.events{session}.licks)<(d.events{session}(i_trial).fv_on+post_window_definition(2))).*(vertcat(d.events{session}.licks)>(d.events{session}(i_trial).fv_on+post_window_definition(1))))/abs(diff(post_window_definition));
        
        %% Anticipatory-Lickrate
        % lick rate before reward-timepoint in non-rewarded trials
        anticipatory_lickrate(i_trial)=sum((vertcat(d.events{session}.licks)<(d.events{session}(i_trial).fv_on+anticipatory_window_definition(2))).*(vertcat(d.events{session}.licks)>(d.events{session}(i_trial).fv_on+anticipatory_window_definition(1))))/diff(anticipatory_window_definition);
        
        %% Combined Anticipatory and Post Lickrate
        combantipost_lickrate(i_trial)=sum((vertcat(d.events{session}.licks)<(d.events{session}(i_trial).fv_on+post_window_definition(2))).*(vertcat(d.events{session}.licks)>(d.events{session}(i_trial).fv_on+anticipatory_window_definition(1))))/(post_window_definition(2)-anticipatory_window_definition(1));
        
        helpers_classifier{session}(i_trial).baseline_lickrate = baseline_lickrate(i_trial);
        helpers_classifier{session}(i_trial).post_lickrate = post_lickrate(i_trial);
        helpers_classifier{session}(i_trial).anticipatory_lickrate = anticipatory_lickrate(i_trial);            
        helpers_classifier{session}(i_trial).combantipost_lickrate = combantipost_lickrate(i_trial);            
    
        helpers_classifier{session}(i_trial).drop_or_not = d.events{session}(i_trial).drop_or_not;
        helpers_classifier{session}(i_trial).curr_odor_num = d.events{session}(i_trial).curr_odor_num;
        helpers_classifier{session}(i_trial).reward_prob = d.events{session}(i_trial).rew_prob_cur;        
               
    end;
    
%     helpers_classifier{session}.animalID = d.info(session).animal;
%     helpers_classifier{session}.date = d.info(session).date;

end;