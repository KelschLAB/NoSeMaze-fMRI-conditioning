%% plot_matrixDifferences_taskVScontrol_thresholdPlot_jr.m
% also: zero val estimation (aka at which threshold is the network not changing
% anymore)

% pre-clearing
close all
clear all
clc

% load colormap
load('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers/myColormapICON.mat');
           
%% Selection of input
% block
block_selection{1}='TPnoPuff11to40';
block_selection{2}='TPnoPuff81to120';
% cormat version
cormat_version_task = 'cormat_v11';
cormat_version_control = 'cormat_v6';
% bi-/unihemispheric atlas
separated_hemisphere = 0;
% binarized/non-binarized network
binarization_method = 'max';
connectedness = 'connected';
% input directories
if separated_hemisphere==1
    inputDir_GA_task = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
    inputDir_GA_control = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'separated_hemisphere' filesep binarization_method '_' connectedness];
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/',cormat_version_task,'separated_hemisphere','threshold_FCmatrix_plots')
elseif separated_hemisphere==0
    inputDir_GA_task = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    inputDir_GA_control = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    outputDir = fullfile('/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/',cormat_version_task,'combined_hemisphere','threshold_FCmatrix_plots')
end
if ~exist(outputDir)
    mkdir(outputDir);
end

% sorting
sorting= [4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11,32:33,29:31,34:35,38:41,45:52,22:23,36,37,44];

% Load roidata.mat to make ROI-names
roidata_file = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/',cormat_version_task,'/beta4D/combined_hemisphere',['roidata_' cormat_version_task(8:end) '_Lavender.mat']);
load(roidata_file);
names = {subj(1).roi.name};
names = names(sorting);


%% Load data task
load(fullfile(inputDir_GA_task,['gstruc_' block_selection{1} '_p.mat']));
for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myMat_1{ix}{jx}(:,:)=gstruc(ix,jx).o_CIJ_thresh(sorting,sorting); end; end
load(fullfile(inputDir_GA_task,['gstruc_' block_selection{2} '_p.mat']));
for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myMat_2{ix}{jx}(:,:)=gstruc(ix,jx).o_CIJ_thresh(sorting,sorting); if ix<42; myMat_diff_TASK{ix}{jx}(:,:)=myMat_2{ix}{jx}(:,:)-myMat_1{ix}{jx}(:,:); end; end; end

% set counter
counter=1; 

% figure
fig(1)=figure('visible', 'on');     
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.8,0.8]);
% subplots first row
clear myMatrices
for ix=1:10:41 
    [T p p2 fdrmat meanval stdab]=lei_pairedtt(myMat_2{ix},myMat_1{ix},0.05)
    subplot(3,5,counter); imagesc(T.*(p2<0.05)); ax=gca; ax.Colormap=[1 1 1; myColormap]; ax.CLim=[-5,5]; colorbar;
    myMatrices{counter}=T;%.*(p2<0.05);
    myMatrices{counter}(myMatrices{counter}==0)=nan;
    counter=counter+1;
    title(['thresh: ' num2str(ix+9) '%']);
    % save source data
    clear SourceData toSave
    toSave = T.*(p2<0.05);
    toSave(isnan(toSave))=0;
    SourceData = array2table(toSave,'VariableNames',names,'RowNames',names);
    writetable(SourceData,fullfile(outputDir,['SourceData_task_thresh' num2str(ix+9) '.csv']),'WriteVariableNames',true,'WriteRowNames',true);
end 

%% Load data control
load(fullfile(inputDir_GA_control,['gstruc_' block_selection{1} '_p.mat']));
for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myMat_3{ix}{jx}(:,:)=gstruc(ix,jx).o_CIJ_thresh(sorting,sorting); end; end
load(fullfile(inputDir_GA_control,['gstruc_' block_selection{2} '_p.mat']));
for ix=1:size(gstruc,1); for jx=1:size(gstruc,2); myMat_4{ix}{jx}(:,:)=gstruc(ix,jx).o_CIJ_thresh(sorting,sorting); if ix<42; myMat_diff_CON{ix}{jx}(:,:)=myMat_4{ix}{jx}(:,:)-myMat_3{ix}{jx}(:,:); end; end; end

% subplots second row
counter=6; 
for ix=1:10:41 
    [T p p2 fdrmat meanval stdab]=lei_pairedtt(myMat_4{ix},myMat_3{ix},0.05)
    subplot(3,5,counter); imagesc(T.*(p2<0.05)); ax=gca; ax.Colormap=[1 1 1; myColormap]; ax.CLim=[-5,5]; colorbar;
    myMatrices{counter}=T;%.*(p2<0.05);
    myMatrices{counter}(myMatrices{counter}==0)=nan;
    counter=counter+1;
    % save source data
    clear SourceData toSave
    toSave = T.*(p2<0.05);
    toSave(isnan(toSave))=0;
    SourceData = array2table(toSave,'VariableNames',names,'RowNames',names);
    writetable(SourceData,fullfile(outputDir,['SourceData_control_thresh' num2str(ix+9) '.csv']),'WriteVariableNames',true,'WriteRowNames',true);
end 

% load new colormap
load('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers/myColormap_graygreen.mat');

%% Task vs control
% subplots third row
counter=11; 
for ix=1:10:41 
    [T p p2 fdrmat meanval stdab]=lei_pairedtt(myMat_diff_TASK{ix},myMat_diff_CON{ix},0.05)
    subplot(3,5,counter); imagesc(T.*(p2<0.05)); ax=gca; ax.Colormap=[1 1 1; myColormap]; ax.CLim=[-5,5]; colorbar;
    myMatrices{counter}=T;%.*(p2<0.05);
    myMatrices{counter}(myMatrices{counter}==0)=nan;
    counter=counter+1;
    % save source data
    clear SourceData toSave
    toSave = T.*(p2<0.05);
    toSave(isnan(toSave))=0;
    SourceData = array2table(toSave,'VariableNames',names,'RowNames',names);
    writetable(SourceData,fullfile(outputDir,['SourceData_taskVScontrol_thresh' num2str(ix+9) '.csv']),'WriteVariableNames',true,'WriteRowNames',true);
end 

% print
[annot, srcInfo] = docDataSrc(fig(1),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(1),fullfile(outputDir,['matrixComparison_taskVScontrol_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['matrixComparison_taskVScontrol_thresholds']),'-painters','-r400','-bestfit','-append');

%% ZERO VALS ESTIMATION
for ix=1:61; for jx=1:24; zeroVals{1}(ix,jx)=sum(sum(myMat_1{1,ix}{1,jx}(:,:)==0)); end; end;
for ix=1:61; for jx=1:24; zeroVals{2}(ix,jx)=sum(sum(myMat_2{1,ix}{1,jx}(:,:)==0)); end; end;
for ix=1:41; for jx=1:24; zeroVals{3}(ix,jx)=sum(sum(myMat_3{1,ix}{1,jx}(:,:)==0)); end; end;
for ix=1:41; for jx=1:24; zeroVals{4}(ix,jx)=sum(sum(myMat_4{1,ix}{1,jx}(:,:)==0)); end; end;

figure; for ix=1:4; subplot(2,2,ix); imagesc(zeroVals{ix}); ax=gca; ax.Colormap=jet; end