%% master_GA_gPPI_reappraisal_jr.m
% Jonathan Reinwald, 05/2021
%
% -
%% Clearing
clear all
close all

%% Selection of method
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness_val = 'connected';

%% Select preprocessing type
mySelectedGLM = 'HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023';

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));
% add GA scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-GitLab'));
% add brain connectivity toolbox
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/2019_03_03_BCT'));

%% Load filelist
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')
end

%% Define directories
% main directory
if separated_hemisphere==0
    mainDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/combined_hemisphere/',mySelectedGLM);
elseif separated_hemisphere==1
    mainDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/separated_hemisphere/',mySelectedGLM);
end
% output directory
[fdir,fname2,~]=fileparts(mainDir);
[~,fname1,~]=fileparts(fdir);
outputdir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/09-GA_gPPI',fname1,fname2,binarization_method);
if ~exist(outputdir)
    mkdir(outputdir)
end
cd(outputdir);
% load PPI file
load(fullfile(mainDir,'results_PPI_symmetric.mat'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over conditions (e.g. Lavender, Puff, ...)
if 1==1
    for cond_idx = [2,5,7,10]%1:size(PPI_betas_all,3)
        % clear
        clear cormat 
        
        % make "cormat-file" out of PPI
        % Loop over subjects
        for subj_idx = 1:size(PPI_betas_all,4)
            cormat{1,subj_idx}=squeeze(PPI_betas_all(:,:,cond_idx,subj_idx));
        end
        
        % load and define names
        load(fullfile(mainDir,'roidata.mat'));
        names={subj(1).roi.name};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% The following is adapted from rb_network_example.m
        % by Jonathan Reinwald, 05/2021
        
        %%  ---------- delete diagonal elements of cormats -----------------
        if 1==1
            % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=cormat{jmat}.*~eye(size(cormat{jmat}));
            end
            % Save cormat
            save([outputdir filesep 'cormat_' res(cond_idx).name{1} '.mat'],'cormat','names');
        end
        
        %% ------ analyze positive/negative weights seperatly or use absolute values ----------
        % NB: for correlation networks this is a necessary step of the analysis, as some network
        % properties can not be calculated (or don't make sense) if negative weights are involved
        % For wavelet coherence it's unneccessary - only positive weights in the first place
        
        % positive edges seperately
        if 1==1   
            % Load cormat
            load([outputdir filesep 'cormat_' res(cond_idx).name{1} '.mat'],'cormat','names');
            % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=cormat{jmat}.*(cormat{jmat}>0).*sign(cormat{jmat});
            end
            % Save cormat
            save([outputdir filesep 'cormat_' res(cond_idx).name{1} '_p.mat'],'cormat','names');
        end
        
        % negative edges separately (absolute weights of negative edges)
        if 1==1
            % Load cormat
            load([outputdir filesep 'cormat_' res(cond_idx).name{1} '.mat'],'cormat','names');
                        % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=cormat{jmat}.*(cormat{jmat}<0).*sign(cormat{jmat});
            end
            % Save cormat
            save([outputdir filesep 'cormat_' res(cond_idx).name{1} '_n.mat'],'cormat','names');
        end
        
        % absolute values of everything
        if 1==1
            % Load cormat
            load([outputdir filesep 'cormat_' res(cond_idx).name{1} '.mat'],'cormat','names');
                        % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=abs(cormat{jmat});
            end   
            % Save cormat
            save([outputdir filesep 'cormat_' res(cond_idx).name{1} '_a.mat'],'cormat','names');
        end     
        
% % %         %% --------------- Fisher Z-scores ------------------------
% % %         if 1==0
% % %             % Load cormat
% % %             load([outputdir filesep deblank(cormat_files(ix,:))],'cormat','names');  
% % %             % Loop over cormat
% % %             for jmat=1:numel(cormat)
% % %                 cormat{jmat}=fisherz(cormat{jmat});
% % %             end
% % %             % Save cormat
% % %             save([outputdir filesep fname '_ztrans.mat'],'cormat','names');
% % %         end      
        
        %% ------ Calculate network properties over a range of thresholds        
        % Normalization methods: 'max': normalze to maximum weight, 'bin': binarize, 'none': don't normalize
        normalize = binarization_method; % choose normalization procedure, see help rb_graph_thresh_flex for options
        
        if 1==1    
            % Load cormat
            clear cormat
            load([outputdir filesep 'cormat_' res(cond_idx).name{1} '_p.mat'],'cormat','names');
            % Define thresholds
            cutoffs = [0.1:0.01:0.7]; % density thresholds, just a minimal example - adjust to your needs!!!
            
            % Choose graph metrics
            if strcmp(connectedness_val,'connected')
                calcat={'all'}; % chose which graph metrics to calculate, see help rb_graph_thresh_flex for options
            else
                calcat={'smallworld','efficiency','centrality','modularity','norm','swpcalc','resiliencecalc'};
            end
    
            % Transpose cormat before Running
            cormat=cormat';
            
            % Calculation of graph metrics
            gstruc = rb_graph_thresh_flex(cormat,cutoffs,normalize,calcat);
            % Save gstruc
            save([outputdir filesep 'gstruc_' res(cond_idx).name{1} '_p.mat'],'gstruc');
        end
        
        
        %% ------------ calculate AUC ------------------------------
        if 1==1
            % calculate averages of graph metrics over a range of thresholds
            % (choice of threshold is arbitrary)
            
            % Load gstruc
            load([outputdir filesep 'gstruc_' res(cond_idx).name{1} '_p.mat'],'gstruc');
            
            % thresholds to take into calculation for AUC. These are indices for
            % positions in the threshold vector!
            minthr_ind=1;
            maxthr_ind=41;
            
            % Calculation of AUC
            auc_struc=rb_gstruc_2_auc(gstruc,minthr_ind,maxthr_ind);
            % Save gstruc
            save([outputdir filesep 'auc_struc_' res(cond_idx).name{1} '_p.mat'],'auc_struc');
        end      
    end
end

%% Loop over cormat conditions (e.g. Lavender, Puff, ...)
% % 1 'cormat_v1_Lavender.mat       '
% % 2 'cormat_v1_Odor11to40.mat     '
% % 3 'cormat_v1_Odor1to10.mat      '
% % 4 'cormat_v1_Odor1to20.mat      '
% % 5 'cormat_v1_Odor1to40.mat      '
% % 6 'cormat_v1_Odor21to40.mat     '
% % 7 'cormat_v1_Odor41to80.mat     '
% % 8 'cormat_v1_Odor81to120.mat    '
% % 9 'cormat_v1_Odor_TPNoPuff.mat  '
% % 10 'cormat_v1_Odor_TPPuff.mat    '
% % 11 'cormat_v1_TP-NoPuff.mat      '
% % 12 'cormat_v1_TP-Puff.mat        '
% % 13 'cormat_v1_TPnoPuff11to40.mat '
% % 14 'cormat_v1_TPnoPuff1to10.mat  '
% % 15 'cormat_v1_TPnoPuff1to20.mat  '
% % 16 'cormat_v1_TPnoPuff1to40.mat  '
% % 17 'cormat_v1_TPnoPuff21to40.mat '
% % 18 'cormat_v1_TPnoPuff41to80.mat '
% % 19 'cormat_v1_TPnoPuff81to120.mat'

