%% plot_LME_globMetGA_reappraisal_jr.m
% Script for plotting pre-selected global graph metrics
% Reinwald 06/2022

%% Clearing
close all
clear all
clc

%% Comparison selection
selection_name{1}='Odor11to40';
selection_name{2}='Odor81to120';
selection_name{3}='TPnoPuff11to40';
selection_name{4}='TPnoPuff81to120';

%% Threshold selection for AUC
% thresholds to take into calculation for AUC. These are indices for
% positions in the threshold vector!
minthr_ind_range=[1,31,36];
maxthr_ind_range=[41,41,41];

%% Selection of input
% cormat version
cormat_version = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'bin'; % 'max'
connectedness = 'connected';
% folder selection
if separated_hemisphere==1
    inputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
elseif separated_hemisphere==0
    inputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
end

%% Loop over threshold ranges
for mx = 1:length(minthr_ind_range)
    
    %% current thresholds
    minthr_ind = minthr_ind_range(mx)
    maxthr_ind = maxthr_ind_range(mx)
    
    %% Output directory
    if separated_hemisphere==1
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness '/LME'];
    elseif separated_hemisphere==0
        outputDir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/06-GA/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness '/LME'];
    end
    outputDir = fullfile(outputDir,['global_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9)]);
    mkdir(outputDir);
    cd(outputDir);
    
    if exist(fullfile(outputDir,'GA_globalLME.ps'))==2
        delete(fullfile(outputDir,'GA_globalLME.ps'));
    end
    
    %% Load input data
    for curr_sel=1:length(selection_name)
        load(fullfile(inputDir,['auc_struc_' selection_name{curr_sel} '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat']));
        myData{curr_sel}.auc_struc = auc_struc;
    end
    
    %% Selection of global metrics
    metricnames_all = fieldnames(myData{1}.auc_struc);
    global_metrics = metricnames_all(contains(fieldnames(myData{1}.auc_struc),'g_'))
    % throw out: null models, _JR (doubled), _clus,  _path (both for SWP)
    global_metrics=global_metrics(logical(~contains(global_metrics,'_JR') .* ~contains(global_metrics,'_path') .* ~contains(global_metrics,'_null') .* ~contains(global_metrics,'_clus'))),
    if strcmp(binarization_method,'max')
        global_metrics(7)=[];
    end
    
    %% Loop over global names for plotting
    for ig=1:length(global_metrics)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% statistics: linear mixed effects model
        % data preparation
        % set counter
        counter=1;
        
        % loop over animals
        for animal_ID=1:length(myData{1}.auc_struc)
            
            % loop over the four time point
            for auc_idx = 1:length(myData)
                
                % animal
                animal(counter)=animal_ID;
                
                % metrics
                metric(counter)=myData{auc_idx}.auc_struc(animal_ID).(global_metrics{ig});
                selection_name_tbl{counter}=selection_name{auc_idx};
                
                % intra-trial timepoint
                if contains(selection_name{auc_idx},'Odor')
                    IT_timepoint{counter}='odor';
                elseif contains(selection_name{auc_idx},'TPnoPuff')
                    IT_timepoint{counter}='TPnopuff';
                end
                % block
                if contains(selection_name{auc_idx},'11to40')
                    block(counter)=1;
                elseif contains(selection_name{auc_idx},'81to120')
                    block(counter)=3;
                end
                % counter update
                counter=counter+1;
            end
        end
        
        % create the input table
        myTable.(global_metrics{ig}).input = table(block',IT_timepoint',animal',metric',selection_name_tbl','VariableNames',{'block','IT_timepoint','animal','g_metric','selection_name'});
        myTable.(global_metrics{ig}).input.animal = categorical(myTable.(global_metrics{ig}).input.animal);
        myTable.(global_metrics{ig}).input.block = categorical(myTable.(global_metrics{ig}).input.block);
        
        % fit linear mixed effects model (% choosing between individual
        % slopes for all animals (block|animal) or on slope (1|animal),
        % see also:
        % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
        % ( The Importance of Random Slopes in Mixed Models for Bayesian
        % Hypothesis Testing, Klaus Oberauer)
        lme = fitlme(myTable.(global_metrics{ig}).input,'g_metric ~ 1 + block*IT_timepoint + (1|animal)');
        %         lme_new = fitlme(myTable.(global_metrics{ig}).input,'l_metric ~ 1 + block*IT_timepoint + (block*IT_timepoint|animal)');
        % CAVE: robust linear models are implemented in R and might
        % ameliorate some results (robustlmm)
        % p values
        p_intercept.(global_metrics{ig})=double(lme.Coefficients(1,6));
        p_block.(global_metrics{ig})=double(lme.Coefficients(2,6));
        p_IT_timepoint.(global_metrics{ig})=double(lme.Coefficients(3,6));
        p_interaction.(global_metrics{ig})=double(lme.Coefficients(4,6));
        % betas
        beta_intercept.(global_metrics{ig})=double(lme.Coefficients(1,2));
        beta_block.(global_metrics{ig})=double(lme.Coefficients(2,2));
        beta_IT_timepoint.(global_metrics{ig})=double(lme.Coefficients(3,2));
        beta_interaction.(global_metrics{ig})=double(lme.Coefficients(4,2));
        % tstat
        tstat_intercept.(global_metrics{ig})=double(lme.Coefficients(1,4));
        tstat_block.(global_metrics{ig})=double(lme.Coefficients(2,4));
        tstat_IT_timepoint.(global_metrics{ig})=double(lme.Coefficients(3,4));
        tstat_interaction.(global_metrics{ig})=double(lme.Coefficients(4,4));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % figure
        % set figure
        fig(ig)=figure('visible','off');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
        
        % boxplot(myTable.(global_metrics{ig}).input.g_metric,myTable.(global_metrics{ig}).input.selection_name,'grouporder',{'Odor11to40','TPnoPuff11to40','Odor81to120','TPnoPuff81to120'}); hold on;
        bb=notBoxPlot_modified([[myTable.(global_metrics{ig}).input.g_metric(strcmp(myTable.(global_metrics{ig}).input.selection_name,'Odor11to40'))],[myTable.(global_metrics{ig}).input.g_metric(strcmp(myTable.(global_metrics{ig}).input.selection_name,'TPnoPuff11to40'))],[myTable.(global_metrics{ig}).input.g_metric(strcmp(myTable.(global_metrics{ig}).input.selection_name,'Odor81to120'))],[myTable.(global_metrics{ig}).input.g_metric(strcmp(myTable.(global_metrics{ig}).input.selection_name,'TPnoPuff81to120'))]]);
        for ib=1:length(bb)
            bb(ib).data.MarkerSize=8;
            bb(ib).data.MarkerEdgeColor='none';
            bb(ib).semPtch.EdgeColor='none';
            bb(ib).sdPtch.EdgeColor='none';
        end
        
        % color definitions
        bb(1).data.MarkerFaceColor= [204/255 51/255 204/255].*0.5;
        bb(1).mu.Color= [204/255 51/255 204/255].*0.5;
        bb(1).semPtch.FaceColor= [255/255 102/255 204/255].*0.5;
        bb(1).sdPtch.FaceColor= [255/255 204/255 204/255].*0.5;
        % color definitions
        bb(2).data.MarkerFaceColor= [204/255 51/255 204/255];
        bb(2).mu.Color= [204/255 51/255 204/255];
        bb(2).semPtch.FaceColor= [255/255 102/255 204/255];
        bb(2).sdPtch.FaceColor= [255/255 204/255 204/255];
        % color definitions
        bb(3).data.MarkerFaceColor= [0 160/255 227/255].*0.5;
        bb(3).mu.Color= [0 160/255 227/255].*0.5;
        bb(3).semPtch.FaceColor= [75/255 207/255 227/255].*0.5;
        bb(3).sdPtch.FaceColor= [150/255 255/255 227/255].*0.5;
        % color definitions
        bb(4).data.MarkerFaceColor= [0 160/255 227/255];
        bb(4).mu.Color= [0 160/255 227/255];
        bb(4).semPtch.FaceColor= [75/255 207/255 227/255];
        bb(4).sdPtch.FaceColor= [150/255 255/255 227/255];
        
        
        % axis
        box('off');
        ax=gca;
        ax.YLabel.String='A.U.';
        ax.XTickLabel={'Odor11to40','TPnoPuff11to40','Odor81to120','TPnoPuff81to120'};
        ax.FontSize=14;
        ax.FontWeight='bold';
        ax.LineWidth=2;
        rotateXLabels(ax,45);
        % title
        if separated_hemisphere==0
            tt=title([global_metrics{ig} ' (' binarization_method ', combined hemisph.)']);
        elseif separated_hemisphere==1
            tt=title([global_metrics{ig} ' (' binarization_method ', separated hemisph.)']);
        end
        tt.Interpreter='none';
        
        % information on statistics
        tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['p_b_l_o_c_k=' num2str(p_block.(global_metrics{ig}))]);
        if p_block.(global_metrics{ig})<.05
            tx.Color=[0.8,0,0];
        end
        tx=text(ax.XLim(1)+.2*(diff(ax.XLim)),ax.YLim(1)+.15*(diff(ax.YLim)),['p_i_n_t_r_a_t_r_i_a_l_T_P=' num2str(p_IT_timepoint.(global_metrics{ig}))]);
        if p_IT_timepoint.(global_metrics{ig})<.05
            tx.Color=[0.8,0,0];
        end
        tx=text(ax.XLim(1)+.3*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_i_n_t_e_r_a_c_t_i_o_n=' num2str(p_interaction.(global_metrics{ig}))]);
        if p_interaction.(global_metrics{ig})<.05
            tx.Color=[0.8,0,0];
        end
        
        % results for saving
        % loop over the four time point
        for auc_idx = 1:length(myData)
            res_auc_struc.(global_metrics{ig}).(selection_name{auc_idx}) = [myData{auc_idx}.auc_struc.(global_metrics{ig})]';
        end
        
        % print
        [annot, srcInfo] = docDataSrc(fig(ig),fullfile(outputDir),mfilename('fullpath'),logical(1));
        exportgraphics(fig(ig),fullfile(outputDir,['GA_globalLME_' global_metrics{ig} '.pdf']),'Resolution',300);
        print('-dpsc',fullfile(outputDir,['GA_globalLME']),'-painters','-r400','-append');
        
        % close
        close all;
    end

    % save data
    save(fullfile(outputDir,['res_auc_struc_global.mat']),'res_auc_struc');
end

