% (1) Open a device handle:
dev = limeSDR(); % Open device

% (2) Setup device parameters. These may be changed while the device
%     is actively streaming.
dev.tx0.frequency  = 1000e6;    % when set to 2450e6, samples are real, not complex.
dev.tx0.samplerate = 40e6;      % when set to 40e6, 50e6, overflow may occur.
dev.tx0.gain = 40;
dev.tx0.antenna = 1;

% (3) Enable stream parameters. These may NOT be changed while the device
%     is streaming.
dev.tx0.enable;

% (4) Start the module
dev.start();
pause(3)

% (5) Receive samples on RX0 channel
SampleRate = dev.tx0.samplerate;  % in SPS
Duration = 1e-3;          % duration in sec
sourceFreq = 1e6;      % in Hz
sourceAmp = 0.8;        % amplitude [0,1);
sourceLen = round(Duration*SampleRate);
waveform = sourceAmp*exp(1j*2*pi*sourceFreq/SampleRate*(0:sourceLen-1)).';
plotWaveform(waveform, SampleRate);
for idxLoop = 1:round(30/Duration)
    dev.transmit(waveform);
end

%   (6) Cleanup and shutdown by stopping the RX stream and having MATLAB
%       delete the handle object.
dev.stop();
clear dev;

return

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
if rangePhaseDiff>30
    warning('Phase jump!'); 
end


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