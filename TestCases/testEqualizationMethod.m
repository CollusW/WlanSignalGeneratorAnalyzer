% /*!
%  *  @brief     This script is used to simulate the performance of equalization methods.
%  *  @details   Use WLAN system toolbox. 
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2018.09.26
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 2017.09.26. Collus Wang, first draft inherited from testPhaseTracking.m}
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

NumTestLoop = 2000;                % number of loops in simulation
SnrDbRange = 10:5:40;        % SNR dB range

%% specified parameters
txPara.hWlanConfig.PSDULength = 1600;       % Number of bytes carried in the user payload

chPara.SwitchAWGN = true;                    % switch flag of AWGN.  true = add noise; false = not add noise.
chPara.SwitchMultipath =  true;              % switch flag of freq and phase offset. true = add freq and phase offset.
chPara.SwitchFreqPhaseOffset = true;        % switch flag of Multipath, true = add multipath channel, false = no multipath channel.

rxParaMMSE = rxPara;
rxParaMMSE.hCfgRecLSIG.EqualizationMethod = 'MMSE';
rxParaMMSE.hCfgRecHTData.EqualizationMethod = 'MMSE';
rxParaZF = rxPara;
rxParaZF.hCfgRecLSIG.EqualizationMethod = 'ZF';
rxParaMMSE.hCfgRecHTData.EqualizationMethod = 'ZF';

%% Start Timer
tStart = tic;

%% start test
recBitErrMmse = zeros(NumTestLoop,length(SnrDbRange));
recBitErrZf = zeros(NumTestLoop,length(SnrDbRange));
% recFineFreqErr = zeros(NumTestLoop,length(SnrDbRange));
for idxSNR = 1:length(SnrDbRange)
    idxSNR
    for idxTestLoop = 1:NumTestLoop
        if mod(idxTestLoop,20), fprintf('idxTestLoop = %d\n', idxTestLoop); end
        % Transmitter
        [txWaveform, txPPDU, txPSDU] = GenTxWaveform(macPara, txPara);
        
        % Channel
        chPara = GenChPara(phyPara);        % Generate Channel parameter
        chPara.AwgnChannel.EbNo = SnrDbRange(idxSNR);
        rxWaveform = ChannelSim(txWaveform, chPara);
        
        % Receiver
        [recPPDU, recPSDUMmse, rxEVM, rxEst] = Receiver(rxWaveform, rxParaMMSE);
        [recPPDU, recPSDUZf, rxEVM, rxEst] = Receiver(rxWaveform, rxParaZF);
        if ~isempty(recPSDUMmse), recBitErrMmse(idxTestLoop,idxSNR) = sum(abs(txPSDU-recPSDUMmse)); else, recBitErrMmse(idxTestLoop,idxSNR)=length(txPSDU); end
        if ~isempty(recPSDUZf), recBitErrZf(idxTestLoop,idxSNR) = sum(abs(txPSDU-recPSDUZf)); else, recBitErrZf(idxTestLoop,idxSNR)=length(txPSDU); end
    end
end

%% plot BER and PER
bitErrRateMmse = sum(recBitErrMmse)/(length(txPSDU)*NumTestLoop);
packetErrRateMmse = sum(recBitErrMmse>0)/NumTestLoop;
bitErrRateZf = sum(recBitErrZf)/(length(txPSDU)*NumTestLoop);
packetErrRateZf = sum(recBitErrZf>0)/NumTestLoop;
figure(10000);clf;LineWidth = 1.5;
semilogy(SnrDbRange, bitErrRateMmse,'o-','LineWidth', LineWidth); hold on;
semilogy(SnrDbRange, bitErrRateZf,'x-','LineWidth', LineWidth);
grid on; title('Bit Error Rate'); xlabel('SNR (dB)'); ylabel('BER'); legend('MMSE', 'Zero-Forcing');
figure(20000);clf;
semilogy(SnrDbRange, packetErrRateMmse,'o-','LineWidth', LineWidth); hold on;
semilogy(SnrDbRange, packetErrRateZf,'x-','LineWidth', LineWidth);
grid on; title('Packet Error Rate'); xlabel('SNR (dB)'); ylabel('PER'); legend('MMSE', 'Zero-Forcing');

%% stop timer
tElapsed = toc(tStart);
fprintf('Total elapsed time = %.2fsec = %dmin %.2fsec\n', tElapsed, floor(tElapsed/60), tElapsed-floor(tElapsed/60)*60);
