%% master_gPPI_social_defeat_jr.m

%       ROIs: a time points x ROIs x sessions matrix with regional BOLD time courses
%             in the columns
%       SPMmat: SPM.mat of the individual first level analyses, either
%               'SPM.mat' if SPM.mat should be taken from the directory
%               where the function is located in or the complete path
%               including the file.
%       Outname: name of the file to save the results (betas) in

%% Preparation
clear all;
% close all;

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
HRF_name = ['HRF' HRF_TCbased '_' HRF_infopath];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_'; % No smoothing before cormat creation
epiSuffix = '_c1_c2t_wds';

% GLM dir
GLM_dir= spm_select(1,'dir','Select GLM Directory',{},'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/03-results');

%% Set pathes for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));

%% Path definition
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/12-gPPI';
if exist(main_dir)~=7
    mkdir(main_dir);
end

[~,fname,~]=fileparts(GLM_dir);
% create working directory
work_dir = fullfile(main_dir,fname);
if exist(work_dir)~=7
    mkdir(work_dir);
end
cd(work_dir);

% create directory for plots
save_dir = fullfile(work_dir,'plots');
if exist(save_dir)~=7
    mkdir(save_dir);
end
if exist(fullfile(save_dir,'AllConditions.ps'))==2
    delete(fullfile(save_dir,'AllConditions.ps'));
end
if exist(fullfile(save_dir,'AllTtests.ps'))==2
    delete(fullfile(save_dir,'AllTtests.ps'));
end


%% Predefine atlas
%% combinded hemispheres
Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged_jr.txt';
Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged.nii';
%% separated hemispheres
%     Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.txt';
%     Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.nii';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Create cormat file
if 1==0
    % Loop over animals
    for subj_ix = 1:length(Pfunc_social_defeat)
        
        % Select functional data
        [fdir, fname, ext]=fileparts(Pfunc_social_defeat{subj_ix});
        Pfunc_all{subj_ix} = spm_select('ExtFPlist',[fdir filesep 'wavelet'],['^' epiPrefix fname epiSuffix '.nii'],1);
    end
    [cormat  subj]=wwf_covmat_hres_jr(Ptxt,char(Pfunc_all),Patlas);
    save(fullfile(work_dir,['cormat.mat']),'cormat');
    save(fullfile(work_dir,['roidata.mat']),'subj');
end

%% 2. Create ROI-mat and run gppi
if 1==0
    % load roidata
    load(fullfile(work_dir,['roidata.mat']),'subj');
    
    % Loop over animals
    for subj_ix = 1:length(Pfunc_social_defeat)
        % subjAbrev
        [fdir, fname, ext]=fileparts(Pfunc_social_defeat{subj_ix});
        subjAbrev = fname(1:6);
        % PPI mat per subject
        Nrois = size(subj(subj_ix).roi,2);
        for roi_ix=1:Nrois;
            ppimat(:,roi_ix)=(subj(subj_ix).roi(roi_ix).tcourse)';
        end
        
        % SPM file
        spm_file=fullfile(GLM_dir,'firstlevel',subjAbrev,'SPM.mat');
        output_dir=fullfile(work_dir,'PPI_files');
        if exist(output_dir)~=7
            mkdir(output_dir);
        end
        %
        wb_gppi_spmmat(ppimat, spm_file, fullfile(output_dir,['PPI_' subjAbrev '.mat']))
    end
end

%% 3. Statistics on ROI-mat
if 1==0
    % load PPI-mat files
    input_dir=fullfile(work_dir,'PPI_files');
    PPI_files = spm_select('FPList',input_dir,['^PPI.*.mat']);
    
    % load SPM.mat file for the definition of the conditions
    [fdir, fname, ext]=fileparts(Pfunc_social_defeat{1});
    subjAbrev = fname(1:6);
    spm_file=fullfile(GLM_dir,'firstlevel',subjAbrev,'SPM.mat');
    load(spm_file);
    
    % statistics
    for subj_ix=1:size(PPI_files,1)
        load(deblank(PPI_files(subj_ix,:)));
        PPI_betas_all(:,:,:,subj_ix)=PPI_beta;
    end
    
    % general conditions
    counter=1;
    for cond_ix=1:length(SPM.Sess.U)
        for subcond_ix=1:length(SPM.Sess.U(cond_ix).name)
            % ttest
            for r1=1:size(PPI_betas_all,1)
                for r2=1:size(PPI_betas_all,1)
                    [res(counter).h(r1,r2),res(counter).p(r1,r2),ci,stats] = ttest(squeeze(PPI_betas_all(r1,r2,counter,:)));
                    res(counter).tstat(r1,r2)=stats.tstat;
                    res(counter).name = SPM.Sess.U(cond_ix).name(subcond_ix);
                end
            end
            % counter update
            counter=counter+1;
        end
    end
    
    % comparisons conditions
    counter=1;
    for cond_ix=1:(length(SPM.Sess.U)-1)
        for comp_ix=(cond_ix+1):length(SPM.Sess.U)
            % ttest
            for r1=1:size(PPI_betas_all,1)
                for r2=1:size(PPI_betas_all,1)
                    [res_comp(counter).h(r1,r2),res_comp(counter).p(r1,r2),ci,stats] = ttest(squeeze(PPI_betas_all(r1,r2,cond_ix,:)),squeeze(PPI_betas_all(r1,r2,comp_ix,:)));
                    res_comp(counter).tstat(r1,r2)=stats.tstat;
                    res_comp(counter).name = [SPM.Sess.U(cond_ix).name{1} '_VS_' SPM.Sess.U(comp_ix).name{1}];
                end
            end
            % counter update
            counter=counter+1;
        end
    end
    
    % save
    save(fullfile(work_dir,'results_PPI.mat'),'res','res_comp','PPI_betas_all');
end

%% 4. Plots
if 1==1
    % load roidata for defining names
    load(fullfile(work_dir,['roidata.mat']),'subj');
    names={subj(1).roi.name};
    load(fullfile(work_dir,'results_PPI.mat'),'res','res_comp');
    % Loop over res (general PPI results for the conditions) and res_comp (t-test between conditions)
    for res_ix=1:2
        % define res
        if res_ix==1
            res=res;
        elseif res_ix==2
            res=res_comp;
        end
        for cond_ix=1:length(res)
            % plots
            fig(cond_ix)=figure('visible', 'off');
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
            
            clear T
            T=res(cond_ix).tstat;
            imagesc(T);
            set(gca,'dataAspectRatio',[1 1 1])
            ax=gca;
            set(gca,'TickLabelInterpreter','none');
            ax.CLim=[-5,5];
            ax.Colormap=jet;
            ax.XTick=[1:length(names)];
            ax.XTickLabel=names;
            ax.YTick=[1:length(names)];
            ax.YTickLabel=names;
            ax.FontSize=8;
            rotateXLabels(ax,90);
            
            % Title
            tt = title(res(cond_ix).name);
            tt.Interpreter='none';
            
            p_values=res(cond_ix).p(:);
            p_values=p_values(~isnan(p_values));
            [pID,pN,qvalues] = FDR(p_values(:),0.05);
            clear fdrmat
            if ~isempty(pID)
                fdrmat=res(cond_ix).p<pID;
            else
                fdrmat=logical(zeros(size(res(cond_ix).p)));
            end
            
            grid on
            % Mark FDR_corrected values
            for x=1:size(T,1)
                for y=1:size(T,2) %size(T,2);
                    if (x == y)
                        xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
                        patch(xv,yv,[1 1 1])
                    end
                    %                     if (p2(y,x)<0.05)
                    %                         text((x-1)+.6,y+.1,sprintf('%2.1f',T(y,x)),'color',[1 1 1], ...
                    %                             'fontsize',7) ;
                    %                     end
                    if fdrmat(y,x)
                        xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                        line(xv,yv,'linewidth',2,'color',[0 0 0]);
                    end
                end
            end
            
            % save
            cd(save_dir);
            
            % print
            [annot, srcInfo] = docDataSrc(fig(cond_ix),fullfile(save_dir),mfilename('fullpath'),logical(1));
            if res_ix==1
                exportgraphics(fig(cond_ix),fullfile(save_dir,[res(cond_ix).name{1} '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(save_dir,['AllConditions']),'-painters','-r400','-append');
            elseif res_ix==2
                exportgraphics(fig(cond_ix),fullfile(save_dir,[[res(cond_ix).name] '.pdf']),'Resolution',300);
                print('-dpsc',fullfile(save_dir,['AllTtests']),'-painters','-r400','-append');
            end
        end
    end
end




