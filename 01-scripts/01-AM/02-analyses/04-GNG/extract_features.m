%% This scrript extracts features of learning and CS+/- processing from the licking behavior in AM for correlation to fMRI
% David Wolf, 06.2023
clear; close all;
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/01-AM/02-analyses/03-GNG'));

% The reappraisal scan was the first scan and occurred between the 07/22
% and 07/29. So all animals had experienced 4 reversals before it.
%   Variante 1: compute learning parameters before the reappraisal scan
%   Variante 2: compute learning parameters for the longest duration
%   available (while keeping the max number of animals in). Two animals had
%   been excluded after reappraisal, so the parameters are incomplete for
%   them and correlation would not be possible.

%% AM1
processed_data_path = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/01-AM/01-AM1/02-GNG_task';
plot_output = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/02-GNG_task';

% combine the single animal days into one d-struct for compatibility to
% other scripts
d_am1 = combine_single_animals(processed_data_path);

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
lick_params_am1 = compute_learning_parameters_ICON(d_am1,12);

% compute learning features
lick_params_am1_short = compute_learning_parameters_ICON(d_am1_short,5);

%% AM2
processed_data_path = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/01-AM/02-AM2/02-GNG_task';
plot_output = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/02-GNG_task';

% combine the single animal days into one d-struct for compatibility to
% other scripts
d_am2 = combine_single_animals(processed_data_path);

% plot PSTH for all animals
% plot_raw_lickdata(d_am2,plot_output);

% compute learning features
lick_params_am2 = compute_learning_parameters_ICON(d_am2,12);
lick_params_am2_short = compute_learning_parameters_ICON(d_am2,5); % short is only up to reversal scan

%% combine AM1 & AM2

lick_params = struct2table(cat(2,lick_params_am1,lick_params_am2));
lick_params_short = struct2table(cat(2,lick_params_am1_short,lick_params_am2_short));


%% Feature analysis: inspect feature distributions and decide which features should be log-transformed before PCA

plot_output = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/histograms/';
if ~isfolder(plot_output); mkdir(plot_output); end
plot_output_short = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/histograms/';
if ~isfolder(plot_output_short); mkdir(plot_output_short); end

% plot distributions of all features
plot_features = [3,7:size(lick_params,2)];
for ii = 1:numel(plot_features)
   f=figure;
   histogram(table2array(lick_params(:,plot_features(ii))));
   title(lick_params.Properties.VariableNames{plot_features(ii)},'Interpreter','none');
   saveas(f,fullfile(plot_output,[num2str(plot_features(ii)),'_',lick_params.Properties.VariableNames{plot_features(ii)},'.png']),'png');
   close all;    
end

% select skewed features for log-transformation
log_transform_features = [3,7:13,38:85,87:91,93:136];
for ii = 1:numel(log_transform_features)
   if any(table2array(lick_params(:,log_transform_features(ii)))==0) % if 0 values exist, add smallest value/2 to everywhere to ensure log works
       lick_params.(['log10(',lick_params.Properties.VariableNames{log_transform_features(ii)},')']) = ...
           log10(table2array(lick_params(:,log_transform_features(ii)))+min(table2array(lick_params(table2array(lick_params(:,log_transform_features(ii)))>0,log_transform_features(ii))))./2);
   else
       lick_params.(['log10(',lick_params.Properties.VariableNames{log_transform_features(ii)},')']) = log10(table2array(lick_params(:,log_transform_features(ii))));
   end
   
   f=figure;
   histogram(lick_params.(['log10(',lick_params.Properties.VariableNames{log_transform_features(ii)},')']));
   title(['log10(',lick_params.Properties.VariableNames{log_transform_features(ii)},')'],'Interpreter','none');
   tmp_idx = find(strcmp(lick_params.Properties.VariableNames,['log10(',lick_params.Properties.VariableNames{log_transform_features(ii)},')']));
   saveas(f,fullfile(plot_output,[num2str(tmp_idx),'_','log10(',lick_params.Properties.VariableNames{log_transform_features(ii)},')','.png']),'png');
   close all;    
end

% save output
writetable(lick_params,fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params.xlsx'));
save(fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params.mat'),'lick_params');

%%%% same for the short lick params

% plot distributions of all features
plot_features = [3,7:size(lick_params_short,2)];
for ii = 1:numel(plot_features)
   f=figure;
   histogram(table2array(lick_params_short(:,plot_features(ii))));
   title(lick_params_short.Properties.VariableNames{plot_features(ii)},'Interpreter','none');
   saveas(f,fullfile(plot_output_short,[num2str(plot_features(ii)),'_',lick_params_short.Properties.VariableNames{plot_features(ii)},'.png']),'png');
   close all;    
end

% select skewed features for log-transformation
log_transform_features = [3,7:13,24:43,45:49,51:73];
for ii = 1:numel(log_transform_features)
   if any(table2array(lick_params_short(:,log_transform_features(ii)))==0) % if 0 values exist, add smallest value/2 to everywhere to ensure log works
       lick_params_short.(['log10(',lick_params_short.Properties.VariableNames{log_transform_features(ii)},')']) = ...
           log10(table2array(lick_params_short(:,log_transform_features(ii)))+min(table2array(lick_params_short(table2array(lick_params_short(:,log_transform_features(ii)))>0,log_transform_features(ii))))./2);
   else
       lick_params_short.(['log10(',lick_params_short.Properties.VariableNames{log_transform_features(ii)},')']) = log10(table2array(lick_params_short(:,log_transform_features(ii))));
   end
   
   f=figure;
   histogram(lick_params_short.(['log10(',lick_params_short.Properties.VariableNames{log_transform_features(ii)},')']));
   title(['log10(',lick_params_short.Properties.VariableNames{log_transform_features(ii)},')'],'Interpreter','none');
   tmp_idx = find(strcmp(lick_params_short.Properties.VariableNames,['log10(',lick_params_short.Properties.VariableNames{log_transform_features(ii)},')']));
   saveas(f,fullfile(plot_output_short,[num2str(tmp_idx),'_','log10(',lick_params_short.Properties.VariableNames{log_transform_features(ii)},')','.png']),'png');
   close all;    
end


% save output
writetable(lick_params_short,fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params.xlsx'));
save(fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params.mat'),'lick_params_short');


%% Correlate features pairwise to see if short and long actually differ by a lot
clear;
load(fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/','lick_params.mat'),'lick_params');
load(fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','lick_params.mat'),'lick_params_short');
plot_output = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/correlation';

% do pairwise correlations of the same feature
lick_params_short_fieldnames = lick_params_short.Properties.VariableNames;
lick_params_fieldnames = lick_params.Properties.VariableNames;

ID_long = lick_params.ID;
ID_short = lick_params_short.ID;
lick_params_short(~contains(ID_short,ID_long),:) = [];

% sort alphabetically to match IDs
lick_params = sortrows(lick_params,'ID','ascend');
lick_params_short = sortrows(lick_params_short,'ID','ascend');

R = [];
for ii = [2:5,7:numel(lick_params_fieldnames)]
    
    % find matching feature in short
    short_idx = find(strcmp(lick_params_short_fieldnames,lick_params_fieldnames{ii}));
    
    if ~isempty(short_idx)
       % pairwise correlation
       [Rho,pval] = corr(table2array(lick_params(:,ii)),table2array(lick_params_short(:,short_idx)));
       
       % plot
       f = figure;
       scatter(table2array(lick_params(:,ii)),table2array(lick_params_short(:,short_idx)));
       xlabel({lick_params_fieldnames{ii},'long'},'Interpreter','none');
       ylabel({lick_params_short_fieldnames{short_idx},'short'},'Interpreter','none');
       lsline;
       title({['R = ',num2str(Rho)],['p = ',num2str(pval)]});
       saveas(f,fullfile(plot_output,[lick_params_fieldnames{ii},'.png']),'png');
       close all;    
   
       R = cat(1,R,Rho);
        
    end
    
end




