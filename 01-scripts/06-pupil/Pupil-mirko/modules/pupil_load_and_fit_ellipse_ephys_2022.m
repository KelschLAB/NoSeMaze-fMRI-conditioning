function [pupil_dia,lid_dia,lid_dia_v2] = pupil_load_and_fit_ellipse_ephys_2022(Videolist_csv, Videolist, likelihood_threshold_pupil, likelihood_threshold_lid,  savedir, plotter)
%% This function loads the csv output files from DLC from the 8-point pupil network and fits and ellipse
% The ellipse for pupil area can only be fit where there are at least 5
% estimated markers with a likelihood above the threshold. The output
% (d_mean) contains NaN on all timepoints where no fit can be made. This
% can be scrubbed with pupil_scrubbing.m.
%
%
% plotter = 0;


% timer
tic

% clearing
clear area_fit_lid area_fit_lid_rotated

%% Load Output data (as csv)
[fdir,fname,fext]=fileparts(Videolist_csv);
coords = readtable(Videolist_csv,'delimiter',',','headerlines',1);

%% Find outliers with low likelihood of correct pose estimation
coords_clean = coords;
% for every marker find timepoints of low likelihood

% pupil
for m = 4:3:25
    % set NaN for x and y coords of low likelihood timepoints
    coords_clean.(m-1)(coords.(m) < likelihood_threshold_pupil) = NaN;
    coords_clean.(m-2)(coords.(m) < likelihood_threshold_pupil) = NaN;
end

% eye-lid
for m = 28:3:49
    % set NaN for x and y coords of low likelihood timepoints
    coords_clean.(m-1)(coords.(m) < likelihood_threshold_lid) = NaN;
    coords_clean.(m-2)(coords.(m) < likelihood_threshold_lid) = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% I. PUPIL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fit ellipse if at least 5 markers available
% convert table to array: xy-coords for one marker in two adjacent columns
coords_array = table2array(coords_clean(:,[2,3,5,6,8,9,11,12,14,15,17,18,20,21,23,24]));

% preallocate area of ellipse
area_fit_pupil = nan(size(coords_array,1),1);
X0_in = nan(size(coords_array,1),1);
Y0_in = nan(size(coords_array,1),1);

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
        X0_in(tp) = ellipse_t.X0_in;
        Y0_in(tp) = ellipse_t.Y0_in;
    catch
        warning(['Timepoint: ',num2str(tp),' no pupil-fit possible.']);
    end
    
end

d_mean_pupil = area_fit_pupil;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% II. EYE-LID %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fit curves to upper and lower lid if all markers available
% convert table to array: xy-coords for one marker in two adjacent columns
coords_array_lid = table2array(coords_clean(:,[26,27,29,30,32,33,35,36,38,39,41,42,44,45,47,48]));

% predefinitions
% after backrotation (careful with these values...)
area_fit_lid = nan(size(coords_array_lid,1),1);
% polyarea fit (octagon)
area_fit_lid_poly = nan(size(coords_array_lid,1),1);
% area between curves after rotation
area_fit_lid_rotated = nan(size(coords_array_lid,1),1);
% outliers
outlier_frames_lid = [];

% Specify NumFrames2check for plot of the lid-fit
NumFrames2check=[1:1000:size(coords_array_lid,1)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rotation of the eye to get a better estimate of the lid areal
% Rational: For curve-fitting, left and right corner of the eye
% (eastern/western dots from DLC) must be in a horizontal line
% General approach:
% - Draw a line between eastern and western corner of the lid
% (left-right)
% - Estimate the angle of the slope of the line

% 1. Find the first tp where eastern and western corner of the eye are non-nan values
nanvec_LidPosition_EastOrWest=find(sum(~isnan(coords_array_lid(:,[5,6,13,14])),2)==4);


% 2. Angle estimation is done only for the first timepoint with the
% eastern and western corners found
tp=nanvec_LidPosition_EastOrWest(1);

% coordinates
tp_array = coords_array_lid(tp,:);

% reshape into tp_array_curr with x-values (column 1) and y-values
% (column 2)
tp_array_curr = reshape(tp_array,2,8)';
tp_array_curr(:,1)=tp_array_curr(:,1)+500;
tp_array_curr(:,2)=tp_array_curr(:,2)+300;
% 3. "Line" drawing
% point1 --> western corner of the lid (CAVE: negative y-values
% due to specific orientation for plotting (x=0,y=0 at top left
% corner)
point1 = [tp_array_curr(7,1),-tp_array_curr(7,2)];
% point2 --> eastern corner of the lid
point2 = [tp_array_curr(3,1),-tp_array_curr(3,2)];
x1 = point1(1);
y1 = point1(2);
x2 = point2(1);
y2 = point2(2);
% slope
slope = (y2 - y1) ./ (x2 - x1);

% 4. estimation of angle
angle = atand(slope);
%     % for negative angles
%     if angle<0
%         angle=angle+180;
%     end
theta = round(angle);

% theta is the estimated rotation angle in degree
rot_val=theta;

%% Correction of nan-values with interpolation from Walter
plot_button=0;
clear M M_corrected Remove_Lid
M(1,:,:)=coords_array_lid;
[M_corrected, Removed_Lid] = RemovePikes_NaN_jr(M, M, 3, 4, plot_button,nan);
coords_array_lid = squeeze(M_corrected);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over tp for the eye-lid
for tp = 1:size(coords_array_lid,1)
    
    % reshape array to x and y columns
    tp_array = coords_array_lid(tp,:);
    
    % nan-values are deleted
    tp_array(isnan(tp_array)) = [];
    
    % if not all points for estimation of lid-curve --> outlier
    % (continue with next tp)
    if length(tp_array)<16
        outlier_frames_lid = [outlier_frames_lid tp];
        continue
    end
    
    % reshape into tp_array with x-values (column 1) and y-values
    % (column 2)
    tp_array = reshape(tp_array,2,8)';
    tp_array(:,1)=tp_array(:,1)+650;
    tp_array(:,2)=tp_array(:,2)+300;
    
    % rough estimate for comparison: polyarea fit within the 8 points
    area_fit_lid_poly(tp) = polyarea(tp_array(:,1),tp_array(:,2));
    
    
    try
        % define tp_array_orig as tp_array is later replaced by the
        % rotated values
        tp_array_orig=tp_array;
        
        % ORDER COLUMNS
        coordT=tp_array_orig; %GET X AND Y TO ROTATE
        
        % ROTATION MATRIX
        R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; % CREATE THE MATRIX
        rotcoord=coordT*R'; % MULTIPLY VECTORS BY THE ROT MATRIX
        % REPLACE X and Y columns on tp_array with rotcoord X and Y
        tp_array=rotcoord;
        
        %% Curve-Fitting
        fitobject_upperLid = fit(tp_array([7,8,1,2,3],1),tp_array([7,8,1,2,3],2),'cubicinterp');
        yfit_upperLid = fitobject_upperLid([tp_array(7):0.1:tp_array(3)]);
        
        p_upperLid = polyfit(tp_array([7,8,1,2,3],1),tp_array([7,8,1,2,3],2),2);
        yfit_polyval_upperLid = polyval(p_upperLid,[tp_array(7):0.1:tp_array(3)]);
        
        fitobject_lowerLid = fit(tp_array([7,4,5,6,3],1),tp_array([7,4,5,6,3],2),'cubicinterp');
        yfit_lowerLid = fitobject_lowerLid([tp_array(7):0.1:tp_array(3)]);
        
        p_lowerLid = polyfit(tp_array([7,4,5,6,3],1),tp_array([7,4,5,6,3],2),2);
        yfit_polyval_lowerLid = polyval(p_lowerLid,[tp_array(7):0.1:tp_array(3)]);
        
        if rot_val
            R=[cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
            backrot_coord_upperLid=[[tp_array(7):0.1:tp_array(3)]',yfit_upperLid]*R';
            backrot_coord_lowerLid=[[tp_array(7):0.1:tp_array(3)]',yfit_lowerLid]*R';
            backrot_polyval_upperLid=[[tp_array(7):0.1:tp_array(3)]',yfit_polyval_upperLid']*R';
            backrot_polyval_lowerLid=[[tp_array(7):0.1:tp_array(3)]',yfit_polyval_lowerLid']*R';
        end
        
        %% plot option
        %
        
        if any(NumFrames2check==tp)
            
            f5=figure('visible','on');
            
            v=VideoReader(char(Videolist));
            v.CurrentTime=tp.*0.1;
            
            imagesc(readFrame(v).*0.7);%.*0.7 for darker color; ([300:end],[640:end],:)
            hold on;
            sc1=scatter(tp_array(:,1),tp_array(:,2),'o','filled');% values (640,300) are added due to cropping in DLC
            sc1.SizeData=10;
            sc1.MarkerEdgeColor=[1,0,0];
            sc1.MarkerFaceColor=[1,0,0];
            if rot_val
                hold on;
                sc2=scatter(rotcoord(:,1),rotcoord(:,2),'o','filled');% values (640,300) are added due to cropping in DLC
                sc2.SizeData=10;
                sc2.MarkerEdgeColor=[0,0,1];
                sc2.MarkerFaceColor=[0,0,1];
            end
            hold on; pl1=plot(fitobject_upperLid,tp_array([7,8,1,2,3],1),tp_array([7,8,1,2,3],2));
            hold on; pl2=plot(fitobject_lowerLid,tp_array([7,4,5,6,3],1),tp_array([7,4,5,6,3],2));
            pl1(2).LineStyle='-';
            pl1(2).LineWidth=1.5;
            pl1(2).Color=[0.7,0,0];
            pl2(2).LineStyle='-';
            pl2(2).LineWidth=1.5;
            pl2(2).Color=[0.7,0,0];
            ax=gca;
            ax.YLim=[0,size(readFrame(v),2)];
            ax.XLim=[0,size(readFrame(v),2)];
            
            if rot_val
                hold on; sc3=scatter(backrot_coord_upperLid(:,1),backrot_coord_upperLid(:,2));
                sc3.SizeData=5;
                sc3.MarkerEdgeColor=[0,0,1];
                sc3.MarkerFaceColor=[0,0,1];
                
                hold on; sc4=scatter(backrot_coord_lowerLid(:,1),backrot_coord_lowerLid(:,2));
                sc4.SizeData=5;
                sc4.MarkerEdgeColor=[0,0,1];
                sc4.MarkerFaceColor=[0,0,1];
                
                hold on; sc5=scatter(backrot_polyval_upperLid(:,1),backrot_polyval_upperLid(:,2));
                sc5.SizeData=5;
                sc5.MarkerEdgeColor=[0,1,0];
                sc5.MarkerFaceColor=[0,1,0];
                
                hold on; sc6=scatter(backrot_polyval_lowerLid(:,1),backrot_polyval_lowerLid(:,2));
                sc6.SizeData=5;
                sc6.MarkerEdgeColor=[0,1,0];
                sc6.MarkerFaceColor=[0,1,0];
            end
            
            
            % legend
            if rot_val
                ll=legend([sc1,sc3,pl1(2)],'data (DLC)','data (DLC), rot.','fitted curve');
            else
                ll=legend([sc1,pl1(2)],'data (DLC)','data (DLC), rot.','fitted curve');
            end
            
            % title
            title(['Frame: ' num2str(tp) '; Time: ' num2str(tp.*0.1) ' s']);
            
            % save
            % quadratic figure with symmetric axis
            f5.CurrentAxes.PlotBoxAspectRatio=[1,1,1];
            print('-dpsc',fullfile(fdir,['PupilLid_' fname '_' date '.ps']) ,'-r400','-append')
            
            %                 pause(0.5);
            %                 close(figure(5));
        end
        
        area_fit_lid_rotated(tp)=trapz([tp_array(7):0.1:tp_array(3)],yfit_lowerLid-yfit_upperLid);% substraction of upper from lower lid due to upside-down coordinates!
        [yMax_lowerLid,xMax_lowerLid]=max(abs(yfit_lowerLid));[yMin_upperLid,xMin_upperLid]=min(abs(yfit_upperLid));
        dia_fit_lid_rotated(tp)=sqrt((xMax_lowerLid-xMin_upperLid)^2+(yMax_lowerLid-yMin_upperLid)^2);
        dia_fit_lid_middle_rotated(tp)=yfit_lowerLid(round(length(yfit_lowerLid)/2))-yfit_upperLid(round(length(yfit_upperLid)/2));
        
        area_fit_lid(tp)=trapz([tp_array(7):0.1:tp_array(3)],backrot_coord_lowerLid(:,2)-backrot_coord_upperLid(:,2));
        
        area_fit_lid_rotated_v2(tp)=trapz([tp_array(7):0.1:tp_array(3)],yfit_polyval_lowerLid-yfit_polyval_upperLid);
        [yMax_lowerLid,xMax_lowerLid]=max(abs(yfit_polyval_lowerLid));[yMin_upperLid,xMin_upperLid]=min(abs(yfit_polyval_upperLid));
        dia_fit_lid_rotated_v2(tp)=sqrt((xMax_lowerLid-xMin_upperLid)^2+(yMax_lowerLid-yMin_upperLid)^2);
        dia_fit_lid_middle_rotated_v2(tp)=yfit_polyval_lowerLid(round(length(yfit_polyval_lowerLid)/2))-yfit_polyval_upperLid(round(length(yfit_polyval_upperLid)/2));
        
        area_fit_lid_v2(tp)=trapz([tp_array(7):0.1:tp_array(3)],backrot_polyval_lowerLid(:,2)-backrot_polyval_upperLid(:,2));
    catch
        warning(['Timepoint: ',num2str(tp),' no lid-fit possible.']);
    end
end


% put area values into d_mean
d_mean_lid = area_fit_lid;
d_mean_lid_rot = area_fit_lid_rotated;
d_mean_lid_poly = area_fit_lid_poly;
d_mean_lid_v2 = area_fit_lid_v2;
d_mean_lid_rot_v2 = area_fit_lid_rotated_v2;
d_lid_dia = dia_fit_lid_rotated;
d_lid_dia_middle = dia_fit_lid_middle_rotated;
d_lid_dia_v2 = dia_fit_lid_rotated_v2;
d_lid_dia_middle_v2 = dia_fit_lid_middle_rotated_v2;

d_XO = X0_in;
d_YO = Y0_in;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timer off
toc

% % % % % % % % % % % % %     % plot: (probably not necessary anymore)
% % % % % % % % % % % % %     if plotter
% % % % % % % % % % % % %         fig=figure('visible', 'on');
% % % % % % % % % % % % %         hold on;
% % % % % % % % % % % % %         plot(d_mean);
% % % % % % % % % % % % %         ax=gca;
% % % % % % % % % % % % %         for sx=1:length(outlier_frames_pupil)
% % % % % % % % % % % % %             line([outlier_frames_pupil(sx),outlier_frames_pupil(sx)],[0,ax.YLim(2)],'color','r');
% % % % % % % % % % % % %         end
% % % % % % % % % % % % %         ax.YLabel.String='Pupil Diameter';
% % % % % % % % % % % % %         ax.XLabel.String='Frame [30 fps]';
% % % % % % % % % % % % %         legend('Outlier Frames','Location','NorthEast')
% % % % % % % % % % % % %         title(fname,'Interpreter','none')
% % % % % % % % % % % % %
% % % % % % % % % % % % %         set(gcf, 'InvertHardcopy', 'off')
% % % % % % % % % % % % %         print('-dpsc',fullfile(savedir,['Pupil_uncorrected.ps']) ,'-r200','-append');
% % % % % % % % % % % % %         %         saveas(gcf,fullfile(savedir,[fname,'.png']));
% % % % % % % % % % % % %         close all;
% % % % % % % % % % % % %     end

% create pupil_dia string array
pupil_dia.name = fname;
pupil_dia.length = length(d_mean_pupil);
pupil_dia.d_mean = d_mean_pupil;
pupil_dia.outliers = find(isnan(area_fit_pupil));
pupil_dia.numb_outliers = nnz(isnan(area_fit_pupil));
pupil_dia.d_X0 = d_XO;
pupil_dia.d_Y0 = d_YO;

% create lid_dia string array
lid_dia.name = fname;
lid_dia.length = length(d_mean_lid);
lid_dia.d_mean = d_mean_lid;
lid_dia.d_mean_rot = d_mean_lid_rot;
lid_dia.d_mean_poly = d_mean_lid_poly;
lid_dia.outliers = find(isnan(area_fit_lid));
lid_dia.numb_outliers = nnz(isnan(area_fit_lid));
lid_dia.removed_lid = Removed_Lid/length(area_fit_lid_rotated);
lid_dia.diaMax = d_lid_dia;
lid_dia.diaMiddle = d_lid_dia_middle;

% create lid_dia string array
lid_dia_v2.name = fname;
lid_dia_v2.length = length(d_mean_lid_v2);
lid_dia_v2.d_mean = d_mean_lid_v2;
lid_dia_v2.d_mean_rot = d_mean_lid_rot_v2;
lid_dia_v2.d_mean_poly = d_mean_lid_poly;
lid_dia_v2.outliers = find(isnan(area_fit_lid_v2));
lid_dia_v2.numb_outliers = nnz(isnan(area_fit_lid_v2));
lid_dia_v2.removed_lid = Removed_Lid/length(area_fit_lid_rotated_v2);
lid_dia_v2.diaMax = d_lid_dia_v2;
lid_dia_v2.diaMiddle = d_lid_dia_middle_v2;

