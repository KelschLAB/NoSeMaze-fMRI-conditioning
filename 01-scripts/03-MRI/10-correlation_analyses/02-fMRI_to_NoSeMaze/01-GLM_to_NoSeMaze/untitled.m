clear all
clc


%% Load regressors of interest
% Social hierarchy with David's Score
ExplVar(1).name = 'DS';
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/01-AM1/01-tubetest/DS_info_AM1_day1to16.mat','DS_info');
DS_info1 = DS_info;
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/01-AM/02-AM2/01-tubetest/DS_info_AM2_day1to14.mat','DS_info');
DS_info2 = DS_info;
ExplVar(1).values = [[DS_info1.DS]';[DS_info2.DS]'];
ExplVar(1).ID = [[DS_info1.ID];[DS_info2.ID]];

ExplVar(2).name = 'DS_zscored';
ExplVar(2).values = [zscore([DS_info1.DS])';zscore([DS_info2.DS])'];
ExplVar(2).ID = [[DS_info1.ID];[DS_info2.ID]];

ExplVar(3).name = 'Rank';
[~,Idx1]=sort([DS_info1.DS]);
[~,Rank1]=sort(Idx1);
[~,Idx2]=sort([DS_info2.DS]);
[~,Rank2]=sort(Idx2);
ExplVar(3).values = [Rank1';Rank2'];
ExplVar(3).ID = [[DS_info1.ID];[DS_info2.ID]];

% define ID and Animal numb for all regressors
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/11-correlation_to_NoSeMaze/AnimalNumb_to_ID.mat');
for ix=1:length(ExplVar)
    for jx=1:length(ExplVar(ix).ID)
        ExplVar(ix).AnimalNumb(jx,1) = AnimalNumb_to_ID(strcmp([AnimalNumb_to_ID.ID],ExplVar(ix).ID(jx))).AnimalNumb;
    end
end

%% 
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/maskdeactivationT001rank/tc_matrsess_all_BINS6_TRsbefore2.mat');

[~,Idx]=sort(tc_matrsess_info.AnimalNumb);
tc_matrsess_all=tc_matrsess_all(Idx,:,:);
tc_matrsess_all_highres=tc_matrsess_all_highres(Idx,:,:);
tc_matrsess_all_highres_lin=tc_matrsess_all_highres_lin(Idx,:,:);
tc_matrsess_all_highres_spline=tc_matrsess_all_highres_spline(Idx,:,:);

[~,Idx]=sort(ExplVar(3).AnimalNumb);
myRanks=ExplVar(3).values(Idx);

[RanksSorted,Idx]=sort(myRanks);
tc_matrsess_all=tc_matrsess_all(Idx,:,:);
tc_matrsess_all_highres=tc_matrsess_all_highres(Idx,:,:);
tc_matrsess_all_highres_lin=tc_matrsess_all_highres_lin(Idx,:,:);
tc_matrsess_all_highres_spline=tc_matrsess_all_highres_spline(Idx,:,:);

clear myMat
% myMat = squeeze(mean(tc_matrsess_all_highres_lin(:,[81:120],:),2))-squeeze(mean(tc_matrsess_all_highres_lin(:,[1:40],:),2));
myMat = squeeze(mean(tc_matrsess_all(:,[81:120],:),2))-squeeze(mean(tc_matrsess_all(:,[11:40],:),2));

% for ix=1:size(myMat,2)
%     myMat_s(:,ix)=smooth(myMat(:,ix),3);
% end

for ix=1:24
    myMat_s(ix,:)=myMat(ix,:)-mean(myMat(ix,1:4));
end
figure; imagesc(myMat_s);
colormap('jet');ax=gca;ax.CLim=[-.6,.6];

