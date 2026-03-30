## %maybe start:ending is set wrong, causing error messages of bad values at beginning and end of trace
% post hoc bandpass filterin pupil data, is now integrated in normal code
function d = pup_posthoc_bp(d)
pupil = d.pupil;
pupil_sesh_idx = find(arrayfun(@(pupil) ~isempty(pupil.bp_trace),pupil));
% pupil_sesh_idx = find(ismember(find(arrayfun(@(pupil) isempty(pupil.bp_trace),pupil)),find(arrayfun(@(pupil) ~isempty(pupil.raw_trace),pupil))));

% filter settings 
N_BP =2;
F3dB1_BP = 0.0025;
F3dB2_BP = 0.6;
BP6_params = ['fdesign.bandpass(N,F3dB1,F3dB2,' num2str(N_BP) ',' num2str(F3dB1_BP) ',' num2str(F3dB2_BP) ') d1 = design(h,butter)'];  

% % filter settings 
% N_LP =2;
% F3dB1_BP = 0.01;
% F3dB_LP = 0.6;
% LP3_params = ['fdesign.lowpass(N,F3dB,' num2str(N_LP) ',' num2str(F3dB_LP) ') d1 = design(h,butter)'];  


for s = pupil_sesh_idx
    
    start = round(pupil(s).info.intanalign)*10;
    ending = round(pupil(s).info.intanalign)*10+diff(d.pupil(s).info.StartEndFrames);

    clear pup_bp
    %get bandpass-filtered data
    % % get outliers
    pup_raw = pupil(s).raw_trace(start:ending); 

    outliers = find(isnan(pup_raw));
    
    clear X T S
    X=pup_raw;
    T=zeros(length(pup_raw),1);
    T(outliers)=1;
    
    % scrubbing
    [S, T] = SNiP_scrubbing(X, T, 'spline');
    pup_scrub=S;

    % bandpass filter
    h = fdesign.bandpass('N,F3dB1,F3dB2',N_BP,F3dB1_BP,F3dB2_BP);
    d1 = design(h,'butter');
    pup = filtfilt(d1.sosMatrix,d1.ScaleValues,pup_scrub); % band pass filter ...
%     
%     % lowpass filter
%     h = fdesign.lowpass('N,F3dB',N_LP,F3dB_LP);
%     d1 = design(h,'butter');
%     pup = filtfilt(d1.sosMatrix,d1.ScaleValues,pup_scrub); % band pass filter ...
    
    d.pupil(s).bp6_trace = nan(length(d.pupil(s).lp_trace),1);        
    d.pupil(s).bp6_trace(start:ending) =pup;%(VOI_Info.FrameBegin:end);
    d.pupil(s).info.BP6_params = BP6_params;
    end
end
