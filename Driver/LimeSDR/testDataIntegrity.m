% (1) Open a device handle:
dev = limeSDR(); % Open device

% (2) Setup device parameters. These may be changed while the device
%     is actively streaming.
dev.rx0.frequency  = 1000e6;    % when set to 2450e6, samples are real, not complex.
dev.rx0.samplerate = 40e6;      % when set to 40e6, 50e6, overflow may occur.
dev.rx0.gain = 60;
dev.rx0.antenna = 1;

% (3) Enable stream parameters. These may NOT be changed while the device
%     is streaming.
dev.rx0.enable;

% (4) Start the module
dev.start();

% (5) Receive samples on RX0 channel
Duration = 1e-3;    % in second.
numSample = ceil(Duration*dev.rx0.samplerate);
for idxLoop = 1:10
    samples = dev.receive(numSample,0);
%     samples(100) = [];    % manually make some overflow
    plotWaveform(samples, dev.rx0.samplerate)
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