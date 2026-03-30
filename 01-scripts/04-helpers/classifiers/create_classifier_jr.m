function [classifier,classifier_info] = create_classifier_jr(helpers_classifier,session_selection,trial_selection_original,classifier_selection,number_of_blocks,number_of_trials_considered)
%% create_classifier_jr.m

% 11/2020 Jonathan Reinwald
% input: d-struct, baseline-, anticipatory-, post-window definitions (as 1x2 vectors)
% output: helpers_classifier including  information on
% ant-/post-/baseline-lickrates, rewards, odor, ...
clear classifier

% Convert trial_selection to a binary vector with length 160;
trial_selection = zeros(1,length(helpers_classifier{1}));
trial_selection(trial_selection_original) = 1;
trial_selection = logical(trial_selection);

%% I. MOTIVATIONAL CLASSIFIERS
% only run if preselected in master script
if any(strcmp(classifier_selection,'motivational'))
    % set counter for sessions
    counter_sessions=1;
    %% Loop over sessions
    for i_session = 1:length(session_selection);
        clear session;
        % define sessions as the real session number
        session = session_selection(i_session);
        % motivational
        classifier(counter_sessions).baseline_lickrate = mean([helpers_classifier{session}(trial_selection).baseline_lickrate]);
        classifier(counter_sessions).post_reward_lickrate = mean([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).post_lickrate]);
        classifier(counter_sessions).noLicks_percent_all = 1-sum(logical([helpers_classifier{session}.anticipatory_lickrate]+[helpers_classifier{session}.post_lickrate]))/length(logical([helpers_classifier{session}.anticipatory_lickrate]+[helpers_classifier{session}.post_lickrate]));         
        
        classifier(counter_sessions).noLicks_percent_anticipatorynonreward = 1-sum(logical([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).anticipatory_lickrate]))/length([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).anticipatory_lickrate]);
        classifier(counter_sessions).noLicks_percent_anticipatoryreward = 1-sum(logical([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).anticipatory_lickrate]))/length([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).anticipatory_lickrate]);
        classifier(counter_sessions).noLicks_percent_anticipatoryALL = 1-sum(logical([helpers_classifier{session}(logical(trial_selection)).anticipatory_lickrate]))/length([helpers_classifier{session}(logical(trial_selection)).anticipatory_lickrate]);
        
        classifier(counter_sessions).noLicks_percent_postALL = 1-sum(logical([helpers_classifier{session}(logical(trial_selection)).post_lickrate]))/length([helpers_classifier{session}(logical(trial_selection)).post_lickrate]);
        classifier(counter_sessions).noLicks_percent_postreward = 1-sum(logical([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).post_lickrate]))/length([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).post_lickrate]);
        classifier(counter_sessions).noLicks_percent_postnonreward = 1-sum(logical([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).post_lickrate]))/length([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).post_lickrate]);
      
        classifier(counter_sessions).noLicks_percent_combALL = 1-sum(logical([helpers_classifier{session}(logical(trial_selection)).combantipost_lickrate]))/length([helpers_classifier{session}(logical(trial_selection)).combantipost_lickrate]);
        classifier(counter_sessions).noLicks_percent_combreward = 1-sum(logical([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).combantipost_lickrate]))/length([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).combantipost_lickrate]);
        classifier(counter_sessions).noLicks_percent_combnonreward = 1-sum(logical([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).combantipost_lickrate]))/length([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).combantipost_lickrate]);
        
        classifier(counter_sessions).licks_odor5 = [helpers_classifier{session}(logical(([helpers_classifier{session}.curr_odor_num]==5).*trial_selection)).anticipatory_lickrate];
        classifier(counter_sessions).licks_odor9 = [helpers_classifier{session}(logical(([helpers_classifier{session}.curr_odor_num]==9).*trial_selection)).anticipatory_lickrate];
        classifier(counter_sessions).RP = [helpers_classifier{session}(logical(trial_selection)).reward_prob];
        classifier(counter_sessions).rew = [helpers_classifier{session}(logical(trial_selection)).drop_or_not];
  
        
        
        classifier(counter_sessions).motivational_1 = mean([helpers_classifier{session}(trial_selection).baseline_lickrate]);
        classifier(counter_sessions).motivational_2 = mean([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==1).*trial_selection)).post_lickrate]);
        classifier(counter_sessions).motivational_3 = classifier(counter_sessions).motivational_2 - classifier(counter_sessions).motivational_1;
        
        % definitions in info-file
        classifier_info.motivational_1 = 'baseline lickrate';
        classifier_info.motivational_2 = 'post reward lickrate';
        classifier_info.motivational_3 = '(post reward lickrate) - (baseline lickrate)';
        
%         classifier(counter_sessions).animalID = helpers_classifier{session}.animal;
%         classifier(counter_sessions).date = helpers_classifier{session}.date;
                
        % update counter of sessions
        counter_sessions = counter_sessions + 1;
    end
end

%% II. TASK STRUCTURE CLASSIFIERS
% only run if preselected in master script
if any(strcmp(classifier_selection,'task_structure'))
    % set counter for sessions
    counter_sessions=1;
    %% Loop over sessions
    for i_session = 1:length(session_selection);
        clear session;
        % define sessions as the real session number
        session = session_selection(i_session);
        % task structure
        classifier(counter_sessions).post_non_reward_lickrate = mean([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).post_lickrate]);
        classifier(counter_sessions).anticipatory_non_reward_lickrate = mean([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).anticipatory_lickrate]);
        classifier(counter_sessions).combantipost_non_reward_lickrate = mean([helpers_classifier{session}(logical(([helpers_classifier{session}.drop_or_not]==0).*trial_selection)).combantipost_lickrate]);
        
        classifier(counter_sessions).task_structure_1 = mean([helpers_classifier{session}(trial_selection).anticipatory_lickrate])-classifier(counter_sessions).baseline_lickrate;
        classifier(counter_sessions).task_structure_2 = classifier(counter_sessions).post_non_reward_lickrate-classifier(counter_sessions).baseline_lickrate;
        classifier(counter_sessions).task_structure_3 = classifier(counter_sessions).anticipatory_non_reward_lickrate-classifier(counter_sessions).baseline_lickrate;
        
        % definitions in info-file
        classifier_info.task_structure_1 = 'anticipatory lickrate - baseline'
        classifier_info.task_structure_2 = 'post non-reward lickrate - baseline'
        classifier_info.task_structure_3 = 'anticipatory non-reward lickrate - baseline'
        
        % update counter of sessions
        counter_sessions = counter_sessions + 1;
    end
end;

%% III. LEARNING STRUCTURE CLASSIFIERS
% only run if preselected in master script
if any(strcmp(classifier_selection,'learning'))
    % set counter for sessions
    counter_sessions=1;
    %% Loop over sessions
    for i_session = 1:length(session_selection)
        clear session;
        % define sessions as the real session number
        session = session_selection(i_session);
        %% III.1 Learning Metric: Early vs. Late for REWARD PROBABILITIES
        % idea:
        % - compare cases with high and low probability at early and late
        % state of a block
        % - cluster it into cases with high-reward prob (.75) and
        % low-reward prob (.25)
        classifier(counter_sessions).early_licks_25 = [];
        classifier(counter_sessions).late_licks_25 = [];
        classifier(counter_sessions).early_licks_75 = [];
        classifier(counter_sessions).late_licks_75 = [];
                    
        for i_block = 1:number_of_blocks;
            %% High prob
            clear indx_early_tp indx_late_tp
            % indices of all trials with high reward probability
            indx_highprob = find([helpers_classifier{session}.reward_prob] == .75);
            % selection of indices (from all trials with high reward probability) for 6 trials at the beginning of a block ("early")
            range_early = [(1+(length(helpers_classifier{session})/(number_of_blocks*2))*(i_block-1)):((length(helpers_classifier{session})/(number_of_blocks*2))*(i_block-1)+number_of_trials_considered)];
            indx_early_tp = indx_highprob(range_early);
            % selection of indices (from all trials with high reward probability) for 6 trials at the end of a block ("late")
            range_late = [((length(helpers_classifier{session})/(number_of_blocks*2))*(i_block)-(number_of_trials_considered-1)):(length(helpers_classifier{session})/(number_of_blocks*2))*(i_block)];
            indx_late_tp = indx_highprob(range_late);
            
            % mean early_lickrate for 75% probability per block
            classifier(counter_sessions).early_lickrate_highprob(i_block) = mean([helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]);
            classifier(counter_sessions).early_licks_75 = [classifier(counter_sessions).early_licks_75,[helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]];
            % mean late_lickrate for 75% probability per block
            classifier(counter_sessions).late_lickrate_highprob(i_block) = mean([helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]);
            classifier(counter_sessions).late_licks_75 = [classifier(counter_sessions).late_licks_75,[helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]];
                        
            
            %% Low prob
            clear indx_lowprob indx_early_tp indx_late_tp
            % indices of all trials with low reward probability
            indx_lowprob = find([helpers_classifier{session}.reward_prob] == .25);
            % selection of indices (from all trials with low reward probability) for 6 trials at the beginning of a block ("early")
            indx_early_tp = indx_lowprob(range_early);
            % selection of indices (from all trials with low reward probability) for 6 trials at the end of a block ("late")
            indx_late_tp = indx_lowprob(range_late);
            
            % mean early_lickrate for 25% probability per block
            classifier(counter_sessions).early_lickrate_lowprob(i_block) = mean([helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]);
            classifier(counter_sessions).early_licks_25 = [classifier(counter_sessions).early_licks_25,[helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]];
            % mean late_lickrate for 25% probability per block
            classifier(counter_sessions).late_lickrate_lowprob(i_block) = mean([helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]);
            classifier(counter_sessions).late_licks_25 = [classifier(counter_sessions).late_licks_25,[helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]];
            
            %% Calculation of metrics (learning_high_EarlyLate_blocks, learning_low_EarlyLate_blocks) per block
            % - high and low probability
            %
            classifier(counter_sessions).learning_1_blocks_EL_prob75(i_block) = classifier(counter_sessions).early_lickrate_highprob(i_block)-classifier(counter_sessions).late_lickrate_highprob(i_block);
            classifier_info.learning_1_blocks_EL_prob75{1} = '75 % RP, anticipatory'
            classifier_info.learning_1_blocks_EL_prob75{2} = 'DIFF(early - late lickrate)';
            
            classifier(counter_sessions).learning_1_blocks_EL_prob25(i_block) = classifier(counter_sessions).early_lickrate_lowprob(i_block)-classifier(counter_sessions).late_lickrate_lowprob(i_block);
            classifier_info.learning_1_blocks_EL_prob25{1} = '25 % RP, anticipatory'
            classifier_info.learning_1_blocks_EL_prob25{2} = 'DIFF(early - late lickrate)';
        end
        
        
        %% III.2 Learning Metric: Early vs. Late for ODORS
        % idea:
        % - compare cases with high and low probability at early and late
        % state of a block
        % - cluster it into cases with odor 5 and odor 9
        
        for i_block = 1:number_of_blocks;
            %% Odor 5
            clear indx_early_tp indx_late_tp
            % indices of all trials with high reward probability
            indx_odor_5 = find([helpers_classifier{session}.curr_odor_num] == 5);
            % selection of indices (from all trials with high reward probability) for 6 trials at the beginning of a block ("early")
            range_early = [(1+(length(helpers_classifier{session})/(number_of_blocks*2))*(i_block-1)):((length(helpers_classifier{session})/(number_of_blocks*2))*(i_block-1)+number_of_trials_considered)];
            range_late = [((length(helpers_classifier{session})/(number_of_blocks*2))*(i_block)-(number_of_trials_considered-1)):(length(helpers_classifier{session})/(number_of_blocks*2))*(i_block)];
            
            indx_early_tp = indx_odor_5(range_early);
            % selection of indices (from all trials with high reward probability) for 6 trials at the end of a block ("late")
            indx_late_tp = indx_odor_5(range_late);
            
            classifier(counter_sessions).early_lickrate_odor_5(i_block) = mean([helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]);
            classifier(counter_sessions).late_lickrate_odor_5(i_block) = mean([helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]);
            
            %% Odor 9
            clear indx_early_tp indx_late_tp
            % indices of all trials with low reward probability
            indx_odor_9 = find([helpers_classifier{session}.curr_odor_num] == 9);
            % selection of indices (from all trials with low reward probability) for 6 trials at the beginning of a block ("early")
            indx_early_tp = indx_odor_9(range_early);
            % selection of indices (from all trials with low reward probability) for 6 trials at the end of a block ("late")
            indx_late_tp = indx_odor_9(range_late);
            
            classifier(counter_sessions).early_lickrate_odor_9(i_block) = mean([helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]);
            classifier(counter_sessions).late_lickrate_odor_9(i_block) = mean([helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]);
            
            classifier(counter_sessions).motiv_EL(i_block) = (classifier(counter_sessions).early_lickrate_odor_5(i_block)+ classifier(counter_sessions).early_lickrate_odor_9(i_block))-(classifier(counter_sessions).late_lickrate_odor_5(i_block) + classifier(counter_sessions).late_lickrate_odor_9(i_block));
            
            % 9 vs. 5
            if (helpers_classifier{session}(1).curr_odor_num==5 & helpers_classifier{session}(1).reward_prob==.75) | (helpers_classifier{session}(1).curr_odor_num==9 & helpers_classifier{session}(1).reward_prob==.25)
                classifier(counter_sessions).learning_sub2_od5_75start_DIFFod5od9_early(i_block) = classifier(counter_sessions).early_lickrate_odor_5(i_block)-classifier(counter_sessions).early_lickrate_odor_9(i_block);
                classifier_info.learning_sub2_od5_75start_DIFFod5od9_early{1} = 'odor 5, 75% start, early';
                classifier_info.learning_sub2_od5_75start_DIFFod5od9_early{2} = 'DIFF(od5-od9), lickrate [1/s]';
                
                classifier(counter_sessions).learning_sub2_od5_75start_DIFFod5od9_late(i_block) = classifier(counter_sessions).late_lickrate_odor_5(i_block)-classifier(counter_sessions).late_lickrate_odor_9(i_block);
                classifier_info.learning_sub2_od5_75start_DIFFod5od9_late{1} = 'odor 5, 75% start, late';
                classifier_info.learning_sub2_od5_75start_DIFFod5od9_late{2} = 'DIFF(od5-od9), lickrate [1/s]';
                
                classifier(counter_sessions).learning_2_odX1_75start_DIFFodX1odX2_early(i_block) = classifier(counter_sessions).learning_sub2_od5_75start_DIFFod5od9_early(i_block);
                classifier(counter_sessions).learning_2_odX1_75start_DIFFodX1odX2_late(i_block) = classifier(counter_sessions).learning_sub2_od5_75start_DIFFod5od9_late(i_block);
                
            elseif (helpers_classifier{session}(1).curr_odor_num==5 & helpers_classifier{session}(1).reward_prob==.25) | (helpers_classifier{session}(1).curr_odor_num==9 & helpers_classifier{session}(1).reward_prob==.75)
                classifier(counter_sessions).learning_sub2_od9_75start_DIFFod9od5_early(i_block) = classifier(counter_sessions).early_lickrate_odor_9(i_block)-classifier(counter_sessions).early_lickrate_odor_5(i_block);
                classifier_info.learning_sub2_od9_75start_DIFFod9od5_early{1} = 'odor 9, 75% start, early';
                classifier_info.learning_sub2_od9_75start_DIFFod9od5_early{2} = 'DIFF(od9-od5), lickrate [1/s]';
                
                classifier(counter_sessions).learning_sub2_od9_75start_DIFFod9od5_late(i_block) = classifier(counter_sessions).late_lickrate_odor_9(i_block)-classifier(counter_sessions).late_lickrate_odor_5(i_block);
                classifier_info.learning_sub2_od9_75start_DIFFod9od5_late{1} = 'odor 9, 75% start, late';
                classifier_info.learning_sub2_od9_75start_DIFFod9od5_late{2} = 'DIFF(od9-od5), lickrate [1/s]';
                
                classifier(counter_sessions).learning_2_odX1_75start_DIFFodX1odX2_early(i_block) = classifier(counter_sessions).learning_sub2_od9_75start_DIFFod9od5_early(i_block);
                classifier(counter_sessions).learning_2_odX1_75start_DIFFodX1odX2_late(i_block) = classifier(counter_sessions).learning_sub2_od9_75start_DIFFod9od5_late(i_block);
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_early{1} = 'early';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_early{2} = 'DIFF(odor X1-odor X2), lickrate [1/s]';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_early{3,1} = 'Bl.1: odX1 75%, odX2 25%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_early{3,2} = 'Bl.2: odX1 25%, odX2 75%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_early{3,3} = 'Bl.3: odX1 75%, odX2 25%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_early{3,4} = 'Bl.4: odX1 25%, odX2 75%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_late{1} = 'late';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_late{2} = 'DIFF(odor X1-odor X2), lickrate [1/s]';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_late{3,1} = 'Bl.1: odX1 75%, odX2 25%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_late{3,2} = 'Bl.2: odX1 25%, odX2 75%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_late{3,3} = 'Bl.3: odX1 75%, odX2 25%';
                classifier_info.learning_2_odX1_75start_DIFFodX1odX2_late{3,4} = 'Bl.4: odX1 25%, odX2 75%';
                
            end;
            
        end
        
        for i_block = 1:number_of_blocks;
            if classifier(counter_sessions).motiv_EL(i_block)>0
                classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob75(i_block) = (classifier(counter_sessions).early_lickrate_highprob(i_block)-classifier(counter_sessions).motiv_EL(i_block))-(classifier(counter_sessions).late_lickrate_highprob(i_block));
                classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob25(i_block) = (classifier(counter_sessions).early_lickrate_lowprob(i_block)-classifier(counter_sessions).motiv_EL(i_block))-classifier(counter_sessions).late_lickrate_lowprob(i_block);
                classifier_info.learning_1_blocks_corrmotiv_EL_prob75{1} = '75 % RP, motiv. corr.'
                classifier_info.learning_1_blocks_corrmotiv_EL_prob75{2} = 'DIFF(early - late lickrate)';
            elseif classifier(counter_sessions).motiv_EL(i_block)<0
                classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob25(i_block) = classifier(counter_sessions).early_lickrate_lowprob(i_block)-(classifier(counter_sessions).late_lickrate_lowprob(i_block)-classifier(counter_sessions).motiv_EL(i_block));
                classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob75(i_block) = classifier(counter_sessions).early_lickrate_highprob(i_block)-(classifier(counter_sessions).late_lickrate_highprob(i_block)-classifier(counter_sessions).motiv_EL(i_block));
                classifier_info.learning_1_blocks_corrmotiv_EL_prob25{1} = '25 % RP, motiv. corr.'
                classifier_info.learning_1_blocks_corrmotiv_EL_prob25{2} = 'DIFF(early - late lickrate)';
            elseif classifier(counter_sessions).motiv_EL(i_block)==0
                classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob75(i_block) = classifier(counter_sessions).early_lickrate_highprob(i_block)-classifier(counter_sessions).late_lickrate_highprob(i_block);
                classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob25(i_block) = classifier(counter_sessions).early_lickrate_lowprob(i_block)-classifier(counter_sessions).late_lickrate_lowprob(i_block);
            end
        end
        
        
        
        %% III. Post_non-Rewarded
        for i_block = 1:number_of_blocks;
            %% High prob
            clear indx_early_tp indx_late_tp
            % indices of all trials with high reward probability
            indx_highprob = find([helpers_classifier{session}.reward_prob] == .75 & [helpers_classifier{session}.drop_or_not] == 0);
            % selection of indices (from all trials with high reward probability) for 6 trials at the beginning of a block ("early")
            range_early = [(1+(length(helpers_classifier{session})/(number_of_blocks*8))*(i_block-1)):((length(helpers_classifier{session})/(number_of_blocks*8))*(i_block-1)+2)];
            indx_early_tp = indx_highprob(range_early);
            % selection of indices (from all trials with high reward probability) for 6 trials at the end of a block ("late")
            range_late = [((length(helpers_classifier{session})/(number_of_blocks*8))*(i_block)-(2-1)):(length(helpers_classifier{session})/(number_of_blocks*8))*(i_block)];
            indx_late_tp = indx_highprob(range_late);
            
            % mean early_lickrate for 75% probability per block
            classifier(counter_sessions).early_lickrate_highprob_nonrew(i_block) = mean([helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]);
            % mean late_lickrate for 75% probability per block
            classifier(counter_sessions).late_lickrate_highprob_nonrew(i_block) = mean([helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]);
            
            %% Low prob
            clear indx_lowprob indx_early_tp indx_late_tp
            % indices of all trials with low reward probability
            indx_lowprob = find([helpers_classifier{session}.reward_prob] == .25 & [helpers_classifier{session}.drop_or_not] == 0);
            % selection of indices (from all trials with low reward probability) for 6 trials at the beginning of a block ("early")
            range_early = [(1+(length(helpers_classifier{session})/(number_of_blocks*(8/3))*(i_block-1))):((length(helpers_classifier{session})/(number_of_blocks*(8/3)))*(i_block-1)+5)];
            indx_early_tp = indx_lowprob(range_early);
            % selection of indices (from all trials with high reward probability) for 6 trials at the end of a block ("late")
            range_late = [((length(helpers_classifier{session})/(number_of_blocks*(8/3))*(i_block)-(5-1))):(length(helpers_classifier{session})/(number_of_blocks*(8/3))*(i_block))];
            indx_late_tp = indx_lowprob(range_late);
            
            % mean early_lickrate for 25% probability per block
            classifier(counter_sessions).early_lickrate_lowprob_nonrew(i_block) = mean([helpers_classifier{session}(indx_early_tp).anticipatory_lickrate]);
            % mean late_lickrate for 25% probability per block
            classifier(counter_sessions).late_lickrate_lowprob_nonrew(i_block) = mean([helpers_classifier{session}(indx_late_tp).anticipatory_lickrate]);
            
            %% Calculation of metrics (learning_high_EarlyLate_blocks, learning_low_EarlyLate_blocks) per block
            % - high and low probability
            %
            classifier(counter_sessions).learning_1_blocks_nonrew_EL_prob75(i_block) = classifier(counter_sessions).early_lickrate_highprob_nonrew(i_block)-classifier(counter_sessions).late_lickrate_highprob_nonrew(i_block);
            classifier_info.learning_1_blocks_nonrew_EL_prob75{1} = '75 % RP, post non-rew'
            classifier_info.learning_1_blocks_nonrew_EL_prob75{2} = 'DIFF(early - late lickrate)';
            
            classifier(counter_sessions).learning_1_blocks_nonrew_EL_prob25(i_block) = classifier(counter_sessions).early_lickrate_lowprob_nonrew(i_block)-classifier(counter_sessions).late_lickrate_lowprob_nonrew(i_block);
            classifier_info.learning_1_blocks_nonrew_EL_prob25{1} = '25 % RP, post non-rew'
            classifier_info.learning_1_blocks_nonrew_EL_prob25{2} = 'DIFF(early - late lickrate)';
        end
        
        % 75% RP and 25% RP means, anticipatory
        classifier(counter_sessions).learning_1_mean_EL_prob75 = mean(classifier(counter_sessions).learning_1_blocks_EL_prob75);
        classifier_info.learning_1_mean_EL_prob75{1} = '75% RP, mean over blocks, ant'
        classifier_info.learning_1_mean_EL_prob75{2} = 'DIFF(early - late lickrate)';
        
        classifier(counter_sessions).learning_1_mean_EL_prob25 = mean(classifier(counter_sessions).learning_1_blocks_EL_prob25);
        classifier_info.learning_1_mean_EL_prob25{1} = '25% RP, mean over blocks, ant'
        classifier_info.learning_1_mean_EL_prob25{2} = 'DIFF(early - late lickrate)';

        % 75% RP and 25% RP means, post non-ew
        classifier(counter_sessions).learning_1_mean_EL_prob75 = mean(classifier(counter_sessions).learning_1_blocks_nonrew_EL_prob75);
        classifier_info.learning_1_mean_nonrew_EL_prob75{1} = '75% RP, mean over blocks, post non-rew'
        classifier_info.learning_1_mean_nonrew_EL_prob75{2} = 'DIFF(early - late lickrate)';
        
        classifier(counter_sessions).learning_1_mean_EL_prob25 = mean(classifier(counter_sessions).learning_1_blocks_nonrew_EL_prob25);
        classifier_info.learning_1_mean_nonrew_EL_prob25{1} = '25% RP, mean over blocks, post non-rew'
        classifier_info.learning_1_mean_nonrew_EL_prob25{2} = 'DIFF(early - late lickrate)';
        
        % 75% RP and 25% RP means, anticipatory - corrmotiv
        classifier(counter_sessions).learning_1_mean_corrmotiv_EL_prob75 = mean(classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob75(i_block));
        classifier_info.learning_1_mean_corrmotiv_EL_prob75{1} = '75% RP, mean over blocks, corr for motiv'
        classifier_info.learning_1_mean_corrmotiv_EL_prob75{2} = 'DIFF(early - late lickrate)';
        
        classifier(counter_sessions).learning_1_mean_corrmotiv_EL_prob25 = mean(classifier(counter_sessions).learning_1_blocks_corrmotiv_EL_prob25(i_block));
        classifier_info.learning_1_mean_corrmotiv_EL_prob25{1} = '25% RP, mean over blocks, corr for motiv'
        classifier_info.learning_1_mean_corrmotiv_EL_prob25{2} = 'DIFF(early - late lickrate)';
        % update counter of sessions
        
        counter_sessions = counter_sessions + 1;
    end
end