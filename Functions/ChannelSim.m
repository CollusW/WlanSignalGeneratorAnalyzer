function [rxWaveform] = ChannelSim(txWaveform, chPara)
% /*!
%  *  @brief     This function is used to simulate the channel.
%  *  @details   
%  *  @param[out] rxWaveform, Mx1, rx waveform.
%  *  @param[in] txWaveform, Nx1, tx waveform.
%  *  @param[in] chPara, 1x1 struct. Channel parameters structure.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.08.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.23. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.09.08. Collus Wang,  FlagDebugPlot can be set from chPara }
%  */

FlagDebugPlot = true  && chPara.FlagDebugPlot;
FigureStartNum = 400;

% go through channel
if chPara.SwitchMultipath
    rxWaveformChannel = step(chPara.TgnChannel, txWaveform);
else
    rxWaveformChannel = txWaveform;
end

% add freq/phase offset
if chPara.SwitchFreqPhaseOffset
    rxWaveformChannelFreq = step(chPara.PhaseFreqOffset, rxWaveformChannel);
else
    rxWaveformChannelFreq = rxWaveformChannel;
end

% add AWGN
if chPara.SwitchAWGN
    rxWaveformChannelFreqAwgn = step(chPara.AwgnChannel, rxWaveformChannelFreq);
else
    rxWaveformChannelFreqAwgn = rxWaveformChannelFreq;
end

if FlagDebugPlot
    SampleRate = chPara.SampleRate;
    hSA = dsp.SpectrumAnalyzer(...
        'NumInputPorts', 4, ...
        'FrequencyOffset',0, ...
        'SpectrumType',  'Power density', ... % 'Power', 'Power density', or 'Spectrogram'.
        'SpectralAverages', 1, ...
        'PlotMaxHoldTrace', false, ...
        'Window',   'Rectangular', ... % 'Hann'
        'SampleRate',SampleRate, ...
        'ShowLegend', true,...
        'ChannelNames', {'Tx', 'Channel', 'Channel+FreqOffset', 'Channel+FreqOffset+Awgn'},...
        'YLimits', [-150, -20] ...
        );
    step(hSA,txWaveform,rxWaveformChannel,rxWaveformChannelFreq,rxWaveformChannelFreqAwgn );
end

rxWaveform = rxWaveformChannelFreqAwgn;

% if (FlagDebugPlot)  % signal before FreqPhaseOffset
%     hSpectrumAnalyzer = dsp.SpectrumAnalyzer(...
%         'FrequencyOffset',0, ...
%         'SpectrumType',  'Power density', ... % 'Power', 'Power density', or 'Spectrogram'.
%         'SpectralAverages', 1, ...
%         'PlotMaxHoldTrace', false, ...
%         'Window',   'Rectangular', ... % 'Hann'
%         'SampleRate',Fs ...
%         );
%     step(hSpectrumAnalyzer, waveformRx);
%     fprintf('signal rms before FreqPhaseOffset: %.2f\n', rms(waveformRx));
% end
% waveformRx = waveformRx.*exp(1j* (2*pi*freqOffset/Fs*(0:length(waveformRx)-1).'+phaseOffset) ); % add freq and phase offset
% if FlagDebugPlot % signal after FreqPhaseOffset
%     step(hSpectrumAnalyzer, waveformRx);
%     fprintf('signal rms after FreqPhaseOffset: %.2f\n', rms(waveformRx));
% end

%
% % Display the spectrum of the transmitted and received signals. The
% % received signal spectrum is affected by the channel
% spectrumAnalyzer  = dsp.SpectrumAnalyzer('SampleRate',Rs, ...
%             'ShowLegend',true, ...
%             'Window', 'Rectangular', ...
%             'SpectralAverages',10, ...
%             'YLimits',[-30 10], ...
%             'ChannelNames',{'Transmitted waveform','Received waveform'});
% spectrumAnalyzer([txWaveform rxWaveform]);