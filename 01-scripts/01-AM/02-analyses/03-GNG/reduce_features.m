%% This scrript reduces features extracted with "extract_features.m" with PCA for correlation to fMRI
% David Wolf, 06.2023
clear; close all;
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/03-GNG'));



%% Short data: only use lick-data up to the reappraisal scan (4 reversals)
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short','lick_params.mat'));

covariates_short.ID = lick_params_short.ID;
covariates_short.cs_plus_detection_speed = lick_params_short.cs_plus_detection_speed;

zscor_xnan = @(X) bsxfun(@rdivide, bsxfun(@minus, X, mean(X,'omitnan')), std(X, 'omitnan'));
save_plots = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/pca/';
if ~isfolder(save_plots); mkdir(save_plots); end

% CS+ modulation
cs_plus_mod_features = {'log10(cs_plus_modulation_averaged)','log10(cs_plus_modulation_peak_to_base)',...
    'log10(cs_plus_modulation_min_to_base)','log10(cs_plus_ramping)'}; %,'cs_plus_detection_speed'
lick_params_short_fieldnames = lick_params_short.Properties.VariableNames;
cs_plus_feature_indices = find(cellfun(@(x) any(strcmp(cs_plus_mod_features,x)),lick_params_short_fieldnames,'UniformOutput',1));
[cs_plus_coeff,cs_plus_score,~,~,cs_plus_explained] = pca(zscor_xnan(table2array(lick_params_short(:,cs_plus_feature_indices))),'Rows','pairwise');

save(fullfile(save_plots,'cs+_coeff.mat'),'cs_plus_coeff','cs_plus_explained');
for ii = 1:size(cs_plus_score,2)
    covariates_short.(['cs_plus_pc',num2str(ii)]) = cs_plus_score(:,ii);
end

f=figure;
plot(cumsum(cs_plus_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'cs+_variance_explained.png'),'png');
close all;   

f=figure;
dx = 0.05; dy = 0.05; % displacement so the text does not overlay the data points
text(cs_plus_score(:,1)+dx, cs_plus_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params_short.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(cs_plus_score(:,1),cs_plus_score(:,2),12,'filled','k');
xlim([min(cs_plus_score(:,1))-.5 max(cs_plus_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'cs+_scatter_pc12.png'),'png');
close all;   

% CS- modulation, delay avoidance learning 
cs_minus_mod_features = {'log10(cs_minus_modulation_averaged)','log10(cs_minus_modulation_peak_to_base)',...
    'log10(cs_minus_modulation_min_to_base)','log10(cs_minus_modulation_full_window_averaged)',...
    'delay_avoidance_learner'}; %,'cs_minus_detection_speed'
lick_params_short_fieldnames = lick_params_short.Properties.VariableNames;
cs_minus_feature_indices = find(cellfun(@(x) any(strcmp(cs_minus_mod_features,x)),lick_params_short_fieldnames,'UniformOutput',1));
[cs_minus_coeff,cs_minus_score,~,~,cs_minus_explained] = pca(zscor_xnan(table2array(lick_params_short(:,cs_minus_feature_indices))),'Rows','pairwise');

save(fullfile(save_plots,'cs-_coeff.mat'),'cs_minus_coeff','cs_minus_explained');
for ii = 1:size(cs_minus_score,2)
    covariates_short.(['cs_minus_pc',num2str(ii)]) = cs_minus_score(:,ii);
end

f=figure;
plot(cumsum(cs_minus_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'cs-_variance_explained.png'),'png');
exportgraphics(f,fullfile(save_plots,'cs-_variance_explained.pdf'),'ContentType','vector');
close all;   

f=figure;
text(cs_minus_score(:,1)+dx, cs_minus_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params_short.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(cs_minus_score(:,1),cs_minus_score(:,2),12,'filled','k');
xlim([min(cs_minus_score(:,1))-.5 max(cs_minus_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'cs-_scatter_pc12.png'),'png');
exportgraphics(f,fullfile(save_plots,'cs-_scatter_pc12.pdf'),'ContentType','vector');
close all;  

% switching flexibility
switching_features = {'giving_up_at_CS_rev1','giving_up_at_US_rev1',...
    'giving_up_at_CS_rev2','giving_up_at_US_rev2',...
    'log10(cs_plus_switch_latency_at_cs_rev1)','log10(cs_plus_switch_latency_at_us_rev1)',...
    'log10(cs_plus_switch_latency_at_cs_rev2)','log10(cs_plus_switch_latency_at_us_rev2)',...
    'log10(cs_plus_switch_latency_at_cs_rev3)','log10(cs_plus_switch_latency_at_us_rev3)',...
    'log10(cs_plus_switch_latency_at_cs_rev4)','log10(cs_plus_switch_latency_at_us_rev4)',...
    'log10(cs_minus_switch_latency_at_cs_rev2)','log10(cs_minus_switch_latency_at_us_rev2)',...
    'log10(cs_minus_switch_latency_at_cs_rev3)','log10(cs_minus_switch_latency_at_us_rev3)',...
    'log10(cs_minus_switch_latency_at_cs_rev4)','log10(cs_minus_switch_latency_at_us_rev4)',...
    'log10(cs_plus_switch_latency_at_cs_mean)','log10(cs_plus_switch_latency_at_us_mean)',...
    'log10(cs_minus_switch_latency_at_cs_mean)','log10(cs_minus_switch_latency_at_us_mean)',...
    'log10(pause_duration_at_CS_rev1)','log10(pause_duration_at_US_rev1)','log10(pause_duration_at_CS_rev1_in_minutes)',...
    'log10(pause_duration_at_CS_rev2)','log10(pause_duration_at_US_rev2)','log10(pause_duration_at_CS_rev2_in_minutes)',...
    'log10(pause_duration_at_CS_rev3)','log10(pause_duration_at_US_rev3)','log10(pause_duration_at_CS_rev3_in_minutes)',...
    'log10(pause_duration_at_CS_rev4)','log10(pause_duration_at_US_rev4)','log10(pause_duration_at_CS_rev4_in_minutes)',...
    }; 
lick_params_short_fieldnames = lick_params_short.Properties.VariableNames;
switching_feature_indices = find(cellfun(@(x) any(strcmp(switching_features,x)),lick_params_short_fieldnames,'UniformOutput',1));
[switching_coeff,switching_score,~,~,switching_explained] = pca(zscor_xnan(table2array(lick_params_short(:,switching_feature_indices))));

save(fullfile(save_plots,'switching_coeff.mat'),'switching_coeff','switching_explained');
for ii = 1:size(switching_score,2)
    covariates_short.(['switching_pc',num2str(ii)]) = switching_score(:,ii);
end

f=figure;
plot(cumsum(switching_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'switching_variance_explained.png'),'png');
close all;   

f=figure;
text(switching_score(:,1)+dx, switching_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params_short.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(switching_score(:,1),switching_score(:,2),12,'filled','k');
xlim([min(switching_score(:,1))-.5 max(switching_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'switching_scatter_pc12.png'),'png');
close all;  


% cross-reversal shaping
shaping_features = {'log10(cs_plus_relearning_progression_at_cs)','log10(cs_plus_relearning_progression_at_us)',...
    'log10(cs_minus_relearning_progression_at_cs)','log10(cs_minus_relearning_progression_at_us)',...
    'delay_avoidance_shaping','log10(pause_duration_at_CS_shaping_rev_1to2)','log10(pause_duration_at_CS_shaping_rev_1toLate)',...
    'log10(pause_duration_at_CS_shaping_rev_2toLate)','log10(pause_duration_at_US_shaping_rev_1to2)','log10(pause_duration_at_US_shaping_rev_1toLate)',...
    'log10(pause_duration_at_US_shaping_rev_2toLate)','log10(cs_plus_detection_speed_crossreversal_shaping)','log10(baseline_crossreversal_shaping)'}; 
lick_params_short_fieldnames = lick_params_short.Properties.VariableNames;
shaping_feature_indices = find(cellfun(@(x) any(strcmp(shaping_features,x)),lick_params_short_fieldnames,'UniformOutput',1));
[shaping_coeff,shaping_score,~,~,shaping_explained] = pca(zscor_xnan(table2array(lick_params_short(:,shaping_feature_indices))));


save(fullfile(save_plots,'shaping_coeff.mat'),'shaping_coeff','shaping_explained');
for ii = 1:size(shaping_score,2)
    covariates_short.(['shaping_pc',num2str(ii)]) = shaping_score(:,ii);
end

f=figure;
plot(cumsum(shaping_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'shaping_variance_explained.png'),'png');
close all;   

f=figure;
text(shaping_score(:,1)+dx, shaping_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params_short.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(shaping_score(:,1),shaping_score(:,2),12,'filled','k');
xlim([min(shaping_score(:,1))-.5 max(shaping_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'shaping_scatter_pc12.png'),'png');
close all;  

% export
covariates_short = struct2table(covariates_short);
save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short','covariates_short.mat'),'covariates_short');
writetable(covariates_short,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short','covariates_short.xlsx'));

%% Long data: only use lick-data up to the reappraisal scan (4 reversals)
clear;
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long','lick_params.mat'));

covariates_long.ID = lick_params.ID;
covariates_long.cs_plus_detection_speed = lick_params.cs_plus_detection_speed;

zscor_xnan = @(X) bsxfun(@rdivide, bsxfun(@minus, X, mean(X,'omitnan')), std(X, 'omitnan'));
save_plots = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long/pca/';
if ~isfolder(save_plots); mkdir(save_plots); end

% CS+ modulation
cs_plus_mod_features = {'log10(cs_plus_modulation_averaged)','log10(cs_plus_modulation_peak_to_base)',...
    'log10(cs_plus_modulation_min_to_base)','log10(cs_plus_ramping)'}; %,'cs_plus_detection_speed'
lick_params_fieldnames = lick_params.Properties.VariableNames;
cs_plus_feature_indices = find(cellfun(@(x) any(strcmp(cs_plus_mod_features,x)),lick_params_fieldnames,'UniformOutput',1));
[cs_plus_coeff,cs_plus_score,~,~,cs_plus_explained] = pca(zscor_xnan(table2array(lick_params(:,cs_plus_feature_indices))),'Rows','pairwise');

save(fullfile(save_plots,'cs+_coeff.mat'),'cs_plus_coeff','cs_plus_explained');
for ii = 1:size(cs_plus_score,2)
    covariates_long.(['cs_plus_pc',num2str(ii)]) = cs_plus_score(:,ii);
end

f=figure;
plot(cumsum(cs_plus_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'cs+_variance_explained.png'),'png');
close all;   

f=figure;
dx = 0.05; dy = 0.05; % displacement so the text does not overlay the data points
text(cs_plus_score(:,1)+dx, cs_plus_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(cs_plus_score(:,1),cs_plus_score(:,2),12,'filled','k');
xlim([min(cs_plus_score(:,1))-.5 max(cs_plus_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'cs+_scatter_pc12.png'),'png');
close all;   

% CS- modulation, delay avoidance learning 
cs_minus_mod_features = {'log10(cs_minus_modulation_averaged)','log10(cs_minus_modulation_peak_to_base)',...
    'log10(cs_minus_modulation_min_to_base)','log10(cs_minus_modulation_full_window_averaged)',...
    'delay_avoidance_learner'}; %,'cs_minus_detection_speed'
lick_params_fieldnames = lick_params.Properties.VariableNames;
cs_minus_feature_indices = find(cellfun(@(x) any(strcmp(cs_minus_mod_features,x)),lick_params_fieldnames,'UniformOutput',1));
[cs_minus_coeff,cs_minus_score,~,~,cs_minus_explained] = pca(zscor_xnan(table2array(lick_params(:,cs_minus_feature_indices))),'Rows','pairwise');

save(fullfile(save_plots,'cs-_coeff.mat'),'cs_minus_coeff','cs_minus_explained');
for ii = 1:size(cs_minus_score,2)
    covariates_long.(['cs_minus_pc',num2str(ii)]) = cs_minus_score(:,ii);
end

f=figure;
plot(cumsum(cs_minus_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'cs-_variance_explained.png'),'png');
close all;   

f=figure;
text(cs_minus_score(:,1)+dx, cs_minus_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(cs_minus_score(:,1),cs_minus_score(:,2),12,'filled','k');
xlim([min(cs_minus_score(:,1))-.5 max(cs_minus_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'cs-_scatter_pc12.png'),'png');
close all;  

% switching flexibility
switching_features = {'giving_up_at_CS_rev1','giving_up_at_US_rev1',...
    'giving_up_at_CS_rev2','giving_up_at_US_rev2',...
    'log10(cs_plus_switch_latency_at_cs_rev1)','log10(cs_plus_switch_latency_at_us_rev1)',...
    'log10(cs_plus_switch_latency_at_cs_rev2)','log10(cs_plus_switch_latency_at_us_rev2)',...
    'log10(cs_plus_switch_latency_at_cs_rev3)','log10(cs_plus_switch_latency_at_us_rev3)',...
    'log10(cs_plus_switch_latency_at_cs_rev4)','log10(cs_plus_switch_latency_at_us_rev4)',...
    'log10(cs_plus_switch_latency_at_cs_rev5)','log10(cs_plus_switch_latency_at_us_rev5)',...
    'log10(cs_plus_switch_latency_at_cs_rev6)','log10(cs_plus_switch_latency_at_us_rev6)',...
    'log10(cs_plus_switch_latency_at_cs_rev7)','log10(cs_plus_switch_latency_at_us_rev7)',...
    'log10(cs_plus_switch_latency_at_cs_rev8)','log10(cs_plus_switch_latency_at_us_rev8)',...
    'log10(cs_plus_switch_latency_at_cs_rev9)','log10(cs_plus_switch_latency_at_us_rev9)',...
    'log10(cs_plus_switch_latency_at_cs_rev10)','log10(cs_plus_switch_latency_at_us_rev10)',...
    'log10(cs_plus_switch_latency_at_cs_rev11)','log10(cs_plus_switch_latency_at_us_rev11)',...
    'log10(cs_minus_switch_latency_at_cs_rev2)','log10(cs_minus_switch_latency_at_us_rev2)',...
    'log10(cs_minus_switch_latency_at_cs_rev3)','log10(cs_minus_switch_latency_at_us_rev3)',...
    'log10(cs_minus_switch_latency_at_cs_rev4)','log10(cs_minus_switch_latency_at_us_rev4)',...
    'log10(cs_minus_switch_latency_at_cs_rev5)','log10(cs_minus_switch_latency_at_us_rev5)',...
    'log10(cs_minus_switch_latency_at_cs_rev6)','log10(cs_minus_switch_latency_at_us_rev6)',...
    'log10(cs_minus_switch_latency_at_cs_rev7)','log10(cs_minus_switch_latency_at_us_rev7)',...
    'log10(cs_minus_switch_latency_at_cs_rev8)','log10(cs_minus_switch_latency_at_us_rev8)',...
    'log10(cs_minus_switch_latency_at_cs_rev9)','log10(cs_minus_switch_latency_at_us_rev9)',...
    'log10(cs_minus_switch_latency_at_cs_rev10)','log10(cs_minus_switch_latency_at_us_rev10)',...
    'log10(cs_minus_switch_latency_at_cs_rev11)','log10(cs_minus_switch_latency_at_us_rev11)',...
    'log10(cs_plus_switch_latency_at_cs_mean)','log10(cs_plus_switch_latency_at_us_mean)',...
    'log10(cs_minus_switch_latency_at_cs_mean)','log10(cs_minus_switch_latency_at_us_mean)',...
    'log10(pause_duration_at_CS_rev1)','log10(pause_duration_at_US_rev1)','log10(pause_duration_at_CS_rev1_in_minutes)',...
    'log10(pause_duration_at_CS_rev2)','log10(pause_duration_at_US_rev2)','log10(pause_duration_at_CS_rev2_in_minutes)',...
    'log10(pause_duration_at_CS_rev3)','log10(pause_duration_at_US_rev3)','log10(pause_duration_at_CS_rev3_in_minutes)',...
    'log10(pause_duration_at_CS_rev4)','log10(pause_duration_at_US_rev4)','log10(pause_duration_at_CS_rev4_in_minutes)',...
    'log10(pause_duration_at_CS_rev5)','log10(pause_duration_at_US_rev5)','log10(pause_duration_at_CS_rev5_in_minutes)',...
    'log10(pause_duration_at_CS_rev6)','log10(pause_duration_at_US_rev6)','log10(pause_duration_at_CS_rev6_in_minutes)',...
    'log10(pause_duration_at_CS_rev7)','log10(pause_duration_at_US_rev7)','log10(pause_duration_at_CS_rev7_in_minutes)',...
    'log10(pause_duration_at_CS_rev8)','log10(pause_duration_at_US_rev8)','log10(pause_duration_at_CS_rev8_in_minutes)',...
    'log10(pause_duration_at_CS_rev9)','log10(pause_duration_at_US_rev9)','log10(pause_duration_at_CS_rev9_in_minutes)',...
    'log10(pause_duration_at_CS_rev10)','log10(pause_duration_at_US_rev10)','log10(pause_duration_at_CS_rev10_in_minutes)',...
    'log10(pause_duration_at_CS_rev11)','log10(pause_duration_at_US_rev11)','log10(pause_duration_at_CS_rev11_in_minutes)',...
    }; 
lick_params_fieldnames = lick_params.Properties.VariableNames;
switching_feature_indices = find(cellfun(@(x) any(strcmp(switching_features,x)),lick_params_fieldnames,'UniformOutput',1));
[switching_coeff,switching_score,~,~,switching_explained] = pca(zscor_xnan(table2array(lick_params(:,switching_feature_indices))));

save(fullfile(save_plots,'switching_coeff.mat'),'switching_coeff','switching_explained');
for ii = 1:size(switching_score,2)
    covariates_long.(['switching_pc',num2str(ii)]) = switching_score(:,ii);
end

f=figure;
plot(cumsum(switching_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'switching_variance_explained.png'),'png');
close all;   

f=figure;
text(switching_score(:,1)+dx, switching_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(switching_score(:,1),switching_score(:,2),12,'filled','k');
xlim([min(switching_score(:,1))-.5 max(switching_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'switching_scatter_pc12.png'),'png');
close all;  


% cross-reversal shaping
shaping_features = {'log10(cs_plus_relearning_progression_at_cs)','log10(cs_plus_relearning_progression_at_us)',...
    'log10(cs_minus_relearning_progression_at_cs)','log10(cs_minus_relearning_progression_at_us)',...
    'delay_avoidance_shaping','log10(pause_duration_at_CS_shaping_rev_1to2)','log10(pause_duration_at_CS_shaping_rev_1toLate)',...
    'log10(pause_duration_at_CS_shaping_rev_2toLate)','log10(pause_duration_at_US_shaping_rev_1to2)','log10(pause_duration_at_US_shaping_rev_1toLate)',...
    'log10(pause_duration_at_US_shaping_rev_2toLate)','log10(cs_plus_detection_speed_crossreversal_shaping)','log10(baseline_crossreversal_shaping)'}; 
lick_params_fieldnames = lick_params.Properties.VariableNames;
shaping_feature_indices = find(cellfun(@(x) any(strcmp(shaping_features,x)),lick_params_fieldnames,'UniformOutput',1));
[shaping_coeff,shaping_score,~,~,shaping_explained] = pca(zscor_xnan(table2array(lick_params(:,shaping_feature_indices))));


save(fullfile(save_plots,'shaping_coeff.mat'),'shaping_coeff','shaping_explained');
for ii = 1:size(shaping_score,2)
    covariates_long.(['shaping_pc',num2str(ii)]) = shaping_score(:,ii);
end

f=figure;
plot(cumsum(shaping_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile(save_plots,'shaping_variance_explained.png'),'png');
close all;   

f=figure;
text(shaping_score(:,1)+dx, shaping_score(:,2)+dy, cellfun(@(x) x(end-2:end), lick_params.ID, 'UniformOutput',0),'FontSize',6);
hold on;
scatter(shaping_score(:,1),shaping_score(:,2),12,'filled','k');
xlim([min(shaping_score(:,1))-.5 max(shaping_score(:,1))+.5]);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 8 8];
saveas(f,fullfile(save_plots,'shaping_scatter_pc12.png'),'png');
close all;  


% export
covariates_long = struct2table(covariates_long);
save(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long','covariates_long.mat'),'covariates_long');
writetable(covariates_long,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long','covariates_long.xlsx'));


%% correlation between short and long

clear;
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short','covariates_short.mat'));
load(fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/long','covariates_long.mat'));

plot_output = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/correlation';

% do pairwise correlations of the same feature
covariates_short_fieldnames = covariates_short.Properties.VariableNames;
covariates_long_fieldnames = covariates_long.Properties.VariableNames;

ID_long = covariates_long.ID;
ID_short = covariates_short.ID;
covariates_short(~contains(ID_short,ID_long),:) = [];

% sort alphabetically to match IDs
covariates_long = sortrows(covariates_long,'ID','ascend');
covariates_short = sortrows(covariates_short,'ID','ascend');

[Rho,pval] = corr(table2array(covariates_long(:,[2:4,7,8,12:16,33:37])),table2array(covariates_short(:,[2:4,7,8,12:16,35:39])));
Rho(pval>.01) = 0;
f = figure;
imagesc(Rho,[-1 1]);
colormap_BlueWhiteRed;
xlabel('# cov long');
ylabel('# cov short');
box('off')
labels=covariates_long.Properties.VariableNames([2:4,7,8,12:16,33:37]);
ax = gca;
ax.YTick = 1:numel(labels); ax.XTick = 1:numel(labels);
ax.YTickLabel = labels; ax.XTickLabel = labels;
ax.XTickLabelRotation = 30;
set_fonts;
colorbar
f.Units = 'centimeters';
f.Position = [3 3 15 11];
saveas(f,fullfile(plot_output,'covariate_correlation.png'),'png');
close all;  

