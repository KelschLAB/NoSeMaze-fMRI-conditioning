%% Correlation BOLD to RPE: scatterplot
% close all
studydir='/home/jonathan.reinwald/Awake/data/fmri_data/'; cd(studydir);
workingdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/';
protocol_new_dir='/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fMRI_new_mat_sorted';
outputdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/regional_BOLD_to_RPE';

% Predefinition of (differently processed) mean TC, region of interest and
% the respective model
meantcdir{1}='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__12regr_6rp_deriv__Licks__MASK_0';
meantcdir{2}='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__14regr_6rp_csf_deriv__icaden25_16-Feb-2020__Licks__MASK_0';
meantcdir{3}='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/FirstLevelResiduals__16regr_6rp_csf_FD_deriv__icaden25_16-Feb-2020__Licks__MASK_0';
meantcdir_corr{1}='regr12_6rp_deriv__Licks';
meantcdir_corr{2}='regr14_6rp_csf_deriv__ica__Licks';
meantcdir_corr{3}='regr16_6rp_csf_FD_deriv__ica__Licks';

ROI_name{1}='olf tubercle inPax';
ROI_name{2}='NAc inPax';
ROI_name{3}='dorsal striatum inPax';
ROI_name{4}='APC inPax';
ROI_name{5}='PPC inPax';
ROI_name{6}='AON inPax';
ROI_name{7}='OB inPax';
ROI_name{8}='Ectorhinal area';
% ROI_name{9}='Perihinal area'; % no file for FirstLevelResiduals__16regr_6rp_csf_FD_deriv__icaden25_16-Feb-2020__Licks__MASK_0
ROI_name{9}='somatomotor areas inPax';

ROI_name_corr{1}='OT';
ROI_name_corr{2}='NAc';
ROI_name_corr{3}='DorStr';
ROI_name_corr{4}='APC';
ROI_name_corr{5}='PPC';
ROI_name_corr{6}='AON';
ROI_name_corr{7}='OB';
ROI_name_corr{8}='Ect';
% ROI_name_corr{9}='Perih';
ROI_name_corr{9}='SM';

modeldir{1}='/home/jonathan.reinwald/Awake/RLModel/MLE_Pav_Gauss_SigmaB';
modeldir{2}='/home/jonathan.reinwald/Awake/RLModel/MLE_Pav_Gauss_Hybrid_bc';
modeldir{3}='/home/jonathan.reinwald/Awake/RLModel/MLE_Pav_Gauss_AlphaStatic_NewRewCode_01';
modeldir{4}='/home/jonathan.reinwald/Awake/RLModel/MLE_Pav_Gauss_AlphaStatic_NewRewCode_-101';
modeldir{5}='/home/jonathan.reinwald/Awake/RLModel/MLE_Pav_Gauss_Hybrid_bc_NewRewCode';

modeldir_corr{1}='SigmaB';
modeldir_corr{2}='Hybrid_bc';
modeldir_corr{3}='AlphaStatic_2';
modeldir_corr{4}='AlphaStatic_3';
modeldir_corr{5}='Hybrid_bc_new';

% for loop over all sessions ...
load([studydir filesep 'filelist_awake_MAIN_JR.mat'], 'Pfunc');

if 1==0;
    % loop for models:
    for ax=1:length(modeldir)
        % loop for mean timecourses:
        for bx=1:length(meantcdir)
            % loop for ROIs:
            for cx=1:length(ROI_name)
                % loop for Animals:
                for dx=1:length(Pfunc)
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Name:
                    [fdir, fname, ext]=fileparts(Pfunc{dx});
                    animal(dx).name=fname;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Model Values:
                    % load model:
                    load([modeldir{ax} filesep 'RLM_OdorID_' num2str(dx) '.mat']);
                    [mdir, mname, mext]=fileparts(modeldir{ax});
                    % RPE:
                    if ax~=2 && ax~=5;
                        animal(dx).(modeldir_corr{ax}).RPE.val=squeeze(model.logdata(:,7));
                    elseif ax==2 || ax==5;
                        animal(dx).(modeldir_corr{ax}).RPE.val=squeeze(model.logdata(:,8));
                    end
                    % Rew Code:
                    animal(dx).(modeldir_corr{ax}).Rew_code.val=squeeze(model.logdata(:,2));
                    % Odor Code:
                    animal(dx).(modeldir_corr{ax}).Odor.val=squeeze(model.logdata(:,3));                   
                    % Expectancies:
                    animal(dx).(modeldir_corr{ax}).Exp5_code.val=squeeze(model.logdata(:,5));
                    animal(dx).(modeldir_corr{ax}).Exp6_code.val=squeeze(model.logdata(:,6));
                    % Combined Expectancies:
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
                    animal(dx).(modeldir_corr{ax}).ExpAll_code.val=var_allexp;
                    
                    % Alpha:
                    if ax==2 || ax==5;
                        animal(dx).(modeldir_corr{ax}).Alpha.val=squeeze(model.logdata(:,7));
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOLD:
                    % load mean TC: tc_matrix_all
                    [tcdir, tcname, tcext]=fileparts(meantcdir{bx});
                    load([tcdir filesep tcname filesep ROI_name{cx} filesep 'correlation_tc_to_event_output.mat'])
                    % time bins:
                    for jx=1:size(tc_matrix_all,3);
                        animal(dx).(meantcdir_corr{bx}).(ROI_name_corr{cx}).BOLD.(['timebin_' num2str(jx)]).tc=squeeze(tc_matrix_all(dx,:,jx));
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BOLD:
                    % load _protocol_new.mat files
                    [fdir, fname, ext]=fileparts(Pfunc{dx});
                    load([protocol_new_dir filesep fdir(41:56) '_protocol_new.mat']);
                    
                    %% Using all rewarded/non-rewarded trials independent of post-licks
                    % tc values are saved in matrix_nonrew and matrix_rew;
                    % rows = trials, columns = frames
                    [fdir, fname, ext]=fileparts(Pfunc{dx});
                    regressors=load([fdir filesep 'regressors_motcsfFD_der.txt']);
                    FD=regressors(:,8);
                    Nfr=6;
                    TR=1.2;
                    odoronset_rew = ceil([events.fv_on_del5]/TR);
                    timeonset = [events.fv_on_del5];
                    
                    for i = 1:numel(odoronset_rew)
                        OnsetFrame_cur = odoronset_rew(i); % frame of odor exposition
                        if OnsetFrame_cur <= 1 % occured in onse sess ...
                            OnsetFrame_cur = 2;
                        end
                        Index_frames_cur = (OnsetFrame_cur-1):1:(OnsetFrame_cur+Nfr); % index
                        
                        % write tc values for current trial to matrix ...
                        matrix_FD(i,:) = FD(Index_frames_cur);
                        
                        TimeOnset_cur = timeonset(i);
                        for zx = 1:(Nfr+2);
                            matrix_licks(i,zx) =  sum(events(i).licks_del5>=(TimeOnset_cur+(zx-2)*TR) & events(i).licks_del5<=(TimeOnset_cur+(zx-1)*TR));
                        end
                        animal(dx).licks.ant_small(i) = sum(events(i).licks_del5>=(timeonset(i)+1.5) & events(i).licks_del5<=(timeonset(i)+2.7));
                        animal(dx).licks.ant_large(i) = sum(events(i).licks_del5>=(timeonset(i)+0.5) & events(i).licks_del5<=(timeonset(i)+2.7));
                        animal(dx).licks.post(i) = sum(events(i).licks_del5>(timeonset(i)+2.7) & events(i).licks_del5<=(timeonset(i)+4.7));
                    end
                    
                    % time bins:
                    for jx=1:size(tc_matrix_all,3);
                        animal(dx).FD.(['timebin_' num2str(jx)]).tc=squeeze(matrix_FD(:,jx)');
                        animal(dx).licks.(['timebin_' num2str(jx)]).tc=squeeze(matrix_licks(:,jx)');
                    end
                end
            end
        end
    end
    save([workingdir 'animalinfo.mat'],'animal')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Individual Figures
load([workingdir 'animalinfo.mat'],'animal')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

model_sel{1}='SigmaB';
model_sel{2}='Hybrid_bc';
model_sel{3}='AlphaStatic_2';
model_sel{4}='AlphaStatic_3';
model_sel{5}='Hybrid_bc_new';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% animal_selection: 21.11./22.11. --> valve off
if 1==0
    Pfunc(26:40)=[];
    animal(26:40)=[];
    animal_selection='_excludedValve'
else
    animal_selection='_all'
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



val_RPE_zero=0.2;

clear cc_REWall cc_REWpos cc_REWzero cc_REWneg cc_RPEall cc_RPEpos cc_RPEneg

% select preprocessing step
for ex=2%:length(preproc_sel);
    % select Carla's model 
    for dx=2%1:length(model_sel);
        % select region
        for cx=1%1:length(region_sel);
            % loop through the animals
            for ix=1:length(animal);%find(ppp>0.05)%1:length(animal);
                                
                close all;
                f1=figure('units','normalized','outerposition',[0 0 1 1]);
                
                for bx=1:8;
                    % sort RPE:
                    [val_sortRPE,indx_sortRPE]=sort(animal(ix).(model_sel{dx}).RPE.val);
                    % sort BOLD based on RPE:
                    val_sortBOLD=animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc(indx_sortRPE);
                    
                    clear val_mean_BOLD
                    for jx=1:(length(val_sortBOLD)-10);
                        val_mean_BOLD(jx)=mean(val_sortBOLD(jx:(10+jx)));
                    end;
                    
                    [cc_REWall(ix,bx),p_REWall(ix,bx)]=corr(animal(ix).(model_sel{dx}).Rew_code.val,animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc');
                    [cc_REWpos(ix,bx),p_REWpos(ix,bx)]=corr(animal(ix).(model_sel{dx}).RPE.val(animal(ix).(model_sel{dx}).Rew_code.val==1),animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc(animal(ix).(model_sel{dx}).Rew_code.val==1)');
                    [cc_REWzero(ix,bx),p_REWzero(ix,bx)]=corr(animal(ix).(model_sel{dx}).RPE.val(animal(ix).(model_sel{dx}).Rew_code.val==0),animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc(animal(ix).(model_sel{dx}).Rew_code.val==0)');
                    if strcmp(model_sel{dx},'AlphaStatic_3');
                        [cc_REWneg(ix,bx),p_REWneg(ix,bx)]=corr(animal(ix).(model_sel{dx}).RPE.val(animal(ix).(model_sel{dx}).Rew_code.val==-1),animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc(animal(ix).(model_sel{dx}).Rew_code.val==-1)');
                    end;
                    [cc_RPEall(ix,bx),p_RPEall(ix,bx)]=corr(animal(ix).(model_sel{dx}).RPE.val,animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc');
                    [cc_RPEpos(ix,bx),p_RPEpos(ix,bx)]=corr(animal(ix).(model_sel{dx}).RPE.val(animal(ix).(model_sel{dx}).RPE.val>val_RPE_zero),animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc(animal(ix).(model_sel{dx}).RPE.val>val_RPE_zero)');
                    [cc_RPEneg(ix,bx),p_RPEneg(ix,bx)]=corr(animal(ix).(model_sel{dx}).RPE.val(animal(ix).(model_sel{dx}).RPE.val<-val_RPE_zero),animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc(animal(ix).(model_sel{dx}).RPE.val<-val_RPE_zero)');
                    
                    [ccpar_RPEall(ix,bx),ppar_RPEall(ix,bx)]=partialcorr(animal(ix).(model_sel{dx}).RPE.val,animal(ix).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc',animal(ix).(model_sel{dx}).Rew_code.val);
                    
                    if 1==0;
                        subplot(4,3,bx);
                        
                        plot([(10/(length(val_sortBOLD)-10)):(10/(length(val_sortBOLD)-10)):10],val_mean_BOLD,'Color',[0.5 0.5 0.5],'LineWidth',0.5);
                        hold on;ll=line([(find(val_sortRPE==0,1)*10)/(length(val_sortBOLD)-10) (find(val_sortRPE==0,1)*10)/(length(val_sortBOLD)-10)],[-1.2 1.2]);ll.Color=[1 0 0];
                        hold on;
                        ll=line([1 find(val_sortRPE==0,1)*(10/(length(val_sortBOLD)-10))],[mean(val_sortBOLD(val_sortRPE<-val_RPE_zero)) mean(val_sortBOLD(val_sortRPE<-val_RPE_zero))]);ll.Color=[0 0 1];
                        hold on; ll=line([find(val_sortRPE==0,1)*(10/(length(val_sortBOLD)-10)) 10],[mean(val_sortBOLD(val_sortRPE>val_RPE_zero)) mean(val_sortBOLD(val_sortRPE>val_RPE_zero))]);ll.Color=[0 0 1];hold on;
                        
                        ax=gca;
                        ax.YLim=[-2 2];
                        ax.XLim=[0 10];
                        ax.XTick=[0,(find(val_sortRPE==0,1)*10)/(length(val_sortBOLD)-10),10];
                        ax.XTickLabel=[round(val_sortRPE(1),1) round(0,1) round(val_sortRPE(end),1)];
                        ax.XLabel.String='RPE';
                        ax.YLabel.String='BOLD (detr., z-transformed)';
                        ax.YTick=[-1:0.25:1];
                        ax.YTickLabel=[-1:0.25:1];
                        ax.FontSize=6;
                        
                        title(['Time Bin ' num2str(bx)]);
                        legend%({'aa','bb','cb'},'Location','bestfit')
                    end
                    
                end
                
                if 1==0;
                    subplot(4,3,10:11);
                    plot(cc_REWall(ix,:),'Color',[0 0 0],'LineWidth',1,'LineStyle','--');
                    hold on; plot(cc_REWpos(ix,:),'Color',[0 0.7 0.5],'LineWidth',1,'LineStyle','--');
                    hold on; plot(cc_REWzero(ix,:),'Color',[0 0.2 0.5],'LineWidth',1,'LineStyle','--');
                    if strcmp(model_sel{dx},'AlphaStatic_3');
                        hold on; plot(cc_REWneg(ix,:),'Color',[0 0 1],'LineWidth',1,'LineStyle','--');
                    end
                    hold on; plot(cc_RPEall(ix,:),'Color',[1 0 0],'LineWidth',1.5);
                    hold on; plot(cc_RPEpos(ix,:),'Color',[1 0.5 0],'LineWidth',1.5);
                    hold on; plot(cc_RPEneg(ix,:),'Color',[1 1 0],'LineWidth',1.5);
                    if strcmp(model_sel{dx},'AlphaStatic_3');
                        legend({'cc REWtoBOLD','cc RPEtoBOLD (REW=1)','cc RPEtoBOLD (REW=0)','cc RPEtoBOLD (REW=-1)','cc RPEtoBOLD',['cc RPEtoBOLD (RPE>' num2str(val_RPE_zero) ')'],['cc RPEtoBOLD (RPE<-' num2str(val_RPE_zero) ')'],'ccpar RPEtoBOLD','cc high exp','cc low exp'},'Interpreter','none','Location','bestoutside','FontSize',6);
                    else
                        legend({'cc REWtoBOLD','cc RPEtoBOLD (REW=1)','cc RPEtoBOLD (REW=0)','cc RPEtoBOLD',['cc RPEtoBOLD (RPE>' num2str(val_RPE_zero) ')'],['cc RPEtoBOLD (RPE<-' num2str(val_RPE_zero) ')'],'ccpar RPEtoBOLD','cc high exp','cc low exp'},'Interpreter','none','Location','bestoutside','FontSize',6);
                    end
                    
                    hold on; plot(ccpar_RPEall(ix,:),'Color',[0 1 0],'LineWidth',1.5);
                    
                    axis=gca;
                    axis.YLabel.String='Corr.Coeff';
                    
                    axis.XLim=[1,8]
                    axis.XTick=[1.5:1:7.5];
                    axis.XTickLabel=[0:1.2:8.4];
                    axis.XLabel.String='Time [s]';
                    axis.FontSize=6;
                    
                    title(['correlation coefficient BOLD to RPE :' region_sel{cx}]);
                    supt=suptitle([animal(ix).name ' ' region_sel{cx}]);
                    
                    print('-dpsc',fullfile(outputdir,[region_sel{cx} '_individual_CORR_' preproc_sel{ex} '.ps']) ,'-r200','-append','-bestfit');
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % INDIVIDUAL SCATTERPLOTS
            if 1==0;
                for ax=1:83;
                    f1=figure('units','normalized','outerposition',[0 0 1 1]);
                    for jx=1:8;
                        subplot(2,4,jx);
                        clear sc ll1 ll2 axis
                        sc=scatter(animal(ax).(model_sel{dx}).RPE.val',animal(ax).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(jx)]).tc',3,'filled');
                        sc.MarkerEdgeColor=[0 0 0.2];
                        sc.MarkerFaceColor=[0 0 0.2];
                        hold on;
                        ll1=line([0 1],[mean(animal(ax).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(jx)]).tc(animal(ax).(model_sel{dx}).RPE.val>val_RPE_zero)) mean(animal(ax).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(jx)]).tc(animal(ax).(model_sel{dx}).RPE.val>val_RPE_zero))]);
                        ll1.Color=[1 0 0];
                        hold on;
                        ll2=line([-1 0],[mean(animal(ax).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(jx)]).tc(animal(ax).(model_sel{dx}).RPE.val<-val_RPE_zero)) mean(animal(ax).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(jx)]).tc(animal(ax).(model_sel{dx}).RPE.val<-val_RPE_zero))]);
                        ll2.Color=[1 0 0];
                        axis=gca;
                        axis.YLim=[-4 4];
                        axis.YLabel.String=['% BOLD sign. (detr./z-transf.)'];
                        axis.FontSize=6;
                        axis.XLabel.String=['RPE'];
                        title(['timebin_' num2str(jx)],'Interpreter','none');
                    end
                    supt=suptitle([animal(ax).name ' ' region_sel]);
                    supt.Interpreter='none';
                    set(gcf, 'InvertHardcopy', 'off')
                    print('-dpsc',fullfile(outputdir,[region_sel '_individual_scatter_' preproc_sel '.ps']) ,'-r200','-append','-bestfit');
                    close all;
                end
            end
            
            
            %%
            if 1==1
                
                vec_sum=[];
                %         for ax=[1:51 54:60 63:66 68:73 75 77:83];%
                %     for ax=[1 13 20 8 13 21]%
                for ax=1:length(animal)%
                    vec_sum1=[animal(ax).(model_sel{dx}).RPE.val'];
                    for bx=1:8;
                        vec_sum1=[vec_sum1;[animal(ax).(preproc_sel{ex}).(region_sel{cx}).BOLD.(['timebin_' num2str(bx)]).tc]];
                    end
                    vec_sum1=[vec_sum1;[animal(ax).(model_sel{dx}).Rew_code.val']];
                    vec_sum=[vec_sum,vec_sum1];
                end;
                %
                %     for jx=1:8;
                %         [cc_REWall(jx),p_REWall(jx)]=corr(vec_sum(10,:)',vec_sum(1+jx,:)');
                %         [cc_REWpos(jx),p_REWpos(jx)]=corr(vec_sum(1,(vec_sum(10,:)==1))',vec_sum(1+jx,(vec_sum(10,:)==1))');
                %         [cc_REWzero(jx),p_REWzero(jx)]=corr(vec_sum(1,(vec_sum(10,:)==0))',vec_sum(1+jx,(vec_sum(10,:)==0))');
                %         if strcmp(model_sel{dx},'AlphaStatic_3');
                %             [cc_REWneg(jx),p_REWneg(jx)]=corr(vec_sum(1,(vec_sum(10,:)==-1))',vec_sum(1+jx,(vec_sum(10,:)==-1))');
                %         end;
                %         [cc_RPEall(jx),p_RPEall(jx)]=corr(vec_sum(1,:)',vec_sum(1+jx,:)');
                %         [cc_RPEpos(jx),p_RPEpos(jx)]=corr(vec_sum(1,(vec_sum(1,:)>0))',vec_sum(1+jx,(vec_sum(1,:)>0))');
                %         [cc_RPEneg(jx),p_RPEneg(jx)]=corr(vec_sum(1,(vec_sum(1,:)<-val_RPE_zero))',vec_sum(1+jx,(vec_sum(1,:)<-val_RPE_zero))');
                %     end
                
                f9=figure('units','normalized','outerposition',[0 0 1 1]);
                
                for ix=5%1:8;
                    clear val_sortBOLD val_sortRPE vec_sum_temp val_mean_BOLD
                    % sort RPE:
                    [val_sortRPE_orig,indx_sortRPE]=sort(vec_sum(1,:));
                    % sort BOLD based on RPE:
                    val_sortBOLD=vec_sum(ix+1,indx_sortRPE)
%                     % without zero
                    if 1==1;
                        val_sortRPE=val_sortRPE_orig(val_sortRPE_orig~=0);%.2 | val_sortRPE<=-0.2);
                        val_sortBOLD=val_sortBOLD(val_sortRPE_orig~=0);%.2 | val_sortRPE<=-0.2);
                        vec_sum_temp=vec_sum(:,(val_sortRPE_orig~=0));%.2 | val_sortRPE<=-0.2));
                    else 
                        vec_sum_temp=vec_sum;
                    end
                    for jx=1:(length(vec_sum_temp)-400); val_mean_BOLD(jx)=mean(val_sortBOLD(jx:(400+jx))); end;
                    
                    %         for jx=1:(6900-400); val_mean_BOLD(jx)=mean(val_sortBOLD(jx:(400+jx))); end;
                    %         for jx=7400:(length(vec_sum_temp)-400); val_mean_BOLD_2(jx)=mean(val_sortBOLD(jx:(400+jx))); end;
                    %         figure; plot([1:5820],val_mean_BOLD(1:5820)); hold on; plot([6600:length(val_mean_BOLD_2)],val_mean_BOLD_2(6600:end),'r');hold on;
                    %         line([1 5820],[mean(val_mean_BOLD(1:5820)) mean(val_mean_BOLD(1:5820))]);hold on;
                    %         line([6600 length(val_mean_BOLD_2)],[mean(val_mean_BOLD_2(6600:end)) mean(val_mean_BOLD_2(6600:end))]);hold on;
                    
                    subplot(4,3,ix);
                    
                    plot([(40/(length(vec_sum_temp)-400)):(40/(length(vec_sum_temp)-400)):40],val_mean_BOLD,'Color',[0.5 0.5 0.5],'LineWidth',0.5); hold on;
                    ll=line([(find(val_sortRPE>-val_RPE_zero,1)*40)/(length(vec_sum_temp)-400) (find(val_sortRPE>-val_RPE_zero,1)*40)/(length(vec_sum_temp)-400)],[-1.2 1.2]);ll.Color=[1 0 0];hold on;
                    ll=line([(find(val_sortRPE>val_RPE_zero,1)*40)/(length(vec_sum_temp)-400) (find(val_sortRPE>val_RPE_zero,1)*40)/(length(vec_sum_temp)-400)],[-1.2 1.2]);ll.Color=[1 0 0];hold on;
                    ll=line([1 find(val_sortRPE>-val_RPE_zero,1)*(40/(length(vec_sum_temp)-400))],[mean(val_sortBOLD(val_sortRPE<-val_RPE_zero)) mean(val_sortBOLD(val_sortRPE<-val_RPE_zero))]);ll.Color=[0 0 1];hold on;
                    ll=line([find(val_sortRPE>val_RPE_zero,1)*(40/(length(vec_sum_temp)-400)) 40],[mean(val_sortBOLD(val_sortRPE>val_RPE_zero)) mean(val_sortBOLD(val_sortRPE>val_RPE_zero))]);ll.Color=[0 0 1];hold on;
                    plot([(40/(length(vec_sum_temp))):(40/(length(vec_sum_temp))):40],val_sortRPE,'Color',[1 0.5 0],'LineWidth',0.5); hold on;
                    %         gauss_1=fit([(40/(length(vec_sum_temp)-400)):(40/(length(vec_sum_temp)-400)):40]',val_mean_BOLD','gauss4')
                    %         plot(gauss_1)
                    
                    ax=gca;
                    ax.YLim=[-1.2 -0.2];%2 1.2];
                    ax.XLim=[0 40];
                    ax.XTick=[0,(find(val_sortRPE==0,1)*40)/(length(vec_sum_temp)-400),40];
                    ax.XTickLabel=[round(val_sortRPE(1),1) round(0.0,1) round(val_sortRPE(end),1)];
                    ax.XLabel.String='RPE';
                    ax.YLabel.String='BOLD (detr., z-transformed)';
                    ax.YTick=[-1.2:0.2:1.2];
                    ax.YTickLabel=[-1.2:0.2:1.2];
                    ax.FontSize=6;
                    
                    title(['Time Bin ' num2str(ix)]);
                    legend%({'aa','bb','cb'},'Location','bestfit')
                end
                
                
                %     nbp=notBoxPlot(cc_REWall)
                %     for sz=1:size(cc_REWall,2);
                %         nbp(sz).data.MarkerSize=1;
                %     end
                
                
                subplot(4,3,10:11);
                plot(nanmean(cc_REWall),'Color',[0 0 0],'LineWidth',1,'LineStyle','--');
                hold on; plot(nanmean(cc_REWpos),'Color',[0 0.7 0.5],'LineWidth',1,'LineStyle','--');
                hold on; plot(nanmean(cc_REWzero),'Color',[0 0.2 0.5],'LineWidth',1,'LineStyle','--');
                if strcmp(model_sel{dx},'AlphaStatic_3');
                    hold on; plot(nanmean(cc_REWneg),'Color',[0 0 1],'LineWidth',1,'LineStyle','--');
                end
                hold on; plot(nanmean(cc_RPEall),'Color',[1 0 0],'LineWidth',1);
                hold on; plot(nanmean(cc_RPEpos),'Color',[1 0.5 0],'LineWidth',1);
                hold on; plot(nanmean(cc_RPEneg),'Color',[1 1 0],'LineWidth',1);
                
                hold on; plot(nanmean(ccpar_RPEall),'Color',[0 1 0],'LineWidth',1);
                
                if strcmp(model_sel{dx},'AlphaStatic_3');
                    legend({'cc REWtoBOLD','cc RPEtoBOLD (REW=1)','cc RPEtoBOLD (REW=0)','cc RPEtoBOLD (REW=-1)','cc RPEtoBOLD',['cc RPEtoBOLD (RPE>' num2str(val_RPE_zero) ')'],['cc RPEtoBOLD (RPE<-' num2str(val_RPE_zero) ')'],'ccpar RPEtoBOLD','cc high exp','cc low exp'},'Interpreter','none','Location','bestoutside','FontSize',6);
                else
                    legend({'cc REWtoBOLD','cc RPEtoBOLD (REW=1)','cc RPEtoBOLD (REW=0)','cc RPEtoBOLD',['cc RPEtoBOLD (RPE>' num2str(val_RPE_zero) ')'],['cc RPEtoBOLD (RPE<-' num2str(val_RPE_zero) ')'],'ccpar RPEtoBOLD','cc high exp','cc low exp'},'Interpreter','none','Location','bestoutside','FontSize',6);
                end
                axis=gca;
                axis.YLabel.String='Corr.Coeff';
                axis.XLim=[1,8]
                axis.XTick=[1.5:1:7.5];
                axis.XTickLabel=[0:1.2:8.4];
                axis.XLabel.String='Time [s]';
                
                
                tt=title(['correlation coefficient BOLD to RPE: ' region_sel{cx} ' ' model_sel{dx} ' ' preproc_sel{ex}],'Interpreter','none');
                tt.FontSize=8;
                
                supt=suptitle(['BOLD to RPE: ' region_sel{cx} ' ' model_sel{dx} ' ' preproc_sel{ex}])
                supt.Interpreter='none';
                print('-dpsc',fullfile(outputdir,[region_sel{cx} animal_selection '_CORR.ps']) ,'-r200','-append','-bestfit');
            end
        end
    end
end




