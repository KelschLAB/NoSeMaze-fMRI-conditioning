%% This scrript reduced the feature space from the social network analyses in the "master matrix" using PCA
% David Wolf, 08.2023
clear; close all;
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction'));
social_data_path = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/06-social_interaction/';
zscor_xnan = @(X) bsxfun(@rdivide, bsxfun(@minus, X, mean(X,'omitnan')), std(X, 'omitnan'));

%% 3a: load and parse time in arena and ROI information
social_master_data = readtable(fullfile(social_data_path,'MasterFile.xlsx'),'Sheet',2);

% initialize output data 
data = table;
data.Mouse_RFID = social_master_data.ID;
data.Group_ID = cat(1,repelem(1,12)',repelem(2,12)');

social_master_fieldnames = social_master_data.Properties.VariableNames;
totaltime_indices = find(cellfun(@(x) contains(x,'totaltime_'),social_master_fieldnames,'UniformOutput',1));
totaltime_average = mean(table2array(social_master_data(:,totaltime_indices)),2,'omitnan');
socialtime_indices = find(cellfun(@(x) contains(x,'SocialTime_'),social_master_fieldnames,'UniformOutput',1));
socialtime_average = mean(table2array(social_master_data(:,socialtime_indices)),2,'omitnan');
ratio_social_to_total = socialtime_average./totaltime_average;

% calculate corner/middle ratio day-by-day
cm_ratio = [];
for dd = 1:14
    cm_ratio = cat(2,cm_ratio,social_master_data.(['corners_',num2str(dd)])./social_master_data.(['middle_',num2str(dd)]));
end
cm_ratio(isinf(cm_ratio)) = NaN;
cm_ratio_average = mean(cm_ratio,2,'omitnan');

% [coeff,score,~,~,explained_zscored] = pca(zscor_xnan(table2array(social_master_data(:,[3:122,124:138]))),'Rows','pairwise');
% [coeff,score,~,~,explained_zscored] = pca(zscor_xnan(cat(2,totaltime_average,ratio_social_to_total,cm_ratio_average)),'Rows','pairwise');
% [coeff,score,~,~,explained_zscored] = pca(zscor_xnan(cat(2,totaltime_average,socialtime_average,ratio_social_to_total,cm_ratio_average,table2array(social_master_data(:,[3:122,124:138])))),'Rows','pairwise');

for an = 1:size(social_master_data,1)
           
    % find index in master matrix
    animal_idx = find(ismember(data.Group_ID,social_master_data.Group(an)) & contains(data.Mouse_RFID,social_master_data.ID{an}));
    if ~isempty(animal_idx)
        data.time_in_arena_average(animal_idx) = totaltime_average(an);
        data.ratio_social_to_total_time_average(animal_idx) = ratio_social_to_total(an);
        data.corner_to_middle_ratio_average(animal_idx) = cm_ratio_average(an);
        
    else
       warning(['Group #',num2str(social_master_data.Group(an)),': animal ',social_master_data.ID{an},' not found']);
    end
    
end

%% load social interaction information
% use temporally aggregated data (7 day-networks) 

interaction_master_data = readtable(fullfile(social_data_path,'MasterFile.xlsx'),'Sheet',7);

%% reduce social interaction features


%%% normalize features that depend on absolute edge strengths (node
%%% strenght and closeness centrality, because groups differ in these
%%% readouts)

% strength
strength_features = {'strength_int_count_Res7_1','strength_int_count_Res7_2',...
    'strength_mean_distances_Res7_1','strength_mean_distances_Res7_2',...
    'strength_mean_time_Res7_1','strength_mean_time_Res7_2',...
    'strength_summed_time_Res7_1','strength_summed_time_Res7_2'}; 

% normalize strength within group
for ii = 1:numel(strength_features)
    for gr = 1:10
        cur_max_strength = max(interaction_master_data.(strength_features{ii})(interaction_master_data.Group==gr));
        interaction_master_data.([strength_features{ii},'_normalized'])(interaction_master_data.Group==gr) = ...
            interaction_master_data.(strength_features{ii})(interaction_master_data.Group==gr)./cur_max_strength;
    end
end


% closeness
closeness_features = {'closeness_abs_approach_Res7_1','closeness_abs_approach_Res7_2',...
    'closeness_approach_props_Res7_1','closeness_approach_props_Res7_2',...
    'closeness_HWI_time_corr_Res7_1','closeness_HWI_time_corr_Res7_2',...
    'closeness_int_count_Res7_1','closeness_int_count_Res7_2',...
    'closeness_mean_distances_Res7_1','closeness_mean_distances_Res7_2',...
    'closeness_mean_time_Res7_1','closeness_mean_time_Res7_2',...
    'closeness_social_props_Res7_1','closeness_social_props_Res7_2',...
    'closeness_summed_time_Res7_1','closeness_summed_time_Res7_2',...
    'in_closeness_abs_approach_Res7_1','in_closeness_abs_approach_Res7_2',...
    'in_closeness_approach_props_Res7_1','in_closeness_approach_props_Res7_2',...
    'in_closeness_social_props_Res7_1','in_closeness_social_props_Res7_2',...
    'out_closeness_abs_approach_Res7_1','out_closeness_abs_approach_Res7_2',...
    'out_closeness_approach_props_Res7_1','out_closeness_approach_props_Res7_2',...
    'out_closeness_social_props_Res7_1','out_closeness_social_props_Res7_2',...
    }; 

% normalize closeness within group
for ii = 1:numel(closeness_features)
    for gr = 1:10
        cur_max_strength = max(interaction_master_data.(closeness_features{ii})(interaction_master_data.Group==gr));
        interaction_master_data.([closeness_features{ii},'_normalized'])(interaction_master_data.Group==gr) = ...
            interaction_master_data.(closeness_features{ii})(interaction_master_data.Group==gr)./cur_max_strength;
    end
end

% plot distributions
save_plots = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/feature distributions/';

% plot distributions of all features
plot_features = [2:145,147:154];
for ii = 1:numel(plot_features)
   if ~any(isnan(table2array(interaction_master_data(:,plot_features(ii)))))
       f=figure;
       subplot(1,2,1);
       histogram(table2array(interaction_master_data(:,plot_features(ii))));    
       title(interaction_master_data.Properties.VariableNames{plot_features(ii)},'Interpreter','none');

       subplot(1,2,2);
       histogram(log10(table2array(interaction_master_data(:,plot_features(ii)))+.5*min(table2array(interaction_master_data(table2array(interaction_master_data(:,plot_features(ii)))>0,plot_features(ii))))));    
       title(['log10(',interaction_master_data.Properties.VariableNames{plot_features(ii)},')'],'Interpreter','none');
       
       f.Position = [100 100 900 300];
       saveas(f,fullfile(save_plots,[num2str(plot_features(ii)),'_',interaction_master_data.Properties.VariableNames{plot_features(ii)},'.png']),'png');
       close all;    
   end
end



%%% features to log-transform (skewed features)
include_features_log = [2:17,46,47,50:53,62,63,66:69,78,79,84:85,111,118:125,128,129,...
    147:154];

% features not to log-transform
include_features_native = [82,83,94,95,98:101,110,155:182];

% construct matrix for PCA (combine features that are log-transformed
% because skewed with features that are used as they are. All features are
% zscored before PCA.
features_to_transform = table2array(interaction_master_data(:,include_features_log));
X = [];
for ii = 1:size(features_to_transform,2)
    X = cat(2,X,log10(features_to_transform(:,ii)+min(features_to_transform(features_to_transform(:,ii)>0,ii))/2));
end
for ii = 1:size(include_features_native,2)
    X = cat(2,X,table2array(interaction_master_data(:,include_features_native(:,ii))));
end

% delete columns with NaN
columns_to_delete = any(isnan(X));
X(:,columns_to_delete) = [];

interaction_features = interaction_master_data.Properties.VariableNames(cat(2,include_features_log,include_features_native));
[interaction_coeff,interaction_score,~,~,interaction_explained] = pca(zscor_xnan(X));

save_plots= '/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/pca/';
save(fullfile(save_plots,'interaction_coeff.mat'),'interaction_coeff','interaction_explained','interaction_score');

f=figure;
plot(cumsum(interaction_explained),'Color','k');
ylabel('cumulative variance explained (%)');
xlabel('Number of principle components');
ylim([0 100]);
box('off')
set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 4 4];
saveas(f,fullfile(save_plots,'interaction_variance_explained.png'),'png');
close all;   


f=figure;
grouping_by_group = interaction_master_data.Group;
gscatter(interaction_score(:,1),interaction_score(:,2),grouping_by_group,[],[],6);
xlabel('PC1');
ylabel('PC2');
legend('off')
box('off')
f.Units = 'centimeters';
f.Position = [3 3 4 4];
saveas(f,fullfile(save_plots,'interaction_scatter_pc12.png'),'png');
close all;  


% parse scores to data
for an = 1:size(interaction_master_data,1)
           
    % find index in master matrix
    animal_idx = find(ismember(data.Group_ID,interaction_master_data.Group(an)) & contains(data.Mouse_RFID,interaction_master_data.ID{an}));
    if ~isempty(animal_idx)
        for sc = 1:size(interaction_score,2)
            data.(['interaction_PC',num2str(sc)])(animal_idx) = interaction_score(an,sc);
        end
    else
       warning(['Group #',num2str(interaction_master_data.Group(an)),': animal ',interaction_master_data.ID{an},' not found']);
    end
    
end

save('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/unreduced_data.mat','data');
writetable(data,'/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/interaction_features.xlsx');


%% PCA separate for the two groups


%%% features to log-transform (skewed features)
include_features_log = [2:17,46,47,50:53,62,63,66:69,78,79,84:85,111,118:125,128,129,...
    147:154];

% features not to log-transform
include_features_native = [82,83,94,95,98:101,110,155:182];

%%% AM1_G1
for gr = 1:2
    
    cur_data = data(data.Group_ID==gr,:);
    % construct matrix for PCA (combine features that are log-transformed
    % because skewed with features that are used as they are. All features are
    % zscored before PCA.
    features_to_transform = table2array(interaction_master_data(interaction_master_data.Group==gr,include_features_log));
    X = [];
    for ii = 1:size(features_to_transform,2)
        X = cat(2,X,log10(features_to_transform(:,ii)+min(features_to_transform(features_to_transform(:,ii)>0,ii))/2));
    end
    for ii = 1:size(include_features_native,2)
        X = cat(2,X,table2array(interaction_master_data(interaction_master_data.Group==gr,include_features_native(:,ii))));
    end

    % delete columns with NaN
    columns_to_delete = any(isnan(X));
    X(:,columns_to_delete) = [];

    interaction_features = interaction_master_data.Properties.VariableNames(cat(2,include_features_log,include_features_native));
    [interaction_coeff,interaction_score,~,~,interaction_explained] = pca(zscor_xnan(X));

    save_plots= '/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/pca/';
    save(fullfile(save_plots,['interaction_coeff_G',num2str(gr),'.mat']),'interaction_coeff','interaction_explained','interaction_score');    

    f=figure;
    plot(cumsum(interaction_explained),'Color','k');
    ylabel('cumulative variance explained (%)');
    xlabel('Number of principle components');
    ylim([0 100]);
    box('off')
    set_fonts()
    f.Units = 'centimeters';
    f.Position = [3 3 4 4];
    saveas(f,fullfile(save_plots,['interaction_variance_explained_G',num2str(gr),'.png']),'png');
    close all;   


    f=figure;
    scatter(interaction_score(:,1),interaction_score(:,2),6);
    xlabel('PC1');
    ylabel('PC2');
    legend('off')
    box('off')
    f.Units = 'centimeters';
    f.Position = [3 3 4 4];
    saveas(f,fullfile(save_plots,['interaction_scatter_pc12_',num2str(gr),'.png']),'png');
    close all;  


    % parse scores to data 
    for ii = 1:nnz(interaction_master_data.Group==gr)
        tmp = find(interaction_master_data.Group==gr);
        an = tmp(ii);
        
        % find index in master matrix
        animal_idx = find(contains(cur_data.Mouse_RFID,interaction_master_data.ID{an}));
        if ~isempty(animal_idx)
            for sc = 1:size(interaction_score,2)
                cur_data.(['interaction_PC',num2str(sc)])(animal_idx) = interaction_score(ii,sc);
            end
        else
           warning(['Group #',num2str(interaction_master_data.Group(an)),': animal ',interaction_master_data.ID{an},' not found']);
        end

    end

    save(['/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/unreduced_data_G',num2str(gr),'.mat'],'cur_data');
    writetable(cur_data,['/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/01-AM/02-analyses/05-social_interaction/interaction_features_G',num2str(gr),'.xlsx']);


end