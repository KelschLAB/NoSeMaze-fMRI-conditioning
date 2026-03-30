%% This script extracts impulsivity in the go-no-go taks
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

% combine the single animal days into one d-struct for compatibility to
% other scripts
d_am1 = combine_single_animals(processed_data_path);

% remove wrong animals 
d_am1_short = d_am1;
animal_names = []; for an=1:numel(d_am1_short); animal_names = cat(1,animal_names,{d_am1_short(an).events(1).ID}); end
d_am1_short(contains(animal_names,{'0007CB2086','0007CB0F95','0007CB090F'})) = [];

% compute learning features
% number of trials to account before reversal
ntrials_before_reversal = 150; 
[impulsivity_am1,histogram_data_am1] = compute_impulsivity_ICON_jr(d_am1_short,5,ntrials_before_reversal);


%% AM2
processed_data_path = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/01-AM/02-AM2/02-GNG_task';
d_am2 = combine_single_animals(processed_data_path);
% number of trials to account before reversal
ntrials_before_reversal = 150; 
[impulsivity_am2,histogram_data_am2] = compute_impulsivity_ICON_jr(d_am2,5,ntrials_before_reversal);

%% combine
impulsivity = struct2table(cat(2,impulsivity_am1,impulsivity_am2));

%% plot PSTH histograms
for AM_number = 1:2 
    % figure
    fig(AM_number)=figure('visible', 'on');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.9]);
    
    if AM_number==1
        input_histogram_data = histogram_data_am1; input_impulsivity_data=impulsivity_am1;
    else AM_number==2
        input_histogram_data = histogram_data_am2; input_impulsivity_data=impulsivity_am2;
    end
    % Loop over animals
    for an=1:12
        subplot(3,4,an);
        histogram('BinEdges',input_histogram_data(an).BinEdges,'BinCounts',input_histogram_data(an).BinCount_CSminus,'EdgeColor','none');
        hold on;
        histogram('BinEdges',input_histogram_data(an).BinEdges,'BinCounts',input_histogram_data(an).BinCount_CSplus,'EdgeColor','none');
        ax=gca; ax.XLim=[0,3];
        title({input_impulsivity_data(an).ID,[ ' ,Rej.' num2str(round(input_impulsivity_data(an).correct_rejection,2)) ' ,I:' num2str(round(input_impulsivity_data(an).lick_rate_at_odor_on_csminus_to_base_150trials,2))]});
    
         % save source data in csv
         toSave_CSminus(:,1)=input_histogram_data(an).BinEdges(1:end-1)';toSave(:,2)=input_histogram_data(an).BinEdges(2:end)';
         toSave_CSminus(:,an+2)=input_histogram_data(an).BinCount_CSminus;
         toSave_CSplus(:,1)=input_histogram_data(an).BinEdges(1:end-1)';toSave(:,2)=input_histogram_data(an).BinEdges(2:end)';
         toSave_CSplus(:,an+2)=input_histogram_data(an).BinCount_CSminus;
         VarNames{1}='edge_from';VarNames{2}='edge_to';VarNames{an+2}=input_impulsivity_data(an).ID;
    end
    SourceData = array2table(toSave_CSminus,'VariableNames',VarNames);
    writetable(SourceData,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/',['SourceData_CSminus_AM' num2str(AM_number) '.csv']),'WriteVariableNames',true,'WriteRowNames',true);
    SourceData = array2table(toSave_CSplus,'VariableNames',VarNames);
    writetable(SourceData,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/',['SourceData_CSplus_AM' num2str(AM_number) '.csv']),'WriteVariableNames',true,'WriteRowNames',true);
   
    % print
    [annot, srcInfo] = docDataSrc(fig(AM_number),fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/'),mfilename('fullpath'),logical(1))
    exportgraphics(fig(AM_number),fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/',['Lick_Data_AM' num2str(AM_number) '.pdf']),'Resolution',300);
    print('-dpsc',fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/',['Lick_Data_AM' num2str(AM_number)]),'-painters','-r400','-bestfit');
end

%% PCA
%% Feature analysis: inspect feature distributions and decide which features should be log-transformed before PCA
zscor_xnan = @(X) bsxfun(@rdivide, bsxfun(@minus, X, mean(X,'omitnan')), std(X, 'omitnan'));
plot_output_short = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/histograms_jr/';
if ~isfolder(plot_output_short); mkdir(plot_output_short); end

% plot distributions of all features
plot_features = [8:21];
for ii = 1:numel(plot_features)
   f=figure;
   histogram(table2array(impulsivity(:,plot_features(ii))));
   title(impulsivity.Properties.VariableNames{plot_features(ii)},'Interpreter','none');
   saveas(f,fullfile(plot_output_short,[num2str(plot_features(ii)),'_',impulsivity.Properties.VariableNames{plot_features(ii)},'.png']),'png');
   close all;    
end

% select skewed features for log-transformation
log_transform_features = [2:19,21,25];
for ii = 1:numel(log_transform_features)
   if any(table2array(impulsivity(:,log_transform_features(ii)))==0) % if 0 values exist, add smallest value/2 to everywhere to ensure log works
       impulsivity.(['log10(',impulsivity.Properties.VariableNames{log_transform_features(ii)},')']) = ...
           log10(table2array(impulsivity(:,log_transform_features(ii)))+min(table2array(impulsivity(table2array(impulsivity(:,log_transform_features(ii)))>0,log_transform_features(ii))))./2);
   else
       impulsivity.(['log10(',impulsivity.Properties.VariableNames{log_transform_features(ii)},')']) = log10(table2array(impulsivity(:,log_transform_features(ii))));
   end
   
   f=figure;
   histogram(impulsivity.(['log10(',impulsivity.Properties.VariableNames{log_transform_features(ii)},')']));
   title(['log10(',impulsivity.Properties.VariableNames{log_transform_features(ii)},')'],'Interpreter','none');
   tmp_idx = find(strcmp(impulsivity.Properties.VariableNames,['log10(',impulsivity.Properties.VariableNames{log_transform_features(ii)},')']));
   saveas(f,fullfile(plot_output_short,[num2str(tmp_idx),'_','log10(',impulsivity.Properties.VariableNames{log_transform_features(ii)},')','.png']),'png');
   close all;    
end

% CS- modulation, delay avoidance learning 
cs_minus_mod_features = {'log10(cs_minus_modulation_averaged)','log10(cs_minus_modulation_peak)',...
    'log10(cs_minus_modulation_min)','log10(cs_minus_modulation_full_window_averaged)',...
    'log10(correct_rejection)','log10(baseline_rate_CSminus_mean_omitfirst)'};%'delay_avoidance_learner'}; %,'cs_minus_detection_speed'
impulsivity_fieldnames = impulsivity.Properties.VariableNames;
cs_minus_feature_indices = find(cellfun(@(x) any(strcmp(cs_minus_mod_features,x)),impulsivity_fieldnames,'UniformOutput',1));
[cs_minus_coeff,cs_minus_score,~,~,cs_minus_explained] = pca(zscor_xnan(table2array(impulsivity(:,cs_minus_feature_indices))),'Rows','pairwise');

% CS- modulation, to baseline
cs_minus_mod_features = {'log10(cs_minus_modulation_averaged_to_base)','log10(cs_minus_modulation_peak_to_base)',...
    'log10(cs_minus_modulation_min_to_base)','log10(cs_minus_modulation_full_window_averaged)',...
    'log10(correct_rejection)','log10(baseline_rate_CSminus_mean_omitfirst)'};%'delay_avoidance_learner'}; %,'cs_minus_detection_speed'
impulsivity_fieldnames = impulsivity.Properties.VariableNames;
cs_minus_feature_indices = find(cellfun(@(x) any(strcmp(cs_minus_mod_features,x)),impulsivity_fieldnames,'UniformOutput',1));
[cs_minus_coeff_base,cs_minus_score_base,~,~,cs_minus_explained_base] = pca(zscor_xnan(table2array(impulsivity(:,cs_minus_feature_indices))),'Rows','pairwise');

% CS- modulation, with baseline
% cs_minus_mod_features = {'log10(cs_minus_modulation_averaged)','log10(cs_minus_modulation_peak)',...
%     'log10(cs_minus_modulation_min)','log10(cs_minus_modulation_full_window_averaged)',...
%     'correct_rejection','log10(baseline_rate_CSminus_mean_omitfirst)'};%'delay_avoidance_learner'}; %,'cs_minus_detection_speed'
% impulsivity_fieldnames = impulsivity.Properties.VariableNames;
% cs_minus_feature_indices = find(cellfun(@(x) any(strcmp(cs_minus_mod_features,x)),impulsivity_fieldnames,'UniformOutput',1));
% [cs_minus_coeff_with_base,cs_minus_score_with_base,~,~,cs_minus_explained_with_base] = pca(zscor_xnan(table2array(impulsivity(:,cs_minus_feature_indices))),'Rows','pairwise');

save(fullfile(plot_output_short,'cs-_coeff.mat'),'cs_minus_coeff','cs_minus_explained');
save(fullfile(plot_output_short,'cs-_coeff_base.mat'),'cs_minus_coeff_base','cs_minus_explained_base');
% save(fullfile(plot_output_short,'cs-_coeff_with_base.mat'),'cs_minus_coeff_with_base','cs_minus_explained_with_base');
for ii = 1:size(cs_minus_score,2)
    covariates_short.(['cs_minus_pc',num2str(ii)]) = cs_minus_score(:,ii);
    impulsivity.(['cs_minus_pc',num2str(ii)]) = cs_minus_score(:,ii);
end
for ii = 1:size(cs_minus_score_base,2)
    covariates_short.(['cs_minus_pc',num2str(ii) '_base']) = cs_minus_score_base(:,ii);
    impulsivity.(['cs_minus_pc',num2str(ii) '_base']) = cs_minus_score_base(:,ii);
end
% for ii = 1:size(cs_minus_score_with_base,2)
%     covariates_short.(['cs_minus_pc',num2str(ii) '_with_base']) = cs_minus_score_with_base(:,ii);
%     impulsivity.(['cs_minus_pc',num2str(ii) '_with_base']) = cs_minus_score_with_base(:,ii);
% end

f=figure;
plot(cumsum(cs_minus_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts;
f.Units = 'centimeters';
f.Position = [3 3 5 5];
saveas(f,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','cs-_variance_explained_jr.png'),'png');
exportgraphics(f,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','cs-_variance_explained_jr.pdf'),'ContentType','vector');
close all;   

f=figure;
dx = 0.05; dy = 0.05; % displacement so the text does not overlay the data points
text(cs_minus_score(:,1)+dx, cs_minus_score(:,2)+dy, cellfun(@(x) x(end-2:end), impulsivity.ID, 'UniformOutput',0),'FontSize',6);
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
saveas(f,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','cs-_scatter_pc12_jr.png'),'png');
exportgraphics(f,fullfile('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/','cs-_scatter_pc12_jr.pdf'),'ContentType','vector');
close all;  

writetable(impulsivity,['/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/impulsivity_' num2str(ntrials_before_reversal) 'trials.xlsx']);

%% check correlation to CS- PC1

T = readtable('/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/01-AM/04-lickFeatures/short/covariates_short.xlsx');


figure;
scatter(T.cs_minus_pc1,impulsivity.lick_rate_at_odor_on_csminus_to_base,'.','k')
[rho,p] = corr(T.cs_minus_pc1,impulsivity.lick_rate_at_odor_on_csminus_to_base);
title({['Pearson R = ',num2str(rho)],['p = ',num2str(p)]});
xlabel('CS- PC1');
ylabel('CS- impulsivity');



