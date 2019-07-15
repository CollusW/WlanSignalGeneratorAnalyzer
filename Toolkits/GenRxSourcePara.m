function RxSourcePara = GenRxSourcePara(RxSource,RxPara)
% Description: generate TxSinkPara structure from the input Tx sink mode.
% Input:
%   RxSource, string, Rx source mode,  valide value = {'SpectrumAnalyzer', 'USRP', 'File', 'Simulation'}
%       'SpectrumAnalyzer': receive waveform from Spectrum Analyzer.
%       'USRP': receive waveform from USRP device.
%       'File': receive waveform from File.
%       'Simulation': simulation of channel and obtain rx waveform.
% Output:
%   RxSourcePara, struct, used in rx source process. include the following field:
%       'SpectrumAnalyzer' mode:
%           Mode, string, Tx sink mode. value 'SpectrumAnalyzer';
%           IP, IP string, e.g. '192.168.10.200'
%           SampleRate: 1x1 scaler, double, Sample rate in Hz
%           CenterFreq: 1x1 scaler, double, Center frequency in Hz
%           Duration: 1x1 scaler, double, Duration in second
%       'USRP' mode:
%       'File' mode:
%       'Simulation' mode:
% Revision:
%   2016.09.29. V1.0 Collus Wang. first draft.
%	2017.02.07. V1.1 Collus Wang. add 'File' case.
%	2017.08.09. V2.0 Collus Wang. add 'USRP' case.
%	2017.08.17. V2.1 Collus Wang. partially add 'USRP' N210 case.
%	2017.08.17. V2.1 Zhaonian Wang. fulfill 'USRP' N210 case.
%	2017.08.17. V2.2 Collus Wang. default usrp device to B210 and serial number is not specified here.

RxSourcePara = [];

switch RxSource
    case 'SpectrumAnalyzer'
        RxSourcePara.Mode = 'SpectrumAnalyzer';
        RxSourcePara.IP = '192.168.2.40';            % IP string
        RxSourcePara.CenterFreq  = 1575.42e6;            % Hz
        RxSourcePara.SampleRate = RxPara.SampleRate;  % SPS
        RxSourcePara.Duration = 16*20e-3;                 % second
        RxSourcePara.Attenuation = 0;                 % rx attenuation in dB, ATT range = [0:2:70]
    case 'USRP'
        RxSourcePara.Mode = 'USRP';
        RxSourcePara.Duration = 1e-3;                 % second
        RxSourcePara.SampleRate = RxPara.SampleRate;  % SPS
        [v, ~] = version;
        RxSourcePara.Platform = 'B210';     % {'B210', 'N200/N210/USRP2'}
        switch RxSourcePara.Platform
            case 'B210'
                if contains(v, 'R2017a', 'IgnoreCase',true)
                    RxSourcePara.ChannelMapping = 1;            % [1 2] for MIMO  1: ver  2: wide band
                    RxSourcePara.CenterFreq = 2412e6+(6-1)*5e6;   % Hz
                    RxSourcePara.LocalOscillatorOffset = 0e6;    % Hz
                    RxSourcePara.Gain = 60;                         % 0:1:76
                    RxSourcePara.ClockSource = 'Internal';
                    RxSourcePara.DecimationFactor = 1;
                    % Decimation
                    % From 1 to 3; used for B-series and X-series only
                    % 4 to 128;
                    % 128 to 256 (values in this range must be even);
                    % 256 to 512 (values in this range must be evenly divisible by 4)
                    RxSourcePara.TransportDataType = 'int16';
                    RxSourcePara.OutputDataType  = 'Same as transport data type';
                    RxSourcePara.SamplesPerFrame = 362;   % Number of samples per frame of the output signal that the object generates, specified as a positive integer scalar. The default value is 362. This value optimally utilizes the underlying Ethernet packets, which have a size of 1500 8-bit bytes.
                    RxSourcePara.EnableBurstMode = true;
                    RxSourcePara.MasterClockRate = RxPara.SampleRate*RxSourcePara.DecimationFactor;
                    % ADC/DAC sample rate
                    % B200 and B210: Between 5e6 and 56e6.
                    % When using B210 with multiple channels, the clock rate must be no higher
                    % than 30.72 MHz
                end
                RxSourcePara.NumFramesInBurst = ceil(RxSourcePara.Duration*RxPara.SampleRate/RxSourcePara.SamplesPerFrame);
                RxSourcePara.Duration = RxSourcePara.NumFramesInBurst * RxSourcePara.SamplesPerFrame/RxPara.SampleRate;
                RxSourcePara.NumSample = RxSourcePara.NumFramesInBurst * RxSourcePara.SamplesPerFrame;  % should be less than 256M samples (1GB): 256M*2IQ*16bit/8bit
                if RxSourcePara.NumSample>256e6
                    error('Not enough memory to capture');
                end
            case 'N200/N210/USRP2'
                if contains(v, 'R2017a', 'IgnoreCase',true)
                    RxSourcePara.ChannelMapping = 1;            % [1 2] for MIMO  1: ver  2: wide band
                    RxSourcePara.CenterFreq = 1575.42e6;   % Hz
                    RxSourcePara.LocalOscillatorOffset = 5e6;    % Hz
                    RxSourcePara.Gain = 30;        % 0:0.05:38
                    RxSourcePara.ClockSource = 'Internal';
                    RxSourcePara.DecimationFactor = 20;	% this result to a samplerate of 5MSPS.
                    % Decimation
                    % 4 to 128;
                    % 128 to 256 (values in this range must be even);
                    % 256 to 512 (values in this range must be evenly divisible by 4)
                    RxSourcePara.TransportDataType = 'int16';
                    RxSourcePara.OutputDataType  = 'Same as transport data type';
                    RxSourcePara.SamplesPerFrame = 362;   % Number of samples per frame of the output signal that the object generates, specified as a positive integer scalar. The default value is 362. This value optimally utilizes the underlying Ethernet packets, which have a size of 1500 8-bit bytes.
                    RxSourcePara.EnableBurstMode = true;
                    RxSourcePara.NumFramesInBurst = 100;
                    RxSourcePara.MasterClockRate = 1e+08; % When Platform is set to 'N200/N210/USRP2', the master clock rate is always 1e+08 Hz
                end
                RxSourcePara.NumFramesInBurst = ceil(RxSourcePara.Duration*RxPara.SampleRate/RxSourcePara.SamplesPerFrame);
                RxSourcePara.Duration = RxSourcePara.NumFramesInBurst * RxSourcePara.SamplesPerFrame/RxPara.SampleRate;
                RxSourcePara.NumSample = RxSourcePara.NumFramesInBurst * RxSourcePara.SamplesPerFrame;  % should be less than 256M samples (1GB): 256M*2IQ*16bit/8bit
                if RxSourcePara.NumSample>256e6
                    error('Not enough memory to capture');
                end     
        end
    case 'File'
        RxSourcePara.Mode = 'File';
        RxSourcePara.FileType = 'SignalTap';     % {'ModelSim', 'SignalTap'};
        switch RxSourcePara.FileType
            case 'ModelSim'
				RxSourcePara.FileName = {'RecordedFile/ModelSim_MCS0RB26_I.txt', 'RecordedFile/ModelSim_MCS0RB26_Q.txt'};   % {I_file, Q_file} for ModelSim File or {IQ_file for SignalTap File}
                RxSourcePara.OffsetLen = 68;    % number of sampling points to skip in the data.
                RxSourcePara.NumBits = 16;      % number of bits for I or Q. (including sign bit)
            case 'SignalTap'
        		RxSourcePara.FileName = {'./RecordedFile/SignalTap_MCS5.txt'};   % {I_file, Q_file} for ModelSim File or {IQ_file for SignalTap File}
                RxSourcePara.RowStart = 35;		% start row number
                RxSourcePara.RowEnd = 7000;		% end row number
                RxSourcePara.ColIphase = 19;	% I-path column number
                RxSourcePara.ColQphase = 20;	% Q-path column number
            otherwise
                error('Unsupported recorded file type.');
        end
        RxSourcePara.SampleRate = RxPara.SampleRate;  % SPS
        % Note : You also have to specify the SampleRate, MCS, and NumRB in simSystem.m to correctly display the TB BLER
        % information.
    case 'Simulation'
        RxSourcePara.Mode = 'Simulation';
    otherwise
        error('Unsupported Tx sink parameter.')
end
