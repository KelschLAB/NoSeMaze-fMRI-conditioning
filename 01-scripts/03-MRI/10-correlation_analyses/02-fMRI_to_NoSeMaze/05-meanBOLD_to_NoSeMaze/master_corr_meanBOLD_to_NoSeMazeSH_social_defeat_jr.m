%% master_corr_meanBOLD_to_NoSeMazeSH_social_defeat_jr.m
% Reinwald, Jonathan; 08/2023

% genera description:
% - script for correlation analysis with SPM12 between data from the NoSeMaze
%   and the BOLD response (to the reappraisal task)
% - here, the data from the social hierarchy assessed with the tube tests
%   is used as explanatory covariate
% - run XXX BEFORE

%% Preparation
clear all;
close all;

% 
% selection = 'Diff_Ranks_22_mice';
selection = 'Diff_DSz_22_mice';
% selection = 'Rank_before_22_mice';

% Select GLM analysis for beta calculation
GLMdir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results/'
workDir = spm_select(1,'dir','Select Directory with GLM',{},GLMdir);
% GLM2ndlevel_dir = fullfile(workDir,'secondlevel');
GLM2ndlevel_dir = fullfile(workDir,['secondlevel_' selection]);

% working directory
outputDir = fullfile('/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/02-social_defeat/08-correlation_analyses_fMRI_to_NoSeMaze/01-BOLD_to_NoSeMaze',selection);
mkdir(outputDir);
cd(workDir);

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/07-GitHub_KelschLab'))

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
    masklist = masklist(contains({masklist.name},'mask_') & contains({masklist.name},'.nii'));
    
    %% Only if masks exists, the following is running!
    if ~isempty(masklist)
        
        % Loop over masks
        for mx = 1:length(masklist)
            
            %% Load beta coefficients (saved in script master_calculate_and_plot_mean_betas_jr.m)
            [~,fname,~] = fileparts(masklist(mx).name);
            load(fullfile(masklist(mx).folder,[fname '.mat']));
            
            %% Load rank_diff
            load(fullfile(masklist(mx).folder,'SPM.mat'));
            rank_diff = SPM.xC.rc;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% ANALYSIS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % figure
            fig(1)=figure('visible', 'on');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.3,0.7]);
            
            %% Load and calculate beta difference (BOLD)
            if sum(strcmp(fieldnames(res),'mean_betaNeg'))
                beta_diff = [res.mean_betaPos]'-[res.mean_betaNeg]';
                beta_CD1unk = [res.mean_betaNeg]';
                beta_CD1fam = [res.mean_betaPos]';
                beta_CD1unk([10,18])=[];
                beta_CD1fam([10,18])=[];
                beta_diff([10,18])=[];
            else
                beta_CD1fam = [res.mean_betaPos]';
                % exclude animal 10 and 18
                beta_CD1fam([10,18])=[];
            end
            
            
            % Correlations:
            if sum(strcmp(fieldnames(res),'mean_betaNeg'))
                [rr(1),pp(1)]=corr(rank_diff,beta_CD1fam,'type','Pearson');
                [rr(2),pp(2)]=corr(rank_diff,beta_CD1fam,'type','Spearman');
                [rr(3),pp(3)]=corr(rank_diff,beta_CD1unk,'type','Pearson');
                [rr(4),pp(4)]=corr(rank_diff,beta_CD1unk,'type','Spearman');
                [rr(5),pp(5)]=corr(rank_diff,beta_diff,'type','Pearson');
                [rr(6),pp(6)]=corr(rank_diff,beta_diff,'type','Spearman');
            else
                [rr(1),pp(1)]=corr(rank_diff,beta_CD1fam,'type','Pearson');
                [rr(2),pp(2)]=corr(rank_diff,beta_CD1fam,'type','Spearman');
            end
            
            
            %% subplot
            subplot(2,3,1);
            % boxplot
            if sum(strcmp(fieldnames(res),'mean_betaNeg'))
                bb=notBoxPlot_modified([beta_CD1fam,beta_CD1unk]);
            else
                bb=notBoxPlot_modified(beta_CD1fam);
            end
            for ib=1:length(bb)
                bb(ib).data.MarkerSize=6;
                bb(ib).data.MarkerEdgeColor='none';
                bb(ib).semPtch.EdgeColor='none';
                bb(ib).sdPtch.EdgeColor='none';
            end
            % color definitions
            bb(1).data.MarkerFaceColor= [204/255 51/255 204/255];
            bb(1).mu.Color= [204/255 51/255 204/255];
            bb(1).semPtch.FaceColor= [255/255 102/255 204/255];
            bb(1).sdPtch.FaceColor= [255/255 204/255 204/255];
            if length(bb)==2
                % color definitions
                bb(2).data.MarkerFaceColor= [0 160/255 227/255];
                bb(2).mu.Color= [0 160/255 227/255];
                bb(2).semPtch.FaceColor= [75/255 207/255 227/255];
                bb(2).sdPtch.FaceColor= [150/255 255/255 227/255];
            end
            
            % axis
            box('off');
            ax1=gca;
            %     ax1.YLim=[axlimit{ig}];
            ax1.YLabel.String={'mean BOLD'};
            if length(bb)==1
                ax1.XTick=1;
                ax1.XTickLabel={'CD1fam'};
                ax1.XLim=[.5,1.5];
            elseif length(bb)==2
                ax1.XTick=[1:2];
                ax1.XTickLabel={'CD1fam','CD1unk'};
                ax1.XLim=[.5,2.5];
            end
            ax1.FontSize=10;
            ax1.FontWeight='bold';
            ax1.LineWidth=1.5;
            rotateXLabels(ax1,45);
            
            % significance test
            if length(bb)==2
                [h,p]=ttest(beta_CD1fam,beta_CD1unk);
                [clusters, p_values, t_sums, permutation_distribution ] = permutest(beta_CD1fam',beta_CD1unk',true,0.05,10000,true);
                % sign. star
                if p_values<0.05
                    H=sigstar({[1,2]},p_values,0,10);
                end
                % plot permutation result
                tx=text(ax1.XLim(1)+.1*(diff(ax1.XLim)),ax1.YLim(1)+.2*(diff(ax1.YLim)),['p_p_e_r_m=' num2str(p_values)]);
                tx.Interpreter='tex';
            end
            
            %% subplot
            subplot(2,3,[2,3]);
            % scatter
            
            sc(1)=scatter(rank_diff,beta_CD1fam); hold on;
            % color definitions
            sc(1).MarkerFaceColor= [204/255 51/255 204/255];
            
            if sum(strcmp(fieldnames(res),'mean_betaNeg'))
                sc(2)=scatter(rank_diff,beta_CD1unk);
                % color definitions
                sc(2).MarkerFaceColor= [0 160/255 227/255];
            end
            
            for isc=1:length(sc)
                sc(isc).SizeData=40;
                sc(isc).MarkerEdgeColor='none';
            end
            
            % axis
            box('off');
            axis square;
            ax2=gca;
            ax2.YLabel.String={'mean BOLD'};
            ax2.XLabel.String={'rank diff','(after-before)'};
            ax2.XLim=[min(rank_diff),max(rank_diff)];
            ax2.XTick=[min(rank_diff):1:max(rank_diff)];
            ax2.XTickLabel=[min(rank_diff):1:max(rank_diff)];
            
            ax2.YLim(2)=ax1.YLim(2);
            ax2.FontSize=10;
            %             ax2.FontWeight='bold';
            ax2.LineWidth=1.5;
            
            % plot correlation lines
            ll = lsline;
            if length(ll)==2
                ll(1).Color=[0 160/255 227/255];
                ll(1).LineWidth=1.5;
                ll(2).Color=[204/255 51/255 204/255];
                ll(2).LineWidth=1.5;
            else
                ll(1).Color=[204/255 51/255 204/255];
                ll(1).LineWidth=1.5;                
            end
            
            % plot permutation result
            tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['p=' num2str(round(pp(1),3))]);
            tx.Color=[204/255 51/255 204/255];
            tx.FontWeight='bold';
            tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.9*(diff(ax2.YLim)),['psp=' num2str(round(pp(2),3))]);
            tx.Color=[204/255 51/255 204/255];
            tx.FontWeight='bold';
            tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.1*(diff(ax2.YLim)),['rho=' num2str(round(rr(1),3))]);
            tx.Color=[204/255 51/255 204/255];
            tx.FontWeight='bold';
            tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.9*(diff(ax2.YLim)),['rhosp=' num2str(round(rr(2),3))]);
            tx.Color=[204/255 51/255 204/255];
            tx.FontWeight='bold';
            
            if length(sc)==2
                tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['p=' num2str(round(pp(3),3))]);
                tx.Color=[0 160/255 227/255];
                tx.FontWeight='bold';
                tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.2*(diff(ax2.YLim)),['rho=' num2str(round(rr(3),3))]);
                tx.Color=[0 160/255 227/255];
                tx.FontWeight='bold';
                tx=text(ax2.XLim(1)+.1*(diff(ax2.XLim)),ax2.YLim(1)+.8*(diff(ax2.YLim)),['psp=' num2str(round(pp(4),3))]);
                tx.Color=[0 160/255 227/255];
                tx.FontWeight='bold';
                tx=text(ax2.XLim(1)+.5*(diff(ax2.XLim)),ax2.YLim(1)+.8*(diff(ax2.YLim)),['rhosp=' num2str(round(rr(4),3))]);
                tx.Color=[0 160/255 227/255];
                tx.FontWeight='bold';
            end
            
            %% subplot
            if length(sc)==2
                subplot(2,3,[5,6]);
                % boxplot
                sc=scatter(rank_diff,[beta_CD1fam-beta_CD1unk]);
                sc.SizeData=40;
                sc.MarkerEdgeColor='none';
                
                % color definitions
                sc.MarkerFaceColor= ([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                
                % axis
                box('off');
                axis square;
                ax=gca;
                ax.YLabel.String={'mean BOLD','(beta values; CD1fam - CD1unk)'};
                ax.XLabel.String={'rank diff','(after-before)'};
                ax.XLim=[min(rank_diff),max(rank_diff)];
                ax.XTick=[min(rank_diff):1:max(rank_diff)];
                ax.XTickLabel=[min(rank_diff):1:max(rank_diff)];
                ax.FontSize=10;
                %                 ax.FontWeight='bold';
                ax.LineWidth=1.5;
                
                % plot correlation lines
                ll = lsline;
                ll.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                ll.LineWidth=1.5;
                
                % plot permutation result
                tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['p=' num2str(round(pp(5),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.1*(diff(ax.YLim)),['rho=' num2str(round(rr(5),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx=text(ax.XLim(1)+.1*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['p_s_p=' num2str(round(pp(6),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx.Interpreter='tex';
                tx=text(ax.XLim(1)+.5*(diff(ax.XLim)),ax.YLim(1)+.2*(diff(ax.YLim)),['rho_s_p=' num2str(round(rr(6),3))]);
                tx.Color=([204/255 51/255 204/255]+[0 160/255 227/255])./2;
                tx.FontWeight='bold';
                tx.Interpreter='tex';
                
                %
                ax1.YLim=ax2.YLim;
            end
            
            % suptitle
            sup=suptitle([fname ' - ' selection]);
            sup.Interpreter='none';
            
            % print
            [annot, srcInfo] = docDataSrc(fig(1),fullfile(outputDir),mfilename('fullpath'),logical(1));
            exportgraphics(fig(1),fullfile(outputDir,['Correlation_BOLD' fname '_to_' selection '.pdf']),'Resolution',300);
            exportgraphics(fig(1),fullfile(outputDir,['Correlation_BOLD' fname '_to_' selection '.png']),'Resolution',300);
            
            % save source data in csv
            if length(sc)==2
                SourceData = array2table([rank_diff,beta_CD1fam,beta_CD1unk,beta_diff],'VariableNames',{'rank_diff','beta_CD1fam','beta_CD1unk','diff'});
                writetable(SourceData,fullfile(outputDir,['SourceData_Correlation_BOLD' fname '_to_' selection '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
            else
                SourceData = array2table([rank_diff,beta_CD1fam],'VariableNames',{'rank_diff','beta_CD1fam'});
                writetable(SourceData,fullfile(outputDir,['SourceData_Correlation_BOLD' fname '_to_' selection '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
            end
            
            close all
        end
        
    end
end

