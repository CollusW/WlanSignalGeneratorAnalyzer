function [bits, eqDataSym, varargout] = wlanHTDataRecover( ...
    rxHTData, chanEst, noiseVarEst, cfgHT, varargin)
%wlanHTDataRecover Recover information bits from HT-Data field signal
%
%   BITS = wlanHTDataRecover(RXHTDATA, CHANEST, NOISEVAREST, CFGHT)
%   recovers the information bits in the HT-Data field for a HT-Mixed
%   format transmission.
%
%   BITS is an int8 column vector of length 8*CFGHT.PSDULength containing
%   the recovered information bits.
%
%   RXHTDATA is the received time-domain HT-Data field signal. It is a
%   Ns-by-Nr matrix of real or complex values, where Ns represents the
%   number of time-domain samples in the HT-Data field and Nr represents
%   the number of receive antennas. Ns can be greater than the HT-Data
%   field length; in this case additional samples at the end of RXHTDATA
%   are not used.
%
%   CHANEST is the estimated channel at data and pilot subcarriers based on
%   the HT-LTF. It is a real or complex array of size Nst-by-Nsts-by-Nr,
%   where Nst represents the total number of occupied subcarriers.
%
%   NOISEVAREST is the noise variance estimate. It is a real, nonnegative
%   scalar.
% 
%   CFGHT is the format configuration object of type <a href="matlab:help('wlanHTConfig')">wlanHTConfig</a>, which
%   specifies the parameters for the HT-Mixed format.
%
%   BITS = wlanHTDataRecover(..., CFGREC) allows different algorithm
%   options for data recovery via the input CFGREC, which is a
%   <a href="matlab:help('wlanRecoveryConfig')">wlanRecoveryConfig</a> configuration object. When the CFGREC input is not 
%   specified, the default property values of the <a href="matlab:help('wlanRecoveryConfig')">wlanRecoveryConfig</a>  object
%   are adopted in the recovery.
%
%   [..., EQDATASYM, CPE] = wlanHTDataRecover(...) also returns the
%   equalized subcarriers and common phase error.
%
%   EQDATASYM is a complex Nsd-by-Nsym-by-Nss array containing the
%   equalized symbols at data carrying subcarriers. Nsd represents the
%   number of data subcarriers, Nsym represents the number of OFDM symbols
%   in the HT-Data field, and Nss represents the number of spatial streams.
%
%   CPE is a column vector of length Nsym containing the common phase error
%   between each received and expected OFDM symbol.
%   
%   Example:
%   %  Recover a HT-Data field signal through a SISO AWGN channel using 
%   %  ZF equalization.
%  
%     cfgHT = wlanHTConfig('PSDULength', 1024);     % HT format configuration
%     txBits = randi([0 1], 8*cfgHT.PSDULength, 1); % Payload bits
%     txHSig = wlanHTData(txBits, cfgHT);           % Generate HT-Data signal
% 
%     % Pass through an AWGN channel with noise variance of 1
%     rxHTSig = awgn(txHSig, 1, 1);
%
%     % Configure recovery object
%     cfgRec = wlanRecoveryConfig('EqualizationMethod', 'ZF'); 
%     % Recover payload bits 
%     rxBits = wlanHTDataRecover(rxHTSig, ones(56,1), 1, cfgHT, cfgRec);
%   
%     [numerr, ber] = biterr(rxBits, txBits);       % Compare bits
%     disp(ber)
%     
%   [..., EQDATASYM, CPE, EQPILOTSYM] = wlanHTDataRecover(...) also returns the
%   equalized subcarriers and common phase error, as well as the equalized pilot symbols.
%
%   See also wlanHTConfig, wlanRecoveryConfig, wlanHTData. 

%   Copyright 2015-2016 The MathWorks, Inc.
%  * @remark   { revision history: V1.0, 2017.09.02. Collus Wang,  copy from wlan system tool box }
%  * @remark   { revision history: V1.1, 2017.08.18. Collus Wang,  enable to output equalized pilot symbols }
%  * @remark   { revision history: V1.2, 2017.09.08. Collus Wang,  fix error of equalization of pilot symbols in 'None' phase tracking case }

%#codegen

narginchk(4,5);
nargoutchk(0,4);

% Calculate CPE if requested
if nargout>2
    calculateCPE = true;
else
    calculateCPE = false;
end

if nargout>3
    FlagEqPilotSym = true;
else
    FlagEqPilotSym = false;
end

% HT configuration input self-validation
validateattributes(cfgHT, {'wlanHTConfig'}, {'scalar'}, mfilename, ...
                   'HT-Mixed format configuration object');
s = validateConfig(cfgHT, 'MCS');

% Validate rxHTData
validateattributes(rxHTData,   {'double'}, {'2d','finite'}, ...
    'rxHTData', 'HT-Data field signal'); 
% Validate chanEst
validateattributes(chanEst, {'double'}, {'3d','finite'}, ...
    'chanEst', 'channel estimates'); 
% Validate noiseVarEst
validateattributes(noiseVarEst, {'double'}, ...
    {'real','scalar','nonnegative','finite'}, ...
    'noiseVarEst', 'noise variance estimate'); 

numSTS     = cfgHT.NumSpaceTimeStreams;
numRx      = size(rxHTData, 2);
mcsTable   = wlan.internal.getRateTable(cfgHT);
pNcbpssi   = mcsTable.NCBPS/mcsTable.Nss;
numDBPS    = mcsTable.NDBPS;
rate       = mcsTable.Rate;
numOFDMSym = s.NumDataSymbols;
numSS      = mcsTable.Nss;
STBC       = numSTS - numSS;
mSTBC      = 1 + (STBC~=0);

% If PSDU is empty there is no data to return
if cfgHT.PSDULength == 0
    bits     = zeros(0, 1, 'int8');
    eqDataSym  = zeros(mcsTable.NSD, 0, mcsTable.Nss);
    if calculateCPE==true
        varargout{1} = []; % CPE
    end
    return;
end

% Optional recovery configuration input validation
if nargin == 5
    validateattributes(varargin{1}, {'wlanRecoveryConfig'}, {'scalar'}, ...
        mfilename, 'recovery configuration object');

    symOffset = varargin{1}.OFDMSymbolOffset;
    pilotPhaseTracking = varargin{1}.PilotPhaseTracking; 
    eqMethod = varargin{1}.EqualizationMethod;
    maxLDPCIterationCount = varargin{1}.MaximumLDPCIterationCount;
    earlyTermination = varargin{1}.EarlyTermination;
else % use defaults
    symOffset = 0.75;
    pilotPhaseTracking = 'PreEQ';
    eqMethod = 'MMSE'; 
    maxLDPCIterationCount = 12;
    earlyTermination = false;
end

% Get OFDM related parameters
[cfgOFDM,dataInd,pilotInd] = wlan.internal.wlanGetOFDMConfig( ...
    cfgHT.ChannelBandwidth, cfgHT.GuardInterval, 'HT', numSTS);

% Cross validate input
numST = numel([dataInd; pilotInd]); % Total number of occupied subcarriers
coder.internal.errorIf(size(chanEst, 1) ~= numST, ...
    'wlan:wlanHTDataRecover:InvalidHTChanEst1D', numST);
coder.internal.errorIf(size(chanEst, 2) ~= numSTS, ...
    'wlan:wlanHTDataRecover:InvalidHTChanEst2D', numSTS);
coder.internal.errorIf(size(chanEst, 3) ~= numRx, ...
    'wlan:wlanHTDataRecover:InvalidHTChanEst3D');

% Extract data and pilot subcarriers from channel estimate
chanEstData = chanEst(dataInd,:,:);
chanEstPilots = chanEst(pilotInd,:,:);

% Cross-validation between inputs
minInputLen = numOFDMSym*(cfgOFDM.FFTLength+cfgOFDM.CyclicPrefixLength);
coder.internal.errorIf(size(rxHTData, 1) < minInputLen, ...
    'wlan:wlanHTDataRecover:ShortHTDataInput', minInputLen);

% Processing for all streams/numRx
% OFDM demodulation
[ofdmDemodData, ofdmDemodPilots] = wlan.internal.wlanOFDMDemodulate(...
    rxHTData(1:minInputLen, :), cfgOFDM, symOffset);

if calculateCPE==true || strcmp(pilotPhaseTracking, 'PreEQ')
    % Get reference pilots, from IEEE Std 802.11-2012, Eqn 20-58/59
    % For HT-MF, offset by 3 to allow for L-SIG and HT-SIG pilot symbols
    z = 3; 
    refPilots = wlan.internal.htPilots(numOFDMSym, z, ...
        cfgHT.ChannelBandwidth, numSTS);
    
    % Estimate CPE and phase correct symbols
    cpe = wlan.internal.commonPhaseErrorEstimate(ofdmDemodPilots, ...
        chanEstPilots, refPilots);
    if strcmp(pilotPhaseTracking, 'PreEQ')
        ofdmDemodData = wlan.internal.commonPhaseErrorCorrect(ofdmDemodData, cpe);
    end
    if FlagEqPilotSym
        ofdmDemodPilot = wlan.internal.commonPhaseErrorCorrect(ofdmDemodPilots, cpe);
    end
    if calculateCPE==true
        varargout{1} = cpe.'; % Permute to Nsym-by-1
    end
end

% Equalization
if mcsTable.Nss < numSTS
    [eqDataSym, csiData] = wlan.internal.wlanSTBCCombine(ofdmDemodData, ...
        chanEstData, mcsTable.Nss, eqMethod, noiseVarEst);
else    
    [eqDataSym, csiData] = wlan.internal.wlanEqualize(ofdmDemodData, ...
        chanEstData, eqMethod, noiseVarEst);
end
if FlagEqPilotSym
    eqPilotSym = wlan.internal.wlanEqualize(ofdmDemodPilot, ...
        chanEstPilots, eqMethod, noiseVarEst);
    varargout{2} = eqPilotSym;
end

% LLR Demodulation: per Nss, account for nVar
qamDemodOut = wlan.internal.wlanConstellationDemodulate(eqDataSym, ...
    mcsTable.NBPSCS, noiseVarEst);
%   Apply bit-wise CSI
qamDemodOut = bsxfun(@times, ...
    reshape(qamDemodOut, mcsTable.NBPSCS, [], numOFDMSym, mcsTable.Nss), ...
    reshape(csiData, 1, [], 1, mcsTable.Nss)); % [Nbpscs Nsd Nsym Nss]

% Deinterleave per OFDM symbol
deintlvrOut = zeros(pNcbpssi*numOFDMSym, mcsTable.Nss);

if strcmp(cfgHT.ChannelCoding,'BCC')
    for symIdx = 1:numOFDMSym 
        deintlvrOut((symIdx-1)*pNcbpssi+(1:pNcbpssi), :) = ...
            wlan.internal.wlanBCCDeinterleave( ...
            reshape(qamDemodOut(:,:,symIdx,:), [], mcsTable.Nss), ...
            'HT', pNcbpssi, mcsTable.NBPSCS, 20*cfgOFDM.FFTLength/64, mcsTable.Nss);
    end
else
      % Deinterleaving is not required for LDPC
      deintlvrOut = reshape(real(qamDemodOut), [], numSS);
end

% Stream deparsing
streamDeparserOut = wlan.internal.wlanStreamDeparser(deintlvrOut, ...
    mcsTable.NES, mcsTable.NCBPS, mcsTable.NBPSCS);

% Channel decoding
if strcmp(cfgHT.ChannelCoding,'BCC')
    % BCC Channel decoding per Nes
    htDataBits = zeros(round(size(streamDeparserOut, 1)*mcsTable.Rate), ...
                   mcsTable.NES, 'int8');
    for nesIdx = 1:mcsTable.NES 
        htDataBits(:, nesIdx) = wlan.internal.wlanBCCDecode( ...
            streamDeparserOut(:, nesIdx), mcsTable.Rate);
    end
    descramMat = htDataBits.';
    descramIn = descramMat(:);
else
    % LDPC Channel decoding
    numPLD = cfgHT.PSDULength*8 + 16; % Number of payload bits
    % LDPC decoding parameters, IEEE Std 802.11-2012, Section
    % 20.3.11.17.5. 
    cfg = wlan.internal.getLDPCparameters(numDBPS, rate, mSTBC, numPLD);
    descramIn = wlan.internal.wlanLDPCDecode(streamDeparserOut(:), cfg, ...
                maxLDPCIterationCount, earlyTermination);
end

% Combine bits from multiple decoders, descramble with derived initial state
preDescramBits = descramIn(1:7,1); % Extract the first 7 scrambler init bits

scramInit = mod([sum(preDescramBits([1 3 4 7])); ...
                preDescramBits(2:4) + preDescramBits(1:3) + ...
                preDescramBits(5:7); preDescramBits(1:3) + preDescramBits(5:7)], 2);

% Remove the padded and tail bits to output only the data bits
descramOutData = wlan.internal.wlanScramble( ...
    descramIn(1:(16+8*cfgHT.PSDULength),:), scramInit);

% Remove the 16 service bits
bits = descramOutData(17:end);   

end