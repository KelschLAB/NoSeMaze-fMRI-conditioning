clear all;
clc;
close all;

PPI_dir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/combined_hemisphere/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/PPI_files'
PPI_files=spm_select('FPList',PPI_dir,'^PPI_.*.mat');

load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/combined_hemisphere/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/roidata.mat');
names={subj(1).roi.name};

selection_name{1}='Odor11to40';
selection_name{2}='Odor81to120';
selection_name{3}='TPnoPuff11to40';
selection_name{4}='TPnoPuff81to120';

%% Loop over regions
for reg_idx=1:length(names)
    
    % set counter
    counter=1;
    
    %% Loop over animals
    for animal_idx=1:size(PPI_files,1)
        % load PPI
        load(deblank(PPI_files(animal_idx,:)));
        
        %% Loop over the four time point
        for tp_idx = 1:4
            
            % animal
            animal(counter)=animal_idx;
            
            % intra-trial timepoint, block, strength
            
            if tp_idx==1
                % strength calculation
                [is,os,str] = strengths_dir(squeeze(PPI_beta(:,:,2)));                
                % intra-trial timepoint
                IT_timepoint{counter}='Odor';
                % strength
                in_strength(counter)=is(reg_idx);
                out_strength(counter)=os(reg_idx);
                all_strength(counter)=str(reg_idx);
                % block
                block(counter)=1;
                
            elseif tp_idx==2
                % strength calculation
                [is,os,str] = strengths_dir(squeeze(PPI_beta(:,:,5)));
                % intra-trial timepoint
                IT_timepoint{counter}='Odor';
                % strength
                in_strength(counter)=is(reg_idx);
                out_strength(counter)=os(reg_idx);
                all_strength(counter)=str(reg_idx);
                % block
                block(counter)=3;
                
            elseif tp_idx==3
                % strength calculation
                [is,os,str] = strengths_dir(squeeze(PPI_beta(:,:,7)));
                % intra-trial timepoint
                IT_timepoint{counter}='TPnoPuff';
                % strength
                in_strength(counter)=is(reg_idx);
                out_strength(counter)=os(reg_idx);
                all_strength(counter)=str(reg_idx);
                % block
                block(counter)=1;
                
            elseif tp_idx==4
                % strength calculation
                [is,os,str] = strengths_dir(squeeze(PPI_beta(:,:,10)));
                % intra-trial timepoint
                IT_timepoint{counter}='TPnoPuff';
                % strength
                in_strength(counter)=is(reg_idx);
                out_strength(counter)=os(reg_idx);
                all_strength(counter)=str(reg_idx);
                % block
                block(counter)=3;
                
            end
            
            selection_name_tbl{counter}=selection_name{tp_idx};
            
            % counter update
            counter=counter+1;
        end
    end
    
    % create the input table
    myTable.in_strength(reg_idx).input = table(block',IT_timepoint',animal',in_strength',selection_name_tbl','VariableNames',{'block','IT_timepoint','animal','l_metric','selection_name'});
    myTable.in_strength(reg_idx).input.animal = categorical(myTable.in_strength(reg_idx).input.animal);
    myTable.in_strength(reg_idx).input.block = categorical(myTable.in_strength(reg_idx).input.block);
    
    % fit linear mixed effects model (% choosing between individual
    % slopes for all animals (block|animal) or on slope (1|animal),
    % see also:
    % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
    % ( The Importance of Random Slopes in Mixed Models for Bayesian
    % Hypothesis Testing, Klaus Oberauer)
    lme = fitlme(myTable.in_strength(reg_idx).input,'l_metric ~ 1 + block*IT_timepoint + (1|animal)');
    %         lme_new = fitlme(myTable(reg_idx).input,'l_metric ~ 1 + block*timepoint + (block*timepoint|animal)');
    % CAVE: robust linear models are implemented in R and might
    % ameliorate some results (robustlmm)
    % p values
    p_intercept.in_strength(reg_idx)=double(lme.Coefficients(1,6));
    p_block.in_strength(reg_idx)=double(lme.Coefficients(2,6));
    p_IT_timepoint.in_strength(reg_idx)=double(lme.Coefficients(3,6));
    p_interaction.in_strength(reg_idx)=double(lme.Coefficients(4,6));
    % betas
    beta_intercept.in_strength(reg_idx)=double(lme.Coefficients(1,2));
    beta_block.in_strength(reg_idx)=double(lme.Coefficients(2,2));
    beta_IT_timepoint.in_strength(reg_idx)=double(lme.Coefficients(3,2));
    beta_interaction.in_strength(reg_idx)=double(lme.Coefficients(4,2));
    % t-values
    tval_intercept.in_strength(reg_idx)=double(lme.Coefficients(1,4));
    tval_block.in_strength(reg_idx)=double(lme.Coefficients(2,4));
    tval_IT_timepoint.in_strength(reg_idx)=double(lme.Coefficients(3,4));
    tval_interaction.in_strength(reg_idx)=double(lme.Coefficients(4,4));
    
    % create the input table
    myTable.out_strength(reg_idx).input = table(block',IT_timepoint',animal',out_strength',selection_name_tbl','VariableNames',{'block','IT_timepoint','animal','l_metric','selection_name'});
    myTable.out_strength(reg_idx).input.animal = categorical(myTable.out_strength(reg_idx).input.animal);
    myTable.out_strength(reg_idx).input.block = categorical(myTable.out_strength(reg_idx).input.block);
        
    % fit linear mixed effects model (% choosing between individual
    % slopes for all animals (block|animal) or on slope (1|animal),
    % see also:
    % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
    % ( The Importance of Random Slopes in Mixed Models for Bayesian
    % Hypothesis Testing, Klaus Oberauer)
    lme = fitlme(myTable.out_strength(reg_idx).input,'l_metric ~ 1 + block*IT_timepoint + (1|animal)');
    %         lme_new = fitlme(myTable(reg_idx).input,'l_metric ~ 1 + block*timepoint + (block*timepoint|animal)');
    % CAVE: robust linear models are implemented in R and might
    % ameliorate some results (robustlmm)
    % p values
    p_intercept.out_strength(reg_idx)=double(lme.Coefficients(1,6));
    p_block.out_strength(reg_idx)=double(lme.Coefficients(2,6));
    p_IT_timepoint.out_strength(reg_idx)=double(lme.Coefficients(3,6));
    p_interaction.out_strength(reg_idx)=double(lme.Coefficients(4,6));
    % betas
    beta_intercept.out_strength(reg_idx)=double(lme.Coefficients(1,2));
    beta_block.out_strength(reg_idx)=double(lme.Coefficients(2,2));
    beta_IT_timepoint.out_strength(reg_idx)=double(lme.Coefficients(3,2));
    beta_interaction.out_strength(reg_idx)=double(lme.Coefficients(4,2));
    % t-values
    tval_intercept.out_strength(reg_idx)=double(lme.Coefficients(1,4));
    tval_block.out_strength(reg_idx)=double(lme.Coefficients(2,4));
    tval_IT_timepoint.out_strength(reg_idx)=double(lme.Coefficients(3,4));
    tval_interaction.out_strength(reg_idx)=double(lme.Coefficients(4,4));
    
    % create the input table
    myTable.all_strength(reg_idx).input = table(block',IT_timepoint',animal',all_strength',selection_name_tbl','VariableNames',{'block','IT_timepoint','animal','l_metric','selection_name'});
    myTable.all_strength(reg_idx).input.animal = categorical(myTable.all_strength(reg_idx).input.animal);
    myTable.all_strength(reg_idx).input.block = categorical(myTable.all_strength(reg_idx).input.block);
        
    % fit linear mixed effects model (% choosing between individual
    % slopes for all animals (block|animal) or on slope (1|animal),
    % see also:
    % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
    % ( The Importance of Random Slopes in Mixed Models for Bayesian
    % Hypothesis Testing, Klaus Oberauer)
    lme = fitlme(myTable.all_strength(reg_idx).input,'l_metric ~ 1 + block*IT_timepoint + (1|animal)');
    %         lme_new = fitlme(myTable(reg_idx).input,'l_metric ~ 1 + block*timepoint + (block*timepoint|animal)');
    % CAVE: robust linear models are implemented in R and might
    % ameliorate some results (robustlmm)
    % p values
    p_intercept.all_strength(reg_idx)=double(lme.Coefficients(1,6));
    p_block.all_strength(reg_idx)=double(lme.Coefficients(2,6));
    p_IT_timepoint.all_strength(reg_idx)=double(lme.Coefficients(3,6));
    p_interaction.all_strength(reg_idx)=double(lme.Coefficients(4,6));
    % betas
    beta_intercept.all_strength(reg_idx)=double(lme.Coefficients(1,2));
    beta_block.all_strength(reg_idx)=double(lme.Coefficients(2,2));
    beta_IT_timepoint.all_strength(reg_idx)=double(lme.Coefficients(3,2));
    beta_interaction.all_strength(reg_idx)=double(lme.Coefficients(4,2));
    % t-values
    tval_intercept.all_strength(reg_idx)=double(lme.Coefficients(1,4));
    tval_block.all_strength(reg_idx)=double(lme.Coefficients(2,4));
    tval_IT_timepoint.all_strength(reg_idx)=double(lme.Coefficients(3,4));
    tval_interaction.all_strength(reg_idx)=double(lme.Coefficients(4,4));
end

%% 1. Overview plot
% figure
fig(1)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
    
sp1=subplot(1,2,1);
clear p_all;
p_all=[p_block.out_strength',p_IT_timepoint.out_strength',p_interaction.out_strength'];
t_all=[tval_block.out_strength',tval_IT_timepoint.out_strength',tval_interaction.out_strength'];
H=imagesc(t_all);
for jx=1:size(p_all,2)
    FDR_threshold=FDR(p_all(:,jx)',0.05);
    for ix=1:size(p_all,1)
        if p_all(ix,jx)<=0.05
            tt=text(jx,ix,'*');
            tt.FontSize=8;
            tt.FontWeight='bold';
            tt.Color=[0,0,0];
        end
        if ~isempty(FDR_threshold)
            if p_all(ix,jx)<=FDR_threshold
                tt=text(jx,ix,'§');
                tt.FontSize=10;
                tt.FontWeight='bold';
                tt.Color=[1,0,0];
            end
        end
    end
end


ax=gca;
ax.YTick=[1:length(names)];
ax.YTickLabel=names;
ax.FontSize=10;
ax.XTick=[1:3];
ax.XTickLabel=lme.CoefficientNames(2:4);
rotateXLabels(ax,45);
colormap(sp1,jet)
ax.CLim=[-5,5];
colorbar

% title
tt=title('out_strength');
tt.Interpreter='none';
tt.FontSize=10;

% Loop over regions
for roi_idx=1:size(p_all,1)
    % only plot if one metric is significant
    if any(p_all(roi_idx,:)<.05)
        % set figure
        fig(roi_idx)=figure('visible','on');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.7]);
        
        % boxplot
        bb=notBoxPlot_modified([[myTable.out_strength(roi_idx).input.l_metric(strcmp(myTable.out_strength(roi_idx).input.selection_name,'Odor11to40'))],[myTable.out_strength(roi_idx).input.l_metric(strcmp(myTable.out_strength(roi_idx).input.selection_name,'TPnoPuff11to40'))],[myTable.out_strength(roi_idx).input.l_metric(strcmp(myTable.out_strength(roi_idx).input.selection_name,'Odor81to120'))],[myTable.out_strength(roi_idx).input.l_metric(strcmp(myTable.out_strength(roi_idx).input.selection_name,'TPnoPuff81to120'))]]);
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
            tt=title([names{roi_idx} ': all strength' ]);
        tt.Interpreter='none';
        
        % information on statistics
        tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['p_b_l_o_c_k=' num2str(p_block.out_strength(roi_idx))]);
        if p_block.out_strength(roi_idx)<.05
            tx.Color=[0.8,0,0];
        end
        tx=text(ax.XLim(1)+.2*(diff(ax.XLim)),ax.YLim(1)+.15*(diff(ax.YLim)),['p_i_n_t_r_a_t_r_i_a_l_T_P=' num2str(p_IT_timepoint.out_strength(roi_idx))]);
        if p_IT_timepoint.out_strength(roi_idx)<.05
            tx.Color=[0.8,0,0];
        end
        tx=text(ax.XLim(1)+.3*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_i_n_t_e_r_a_c_t_i_o_n=' num2str(p_interaction.out_strength(roi_idx))]);
        if p_interaction.out_strength(roi_idx)<.05
            tx.Color=[0.8,0,0];
        end
        
%         % print
%         [annot, srcInfo] = docDataSrc(fig(roi_idx),fullfile(outputDir),mfilename('fullpath'),logical(1));
%         exportgraphics(fig(roi_idx),fullfile(outputDir,['GA_localLME_' local_metrics{ig} names{roi_idx} '.pdf']),'Resolution',300);
%         print('-dpsc',fullfile(outputDir,['GA_localLME_' local_metrics{ig} '_allRegions']),'-painters','-r400','-append');
    end
end

