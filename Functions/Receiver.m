function [recPPDU, recPSDU, rxEVM, rxEst] = Receiver(rxWaveform, rxPara)
% /*!
%  *  @brief     This function is used to simulate the receiver.
%  *  @details   
%  *  @param[out] recPPDU, Lx1, rx PPDU bits.
%  *  @param[out] recPSDU, Mx1, rx PSDU bits.
%  *  @param[out] rxEVM, Kx1, rx evm in percentage.
%  *  @param[out] rxEst, 1x1, struct. The intermediate estimation results during rx process. Include the following fields:
%                       CoarseFreqOff, 1x1, double, coarse frequency offset estimation in Hz.
%                       FineFreqOff, 1x1, double, fine frequency offset estimation in Hz. The total frequency
%                          offset estimation is CoarseFreqOff+FineFreqOff.
%  *  @param[in] rxWaveform, Nx1, rx waveform.
%  *  @param[in] rxPara, 1x1 struct. rx structure.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.08.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.23. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.08.25. Collus Wang,  add spectrum mask test feature }
%  * @remark   { revision history: V1.2, 2017.08.26. Collus Wang,  add Spectral flatness test feature }
%  * @remark   { revision history: V1.3, 2017.08.29. Collus Wang,  add EVM test feature }
%  * @remark   { revision history: V1.4, 2017.09.02. Collus Wang,  add pilot EVM feature }
%  * @remark   { revision history: V1.5, 2017.09.02. Collus Wang,  fix channel estimation plot bug and optimize display.}
%  * @remark   { revision history: V1.6, 2017.09.08. Collus Wang,  1. export rxEst struct for performance tests. 2.FlagDebugPlot can be set from rxPara}
%  * @remark   { revision history: V1.7, 2017.09.08. Collus Wang,  HTData recovery configuration is parameterized in rxPara for performance evaluation script. }
%  * @remark   { revision history: V1.8, 2017.09.15. Collus Wang,  add LO leakage test feature. }
%  * @remark   { revision history: V1.9, 2017.09.15. Collus Wang,  add frequency tolerance test feature. }
%  * @remark   { revision history: V1.10, 2017.09.23. Collus Wang,  re-arrange figure layouts. }
%  * @remark   { revision history: V1.11, 2017.09.26. Collus Wang,  LSIG/HTSIG recovery configuration is parameterized in rxPara for performance evaluation script. }
%  * @remark   { revision history: V1.12, 2017.11.22. Collus Wang,  fix bug: grpdelay is set to 0 if oversampling=1. }
%  * @remark   { revision history: V1.13, 2018.01.25. Collus Wang,  Code structure optimization. rename some field name accordingly.}
%  */

% Flags
FlagDebugPlot = true && rxPara.FlagDebugPlot;
FigureStartNum = 300;

% Output init.
recPPDU = [];
recPSDU = [];
rxEVM = [];
rxEst = [];

% Get used field from input arguments
hWlanConfig = rxPara.hWlanConfig;
RxSampleRate = rxPara.MasterSampleRate; % Rx ADC Sample Rate in SPS.
cfgRecLSIG = rxPara.hCfgRecLSIG;
cfgRecHTDATA = rxPara.hCfgRecHTData;
CenterFreq = rxPara.CenterFreq;

% Generated parameters
SampleRate = helperSampleRate(hWlanConfig);     % Baseband nominal sampling rate in SPS
fieldIdx = wlanFieldIndices(hWlanConfig);       % Indices for accessing each field within the time-domain packet
OverSampling = RxSampleRate/SampleRate;

% Resample to baseband sample rate
if OverSampling>1
    % Decimate the waveform
    osf = OverSampling;         % Oversampling factor
    filterLen = 120; % Filter length
    beta = 0.5;      % Design parameter for Kaiser window

    % Generate filter coefficients
    coeffs = firnyquist(filterLen,osf,kaiser(filterLen+1,beta));
    coeffs = coeffs(1:end-1); % Remove trailing zero
    padZeros = zeros(osf-mod(length(rxWaveform), osf), 1);
    decimationFilter = dsp.FIRDecimator(osf,'Numerator',coeffs);
    if FlagDebugPlot
        rxWaveformOversample = rxWaveform;  % save for plot
    end
    rxWaveform = decimationFilter([rxWaveform;padZeros]);
    if FlagDebugPlot
        hFig = figure(FigureStartNum+0); clf;
        figureInfo = GetFigurePara('TimeDomain');
        hFig.Position = figureInfo.Position;
        time = ([0:length(rxWaveformOversample)-1].'/RxSampleRate)*1e6;
        semilogy(time, abs(rxWaveformOversample) );
        hold on;
        time = ([0:length(rxWaveform)-1].'/(RxSampleRate/OverSampling))*1e6;
        semilogy(time, abs(rxWaveform));
        grid on;
        xlabel ('Time (microseconds)')
        ylabel('Magnitude (dB)')
        legend('Before decimation', 'After decimation')
        title('Time Domain RX waveform')
    end
else % no oversampling
    if FlagDebugPlot
        rxWaveformOversample = rxWaveform; % save for plot
        hFig = figure(FigureStartNum+0); clf;
        figureInfo = GetFigurePara('TimeDomain');
        hFig.Position = figureInfo.Position;
        time = ([0:length(rxWaveformOversample)-1].'/RxSampleRate)*1e6;
        semilogy(time, abs(rxWaveformOversample) );
        hold on;
        time = ([0:length(rxWaveform)-1].'/(RxSampleRate/OverSampling))*1e6;
        semilogy(time, abs(rxWaveform));
        grid on;
        xlabel ('Time (microseconds)')
        ylabel('Magnitude (dB)')
        legend('Before decimation', 'After decimation')
        title('Time Domain RX waveform')
    end
end

% Receiver processing
%% Packet Detection (Coarse packet offset)
ThdPacketDetection = 0.5;
[coarsePktOffset, decisionStatistics ] = wlanPacketDetect(rxWaveform, hWlanConfig.ChannelBandwidth, 0, ThdPacketDetection);
if isempty(coarsePktOffset) % If empty no L-STF detected; return and packet error
    return
end
if FlagDebugPlot
    figure(FigureStartNum+5); clf;
    plot(decisionStatistics); hold on;
    plot([1,length(decisionStatistics)],[ThdPacketDetection, ThdPacketDetection], 'r--'); grid on;    
    legend('Decision Statistics', 'Threshold')
    ylabel('autocorrStatistics')
    title('Packet Detection')
end

%% Coarse frequency offset correction
% Extract L-STF and perform coarse frequency offset correction
lstf = rxWaveform(coarsePktOffset+(fieldIdx.LSTF(1):fieldIdx.LSTF(2)),:);
coarseFreqOff = wlanCoarseCFOEstimate(lstf, hWlanConfig.ChannelBandwidth);
rxWaveform = helperFrequencyOffset(rxWaveform, SampleRate, -coarseFreqOff);
if FlagDebugPlot
    % Center frequency tolerance test.
    fprintf('Center Frequency Tolerance Test\n');
    fprintf('\tCoarse frequency offset estimation = %+.2f Hz\n', coarseFreqOff);
end
rxEst.CoarseFreqOff = coarseFreqOff;    % save for output.

%% Fine packet offset
% Extract the Non-HT fields and determine fine packet offset using cross-correlation with locally generated L-LTF of the first transmit antenna.
nonhtfields = rxWaveform(coarsePktOffset+(fieldIdx.LSTF(1):fieldIdx.LSIG(2)),:);
ThdSymbolTiming = 0.5;
[finePktOffset, decisionStatistics] = wlanSymbolTimingEstimate(nonhtfields, hWlanConfig.ChannelBandwidth, ThdSymbolTiming);
if FlagDebugPlot
    figure(FigureStartNum+10); clf;
    plot(decisionStatistics); hold on;
    plot([1,length(decisionStatistics)],[ThdSymbolTiming, ThdSymbolTiming], 'r--'); grid on;    
    legend('Decision Statistics', 'Threshold')
    ylabel('autocorrStatistics')
    title('Symbol Timing')
end

% Determine final packet offset
pktOffset = coarsePktOffset+finePktOffset;

%% Early termination
% % If packet detected outside the range of expected delays from the
% % channel modeling; packet error
% if pktOffset>chDelay
%     numPacketErrors = numPacketErrors+1;
%     numPkt = numPkt+1;
%     continue; % Go to next loop iteration
% end

%% Fine frequency offset correction
% Extract L-LTF and perform fine frequency offset correction
lltf = rxWaveform(pktOffset+(fieldIdx.LLTF(1):fieldIdx.LLTF(2)),:);
fineFreqOff = wlanFineCFOEstimate(lltf, hWlanConfig.ChannelBandwidth);
rxWaveform = helperFrequencyOffset(rxWaveform, SampleRate, -fineFreqOff);
if FlagDebugPlot
    % The transmitter center frequency tolerance shall be ¡À 20 ppm maximum for the 5 GHz band and ¡À 25 ppm maximum for the 2.4 GHz band.
    if abs(CenterFreq - 5e9) < abs(CenterFreq - 2.4e9)
        FrequencyTolerancePpm = 20;
    else
        FrequencyTolerancePpm = 25;
    end
    totalFreqOff = coarseFreqOff+fineFreqOff;
    totalFreqOffPpm = totalFreqOff/CenterFreq*1e6;
    fprintf('\tFine frequency offset estimation = %+.2f Hz\n', fineFreqOff);
    fprintf('\tTotal frequency offset estimation = %+.2f Hz = %+.2f ppm\n', totalFreqOff, totalFreqOffPpm);
    fprintf('\tRequired limits = %.0f ppm = %.2f kHz\n', FrequencyTolerancePpm, FrequencyTolerancePpm/1e6*CenterFreq/1e3);
    if abs(totalFreqOff/CenterFreq*1e6) < FrequencyTolerancePpm
        fprintf('\tPassed with margin %.2f ppm.\n', FrequencyTolerancePpm - abs(totalFreqOffPpm));
    else
        fprintf('\tFailed with margin %.2f ppm.\n', FrequencyTolerancePpm - abs(totalFreqOffPpm));
    end
end
rxEst.FineFreqOff = fineFreqOff;    % save for output.

%% Channel estimation L-LTF
lltf = rxWaveform(pktOffset+(fieldIdx.LLTF(1):fieldIdx.LLTF(2)),:);
demodLLTF = wlanLLTFDemodulate(lltf,hWlanConfig.ChannelBandwidth);
chanEstLLTF = wlanLLTFChannelEstimate(demodLLTF, hWlanConfig.ChannelBandwidth);
if FlagDebugPlot
    [InfoOfdmLegacy, IdxDataLegacy, IdxPilotLegacy] = wlan.internal.wlanGetOFDMConfig(hWlanConfig.ChannelBandwidth,'Long', ...
        'Legacy',hWlanConfig.NumSpaceTimeStreams);
    figure(FigureStartNum+20); clf;
    plot(reshape(demodLLTF, [],1), '.')
    axis equal; grid on;
    xlabel ('I-phase'); ylabel('Q-phase'); title('L-LTF demodulation')
    figure(FigureStartNum+21); clf;
    plotInd = InfoOfdmLegacy.DataIndices-InfoOfdmLegacy.FFTLength/2-1;
    stem(plotInd, abs(chanEstLLTF(IdxDataLegacy)), '.'); hold on;
    plotInd = InfoOfdmLegacy.PilotIndices-InfoOfdmLegacy.FFTLength/2-1;
    stem(plotInd, abs(chanEstLLTF(IdxPilotLegacy)), '+')
    grid on; legend('Data subcarriers', 'Pilot subcarriers', 'Location', 'best')
    xlabel ('Subcarrier index'); ylabel('Magnitude'); title('channel estimation with L-LTF')
    
    % Transmit Center Frequency Leakage Test
    fprintf('Transmit Center Frequency Leakage Test\n');
    % Method 1: Time domain
    Pdc = abs(mean(lltf))^2;
    Ptotal = sum(abs(lltf).^2);
    LoLeakagedBTime = pow2db(Pdc/Ptotal);
    LoLeakagedBTimeThd = -17;
    fprintf('\tRelative to overall transmitted power:\n');
    fprintf('\t\tLO leakage = %.2fdB. Required: <%.2fdB.\n', LoLeakagedBTime, LoLeakagedBTimeThd);
    if LoLeakagedBTime < LoLeakagedBTimeThd
        fprintf('\t\tPassed with margin %.2fdB.\n', LoLeakagedBTimeThd-LoLeakagedBTime);
    else
        fprintf('\t\tFailed with margin %.2fdB.\n', LoLeakagedBTimeThd-LoLeakagedBTime);
    end    
    % Method 2: Freq domain
    PSubcarrierDc = abs(sum(lltf)/InfoOfdmLegacy.FFTLength).^2;
    PsubcarrierRest = rms(reshape(demodLLTF,[],1)).^2;
    LoLeakagedBFreq = pow2db(PSubcarrierDc/PsubcarrierRest);
    LoLeakagedBFreqThd = 0;
    fprintf('\tRelative to the average energy of the rest of the subcarriers:\n');
    fprintf('\t\tLO leakage = %.2fdB. Required: <%.2fdB.\n', LoLeakagedBFreq, LoLeakagedBFreqThd);
    if LoLeakagedBFreq < LoLeakagedBFreqThd
        fprintf('\t\tPassed with margin %.2fdB.\n', LoLeakagedBFreqThd-LoLeakagedBFreq);
    else
        fprintf('\t\tFailed with margin %.2fdB.\n', LoLeakagedBFreqThd-LoLeakagedBFreq);
    end
    
end

%% Estimate noise power in using L-LTF
nVarLLTF = helperNoiseEstimate(demodLLTF,hWlanConfig.ChannelBandwidth,...
    hWlanConfig.NumSpaceTimeStreams);

%% Decode L-SIG
lsig = rxWaveform(pktOffset+(fieldIdx.LSIG(1):fieldIdx.LSIG(2)),:);
% cfgRecLSIG = wlanRecoveryConfig('EqualizationMethod','MMSE');
[recLSIG, flagFailCheckLSIG, eqSymLSIG, cpeLSIG] = wlanLSIGRecover(lsig, chanEstLLTF, nVarLLTF, hWlanConfig.ChannelBandwidth, cfgRecLSIG);
if FlagDebugPlot
    figure(FigureStartNum+30); clf;
    plot(eqSymLSIG, '.')
    axis equal; grid on;
    xlabel ('I-phase'); ylabel('Q-phase'); title('Equalized LSIG')
end

%% Evaluation of L-SIG
if ~flagFailCheckLSIG
%     % Recover packet parameters
%     rate = bi2de(double(recLSIG(1:3).'), 'left-msb');
%     if rate <= 1
%         MCS = rate + 6;
%     else
%         MCS = mod(rate, 6);
%     end
%     PSDULength = bi2de(double(recLSIG(6:17)'), 'right-msb');
%     
% %     % Obtain number of OFDM symbols in data field
% %     obj.pNumDataSymbols = getNumDataSymbols(obj);
%     cfgNonHT = wlanNonHTConfig;
%     cfgNonHT.MCS = MCS;
%     cfgNonHT.PSDULength = PSDULength;
%     mcsTable = wlan.internal.getRateTable(cfgNonHT);
%     Ntail = 6; Nservice = 16;
%     numDataSym = ceil((8*cfgNonHT.PSDULength + Nservice + Ntail)/mcsTable.NDBPS);
else % L-SIG parity failed
    return;
end

%% Determine packet format
lsightsig = rxWaveform(pktOffset+(fieldIdx.LSIG(1):fieldIdx.HTSIG(2)),:);
format = wlanFormatDetect(lsightsig,chanEstLLTF, nVarLLTF, hWlanConfig.ChannelBandwidth, cfgRecLSIG);

if ~strcmp(format,'HT-MF') % Switch back to packet detection if a format other than HT-MF is detected
    fprintf('Packet Format = %s. Only proceed with HT-MF format.\n', format);
    return
end

%% decode HT-SIG
htsig = rxWaveform(pktOffset+(fieldIdx.HTSIG(1):fieldIdx.HTSIG(2)),:);
[recHTSIG, flagFailCheckHTSIG, eqSymHTSIG, cpeHTSIG] = wlanHTSIGRecover(htsig,chanEstLLTF, nVarLLTF, hWlanConfig.ChannelBandwidth, cfgRecLSIG);
if FlagDebugPlot
    figure(FigureStartNum+40); clf;
    plot(reshape(eqSymHTSIG, [], 1), '.')
    axis equal; grid on;
    xlabel ('I-phase'); ylabel('Q-phase'); title('Equalized HT-SIG')
end
if ~flagFailCheckHTSIG
    % update decoding information with the HT-SIG information.
    MCS = bi2de(double(recHTSIG(1:7).'), 'right-msb');
    HTLENGTH = bi2de(double(recHTSIG(9:24).'), 'right-msb');
    hWlanConfig.MCS = MCS;
    hWlanConfig.PSDULength = HTLENGTH;
    fieldIdx.HTData = wlanFieldIndices(hWlanConfig, 'HT-Data');       % Indices for accessing each field within the time-domain packet
else % HT-SIG CRC failed
    return;
end

%% Channel estimation HT-LTF
% Extract HT-LTF samples from the waveform, demodulate and perform channel estimation
htltf = rxWaveform(pktOffset+(fieldIdx.HTLTF(1):fieldIdx.HTLTF(2)),:);
htltfDemod = wlanHTLTFDemodulate(htltf,hWlanConfig);
chanEstHTLTF = wlanHTLTFChannelEstimate(htltfDemod,hWlanConfig);
if FlagDebugPlot
    [InfoOfdmHT, IdxDataHT, IdxPilotHT] = wlan.internal.wlanGetOFDMConfig(hWlanConfig.ChannelBandwidth,'Long', ...
        'HT',hWlanConfig.NumSpaceTimeStreams);
    figure(FigureStartNum+50); clf;
    plot(htltfDemod, '.')
    axis equal; grid on;
    xlabel ('I-phase'); ylabel('Q-phase'); title('HT-LTF demodulation')
    figure(FigureStartNum+51); clf;
    plotInd = InfoOfdmHT.DataIndices-InfoOfdmHT.FFTLength/2-1;
    stem(plotInd, abs(chanEstHTLTF(IdxDataHT)), '.'); hold on;
    plotInd = InfoOfdmHT.PilotIndices-InfoOfdmHT.FFTLength/2-1;
    stem(plotInd, abs(chanEstHTLTF(IdxPilotHT)), '+')
    grid on; legend('Data subcarriers', 'Pilot subcarriers')
    xlabel ('Subcarrier index'); ylabel('Magnitude'); title('channel estimation with HT-LTF')
end

%% Spectral flatness measurement
if FlagDebugPlot
    fprintf('Spectral Flatness Test\n')
    [hSF,hCon,hEVM] = TxSetupPlots(hWlanConfig);  % Setup the measurement plots
    TxSpectralFlatnessMeasurement(chanEstHTLTF,hWlanConfig,1,hSF);
end

%% Decode HT-Data 
% Extract HT-Data samples from the waveform and recover the PSDU
htdata = rxWaveform(pktOffset+(fieldIdx.HTData(1):fieldIdx.HTData(2)),:);
% cfgRecHTDATA = wlanRecoveryConfig('OFDMSymbolOffset', 0.75, ...
%     'EqualizationMethod','MMSE', ...    % MMSE  ZF
%     'PilotPhaseTracking', 'PreEQ', ...  % PreEQ  None 
%     'MaximumLDPCIterationCount', 12, ...
%     'EarlyTermination', false ... 
%     );
[recHTDATA,eqSymHTDATA, cpeHTDATA, eqSymPilot ]  = wlanHTDataRecover(htdata, chanEstHTLTF, nVarLLTF, hWlanConfig, cfgRecHTDATA);	% this is the revised function inherited from wlan system toolbox

if FlagDebugPlot
    hFig = figure(FigureStartNum+60); clf;
    figureInfo = GetFigurePara('Constellation');
    hFig.Position = figureInfo.Position;
    plot(reshape(eqSymHTDATA, [], 1), '.'); hold on;
    plot(reshape(eqSymPilot, [], 1), '.g');
    axis equal; grid on; legend('Data', 'Pilot', 'Location', 'best')
    xlabel ('I-phase'); ylabel('Q-phase'); title('Equalized HTDATA with Pilot')
end

%% EVM measurement
if FlagDebugPlot
    fprintf('EVM Test\n')
    % init. the configuration parameters for the ported code.
    numPackets = 1;
    eqSym = eqSymHTDATA;
    pktNum = 1;
    cfgVHT = hWlanConfig;
    
    % RMS EVM per packet. Measure average over subcarriers, OFDM symbols and spatial streams.
    EVMPerPkt = comm.EVM;
    EVMPerPkt.AveragingDimensions = [1 2 3]; % Nst-by-Nsym-by-Nss
    EVMPerPkt.Normalization = 'Average constellation power';
    EVMPerPkt.ReferenceSignalSource  = 'Estimated from reference constellation';
    EVMPerPkt.ReferenceConstellation = helperReferenceSymbols(cfgVHT);
    
    % RMS EVM per subcarrier per spatial stream for a packet. Measure average EVM over symbols
    EVMPerSC = comm.EVM;
    EVMPerSC.AveragingDimensions = 2; % Nst-by-Nsym-by-Nss
    EVMPerSC.Normalization = 'Average constellation power';
    EVMPerSC.ReferenceSignalSource  = 'Estimated from reference constellation';
    EVMPerSC.ReferenceConstellation = helperReferenceSymbols(cfgVHT);
    
    % EVM for pilots, accordingly.
    EVMPerPktPilot = clone(EVMPerPkt);
    EVMPerPktPilot.ReferenceConstellation = helperReferenceSymbols('BPSK');
    EVMPerSCPilot = clone(EVMPerSC);
    EVMPerSCPilot.ReferenceConstellation = helperReferenceSymbols('BPSK');
    
    rmsEVM = zeros(numPackets,1);
    % Compute RMS EVM over all spatial streams for packet
    rmsEVM(pktNum) = EVMPerPkt(eqSym);    rmsEVMPolit = EVMPerPktPilot(eqSymPilot);
    rmsEVMdB = 20*log10(rmsEVM(pktNum)/100); rmsEVMPolitdB = 20*log10(rmsEVMPolit/100);
    fprintf('    RMS Pilot EVM: %2.2f%%, %2.2fdB\n', ...
        rmsEVMPolit,rmsEVMPolitdB);
    fprintf('    RMS Data EVM: %2.2f%%, %2.2fdB\n', ...
        rmsEVM(pktNum),rmsEVMdB);
    
    % EVM Test criteria according to IEEE-802.11-2016 std. section 19.3.18.7.3 Transmitter constellation error
    switch hWlanConfig.MCS
        case num2cell([0,8,16,24]) % BPSK, 1/2 coding rate
            LimitsRmsEVMdB = -5;
        case num2cell([0,8,16,24]+1) % QPSK, 1/2 coding rate
            LimitsRmsEVMdB = -10;
        case num2cell([0,8,16,24]+2) % QPSK, 3/4 coding rate
            LimitsRmsEVMdB = -13;
        case num2cell([0,8,16,24]+3) % 16QAM, 1/2 coding rate
            LimitsRmsEVMdB = -16;
        case num2cell([0,8,16,24]+4) % 16QAM, 3/4 coding rate
            LimitsRmsEVMdB = -19;
        case num2cell([0,8,16,24]+5) % 64QAM, 2/3 coding rate
            LimitsRmsEVMdB = -22;
        case num2cell([0,8,16,24]+6) % 64QAM, 3/4 coding rate
            LimitsRmsEVMdB = -25;
        case num2cell([0,8,16,24]+7) % 64QAM, 5/6 coding rate
            LimitsRmsEVMdB = -27;
        otherwise
            error('Unsupported MCS in EVM test.')
    end
    fprintf('    Required limits = %.2f%%, %+5.2fdB\n', 100*10^(LimitsRmsEVMdB/20), LimitsRmsEVMdB);
    if rmsEVMdB < LimitsRmsEVMdB
        fprintf('    Constellation error test passed with margin %+.1fdB.\n', LimitsRmsEVMdB-rmsEVMdB);
    else
        fprintf('    Constellation error test failed with negative margin %+.1fdB\n', LimitsRmsEVMdB-rmsEVMdB);
    end
    
    % Compute RMS EVM per subcarrier and spatial stream for the packet
    evmPerSC = EVMPerSC(eqSym); % Nst-by-1-by-Nss
    evmPilotPerSC = EVMPerSCPilot(eqSymPilot);

    % Plot RMS EVM per subcarrier and equalized constellation
    TxEVMConstellationPlots(eqSym,evmPerSC, eqSymPilot, evmPilotPerSC, cfgVHT,pktNum,hCon,hEVM);
    
    % Save for output argument
    rxEVM = evmPerSC;
end

%% Spectrum Mask Test
if FlagDebugPlot
    fprintf('Received Spectrum Mask Test\n');
    osf = OverSampling;
    startIdx = osf*(fieldIdx.HTData(1)-1)+1;  % Upsampled start of HT Data
    endIdx = osf*fieldIdx.HTData(2);          % Upsampled end of HT Data
    if OverSampling>1
        delay = grpdelay(decimationFilter,1); % Group delay of downsampling filter
    else
        delay = 0;
    end
    pktOffsetOversampling = pktOffset*OverSampling-delay;
    gatedVHTData = rxWaveformOversample(pktOffsetOversampling+(startIdx:endIdx) , :);
    
    Mode = 'HT';
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
    helperSpectralMaskTest(gatedVHTData,SampleRate,OverSampling, dBrLimits,fLimits,rbw);
end
recPSDU = double(recHTDATA);

% make sure these figures are on the top layer.
if FlagDebugPlot
    figure(FigureStartNum+60);	% constellation
    figure(2);					% spectrum flatness
    figure(3);					% EVM
    figure(FigureStartNum+0);	% time domain
    show(spectrumAnalyzer{1});	% spectrum mask
end

end

% [EOF]