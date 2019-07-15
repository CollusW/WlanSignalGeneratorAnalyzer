function waveformRx = ReceiveWaveformUsrp(RxSourcePara)
% /*!
%  *  @brief     This function is used to check if the rx calibration signal is valid.
%  *  @details   If noise power/total power > Threshold, signal is considered invalid.
%  *  @param[out] waveformRx. complex double, Nx1 vector. received waveform.
%  *  @param[in] RxSourcePara. 1x1 struct. structure that specifies the usrp settings.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.17.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.17. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.09.07. Collus Wang,  automatic find usrp device serial number }
%  */

FlagDebugPlot = ~false;
FigureStartNum = 400;

%% extract frequently used field.
SamplesPerFrame = RxSourcePara.SamplesPerFrame;
NumFramesInBurst = RxSourcePara.NumFramesInBurst;

%% find usrp
if ~exist('usrp', 'var')
    usrp = findsdru()
    if ~strcmp(usrp.Status, 'Success')
        error('USRP device is not ready!')
    end
    usrpDriverVersion = getSDRuDriverVersion()
end
%% usrp intialization
% if ~exist('hUsrpRx', 'var')
[v, ~] = version;
if contains(v, 'R2017a', 'IgnoreCase',true)
    switch RxSourcePara.Platform
        case 'B210'
            hUsrpRx = comm.SDRuReceiver(...
                'Platform',         RxSourcePara.Platform, ...
                'SerialNum',        usrp.SerialNum, ...
                'ChannelMapping',   RxSourcePara.ChannelMapping, ...
                'CenterFrequency',  RxSourcePara.CenterFreq, ...
                'LocalOscillatorOffset',   RxSourcePara.LocalOscillatorOffset, ...
                'Gain',                 RxSourcePara.Gain, ...
                'ClockSource',          RxSourcePara.ClockSource, ...
                'DecimationFactor',     RxSourcePara.DecimationFactor, ...
                'TransportDataType',    RxSourcePara.TransportDataType, ...
                'OutputDataType',       RxSourcePara.OutputDataType, ...
                'SamplesPerFrame',      RxSourcePara.SamplesPerFrame, ...
                'EnableBurstMode',      RxSourcePara.EnableBurstMode, ...
                'NumFramesInBurst',     RxSourcePara.NumFramesInBurst, ...
                'MasterClockRate',      RxSourcePara.MasterClockRate);
        case 'N200/N210/USRP2'
            hUsrpRx = comm.SDRuReceiver(...
                'Platform',         RxSourcePara.Platform, ...
                'ChannelMapping',   RxSourcePara.ChannelMapping, ...
                'CenterFrequency',  RxSourcePara.CenterFreq, ...
                'LocalOscillatorOffset',   RxSourcePara.LocalOscillatorOffset, ...
                'Gain',                 RxSourcePara.Gain, ...
                'ClockSource',          RxSourcePara.ClockSource, ...
                'DecimationFactor',     RxSourcePara.DecimationFactor, ...
                'TransportDataType',    RxSourcePara.TransportDataType, ...
                'OutputDataType',       RxSourcePara.OutputDataType, ...
                'SamplesPerFrame',      RxSourcePara.SamplesPerFrame, ...
                'EnableBurstMode',      RxSourcePara.EnableBurstMode, ...
                'NumFramesInBurst',     RxSourcePara.NumFramesInBurst, ...
                'MasterClockRate',      RxSourcePara.MasterClockRate);
    end
else
    error('Currently support MATLAB 2017a.');
end
% end

%% usrp receiving
fprintf('\nPress any key to begin receive...\n');%pause;
fprintf('Begin receive...')

% Keep accessing the SDRu System object output until it is valid
len = uint32(0);
waveformRx = coder.nullcopy(complex(  zeros(NumFramesInBurst*SamplesPerFrame, length(RxSourcePara.ChannelMapping))  ));
while len <= 0
    [~,len] = step(hUsrpRx);
end

for idx = 1:NumFramesInBurst
    [waveformRx((1:SamplesPerFrame)+(idx-1)*SamplesPerFrame, :), len, over] = step(hUsrpRx);
    if over && idx~=1
        disp(over);
    end
end
waveformRx = complex(double(waveformRx));
fprintf('Done.\n')

% N-serial have fixed master sample rate, it needs a rate-conversion step to expected sample rate. 
if  strcmp(RxSourcePara.Platform,'N200/N210/USRP2')
    fprintf('\nConverting sample rate for N210...')
    FSIN=RxSourcePara.MasterClockRate/RxSourcePara.DecimationFactor;
    FSOUT=RxSourcePara.SampleRate;
    TOL=0; NP=3;
    src = dsp.FarrowRateConverter(FSIN,FSOUT,TOL,NP);
    len=floor(length(waveformRx)/971)*971;
    waveformRx=step(src,waveformRx(1:len));
    fprintf('Done.\n')
end

if FlagDebugPlot
    SampleRate = RxSourcePara.SampleRate;
    lenThd = 5e6;
    if length(waveformRx)>lenThd
        waveformTest = waveformRx(1:lenThd);
    else
        waveformTest = waveformRx;
    end
    % plot received waveform here. Time/Freq. Domain.
    figure(FigureStartNum+0)
    clf
    subplot(3,2,[1,2])
    plot((0:length(waveformTest)-1)/SampleRate, real(waveformTest));
    xlabel('Time (s)')
    ylabel('Real')
    grid on
    title('Time Domain')
    subplot(3,2,[3,4])
    plot((0:length(waveformTest)-1)/SampleRate, imag(waveformTest));
    xlabel('Time (s)')
    ylabel('Imag')
    grid on
    subplot(3,2,5)
    plot(waveformTest);
    grid on
    axis equal
    subplot(3,2,6)
    plot(abs(waveformTest));
    xlabel('Time (s)')
    ylabel('Absolute')
    grid on
    
    figure(FigureStartNum+10); clf;
    plot((0:length(waveformTest)-1)/SampleRate, unwrap(angle(waveformTest)));
    xlabel('Time (s)')
    ylabel('Phase (rad)')
    title('Phase Domain')
    grid on
    
    figure(FigureStartNum+20); clf;
    plot((0:length(waveformTest)-1)*SampleRate/length(waveformTest)-SampleRate/2, mag2db(abs(fftshift(fft(waveformTest)))));
    xlim([-SampleRate/2*1.01, SampleRate/2*1.01]);
    xlabel('Freq. (Hz)')
    ylabel('Magnitude (db)')
    title('Freq. Domain')
    grid on
end
