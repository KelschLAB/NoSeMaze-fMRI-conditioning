%% master_NBS_LME_reappraisal_jr.m

%% Clearing
clear all
close all

%% Predefinitions
% cormat
suffix = 'v11';
cormat_selection = ['cormat_' suffix ];
atlasHemisphere_selection = 'separated'; %'combined'; % 'separated'

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));

%% Load filelist
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')
end

%% Define directories
% Working Directory
inputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_selection '/beta4D/' atlasHemisphere_selection '_hemisphere'];
% Output directory
outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/02-NBS/' cormat_selection '/' atlasHemisphere_selection '_hemisphere'];
if ~exist(outputdir)
    mkdir(outputdir);
end

%% threshold definition
input_type={'Extent'};
thres=.95;

%% trial_selection
trial_selection{1}='Odor11to40'; trial_selection{2}='Odor81to120';
trial_selection{3}='TPnoPuff11to40'; trial_selection{4}='TPnoPuff81to120';

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

%% Load cormat-files
% files
load(fullfile(inputdir,[cormat_selection '_' trial_selection{1} '.mat']));
% Mat_OdorBl1=cat(3,cormat{:});
myData{1}.cormat=cormat;

load(fullfile(inputdir,[cormat_selection '_' trial_selection{2} '.mat']));
% Mat_OdorBl3=cat(3,cormat{:});
myData{2}.cormat=cormat;

load(fullfile(inputdir,[cormat_selection '_' trial_selection{3} '.mat']));
% Mat_TPBl1=cat(3,cormat{:});
myData{3}.cormat=cormat;

load(fullfile(inputdir,[cormat_selection '_' trial_selection{4} '.mat']));
% Mat_TPBl3=cat(3,cormat{:});
myData{4}.cormat=cormat;

% Think of adding fisher-z-transformation (does not change much...)
% z=atanh(r);

%% statistics: LME
if 1==1
    % loops over ROIs
    for r1=1:size(myData{1}.cormat{1},1)
        for r2=1:size(myData{1}.cormat{1},2)
            % data preparation
            % set counter
            counter=1;
            
            % loop over animals
            for animal_ID=1:length(myData{1}.cormat)
                
                % loop over the four time point
                for time_idx = 1:length(myData)
                    
                    % animal
                    animal(counter)=animal_ID;
                    
                    % metrics
                    FC(counter)=myData{time_idx}.cormat{animal_ID}(r1,r2);
                    selection_name_tbl{counter}=trial_selection{time_idx};
                    
                    % intra-trial timepoint
                    if contains(trial_selection{time_idx},'Odor')
                        IT_timepoint{counter}='odor';
                    elseif contains(trial_selection{time_idx},'TPnoPuff')
                        IT_timepoint{counter}='TPnopuff';
                    end
                    % block
                    if contains(trial_selection{time_idx},'11to40')
                        block(counter)=1;
                    elseif contains(trial_selection{time_idx},'81to120')
                        block(counter)=3;
                    end
                    % counter update
                    counter=counter+1;
                end
            end
            
            % create the input table
            myTable(r1,r2).input = table(block',IT_timepoint',animal',FC',selection_name_tbl','VariableNames',{'block','IT_timepoint','animal','FC','selection_name'});
            myTable(r1,r2).input.animal = categorical(myTable(r1,r2).input.animal);
            myTable(r1,r2).input.block = categorical(myTable(r1,r2).input.block);
            
            % fit linear mixed effects model (% choosing between individual
            % slopes for all animals (block|animal) or on slope (1|animal),
            % see also:
            % https://journals.sagepub.com/doi/epub/10.1177/09567976211046884
            % ( The Importance of Random Slopes in Mixed Models for Bayesian
            % Hypothesis Testing, Klaus Oberauer)
            lme = fitlme(myTable(r1,r2).input,'FC ~ 1 + block*IT_timepoint + (1|animal)');
            %         lme_new = fitlme(myTable(r1,r2).input,'FC ~ 1 + block*IT_timepoint + (block*IT_timepoint|animal)');
            % CAVE: robust linear models are implemented in R and might
            % ameliorate some results (robustlmm)
            % p values
            p_intercept(r1,r2)=double(lme.Coefficients(1,6));
            p_block(r1,r2)=double(lme.Coefficients(2,6));
            p_IT_timepoint(r1,r2)=double(lme.Coefficients(3,6));
            p_interaction(r1,r2)=double(lme.Coefficients(4,6));
            % betas
            beta_intercept(r1,r2)=double(lme.Coefficients(1,2));
            beta_block(r1,r2)=double(lme.Coefficients(2,2));
            beta_IT_timepoint(r1,r2)=double(lme.Coefficients(3,2));
            beta_interaction(r1,r2)=double(lme.Coefficients(4,2));
            % tstat
            tstat_intercept(r1,r2)=double(lme.Coefficients(1,4));
            tstat_block(r1,r2)=double(lme.Coefficients(2,4));
            tstat_IT_timepoint(r1,r2)=double(lme.Coefficients(3,4));
            tstat_interaction(r1,r2)=double(lme.Coefficients(4,4));
        end
    end
end

%% NBS on difference-cormat (~ equivalent to interaction effect)
% trial_selection{1}='Odor11to40'; trial_selection{2}='Odor81to120';
% trial_selection{3}='TPnoPuff11to40'; trial_selection{4}='TPnoPuff81to120';

% create cormat diff
for ix=1:24
    cormat_diff3{ix}=myData{4}.cormat{ix}-myData{2}.cormat{ix};
end
for ix=1:24
    cormat_diff1{ix}=myData{3}.cormat{ix}-myData{1}.cormat{ix};
end

% lei-ttest
[T p p2 fdrmat meanval stdab] = lei_pairedtt( cormat_diff3, cormat_diff1, 0.05)

% creation of matrices
Mat_sel=cat(3,cormat_diff3{:});
cormat_sel=cormat;
Mat_comp=cat(3,cormat_diff1{:});
cormat_comp=cormat;

% combined matrix for the input
Mat=cat(3,Mat_sel,Mat_comp);
save(fullfile(outputdir,strcat('Mat_cormat_diff_bl3_cormat_diff_bl1.mat')),'Mat')

% Cog
csvwrite(fullfile(outputdir,'COG.txt'),Cmm(1:size(Mat,1),:));

% GLM (design matrix)
GLM=zeros(size(Mat,3),2);
GLM(:,1)=1;
GLM([1:length(cormat_sel)],2)=1;
GLM([(length(cormat_sel)+1):(length(cormat_sel)+length(cormat_comp))],2)=-1;
csvwrite(fullfile(outputdir,strcat('GLM_cormat_diff_bl3_cormat_diff_bl1.txt')),GLM)

% Threshold definition
pT=thres
pF=thres
thr_F = finv(pF,2-1,size(GLM,1)/2-1);%thr_size-2);%
thr_t = tinv(pT,size(GLM,1)/2-1);%thr_size-2);%

% subjects for exchange block
exchange_vector=[[1:length(cormat_sel)]';[1:length(cormat_comp)]'];
csvwrite(fullfile(outputdir,strcat('ExchangeBlock_cormat_diff_bl3_cormat_diff_bl1.txt')),exchange_vector)

% load UI.mat
load /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/03-FC/02-NBS/input_files/UI.mat

UI.matrices.ui=fullfile(outputdir,strcat('Mat_cormat_diff_bl3_cormat_diff_bl1.mat'));
UI.design.ui=fullfile(outputdir,strcat('GLM_cormat_diff_bl3_cormat_diff_bl1.txt'));
UI.node_coor.ui=fullfile(outputdir,'COG.txt');
UI.exchange.ui=fullfile(outputdir,strcat('ExchangeBlock_cormat_diff_bl3_cormat_diff_bl1.txt'));

% tstat
if exist('tstat_interaction')
    tstat=tstat_interaction;
else
    tstat=T;
end

% contrast
contrast={'[0 1]' '[0 -1]' '[0 1]'};

% NBS
resNBS=acl_NBS_intercept(UI,tstat,thr_t,thr_F,input_type);

% Plot Matrix
fig(1)=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
imagesc(tstat);
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
tt = title(['Interaction Effect (LME)']);
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
exportgraphics(fig(1),fullfile(outputdir,['NBSresults_InteractionEffect_LME_' input_type{1} '_thresh' num2str(1-thres) '.pdf']),'Resolution',300);
% print('-dpsc',fullfile(outputdir,['NBSresults_InteractionEffect_LME_' input_type{1} '_thresh' num2str(1-thres)]),'-painters','-r400','-bestfit');

close all

% acl_NBS_intercept(UI,tstat,thr_t,thr_F,type);