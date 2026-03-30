%% master_calculate_DVARS_reappraisal_control_2023_jr.m
% Calculate DVARS on different preprocessing steps (to get information on
% the motion correction achieved by the preprocessing)

% clearing
clear all
close all
clc

% add pathes
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
% addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
% addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat','P3d','Pdmap_1','Pdmap_2','Pfunc_reappraisal')

% EPI selection
EPI_prefix = {'med1000new_msk_s6_wrst_a1_u_del5_',...
    'med1000new_msk_s6_wrst_a1_u_despiked_del5_',...
    'wave_10cons_med1000new_msk_s6_wrst_a1_u_del5_',...
    'wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_',...
     }
%     'DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_',...
%     'DVARSscrub_0_1_lin_wave_10cons_med1000_msk_s6_wrst_a1_u_del5_',...

% EPI names
EPI_name = {'noMotionCorrection','AFNI','WD10','WD10_AFNI'}

% define output directory
outputdir='/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/01-preprocessing/01-motion/DVARS'
mkdir(outputdir);

        
        
if exist(fullfile(outputdir,'DVARS_info.mat'))
    load(fullfile(outputdir,'DVARS_info.mat'),'DVARS_info');
end

if 1==0
    %% loop over EPI selection
    for EPI_idx = 1:length(EPI_prefix)
        if exist(fullfile(outputdir,['DVARS_' EPI_name{EPI_idx} '.ps']))==2
            delete(fullfile(outputdir,['DVARS_' EPI_name{EPI_idx} '.ps']))
        end
        
        %% loop over subjects
        for subj=1:size(Pfunc_reappraisal,2)
            
            % gray matter mask definition and loading
            [fpath, fname, ext]=fileparts(P3d{subj});
            Pmask_GM=spm_select('ExtFPList',fpath,['^wc1bc_st_' fname '_c2t.nii'],1);
            Vmsk=spm_vol(Pmask_GM);
            mask_mtx=spm_read_vols(Vmsk);
            mask_mtx=mask_mtx>0.4;
            mask_mtx_size=size(mask_mtx);
            mask_mtx=reshape(mask_mtx,prod(mask_mtx_size(1:3)),1);
            
            % EPI: definition and loading
            [fpath, fname, ext]=fileparts(Pfunc_reappraisal{subj});
            if contains(EPI_prefix{EPI_idx},'wave')
                EPI=spm_select('ExtFPlist',[fpath filesep 'wavelet'],['^' EPI_prefix{EPI_idx} fname '_c2t_wds.nii'],[1:2000]);
            else
                EPI=spm_select('ExtFPlist',fpath,['^' EPI_prefix{EPI_idx} fname '_c2t.nii'],[1:2000]);
            end
            V_EPI=spm_vol(EPI);
            mtx=spm_read_vols(V_EPI);
            mtxsz=size(mtx);
            
            % FD: definition and loading (either despiked or not)
            if contains(EPI_prefix{EPI_idx},'despiked')
                MovPar=[spm_load(spm_select('FPList',fpath,'^rp_despiked_del5_.*.txt'))];
            else
                MovPar=[spm_load(spm_select('FPList',fpath,'^rp_del5_.*.txt'))];
            end
            MovPar=MovPar(:,1:6);
            FD_SNiP = SNiP_framewise_displacement(MovPar);
            MovPar(:,[1:3])=MovPar(:,[1:3])./10;
            
            % shape img and mask it
            mtx=reshape(mtx,prod(mtxsz(1:3)),prod(mtxsz(4)));
            mtxfunc=mtx(find(mask_mtx),:);
            
            %% DVARS
            % calculation
            [V,Stat]=DSEvars(mtxfunc,'scale',1/100,'verbose',1);
            [DVARS,DVARS_Stat]=DVARSCalc(mtxfunc,'scale',1/100,'VarType','hIQR','TestMethod','X2','TransPower',1/3,'RDVARS','verbose',1); %[DVARS{ix},DVARS_Stat{ix}]=DVARSCalc(mtxfunc,'scale',1/100,'tail','both','VarType','hIQR','TestMethod','Z','TransPower',1/3,'RDVARS','verbose',1);
            
            % structure for saving
            DVARS_info.(EPI_name{EPI_idx}).DVARS(subj,:) = DVARS;
            DVARS_info.(EPI_name{EPI_idx}).DVARS_stat{subj} = DVARS_Stat;
            DVARS_info.(EPI_name{EPI_idx}).DVARS_pvals(subj,:) = DVARS_Stat.pvals;
            DVARS_info.(EPI_name{EPI_idx}).DVARS_pvals_fraction(subj) = sum((DVARS_Stat.pvals)<0.05)./(mtxsz(4)-1);
            DVARS_info.(EPI_name{EPI_idx}).DVARS_pvals_idx(subj,:) = DVARS_Stat.pvals<0.05;
            % FD
            DVARS_info.(EPI_name{EPI_idx}).FD_SNiP(subj,:) = FD_SNiP;
            [FDts,FD_Stat]=FDCalc(MovPar);
            DVARS_info.(EPI_name{EPI_idx}).FD_DVARS(subj,:) = FDts;
            
            % plot
            f_hdl=figure('visible', 'off');
            set(gcf,'position',[50,50,800,800]);
            idx = find(DVARS_Stat.pvals<0.05./(mtxsz(4)-1));
            fMRIDiag_plot_JR(V,DVARS_Stat,'Idx',idx,'BOLD',mtxfunc,'FD',FDts.*10,'AbsMov',[FD_Stat.AbsRot FD_Stat.AbsTrans],'figure',f_hdl);
            title(fname,'Interpreter','none')
            print('-dpsc',fullfile(outputdir,['DVARS_' EPI_name{EPI_idx} '.ps']) ,'-r400','-append');
        end
        % save
        save(fullfile(outputdir,'DVARS_info.mat'),'DVARS_info');
    end
end

%% Plots
if 1==1
    % define output directory
    outputdir='/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/01-preprocessing/01-motion/DVARS'
    load(fullfile(outputdir,'DVARS_info.mat'),'DVARS_info');
    
    % predefine matrices for plots
    toPlot_corrcoeff=[];
    toPlot_framefraction=[];
    toPlot_partialcorrcoeff=[];
    
    %% loop over EPI selection
    for EPI_idx = 1:length(EPI_prefix)
        %% loop over subjects
        for subj=1:size(Pfunc_reappraisal,2)
            DVARS_info.(EPI_name{EPI_idx}).corrcoeffFDtoDVARS(subj,1) = corr(DVARS_info.(EPI_name{EPI_idx}).DVARS(subj,:)',DVARS_info.(EPI_name{EPI_idx}).FD_SNiP(subj,[2:end])');
            
            % FD: definition and loading (either despiked or not)
            [fpath, fname, ext]=fileparts(Pfunc_reappraisal{subj});
            if contains(EPI_prefix{EPI_idx},'despiked')
                MovPar=[spm_load(spm_select('FPList',fpath,'^rp_despiked_del5_.*.txt'))];
            else
                MovPar=[spm_load(spm_select('FPList',fpath,'^rp_del5_.*.txt'))];
            end
            MovPar(:,[1:3])=MovPar(:,[1:3])./10;
            
            DVARS_info.(EPI_name{EPI_idx}).partialcorrcoeffFDtoDVARS(subj,1) = partialcorr(DVARS_info.(EPI_name{EPI_idx}).DVARS(subj,:)',DVARS_info.(EPI_name{EPI_idx}).FD_SNiP(subj,[2:end])',MovPar(2:end,:));
        end
        % fill matrices
        toPlot_corrcoeff = [toPlot_corrcoeff,DVARS_info.(EPI_name{EPI_idx}).corrcoeffFDtoDVARS];
        toPlot_partialcorrcoeff = [toPlot_partialcorrcoeff,DVARS_info.(EPI_name{EPI_idx}).partialcorrcoeffFDtoDVARS];
        toPlot_framefraction = [toPlot_framefraction,DVARS_info.(EPI_name{EPI_idx}).DVARS_pvals_fraction'];
    end
    
    % plot: correlation DVARS to FD
    % figure
    fig1=figure('visible', 'off');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    % plot
    nb=notBoxPlot(toPlot_corrcoeff);
    % axes
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    
    ax.YLim=[-1,1];
    ax.XTick=[1:length(EPI_name)];
    ax.XTickLabel=EPI_name;
    ax.FontSize=10;
    rotateXLabels(ax,45);
    
    % Title
    tt = title(['CorrCoeff: FD to DVARS']);
    tt.Interpreter='none';
    
    % print
    [annot, srcInfo] = docDataSrc(fig1,outputdir,mfilename('fullpath'),logical(1))
    exportgraphics(fig1,fullfile(outputdir,['CorrCoeff_FDtoDVARS_by_DifferentPreprocessingSteps.pdf']),'Resolution',300);
    % print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
    
       
    % plot: correlation DVARS to FD
    % figure
    fig2=figure('visible', 'off');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    % plot
    nb=notBoxPlot(toPlot_partialcorrcoeff);
    % axes
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    
    ax.YLim=[-1,1];
    ax.XTick=[1:length(EPI_name)];
    ax.XTickLabel=EPI_name;
    ax.FontSize=10;
    rotateXLabels(ax,45);
    
    % Title
    tt = title(['Partial CorrCoeff: FD to DVARS']);
    tt.Interpreter='none';
    
    % print
    [annot, srcInfo] = docDataSrc(fig2,outputdir,mfilename('fullpath'),logical(1))
    exportgraphics(fig2,fullfile(outputdir,['PartialCorrCoeff_FDtoDVARS_by_DifferentPreprocessingSteps.pdf']),'Resolution',300);
    % print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
    
    % plot: correlation DVARS to FD
    % figure
    fig3=figure('visible', 'off');
    set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
    % plot
    nb=notBoxPlot(toPlot_framefraction);
    % axes
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    
    ax.YLim=[0,0.5];
    ax.XTick=[1:length(EPI_name)];
    ax.XTickLabel=EPI_name;
    ax.FontSize=10;
    rotateXLabels(ax,45);
    
    % Title
    tt = title(['Frame Fraction (p<0.05)']);
    tt.Interpreter='none';
    
    % print
    [annot, srcInfo] = docDataSrc(fig3,outputdir,mfilename('fullpath'),logical(1))
    exportgraphics(fig3,fullfile(outputdir,['FrameFractionDVARS_by_DifferentPreprocessingSteps.pdf']),'Resolution',300);
    % print('-dpsc',fullfile(outputdir,['PFC_S1__scatterBOLDtoBOLD_T' tthresh{tthresh_idx} '_' corr_type{corr_idx}]),'-painters','-r400');
end












