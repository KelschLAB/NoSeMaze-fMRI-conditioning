function wb_gppi_spmmat(ROIs, SPMmat, Outname)
% Whole-Brain gPPI Analysis (based on SPM first level analysis)
%
% This function performes gPPI analyses between all regional time
% courses entered.
%
% This function uses pre-processed data which has undergone processing
% associated with first level analyses in SPM, and uses the corresponding
% SPM.mat file. For use with data that did not undergo this processing use
% wb_gppi.m instead.
%
% Usage:
%       ROIs: a time points x ROIs x sessions matrix with regional BOLD time courses
%             in the columns
%       SPMmat: SPM.mat of the individual first level analyses, either
%               'SPM.mat' if SPM.mat should be taken from the directory
%               where the function is located in or the complete path
%               including the file.
%       Outname: name of the file to save the results (betas) in
%
%
% Depends on SPM8. Most of the code was adapted from SPM8 and the PPPI (gPPI)
% toolbox (McLaren et al., 2012). This file is derivative work and is distributed under the terms of
% the GNU General Public Licence as published by the Free Software Foundation
% (either version 2, or at your option, any later version).
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% If this file is of help for your own work, please cite Gerchen et al. (2014). Analyzing
% task-dependent brain network changes by whole-brain psychophysiological interactions:
% a comparison to conventional analysis. Human Brain Mapping.in resulting publications.
%
% Copyright (C) 2014
%
% Martin Fungisai Gerchen
%
% Department of Clinical Psychology
% Bernstein Center for Computational Neuroscience Heidelberg/Mannheim
% Medical Faculty Mannheim/University of Heidelberg
% Central Institute of Mental Health
% Mannheim, Germany
% (martin.gerchen@zi-mannheim.de)

% load data

ROI_mean = ROIs; % CC; instead of: ROI_mean = importdata(ROIs); because CC passes down the matrix from the supra-ordinate script
load(SPMmat);

%% Loop over sessions

    Sessions=numel(SPM.Sess); % number of sessions

% make output datamatrix

    PPI_beta = zeros(size(ROI_mean,2), size(ROI_mean,2), size(SPM.Sess(1,1).U,2), Sessions); % !!! assumes the same number of condition regressors in both sessions

for z=1:Sessions

    %% parameters

        RT = SPM.xY.RT;
        dt = SPM.xBF.dt; % timesteps in seconds of microtime resolution
        NT=round(RT/dt); % number of timepoints per image
        fMRI_T0 = SPM.xBF.T0; % Corrects for slice-timing offset
        nscans = size(ROI_mean,1);
        sess=num2str(z);         
        N = nscans;
        k = 1:NT:N*NT; % microtime to scan time indices   
        HParam = SPM.xX.K(1,z).HParam; % High-pass filter cutoff in seconds

        Sess = SPM.Sess(z);
 
    %% construct regressors

        u = length(Sess.U);
        Sess.U = spm_get_ons(SPM,z); % Get onsets in microtime (SPM8 was updated)
        U.name = {};
        U.u = [];
        U.w = [];

        for i=1:u
            for j=1:length(Sess.U(i).name)
                if any(Sess.U(i).u(33:end,j))
                    U.u             = [U.u Sess.U(i).u(33:end,j)];
                    U.name{end + 1} = Sess.U(i).name{j};
                    U.w             = 1;
                end
            end
        end
        for i = 1:size(U.u,2)
                PSY(:,i)     = zeros(N*NT,1);
                PSY(:,i)     = PSY(:,i) + full(U.u(:,i)*U.w);               
        end

    %% get data
    
        data = zeros(size(ROI_mean,1),size(ROI_mean,2));
        data(:,:) = ROI_mean(:,:,z);
      
    %% construct ppi interaction term regressors (from spm_peb_ppi & PPPI)
        
        % create basis functions and hrf in scan time and microtime
            hrf   = spm_hrf(dt);
            
        % Create convolved explanatory {Hxb} variables in scan time
            hrf = spm_hrf(dt); % create hrf in microtime
%             N = nscans;
            xb  = spm_dctmtx(N*NT + 128,N);
            Hxb = zeros(N,N);
            for i = 1:N
                Hx       = conv(xb(:,i),hrf);
                Hxb(:,i) = Hx(k + 128);
            end
            xb = xb(129:end,:);

        % confounds (in scan time) and constant term
            
            n = fix(2*(nscans*RT)/HParam + 1); % order
            X0 = spm_dctmtx(nscans,n); % create basis functions for discrete cosine transform           
            M     = size(X0,2);        

        % Specify covariance components; assume neuronal response is white
        % treating confounds as fixed effects
        
            Q = speye(N,N)*N/trace(Hxb'*Hxb);
            Q = blkdiag(Q, speye(M,M)*1e6  );

        % get whitening matrix (NB: confounds have already been whitened)
    
            W = SPM.xX.W(Sess.row,Sess.row);    
            
        % Create structure for spm_PEB0 not to estimate any contrasts
            PEBP=cell(2,1);
            PEBP{1}.X = [W*Hxb X0];        % Design matrix for lowest level
            PEBP{1}.C = speye(N,N)/4;        % i.i.d assumptions
            PEBP{2}.X = sparse(N + M,1);    % Design matrix for parameters (0's)
            PEBP{2}.C = Q;

   
    %% calculate ppi
   
        for v = 1:size(data,2) % loop over ROIs

            % Get seed timecourse,
                
                Y(:,1) = data(:,v);
                            
            % calculate underlying neural activity
                
                C       = spm_PEB(Y,PEBP);
                xn      = xb*C{2}.E(1:N);
                xn      = spm_detrend(xn);
               
                PSYxn=zeros(size(PSY,1),size(PSY,2));
                PSYHRF=zeros(numel((k-1) + fMRI_T0),size(PSY,2));
                for j=1:size(PSY,2)
                        % multiply psychological variable by neural signal
                        
                        PSYxn(:,j)   = PSY(:,j).*xn;
                        
                        % convolve and resample at each scan for bold signal
                       
                        ppit        = conv(PSYxn(:,j),hrf);
                        ppit        = ppit((k-1) + fMRI_T0);
                        ppi(:,j)    = spm_detrend(ppit);

                        % similarly for psychological effect
                        
                        PSYHRFtmp   = conv(PSY(:,j),hrf);
                        PSYHRF(:,j) = PSYHRFtmp((k-1) + fMRI_T0);

                end

    %% perform actual ppi analysis

        % construct PPI design matrix

            % get movements

                movements = SPM.Sess(1,z).C.C;
%                 movements = movements(:,[1:6]);

            % construct unfiltered matrix
               
                XPPI = [ppi PSYHRF Y movements ones(nscans,1)];
                K = SPM.xX.K(1,1);

        % set seed vector to 0 in data

            KWY = data;
            KWY(:,v) = zeros(nscans,1);

        % GLM

            xKXs = spm_sp('Set',spm_filter(K,W*XPPI)); % design matrix is filtered and whitened
            xKXs.X = full(xKXs.X);
            pKX = spm_sp('x-',xKXs); % projector
            beta = pKX*KWY; %-Parameter estimates

        % put results in matrix
            for i = 1:size(U.u,2)
                PPI_beta(v,:,i,z) = beta(i,:); % saves betas related to interaction terms in output matrix
            end
          
        end
end % of loop over sessions    
    
% save results
        
    save(Outname,'PPI_beta');
        
end