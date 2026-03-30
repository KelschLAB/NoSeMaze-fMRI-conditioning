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


for ix=1:83;
    for zx=1:160;               
        if animal(ix).SigmaB.Rew_code.val(zx)==1 && animal(ix).SigmaB.Odor.val(zx)==1;
            animal(ix).trial_code.val(zx)=1;
        elseif animal(ix).SigmaB.Rew_code.val(zx)==0 && animal(ix).SigmaB.Odor.val(zx)==1;
            animal(ix).trial_code.val(zx)=2;
        elseif animal(ix).SigmaB.Rew_code.val(zx)==1 && animal(ix).SigmaB.Odor.val(zx)==2;
            animal(ix).trial_code.val(zx)=3;
        elseif animal(ix).SigmaB.Rew_code.val(zx)==0 && animal(ix).SigmaB.Odor.val(zx)==2;
            animal(ix).trial_code.val(zx)=4;
        end
    end
end

nan(8,83,160,4);

for lx=1;%
    for kx=2;
        for ix=1:83;
            for jx=1:8;
                for nx=1:4;
                    clear find_vec;
                    find_vec=find(animal(ix).trial_code.val==nx);
                    sum_mat(jx,ix,find_vec,nx)=animal(ix).(preproc_sel{lx}).(region_sel{kx}).BOLD.(['timebin_' num2str(jx)]).tc(find_vec);
                end
            end
        end
    end
end;
1==1;

sum_mat=sum_mat(:,[1:25,41:83],:,:);

for ix=1:8;
    for nx=1:4;
        test=squeeze(sum_mat(ix,:,:,nx));
        counter=1; 
        for jx=1:8; 
            ex(ix,nx,jx)=nanmean(nanmean(test(:,counter:counter+19))); 
            counter=counter+20; 
        end
    end
end


color=[1 0 0; 1 0.5 0; 0 0 1; 0 1 1];
figure(1);
for ix=1:8;
    ix
    subplot(4,2,ix);
    for nx=1:4;
        nx
        plot(squeeze(ex(:,nx,ix)),'Color',color(nx,:));
        hold on;
        legend({'Start: 75%; R','Start: 75%; NR','Start: 25%; R','Start: 25%; NR',},'Location','southwest');
    end
    ax=gca;
    ax.YLim=[-1.5 0.5];
end
%                 end

%             end
%         end
%
%         figure(1);
%         for ix=1:83;
%             counter=1;
%             for sx=1:8;
%                 for jx=1:8;
%                     MEAN_d_BOLD(sx,jx,ix)=mean(d_BOLD((counter:(counter+10-1)),jx,ix));
%                     SEM_d_BOLD(sx,jx,ix)=SEM_calc(d_BOLD((counter:(counter+10-1)),jx,ix));
%                     MEAN_nd_BOLD(sx,jx,ix)=mean(nd_BOLD((counter:(counter+10-1)),jx,ix));
%                     SEM_nd_BOLD(sx,jx,ix)=SEM_calc(nd_BOLD((counter:(counter+10-1)),jx,ix));
%                 end;
%                 counter=counter+10;
%             end;
%         end;
%
%         counter=1;
%         for sx=1:8;
%             for jx=1:8;
%                 [h(sx,jx),p(sx,jx)]=ttest2(squeeze(mean(d_BOLD((counter:(counter+10-1)),jx,:))),squeeze(mean(nd_BOLD((counter:(counter+10-1)),jx,:))));
%             end
%             counter=counter+10;
%         end
%
%
%         for sx=1:8;
%             subplot(2,4,sx);
%             plot(mean(MEAN_d_BOLD(sx,:,:),3),'g','LineWidth',1.5);
%             hold on;
%             plot(mean(MEAN_d_BOLD(sx,:,:),3)+mean(SEM_d_BOLD(sx,:,:),3),'g','LineStyle','--');
%             hold on;
%             plot(mean(MEAN_d_BOLD(sx,:,:),3)-mean(SEM_d_BOLD(sx,:,:),3),'g','LineStyle','--');
%             hold on;
%
%             plot(mean(MEAN_nd_BOLD(sx,:,:),3),'r','LineWidth',1.5);
%             hold on;
%             plot(mean(MEAN_nd_BOLD(sx,:,:),3)+mean(SEM_nd_BOLD(sx,:,:),3),'r','LineStyle','--');
%             hold on;
%             plot(mean(MEAN_nd_BOLD(sx,:,:),3)-mean(SEM_nd_BOLD(sx,:,:),3),'r','LineStyle','--');
%
%             hold on;
%             ll=line([3.7 3.7],[-0.5 0.5]);
%             ll.Color=[0.5 0.5 0.5];
%             ll.LineWidth=2;
%
%             hold on;
%             for jx=1:8;
%                 if p(sx,jx)<0.05;
%                     tt=text(jx,0.45,'*');
%                     tt.FontSize=20;
%                     hold on;
%                 end
%             end
%
%             ax=gca;
%             ax.YLabel.String='Mean BOLD';
%             ax.XLabel.String='Time';
%             ax.XLim=[1.5,8];
%             ax.XTick=[1.5:1:7.5];
%             ax.XTickLabel=[0:1.2:8.4];
%
%             leg=legend({'mean Rew','mean+SEM Rew','mean-SEM Rew','mean NonRew','mean+SEM NonRew','mean-+SEM NonRew','Reward Timepoint'},'Location','southwest');
%             leg.FontSize=5;
%             title(['BOLD ' region_sel{kx}]);
%         end
%
%     end

%         for ix=1:83;
%             for jx=1:8;
%                 d_FD(ix,jx)=mean(animal(ix).FD.(['timebin_' num2str(jx)]).tc(animal(ix).SigmaB.Rew_code.val==1))
%                 nd_FD(ix,jx)=mean(animal(ix).FD.(['timebin_' num2str(jx)]).tc(animal(ix).SigmaB.Rew_code.val==0));
%             end
%         end
%
%         for jx=1:8;
%             MEAN_d_FD(jx)=mean(d_FD(:,jx));
%             SEM_d_FD(jx)=SEM_calc(d_FD(:,jx));
%             MEAN_nd_FD(jx)=mean(nd_FD(:,jx));
%             SEM_nd_FD(jx)=SEM_calc(nd_FD(:,jx));
%         end;
%
%         for jx=1:8;
%             [h_FD(jx),p_FD(jx)]=ttest2(d_FD(:,jx),nd_FD(:,jx));
%         end;
%
%         subplot(1,2,2);
%         plot(MEAN_d_FD,'g','LineWidth',1.5);
%         hold on;
%         plot(MEAN_d_FD+SEM_d_FD,'g','LineStyle','--');
%         hold on;
%         plot(MEAN_d_FD-SEM_d_FD,'g','LineStyle','--');
%         hold on;
%
%         plot(MEAN_nd_FD,'r','LineWidth',1.5);
%         hold on;
%         plot(MEAN_nd_FD+SEM_nd_FD,'r','LineStyle','--');
%         hold on;_all_animals_CORR
%         plot(MEAN_nd_FD-SEM_nd_FD,'r','LineStyle','--');
%
%         hold on;
%         ll=line([3.7 3.7],[-0.5 0.5]);
%         ll.Color=[0.5 0.5 0.5];
%         ll.LineWidth=2;
%
%         hold on;
%         for jx=1:8;
%             if p_FD(jx)<0.05;
%                 tt=text(jx,0.45,'*');
%                 tt.FontSize=20;
%                 hold on;
%             end
%         end
%
%         ax=gca;
%         ax.YLabel.String='Mean FD';
%         ax.XLabel.String='Time';
%         ax.XLim=[1.5,8];
%         ax.XTick=[1.5:1:7.5];
%         ax.XTickLabel=[0:1.2:8.4];
%
%         leg=legend({'mean Rew','mean+SEM Rew','mean-SEM Rew','mean NonRew','mean+SEM NonRew','mean-+SEM NonRew','Reward Timepoint'},'Location','southwest');
%         leg.FontSize=5;
%         title(['Framewise Displacement ' region_sel{kx}]);
%
% print('-dpsc',fullfile(outputdir,[preproc_sel{lx} '_all_animals_TCRewvsNoRew_FD_Assessment.ps']) ,'-r200','-append','-bestfit');
% close all;
% end;

