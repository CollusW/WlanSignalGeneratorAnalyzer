% /*!
%  *  @brief     This script is used to simulate the BER and PER performance of each MSC.
%  *  @details   Use WLAN system toolbox.
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2018.09.30
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 2017.09.30. Collus Wang, first draft inherited from testEqualizationMethod.m}
%  */

clear all
clc
close all
addpath('../Functions');   % add path which contains the local functions.
addpath('../WlanToolbox');   % add path which contains the revised wlan system toolbox functions.

%% Start Timer
tStart = tic;
hWaitbar = waitbar(0,'Processing...0%%');

%% parameter generation
McsRange = 0:7;  % MCS range 0~7
NumTestLoop = 10000;                % number of loops in simulation
SnrDbRange = 10:5:40;        % SNR dB range
PSDULength = 1600;              % PSDU Length in byte
recBitErr = zeros(NumTestLoop,length(SnrDbRange));  % record of bit err in each MCS
bitErrRate = zeros(length(McsRange),length(SnrDbRange));
packetErrRate = zeros(length(McsRange),length(SnrDbRange));

for idxMCS = 1:length(McsRange)
    fprintf('MCS = MCS%d\n', McsRange(idxMCS));
    macPara = GenMacPara();     % Generate MAC parameter
    phyPara = GenPhyPara();     % Generate PHY common parameter
    phyPara.FlagGlobalDebugPlot = false;    % close all debug plot information for speed
    txPara = GenTxPara(phyPara);        % Generate Tx parameter
    txPara.hWlanConfig.MCS = McsRange(idxMCS);
    chPara = GenChPara(phyPara);        % Generate Channel parameter
    rxPara = GenRxPara(phyPara);        % Generate Rx parameter
    
    %% specified parameters
    txPara.hWlanConfig.PSDULength = PSDULength;       % Number of bytes carried in the user payload
    
    chPara.SwitchAWGN = true;                    % switch flag of AWGN.  true = add noise; false = not add noise.
    chPara.SwitchMultipath =  true;              % switch flag of freq and phase offset. true = add freq and phase offset.
    chPara.SwitchFreqPhaseOffset = true;        % switch flag of Multipath, true = add multipath channel, false = no multipath channel.
    
    rxPara.hCfgRecHTData.PilotPhaseTracking = 'PreEQ';
    
    %% start test
    for idxSNR = 1:length(SnrDbRange)
        idxSNR
        for idxTestLoop = 1:NumTestLoop
            if 1==mod(idxTestLoop-1,100)+1
                fprintf('idxTestLoop = %d\n', idxTestLoop);
                progress = ((idxMCS-1)*length(SnrDbRange)*NumTestLoop+(idxSNR-1)*NumTestLoop + idxTestLoop )/ (length(McsRange)*length(SnrDbRange)*NumTestLoop); % calculate percentage of progress
                tElapsed = toc(tStart);
                estimatedCompletionTime = tElapsed/progress*(1-progress);   % estimation of completion time
                updateMessage = sprintf('Processing...%.2f%%, Elapsed time: %.0f h, %.1f m\nEstimated completion time: %.0f h, %.1f m', ...
                    progress*100, floor(tElapsed/3600), mod(tElapsed,3600)/60, ...
                    floor(estimatedCompletionTime/3600), mod(estimatedCompletionTime,3600)/60);
                waitbar( progress ,hWaitbar,updateMessage);         % update waitbar
            end
            % Transmitter
            [txWaveform, txPPDU, txPSDU] = GenTxWaveform(macPara, txPara);
            
            % Channel
            chPara = GenChPara(phyPara);        % Generate Channel parameter
            chPara.AwgnChannel.EbNo = SnrDbRange(idxSNR);
            rxWaveform = ChannelSim(txWaveform, chPara);
            
            % Receiver
            [recPPDU, recPSDU, rxEVM, rxEst] = Receiver(rxWaveform, rxPara);
            if ~isempty(recPSDU), recBitErr(idxTestLoop,idxSNR) = sum(abs(txPSDU-recPSDU)); else, recBitErr(idxTestLoop,idxSNR)=length(txPSDU); end
        end
    end
    bitErrRate(idxMCS,:) = sum(recBitErr)/(length(txPSDU)*NumTestLoop);
    packetErrRate(idxMCS,:) = sum(recBitErr>0)/NumTestLoop;
end

%% plot BER and PER
figure(10000);clf;
LineStyleMarker = {'o-', 'x-', '+-','*-','s-','d-','v-', '^-', '<-','>-', 'p-','h-', '-.'};
LineWidth = 1.5;
for idxMCS = 1:length(McsRange)
    semilogy(SnrDbRange, bitErrRate(idxMCS,:), LineStyleMarker{mod((idxMCS-1),length(LineStyleMarker))+1}, 'LineWidth', LineWidth); hold on;
end
grid on; title('Bit Error Rate'); xlabel('SNR (dB)'); ylabel('BER'); legend('MCS0','MCS1', 'MCS2', 'MCS3', 'MCS4', 'MCS5', 'MCS6', 'MCS7');

figure(20000);clf;
LineStyleMarker = {'o-', 'x-', '+-','*-','s-','d-','v-', '^-', '<-','>-', 'p-','h-', '-.'};
LineWidth = 1.5;
for idxMCS = 1:length(McsRange)
    semilogy(SnrDbRange, packetErrRate(idxMCS,:), LineStyleMarker{mod((idxMCS-1),length(LineStyleMarker))+1}, 'LineWidth', LineWidth); hold on;
end
grid on; title('Packet Error Rate'); xlabel('SNR (dB)'); ylabel('PER'); legend('MCS0','MCS1', 'MCS2', 'MCS3', 'MCS4', 'MCS5', 'MCS6', 'MCS7');

%% stop timer
tElapsed = toc(tStart);
fprintf('Total elapsed time = %.2fsec = %dmin %.2fsec\n', tElapsed, floor(tElapsed/60), mod(tElapsed,60));
close(hWaitbar)
