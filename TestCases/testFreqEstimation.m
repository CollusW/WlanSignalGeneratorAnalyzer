% /*!
%  *  @brief     This script is used to simulate the performance of wlan frequency offset estimation.
%  *  @details   Use WLAN system toolbox. 
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2018.08.23
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 2017.09.08. Collus Wang, first draft inherited from main.m}
%  */

clear all
clc
close all
addpath('../Functions');   % add path which contains the local functions.
addpath('../WlanToolbox');   % add path which contains the revised wlan system toolbox functions.

%% parameter generation
macPara = GenMacPara();     % Generate MAC parameter
phyPara = GenPhyPara();     % Generate PHY common parameter
phyPara.FlagGlobalDebugPlot = false;    % close all debug plot information for speed
txPara = GenTxPara(phyPara);        % Generate Tx parameter
chPara = GenChPara(phyPara);        % Generate Channel parameter
rxPara = GenRxPara(phyPara);        % Generate Rx parameter

NumTestLoop = 200;                % number of loops in simulation
SnrDbRange = 10:5:40;        % SNR dB range
FreqPpm = 20;               % frequency accuracy in ppm.

%% specified parameters
chPara.SwitchAWGN = true;                    % switch flag of AWGN.  true = add noise; false = not add noise.
chPara.SwitchMultipath =  true;              % switch flag of freq and phase offset. true = add freq and phase offset.
chPara.SwitchFreqPhaseOffset = true;        % switch flag of Multipath, true = add multipath channel, false = no multipath channel.

%% Start Timer
tStart = tic;

%% start test
recCoarseFreqErr = zeros(NumTestLoop,length(SnrDbRange));
recFineFreqErr = zeros(NumTestLoop,length(SnrDbRange));
% Transmitter
[txWaveform, txPPDU, txPSDU] = GenTxWaveform(macPara, txPara);
for idxSNR = 1:length(SnrDbRange)
    idxSNR
    chPara.AwgnChannel.EbNo = SnrDbRange(idxSNR);
    for idxTestLoop = 1:NumTestLoop
        % specified parameters
        chPara.PhaseFreqOffset.FrequencyOffset = (rand*2-1)*FreqPpm/1e6*phyPara.CenterFreq;   % frequency offset, in Hz. Valid only when SwitchFreqPhaseOffset = true.
        chPara.PhaseFreqOffset.PhaseOffset = rand*360/180*pi;          % phase offset, in rad. Valid only when SwitchFreqPhaseOffset = true.

        % Channel
        rxWaveform = ChannelSim(txWaveform, chPara);
        
        % Receiver
        [recPPDU, recPSDU, rxEVM, rxEst] = Receiver(rxWaveform, rxPara);
        recCoarseFreqErr(idxTestLoop,idxSNR) = rxEst.CoarseFreqOff - chPara.PhaseFreqOffset.FrequencyOffset;
        recFineFreqErr(idxTestLoop,idxSNR) = (rxEst.CoarseFreqOff+rxEst.FineFreqOff) - chPara.PhaseFreqOffset.FrequencyOffset;
    end
end

%% plot Coarse CFO estimation
meanCoarseFreqErr = mean(recCoarseFreqErr);
stdCoarseFreqErr = std(recCoarseFreqErr);
figure(10000);clf;
plot(SnrDbRange, meanCoarseFreqErr); grid on; title('Mean of Coarse Freq. Est. Error'); xlabel('SNR (dB)'); ylabel('Freq Error (Hz)');
figure(20000);clf;
plot(SnrDbRange, stdCoarseFreqErr); grid on; title('STD of Coarse Freq. Est. Error'); xlabel('SNR (dB)'); ylabel('Freq Error (Hz)');
figure(30000); clf;
plot(SnrDbRange, recCoarseFreqErr, '.b'); grid on; title('Record of Coarse Freq. Estimation Error'); xlabel('SNR (dB)'); ylabel('Freq Error (Hz)');

%% plot Fine CFO estimation
meanFineFreqErr = mean(recFineFreqErr);
stdFineFreqErr = std(recFineFreqErr);
figure(40000);clf;
plot(SnrDbRange, meanFineFreqErr); grid on; title('Mean of Fine Freq. Est. Error'); xlabel('SNR (dB)'); ylabel('Freq Error (Hz)');
figure(50000);clf;
plot(SnrDbRange, stdFineFreqErr); grid on; title('STD of Fine Freq. Est. Error'); xlabel('SNR (dB)'); ylabel('Freq Error (Hz)');
figure(60000); clf;
plot(SnrDbRange, recFineFreqErr, '.b'); grid on; title('Record of Fine Freq. Estimation Error'); xlabel('SNR (dB)'); ylabel('Freq Error (Hz)');

%% stop timer
tElapsed = toc(tStart);
fprintf('Total elapsed time = %.2fsec = %dmin %.2fsec\n', tElapsed, floor(tElapsed/60), tElapsed-floor(tElapsed/60)*60);
