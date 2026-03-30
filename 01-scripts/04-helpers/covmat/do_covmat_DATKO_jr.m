if 1==1
    load('/home/jonathan.reinwald/DATKO/data/MRI_data/pathlist_DATKO.mat');
end
cd('/home/jonathan.reinwald/DATKO/analyses/functional_analyses/covmat/SIGMA_atlas_unilateral/');


%-------------- create covmat -------------------------------------------

% predefinition of path, EPIs and atlas
fpath='/home/jonathan.reinwald/DATKO/data/MRI_data/pvconverted_data'

% EPI selection
Pcur=char(spm_select('ExtFPlistrec',fpath,['^bpm_0.01_0.1_scrub_X2_spline_regfilt_motcsf_rswraaztec_or0_u.*._c1_reorient2.nii'],1));

% Atlas selection
% Patlas='/home/jonathan.reinwald/DATKO/helpers/atlas/SIGMA_Wistar_Rat_Brain_TemplatesAndAtlases_Version1/SIGMA_Rat_Brain_Atlases/SIGMA_Anatomical_Atlas/SIGMA_Anatomical_Brain_Atlas_Version1_reorient_jr_merged.nii';
% Ptxt='/home/jonathan.reinwald/DATKO/helpers/atlas/SIGMA_Wistar_Rat_Brain_TemplatesAndAtlases_Version1/SIGMA_Rat_Brain_Atlases/SIGMA_Anatomical_Atlas/SIGMA_Anatomical_Brain_Atlas_Version1_reorient_jr_merged_noCerebellum.txt';
Patlas='/home/jonathan.reinwald/DATKO/helpers/atlas_creation/unilateral_atlas/SIGMA_atlas_JR_unilateral.nii'
Ptxt='/home/jonathan.reinwald/DATKO/helpers/atlas_creation/unilateral_atlas/SIGMA_atlas_JR_unilateral_noCerebBS.txt'
% create working directory
[fpath fname_cur ext]=fileparts(deblank(Pcur(1,:)));
[fpath fname_atl ext]=fileparts(Ptxt);
% mkdir(pwd,[fname_atl '_' fname_cur]);
% cd([pwd filesep fname_atl '_' fname_cur])
% Names selection
% load names_110.mat names
load /home/jonathan.reinwald/DATKO/helpers/atlas_creation/unilateral_atlas/names_120.mat names

if 1==1
    [cormat subj]=wwf_covmat_hres_jr(Ptxt,Pcur,Patlas);
    
    save cormat cormat
    save roidata subj
end

% --------------- plot matrices to ps file ---------------------
load cormat cormat
if 1==1
    for ix=1:size(cormat,2);
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^bpm_0.01_0.1_scrub_X2_spline_regfilt_motcsf_rswraaztec_or0_u.*._c1_reorient2.nii'],1);%bpm_0.01_0.1_scrub_0.05_lin_
        rb_mtxplot2file(cormat{ix},names,[pwd filesep 'cormat_all.ps'],Pcur)
    end
end




if 1==0
    load cormat%_ROIs_ICA_62
    %load names_sorted_62.mat names idx
    %cormat=cormat_ICA
    load names_sorted.mat names idx
    % load /home/jonathan.reinwald/Output/2016_12_TTA/Oatp1c1_Mct8_dko/functional/cormat/cormat_bpm_0.01_0.1_scrub_0.05_lin_regfilt_motcsfgs/roidata.mat subj
end
%sorting of matrices
if 1==0;
    for ix=1:size(cormat,2);
        cormat{1,ix}=cormat{1,ix}(idx,idx)
    end;
end;

% z=ones(62,1);
% for ix=[5 31 32 33 34];
%     z(ix)=0;
% end;
% z=logical(z);
% if 1==1;
%     for jx=1:size(cormat,2);
%         cormat{1,jx}=cormat{1,jx}(z,z)
%     end;
% end;
% %
% names=names(z);

% if 1==1;
%     for ix=1:size(Pfunc,2);
%         cormat{1,ix}=cormat{1,ix}./max(max(triu(cormat{1,ix},1)))
%         %mean(mean(cormat{1,1}(cormat{1,1}<1)))
%     end;
% end;%


% --------------------- ttest plus plot ---------------------------------
% load /home/jonathan.reinwald/Output/2016_12_TTA/Oatp1c1_Mct8_dko/functional/cormat/cormat_bpm_0.01_0.1_regfilt_motcsfgs/names_abrev.mat names
if 1==0
    gr(1,:)=([1 2 1 1 2 1 1 2 1 1 2 2 1 1 2 2 2 1 2 1 3 4 4 2 1 3 3 4 4 3 3 4 3 3 4 4 3 3 3 4 3 4 4 6 6 5 5 4 5 5 6 6 5 6 5 6 6 5 6 5 6 6 5 6 6 5 5]);
    %%Motion:
    %DVARS: eclude animal # 54
    gr(1,54)=0;
    %gr=gr(find(gr));
    %FD: exclude animal # 5,14,20,27,35,37,41,47,54,64
    %%Atlas: 'red matrices'
    % 16,27,35,46 (to discuss: 17)
    gr(1,[16,27,46])=0;
    
    gr_name{1}={'22q11-del','22q11-WT','1q21-del','1q21-WT','15q13-del','15q13-WT','all_X2_DVARS_Nichols'};
    %gr_name{2}={'22q11-del','22q11-WT','1q21-del','1q21-WT','15q13-del','15q13-WT','all_X2_DVARS_Nichols'};
    %     gr_name{3}={'22q11-del','22q11-WT','1q21-del','1q21-WT','15q13-del','15q13-WT','<10%'};
    for hx=1:size(gr,1);
        kx=0
        for ix=[1,3,5]%1:5;
            input1=cormat(gr(hx,:)==ix)
            for jx=ix+1%(ix+1):6;
                fpath='/home/jonathan.reinwald/Output/CNV_jr/functional/cormat/Atlas_280218_cormat_bpm_0.01_0.1_scrub_X2_lin_regfilt_motcsf/';
                input2=cormat(gr(hx,:)==jx)
                [T p p2 fdrmat meanval stdab]=lei_ttest2(input1,input2,0.05,0);
                kx=kx+1;
                figure(hx*10+1)
                mk_subplot_fdr_jr
                figure(hx*10+3)
                mk_plot_fdr_jr
                outname3=[gr_name{1,hx}{1,7} '_animals_summary_FDR_5.ps']
                print(figure(hx*10+3),outname3,'-dpsc','-r600','-append')
                saveas (figure(hx*10+3),[fpath 'Figures/' [gr_name{1,hx}{1,size(gr_name{1,hx},2)} '_FDR_' gr_name{1,hx}{1,ix} '_vs_' gr_name{1,hx}{1,jx}]],'tif');
                
                figure(hx*10+2)
                mk_subplot2_jr
                figure(hx*10+4)
                mk_plot2_jr
                outname4=[gr_name{1,hx}{1,7} '_animals_summary_noFDR_5.ps']
                print(figure(hx*10+4),outname4,'-dpsc','-r600','-append')
                saveas (figure(hx*10+4),[fpath 'Figures/' [gr_name{1,hx}{1,size(gr_name{1,hx},2)} '_noFDR_' gr_name{1,hx}{1,ix} '_vs_' gr_name{1,hx}{1,jx}]],'tif');
                
            end;
        end;
        set(figure(hx*10+1),'Position',get( 0, 'Screensize' ));
        outname1=[gr_name{1,hx}{1,7} '_animals_summary_FDR_5.tif']
        %saveas(figure(hx*10+1),outname1)
        print(outname1,'-dpng','-r600')
        close(gcf)
        set(figure(hx*10+2),'Position',get( 0, 'Screensize' ));
        outname2=[gr_name{1,hx}{1,7} '_animals_summary_noFDR_5.tif']
        print(outname2,'-dpng','-r600')
        close(gcf)
        %saveas(figure(hx*10+2),outname2)
    end;
end;
close all


if 1==0
    gr(1,:)=([1 2 1 1 2 1 1 2 1 1 2 2 1 1 2 2 2 1 2 1 3 2 2 2 1 3 3 2 2 3 3 2 3 3 2 2 3 3 3 2 3 2 2 2 2 4 4 2 4 4 2 2 4 0 4 2 2 4 2 4 2 2 4 2 2 4 4]);
    gr_name{1}={'22q11-del','WT','1q21-del','15q13-del','all_X2_DVARS_Nichols_WTsummarized'};
    for hx=1:size(gr,1);
        kx=0
        for ix=1:3;
            input1=cormat(gr(hx,:)==ix)
            for jx=(ix+1):4;
                fpath='/home/jonathan.reinwald/Output/CNV_jr/functional/cormat/Bihemispheric_Atlas_07032018_cormat_bpm_0.01_0.1_regfilt_motcsfgs/';
                input2=cormat(gr(hx,:)==jx)
                [T p p2 fdrmat meanval stdab]=lei_ttest2(input1,input2,0.05,0);
                kx=kx+1;
                figure(hx*10+1)
                mk_subplot_fdr_jr
                figure(hx*10+3)
                mk_plot_fdr_jr
                outname3=[gr_name{1,hx}{1,5} '_animals_summary_FDR_ALL_WTsummarized.ps']
                print(figure(hx*10+3),outname3,'-dpsc','-r600','-append')
                saveas (figure(hx*10+3),[fpath 'Figures/' [gr_name{1,hx}{1,size(gr_name{1,hx},2)} '_FDR_' gr_name{1,hx}{1,ix} '_vs_' gr_name{1,hx}{1,jx}]],'tif');
                
                figure(hx*10+2)
                mk_subplot2_jr
                figure(hx*10+4)
                mk_plot2_jr
                outname4=[gr_name{1,hx}{1,5} '_animals_summary_noFDR_ALL_WTsummarized.ps']
                print(figure(hx*10+4),outname4,'-dpsc','-r600','-append')
                saveas (figure(hx*10+4),[fpath 'Figures/' [gr_name{1,hx}{1,size(gr_name{1,hx},2)} '_noFDR_' gr_name{1,hx}{1,ix} '_vs_' gr_name{1,hx}{1,jx}]],'tif');
                
            end;
        end;
        set(figure(hx*10+1),'Position',get( 0, 'Screensize' ));
        outname1=[gr_name{1,hx}{1,5} '_animals_summary_FDR_WTsummarized.tif']
        %saveas(figure(hx*10+1),outname1)
        print(outname1,'-dpng','-r600')
        close(gcf)
        set(figure(hx*10+2),'Position',get( 0, 'Screensize' ));
        outname2=[gr_name{1,hx}{1,5} '_animals_summary_noFDR_WTsummarized.tif']
        print(outname2,'-dpng','-r600')
        close(gcf)
        %saveas(figure(hx*10+2),outname2)
    end;
end;

%--------------- smooth----------------------------------------

if 1==0
    for ix=1:size(Pfunc,1);
        [fdir fname ext]=fileparts(Pfunc{ix});
        Pfuncall=spm_select('ExtFPlist',fdir,[fname '.nii'],[1:1000]);
        job_smooth8
        matlabbatch{1}.spm.spatial.smooth.data=cellstr(Pfuncall);
        spm_jobman('run',matlabbatch);
    end
end



