function [R, T] = SNiP_scrubbing(X, T, method, varargin)
% function [S, T] = SNiP_scrubbing(X, T, method, cutorkeep)
%
% Does 'scrubbing' on nD input data, assuming the last dimension is time.  
% 
% Inputs
% X         Data matrix (nD). Handles 2D as well as 4D data, assuming the
%           last dimension represents time. This deviates from the usual
%           time x ROIs matrix that we have in SNiP_Graph.
%
% T         Logical vector indicating which timepoint to remove/interpolate.  
%
% method    one of 'cut', 'nearest', 'linear', 'spline', 'pchip'. This function
%           uses interp1 to interpolate (with the obvious exception of
%           'cut').
%
% cutorkeep OPTIONAL: if the temporal mask created indicates scrubbing of
%           the first and/or last volume(s), NaNs are created by the
%           interpolation. Options 'cut' or 'keep' will affect the behavior
%           of the function in that 'cut' means to not return NaN
%           volumes/timeseries but 'keep' does. Defaults is to 'keep' and
%           NaN values are returned.
%
% Outputs
% S         interpolated (scrubbed) data (original size of matrix with last
%           dimension representing time).
%
% T         Temporal indices are also returned in case the start/end was
%           changed.
%
% This code was completely rewritten inspired by another implementation 
% running on voxel-wise raw data only. 
%
% Axel Schäfer (axel.schaefer@zi-mannheim.de)
%


% Some error checking
sX = size(X);

% find indices pointing to bad frames
if ~islogical(T)
    T = logical(T);
end
Ti = find(T);
Tii = find(~T);

if isempty(Ti)
    R = X;
    disp('nothing to scrub since T is all zeros');
    return;
end

if length(sX)==2 && any(sX == 1)
    % assume 1D data
    is1D = true;
    if length(X) ~= length(T)
        error('length of X and T don''t match');
    end
else
    % assume nD and last dimension to be time (!)
    is1D = false;
    if (sX(end) ~= length(T)) 
        error('length of X and T don''t match');
    end
    
    % reshape
    X = reshape(X, prod(sX(1:(end-1))), sX(end));
end

R = X;

% find bad frames at start/end and deal with it
if T(1) || T(end)
    if nargin > 3 && strcmp(varargin{1},'cut')
        % cut end and/or start
        while T(1) 
            T = T(2:end);
            R = R(:,2:end);
            sX(end) = sX(end)-1;
        end
        while T(end) 
            T = T(1:(end-1));
            R = R(:,1:(end-1));
            sX(end) = sX(end)-1;
        end
        Ti = find(T);
        Tii = find(~T);
    else
        fprintf(2,'found bad volumes at start and/or end of timeseries\n\n');
    end
end

% if all volumes are discarded, bail out.
if isempty(Tii)
    error('no volumes to scrub remain');    
end

% finally, do the interpolation
if is1D
    if strcmp(method, 'cut')
        R = X(~T);
    else
        S = interp1(Tii, X(Tii), Ti, method);
        R(Ti) = S;
    end
else
    if strcmp(method,'cut')
        R = X(:,~T);
        %% following line added by JR for cutting:
        sX=[sX(1:3), length(find(~T))];
    else
%        for j=1:size(X,1)
%            S = interp1(Tii, X(j,Tii)', Ti, method);
%            R(j,Ti) = S;
%        end
        % this is much faster than the loop
        S = interp1(Tii, X(:,Tii)', Ti, method); 
        R(:,Ti) = S';
    end
    % reshape back
    if T(end-1)
        R(:,end-1)=R(:,end-2);
    end
    
    if T(end)
        R(:,end)=R(:,end-1);
    end
    R = reshape(R, sX);
end

