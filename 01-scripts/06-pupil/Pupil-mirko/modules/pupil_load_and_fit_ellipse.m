function [pupil_dia,lid_dia] = pupil_load_and_fit_ellipse(Videolist_csv, Videolist, likelihood_threshold, savedir, plotter)
%% This function loads the csv output files from DLC from the 8-point pupil network and fits and ellipse
% The ellipse for pupil area can only be fit where there are at least 5
% estimated markers with a likelihood above the threshold. The output
% (d_mean) contains NaN on all timepoints where no fit can be made. This
% can be scrubbed with pupil_scrubbing.m.
%
%
% plotter = 0;

for vid = 1:numel(Videolist_csv)
    %% Load Output data (as csv)
    
    [fdir,fname,fext]=fileparts(Videolist_csv{vid});
    coords = readtable(Videolist_csv{vid},'delimiter',',','headerlines',1);
    
    %% Find outliers with low likelihood of correct pose estimation
    
    coords_clean = coords;
    % for every marker find timepoints of low likelihood
    for m = 4:3:49
        % set NaN for x and y coords of low likelihood timepoints
        coords_clean.(m-1)(coords.(m) < likelihood_threshold) = NaN;
        coords_clean.(m-2)(coords.(m) < likelihood_threshold) = NaN;
    end
    
    
    %% Fit ellipse if at least 5 markers available
    % convert table to array: xy-coords for one marker in two adjacent columns
    coords_array = table2array(coords_clean(:,[2,3,5,6,8,9,11,12,14,15,17,18,20,21,23,24]));
    
    % preallocate area of ellipse
    area_fit_pupil = nan(size(coords_array,1),1);
    outlier_frames_pupil = [];
    for tp = 1:size(coords_array,1)
        % reshape array to x and y columns
        tp_array = coords_array(tp,:);
        tp_array(isnan(tp_array)) = [];
        
        % if at least 5 points for estimation available:
        if length(tp_array)<10
            outlier_frames_pupil = [outlier_frames_pupil tp];
            continue
        end
        
        tp_array = reshape(tp_array,2,length(tp_array)/2)';
        try
            %  Ohad Gal (2020). fit_ellipse (https://www.mathworks.com/matlabcentral/fileexchange/3215-fit_ellipse), MATLAB Central File Exchange. Retrieved June 18, 2020.
            ellipse_t = fit_ellipse(tp_array(:,1),tp_array(:,2));
            area_fit_pupil(tp) = pi*ellipse_t.a*ellipse_t.b;
        catch
            warning(['Timepoint: ',num2str(tp),' no pupil-fit possible.']);
        end
    end
    d_mean_pupil = area_fit_pupil;
    
    %% Fit curves to upper and lower lid if at least 5 markers available
    % convert table to array: xy-coords for one marker in two adjacent columns
    coords_array_lid = table2array(coords_clean(:,[26,27,29,30,32,33,35,36,38,39,41,42,44,45,47,48]));
    
    area_fit_lid = nan(size(coords_array_lid,1),1);
    outlier_frames_lid = [];
    
    tic
    NumFrames2check=[1:1000:size(coords_array_lid,1)];
    
    for tp = 1:size(coords_array_lid,1)
        
        % reshape array to x and y columns
        tp_array = coords_array_lid(tp,:);
        tp_array(isnan(tp_array)) = [];
        
        % if at least 5 points for estimation available:
        if length(tp_array)<14
            outlier_frames_lid = [outlier_frames_lid tp];
            continue
        end
        tp_array = reshape(tp_array,2,8)';
        
        try
            
            fitobject_upperLid = fit(tp_array([7,8,1,2,3],1)+640,tp_array([7,8,1,2,3],2)+300,'cubicinterp');
            yfit_upperLid = fitobject_upperLid([tp_array(7)+640:0.1:tp_array(3)+640]);
            fitobject_lowerLid = fit(tp_array([7,4,5,6,3],1)+640,tp_array([7,4,5,6,3],2)+300,'cubicinterp');
            yfit_lowerLid = fitobject_lowerLid([tp_array(7)+640:0.1:tp_array(3)+640]);
            %%     plot option
            %
            if sum(NumFrames2check==tp)
                f5 = figure(5);
                v=VideoReader(char(Videolist{vid}));
                v.CurrentTime=tp;
                imagesc(readFrame(v));%([300:end],[640:end],:)
                hold on;
                sc=scatter(tp_array(:,1)+640,tp_array(:,2)+300,'o','filled');% values (640,300) are added due to cropping in DLC
                sc.SizeData=10;
                sc.MarkerEdgeColor=[1,0,0];
                sc.MarkerFaceColor=[1,0,0];
                hold on; pl1=plot(fitobject_upperLid,tp_array([7,8,1,2,3],1)+640,tp_array([7,8,1,2,3],2)+300);
                hold on; pl2=plot(fitobject_lowerLid,tp_array([7,4,5,6,3],1)+640,tp_array([7,4,5,6,3],2)+300);
                pl1(2).LineStyle='-';
                pl1(2).LineWidth=1.5;
                pl1(2).Color=[0.7,0,0];
                pl2(2).LineStyle='-';
                pl2(2).LineWidth=1.5;
                pl2(2).Color=[0.7,0,0];               
                
                pause(0.5);
                close(figure(5));
            end
            
            
            area_fit_lid(tp)=trapz([tp_array(7):0.1:tp_array(3)],yfit_lowerLid-yfit_upperLid);% substraction of upper from lower lid due to upside-down coordinates!
        catch
            warning(['Timepoint: ',num2str(tp),' no lid-fit possible.']);
        end
        
    end
    toc
    d_mean_lid = area_fit_lid;
    
    % plot:
    if plotter
        fig=figure('visible', 'on');
        hold on;
        plot(d_mean);
        ax=gca;
        for sx=1:length(outlier_frames_pupil)
            line([outlier_frames_pupil(sx),outlier_frames_pupil(sx)],[0,ax.YLim(2)],'color','r');
        end
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [30 fps]';
        legend('Outlier Frames','Location','NorthEast')
        title(fname,'Interpreter','none')
        
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_uncorrected.ps']) ,'-r200','-append');
        %         saveas(gcf,fullfile(savedir,[fname,'.png']));
        close all;
    end
    % create pupil_dia string array
    pupil_dia(vid).name = fname;
    pupil_dia(vid).length = length(d_mean_pupil);
    pupil_dia(vid).d_mean = d_mean_pupil;
    pupil_dia(vid).outliers = find(isnan(area_fit_pupil));
    pupil_dia(vid).numb_outliers = nnz(isnan(area_fit_pupil));
    
    lid_dia(vid).name = fname;
    lid_dia(vid).length = length(d_mean_lid);
    lid_dia(vid).d_mean = d_mean_lid;
    lid_dia(vid).outliers = find(isnan(area_fit_lid));
    lid_dia(vid).numb_outliers = nnz(isnan(area_fit_lid));
    
end
