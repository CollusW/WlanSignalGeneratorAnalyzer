% /*!
%  *  @brief     This script is used to simulate the performance of wlan phase tracking.
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

%% specified parameters
txPara.hWlanConfig.PSDULength = 1600;       % Number of bytes carried in the user payload

chPara.SwitchAWGN = true;                    % switch flag of AWGN.  true = add noise; false = not add noise.
chPara.SwitchMultipath =  true;              % switch flag of freq and phase offset. true = add freq and phase offset.
chPara.SwitchFreqPhaseOffset = true;        % switch flag of Multipath, true = add multipath channel, false = no multipath channel.

rxParaPhaseTrackingOff = rxPara;
rxParaPhaseTrackingOff.hCfgRecHTData.PilotPhaseTracking = 'None';
rxParaPhaseTrackingOn = rxPara;
rxParaPhaseTrackingOn.hCfgRecHTData.PilotPhaseTracking = 'PreEQ';

%% Start Timer
tStart = tic;

%% start test
recBitErrPtOff = zeros(NumTestLoop,length(SnrDbRange));
recBitErrPtOn = zeros(NumTestLoop,length(SnrDbRange));
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
        [recPPDU, recPSDUPtOff, rxEVM, rxEst] = Receiver(rxWaveform, rxParaPhaseTrackingOff);
        [recPPDU, recPSDUPtOn, rxEVM, rxEst] = Receiver(rxWaveform, rxParaPhaseTrackingOn);
        if ~isempty(recPSDUPtOff), recBitErrPtOff(idxTestLoop,idxSNR) = sum(abs(txPSDU-recPSDUPtOff)); else, recBitErrPtOff(idxTestLoop,idxSNR)=length(txPSDU); end
        if ~isempty(recPSDUPtOn), recBitErrPtOn(idxTestLoop,idxSNR) = sum(abs(txPSDU-recPSDUPtOn)); else, recBitErrPtOn(idxTestLoop,idxSNR)=length(txPSDU); end
    end
end

%% plot BER and PER
bitErrRatePtOff = sum(recBitErrPtOff)/(length(txPSDU)*NumTestLoop);
packetErrRatePtOff = sum(recBitErrPtOff>0)/NumTestLoop;
bitErrRatePtOn = sum(recBitErrPtOn)/(length(txPSDU)*NumTestLoop);
packetErrRatePtOn = sum(recBitErrPtOn>0)/NumTestLoop;
figure(10000);clf;
semilogy(SnrDbRange, bitErrRatePtOff); hold on;
semilogy(SnrDbRange, bitErrRatePtOn);
grid on; title('Bit Error Rate'); xlabel('SNR (dB)'); ylabel('BER'); legend('Phase Tracking Off', 'Phase Tracking On');
figure(20000);clf;
semilogy(SnrDbRange, packetErrRatePtOff); hold on;
semilogy(SnrDbRange, packetErrRatePtOn);
grid on; title('Packet Error Rate'); xlabel('SNR (dB)'); ylabel('PER'); legend('Phase Tracking Off', 'Phase Tracking On');

%% stop timer
tElapsed = toc(tStart);
fprintf('Total elapsed time = %.2fsec = %dmin %.2fsec\n', tElapsed, floor(tElapsed/60), tElapsed-floor(tElapsed/60)*60);
