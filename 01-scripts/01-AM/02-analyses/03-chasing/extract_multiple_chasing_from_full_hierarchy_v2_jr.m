function [full_hierarchy] = extract_multiple_chasing_from_full_hierarchy_v2_jr(full_hierarchy,time_threshold)
% subscript to extract the chasing features including the separation by a
% certain time threshold
% adapated by Jonathan Reinwald 03/2024

% loop over days
for day = 1:length(full_hierarchy)
    % empty multiple chasing matrix
    full_hierarchy(day).match_matrix_multiple_chasing = zeros(size(full_hierarchy(day).match_matrix_chasing));
    full_hierarchy(day).match_matrix_double_chasing = zeros(size(full_hierarchy(day).match_matrix_chasing));
    full_hierarchy(day).match_matrix_single_following = zeros(size(full_hierarchy(day).match_matrix_chasing));
    full_hierarchy(day).match_info_multiple_chasing = cell(size(full_hierarchy(day).match_matrix_chasing));
    full_hierarchy(day).match_info_single_following = cell(size(full_hierarchy(day).match_matrix_chasing));
    
    % find all events during the day (putative pairs for consecutive
    % following events within a short period of time) 
    [r1,r2]=find(full_hierarchy(day).match_matrix_chasing > 0);
    % 
    for r_idx = 1:length(r1)
        % differentiate the loser_entry_times to get an estimate of the
        % time between successive events
        % NOTE: only unidirectional events are considered, i.e., a1
        % chases a2 in the all the events, not switches of the chaser!
        time_between_events = diff([full_hierarchy(day).match_info_chasing{r1(r_idx),r2(r_idx)}.loser_entry_time]);
        % in two cases, the following is equivalent to the old chasing: 1.)
        % only one event (--> time_between_events is empty); 2.) all events
        % are having a time in between > threshold
        if isempty(time_between_events) || sum(time_between_events > time_threshold)==length(time_between_events)
            full_hierarchy(day).match_info_single_following{r1(r_idx),r2(r_idx)} = [full_hierarchy(day).match_info_chasing{r1(r_idx),r2(r_idx)}];
            full_hierarchy(day).match_matrix_single_following(r1(r_idx),r2(r_idx)) = full_hierarchy(day).match_matrix_chasing(r1(r_idx),r2(r_idx));
        elseif any(time_between_events < time_threshold)
            clear event_selection event_selection_following
            % short event pairs are assigned to the double/multiple chasing
            event_selection = logical([time_between_events < time_threshold,0] + [0,time_between_events < time_threshold]); % Note: select the respective event and the following event as a logical vector (to avoid numbers > 1)
            full_hierarchy(day).match_info_multiple_chasing{r1(r_idx),r2(r_idx)} = full_hierarchy(day).match_info_chasing{r1(r_idx),r2(r_idx)}(event_selection);
            full_hierarchy(day).match_matrix_multiple_chasing(r1(r_idx),r2(r_idx)) = full_hierarchy(day).match_matrix_multiple_chasing(r1(r_idx),r2(r_idx)) + sum(event_selection);
            full_hierarchy(day).match_matrix_double_chasing(r1(r_idx),r2(r_idx)) = full_hierarchy(day).match_matrix_double_chasing(r1(r_idx),r2(r_idx)) + sum(time_between_events < time_threshold);
            % the rest of the events pairs is assigned to the single following
            event_selection_following = ~logical(event_selection);
            full_hierarchy(day).match_info_single_following{r1(r_idx),r2(r_idx)} = full_hierarchy(day).match_info_chasing{r1(r_idx),r2(r_idx)}(event_selection_following);
            full_hierarchy(day).match_matrix_single_following(r1(r_idx),r2(r_idx)) = full_hierarchy(day).match_matrix_single_following(r1(r_idx),r2(r_idx)) + sum(event_selection_following);
        end
    end
    % Control: Single following and multiple chasing matrix have to be
    % equal to the "old" chasing
    if sum(sum(full_hierarchy(1).match_matrix_chasing - (full_hierarchy(1).match_matrix_multiple_chasing+full_hierarchy(1).match_matrix_single_following)))==0
        disp(['Day ' num2str(day) ' is correct']);
    else
        error(['Day ' num2str(day) ' has an error']);
    end
end

