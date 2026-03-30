%% plot_FCaddedByThresholds_jr.m

clear all
close all

% define colors
colors={[1,0,0],[0,1,0],[1,0,1],[0,1,1],[0,0,1],[.5,0,0],[0,.5,0],[.5,0,.5],[0,.5,.5],[0,0,.5]};

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
    outputDir = fullfile('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/',cormat_version_task,'separated_hemisphere','histogram_FCadded')
elseif separated_hemisphere==0
    inputDir_GA_task = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/' cormat_version_task filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    inputDir_GA_control = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version_control filesep 'combined_hemisphere' filesep binarization_method '_' connectedness];
    outputDir = fullfile('/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/04-FC/01-BASCO/01-Cormat/',cormat_version_task,'combined_hemisphere','histogram_FCadded')
end
if ~exist(outputDir)
    mkdir(outputDir);
end

%% Load and plot data
% load data task
load(fullfile(inputDir_GA_task,['gstruc_' block_selection{2} '_p.mat']));
for ix=1:41; for jx=1:24; myMat1(ix,jx,:,:)=gstruc(ix,jx).o_CIJ_thresh; end; end

% set figure
fig(1)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0,2,1]);

% subplot
subplot(2,1,1); counter=1; 
for ix=1:5:41
    hold on; h1(counter)=histogram(myMat1(ix,:,:,:),'BinWidth',0.01,'EdgeColor',colors{counter},'LineStyle','-','LineWidth',1,'DisplayStyle','stairs');  counter=counter+1; ax=gca; ax.YLim=[0,counter*1200]; title(['TASK, thresh ' num2str(ix)]); 
end 

% load data task
load(fullfile(inputDir_GA_task,['gstruc_' block_selection{1} '_p.mat']));
for ix=1:41; for jx=1:24; myMat2(ix,jx,:,:)=gstruc(ix,jx).o_CIJ_thresh; end; end
counter=1; for ix=1:5:41; hold on; h2(counter)=histogram(myMat2(ix,:,:,:),'BinWidth',0.01,'EdgeColor',colors{counter},'LineStyle',':','LineWidth',1,'DisplayStyle','stairs'); counter=counter+1; ax=gca; ax.YLim=[0,counter*1200]; title(['TASK, thresh ' num2str(ix)]); end; 

% load data control
load(fullfile(inputDir_GA_control,['gstruc_' block_selection{2} '_p.mat']));
for ix=1:41; for jx=1:24; myMat3(ix,jx,:,:)=gstruc(ix,jx).o_CIJ_thresh; end; end
subplot(2,1,2);  counter=1; for ix=1:5:41; hold on; h3(counter)=histogram(myMat3(ix,:,:,:),'BinWidth',0.01,'EdgeColor',colors{counter},'LineStyle','-','LineWidth',1,'DisplayStyle','stairs');  counter=counter+1; ax=gca; ax.YLim=[0,(counter)*1200]; title(['CON, thresh ' num2str(ix)]); end; 

% load data control
load(fullfile(inputDir_GA_control,['gstruc_' block_selection{1} '_p.mat']));
for ix=1:41; for jx=1:24; myMat4(ix,jx,:,:)=gstruc(ix,jx).o_CIJ_thresh; end; end
counter=1; for ix=1:5:41; hold on; h4(counter)=histogram(myMat4(ix,:,:,:),'BinWidth',0.01,'EdgeColor',colors{counter},'LineStyle',':','LineWidth',1,'DisplayStyle','stairs'); counter=counter+1; ax=gca; ax.YLim=[0,(counter)*1200]; title(['CON, thresh ' num2str(ix)]); end; 

% set figure
fig(2)=figure('visible','on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.35,1]); 

for ix=1:8
    subplot(4,2,ix);
    hold on; count_temp1=h1(ix+1).BinCounts-h1(ix).BinCounts; count_temp1(count_temp1<0)=0; edges = h1(ix).BinEdges;
    sd{1}=histogram('BinCounts',count_temp1,'BinEdges',edges,'EdgeColor','none','FaceColor',[0 160/255 227/255],'FaceAlpha',0.1,'LineWidth',1.5);
    sd{1}=histogram('BinCounts',count_temp1,'BinEdges',edges,'EdgeColor',[0 160/255 227/255],'LineWidth',1.5,'DisplayStyle','stairs');
    hold on; count_temp2=h2(ix+1).BinCounts-h2(ix).BinCounts; count_temp2(count_temp2<0)=0; edges = h2(ix).BinEdges;
    sd{2}=histogram('BinCounts',count_temp2,'BinEdges',edges,'EdgeColor','none','FaceColor',[204/255 51/255 204/255],'FaceAlpha',0.1,'LineWidth',1.5);
    sd{2}=histogram('BinCounts',count_temp2,'BinEdges',edges,'EdgeColor',[204/255 51/255 204/255],'LineWidth',1.5,'DisplayStyle','stairs');    
    hold on; count_temp3=h3(ix+1).BinCounts-h3(ix).BinCounts; count_temp3(count_temp3<0)=0; edges = h3(ix).BinEdges;
    sd{3}=histogram('BinCounts',count_temp3,'BinEdges',edges,'EdgeColor','none','FaceColor',[0 160/255 227/255].*0.5,'FaceAlpha',0.1,'LineWidth',1.5,'LineStyle',':');
    sd{3}=histogram('BinCounts',count_temp3,'BinEdges',edges,'EdgeColor',[0 160/255 227/255].*0.5,'LineWidth',1.5,'LineStyle','-.','DisplayStyle','stairs');
    hold on; count_temp4=h4(ix+1).BinCounts-h4(ix).BinCounts; count_temp4(count_temp4<0)=0; edges = h4(ix).BinEdges;
    sd{4}=histogram('BinCounts',count_temp4,'BinEdges',edges,'EdgeColor','none','FaceColor',[204/255 51/255 204/255].*0.5,'FaceAlpha',0.1,'LineWidth',1.5,'LineStyle',':');
    sd{4}=histogram('BinCounts',count_temp4,'BinEdges',edges,'EdgeColor',[204/255 51/255 204/255].*0.5,'LineWidth',1.5,'LineStyle','-.','DisplayStyle','stairs');
    ax=gca; ax.YLim=[0,600]; ax.XLim=[0,.8];
    ax.XTick=[0:0.1:.8];ax.XTickLabel=[0:0.1:.8];
    ax.LineWidth=1.2;
    ax.FontSize=8;
    ax.YLabel.String={'count','(added connections)'};
    ax.XLabel.String={'FC','(added connections)'};
    tt=title(['Added connections: ' 'from ' num2str(5*ix+5) '% to ' num2str(5*(ix+1)+5) '% sparsity thresh.']);
    tt.FontSize=8;
end
% save source data for plot
clear SourceData
SourceData = array2table([h1(1).BinEdges(1:end-1)',h1(1).BinEdges(2:end)',h1(1).BinCounts',h1(2).BinCounts',h1(3).BinCounts',h1(4).BinCounts',h1(5).BinCounts',h1(6).BinCounts',h1(7).BinCounts',h1(8).BinCounts',h1(9).BinCounts'],'VariableNames',{'edge_from','edge_to','count_10','count_15','count_20','count_25','count_30','count_35','count_40','count_45','count_50'});
writetable(SourceData,fullfile(outputDir,['SourceData_Task' block_selection{2} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
SourceData = array2table([h2(1).BinEdges(1:end-1)',h2(1).BinEdges(2:end)',h2(1).BinCounts',h2(2).BinCounts',h2(3).BinCounts',h2(4).BinCounts',h2(5).BinCounts',h2(6).BinCounts',h2(7).BinCounts',h2(8).BinCounts',h2(9).BinCounts'],'VariableNames',{'edge_from','edge_to','count_10','count_15','count_20','count_25','count_30','count_35','count_40','count_45','count_50'});
writetable(SourceData,fullfile(outputDir,['SourceData_Task' block_selection{1} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
SourceData = array2table([h3(1).BinEdges(1:end-1)',h3(1).BinEdges(2:end)',h3(1).BinCounts',h3(2).BinCounts',h3(3).BinCounts',h3(4).BinCounts',h3(5).BinCounts',h3(6).BinCounts',h3(7).BinCounts',h3(8).BinCounts',h3(9).BinCounts'],'VariableNames',{'edge_from','edge_to','count_10','count_15','count_20','count_25','count_30','count_35','count_40','count_45','count_50'});
writetable(SourceData,fullfile(outputDir,['SourceData_Control' block_selection{2} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
SourceData = array2table([h4(1).BinEdges(1:end-1)',h4(1).BinEdges(2:end)',h4(1).BinCounts',h4(2).BinCounts',h4(3).BinCounts',h4(4).BinCounts',h4(5).BinCounts',h4(6).BinCounts',h4(7).BinCounts',h4(8).BinCounts',h4(9).BinCounts'],'VariableNames',{'edge_from','edge_to','count_10','count_15','count_20','count_25','count_30','count_35','count_40','count_45','count_50'});
writetable(SourceData,fullfile(outputDir,['SourceData_Control' block_selection{1} '.csv']),'WriteVariableNames',true,'WriteRowNames',true)


%     [p, observeddifference, effectsize] = permutationTest(valDiffStr(ix,:),valDiffStr_con(ix,:),10000)


% print
[annot, srcInfo] = docDataSrc(fig(2),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(2),fullfile(outputDir,['Connection_Added_TaskVsCon_thresholdPlot.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['Connection_Added_TaskVsCon_thresholdPlot']),'-painters','-bestfit','-r400','-append');

