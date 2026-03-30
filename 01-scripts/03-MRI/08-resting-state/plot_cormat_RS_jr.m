%% plot_cormat_RS_jr.m
% Jonathan Reinwald, 05/2021
% Script for plotting:
% -

%% Clearing
clear all
close all

%% Load filelist
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')
end

%% Define directories
% selection of EPI
% epiPrefix = 'bpm_0.01_0.1_wave_10cons_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
% epiPrefix = 'bpm_0.01_0.1_wave_10cons_med1000_msk_regfilt_motcsfgsder_wrst_a1_u_despiked_del5_';
epiPrefix = 'bpm_0.01_0.1_med1000_msk_s6_regfilt_motcsfgsder_wrst_a1_u_despiked_del5_';
epiSuffix = '_c1_c2t';

% epiPrefix = 'bpm_0.01_0.1_scrub_0_1_lin_wave_10cons_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
% epiPrefix = 'bpm_0.01_0.1_med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_despiked_del5_';
% epiSuffix = '_c1_c2t_wds';

% input and output directory
inputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/10-resting_state/01-cormat/',epiPrefix,'separated_hemisphere');
outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/05-resting-state/01-cormat/',epiPrefix,'separated_hemisphere');
mkdir(outputDir);
pDataDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing';

% Load roidata.mat to make ROI-names
load([inputDir filesep 'roidata.mat']);
names = {subj(1).roi.name};

% Load cormat.mat to make ROI-names
load([inputDir filesep 'cormat.mat']);

% Load Pcur (for names later)
Pcur = spm_select('ExtFPlistrec',pDataDir,['^' epiPrefix '.*.' epiSuffix '.nii'],1);

%% Mean connectivity matrix plot
if 1==1
    load([inputDir filesep 'cormat.mat']);
    
    % Make mean connectivity matrix
    clear cormat_3D
    cormat_3D = cat(3,cormat{:});
    % Plot
    fig=figure('visible', 'off');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    imagesc(mean(cormat_3D,3));
    set(gca,'dataAspectRatio',[1 1 1])
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    ax.CLim=[-1,1];
    ax.Colormap=jet;
    ax.XTick=[1:length(names)];
    ax.XTickLabel=names;
    ax.YTick=[1:length(names)];
    ax.YTickLabel=names;
    %         axis square;
    rotateXLabels(ax,90);
    % Title
    tt = title('Mean Resting-State Matrix');
    tt.Interpreter='none';
    colorbar;
    
    % Save
    if 1==1
        print('-dpsc',fullfile([outputDir filesep],['Mean_RS_Cormat.ps']) ,'-r400')
    end
    close(fig);
end


%% Loop over Animals
if 1==1
    for ix = 1:length(cormat)
        % Make title-name
        clear curr_name find_
        fname=Pcur(ix,:);
        find_ = strfind(fname,'ZI_M')
        curr_name = fname(find_(1):find_(1)+5);
        
        % Plot Matrix
        fig1=figure('visible', 'off');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
        imagesc(cormat{ix});
        set(gca,'dataAspectRatio',[1 1 1])
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        ax.XTick=[1:length(names)];
        ax.XTickLabel=names;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=names;
        rotateXLabels(ax,90);
        
        % Title
        tt = title(curr_name);
        tt.Interpreter='none';
        colorbar;
        
        % Save
        if 1==1
            print('-dpsc',fullfile([outputDir filesep],['Individual_RS_Cormat.ps']) ,'-r400','-append')
        end
    end
end








