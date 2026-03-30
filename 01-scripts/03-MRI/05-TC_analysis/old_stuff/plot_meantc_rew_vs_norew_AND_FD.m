load('/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/animalinfo.mat');

region_sel{1}='OT';
region_sel{2}='NAc';
region_sel{3}='DorStr';
region_sel{4}='APC';
region_sel{5}='PPC';
region_sel{6}='AON';
region_sel{7}='OB';
region_sel{8}='Ect';
region_sel{9}='SM';

preproc_sel{1}='regr12_6rp_deriv__Licks'
preproc_sel{2}='regr14_6rp_csf_deriv__ica__Licks';
preproc_sel{3}='regr16_6rp_csf_FD_deriv__ica__Licks';

outputdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/regional_BOLD_to_RPE';

for lx=1%:3;
    for kx=1%:9;
        
        for ix=1:83;
            for jx=1:8;
                d_BOLD(ix,jx)=mean(animal(ix).(preproc_sel{lx}).(region_sel{kx}).BOLD.(['timebin_' num2str(jx)]).tc(animal(ix).SigmaB.Rew_code.val==1))
                nd_BOLD(ix,jx)=mean(animal(ix).(preproc_sel{lx}).(region_sel{kx}).BOLD.(['timebin_' num2str(jx)]).tc(animal(ix).SigmaB.Rew_code.val==0));
            end
        end
        
        for jx=1:8;
            MEAN_d_BOLD(jx)=mean(d_BOLD(:,jx));
            SEM_d_BOLD(jx)=SEM_calc(d_BOLD(:,jx));
            MEAN_nd_BOLD(jx)=mean(nd_BOLD(:,jx));
            SEM_nd_BOLD(jx)=SEM_calc(nd_BOLD(:,jx));
        end;
        
        for jx=1:8;
            [h(jx),p(jx)]=ttest2(d_BOLD(:,jx),nd_BOLD(:,jx));
        end;
        
        figure(1);
        subplot(1,2,1);
        plot(MEAN_d_BOLD,'g','LineWidth',1.5);
        hold on;
        plot(MEAN_d_BOLD+SEM_d_BOLD,'g','LineStyle','--');
        hold on;
        plot(MEAN_d_BOLD-SEM_d_BOLD,'g','LineStyle','--');
        hold on;
        
        plot(MEAN_nd_BOLD,'r','LineWidth',1.5);
        hold on;
        plot(MEAN_nd_BOLD+SEM_nd_BOLD,'r','LineStyle','--');
        hold on;
        plot(MEAN_nd_BOLD-SEM_nd_BOLD,'r','LineStyle','--');
        
        hold on;
        ll=line([3.7 3.7],[-0.5 0.5]);
        ll.Color=[0.5 0.5 0.5];
        ll.LineWidth=2;
        
        hold on;
        for jx=1:8;
            if p(jx)<0.05;
                tt=text(jx,0.45,'*');
                tt.FontSize=20;
                hold on;
            end
        end
        
        ax=gca;
        ax.YLabel.String='Mean BOLD';
        ax.XLabel.String='Time';
        ax.XLim=[1.5,8];
        ax.XTick=[1.5:1:7.5];
        ax.XTickLabel=[0:1.2:8.4];
        
        leg=legend({'mean Rew','mean+SEM Rew','mean-SEM Rew','mean NonRew','mean+SEM NonRew','mean-+SEM NonRew','Reward Timepoint'},'Location','southwest');
        leg.FontSize=5;        
        title(['BOLD ' region_sel{kx}]);
        
        for ix=1:83;
            for jx=1:8;
                d_FD(ix,jx)=mean(animal(ix).FD.(['timebin_' num2str(jx)]).tc(animal(ix).SigmaB.Rew_code.val==1))
                nd_FD(ix,jx)=mean(animal(ix).FD.(['timebin_' num2str(jx)]).tc(animal(ix).SigmaB.Rew_code.val==0));
            end
        end
        
        for jx=1:8;
            MEAN_d_FD(jx)=mean(d_FD(:,jx));
            SEM_d_FD(jx)=SEM_calc(d_FD(:,jx));
            MEAN_nd_FD(jx)=mean(nd_FD(:,jx));
            SEM_nd_FD(jx)=SEM_calc(nd_FD(:,jx));
        end;
        
        for jx=1:8;
            [h_FD(jx),p_FD(jx)]=ttest2(d_FD(:,jx),nd_FD(:,jx));
        end;
        
        subplot(1,2,2);
        plot(MEAN_d_FD,'g','LineWidth',1.5);
        hold on;
        plot(MEAN_d_FD+SEM_d_FD,'g','LineStyle','--');
        hold on;
        plot(MEAN_d_FD-SEM_d_FD,'g','LineStyle','--');
        hold on;
        
        plot(MEAN_nd_FD,'r','LineWidth',1.5);
        hold on;
        plot(MEAN_nd_FD+SEM_nd_FD,'r','LineStyle','--');
        hold on;
        plot(MEAN_nd_FD-SEM_nd_FD,'r','LineStyle','--');
        
        hold on;
        ll=line([3.7 3.7],[-0.5 0.5]);
        ll.Color=[0.5 0.5 0.5];
        ll.LineWidth=2;
        
        hold on;
        for jx=1:8;
            if p_FD(jx)<0.05;
                tt=text(jx,0.45,'*');
                tt.FontSize=20;
                hold on;
            end
        end
        
        ax=gca;
        ax.YLabel.String='Mean FD';
        ax.XLabel.String='Time';
        ax.XLim=[1.5,8];
        ax.XTick=[1.5:1:7.5];
        ax.XTickLabel=[0:1.2:8.4];
        
        leg=legend({'mean Rew','mean+SEM Rew','mean-SEM Rew','mean NonRew','mean+SEM NonRew','mean-+SEM NonRew','Reward Timepoint'},'Location','southwest');
        leg.FontSize=5;
        title(['Framewise Displacement ' region_sel{kx}]);
        
        print('-dpsc',fullfile(outputdir,[preproc_sel{lx} '_all_animals_TCRewvsNoRew_FD_Assessment.ps']) ,'-r200','-append','-bestfit');
        close all;
    end;
end
