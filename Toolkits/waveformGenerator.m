% /*!
%  *  @brief     This script is used to generate the waveform.
%  *  @details   write waveform to Matlab baseband file for receiver tests.
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.11.04
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 2017.11.04. Collus Wang, first draft }
%  */

clear all
clc
close all
addpath('../Functions');   % add path which contains the local functions.
addpath('../WlanToolbox');   % add path which contains the revised wlan system toolbox functions.

%% parameter generation
macPara = GenMacPara();     % Generate MAC parameter
phyPara = GenPhyPara();     % Generate PHY common parameter
txPara = GenTxPara(phyPara);        % Generate Tx parameter
chPara = GenChPara(phyPara);        % Generate Channel parameter
chPara.SwitchAWGN = true;                    % switch flag of AWGN.  true = add noise; false = not add noise.
chPara.SwitchMultipath =  true;              % switch flag of freq and phase offset. true = add freq and phase offset.
chPara.SwitchFreqPhaseOffset = true;        % switch flag of Multipath, true = add multipath channel, false = no multipath channel.
rxPara = GenRxPara(phyPara);        % Generate Rx parameter

phyPara.TxSink.Type = 'MatlabBasebandFile';
phyPara.TxSink.FileName = '..\Results\waveformRx.bb'; % file name with path (reletive to main.m in the root folder).

% Transmitter
[txWaveform, txPPDU, txPSDU] = GenTxWaveform(macPara, txPara);
% Channel
rxWaveform = ChannelSim(txWaveform, chPara);


switch phyPara.TxSink.Type
    case 'MatlabBasebandFile'
        basebandWriter = comm.BasebandFileWriter('Filename',phyPara.TxSink.FileName, ...
            'SampleRate', phyPara.MasterSampleRate, ...
            'CenterFrequency', phyPara.CenterFreq, ...
            'Metadata', struct(), ...
            'NumSamplesToWrite', Inf);
        basebandWriter(rxWaveform);
    otherwise
        error('Unsupported Tx sink type.')
end


return
