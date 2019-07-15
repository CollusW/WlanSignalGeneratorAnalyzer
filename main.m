% /*!
%  *  @brief     This script is used to serve as an standard wlan transmitter and receiver.
%  *  @details   Use WLAN system toolbox. 
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2018.08.23
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 2017.08.23. Collus Wang, first draft }
%  * @remark   { revision history: V1.1 2017.10.06. Collus Wang, add read rx waveform from Matlab Baseband signal file feature. }
%  * @remark   { revision history: V1.1 2017.11.04. Collus Wang, get packetError only in simulation mode. }
%  * @remark   { revision history: V1.2 2018.01.25. Collus Wang, optimization of code structure. }
%  */

clear all
clc
close all
addpath('./Functions');   % add path which contains the local functions.
addpath('./WlanToolbox');   % add path which contains the revised wlan system toolbox functions.
addpath('./Driver/LimeSDR');

%% parameter generation
macPara = GenMacPara();     % Generate MAC parameter
phyPara = GenPhyPara();     % Generate PHY parameter, including TxPhy, TxSink, RxPhy, RxSource, and Channel, etc.  

%% Tx
if phyPara.FlagTxEnable
    fprintf('\nGeneration of Tx waveform...');
    [txWaveform, txPPDU, txPSDU] = GenTxWaveform(macPara, phyPara.TxPhyPara);    % Generation of Tx waveform
    fprintf('Tx waveform generation done.')
    fprintf('\nBegin Transmission of Tx waveform...');
    FlagTxSuccess = TransmitWaveform( txWaveform, phyPara.TxSinkPara);           % Transmit waveform
    fprintf('Tx waveform transmission done.\n')
end

%% Rx
if phyPara.FlagRxEnable
    fprintf('\nReception of Rx waveform...');
    switch phyPara.RxSourcePara.Mode
        case 'Simulation'
            rxWaveform = ChannelSim(txWaveform, phyPara.ChannelPara);       % Channel
        case 'MatlabBasebandFile'
            rxWaveform = GetRxWaveform(phyPara);
        case 'SDR.LimeSDR'
            rxWaveform = GetRxWaveform(phyPara);
    end
    fprintf('\nReception of Rx waveform done.');
    fprintf('\nBegin Rx waveform demodulation and analyzation...\n');
    [recPPDU, recPSDU, rxEVM] = Receiver(rxWaveform, phyPara.RxPhyPara);
    if strcmp(phyPara.RxSourcePara.Mode, 'Simulation')
        packetError = any(biterr(txPSDU,recPSDU))
    end
    fprintf('Rx waveform demodulation and analyzation done.\n');
end

return
