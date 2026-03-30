function varargout = physcorr_onlyHR(funcfiles, X, TR, only_retroicor, passfreq, output_dir);

% function physcorr(funcfiles, X, TR, only_retroicor, passfreq);
%
% X: physiological predictors from parseLog.
% TR: [sec] e.g. 0.609.
%
% Version 4-9-2008: multiple regression.

outputfiles = {};
if ~strcmp(output_dir(end), '/'),
    output_dir = [output_dir '/'];
end;
if ~exist(output_dir),
    mkdir(output_dir);
end;
base_output_name = [output_dir 'aztec_or' num2str(only_retroicor)];
headerinfo = spm_vol(funcfiles);
headerinfo_out = headerinfo;
V = spm_vol(funcfiles);
if length(V) < length(X(:, 1)),
    X = X(1:length(V), :);
    fprintf('Warning: more fysio than MRI scans');
end;
if length(V) > length(X(:, 1)),
    temp = V;
    V = {};
    for n = 1:length(X(:, 1)),
        V{n} = temp{n};
    end;
    fprintf('Warning: fewer fysio than MRI scans');
end;

hpX = make_X(length(V), 1 / TR, passfreq);

critForBrainVoxel = 0; % temporary: integrate into future params struct.

% lagged predictors
predvec = [2 2 3 7];
poslimsec = [20 60 20 15];
neglimsec = [0 0 0 10];

% predictor and variance matrices
poslim = floor(poslimsec ./ TR);
neglim = floor(neglimsec ./ TR);
nScans = size(X, 1);
    
for laggedVar = 1:length(predvec),
    lags = (-neglim(laggedVar)):poslim(laggedVar);
    nLags = length(lags);
    lagged{laggedVar} = zeros(nScans, nLags);
    varLagged{laggedVar} = zeros(1, nLags);
    for iLag = 1:nLags,
        lag0 = lags(iLag);
        if lag0 < 0,
            a = 1; c = 1 + abs(lag0);
            b = nScans - abs(lag0); d = nScans;
        else,
            a = 1 + lag0; c = 1;
            b = nScans; d = nScans - lag0;
        end;
        lagged{laggedVar}(a:b, iLag) = X(c:d, predvec(laggedVar)); % - mean(X(c:d, predvec(laggedVar)));
        nz = find(lagged{laggedVar}(:, iLag) ~= 0);
        z = find(lagged{laggedVar}(:, iLag) == 0);
        lagged{laggedVar}(z, iLag) = mean(lagged{laggedVar}(nz, iLag));
        lagged{laggedVar}(:, iLag) = lagged{laggedVar}(:, iLag) - mean(lagged{laggedVar}(:, iLag));
        varLagged{laggedVar}(iLag) = sqrt(var(lagged{laggedVar}(a:b, iLag)));
        N{laggedVar}(iLag) = length(a:b);
    end;
end;

temp0 = headerinfo{1}.dim(1:3);
dims = [temp0(:)' length(X(:, 1))];
cardiac_map = zeros(dims(1:3));
resp_map = zeros(dims(1:3));
retromap = zeros(dims(1:3));
restmap = zeros(dims(1:3));
r_map = {};
lag_map = {};
xc_cell = {};
for nnn = 1:length(predvec), lag_map{nnn} = zeros(dims(1:3)); r_map{nnn} = zeros(dims(1:3)); end;
for z = 1:dims(3),
    %fprintf(['Plane=' num2str(z) ' ']);
    %fprintf('Reading... ');
    tic;
    A = spm_matrix([0 0 z]);
    plane = zeros(dims(1), dims(2), length(V));
    for iScan = 1:length(V),
        plane(:, :, iScan) = spm_slice_vol(V{iScan}, A, V{1}.dim(1:2), 0);
    end;
    %fprintf('\nTime to read plane = %g\n', toc); tic;
    %fprintf('Correcting... ');
    for x = 1:dims(1),
        if mod(x, ceil(dims(1) / 10)) == 0, fprintf('|'); end;
        for y = 1:dims(2),
            %timecourse = plane(:, index);
            timecourse = plane(x, y, :);
            timecourse = timecourse(:);
            % check if brain-voxel
            old_mean = mean(timecourse);
            if isnan(old_mean),
                plane(x, y, :) = 0;
                continue;
            elseif old_mean <= critForBrainVoxel,
                plane(x, y, :) = 0;
                continue;
            end;
            % timecourse = detrend(timecourse);
            [slow, timecourse] = highpass_thomas(timecourse, hpX);
            tcbu = timecourse; % to be used for getting correlations with predictors
            if length(find(isnan(timecourse))) > 0,
                continue;
            end;
            try,
                % cardiac pulsitility
                [timecourse, fitted, fit_params, fit_val] = cardiac_puls(timecourse, X(:, 1));
                cardiac_map(x, y, z) = fit_val;
            catch,
                fprintf(['Time course (' num2str(x) ', ' num2str(y) ') could not be fitted.\n']);
            end;
%             try,
%                 % respiration phase
%                 if var(X(:, 8)) > 0,
%                     [timecourse, fitted, fit_params, fit_val] = cardiac_puls(timecourse, X(:, 8));
%                     [dummy, fitted, fit_params, fit_val] = cardiac_puls(tcbu, X(:, 8));
%                     resp_map(x, y, z) = fit_val;
%                 end;
%             catch,
%                 fprintf(['Time course (' num2str(x) ', ' num2str(y) ') could not be fitted.\n']);
%             end;
            retromap(x, y, z) = 1 - var(timecourse) / var(tcbu);
            tcbu_postfase = timecourse;
            if only_retroicor == 0,
                residual = timecourse;
                predictors = {};
                scan0 = 0;
                scan1 = length(timecourse);
                for iiPred = 1:length(predvec),
                    %disp(iiPred);
                    if var(X(:, predvec(iiPred))) == 0,
                        continue;
                    end;
                    lags = (-neglim(iiPred)):poslim(iiPred);
                    iPred = predvec(iiPred);
                    pred0 = X(:, iPred);
                    if iiPred == 2,
                        xc = lag_cor2(lagged{iiPred}, residual, varLagged{iiPred}, N{iiPred});
                    else,
                        xc = lag_cor2(lagged{iiPred}, timecourse, varLagged{iiPred}, N{iiPred});
                    end;
                    [r_abs, fmr] = max(abs(xc));
                    r = xc(fmr);
                    shift0 = lags(fmr);
                    % shift0 < 0: pred0 is predicted by fMRI
                    % shift0 > 0: pred0 predicts fMRI
                    pred1 = zeros(size(pred0));
                    if shift0 < 0,
                        a = 1;
                        c = 1 + abs(shift0);
                        d = length(pred0);
                        b = length(c:d);
                        pred1(a:b) = pred0(c:d);
                        e = a;
                        f = b;
                    elseif shift0 > 0,
                        a = 1;
                        c = 1 + abs(shift0);
                        d = length(pred0);
                        b = length(c:d);
                        pred1(c:d) = pred0(a:b);
                        e = c;
                        f = d;
                    else,
                        pred1 = pred0;
                        e = 1;
                        f = length(pred0);
                    end;
                    reglijn = linfit(pred1(e:f), timecourse(e:f));
                    residual(e:f) = residual(e:f) - reglijn;
                    predictor{iiPred} = pred1;
                    if e > scan0, scan0 = e; end;
                    if f < scan1, scan1 = f; end;
                    % Get nice r_ and lag_maps, pre-RETROICOR
                    xc = lag_cor2(lagged{iiPred}, tcbu, varLagged{iiPred}, N{iiPred});
                    [r_abs, fmr] = max(abs(xc));
                    r = xc(fmr);
                    shift0 = lags(fmr);
                    lag_map{iiPred}(x, y, z) = shift0;
                    r_map{iiPred}(x, y, z) = r;
                end;
                % multiple regression here
                mr_y = timecourse(scan0:scan1);
                mr_X = [];
                for iiPred = 1:length(predvec), 
                    if var(X(:, predvec(iiPred))) == 0,
                        continue;
                    end;
                    mr_X = [mr_X predictor{iiPred}(scan0:scan1)]; 
                end;
                try,
                    mr_b = inv(mr_X' * mr_X) * mr_X' * mr_y;
                catch,
                    fprintf(['Error line 185 ' num2str(x) num2str(y) num2str(z) '\n']);
                end;
                mr_model = mr_X * mr_b;
                mr_expl = var(mr_model);
                mr_error = var(timecourse(scan0:scan1) - mr_model);
                try,
                    mr_R2 = mr_expl / mr_error;
                catch,
                    mr_R2 = NaN;
                end;
                timecourse(scan0:scan1) = timecourse(scan0:scan1) - mr_model;
            end;
            % replace slow part
            plane(x, y, :) = timecourse + slow;
            restmap(x, y, z) = 1 - var(timecourse) / var(tcbu_postfase);
        end; % of y
    end; % of x
    % Save corrected plane
    fprintf('Writing... ');
    for iScan = 1:dims(4),
        tosave = plane(:, :, iScan);
        [p0, newname] = fileparts(funcfiles{iScan});
        headerinfo_out{iScan}.fname = [base_output_name '_' newname '.nii'];
        if z == 1,
            outputfiles{length(outputfiles) + 1} = headerinfo_out{iScan}.fname;
            headerinfo_out{iScan} = spm_create_vol(headerinfo_out{iScan});
        end;
        spm_write_plane(headerinfo_out{iScan}, tosave, z);
        fclose('all');
    end;
    fprintf('Done. ');
    if mod(z, 1) == 0, fprintf('\n'); end;
    clear plane;
end; % of z

% Save results
headerinfo{1}.fname = [base_output_name '_cardiac.nii'];
spm_write_vol(headerinfo{1}, 100 * cardiac_map);
headerinfo{1}.fname = [base_output_name '_respPhase.nii'];
spm_write_vol(headerinfo{1}, 100 * resp_map);
headerinfo{1}.fname = [base_output_name '_RETRO.nii'];
spm_write_vol(headerinfo{1}, 100 * retromap);
headerinfo{1}.fname = [base_output_name '_lagged.nii'];
spm_write_vol(headerinfo{1}, 100 * restmap);
if only_retroicor == 0,
    vartypes = {'HR1', 'HR2', 'HRV' ,'RVT'};
    for n = 1:4,
        headerinfo{1}.fname = [base_output_name '_r_' vartypes{n} '.nii'];
        spm_write_vol(headerinfo{1}, 100 * r_map{n});
        headerinfo{1}.fname = [base_output_name '_bestLag_' vartypes{n} '.nii'];
        spm_write_vol(headerinfo{1}, lag_map{n});
    end;
end;

varargout{1} = outputfiles;

fclose('all');

function [r, scaled_r, lags] = lag_cor(x, y, period, neglimsec, poslimsec)
% function [r, scaled_r, lags] = lag_cor(x, y, period, neglimsec, poslimsec)
%
% Returns the correlation between x and y as a function of lag.
% Correlations are computed over overlapping segments.
% Scaled correlations are normed by the number of elements that
% were used in the calculation (to avoid instability).
% The norming factor is (this_length / max_length).
%
% y must contain at least 3 elements.
% x must be at least as long as y (or will be zero padded);
x = x(:); y = y(:);
if length(x) < length(y),
    x = [x; zeros(length(y) - length(x), 1)];
end;
poslim = ceil(poslimsec / period);
neglim = ceil(neglimsec / period);
lags = (-min(neglim, (length(y) - 2))):min(poslim, (length(y) - 2));
for iLag = 1:length(lags),
    lag0 = lags(iLag);
    if lags(iLag) >= 0,
        lag0 = lag0 + 1;
        y0 = y(lag0:end);
        x0 = x(1:length(y0));
    else,
        lag0 = abs(lag0) + 1;
        x0 = x(lag0:end);
        y0 = y(1:length(x0));
    end;
    cm = corrcoef(x0, y0);
    scaled_r(iLag) = cm(1, 2) * (length(y0) / length(y));
    r(iLag) = cm(1, 2);
end;

function reglijn = linfit(x, y)
m_y = mean(y);
m_x = mean(x);
sd_y = sqrt(var(y));
sd_x = sqrt(var(x));
cm = corrcoef(x, y);
r = cm(1, 2);
x = x - m_x;
y = y - m_y;
reglijn = m_y + r * (sd_y / sd_x) * x;

function xc = lag_cor2(lagged, y, vars, N)
covVec = (y' * lagged) ./ N;
var_y = sqrt(var(y));
xc = covVec ./ (vars * var_y);
catcher0 = 0;
