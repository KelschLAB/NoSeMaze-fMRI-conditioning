function [pupil_dia_cut_corr,N,F3dB] = pupil_scrubbing(Videolist_csv, pupil_dia, savedir,plotter)
%% This function uses JR's scrubbing pipeline for pupil data and returns the corrected data
%
%
%%
% plotter = 1;
% lowpass filter
N = 2;
F3dB = 0.15; % [pi*rad/sample] (pi*rad==1/2cycle => Frequency/[sample_rate/2] == F3dB)
   
%% Loop over all included video sessions
for vid = 1:size(pupil_dia,2)
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});    
    
    clear X T S
    X=pupil_dia(vid).d_mean;
    if isfield(pupil_dia,'ipoints')
        if isempty(pupil_dia(vid).ipoints)
            T=zeros(length(pupil_dia(vid).d_mean),1);
        elseif ~isempty(pupil_dia(vid).ipoints)
            T=zeros(pupil_dia(vid).ipoints,1);
        end
    else
        T=zeros(length(pupil_dia(vid).d_mean),1);
    end
    T(pupil_dia(vid).outliers)=1;

    % scrubbing
    [S, T] = SNiP_scrubbing(X, T, 'lin');
    pupil_dia_cut_corr(vid).d_mean=S;

    % lowpass filter
%     h = fdesign.lowpass('N,F3dB',N,F3dB);
%     d1 = design(h,'butter');
%     pupil_dia_cut_corr(vid).d_mean_lp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_cut_corr(vid).d_mean); % low pass filter ...
% 
%     LP_params = ['fdesign.lowpass(N,F3dB,' num2str(N) ',' num2str(F3dB) ') d1 = design(h,butter)']; 

    if plotter
        % plot
        figure(1);
        subplot(2,1,1);
        plot(pupil_dia(vid).d_mean);
        hold on;
        plot(pupil_dia_cut_corr(vid).d_mean);

        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [20 fps]';
        legend('to scrub','Location','NorthEast')
        title(fname,'Interpreter','none')

        subplot(2,1,2);
        plot(pupil_dia_cut_corr(vid).d_mean);
        hold on;
        plot(pupil_dia_cut_corr(vid).d_mean_lp,'r');

        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [20 fps]';
        legend('LowPassfiltered','Location','NorthEast')
        title(fname,'Interpreter','none')
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_scrubbing_and_lowpassfiltering.ps']) ,'-r200','-append');
        close all
    end
end
