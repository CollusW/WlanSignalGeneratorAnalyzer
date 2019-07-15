function phyPara = GenPhyPara()
% /*!
%  *  @brief     This function is used to generate PHY parameters.
%  *  @details   including the Tx, Rx, TxSink, Rx source, and channel parameters.
%  *  @param[out] phyPara, 1x1 struct. PHY parameter structure.
%  *  @param[in] 
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.23. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.09.08. Collus Wang,  add FlagGlobalDebugPlot }
%  * @remark   { revision history: V1.2, 2017.10.06. Collus Wang,  add RxSouce field which specifies the rx source parameter. }
%  * @remark   { revision history: V1.3, 2018.01.25. Collus Wang,  Code structure optimization. }
%  */

%% Flags
phyPara.FlagGlobalDebugPlot = true;                    % false = close mudule debug plot information; true = debug plot information depends on each module.
phyPara.FlagTxEnable = true;						   % true = Enable TX part. false = disable TX part.
phyPara.FlagRxEnable = true;						   % true = Enable RX part. false = disable RX part.

%% Tx Parameters
if phyPara.FlagTxEnable
    %% TxPhyPara
    % User specified parameters
    phyPara.TxPhyPara.Mode = 'HT';                  % {'HT', 'VHT', 'Non-HT'}
    phyPara.TxPhyPara.MasterSampleRate = 40e6;      % Tx DAC/IQ waveform sample rate in SPS.
    phyPara.TxPhyPara.CenterFreq  = 2412e6;         % Carrier Frequency in Hz.
    switch lower(phyPara.TxPhyPara.Mode)
        case 'ht'
             phyPara.TxPhyPara.hWlanConfig = wlanHTConfig(...
                'ChannelBandwidth',   'CBW20', ...  'CBW20'(default) | 'CBW40'
                'NumTransmitAntennas', 1, ...       1 (default) | 2 | 3 | 4
                'NumSpaceTimeStreams', 1, ...       1 (default) | 2 | 3 | 4
                'NumExtensionStreams', 0, ...           0 (default) | 1 | 2 | 3
                'SpatialMapping', 'Direct', ... Spatial mapping scheme: 'Direct' (default) | 'Hadamard' | 'Fourier' | 'Custom'
                'SpatialMappingMatrix', 1, ... Spatial mapping matrix: 1 (default) | scalar | matrix | 3-D array
                'MCS', 5, ... Modulation and coding scheme: 0 (default) | integer from 0 to 31
                'GuardInterval', 'Long', ...Cyclic prefix length for the data field within a packet: 'Long' 800ns (default) | 'Short' 400ns
                'ChannelCoding', 'BCC', ... Type of forward error correction coding: 'BCC' (default) | 'LDPC'
                'PSDULength', 1024, ...Number of bytes carried in the user payload: 1024 (default) | integer from 0 to 65,535.  26*NumSym-3
                'AggregatedMPDU', false, ... MPDU aggregation indicator: false (default) | true
                'RecommendSmoothing', true ...Recommend smoothing for channel estimation: true (default) | false
                );
		case 'vht'
			error('Not implemented yet.')
		case 'non-ht'
			error('Not implemented yet.')
        otherwise
            error('Unsupported mode')
    end
    phyPara.TxPhyPara.IdleTime = 100e-6;    %  Idle time added after each packet, specified as a nonnegative scalar in seconds. If over-sampled, IdleTime should be turned on due to filter delays.
                                            %   If IdleTime is not set to the default value, it must be:
                                            %   ¡Ý 1e-06 seconds for DMG format
                                            %   ¡Ý 2e-06 seconds for VHT, HT-mixed, non-HT formats
    % Flags for debug plot and print
    phyPara.TxPhyPara.FlagDebugPlot = true && phyPara.FlagGlobalDebugPlot;   % false = close mudule debug plot information; true = debug plot information depends on each module.

    % Generated parameters. Should not be modified.
    phyPara.TxPhyPara.SampleRate = helperSampleRate(phyPara.TxPhyPara.hWlanConfig);     % Baseband nominal sampling rate in SPS
    phyPara.TxPhyPara.OverSampling =  phyPara.TxPhyPara.MasterSampleRate/phyPara.TxPhyPara.SampleRate;
    % Check parameters.
    if mod(phyPara.TxPhyPara.OverSampling,1)
        error('phyPara.TxPhyPara.MasterSampleRate should be multiple of phyPara.TxPhyPara.SampleRate.');
    end
    %% TxSinkPara
    phyPara.TxSinkPara.Mode = 'Simulation';             % generate Tx sink para. {'SignalGenerator', 'SDR.USRP', 'SDR.LimeSDR' 'File', 'Simulation'}
    phyPara.TxSinkPara.MinDuration = 0.3e-3;             % minimum signal period. if transmitted waveform is less than this value, pad some zeros so that signal is periodical. unit is second.
    switch phyPara.TxSinkPara.Mode
        case 'SignalGenerator'  % Signal Generator, tested with {'Agilent E4440A'}
            phyPara.TxSinkPara.CenterFreq = phyPara.TxPhyPara.CenterFreq;         % Singal Generator LO, in Hz
            phyPara.TxSinkPara.SampleRate = phyPara.TxPhyPara.MasterSampleRate;   % ARB Sample rate in SPS
            phyPara.TxSinkPara.IP = '192.168.2.38';                               % Signal Generator IP, string
            phyPara.TxSinkPara.Amplitude = -20;                                   % Output power in dBm
            phyPara.TxSinkPara.FileName = 'WLAN_MATLAB';                          % File name in Signal Generator RAM. {'WLAN_MATLAB'};
        case 'SDR.LimeSDR'      % SDR - LimeSDR with USB3 interface.
            phyPara.TxSinkPara.CenterFreq  = phyPara.TxPhyPara.CenterFreq;         % LO frequency in Hz. LimeSDR supports range {300e3~3.8e9}
            phyPara.TxSinkPara.SampleRate = phyPara.TxPhyPara.MasterSampleRate;    % IQ waveform sample rate in SPS
            phyPara.TxSinkPara.Gain = 70;                                          % Tx Gain
            phyPara.TxSinkPara.TransmitTime = 60;                                  % Transmission time, scaler double. IQ waveform is repeated until Transmission time is reached. Unit is second.
        case 'SDR.USRP'        % SDR - USRP
            error('not supported Tx sink parameter in this version.')
        case 'File'           % File - mat file or other format 
            error('not supported Tx sink parameter in this version.')
        case 'Simulation'     % Simulation 
            disp('');   % do nothing.
        otherwise
            error('Unsupported Tx sink parameter.')
    end
end

%% Rx Parameters
if phyPara.FlagRxEnable
    %% Rx Phy Para.
    phyPara.RxPhyPara.Mode = 'HT';                  % 802.11 mode {'Non-HT', 'HT', 'VHT'}
    phyPara.RxPhyPara.MasterSampleRate = 40e6;      % Rx ADC/IQ waveform sample rate in SPS.
    phyPara.RxPhyPara.CenterFreq  = 2412e6;         % Carrier Frequency in Hz.
    switch lower(phyPara.RxPhyPara.Mode)
        case 'ht'
            % receiver initial configuration.
            phyPara.RxPhyPara.hWlanConfig = wlanHTConfig(...
                'ChannelBandwidth',   'CBW20', ...  'CBW20'(default) | 'CBW40'
                'NumTransmitAntennas', 1, ...       1 (default) | 2 | 3 | 4
                'NumSpaceTimeStreams', 1, ...       1 (default) | 2 | 3 | 4
                'NumExtensionStreams', 0, ...           0 (default) | 1 | 2 | 3
                'SpatialMapping', 'Direct', ... Spatial mapping scheme: 'Direct' (default) | 'Hadamard' | 'Fourier' | 'Custom'
                'SpatialMappingMatrix', 1, ... Spatial mapping matrix: 1 (default) | scalar | matrix | 3-D array
                'MCS', 5, ... Modulation and coding scheme: 0 (default) | integer from 0 to 31
                'GuardInterval', 'Long', ...Cyclic prefix length for the data field within a packet: 'Long' 800ns (default) | 'Short' 400ns
                'ChannelCoding', 'BCC', ... Type of forward error correction coding: 'BCC' (default) | 'LDPC'
                'PSDULength', 1024, ...Number of bytes carried in the user payload: 1024 (default) | integer from 0 to 65,535
                'AggregatedMPDU', false, ... MPDU aggregation indicator: false (default) | true
                'RecommendSmoothing', true ...Recommend smoothing for channel estimation: true (default) | false
                );
            % L-SIG/H-SIG data recovery configuration parameter.
            phyPara.RxPhyPara.hCfgRecLSIG = wlanRecoveryConfig('EqualizationMethod','MMSE');   % MMSE  ZF
            % HT data recovery configuration parameter.
            phyPara.RxPhyPara.hCfgRecHTData = wlanRecoveryConfig('OFDMSymbolOffset', 0.75, ...
                'EqualizationMethod','MMSE', ...    % MMSE  ZF
                'PilotPhaseTracking', 'PreEQ', ...  % PreEQ  None
                'MaximumLDPCIterationCount', 12, ...
                'EarlyTermination', false ...
                );
		case 'vht'
			error('Not implemented yet.')
		case 'non-ht'
			error('Not implemented yet.')
        otherwise
            error('Unsupported mode')
    end
    % Flags for debug plot and print
    phyPara.RxPhyPara.FlagDebugPlot = true && phyPara.FlagGlobalDebugPlot;                    % false = close mudule debug plot information; true = debug plot information depends on each module.
    
    %% Rx Source Para.
    phyPara.RxSourcePara.Mode = 'Simulation';             % {'Simulation', 'MatlabBasebandFile', 'SDR.LimeSDR'}
    switch phyPara.RxSourcePara.Mode
        case 'Simulation'
%             phyChConfig.Mode = phyPara.RxPhyPara.Mode;
%             phyChConfig.MasterSampleRate = phyPara.RxPhyPara.SampleRate;
%             phyChConfig.CenterFreq = phyPara.RxPhyPara.CenterFreq;
            phyPara.ChannelPara = GenChPara(phyPara.RxPhyPara);        % Generate Channel parameter
        case 'MatlabBasebandFile'
            phyPara.RxSourcePara.Source.FileName = '.\Results\waveformRxUSRP.bb'; % file name with path (reletive to main.m in the root folder).
        case 'SDR.LimeSDR'
            phyPara.RxSourcePara.SampleRate = phyPara.RxPhyPara.MasterSampleRate;    % Tx or Rx sampler rate in SPS.
            phyPara.RxSourcePara.CenterFreq = phyPara.RxPhyPara.CenterFreq;        % Center frequency in Hz.
            phyPara.RxSourcePara.Duration = 0.6e-3;
            phyPara.RxSourcePara.Gain = 50;
        case 'SpectrumAnalyzer'
            error('Unsupported RX source type.')
        otherwise
            error('Unsupported RX source type.')
    end

end

end
       

function chPara = GenChPara(phyPara)
% /*!
%  *  @brief     This function is used to generate channel parameters.
%  *  @details   
%  *  @param[out] chPara, 1x1 struct. Channel parameter structure.
%  *  @param[in] phyPara, 1x1 struct. PHY common parameters structure.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2017.08.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.23. Collus Wang,  first draft }
%  * @remark   { revision history: V1.1, 2017.09.08. Collus Wang,  add FlagDebugPlot }
%  * @remark   { revision history: V1.2, 2017.09.08. Collus Wang,  set default frequency offset to random according to clock accuracy. Default phase offset is set to random. }
%  */

chPara = [];
Mode = phyPara.Mode;
MasterSampleRate = phyPara.MasterSampleRate;
CenterFreq = phyPara.CenterFreq;

chPara.SwitchAWGN = true;                    % switch flag of AWGN.  true = add noise; false = not add noise.
chPara.SwitchMultipath =  true;              % switch flag of freq and phase offset. true = add freq and phase offset.
chPara.SwitchFreqPhaseOffset = true;        % switch flag of Multipath, true = add multipath channel, false = no multipath channel.


chPara.SampleRate = phyPara.MasterSampleRate;

% Channel model
if chPara.SwitchMultipath
    switch lower(Mode)
        case 'ht' % TG-N channel
            TgnChannel = wlanTGnChannel;
            TgnChannel.SampleRate = MasterSampleRate;
            TgnChannel.DelayProfile = 'Model-B';
            TgnChannel.CarrierFrequency = CenterFreq;
            TgnChannel.NormalizePathGains = true;
            TgnChannel.NumTransmitAntennas = 1;
            if TgnChannel.NumTransmitAntennas>1
                TgnChannel.TransmitAntennaSpacing = 0.5;
            end
            TgnChannel.NumReceiveAntennas = 1;
            if TgnChannel.NumReceiveAntennas>1
                TgnChannel.ReceiveAntennaSpacing = 0.5;
                TgnChannel.NormalizeChannelOutputs = true;
            end
            TgnChannel.LargeScaleFadingEffect = 'None';       % Type of large-scale fading effects, specified as 'None', 'Pathloss', 'Shadowing', or 'Pathloss and shadowing'.
            TgnChannel.TransmitReceiveDistance = 10;
            if strcmp(TgnChannel.DelayProfile, 'Model-D') || strcmp(TgnChannel.DelayProfile, 'Model-E')
                TgnChannel.FluorescentEffect = true;
                TgnChannel.PowerLineFrequency = '50Hz';    %{'50Hz', '60Hz'}
            end
            TgnChannel.RandomStream = 'Global stream';     %   {'Global stream' or 'mt19937ar with seed'}
            if strcmp(TgnChannel.RandomStream, 'mt19937ar with seed')
                TgnChannel.Seed = 73;
            end
            TgnChannel.PathGainsOutputPort = false;
            chPara.TgnChannel = TgnChannel;
        otherwise
            error('Unsupported mode')
    end
end

% add noise
if chPara.SwitchAWGN
    AwgnChannel = comm.AWGNChannel;
    AwgnChannel.NoiseMethod = 'Signal to noise ratio (Eb/No)';
    if strcmp(AwgnChannel.NoiseMethod, 'Variance')
        AwgnChannel.VarianceSource = 'Property';        % {'Property' | 'Input port'}
    end
    AwgnChannel.EbNo = 30;
    % AwgnChannel.EsNo = 10;
    % AwgnChannel.SNR = 10;
    % AwgnChannel.BitsPerSymbol = 1;
    % AwgnChannel.SignalPower = 1;
    % AwgnChannel.SamplesPerSymbol = 1;
    % AwgnChannel.Variance = 1;
    % AwgnChannel.RandomStream = 'Global stream';   % {Global stream | mt19937ar}
    % AwgnChannel.Seed = 67;
    
    chPara.AwgnChannel = AwgnChannel;
end

if chPara.SwitchFreqPhaseOffset
    FreqAccuracyPpm = 20;               % frequency accuracy in ppm.
    FreqOffset = (rand*2-1)*FreqAccuracyPpm/1e6*phyPara.CenterFreq;   % frequency offset, in Hz. Valid only when SwitchFreqPhaseOffset = true.
    PhaseOffset = rand*360;          % phase offset, in degrees. Valid only when SwitchFreqPhaseOffset = true.

    PhaseFreqOffset = comm.PhaseFrequencyOffset('SampleRate',MasterSampleRate,'FrequencyOffset',FreqOffset, 'PhaseOffset', PhaseOffset);  % Create a phase and frequency offset object
    chPara.PhaseFreqOffset = PhaseFreqOffset;
end

% Flags for debug plot and print
chPara.FlagDebugPlot = ~true && phyPara.FlagGlobalDebugPlot;                    % false = close mudule debug plot information; true = debug plot information depends on each module.
end