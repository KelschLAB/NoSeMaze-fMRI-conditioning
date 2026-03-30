
figure(7);
for ix=1:8;
    % sort RPE:
    [val_sortRPE,indx_sortRPE]=sort(vec_sum_all(ix).vec_sum(1,:));
    % sort BOLD based on RPE:
    val_sortBOLD=vec_sum_all(ix).vec_sum(2,indx_sortRPE)
    for jx=1:(13280-400); val_mean_BOLD(jx)=mean(val_sortBOLD(jx:(400+jx))); end;
    for jx=1:40; val_mean_BOLD_new(jx)=mean(val_sortBOLD((332*(jx-1)+1):(332*jx))); end;
    for jx=1:40; val_mean_RPE(jx)=mean(val_sortRPE((332*(jx-1)+1):(332*jx))); end;

    subplot(3,3,ix); 

    plot([(40/(13280-400)):(40/(13280-400)):40],val_mean_BOLD,'Color',[0.5 0.5 0.5],'LineWidth',0.5); hold on;ll=line([(find(val_sortRPE==0,1)*40)/(13280-400) (find(val_sortRPE==0,1)*40)/(13280-400)],[-0.6 0.6]);ll.Color=[1 0 0];hold on;
    ll=line([1 find(val_sortRPE==0,1)*(40/(13280-400))],[mean(val_sortBOLD(val_sortRPE<0)) mean(val_sortBOLD(val_sortRPE<0))]);ll.Color=[0 0 1];hold on; ll=line([find(val_sortRPE==0,1)*(40/(13280-400)) 40],[mean(val_sortBOLD(val_sortRPE>0)) mean(val_sortBOLD(val_sortRPE>0))]);ll.Color=[0 0 1];hold on;
    plot([(332/2)*(40/13280):332*(40/13280):40],val_mean_BOLD_new,'Color',[0.5 0 0],'LineWidth',1,'LineStyle','--'); hold on;
    plot([(332/2)*(40/13280):332*(40/13280):40],val_mean_RPE/10-0.3,'Color',[1 0.5 0]);
    
    ax=gca;
    ax.YLim=[-0.6 0.6];
    ax.XLim=[0 40];
    ax.XTick=[0,(find(val_sortRPE==0,1)*40)/(13280-400),40];
    ax.XTickLabel=[val_sortRPE(1) 0 val_sortRPE(end)];
    ax.XLabel.String='RPE';
    ax.YLabel.String='BOLD (detr., z-transformed)';
    ax.YTick=[-0.6:0.2:0.6];
    ax.YTickLabel=[-0.6:0.2:0.6];
    
    title(['Time Bin ' num2str(ix)]);
    
    [c(ix),p(ix)]=corr(val_sortBOLD',val_sortRPE');
    [c_pos(ix),p_pos(ix)]=corr(val_sortBOLD(val_sortRPE>0)',val_sortRPE(val_sortRPE>0)');
    [c_neg(ix),p_neg(ix)]=corr(val_sortBOLD(val_sortRPE<0)',val_sortRPE(val_sortRPE<0)');
    
    legend%({'aa','bb','cb'},'Location','bestfit')

end