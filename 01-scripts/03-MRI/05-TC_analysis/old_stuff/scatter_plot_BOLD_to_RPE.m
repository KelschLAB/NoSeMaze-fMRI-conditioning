%% Correlation BOLD to RPE: scatterplot
close all
studydir='/home/jonathan.reinwald/Awake/data/fmri_data/'; cd(studydir)

% Predefinition of (differently processed) mean TC, region of interest and
% the respective model
% meantcdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__12regr_6rp_deriv__Licks__MASK_0/';
meantcdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__14regr_6rp_csf_deriv__icaden25_16-Feb-2020__Licks__MASK_0/';
% meantcdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__16regr_6rp_csf_FD_deriv__icaden25_16-Feb-2020__Licks__MASK_0/';

ROI_name{1}='olf tubercle inPax';
ROI_name{2}='NAc inPax';

% modeldir='/home/jonathan.reinwald/Awake/RLModel/fMRI_data/MLE_Pav_Gauss_AlphaStatic_NewRewCode_01/';
modeldir='/home/jonathan.reinwald/Awake/RLModel/fMRI_data/MLE_Pav_Gauss_Hybrid_bc/';


% for loop over all sessions ...
load([studydir filesep 'filelist_awake_MAIN_JR.mat'], 'Pfunc');

trial_selection=[1:160*76];

for sx=1;
    % load mean TC: tc_matrix_all
    load([meantcdir ROI_name{sx} filesep 'correlation_tc_to_event_output.mat'])
    
    for ix=1:length(Pfunc);
        load([modeldir 'RLM_OdorID_' num2str(ix) '.mat']);
        RPE_all(ix,:)=model.logdata(:,8);%2=drop or not, 8=RPE, 5=expect. high, 6= expected low, 7=alpha
        %%
        if median(median(model.logdata(1:40,5))>0.5);
            varhigh=[model.logdata(1:40,5);model.logdata(41:80,6);model.logdata(81:120,5);model.logdata(121:160,6)];
            varhighsel=[(model.logdata(1:40,3)==1);(model.logdata(41:80,3)==2);(model.logdata(81:120,3)==1);(model.logdata(121:160,3)==2)];
            varlow=[model.logdata(1:40,6);model.logdata(41:80,5);model.logdata(81:120,6);model.logdata(121:160,5)];
            varlowsel=[(model.logdata(1:40,3)==2);(model.logdata(41:80,3)==1);(model.logdata(81:120,3)==2);(model.logdata(121:160,3)==1)];
        elseif median(median(model.logdata(1:40,6))>0.5);
            varhigh=[model.logdata(1:40,6);model.logdata(41:80,5);model.logdata(81:120,6);model.logdata(121:160,5)];
            varhighsel=[(model.logdata(1:40,3)==2);(model.logdata(41:80,3)==1);(model.logdata(81:120,3)==2);(model.logdata(121:160,3)==1)];
            varlow=[model.logdata(1:40,5);model.logdata(41:80,6);model.logdata(81:120,5);model.logdata(121:160,6)];
            varlowsel=[(model.logdata(1:40,3)==1);(model.logdata(41:80,3)==2);(model.logdata(81:120,3)==1);(model.logdata(121:160,3)==2)];
        end
        for jx=2:length(varhighsel);
            if varhighsel(jx)==1;
                var_allexp(jx)=varhigh(jx);
            elseif varlowsel(jx)==1;
                var_allexp(jx)=varlow(jx);
            end
        end
        %%
        Expect_all(ix,:)=var_allexp;%2=drop or not, 8=RPE, 5=expect. high, 6= expected low, 7=alpha
        Rew_all(ix,:)=model.logdata(:,2);
    end;
    % create summary vector: vector_RPE_BOLD for all trials
    
    for jx=1:size(tc_matrix_all,3); % time bins in correlation_tc_to_event_output.mat
        for ix=1:length(Pfunc);
            [fdir, fname, ext]=fileparts(Pfunc{ix});
            vector_combined(jx,ix).name=fname;
            vector_combined(jx,ix).timebin_name=['timebin_' num2str(jx)];
            vector_combined(jx,ix).RPE=squeeze(RPE_all(ix,:));
            vector_combined(jx,ix).BOLD=squeeze(tc_matrix_all(ix,:,jx));
            vector_combined(jx,ix).Expect=squeeze(Expect_all(ix,:));
            vector_combined(jx,ix).Rew=squeeze(Rew_all(ix,:));
            [vector_combined(jx,ix).cc_RPE_BOLD,vector_combined(jx,ix).p_RPE_BOLD]=corr(squeeze(RPE_all(ix,:))',squeeze(tc_matrix_all(ix,:,jx))');
            [vector_combined(jx,ix).cc_Rew_BOLD,vector_combined(jx,ix).p_Rew_BOLD]=corr(squeeze(Rew_all(ix,:))',squeeze(tc_matrix_all(ix,:,jx))');
            vector_combined(jx,ix).cc_RPE_BOLD_div_cc_Rew_BOLD=vector_combined(jx,ix).cc_RPE_BOLD/vector_combined(jx,ix).cc_Rew_BOLD;
        end
    end
    
    figure(1+(sx-1)*3)
    for jx=1:size(tc_matrix_all,3); % time bins in correlation_tc_to_event_output.mat
        subplot(3,3,jx);
        clear vec_sum;
        vec_sum=[];
        for ix=1:length(Pfunc);
            vec_sum=[vec_sum,[vector_combined(jx,ix).RPE;vector_combined(jx,ix).BOLD;vector_combined(jx,ix).Expect;vector_combined(jx,ix).Rew]];
        end;
        [cc_REWall(jx),p_REWall(jx)]=corr(vec_sum(4,trial_selection)',vec_sum(2,trial_selection)');
        [cc_REWpos(jx),p_REWpos(jx)]=corr(vec_sum(1,(vec_sum(4,trial_selection)==1))',vec_sum(2,(vec_sum(4,trial_selection)==1))');
        [cc_REWzero(jx),p_REWzero(jx)]=corr(vec_sum(1,(vec_sum(4,trial_selection)==0))',vec_sum(2,(vec_sum(4,trial_selection)==0))');
%             [cc_REWneg(jx),p_REWneg(jx)]=corr(vec_sum(1,(vec_sum(4,:)==-1))',vec_sum(2,(vec_sum(4,:)==-1))');
        [cc_RPEall(jx),p_RPEall(jx)]=corr(vec_sum(1,trial_selection)',vec_sum(2,trial_selection)');
        [cc_RPEpos(jx),p_RPEpos(jx)]=corr(vec_sum(1,(vec_sum(1,trial_selection)>0))',vec_sum(2,(vec_sum(1,trial_selection)>0))');
        [cc_RPEneg(jx),p_RPEneg(jx)]=corr(vec_sum(1,(vec_sum(1,trial_selection)<0))',vec_sum(2,(vec_sum(1,trial_selection)<0))');
        [cc_Expectall(jx),p_Expectall(jx)]=corr(vec_sum(3,trial_selection)',vec_sum(2,trial_selection)');
        [cc_Expectpos(jx),p_Expectpos(jx)]=corr(vec_sum(3,(vec_sum(3,trial_selection)>0.5))',vec_sum(2,(vec_sum(3,trial_selection)>0.5))');
        [cc_Expectneg(jx),p_Expectneg(jx)]=corr(vec_sum(3,(vec_sum(3,trial_selection)<0.5))',vec_sum(2,(vec_sum(3,trial_selection)<0.5))');
        
        scatter(vec_sum(1,trial_selection)',vec_sum(2,trial_selection)',0.5,'filled');
        vec_sum_all(jx).vec_sum=vec_sum;
        ax=gca;
        ax.YLim=[-5 5];
        ax.XLim=[-2 2];
        ax.XLabel.String='RPE';
        title([vector_combined(jx,1).timebin_name '_' ROI_name{sx}]);
    end;
    
    figure(2+(sx-1)*3);
    % subplot(2,2,1);
    plot(cc_REWall,'Color',[0 0 0],'LineWidth',1,'LineStyle','--');
    hold on; plot(cc_REWpos,'Color',[0 0.7 0.5],'LineWidth',1,'LineStyle','--');
    hold on; plot(cc_REWzero,'Color',[0 0.2 0.5],'LineWidth',1,'LineStyle','--');
%     hold on; plot(cc_REWneg,'Color',[0 0 1],'LineWidth',2);
    hold on; plot(cc_RPEall,'Color',[1 0 0],'LineWidth',2);
    hold on; plot(cc_RPEpos,'Color',[1 0.5 0],'LineWidth',2);
    hold on; plot(cc_RPEneg,'Color',[1 1 0],'LineWidth',2);
    % hold on; plot(cc_Expectall,'Color',[0 1 0],'LineWidth',2);
    % hold on; plot(cc_Expectpos,'Color',[0 0.8 0],'LineWidth',2);
    % hold on; plot(cc_Expectneg,'Color',[0 0.2 0],'LineWidth',2);
%     legend({'cc Rew','cc REW_1','cc REW_0','cc REW_-1','cc RPE all','cc pos. RPE','cc neg. RPE','cc high exp','cc low exp'},'Interpreter','none');
    legend({'cc REWtoBOLD','cc RPEtoBOLD (REW=1)','cc RPEtoBOLD (REW=0)','cc RPEtoBOLD','cc RPEtoBOLD (RPE>0)','cc RPEtoBOLD (RPE<0)','cc high exp','cc low exp'},'Interpreter','none');
    title(['correlation coefficient BOLD to RPE ' ROI_name{sx}]);
    
    figure(3+(sx-1)*3);
    for jx=1:8;
        ms(jx,1)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(1,:)>0));
    end
    for jx=1:8;
        ms(jx,2)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(1,:)<0));
    end
    subplot(1,3,1);
    plot(ms(:,1));
    hold on;
    plot(ms(:,2),'g');
    legend({'mean TC: pos. RPE','mean TC: neg. RPE'});
    title(['mean TC RPE ' ROI_name{sx}]);
    
    for jx=1:8;
        ms(jx,1)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(3,:)>0.5));
    end
    for jx=1:8;
        ms(jx,2)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(3,:)<0.5));
    end
    subplot(1,3,2);
    plot(ms(:,1));
    hold on;
    plot(ms(:,2),'g');
    legend({'mean TC high exp','mean TC low exp'});
    title(['mean TC Expectation '  ROI_name{sx}]);
    
    
    for jx=1:8;
        ms(jx,1)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(4,:)==1));
    end
    for jx=1:8;
        ms(jx,2)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(4,:)==0));
    end
    for jx=1:8;
        ms(jx,3)=mean(vec_sum_all(jx).vec_sum(2,vec_sum_all(jx).vec_sum(4,:)==-1));
    end
    subplot(1,3,3);
    plot(ms(:,1));
    hold on;
    plot(ms(:,2),'g');
    
%     hold on;
%     plot(ms(:,3),'r');
%     legend({'mean TC: Rew=1','mean TC: Rew=0'});
%         legend({'mean TC: Rew=1','mean TC: Rew=0','mean TC: Rew=1-'});

    title(['mean TC Reward ' ROI_name{sx}]);
end



