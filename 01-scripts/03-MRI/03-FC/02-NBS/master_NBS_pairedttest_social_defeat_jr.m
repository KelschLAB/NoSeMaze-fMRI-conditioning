%% master_NBS_pairedttest_social_defeat_jr.m

%% Clearing
clear all
close all

%% Predefinitions
% cormat
suffix = 'v4';
cormat_selection = ['cormat_' suffix ];
atlasHemisphere_selection = 'combined'; %'combined'; % 'separated'

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));

%% Define directories
% Working Directory
inputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/' cormat_selection '/beta4D/' atlasHemisphere_selection '_hemisphere'];
% Output directory
outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/02-social_defeat/04-FC/02-NBS/' cormat_selection '/' atlasHemisphere_selection '_hemisphere'];
if ~exist(outputdir)
    mkdir(outputdir);
end

%% threshold definition
input_type={'Extent'};
thres=.95;

%% trial_selection
trial_selection{1}='CD1-familiar'; trial_selection{2}='CD1-unknown';trial_selection{3}='129-sv-female';

%% Predefine atlas
if strcmp(atlasHemisphere_selection,'combined')
    % combinded hemispheres
    Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged_jr.txt';
    Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged.nii';
elseif strcmp(atlasHemisphere_selection,'separated')
    % separated hemispheres
    Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.txt';
    Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.nii';
end

[~,atlas_name,~]=fileparts(Patlas);
atlas_parameter_dir=fullfile('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/03-FC/02-NBS/atlas_parameters',atlas_name);
if ~isdir(atlas_parameter_dir)
    mkdir(atlas_parameter_dir)
    [C, Cmm,  D] = acl_calculate_center(Patlas)
    save(fullfile(atlas_parameter_dir,'atlas_parameters.mat'),'C','Cmm','D')
else
    load(fullfile(atlas_parameter_dir,'atlas_parameters.mat'),'C','Cmm','D')
end

%% ROI names
load(fullfile(inputdir,['roidata_' suffix '_' trial_selection{1} '.mat']));
names={subj(1).roi.name};

%% Loop over trial selection
for sel_idx = 1:length(trial_selection)
        
    %% Loop for comparison
    for comp_idx = (sel_idx+1):length(trial_selection)
    
        %% Load cormat-files
        % main file
        load(fullfile(inputdir,[cormat_selection '_' trial_selection{sel_idx} '.mat']));       
        Mat_sel=cat(3,cormat{:});
        cormat_sel=cormat;

        % comparison file
        load(fullfile(inputdir,[cormat_selection '_' trial_selection{comp_idx} '.mat']));
        Mat_comp=cat(3,cormat{:});
        cormat_comp=cormat;
          
        % Think of adding fisher-z-transformation (does not change much...)
        % z=atanh(r);
        
        % paired ttest
        [T p p2 fdrmat meanval stdab] = lei_pairedtt( cormat_sel, cormat_comp, 0.05)
   
        % combined matrix for the input
        Mat=cat(3,Mat_sel,Mat_comp);
        save(fullfile(outputdir,strcat('Mat_',trial_selection{sel_idx},'_',trial_selection{comp_idx},'.mat')),'Mat')
                
        % Cog
        csvwrite(fullfile(outputdir,'COG.txt'),Cmm(1:size(Mat,1),:));

        % GLM (design matrix)
        GLM=zeros(size(Mat,3),2);
        GLM(:,1)=1;
        GLM([1:length(cormat_sel)],2)=1;
        GLM([(length(cormat_sel)+1):(length(cormat_sel)+length(cormat_comp))],2)=-1;
        csvwrite(fullfile(outputdir,strcat('GLM_',trial_selection{sel_idx},'_',trial_selection{comp_idx},'.txt')),GLM)
        
        % Threshold definition
        pT=thres
        pF=thres
        thr_F = finv(pF,2-1,size(GLM,1)/2-1);%thr_size-2);%
        thr_t = tinv(pT,size(GLM,1)/2-1);%thr_size-2);%
        
        % subjects for exchange block
        exchange_vector=[[1:length(cormat_sel)]';[1:length(cormat_comp)]'];
        csvwrite(fullfile(outputdir,strcat('ExchangeBlock_',trial_selection{sel_idx},'_',trial_selection{comp_idx},'.txt')),exchange_vector)
        
        % load UI.mat
        load /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/03-FC/02-NBS/input_files/UI.mat
        
        UI.matrices.ui=fullfile(outputdir,strcat('Mat_',trial_selection{sel_idx},'_',trial_selection{comp_idx},'.mat'));
        UI.design.ui=fullfile(outputdir,strcat('GLM_',trial_selection{sel_idx},'_',trial_selection{comp_idx},'.txt'));
        UI.node_coor.ui=fullfile(outputdir,'COG.txt');
        UI.exchange.ui=fullfile(outputdir,strcat('ExchangeBlock_',trial_selection{sel_idx},'_',trial_selection{comp_idx},'.txt'));
        
        % tstat
        tstat=T;
        
        % contrast
        contrast={'[0 1]' '[0 -1]' '[0 1]'};
        
        % NBS
        resNBS=acl_NBS_intercept(UI,tstat,thr_t,thr_F,input_type);
        
        % Plot Matrix
        fig(1)=figure('visible', 'off');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
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
        ax.FontSize=4;
        rotateXLabels(ax,90);

        % Title
        tt = title([trial_selection{sel_idx},'_',trial_selection{comp_idx}]);
        tt.Interpreter='none';
        colorbar;
        grid on
                
        % Mark NBS corrected values
        NBSmat=(resNBS.T_R1+resNBS.T_R2)';
        for x=1:size(T,1)
            for y=x:size(T,2) %size(T,2);
                if (x == y)
                    xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
                    patch(xv,yv,[1 1 1])
                end
                %                     if (p2(y,x)<0.05)
                %                         text((x-1)+.6,y+.1,sprintf('%2.1f',T(y,x)),'color',[1 1 1], ...
                %                             'fontsize',7) ;
                %                     end
                if NBSmat(y,x)
                    xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                    line(xv,yv,'linewidth',2,'color',[0 0 0]);
                end
            end
        end
        
        % print
        [annot, srcInfo] = docDataSrc(fig(1),fullfile(outputdir),mfilename('fullpath'),logical(1))
        exportgraphics(fig(1),fullfile(outputdir,['NBSresults_' trial_selection{sel_idx} '_' trial_selection{comp_idx} '_' input_type{1} '_thresh' num2str(1-thres) '.pdf']),'Resolution',300);
        print('-dpsc',fullfile(outputdir,['NBSresults_' trial_selection{sel_idx} '_' trial_selection{comp_idx}  '_' input_type{1} '_thresh' num2str(1-thres)]),'-painters','-r400','-bestfit');
        
        close all
    end
    
end

% acl_NBS_intercept(UI,tstat,thr_t,thr_F,type);