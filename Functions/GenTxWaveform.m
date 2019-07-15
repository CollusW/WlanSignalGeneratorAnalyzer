function [txWaveform, txPPDU, txPSDU] = GenTxWaveform(macPara, txPara)
% /*!
%  *  @brief     This function is used to simulate the transmitter, generate tx waveform.
%  *  @details   
%  *  @param[out] txWaveform, Nx1, tx waveform.
%  *  @param[out] txPPDU, Lx1, tx PPDU bits.
%  *  @param[out] txPSDU, Mx1, tx PSDU bits.
%  *  @param[in] macPara, 1x1 struct. MAC parameters structure.
%  *  @param[in] txPara, 1x1 struct. Tx parameters structure.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.08.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.23. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.09.08. Collus Wang,  FlagDebugPlot can be set from txPara}
%  * @remark   { revision history: V1.2, 2018.01.25. Collus Wang,  Code structure optimization. rename some field name accordingly.}
%  */

% Debug switches and parameters
FlagDebugPlot = true && txPara.FlagDebugPlot;
FigureStartNum = 100;

% Extract used fields
hWlanConfig = txPara.hWlanConfig;
OverSampling = txPara.OverSampling;
MasterSampleRate = txPara.MasterSampleRate; % DAC sample rate after over sampling.
IdleTime = txPara.IdleTime;

txPSDU = randi([0 1],hWlanConfig.PSDULength*8,1);

lstf = wlanLSTF(hWlanConfig);
lltf = wlanLLTF(hWlanConfig);
lsig = wlanLSIG(hWlanConfig);
htsig = wlanHTSIG(hWlanConfig);
htstf = wlanHTSTF(hWlanConfig);
htltf = wlanHTLTF(hWlanConfig);
htData = wlanHTData(txPSDU,hWlanConfig);

txPPDU = [lstf; lltf; lsig; htsig; htstf; htltf; htData];

if IdleTime>0
    padZeros = zeros(round(IdleTime*MasterSampleRate/OverSampling), 1);
    txPPDU = [txPPDU; padZeros];
end
    
if FlagDebugPlot
    SampleRate = txPara.SampleRate;         % Baseband nominal sampling rate in SPS, without oversampling.
    fieldIdx = wlanFieldIndices(hWlanConfig);
    
    figure(FigureStartNum+0); clf;
    subplot(211);
    time = ([0:length(txPPDU)-1].'/SampleRate)*1e6;
    PlotWithMarkers(time, abs(txPPDU), fieldIdx.HTLTF(2) );
    grid on;
    xlabel ('Time (microseconds)')
    ylabel('Magnitude')
    title('HT PPDU = Preamble + Data')
    subplot(212)
    numSamples = double(fieldIdx.HTLTF(2)); % The stop index of HT-LTF indicates the preamble length in samples.
    time = ([0:numSamples-1].'/SampleRate)*1e6;
    PlotWithMarkers(time, abs(txPPDU(1:numSamples)), double([fieldIdx.LSTF(2),fieldIdx.LLTF(2), fieldIdx.LSIG(2), fieldIdx.HTSIG(2),fieldIdx.HTSTF(2), fieldIdx.HTLTF(2)]) );
    grid on;
    xlabel ('Time (microseconds)')
    ylabel('Magnitude')
    title('HT Preamble = LSTF + LLTF + LSIG + HTSIG + HSTF + HTLTF')

    hCCDF = comm.CCDF('PAPROutputPort', true);
    [~,~,papr] = hCCDF(txPPDU);
    fprintf('PAPR of txPPDU = %5.2f dB\n', papr);
    figure(FigureStartNum+10); clf;
    plot(hCCDF);
    legend('txPPDU')
    
    % L-STF
    figure(FigureStartNum+11); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(lstf, SampleRate); grid on; title('L-STF Time');
    subplot(2,2, 2); PlotFreqDomain(lstf(33:end), SampleRate); grid on; title('L-STF Freq');
    subplot(2,2, 4); PlotConsDomain(lstf(33:end)); grid on; title('L-STF Contellation');
    % L-LTF
    figure(FigureStartNum+12); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(lltf, SampleRate); grid on; title('L-LTF Time');
    subplot(2,2, 2); PlotFreqDomain(lltf(33:end), SampleRate); grid on; title('L-LTF Freq');
    subplot(2,2, 4); PlotConsDomain(lltf(33:end)); grid on; title('L-LTF Contellation');
    % L-SIG
    figure(FigureStartNum+13); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(lsig, SampleRate); grid on; title('L-SIG Time');
    subplot(2,2, 2); PlotFreqDomain(lsig((1:64)+16), SampleRate); grid on; title('L-SIG Freq');
    subplot(2,2, 4); PlotConsDomain(lsig((1:64)+16)); grid on; title('L-SIG Contellation');
    % HT-SIG1
    figure(FigureStartNum+14); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(htsig(1:80), SampleRate); grid on; title('HT-SIG1 Time');
    subplot(2,2, 2); PlotFreqDomain(htsig((1:64)+16), SampleRate); grid on; title('HT-SIG1 Freq');
    subplot(2,2, 4); PlotConsDomain(htsig((1:64)+16)); hold on; PlotConsDomainData(htsig((1:64)+16)); PlotConsDomainPilot(htsig((1:64)+16)); 
    legend('All', 'Data', 'Pilot'); title('HT-SIG1 Contellation');
    % HT-SIG2
    figure(FigureStartNum+15); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(htsig((1:80)+80), SampleRate); grid on; title('HT-SIG2 Time');
    subplot(2,2, 2); PlotFreqDomain(htsig((1:64)+16+80), SampleRate); grid on; title('HT-SIG2 Freq');
    subplot(2,2, 4); PlotConsDomain(htsig((1:64)+16+80)); hold on; PlotConsDomainData(htsig((1:64)+16+80)); PlotConsDomainPilot(htsig((1:64)+16+80)); grid on; 
    legend('All', 'Data', 'Pilot'); title('HT-SIG2 Contellation');
    % HT-STF
    figure(FigureStartNum+16); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(htstf, SampleRate); grid on; title('HT-STF Time');
    subplot(2,2, 2); PlotFreqDomain(htstf(17:end), SampleRate); grid on; title('HT-STF Freq');
    subplot(2,2, 4); PlotConsDomain(htstf(17:end)); grid on; title('HT-STF Contellation');
    % HT-LTF
    if length(htltf)>80; warning('More symbols are in HT-LTF. Only the first is shown in figure.'); end
    figure(FigureStartNum+17); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(htltf, SampleRate); grid on; title('HT-LTF Time');
    subplot(2,2, 2); PlotFreqDomain(htltf(17:end), SampleRate); grid on; title('HT-LTF Freq');
    subplot(2,2, 4); PlotConsDomain(htltf(17:end)); grid on; title('HT-LTF Contellation');
    % HT-DATA
    figure(FigureStartNum+18); clf;
    subplot(2,2,[1,3]); PlotTimeDomain(htData, SampleRate); grid on; title('HT-Data Time');
    for idxSymbol = 1:floor(length(htData)/80)
        idxTime = (17:80) + (idxSymbol-1)*80;
        subplot(2,2, 2); PlotFreqDomain(htData(idxTime), SampleRate); hold on;
        subplot(2,2, 4); PlotConsDomain(htData(idxTime)); hold on; PlotConsDomainData(htData(idxTime)); PlotConsDomainPilot(htData(idxTime)); 
    end
    subplot(2,2, 2); title('HT-Data Freq'); grid on;
    subplot(2,2, 4); title('HT-Data Contellation'); grid on; legend('All', 'Data', 'Pilot'); 
end

if OverSampling>1
    % Method 1
    % txWaveform = interp(txPPDU, OverSampling);
    
    % Method 2
    % Oversample the waveform
    osf = OverSampling;         % Oversampling factor
    filterLen = 120; % Filter length
    beta = 0.5;      % Design parameter for Kaiser window
    
    if IdleTime*MasterSampleRate < filterLen
        warning('Tx Filter length is longer than IdleTime. Packet may be truncated.')
    end
    
    % Generate filter coefficients
    coeffs = osf.*firnyquist(filterLen,osf,kaiser(filterLen+1,beta));
    coeffs = coeffs(1:end-1); % Remove trailing zero
    interpolationFilter = dsp.FIRInterpolator(osf,'Numerator',coeffs);
    txWaveform = interpolationFilter(txPPDU);
    
    % Plot the magnitude and phase response of the filter applied after
    % oversampling
    if FlagDebugPlot
        h = fvtool(interpolationFilter);
        h.Analysis = 'freq';           % Plot magnitude and phase responses
        h.FS = txPara.MasterSampleRate;                 % Set sampling rate
        h.NormalizedFrequency = 'off'; % Plot responses against frequency
    end
else    % no oversampling
    txWaveform = txPPDU;
end

%% HPA modeling
% hpaBackoff = 8; % dB
% 
% % Create and configure a memoryless nonlinearity to model the amplifier
% nonLinearity = comm.MemorylessNonlinearity;
% nonLinearity.Method = 'Rapp model';
% nonLinearity.Smoothness = 3; % p parameter
% nonLinearity.LinearGain = -hpaBackoff;
% 
% % Apply the model to each transmit antenna
% for i=1:cfgVHT.NumTransmitAntennas
%     txWaveform(:,i) = nonLinearity(txWaveform(:,i));
% end

%% Plot waveform
if FlagDebugPlot
    OverSampling = txPara.OverSampling;
    TxSampleRate = txPara.MasterSampleRate;

    fieldIdx = wlanFieldIndices(hWlanConfig);
    fieldNames = fieldnames(fieldIdx);
    for idxField = 1:length(fieldNames)
        tmp = getfield(fieldIdx, fieldNames{idxField}); %#ok<GFLD>
        tmp = [(tmp(1)-1)*OverSampling+1, tmp(2)*OverSampling];
        fieldIdx = setfield(fieldIdx, fieldNames{idxField}, tmp); %#ok<SFLD>
    end
    
    figure(FigureStartNum+20); clf;
    subplot(211);
    time = ([0:length(txWaveform)-1].'/TxSampleRate)*1e6;
    PlotWithMarkers(time, abs(txWaveform), fieldIdx.HTLTF(2) );
    grid on;
    xlabel ('Time (microseconds)')
    ylabel('Magnitude')
    title('HT PPDU waveform = Preamble + Data')
    subplot(212)
    numSamples = double(fieldIdx.HTLTF(2)); % The stop index of HT-LTF indicates the preamble length in samples.
    time = ([0:numSamples-1].'/TxSampleRate)*1e6;
    PlotWithMarkers(time, abs(txWaveform(1:numSamples)), double([fieldIdx.LSTF(2),fieldIdx.LLTF(2), fieldIdx.LSIG(2), fieldIdx.HTSIG(2),fieldIdx.HTSTF(2), fieldIdx.HTLTF(2)]) );
    grid on;
    xlabel ('Time (microseconds)')
    ylabel('Magnitude')
    title('HT Preamble waveform = LSTF + LLTF + LSIG + HTSIG + HSTF + HTLTF')

    hCCDF = comm.CCDF('PAPROutputPort', true);
    [~,~,papr] = hCCDF(txWaveform);
    fprintf('PAPR of txWaveform = %5.2f dB\n', papr);
    figure(FigureStartNum+10); hold on;
    plot(hCCDF);
    legend('txPPDU', 'txWaveform')
    
    %% Spectrum mask test
    fprintf('Trasmit Spectrum Mask Test\n');
    Mode = txPara.Mode;
    % config Tx mask parameters.
    cbwMHz = SampleRate/1e6;
    switch lower(Mode)
        case 'vht'
            %  From IEEE Std 802.11ac-2013 Section 22.3.18.1
            dBrLimits = [-40, -40, -28, -20, 0, 0, -20, -28, -40, -40];
            fLimits = [-Inf, -1.5*cbwMHz, -cbwMHz, -(cbwMHz/2+1), -(cbwMHz/2-1), ...
                (cbwMHz/2-1), (cbwMHz/2+1), cbwMHz, 1.5*cbwMHz, Inf];
            rbw = 100e3;      % Resolution bandwidth
        case 'ht'
            %  From IEEE Std 802.11-2016 Section 19.3.18.1
            dBrLimits = [-45, -45, -28, -20, 0, 0, -20, -28, -45, -45];            %  for 2.4 GHz band.
%             dBrLimits = [-40, -40, -28, -20, 0, 0, -20, -28, -40, -40];            %  for 5 GHz band.
            fLimits = [-Inf, -1.5*cbwMHz, -cbwMHz, -(cbwMHz/2+1), -(cbwMHz/2-1), ...
                (cbwMHz/2-1), (cbwMHz/2+1), cbwMHz, 1.5*cbwMHz, Inf];
            rbw = 100e3;      % Resolution bandwidth
        case 'non-ht'
            %  From IEEE Std 802.11-2016 Section 17.3.9.3
            dBrLimits = [-40, -40, -28, -20, 0, 0, -20, -28, -40, -40];
            fLimits = [-Inf, -1.5*cbwMHz, -cbwMHz, -(cbwMHz/2+1*cbwMHz/20), -(cbwMHz/2-1*cbwMHz/20), ...
                (cbwMHz/2-1*cbwMHz/20), (cbwMHz/2+1*cbwMHz/20), cbwMHz, 1.5*cbwMHz, Inf];
            rbw = 100e3;      % Resolution bandwidth
        case 'dmg'
            %  From IEEE Std 802.11-2016 Section 20.3.2
            dBrLimits = [-30, -30, -22, -17, 0, 0, -17, -22, -30, -30];
            fLimits = [-Inf, -3.06, -2.7, -1.2, -0.94, 0.94, 1.2, 2.7, 3.06, Inf] * 1e3;
            rbw = 1e6; % Resolution bandwidth in Hz
        otherwise
            error('Unsupported mode for tx spectrum mask test')
    end
    gatedVHTData = txWaveform(fieldIdx.HTData(1):fieldIdx.HTData(2), :);
    helperSpectralMaskTest(gatedVHTData,SampleRate,OverSampling, dBrLimits,fLimits,rbw);
    
end


end


function [] = PlotWithMarkers(xdata, ydata, markerIdx )
    fieldMarkers = zeros(length(ydata),1);
    peak = 1.2*max(abs(ydata));
    fieldMarkers(markerIdx) = peak;
    plot(xdata, ydata); hold on;
    stem(xdata+(xdata(2)-xdata(1))/2, fieldMarkers, '--r', 'Marker', 'none' );
end

function hPlot = PlotTimeDomain(tdata, SampleRate)
time = (0:length(tdata)-1)/SampleRate*1e6;
hPlot = plot(time, abs(tdata));
xlabel ('Time (microseconds)')
ylabel('Magnitude')
end

function hPlot = PlotFreqDomain(tdata, SampleRate)
freq =  ([0:length(tdata)-1]-length(tdata)/2)*SampleRate/length(tdata)/1e6;
fdata = abs(fftshift(fft(tdata)));
hPlot = stem(freq, fdata, '.-');
xlabel ('Frequency (MHz)')
ylabel('Magnitude')
end

function hPlot = PlotConsDomain(tdata)
fdata = fftshift(fft(tdata));
hPlot = plot(fdata, '.--'); axis equal;
xlabel ('I-phase')
ylabel('Q-phase')
end

function hPlot = PlotConsDomainPilot(tdata)
fdata = fftshift(fft(tdata));
pilotIdx = [7,-7,21,-21]+33;
hPlot = plot(fdata(pilotIdx), 'or'); axis equal;
xlabel ('I-phase')
ylabel('Q-phase')
end

function hPlot = PlotConsDomainData(tdata)
fdata = fftshift(fft(tdata));
dataIdx = (-26:26);
dataIdx([0,-7,7,21,-21]+27) = [];   % remove pilot subcarriers
dataIdx = dataIdx +33;
hPlot = plot(fdata(dataIdx), '.b'); axis equal;
xlabel ('I-phase')
ylabel('Q-phase')
end
