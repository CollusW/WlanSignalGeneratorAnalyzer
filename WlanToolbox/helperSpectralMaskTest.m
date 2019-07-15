function isMaskPassing = helperSpectralMaskTest(x, fs, osr, varargin)
%helperSpectralMaskTest Featured example helper function
%   Plots the power spectral density (PSD) and overlays WLAN PSD limits to
%   check if spectral emissions are within specified levels.

%   Copyright 2015-2016 The MathWorks, Inc.
%  * @remark   { revision history: V1.0, 2017.09.23. Collus Wang,  copy from wlan system tool box }
%  * @remark   { revision history: V1.1, 2017.09.23. Collus Wang,  make spectrumAnalyzer so that its window remains even if this function exits. }

narginchk(3,6);
nargoutchk(0,1);
cbwMHz = fs/1e6;  % Channel bandwidth in MHz
rbw = 100e3;      % Resolution bandwidth
if nargin==5
    % Must be same size vectors
    dBrLimits = varargin{1};
    fLimits = varargin{2};
elseif nargin==6
    dBrLimits = varargin{1};
    fLimits = varargin{2};
    rbw = varargin{3}; % Resolution bandwidth for DMG 1 MHz
else % Default
    %  From IEEE Std 802.11ac-2013 Section 22.3.18.1
    dBrLimits = [-40 -40 -28 -20 0 0 -20 -28 -40 -40];
    fLimits = [-Inf -1.5*cbwMHz -cbwMHz -(cbwMHz/2+1) -(cbwMHz/2-1) ...
        (cbwMHz/2-1) (cbwMHz/2+1) cbwMHz 1.5*cbwMHz Inf];
end

vbw = 30e3;         % Video bandwidth
N = floor(rbw/vbw); % number of spectral averages
global spectrumAnalyzer
spectrumAnalyzer = cell(size(x,2),1); % Spectrum analyzer per antenna
for txIdx = 1:size(x,2)
    % Construct dsp.SpectrumAnalyzer and set SpectralMask property
    spectrumAnalyzer{txIdx} = dsp.SpectrumAnalyzer('SampleRate',fs*osr, ...
        'SpectrumType','Power density','PowerUnits','dBm', ...
        'SpectralAverages',N,'RBWSource','Property','RBW',rbw, ...
        'ReducePlotRate',false,'ShowLegend',true, ...
        'Name',sprintf('Spectrum Analyzer, Transmit Antenna %d',txIdx), ...
        'ChannelNames',{sprintf('Transmit Antenna %d',txIdx)});
    figureInfo = GetFigurePara('SpectrumMask');
    spectrumAnalyzer{txIdx}.Position = figureInfo.Position;
    spectrumAnalyzer{txIdx}.SpectralMask.EnabledMasks = 'Upper';
    spectrumAnalyzer{txIdx}.SpectralMask.ReferenceLevel = 'Spectrum peak';
    spectrumAnalyzer{txIdx}.SpectralMask.UpperMask = [fLimits*1e6; dBrLimits].'; % fLimits must be in Hz.
    
    % Get the number of segments to process
    setup(spectrumAnalyzer{txIdx},complex(x(1,1)));
    segLen = spectrumAnalyzer{txIdx}.getFramework.Visual.SpectrumObject.getInputSamplesPerUpdate(true);
    numSegments = floor(size(x,1)/segLen);
    
    % Process each segment and test the PSD against the mask
    for idx = 1:numSegments
        spectrumAnalyzer{txIdx}(x((idx-1)*segLen+(1:segLen),txIdx));
        maskStatus = getSpectralMaskStatus(spectrumAnalyzer{txIdx});
        isMaskPassing = maskStatus.IsCurrentlyPassing;
        if ~isMaskPassing
            disp('   Spectrum mask failed');
            releaseAnaylzers(spectrumAnalyzer);
            assignin('caller', 'spectrumAnalyzer', spectrumAnalyzer);
            return; % Do not update any more
        end
    end
end
disp('   Spectrum mask passed');
releaseAnaylzers(spectrumAnalyzer);
assignin('caller', 'spectrumAnalyzer', spectrumAnalyzer);
end

function releaseAnaylzers(spectrumAnalyzer)
    for i = 1:numel(spectrumAnalyzer)
        release(spectrumAnalyzer{i});
    end
end