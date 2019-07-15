function TxSpectralFlatnessMeasurement(chanEst,cfgWlan,pktNum,hSF) 
% /*!
%  *  @brief     This function is used to test spectral flatness.
%  *  @details   Measures and plots the spectral flatness using channel estimates. 
%  *  @param[out] Null
%  *  @param[in] chanEst,  Nx1 complex, chnnel estimation.
%  *  @param[in] cfgWlan,    1x1 wlan configration object.
%  *  @param[in] pktNum,  1x1 integer, packet number.
%  *  @param[in] hSF, 1x1 figure handler for spectral flatness test.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.26.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.26. Collus Wang,  first draft inherited from matlab 2017a helper fuction vhtTxSpectralFlatnessMeasurement.m}
%  */

switch class(cfgWlan)
    case 'wlanHTConfig'
        validateattributes(cfgWlan,{'wlanHTConfig'},{'scalar'},mfilename, ...
            'format configuration object');
    case 'wlanVHTConfig'
        % Function for VHT and direct spatial mapping only
        validateattributes(cfgVHT,{'wlanVHTConfig'},{'scalar'},mfilename, ...
            'format configuration object');
    otherwise
        error('Unsupported wlanConfiguration class.')
end
coder.internal.errorIf(~strcmpi(cfgWlan.SpatialMapping,'Direct'), ...
    'wlan:vhtTxSpectralFlatnessMeasurement:InvalidSpatialMapping');

% Calculate the deviation for each subcarrier of interest
[dev,testSC] = spectralFlatness(cfgWlan,chanEst);

% Indices of subcarriers tested within whole FFT window
ind = sort([testSC{1} testSC{2}]);

% Plot spectral flatness
Nfft = helperFFTLength(cfgWlan);
figure(hSF);
hSFAx = gca;
hold(hSFAx,'off');
plot(hSFAx,ind-Nfft/2-1,dev,'o');
ylim(hSFAx,[min(-6.5,min(dev(:))), max(4.5,max(dev(:)))]);
title(hSFAx,['Spectral Flatness, Packet:' num2str(pktNum)]);
ylabel(hSFAx,'Deviation (dB)');
xlabel(hSFAx,'Subcarrier Index');
grid(hSFAx,'on');
hold(hSFAx,'on');

% Overlay lower limits
indRange = (ind(1):ind(end)).'; 
dBr = [-4 -6]; % Lower limit for two sets of test subcarriers
limlow = limitPlot(dBr,indRange,testSC,Nfft);
% Overlay upper limits
dBr = [+4 +4]; % Upper limit for two sets of test subcarriers
limup = limitPlot(dBr,indRange,testSC,Nfft);

% Create legend
numAnts = size(dev,2);
legendEntries = cell(numAnts+1,1);
legendEntries(1:numAnts) = arrayfun(@(x)sprintf('Antenna %d',x), ...
    1:numAnts,'UniformOutput',false);
legendEntries{numAnts+1} = 'Deviation limit';
legend(hSFAx,legendEntries,'location','south');

drawnow; % Update plot

% Determine if limit exceeded
if any(any(bsxfun(@lt,dev,limlow(~isnan(limlow))))) || ...
        any(any(bsxfun(@gt,dev,limup(~isnan(limup)))))
    disp('    Spectral flatness failed');
else
    disp('    Spectral flatness passed');
end

% Plot spectral flatness limit
function lim = limitPlot(dBr,indRange,testSC,Nfft)
    lim = nan(numel(indRange),1);
    [~,ia] = intersect(indRange,testSC{1});
    lim(ia) = dBr(1)*ones(size(testSC{1}));
    [~,ia] = intersect(indRange,testSC{2});
    lim(ia) = dBr(2)*ones(size(testSC{2}));
    plot(hSFAx,indRange-Nfft/2-1,lim,'r-');
end

end

function [deviation,testSC] = spectralFlatness(cfgVHT,est)
    % Spectral flatness test assumes wired link between each transmit and
    % receive antenna, therefore only use the appropriate channel
    % estimates (an identity matrix for each subcarrier).
    [Nst,Nsts,~] = size(est);
    t = repmat(permute(eye(cfgVHT.NumSpaceTimeStreams),[3 1 2]),Nst,1,1);
    estUse = reshape(est(t==1),Nst,[]);

    [ofdmInfo,dInd,pInd] = wlan.internal.wlanGetOFDMConfig( ...
        cfgVHT.ChannelBandwidth,'Long','VHT',cfgVHT.NumSpaceTimeStreams);

    % Store channel estimates in subcarrier locations with nulls
    estFullFFT = zeros(ofdmInfo.FFTLength,Nsts);
    estFullFFT(ofdmInfo.DataIndices,:) = estUse(dInd,:);
    estFullFFT(ofdmInfo.PilotIndices,:) = estUse(pInd,:);

    % Subcarriers used for the measurement as per IEEE Std 802.11ac-2013
    % Table 22-23.
    switch cfgVHT.ChannelBandwidth
        case 'CBW20' 
            avSC = [-16:-1 1:16]+ofdmInfo.FFTLength/2+1; % Average subcarrier indices
            testSC{1} = avSC; % Lower test subcarrier indices
            testSC{2} = [-28:-17 17:28]+ofdmInfo.FFTLength/2+1; % Upper test subcarrier indices
        case 'CBW40' 
            avSC = [-42:-2 2:42]+ofdmInfo.FFTLength/2+1;
            testSC{1} = avSC;
            testSC{2} = [-58:-43 43:58]+ofdmInfo.FFTLength/2+1;
        case 'CBW80' 
            avSC = [-84:-2 2:84]+ofdmInfo.FFTLength/2+1;
            testSC{1} = avSC;
            testSC{2} = [-122:-85 85:122]+ofdmInfo.FFTLength/2+1;
        otherwise % 'CBW160' 
            avSC = [-172:-130 -126:-44 44:126 130:172]+ofdmInfo.FFTLength/2+1;
            testSC{1} = avSC;
            testSC{2} = [-250:-173 -43:-6 6:43 173:250]+ofdmInfo.FFTLength/2+1;
    end
    
    % Calculate average magnitude of channel estimate
    avChanEst = 20*log10(mean(abs(estFullFFT(avSC,:))));
    
    % For each set of subcarrier indices calculate the deviation from the
    % average magnitude
    for i=1:numel(testSC)
        Eiavg = 20*log10(abs(estFullFFT(testSC{i},:)));
        chanEstDeviation{i} = bsxfun(@minus,Eiavg,avChanEst); %#ok<AGROW>
    end
    
    % Combine the subcarrier estimate deviations into one
    [~,idx] = sort([testSC{1} testSC{2}]);
    comb = [chanEstDeviation{1}; chanEstDeviation{2}];
    deviation = comb(idx,:,:);
end