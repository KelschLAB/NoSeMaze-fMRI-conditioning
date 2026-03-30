%% master_NBS_cormat_reappraisalVScontrol_Odor11to40_jr.m

%% Clearing
% clear all
% close all

%% Predefinitions
% predefine cormat selection
cormat_control = 'cormat_v6'; %v4: DVARS,WD,AFNI and no smoothing; v7: later (0.4+0.9)
cormat_task = 'cormat_v11'; %v14: DVARS,WD,AFNI and no smoothing
atlasHemisphere_selection = 'combined';%'separated_v2_2023'; %'combined'; % 'separated'

trial_selection{1}='Odor81to120'; %trial_selection{2}='Odor11to40';

%% Load filelist
if 1==1
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat','P3d','Pdmap_1','Pdmap_2','Pfunc_reappraisal')
end

%% Define directories
% Working Directory
inputDir_control = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_control '/beta4D/' atlasHemisphere_selection '_hemisphere'];
inputDir_task = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_task '/beta4D/' atlasHemisphere_selection '_hemisphere'];

% Output directory
outputDir = ['/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/04-FC/02-NBS/' cormat_control 'VS' cormat_task '/' atlasHemisphere_selection '_hemisphere'];
if ~exist(outputDir)
    mkdir(outputDir);
end

%% threshold definition
input_type={'Extent'};
thres=.975;

% sorting
sorting= [4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11,32:33,29:31,34:35,38:41,45:52,22:23,36,37,44];

%% trial_selection

% load correlation matrices
load(fullfile(inputDir_control,[cormat_control '_' trial_selection{1} '.mat']))
cormat_bl1_con = cormat;

load(fullfile(inputDir_task,[cormat_task '_' trial_selection{1} '.mat']))
cormat_bl1_task = cormat;

% concatenation of diff matrices
cormat_all=[cormat_bl1_con,cormat_bl1_task];
% save diff matrices as 3D-vector
Mat=cat(3,cormat_all{:});
% sorting
for i = 1:size(Mat,3)
    Mat(:,:,i)=Mat(sorting,sorting,i);
end
save(fullfile(outputDir,['Mat_' cormat_task '_' trial_selection{1} '.mat']),'Mat');

%% preparation of NBS input
% NBS_input dir
NBS_generalDir = '/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/03-FC/02-NBS/input_files';
% create GLM design matrix
GLM_design=[[ones(24,1);zeros(24,1)],[zeros(24,1);ones(24,1)]];
csvwrite(fullfile(outputDir,['GLM_design_' cormat_task '_' trial_selection{1} '.txt']),GLM_design);

% primary t-/f-threshold
thr_t = tinv(thres,size(GLM_design,1)-2);
thr_F = finv(thres,2-1,size(GLM_design,1)-2);

% sorting
for i = 1:length(cormat_bl1_con)
    cormat_bl1_con{i}=cormat_bl1_con{i}(sorting,sorting);
    cormat_bl1_task{i}=cormat_bl1_task{i}(sorting,sorting);
end

% t-statistic
[T p p2 fdrmat meanval stdab] = lei_ttest2(cormat_bl1_con,cormat_bl1_task, 0.05);

% contrast
contrasts={'[1 -1]' '[-1 1]' '[1 1]'};

% UI
load(fullfile(NBS_generalDir,'UI.mat'));
UI.matrices.ui=fullfile(outputDir,['Mat_' cormat_task '_' trial_selection{1} '.mat']);
UI.design.ui=fullfile(outputDir,['GLM_design_' cormat_task '_' trial_selection{1} '.txt']);
load(fullfile(NBS_generalDir,'COG.txt'));
UI.node_label.ui=fullfile(NBS_generalDir,'nodeLabels.txt');
UI.exchange.ui='';
        
% tstat
tstat=T;
  
% load names
load(fullfile(inputDir_control,['roidata_' cormat_control(end-1:end) '_Lavender.mat']))
names={subj(1).roi.name};

% sorting
names=names(sorting);

% NBS
resNBS=acl_NBS_intercept(UI,tstat,thr_t,thr_F,input_type,contrasts);

% Plot
fig1=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
data = tril(T,-1);
% data(data==0)=nan;
imagesc(data,'AlphaData',~isnan(data));
box off;
set(gca,'dataAspectRatio',[1 1 1])
ax=gca;
set(gca,'TickLabelInterpreter','none');
ax.CLim=[-5,5];
ax.Colormap=jet;
load('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers/myColormap_darkredgreen.mat');
ax.Colormap=myColormap;
%                 ax.Colormap = flipud(crameri('bam'));

ax.XTick=[1:length(names)];
ax.XTickLabel=names;
ax.YTick=[1:length(names)];
ax.YTickLabel=names;
ax.FontSize=6;
rotateXLabels(ax,90);

% Title
tt = title({'Comparison: CON vs TASK',['thresh: ' num2str(thres)]});
tt.Interpreter='none';
colorbar;
NBSmat = full(resNBS.CON_MAT2{1,1})+full(resNBS.CON_MAT2{1,1})';
% Mark NBS correction values
for x=1:size(T,1)
    for y=x+1:size(T,2) %size(T,2);
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
            line(xv,yv,'linewidth',1,'color',[0.1 0.1 0.1],'linestyle','-');
        end
    end
end      
cd(outputDir);

% print
[annot, srcInfo] = docDataSrc(fig1,fullfile(outputDir),mfilename('fullpath'),logical(1));exportgraphics(fig1,fullfile(outputDir,['NBS_reappraisalVScontrol_' cormat_control 'VS' cormat_task '_thresh' num2str(thres) '_' 'T_' num2str(thr_t) '.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['NBS_reappraisalVScontrol_' cormat_control 'VS' cormat_task '_thresh' num2str(thres) '_T_' num2str(thr_t)]),'-painters','-r400');

%% plot schemaball
fig2=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);

%
cmap=flipud(myColormap(100:end,:));
Cdata = (NBSmat+NBSmat').*T;
% make it into a index image.
cmin = min(Cdata(:));
cmax = max(Cdata(:));
m = length(cmap);
index = fix((Cdata-cmin)/(cmax-cmin)*m)+1;
RGB = ind2rgb(index,cmap);

%
schemaball(names, (NBSmat+NBSmat').*T, 10,[-5,5],ones(length(names),3).*0.5,RGB);

% Title
tt = title({'Schemaball - CON vs TASK',['thresh: ' num2str(thres)]});
tt.Interpreter='none';


% print
[annot, srcInfo] = docDataSrc(fig2,fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig2,fullfile(outputDir,['Schemaball_NBS_reappraisalVScontrol_' cormat_control 'VS' cormat_task '_thresh' num2str(thres) '_' 'T_' num2str(thr_t) '.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['Schemaball_NBS_reappraisalVScontrol_' cormat_control 'VS' cormat_task '_thresh' num2str(thres) '_T_' num2str(thr_t)]),'-painters','-r400');

  

