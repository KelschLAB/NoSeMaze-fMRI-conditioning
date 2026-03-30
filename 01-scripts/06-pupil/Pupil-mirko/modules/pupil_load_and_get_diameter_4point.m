function pupil_dia = pupil_load_and_get_diameter_4point(Videolist_csv, likelihood_threshold, savedir,plot_botton)

for vid = 1:numel(Videolist_csv)
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
%         fdir=Videolist_csv1(vid).folder;
%         [~,fname,fext]=fileparts(Videolist_csv1(vid).name);
        % abreviations: tp = timepoint, up = upper, r = right, lo = lower, l =
        % left, x = x-value, y = y-value, lh = likelihood;
        [tp,x_up,y_up,lh_up,x_r,y_r,lh_r,x_lo,y_lo,lh_lo,x_l,y_l,lh_l]=textread(Videolist_csv{vid},'%n %n %n %n %n %n %n %n %n %n %n %n %n','delimiter',',','headerlines',3);
        
        % d_v is vertical distance
        d_v=sqrt((x_up-x_lo).^2+(y_up-y_lo).^2);
        % d_h is horizontal distance
        d_h=sqrt((x_r-x_l).^2+(y_r-y_l).^2);
        % mean between d_h and d_v
        d_mean=(d_h+d_v)./2;
        
        
        % use loglikelikelihood (lh_XXX) to find outlier frames
        % outliers exist in all four labels --> create lh_all and build the
        % help_var with size lh_XX x 4
        lh_all=[lh_up,lh_r,lh_lo,lh_l];
        help_var_all=[];
        for tx=1:size(lh_all,2)
            clear help_var;
            help_var=find(lh_all(:,tx)<0.95);
            help_var_all=[help_var_all;help_var];
        end
        
        % help_var_all includes all the frames with a loglikelihood < 0.95
        help_var_all=sort(help_var_all);
        
        % outlier_frames as unique vector
        outlier_frames=unique(help_var_all);
        
        if plot_botton 
        % plot:
        figure(1);
        for sx=1:length(outlier_frames)
            line([outlier_frames(sx),outlier_frames(sx)],[0,500],'color','r');
        end
        hold on;
        plot(d_mean);
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [30 fps]';
        legend('Outlier Frames','Location','NorthEast')
        title(fname,'Interpreter','none')
        
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_uncorrected.ps']) ,'-r200','-append');
        close all;
        end
        % create pupil_dia string array
        pupil_dia(vid).name = fname;
        pupil_dia(vid).length = length(d_mean);
        pupil_dia(vid).d_mean = d_mean;
        pupil_dia(vid).outliers = outlier_frames;
        pupil_dia(vid).numb_outliers = length(outlier_frames);
        
    end
end

