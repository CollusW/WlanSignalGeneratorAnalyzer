function rxWaveform = GetRxWaveform(phyPara)
% /*!
%  *  @brief     This function is used to get received waveform according to configurations.
%  *  @details   
%  *  @param[out] rxWaveform, nx1 complex. received waveform. n is the number of samples.
%  *  @param[in]  phyPara. configuration parameter struct.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.10.06.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.10.06. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2018.01.25. Collus Wang,  Support SDR.LimeSDR. }
%  */

FlagDebugPlot = false;

switch phyPara.RxSourcePara.Mode
    case 'MatlabBasebandFile'   % read from Matlab baseband signal file.
        fprintf('Rx waveform read from Matlab baseband signal file.\n');
        
        FileName = phyPara.Source.FileName;
        % Create an object to stream the data from the file
        basebandReader = comm.BasebandFileReader('Filename', FileName);
        basebandInfo = info(basebandReader);
        basebandReader.SamplesPerFrame = basebandInfo.NumSamplesInData; % read entire samples
        
        % The center frequency, sample rate and number of channels in the captured
        % waveform are provided by the comm.BasebandFileReader object.
        fprintf('\tCenter frequency = %.2f MHz\n', basebandReader.CenterFrequency/1e6);
        fprintf('\tSample rate = %.2f Msps\n', basebandReader.SampleRate/1e6);
        fprintf('\tNumber of receive antennas = %d\n', basebandReader.NumChannels);
        
        % check if read out parameters are consistent with current settings.
        if basebandReader.CenterFrequency ~= phyPara.CenterFreq
            error('Center frequency read from baseband file is not consitent with the specified frequency.')
        end
        if basebandReader.SampleRate ~= phyPara.MasterSampleRate
            error('Sample rate read from baseband file is not consitent with the specified sample rate.')
        end
        
        % load waveform
        rxWaveform = step(basebandReader);
    case 'SDR.LimeSDR'
        dev = limeSDR(); % Open device
        
        % Setup device parameters. These may be changed while the device is actively streaming.
        dev.rx0.frequency  = phyPara.RxSourcePara.CenterFreq;
        dev.rx0.samplerate = phyPara.RxSourcePara.SampleRate;      % when set to 40e6, 50e6, overflow may occur.
        dev.rx0.gain = phyPara.RxSourcePara.Gain;
        dev.rx0.bandwidth = 20e6;
        dev.rx0.antenna = 1;
        
        dev.rx0.enable;     % Enable stream parameters. These may NOT be changed while the device is streaming.
        dev.start();        % Start the module
%         pause(3)        % wait for LO and IQ path to setup.
        
        Duration = phyPara.RxSourcePara.Duration;    % in second.
        numSample = ceil(Duration*dev.rx0.samplerate);
        rxWaveform = dev.receive(numSample,0);
        if FlagDebugPlot
            plotWaveform(rxWaveform, dev.rx0.samplerate);
        end
        
        % Cleanup and shutdown by stopping the RX stream and having MATLAB delete the handle object.
        dev.stop();
        clear dev;        
    otherwise
        error('Unsupported RX source type.')
end
end

function [] = plotWaveform(waveform, SampleRate)
% time domain waveform
figure(1000)
subplot(211)
plot((0:length(waveform)-1), real(waveform));
xlabel('Time (point)')
ylabel('Real part')
title('Time Domain')
subplot(212)
plot((0:length(waveform)-1), imag(waveform));
xlabel('Time (point)')
ylabel('Image part')

% amplitude-phase domain
figure(1100)
subplot(311)
plot((0:length(waveform)-1), abs(waveform));
xlabel('Time (point)')
ylabel('Amplitude')
title('Amplitude-Phase Domain')
subplot(312)
phaseDegree = rad2deg(phase(waveform));
plot((0:length(waveform)-1), phaseDegree);
ylabel('Phase (degree)')
subplot(313)
phaseDiff = phaseDegree(2:end) - phaseDegree(1:end-1);
meanPhaseDiff = mean(phaseDiff);
stdPhaseDiff = std(phaseDiff);
rangePhaseDiff = max(phaseDiff)-min(phaseDiff);
plot((0:length(waveform)-2), phaseDiff);
xlabel('Time (point)')
str = sprintf('Mean=%.1f, STD=%.2f, Range=%.1f degree',meanPhaseDiff, stdPhaseDiff, rangePhaseDiff);
title(str)
ylabel('Phase difference (degree)')

% constellation
figure(1200)
plot(complex(waveform));
xlabel('I-phase')
ylabel('Q-phase')
title('Constellation')

% freq domain waveform
figure(1300)
NumSample = length(waveform);
FullScale = 1;
plot((0:NumSample-1)*SampleRate/NumSample, mag2db(abs((fft(waveform/NumSample/FullScale)))) )
xlabel('Freq (Hz)')
ylabel('Amplitude (dBFS)')
title('Freq Domain')
end
