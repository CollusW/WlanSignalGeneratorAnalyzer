% /*!
%  *  @brief     This script is used to capture the waveform from USRP.
%  *  @details   write waveform to Matlab baseband file for receiver tests.
%  *  @pre       .
%  *  @bug      Null
%  *  @warning  Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.11.22
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 2017.11.20. Collus Wang, first draft }
%  */

clear all
clc
close all
addpath('../Functions');   % add path which contains the local functions.
addpath('../WlanToolbox');   % add path which contains the revised wlan system toolbox functions.

%% system para.
RxPara.SampleRate = 20e6;
RxSourcePara = GenRxSourcePara('USRP',RxPara);   %{'SpectrumAnalyzer', 'USRP', 'File', 'Simulation'}
phyPara.TxSink.Type = 'MatlabBasebandFile';
phyPara.TxSink.FileName = '..\Results\waveformRxUSRP.bb'; % file name with path (reletive to main.m in the root folder).

%% print info.
ShowConfiguration(RxSourcePara);

%% receive
waveformRx = ReceiveWaveformUsrp(RxSourcePara);
timestampCapture =clock();	% record the time of waveform capture
fprintf('WaveformRx captured from USRP at: %d.%d.%d, %d:%d:%f\n', timestampCapture(1),timestampCapture(2),timestampCapture(3),timestampCapture(4),timestampCapture(5),timestampCapture(6));

%% write to file
switch phyPara.TxSink.Type
    case 'MatlabBasebandFile'
        basebandWriter = comm.BasebandFileWriter('Filename',phyPara.TxSink.FileName, ...
            'SampleRate', RxPara.SampleRate, ...
            'CenterFrequency', RxSourcePara.CenterFreq, ...
            'Metadata', struct('TimeStamp', timestampCapture), ...
            'NumSamplesToWrite', Inf);
        basebandWriter(waveformRx);
    otherwise
        error('Unsupported Tx sink type.')
end
