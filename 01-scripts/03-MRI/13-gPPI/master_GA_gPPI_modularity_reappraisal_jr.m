clear all;
clc;
close all;

PPI_dir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/combined_hemisphere/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/PPI_files'
PPI_files=spm_select('FPList',PPI_dir,'^PPI_.*.mat');

load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/12-gPPI/combined_hemisphere/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/roidata.mat');
names={subj(1).roi.name};

selection_name{1}='Odor11to40';
selection_name{2}='Odor81to120';
selection_name{3}='TPnoPuff11to40';
selection_name{4}='TPnoPuff81to120';

%% Loop over regions   
M1_all=[];Q1_all=[];
M2_all=[];Q2_all=[];
M3_all=[];Q3_all=[];
M4_all=[];Q4_all=[];


%% Loop over animals
for animal_idx=1:size(PPI_files,1)
    % load PPI
    load(deblank(PPI_files(animal_idx,:)));
    
    %% Loop over the four time point
    for tp_idx = 1:4
               
        if tp_idx==1
            % calculation
            W=squeeze(PPI_beta(:,:,2));
            for ix=1:100 
                [M1(ix,:),Q1(ix)]=community_louvain(W,[],[],'negative_asym'); 
%                 [M1(ix,:),Q1(ix)]=modularity_dir(W,1);
            end
            D1_test(animal_idx,:,:)=agreement(M1');
            M1_all=[M1_all;M1];
            Q1_all=[Q1_all;Q1];
                        
        elseif tp_idx==2
            % calculation
            W=squeeze(PPI_beta(:,:,5));
            for ix=1:100
                [M2(ix,:),Q2(ix)]=community_louvain(W,[],[],'negative_asym');
%                 [M2(ix,:),Q2(ix)]=modularity_dir(W,1);
            end
            D2_test(animal_idx,:,:)=agreement(M2');
            M2_all=[M2_all;M2];
            Q2_all=[Q2_all;Q2];
            
        elseif tp_idx==3
            % calculation
            W=squeeze(PPI_beta(:,:,7));
            for ix=1:100
                [M3(ix,:),Q3(ix)]=community_louvain(W,[],[],'negative_asym');
%                 [M3(ix,:),Q3(ix)]=modularity_dir(W,1);
            end
            D3_test(animal_idx,:,:)=agreement(M3');
            M3_all=[M3_all;M3];
            Q3_all=[Q3_all;Q3];
            
        elseif tp_idx==4
            % calculation
            W=squeeze(PPI_beta(:,:,10));
            for ix=1:100
                [M4(ix,:),Q4(ix)]=community_louvain(W,[],[],'negative_asym');
%                 [M4(ix,:),Q4(ix)]=modularity_dir(W,1);
            end
            D4_test(animal_idx,:,:)=agreement(M4');
            M4_all=[M4_all;M4];
            Q4_all=[Q4_all;Q4];
        end
    end
end

D1=agreement(M1_all');
D2=agreement(M2_all');
D3=agreement(M3_all');
D4=agreement(M4_all');

figure; 
subplot(2,2,1); imagesc(D1);ax=gca; ax.XTick=[1:52]; ax.YTick=[1:52]; ax.XTickLabel=names; ax.YTickLabel=names; rotateXLabels(ax,90);
subplot(2,2,2); imagesc(D2);ax=gca; ax.XTick=[1:52]; ax.YTick=[1:52]; ax.XTickLabel=names; ax.YTickLabel=names; rotateXLabels(ax,90);
subplot(2,2,3); imagesc(D3);ax=gca; ax.XTick=[1:52]; ax.YTick=[1:52]; ax.XTickLabel=names; ax.YTickLabel=names; rotateXLabels(ax,90);
subplot(2,2,4); imagesc(D4);ax=gca; ax.XTick=[1:52]; ax.YTick=[1:52]; ax.XTickLabel=names; ax.YTickLabel=names; rotateXLabels(ax,90);


