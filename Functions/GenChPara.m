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
