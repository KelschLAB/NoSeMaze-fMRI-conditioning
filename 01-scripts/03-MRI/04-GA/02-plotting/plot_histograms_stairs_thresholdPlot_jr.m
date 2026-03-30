%% plot_histograms_stairs_thresholdPlot_jr.m
% JR, 16.10.2023
% - script is work in progress

% clearing
clear all
close all
clc

% color
color_bl3 = [0 160/255 227/255];
color_bl1 = [204/255 51/255 204/255];
color_task = [0/255 128/255 128/255];
color_con = [75/255 75/255 75/255];

% output directory
% outputDir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/cormat_v11/separated_v2_2023_hemisphere/max_connected/threshold_plots/cormat_v11VScormat_v6';
outputDir = '/zi-flstorage/data/jonathan/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/06-GA/cormat_v11/separated_v2_2023_hemisphere/max_connected/threshold_plots/cormat_v11VScormat_v6';

if ~exist(outputDir)
    mkdir(outputDir);
end

% load data task
cd('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/07-GA/01-gstruct_files/cormat_v11/separated_v2_2023_hemisphere/max_connected')
load('gstruc_TPnoPuff81to120_p.mat')
g3=gstruc;
load('gstruc_TPnoPuff11to40_p.mat')
g1=gstruc;

fig(1)=figure('visible', 'on');     set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.9,0.8]); 
for ix=1:41 
    val3=[g3(ix,:).l_strength]; 
    val1=[g1(ix,:).l_strength]; 
    valDiffStr(ix,:)=val3(:)-val1(:);
    [h(ix),p_str_tsk(ix)]=ttest(val3(:),val1(:)); 
    subplot(7,7,ix); 
    histogram(val1(:),'BinWidth',1,'EdgeColor',color_bl1,'LineWidth',1.5,'DisplayStyle','stairs'); 
    hold on; histogram(val3(:),'BinWidth',1,'EdgeColor',color_bl3,'LineWidth',1.5,'DisplayStyle','stairs'); 
    title([num2str(ix+9) '%']); ax=gca; ax.Box='off'; ax.LineWidth=1; 
end
suptitle('strength, task');

% print
[annot, srcInfo] = docDataSrc(fig(1),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(1),fullfile(outputDir,['histogram_stairsPlot_strength_task_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_stairsPlot_strength_task_thresholds']),'-painters','-r400','-bestfit','-append');

fig(2)=figure('visible', 'on');     set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.9,0.8]); 
for ix=1:41 
    val3=[g3(ix,:).l_cc]; 
    val1=[g1(ix,:).l_cc]; 
    valDiffCC(ix,:)=val3(:)-val1(:);
    [h(ix),p_cc_tsk(ix)]=ttest(val3(:),val1(:)); 
    subplot(7,7,ix); 
    histogram(val1(:),'BinWidth',0.05,'EdgeColor',color_bl1,'LineWidth',1.5,'DisplayStyle','stairs'); 
    hold on; histogram(val3(:),'BinWidth',0.05,'EdgeColor',color_bl3,'LineWidth',1.5,'DisplayStyle','stairs'); 
    title([num2str(ix+9) '%']); ax=gca; ax.Box='off'; ax.LineWidth=1; 
end
suptitle('clustering coeff., task');

% print
[annot, srcInfo] = docDataSrc(fig(2),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(2),fullfile(outputDir,['histogram_stairsPlot_CC_task_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_stairsPlot_CC_task_thresholds']),'-painters','-r400','-bestfit','-append');

% load data control
cd('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/cormat_v6/separated_v2_2023_hemisphere/max_connected')
load('gstruc_TPnoPuff81to120_p.mat')
g3=gstruc;
load('gstruc_TPnoPuff11to40_p.mat')
g1=gstruc;
fig(3)=figure('visible', 'on');     set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.9,0.8]); 
for ix=1:41 
    val3_con=[g3(ix,:).l_strength]; 
    val1_con=[g1(ix,:).l_strength]; 
    valDiffStr_con(ix,:)=val3_con(:)-val1_con(:);
    [h(ix),p_str_con(ix)]=ttest(val3_con(:),val1_con(:)); 
    subplot(7,7,ix); 
    histogram(val1_con(:),'BinWidth',1,'EdgeColor',color_bl1,'LineWidth',1.5,'DisplayStyle','stairs'); 
    hold on; histogram(val3_con(:),'BinWidth',1,'EdgeColor',color_bl3,'LineWidth',1.5,'DisplayStyle','stairs'); 
    title([num2str(ix+9) '%']); ax=gca; ax.Box='off'; ax.LineWidth=1; 
end
suptitle('strength, control');

% print
[annot, srcInfo] = docDataSrc(fig(3),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(3),fullfile(outputDir,['histogram_stairsPlot_strength_control_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_stairsPlot_strength_control_thresholds']),'-painters','-r400','-bestfit','-append');

fig(4)=figure('visible', 'on');     set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.9,0.8]);
for ix=1:41 
    val3_con=[g3(ix,:).l_cc]; 
    val1_con=[g1(ix,:).l_cc]; 
    valDiffCC_con(ix,:)=val3_con(:)-val1_con(:);
    [h(ix),p_cc_con(ix)]=ttest(val3_con(:),val1_con(:)); 
    subplot(7,7,ix); 
    histogram(val1_con(:),'BinWidth',0.05,'EdgeColor',color_bl1,'LineWidth',1.5,'DisplayStyle','stairs'); 
    hold on; histogram(val3_con(:),'BinWidth',0.05,'EdgeColor',color_bl3,'LineWidth',1.5,'DisplayStyle','stairs'); 
    title([num2str(ix+9) '%']); ax=gca; ax.Box='off'; ax.LineWidth=1; 
end
suptitle('clustering coeff., control');

% print
[annot, srcInfo] = docDataSrc(fig(4),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(4),fullfile(outputDir,['histogram_stairsPlot_CC_control_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_stairsPlot_CC_control_thresholds']),'-painters','-r400','-bestfit','-append');

fig(5)=figure('visible', 'on');     set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.9,0.8]);
for ix=1:41 
    subplot(7,7,ix); 
    histogram(valDiffCC_con(ix,:),'BinWidth',0.05,'EdgeColor',color_con,'LineWidth',1.5,'DisplayStyle','stairs'); 
    hold on; histogram(valDiffCC(ix,:),'BinWidth',0.05,'EdgeColor',color_task,'LineWidth',1.5,'DisplayStyle','stairs'); 
    title([num2str(ix+9) '%']); ax=gca; ax.Box='off'; ax.LineWidth=1; 
end

suptitle('clustering coeff., task vs control');

% print
[annot, srcInfo] = docDataSrc(fig(5),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(5),fullfile(outputDir,['histogram_stairsPlot_CC_taskVScontrol_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_stairsPlot_CC_taskVScontrol_thresholds']),'-painters','-r400','-bestfit','-append');

fig(6)=figure('visible', 'on');     set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.9,0.8]);
for ix=1:41 
    subplot(7,7,ix); 
    histogram(valDiffStr_con(ix,:),'BinWidth',1,'EdgeColor',color_con,'LineWidth',1.5,'DisplayStyle','stairs'); 
    hold on; histogram(valDiffStr(ix,:),'BinWidth',1,'EdgeColor',color_task,'LineWidth',1.5,'DisplayStyle','stairs'); 
    title([num2str(ix+9) '%']); ax=gca; ax.Box='off'; ax.LineWidth=1; 
end
suptitle('strength, task vs control');

% print
[annot, srcInfo] = docDataSrc(fig(6),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(6),fullfile(outputDir,['histogram_stairsPlot_strength_taskVScontrol_thresholds.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_stairsPlot_strength_taskVScontrol_thresholds']),'-painters','-r400','-bestfit','-append');


for ix=1:41 
    [p_str_all(ix), observeddifference_str_all(ix), effectsize_str_all(ix)] = permutationTest(valDiffStr(ix,:),valDiffStr_con(ix,:),10000)
    [p_CC_all(ix), observeddifference_CC_all(ix), effectsize_CC_all(ix)] = permutationTest(valDiffCC(ix,:),valDiffCC_con(ix,:),10000)
end

% comparison
fig(7)=figure('visible', 'on');     
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.5,0.8]);

subplot(2,1,1);
pl1=plot(observeddifference_str_all);
pl1.LineWidth=2; 
pl1.LineStyle='--';
hold on;
pl2=plot(effectsize_str_all);
pl2.LineWidth=2; 
pl2.LineStyle='-';
ax=gca;ax.Box='off';
ax.XLim=[1,41];
yLim=ax.YLim;
ax.XTick=[1:5:41];
ax.XTickLabel=[0:5:40]+10;
ax.XLabel.String={'sparsity threshold','%'};
ax.YLabel.String='observed diff; effect size';
% statistics
for ix=1:length(p_str_all)
    if p_str_all(ix)<0.05
        tx=text(ix,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
    elseif p_str_all(ix)<0.1
        tx=text(ix,yLim(1)+0.9*(yLim(2)-yLim(1)),'#');
    end
end
legend({'observed diff','effect size'})
title('strength: Task Vs Con')

subplot(2,1,2);
pl1=plot(observeddifference_CC_all);
pl1.LineWidth=2; 
pl1.LineStyle='--';
hold on;
pl2=plot(effectsize_CC_all);
pl2.LineWidth=2; 
pl2.LineStyle='-';
ax=gca;
ax.XLim=[1,41];
yLim=ax.YLim;
ax.XTick=[1:5:41];
ax.XTickLabel=[0:5:40]+10;
ax.XLabel.String='sparsity threshold';
ax.YLabel.String='observed diff; effect size';
% statistics
for ix=1:length(p_CC_all)
    if p_CC_all(ix)<0.05
        tx=text(ix,yLim(1)+0.9*(yLim(2)-yLim(1)),'*');
    elseif p_CC_all(ix)<0.1
        tx=text(ix,yLim(1)+0.9*(yLim(2)-yLim(1)),'#');
    end
end
legend({'observed diff','effect size'})
title('clustering coeff.: Task Vs Con')

% print
[annot, srcInfo] = docDataSrc(fig(7),fullfile(outputDir),mfilename('fullpath'),logical(1));
exportgraphics(fig(7),fullfile(outputDir,['histogram_EffectSize_TaskVSControl.pdf']),'Resolution',300);
print('-dpsc',fullfile(outputDir,['histogram_EffectSize_TaskVSControl']),'-painters','-r400','-bestfit','-append');

close all


