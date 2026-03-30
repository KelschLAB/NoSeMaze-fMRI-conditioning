
studydir='/home/jonathan.reinwald/Awake/fmri_data/'; cd(studydir)
outputdir='/home/jonathan.reinwald/Awake/tc_to_RPE_correlation/';

% for loop over all sessions ...
load([studydir filesep 'filelist_awake_MAIN_JR.mat'], 'Pfunc');


odoronset_all=[];
RPE_all=[];
Drop_or_not_all=[];
counter_frame=0;

for ix=1:83;
    
    [fdir, fname, ext]=fileparts(Pfunc{ix});
    TR = 1.2;
    load(['/home/jonathan.reinwald/Awake/behavioral_data/MRTprediction/fMRI_new_mat_sorted/' fname(1:11) '_' fdir(53:56) '_protocol_new.mat']);
    
    % define number of frames you want to add to the odor volume for analysis per trial ...
    Nfr = 6;
    
    %% Using all rewarded/non-rewarded trials independent of post-licks
    % tc values are saved in matrix_nonrew and matrix_rew;
    % rows = trials, columns = frames
    odoronset = ceil([events.fv_on_del5]/TR);
    odoronset_all=[odoronset_all,counter_frame + odoronset];
    if ix == 1;
        counter_frame = counter_frame+1595;
    elseif ix ~=1;
        counter_frame = counter_frame+1545;
    end;
    
    load(['/home/jonathan.reinwald/Awake/RLModel/MLE_Pav_Gauss_Hybrid_bc/RLM_OdorID_' num2str(ix) '.mat']);
    RPE_all=[RPE_all,model.logdata(:,8)'];
    Drop_or_not_all=[Drop_or_not_all,[events.drop_or_not]];
    
end

% load('/home/jonathan.reinwald/Awake/fmri_data/ICA_denoising/ica25_08-Feb-2020/ICA_results_allsubj_ica25.mat');

for jx=1:9;
    for ix=1:size(icasig,1);
        clear tc;
        tc=icasig(ix,:);
        %% modify tc ...
        
        % detrend data ...
        tc_detr = detrend(tc);
        
        % normalize data ..
        tc_detr_norm = zscore(tc_detr);
        
        Index_frames = odoronset_all;
        
        [coef_RPE(ix,jx),p_RPE(ix,jx)]=corr(tc(Index_frames+(jx-1))',RPE_all');
        [coef_Drop(ix,jx),p_Drop(ix,jx)]=corr(tc(Index_frames+(jx-1))',Drop_or_not_all');
        mean_1(ix,jx)=mean(tc(Index_frames+(jx-1))');
    end;
end;


f1=figure; 
subplot(3,2,1); imagesc(coef_RPE.*(p_RPE<(0.05/(25*9)))); 
ax=gca; ax.XTick=[0.5:1:9.5];ax.XTickLabel=[-1.2:1.2:9.6];ax.XLabel.String='Time';ax.XLim=[1.5, 9.5]
ax.YLabel.String='Component';ax.CLim=[-0.1 0.1];colorbar;
subplot(3,2,2); imagesc(-log(p_RPE).*(p_RPE<(0.05/(25*9))));
ax=gca; ax.XTick=[0.5:1:9.5];ax.XTickLabel=[-1.2:1.2:9.6];ax.XLabel.String='Time';ax.XLim=[1.5, 9.5]
ax.YLabel.String='Component';ax.CLim=[0 50];colorbar;
subplot(3,2,3); imagesc(coef_Drop); subplot(3,2,4); imagesc(-log(p_Drop).*(p_Drop<0.005));
subplot(3,2,5); imagesc(mean_1);

f2=figure; 
imagesc(ccicre_sessmean_abs); ax=gca; ax.XTick=[1:20];ax.XTickLabel={'RP1','RP2','RP3','RP4','RP5','RP6','dRP1','dRP2','dRP3','dRP4','dRP5','dRP6','CSF','GS','mean allcorr','max allcorr','mean RP','max RP','mean RPder','max RPder'};
rotateXLabels(ax,45);ax.CLim=[-0.2 0.5]; colorbar





