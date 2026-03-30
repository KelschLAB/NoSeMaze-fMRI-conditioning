%% This script extracts features of learning and CS+/- processing from the licking behavior in AM for correlation to fMRI
% David Wolf, 06.2023
clear; close all;
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/03-GNG'));

% The reappraisal scan was the first scan and occurred between the 07/22
% and 07/29. So all animals had experienced 4 reversals before it.
%   Variante 1: compute learning parameters before the reappraisal scan
%   Variante 2: compute learning parameters for the longest duration
%   available (while keeping the max number of animals in). Two animals had
%   been excluded after reappraisal, so the parameters are incomplete for
%   them and correlation would not be possible.

%% AM1
processed_data_path = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/01-AM1/02-GNG_task';
plot_output = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/01-AM1/02-GNG_task';

%% AM2
processed_data_path = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/02-AM2/02-GNG_task';
plot_output = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/02-AM2/02-GNG_task';

if 1==0
    % combine the single animal days into one d-struct for compatibility to
    % other scripts
    tic
    d_am1 = combine_single_animals(processed_data_path);
    toc
    
    % remove wrong animals
    d_am1_short = d_am1;
    animal_names = []; for an=1:numel(d_am1_short); animal_names = cat(1,animal_names,{d_am1_short(an).events(1).ID}); end
    d_am1_short(contains(animal_names,{'0007CB2086','0007CB0F95','0007CB090F'})) = [];
    
    % remove wrong animals
    animal_names = []; for an=1:numel(d_am1); animal_names = cat(1,animal_names,{d_am1(an).events(1).ID}); end
    d_am1(contains(animal_names,{'0007CB330D','0007CB0ABC','0007CB2086','0007CB0F95','0007CB090F'})) = [];
    
    % plot PSTH for all animals
    % plot_raw_lickdata(d_am1,plot_output);
    
    % compute learning features
    lick_params_am1 = compute_learning_parameters_ICON_jr(d_am1,12,plot_output);
    
    % compute learning features
    lick_params_am1_short = compute_learning_parameters_ICON_jr(d_am1_short,5,plot_output);
    
    % combine the single animal days into one d-struct for compatibility to
    % other scripts
    d_am2 = combine_single_animals(processed_data_path);
    
    % plot PSTH for all animals
    % plot_raw_lickdata(d_am2,plot_output);
    
    % compute learning features
    lick_params_am2 = compute_learning_parameters_ICON_jr(d_am2,12,plot_output);
    lick_params_am2_short = compute_learning_parameters_ICON_jr(d_am2,5,plot_output); % short is only up to reversal scan
    
    %% combine AM1 & AM2
    
    lick_params = struct2table(cat(2,lick_params_am1,lick_params_am2));
    lick_params_short = struct2table(cat(2,lick_params_am1_short,lick_params_am2_short));
    
    % save output
    writetable(lick_params,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params.xlsx'));
    save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params.mat'),'lick_params');
    
    % save output
    writetable(lick_params_short,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params.xlsx'));
    save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params.mat'),'lick_params_short');
end

% load data
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params.mat'),'lick_params');
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params.mat'),'lick_params_short');

%% Feature analysis: inspect feature distributions and decide which features should be log-transformed before PCA
plot_output = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/histograms/';
if ~isfolder(plot_output); mkdir(plot_output); end
plot_output_short = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/histograms/';
if ~isfolder(plot_output_short); mkdir(plot_output_short); end

% predefine features of interest
plot_features = {'baseline_rate_mean_omitfirst','cs_plus_modulation_peak_minus_base','cs_minus_modulation_min_minus_base','cs_plus_modulation_peak','cs_minus_modulation_min','cs_plus_ramping','cs_plus_detection_speed','cs_minus_detection_speed',...
    'cs_plus_switch_latency_at_cs_rev2','cs_plus_switch_latency_at_cs_rev3','cs_plus_switch_latency_at_cs_rev4','cs_minus_switch_latency_at_cs_rev2','cs_minus_switch_latency_at_cs_rev3','cs_minus_switch_latency_at_cs_rev4',...
    'delay_avoidance_learner','correct_rejection_rate','correct_hit_rate','correct_rejection_rate_all','correct_hit_rate_all'};
BinWidth_features = {0.5,1,1,1,0.25,1,0.1,0.1,...
    50,50,50,50,50,50,...
    0.5,0.05,0.05,0.05,0.05};
XLimits_features = {[0,10],[-12,12],[-12,12],[0,12],[0,4],[0,16],[0,1],[0,1],...
    [0,1000],[0,1000],[0,1000],[0,1000],[0,1000],[0,1000],...
    [0,1],[0,1],[0,1],[0,1],[0,1]};

% plot distributions of selected features
if 1==0
    for ii = 1:numel(plot_features)
        f=figure;
        clear plot_data
        plot_data = lick_params.(plot_features{ii});
        histogram(plot_data(~isnan(plot_data)),'EdgeColor','none','BinWidth',BinWidth_features{ii});
        box off
        ax=gca;
        ax.XLim=XLimits_features{ii};
        title(plot_features{ii},'Interpreter','none');
        saveas(f,fullfile(plot_output,[plot_features{ii},'_original.png']),'png');
        saveas(f,fullfile(plot_output,[plot_features{ii},'_original.pdf']),'pdf');
        close all;
        
        f=figure;
        clear plot_data
        plot_data = lick_params_short.(plot_features{ii});
        histogram(plot_data(~isnan(plot_data)),'EdgeColor','none','BinWidth',BinWidth_features{ii});
        box off
        ax=gca;
        ax.XLim=XLimits_features{ii};
        title(plot_features{ii},'Interpreter','none');
        saveas(f,fullfile(plot_output_short,[plot_features{ii},'_short_original.png']),'png');
        saveas(f,fullfile(plot_output_short,[plot_features{ii},'_short_original.pdf']),'pdf');
        close all;
    end
end

%% For lick_params_short
if 1==1
    % boxcox transformation and plotting
    for ii = 1:numel(plot_features)
        
        % preparation
        clear myData
        myData = lick_params_short.(plot_features{ii});
        myData_red = myData(~isnan(myData) & ~isinf(myData));
        data_transformation(ii).metric_name = plot_features{ii};
        data_transformation(ii).original_data = myData_red;
        
        % 1. test for normality with sw and ks
        [data_transformation(ii).H_sw, data_transformation(ii).pValue_sw, data_transformation(ii).W_sw] = swtest(myData_red);
        [data_transformation(ii).H_ks, data_transformation(ii).pValue_ks, ~, ~] = kstest(myData_red);
        
        % 2. data transformation
        if data_transformation(ii).H_sw==1 || data_transformation(ii).H_ks==1
            
            % 2.1 tranformation (searching for optimal lambda and transform
            % data)
            % Add a small constant to avoid zero or negative values
            if min(myData_red)<0
                epsilon = ceil(abs(min(myData_red)));
            else
                epsilon = 1e-3; % Small constant
            end
            data_adj = myData_red + epsilon;
            
            % Define a range of lambda values to test
            lambda_values = -10:0.01:10;
            % Initialize variable to store the maximum log-likelihood and the best lambda
            max_log_likelihood = -Inf;
            best_lambda = NaN;
            % Iterate over each lambda value
            for lambda = lambda_values
                if lambda == 0
                    % For lambda = 0, use log transformation
                    transformed_data = log(data_adj);
                else
                    % Box-Cox transformation for lambda != 0
                    transformed_data = (data_adj .^ lambda - 1) / lambda;
                end
                % Calculate the log-likelihood
                n = length(data_adj);
                log_likelihood = -n/2 * log(var(transformed_data)) + (lambda - 1) * sum(log(data_adj));
                % Update the best lambda if the current log-likelihood is higher
                if log_likelihood > max_log_likelihood
                    max_log_likelihood = log_likelihood;
                    best_lambda = lambda;
                end
            end
            % Display the optimal lambda
            disp('Optimal Lambda:');
            disp(best_lambda);
            
            if best_lambda == 0
                transformed_data_boxcox = myData_red;
                transformed_data_log10 = log10(data_adj);
            else
                transformed_data_boxcox = (data_adj .^ best_lambda - 1) / best_lambda;
                transformed_data_log10 = log10(data_adj);
            end
            
            % 2.2 test for normality with transformed data
            [data_transformation(ii).H_sw_transformed_boxcox, data_transformation(ii).pValue_sw_transformed_boxcox, ~] = swtest(transformed_data_boxcox);
            [data_transformation(ii).H_ks_transformed_boxcox, data_transformation(ii).pValue_ks_transformed_boxcox, ~, ~] = kstest(transformed_data_boxcox);
            [data_transformation(ii).H_sw_log10, data_transformation(ii).pValue_sw_log10, ~] = swtest(transformed_data_log10);
            [data_transformation(ii).H_ks_log10, data_transformation(ii).pValue_ks_log10, ~, ~] = kstest(transformed_data_log10);
            data_transformation(ii).transformed_data_boxcox = transformed_data_boxcox;
            data_transformation(ii).transformed_data_log10 = transformed_data_log10;
            data_transformation(ii).best_lambda = best_lambda;
            
            % 2.3 redo plotting
            f=figure;
            histogram(data_transformation(ii).transformed_data_boxcox,'EdgeColor','none');
            box off
            title([plot_features{ii} ' (transformed boxcox)'],'Interpreter','none');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedBoxCox.png']),'png');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedBoxCox.pdf']),'pdf');
            close all;
            
            f=figure;
            histogram(data_transformation(ii).transformed_data_log10,'EdgeColor','none');
            box off
            title([plot_features{ii} ' (transformed log10)'],'Interpreter','none');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedLog10.png']),'png');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedLog10.pdf']),'pdf');
            close all;
        end
        
        % preparation
        lick_params_short = [lick_params_short,table(nan(height(lick_params_short),1),'VariableNames',{['log10(' plot_features{ii} ')']})];
        lick_params_short.(['log10(' plot_features{ii} ')'])(find(~isnan(myData) & ~isinf(myData))) = data_transformation(ii).transformed_data_log10;
        
        lick_params_short = [lick_params_short,table(nan(height(lick_params_short),1),'VariableNames',{['boxcox(' plot_features{ii} ')']})];
        lick_params_short.(['boxcox(' plot_features{ii} ')'])(find(~isnan(myData) & ~isinf(myData))) = data_transformation(ii).transformed_data_boxcox;
    end
    
    % % save output
    writetable(lick_params_short,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params_transformed.xlsx'));
    save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params_transformed.mat'),'lick_params_short');
    save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','data_transformation.mat'),'data_transformation');
end

%% For lick_params
if 1==1
    % boxcox transformation and plotting
    for ii = 1:numel(plot_features)
        
        % preparation
        clear myData
        myData = lick_params.(plot_features{ii});
        myData_red = myData(~isnan(myData) & ~isinf(myData));
        data_transformation(ii).metric_name = plot_features{ii};
        data_transformation(ii).original_data = myData_red;
        
        % 1. test for normality with sw and ks
        [data_transformation(ii).H_sw, data_transformation(ii).pValue_sw, data_transformation(ii).W_sw] = swtest(myData_red);
        [data_transformation(ii).H_ks, data_transformation(ii).pValue_ks, ~, ~] = kstest(myData_red);
        
        % 2. data transformation
        if data_transformation(ii).H_sw==1 || data_transformation(ii).H_ks==1
            
            % 2.1 tranformation (searching for optimal lambda and transform
            % data)
            % Add a small constant to avoid zero or negative values
            if min(myData_red)<0
                epsilon = ceil(abs(min(myData_red)));
            else
                epsilon = 1e-3; % Small constant
            end
            data_adj = myData_red + epsilon;
            
            % Define a range of lambda values to test
            lambda_values = -10:0.01:10;
            % Initialize variable to store the maximum log-likelihood and the best lambda
            max_log_likelihood = -Inf;
            best_lambda = NaN;
            % Iterate over each lambda value
            for lambda = lambda_values
                if lambda == 0
                    % For lambda = 0, use log transformation
                    transformed_data = log(data_adj);
                else
                    % Box-Cox transformation for lambda != 0
                    transformed_data = (data_adj .^ lambda - 1) / lambda;
                end
                % Calculate the log-likelihood
                n = length(data_adj);
                log_likelihood = -n/2 * log(var(transformed_data)) + (lambda - 1) * sum(log(data_adj));
                % Update the best lambda if the current log-likelihood is higher
                if log_likelihood > max_log_likelihood
                    max_log_likelihood = log_likelihood;
                    best_lambda = lambda;
                end
            end
            % Display the optimal lambda
            disp('Optimal Lambda:');
            disp(best_lambda);
            
            if best_lambda == 0
                transformed_data_boxcox = myData_red;
                transformed_data_log10 = log10(data_adj);
            else
                transformed_data_boxcox = (data_adj .^ best_lambda - 1) / best_lambda;
                transformed_data_log10 = log10(data_adj);
            end
            
            % 2.2 test for normality with transformed data
            [data_transformation(ii).H_sw_transformed_boxcox, data_transformation(ii).pValue_sw_transformed_boxcox, ~] = swtest(transformed_data_boxcox);
            [data_transformation(ii).H_ks_transformed_boxcox, data_transformation(ii).pValue_ks_transformed_boxcox, ~, ~] = kstest(transformed_data_boxcox);
            [data_transformation(ii).H_sw_log10, data_transformation(ii).pValue_sw_log10, ~] = swtest(transformed_data_log10);
            [data_transformation(ii).H_ks_log10, data_transformation(ii).pValue_ks_log10, ~, ~] = kstest(transformed_data_log10);
            data_transformation(ii).transformed_data_boxcox = transformed_data_boxcox;
            data_transformation(ii).transformed_data_log10 = transformed_data_log10;
            data_transformation(ii).best_lambda = best_lambda;
            
            % 2.3 redo plotting
            f=figure;
            histogram(data_transformation(ii).transformed_data_boxcox,'EdgeColor','none');
            box off
            title([plot_features{ii} ' (transformed boxcox)'],'Interpreter','none');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedBoxCox.png']),'png');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedBoxCox.pdf']),'pdf');
            close all;
            
            f=figure;
            histogram(data_transformation(ii).transformed_data_log10,'EdgeColor','none');
            box off
            title([plot_features{ii} ' (transformed log10)'],'Interpreter','none');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedLog10.png']),'png');
            saveas(f,fullfile(plot_output,[plot_features{ii},'_transformedLog10.pdf']),'pdf');
            close all;
        end
        
        % preparation
        lick_params = [lick_params,table(nan(height(lick_params),1),'VariableNames',{['log10(' plot_features{ii} ')']})];
        lick_params.(['log10(' plot_features{ii} ')'])(find(~isnan(myData) & ~isinf(myData))) = data_transformation(ii).transformed_data_log10;
        
        lick_params = [lick_params,table(nan(height(lick_params),1),'VariableNames',{['boxcox(' plot_features{ii} ')']})];
        lick_params.(['boxcox(' plot_features{ii} ')'])(find(~isnan(myData) & ~isinf(myData))) = data_transformation(ii).transformed_data_boxcox;
    end
    
    % % save output
    writetable(lick_params,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params_transformed.xlsx'));
    save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params_transformed.mat'),'lick_params');
    save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','data_transformation.mat'),'data_transformation');
end



























% % 
% % %% Correlate features pairwise to see if short and long actually differ by a lot
% % clear;
% % load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params_new.mat'),'lick_params');
% % load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params_new.mat'),'lick_params_short');
% % plot_output = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/correlation';
% % 
% % % do pairwise correlations of the same feature
% % lick_params_short_fieldnames = lick_params_short.Properties.VariableNames;
% % lick_params_fieldnames = lick_params.Properties.VariableNames;
% % 
% % ID_long = lick_params.ID;
% % ID_short = lick_params_short.ID;
% % lick_params_short(~contains(ID_short,ID_long),:) = [];
% % 
% % % sort alphabetically to match IDs
% % lick_params = sortrows(lick_params,'ID','ascend');
% % lick_params_short = sortrows(lick_params_short,'ID','ascend');
% % 
% % R = [];
% % for ii = [2:5,7:numel(lick_params_fieldnames)]
% %     
% %     % find matching feature in short
% %     short_idx = find(strcmp(lick_params_short_fieldnames,lick_params_fieldnames{ii}));
% %     
% %     if ~isempty(short_idx)
% %         % pairwise correlation
% %         [Rho,pval] = corr(table2array(lick_params(:,ii)),table2array(lick_params_short(:,short_idx)));
% %         
% %         % plot
% %         f = figure;
% %         scatter(table2array(lick_params(:,ii)),table2array(lick_params_short(:,short_idx)));
% %         xlabel({lick_params_fieldnames{ii},'long'},'Interpreter','none');
% %         ylabel({lick_params_short_fieldnames{short_idx},'short'},'Interpreter','none');
% %         lsline;
% %         title({['R = ',num2str(Rho)],['p = ',num2str(pval)]});
% %         saveas(f,fullfile(plot_output,[lick_params_fieldnames{ii},'.png']),'png');
% %         close all;
% %         
% %         R = cat(1,R,Rho);
% %         
% %     end
% %     
% % end




