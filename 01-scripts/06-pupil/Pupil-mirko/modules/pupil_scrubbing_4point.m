function [pupil_dia_corr,filt_info] = pupil_scrubbing_4point(Videolist_csv, pupil_dia, savedir,plot_button,filtering)

% set filtering settings
% LP
N_LP = 2;
F3dB_LP = 0.15; % [pi*rad/sample] (pi*rad==1/2cycle => Frequency/[sample_rate/2] == F3dB)
% BP
N_BP =2;
F3dB1_BP = 0.01;
F3dB2_BP = 0.15;

filt_info =[];
if filtering
filt_info.LP_params = ['fdesign.bandpass(N,F3dB1,F3dB2,' num2str(N_BP) ',' num2str(F3dB1_BP) ',' num2str(F3dB2_BP) ') d1 = design(h,butter)'];  
filt_info.BP_params = ['fdesign.bandpass(N,F3dB1,F3dB2,' num2str(N_BP) ',' num2str(F3dB1_BP) ',' num2str(F3dB2_BP) ') d1 = design(h,butter)'];  
end

for vid = 1:numel(Videolist_csv)
     
        [fdir,fname,fext]=fileparts(Videolist_csv{vid});
        
        % threshold for numb of outliers to
        clear X T S
        X=pupil_dia(vid).d_mean;
        if isempty(pupil_dia(vid).ipoints)
            T=zeros(length(pupil_dia(vid).d_mean),1);
        elseif ~isempty(pupil_dia(vid).ipoints)
            T=zeros(pupil_dia(vid).ipoints,1);
        end
        T(pupil_dia(vid).outliers)=1;
        
        % manual correction of unregcognized outlier in #7
%         if vid==7;
%             T(17355)=1;
%         elseif vid==30;
%             T(32920:32950)=0;
%         end
        
        % scrubbing
        [S, T] = SNiP_scrubbing(X, T, 'spline');
        pupil_dia_corr(vid).d_mean=S;
if filtering                
        % highpass filter
        h = fdesign.highpass('N,F3dB',2,0.005);
        d1 = design(h,'butter');
        pupil_dia_corr(vid).d_mean_hp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_corr(vid).d_mean); % high pass filter ...
        
        % bandpass filter
        h = fdesign.bandpass('N,F3dB1,F3dB2',N_BP,F3dB1_BP,F3dB2_BP);
        d1 = design(h,'butter');
        pupil_dia_corr(vid).d_mean_bp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_corr(vid).d_mean); % band pass filter ...
                         
        % lowpass filter
        h = fdesign.lowpass('N,F3dB',N_LP,F3dB_LP);%N = 12 before
        d1 = design(h,'butter');
        pupil_dia_corr(vid).d_mean_lp = filtfilt(d1.sosMatrix,d1.ScaleValues,pupil_dia_corr(vid).d_mean); % low pass filter ...
end
        if plot_button
        % plot
        figure(1);
        subplot(2,1,1);
        plot(pupil_dia(vid).d_mean);
        hold on;
        plot(pupil_dia_corr(vid).d_mean);
        
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [20 fps]';
        legend('to scrub','Location','NorthEast')
        title(fname,'Interpreter','none')
        if filtering        
        subplot(2,1,2);
        plot(pupil_dia_corr(vid).d_mean);
        hold on;
        plot(pupil_dia_corr(vid).d_mean_lp,'r');
        
        ax=gca;
        ax.YLabel.String='Pupil Diameter';
        ax.XLabel.String='Frame [20 fps]';
        legend('LowPassfiltered','Location','NorthEast')
        title(fname,'Interpreter','none')
        end
        
        set(gcf, 'InvertHardcopy', 'off')
        print('-dpsc',fullfile(savedir,['Pupil_scrubbing_and_lowpassfiltering.ps']) ,'-r200','-append');
        waitfor(msgbox('Check results!'))
        close all
        end
        
    end
end