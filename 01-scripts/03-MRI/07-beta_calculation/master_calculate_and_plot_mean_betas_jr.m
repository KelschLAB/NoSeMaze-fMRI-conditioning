%% master_calculate_and_plot_mean_betas_jr.m
% Reinwald, Jonathan
% last update: 02/2023
% Script for calculating and plotting of mean betas

%% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %%
% mask_*.nii-files are needed before for the definition of the region of interest, e.g., the "insula blob"
% --> save them in your GLM folders beforehand

% Preparation
clear all
clc
close all

% Select GLM analysis for beta calculation
GLMdir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/'
workDir = spm_select(1,'dir','Select Directory with GLM',{},GLMdir);
GLM2ndlevel_dir = fullfile(workDir,'secondlevel');
GLM1stlevel_dir = fullfile(workDir,'firstlevel');

% List of regions
contrastlist = dir(GLM2ndlevel_dir);
% delete ./..
contrastlist = contrastlist(~contains({contrastlist.name},'.'));

%% Loop over contrasts
for cix = 1:length(contrastlist)
    
    % go to directory
    cd(fullfile(contrastlist(cix).folder,contrastlist(cix).name));
    
    %% 1. Check for pre-existing masks
    clear masklist
    % List of regions
    masklist = dir(fullfile(contrastlist(cix).folder,contrastlist(cix).name));
    % delete ./..
    masklist = masklist(contains({masklist.name},'mask_') & contains({masklist.name},'activation_') & contains({masklist.name},'.nii'));
    
    %% Only if masks exists, the following is running!
    if ~isempty(masklist)
        
        % Loop over masks
        for mx = 1:length(masklist)
            
            % mask
            P_mask = fullfile(masklist(mx).folder,masklist(mx).name);
            
            % Calculation of mean values
            V_mask = spm_vol(P_mask);
            img_mask = spm_read_vols(V_mask);
            img_mask(img_mask==0)=nan;
            img_mask(img_mask>0)=1;
            
            %% Calculation is only performed if the image file (mask) contains values
            if nansum(nansum(nansum(img_mask)))>0
                
                clear res
                
                load(fullfile(GLM1stlevel_dir,'contrast_info.mat'));
                contrast_id = find(strcmp(contrast_info.names,contrastlist(cix).name));
                
                %% 1. From spmT_000X.nii
                if contrast_id < 10
                    contrast_abbrev = ['spmT_000' num2str(contrast_id)]
                elseif contrast_id >= 10
                    contrast_abbrev = ['spmT_00' num2str(contrast_id)]
                end
                [GLM1stlevel_contrastlist]=spm_select('FPListRec',GLM1stlevel_dir,[contrast_abbrev '.nii']);
                
                for ix = 1:size(GLM1stlevel_contrastlist,1)
                    P=deblank(GLM1stlevel_contrastlist(ix,:));
                    V=spm_vol(P);
                    img=spm_read_vols(V);
                    
                    clear fdir fname
                    [fdir,~,~]=fileparts(deblank(GLM1stlevel_contrastlist(ix,:)));
                    [~,fname,~]=fileparts(fdir);
                    
                    res.name{ix} = fname;
                    res.mean_spmT(ix) = nanmean(nanmean(nanmean(img.*img_mask)));
                end
                
                %% 2. From betas.nii
                % Load SPM.mat
                load(fullfile(GLM1stlevel_dir,'ZI_M11','SPM.mat'));
                
                clear beat_neg beta_pos
                beta_neg = find(SPM.xCon(contrast_id).c==-1);
                beta_pos = find(SPM.xCon(contrast_id).c==1);
                
                if ~isempty(beta_neg) && beta_neg < 10
                    beta_neg_abbrev = ['beta_000' num2str(beta_neg)]
                elseif ~isempty(beta_neg) && beta_neg >= 10
                    beta_neg_abbrev = ['beta_00' num2str(beta_neg)]
                end
                if beta_pos < 10
                    beta_pos_abbrev = ['beta_000' num2str(beta_pos)]
                elseif beta_pos >= 10
                    beta_pos_abbrev = ['beta_00' num2str(beta_pos)]
                end
                
                if ~isempty(beta_neg)
                    [GLM1stlevel_betalist_neg]=spm_select('FPListRec',GLM1stlevel_dir,[beta_neg_abbrev '.nii']);
                end
                [GLM1stlevel_betalist_pos]=spm_select('FPListRec',GLM1stlevel_dir,[beta_pos_abbrev '.nii']);
                
                for ix = 1:size(GLM1stlevel_betalist_pos,1)
                    
                    if ~isempty(beta_neg)
                        P=deblank(GLM1stlevel_betalist_neg(ix,:));
                        V=spm_vol(P);
                        img_neg=spm_read_vols(V);
                        res.(['mean_beta_' SPM.Sess.U(beta_neg).name{1}])(ix) = nanmean(nanmean(nanmean(img_neg.*img_mask)));
                    end
                    
                    P=deblank(GLM1stlevel_betalist_pos(ix,:));
                    V=spm_vol(P);
                    img_pos=spm_read_vols(V);
                    
                    clear fdir fname
                    [fdir,~,~]=fileparts(deblank(GLM1stlevel_betalist_pos(ix,:)));
                    [~,fname,~]=fileparts(fdir);
                    
                    res.name{ix} = fname;
                    res.(['mean_beta_' SPM.Sess.U(beta_pos).name{1}])(ix) = nanmean(nanmean(nanmean(img_pos.*img_mask)))
                end
                
                % figure
                fig1=figure('visible', 'off');
                set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.15,0.7]);
                
                %% Subplot both groups
                % boxplot
                clear fieldnames_res myFieldnames myResToPlot bb
                fieldnames_res=fieldnames(res);
                myFieldnames = fieldnames_res(contains(fieldnames_res,'beta'));
                myResToPlot=[];
                for ixx=1:length(myFieldnames)
                    myResToPlot=[myResToPlot,[res.(myFieldnames{ixx})]'];
                    myLabels{ixx}=myFieldnames{ixx}(strfind(myFieldnames{ixx},'Bl'):end);
                end
                
                if size(myResToPlot,2)==1
                    bb=notBoxPlot(myResToPlot);
                elseif size(myResToPlot,2)==2
                    bb=notBoxPlot_modified(myResToPlot);
                end
                
                if exist('bb','var') == 1
                    for nBB=1:length(bb)
                        bb(nBB).data.MarkerSize = 6;
                        bb(nBB).data.MarkerEdgeColor = 'none';
                        bb(nBB).data.MarkerFaceColor = [.3 .3 .8];
                        bb(nBB).sdPtch.EdgeColor = 'none';
                        bb(nBB).semPtch.EdgeColor = 'none';
                    end
                end
                % axis
                box('off');
                ax=gca;
                %             ax.YLim=[axlimit{ig}];
                
                ax.YLabel.String='beta coeff.';
                ax.XTick=1:length(myLabels);
                ax.XTickLabel=myLabels;
                ax.XLim=[.5,size(myResToPlot,2)+.5];
                set(gca,'TickLabelInterpreter','none');
                ax.FontSize=14;
                %     ax.FontWeight='bold';
                ax.LineWidth=3;
                rotateXLabels(ax,70);
                
                % sign. test
                if length(myFieldnames)>1
                    [~,p]=ttest([res.(myFieldnames{1})]',[res.(myFieldnames{2})]');
                    if p<0.05
                        H=sigstar({[1,2]},p,0,30);
                    end
                end
                %                 h = findobj('Type','Scatter');
                %                 for ih=1:length(h)
                %                     h(ih).SizeData=80;
                %                 end
                
                if min(min(myResToPlot)) < 0 && max(max(myResToPlot)) < 0
                    ax.YLim=[-ceil(abs(ax.YLim(1))),-ceil(abs(ax.YLim(2)))];
                elseif min(min(myResToPlot)) < 0 && max(max(myResToPlot)) > 0
                    ax.YLim=[-ceil(abs(ax.YLim(1))),ceil(abs(ax.YLim(2)))];
%                 else
%                     ax.YLim=[ceil(abs(ax.YLim(1))),ceil(abs(ax.YLim(2)))];
                end
                
                % title
                tt=title(masklist(mx).name(1:end-4));
                tt.Interpreter='none';
                
                % Save
                if 1==1
                    exportgraphics(gcf,fullfile(contrastlist(cix).folder,contrastlist(cix).name,[masklist(mx).name(1:end-4) '.pdf']),'ContentType','vector')
                    save(fullfile(contrastlist(cix).folder,contrastlist(cix).name,[masklist(mx).name(1:end-4) '.mat']),'res');
                end
                
                
                close all
            end
        end
    end
end