function [ FlagSuccess ] = TransmitWaveform( TxWaveformIQ, TxSinkPara)
% /*!
%  *  @brief     This function is used to transmit the IQ waveform according to TxSinkPara settings.
%  *  @details   
%  *  @param[out] FlagSuccess. true = transmission success, otherwise false.
%  *  @param[in] TxWaveformIQ,  NxM, complex. N is number of IQ samples, M is the number of antennae.
%  *  @param[in] TxSinkPara,    1x1 struct, tx sink configuration parameters.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.18.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.18. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2018.01.25. Collus Wang,  optimization of code structure, incorparate all mode into this function. }
%  */


switch TxSinkPara.Mode
    case 'SignalGenerator'
        TxWaveformIQ = FillMinDuration(TxWaveformIQ, TxSinkPara);
        [ FlagSuccess ] = TransmitWaveformSG(TxWaveformIQ, TxSinkPara);
    case 'SDR.LimeSDR'
        TxWaveformIQ = FillMinDuration(TxWaveformIQ, TxSinkPara);
        TxWaveformIQ = 1*TxWaveformIQ/max(abs(TxWaveformIQ));   % Lime SDR accept range [-1,1];
        [ FlagSuccess ] = TransmitWaveformSDRLime(TxWaveformIQ, TxSinkPara);
    case 'Simulation'
        FlagSuccess = true;
    otherwise
        error('Unsupported Tx sink.');
end
end

function filledWaveform = FillMinDuration(TxWaveformIQ, TxSinkPara)
SampleRate = TxSinkPara.SampleRate;
MinDuration = TxSinkPara.MinDuration;
if size(TxWaveformIQ, 1) < MinDuration*SampleRate
    padZeros = zeros( round( MinDuration*SampleRate) - (size(TxWaveformIQ,1)), 1);
    filledWaveform = [TxWaveformIQ; padZeros];
end
end

function [ FlagSuccess ] = TransmitWaveformSDRLime(TxWaveformIQ, TxSinkPara)
TransmitTime = TxSinkPara.TransmitTime;
numLoop = ceil(TransmitTime / (size(TxWaveformIQ,1)/TxSinkPara.SampleRate));

%   (1) Open a device handle:
dev = limeSDR(); % Open device

%   (2) Setup device parameters. These may be changed while the device
%       is actively streaming.
dev.tx0.frequency  = TxSinkPara.CenterFreq;
dev.tx0.samplerate = TxSinkPara.SampleRate;      % when set to 40e6, 50e6, overflow may occur.
dev.tx0.gain = TxSinkPara.Gain;
dev.tx0.antenna = 1;

%   (3) Enable stream parameters. These may NOT be changed while the device
%       is streaming.
dev.tx0.enable;

%   (4) Start the module
dev.start();
pause(3)        % wait for LO and IQ path to setup.

%   (5) Receive 5000 samples on RX0 channel
for idxLoop = 1:numLoop
    dev.transmit(TxWaveformIQ);
end

%   (6) Cleanup and shutdown by stopping the RX stream and having MATLAB
%       delete the handle object.
dev.stop();
clear dev;
FlagSuccess = true;
end
        
function [ FlagSuccess ] = TransmitWaveformSG(TxWaveformIQ, TxSinkPara)
% TransmitWaveform:
% Input:
%   TxWaveformIQ: Nx1 is a colomn vector containing the complex waveform IQ to be
% sent by the signal generator.
%   TxSinkPara struct with member fields:
%       IP: IP string, e.g. '192.168.10.200'
%       SampleRate: 1x1 scaler, double, Sample rate in Hz
%       CenterFreq: 1x1 scaler, double, Center frequency in Hz
%       Amplitude: 1x1 scaler, double, amplitude in dBm
%       FileName: string. file name of the downloaded waveform
%       MinDuration: 1x1 scaler, double. minimum signal duration. pad some zeros so that SG transmit signals periodically. unit is second.
% Output:
%   FlagSuccess: success = true; fail = false;
% 2016-03-08, V1.0, Qi Yujun
% 2016-09-29, V1.01, Collus Wang, add Amplitude feature.
% 2017.04.27, V2.0, Collus Wang. change input argument to struct. add file name and min duration feature.
% 2017.05.03, V2.1, Collus Wang. ceil lenPadZeros so that it is an integer.

% extract the parameters
IP = TxSinkPara.IP;
SampleRate = TxSinkPara.SampleRate;
CenterFreq = TxSinkPara.CenterFreq;
Amplitude = TxSinkPara.Amplitude;
FileName = TxSinkPara.FileName;
MinDuration = TxSinkPara.MinDuration;

% start processing
FlagSuccess = false;
% Open a VISA connection or a raw TCPIP/GPIB connection to the instrument
% deviceObject = visa('agilent','TCPIP0::A-N5182A-80056.dhcp.mathworks.com::inst0::INSTR');
% deviceObject = gpib('agilent',8,19);
%     IP = input('please input instrument IP:','s');
%     IP = '192.168.0.38';
deviceObject = tcpip(IP,5025);

% Set up the output buffer size to hold at least the number of bytes we are
% transferring
deviceObject.OutputBufferSize = 900e6;

% Set output to Big Endian with TCPIP objects, because we do the interleaving
% and the byte ordering in code. For VISA or GPIB objecs, use littleEndian.
deviceObject.ByteOrder = 'bigEndian';

% Adjust the timeout to ensure the entire waveform is downloaded before a
% timeout occurs
deviceObject.Timeout = 600;

%Open the instrument
fopen(deviceObject);

% Some more commands to make sure we don't damage the instrument
fprintf(deviceObject,':OUTPut:STATe OFF');
fprintf(deviceObject,':SOURce:RADio:ARB:STATe OFF');
fprintf(deviceObject,':OUTPut:MODulation:STATe OFF');

% make sure IQ data is a Nx1 array.
[m,n] = size(TxWaveformIQ);
if n~=1 && m~=1
    error('IQData should be an Nx1 complex array ');
end
if 1 == m
    TxWaveformIQ = TxWaveformIQ.';
end
% pad some zeros so that SG transmit signals periodically.
lenPadZeros = ceil(MinDuration*SampleRate) - length(TxWaveformIQ);
if lenPadZeros > 0
    TxWaveformIQ = [TxWaveformIQ; zeros(lenPadZeros,1)];
elseif lenPadZeros < 0
    warning('Signal duration is longer than MinDuration setting.');
end

% Define a filename for the data in the ARB
ArbFileName = FileName;  

% Seperate out the real and imaginary data in the IQ Waveform
wave = [real(TxWaveformIQ),imag(TxWaveformIQ)].';
wave = wave(:)';    % transpose the waveform

% Scale the waveform
tmp = max(abs([max(wave) min(wave)]));
if (tmp == 0)
    tmp = 1;
end
% ARB binary range is 2's Compliment -32768 to + 32767
% So scale the waveform to +/- 32767 not 32768
scale = 2^15-1;
scale = scale/tmp;
wave = round(wave * scale);
modval = 2^16;
% Get it from double to unsigned int and let the driver take care of Big
% Endian to Little Endian for you  Look at ESG in Workspace.  It is a
% property of the VISA driver.
wave = uint16(mod(modval + wave, modval));

% Write the data to the instrument
n = size(wave);
fprintf('Starting Download of %d Points\n',n(2)/2);
binblockwrite(deviceObject,wave,'uint16',[':MEM:DATA:UNProtected "WFM1:' ArbFileName '",']);

% Write out the ASCII LF character
fprintf(deviceObject,'');

% Wait for instrument to complete download
% If you see a "Warning: A timeout occurred before the Terminator was reached."
% warning you will need to adjust the deviceObject.Timeout value until no
% warning results on execution
commandCompleted = query(deviceObject,'*OPC?');
commandCompleted = str2double(commandCompleted);

if commandCompleted == 1
    fprintf('ARB download success.\n')
else
    warning('ARB download with warning.\n')
end
% check if there is data error
status_description = query(deviceObject,'SYSTEM:ERROR?');
cdata = strcmpi(status_description,['+0,"No error"' char(10)]);

% set sample clock and check
if ( SampleRate > 0 ) && ( SampleRate <= 100e6 )
    fprintf(deviceObject, [':SOURce:RADio:ARB:CLOCk:SRATe ' num2str(SampleRate) ] );
else
    error('SampleRate should be less than 100*e6 ');
end
status_description = query(deviceObject,'SYSTEM:ERROR?');
csamp = strcmpi(status_description,['+0,"No error"' char(10)]);
if csamp ==0
    error('Error after setting ARB sample rate.')
end

% set the amplitude and check
if ~( (Amplitude > -130) && (Amplitude <15) )
    error('Amplitude should be between -130 and +15dBm.');
end
fprintf(deviceObject, ['POWer ', num2str(Amplitude)]);
status_description = query(deviceObject,'SYSTEM:ERROR?');
camp = strcmpi(status_description,['+0,"No error"' char(10)]);
if camp ==0
    error('Error after setting power.')
end

% Set the instrument source freq and check
if (CenterFreq > 6e9)
    error('CenterFreq should be less than 6GHz ');
end
fprintf(deviceObject, ['SOURce:FREQuency ' num2str(CenterFreq) ] );
status_description = query(deviceObject,'SYSTEM:ERROR?');
cfreq = strcmpi(status_description,['+0,"No error"' char(10)]);
if cfreq ==0
    error('Error after setting center frequency.')
end


% Some more commands to start playing back the signal on the instrument
fprintf(deviceObject,':SOURce:RADio:ARB:STATe ON');
fprintf(deviceObject,':OUTPut:MODulation:STATe ON');
fprintf(deviceObject,':OUTPut:STATe ON');
fprintf(deviceObject,[':SOURce:RADio:ARB:WAV "ARBI:' ArbFileName '"']);

% Close the connection to the instrument
fclose(deviceObject); delete(deviceObject); clear deviceObject
fprintf('ARB download and play. Success.\n')
FlagSuccess = true;

end
