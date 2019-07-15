function TxEVMConstellationPlots(eqSym,subcarrierEVM, eqPilotSym, subcarrierPilotEVM, cfg,pktNum,hCon,hEVM)  
% /*!
%  *  @brief     This function is used to plot the EVM and constellation.
%  *  @details   Plots EVM per subcarrier and constellation.
%  *  @param[out] Null
%  *  @param[in] eqSym,  NxM complex, equalized data constellation symbols. N is the number of data subcarriers, M is the number of time symbols.
%  *  @param[in] eqPilotSym,  KxM complex, equalized pilot constellation symbols. K is the number of pilot subcarriers, M is the number of time symbols.
%  *  @param[in] subcarrierEVM,    Nx1 double, data EVM per subcarrier.
%  *  @param[in] subcarrierPilotEVM,    Kx1 double, pilot EVM per subcarrier.
%  *  @param[in] cfgWlan,    1x1 wlan configration object.
%  *  @param[in] pktNum,  1x1 integer, packet number.
%  *  @param[in] hCon,  1x1 constellation handller cell.
%  *  @param[in] hEVM, 1x1 figure handler for EVM plot.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.26.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.26. Collus Wang,  first draft inherited from matlab 2017a helper fuction vhtTxEVMConstellationPlots.m}
%  * @remark   { revision history: V1.0, 2017.09.02. Collus Wang,  add feature: plot pilot EVM}
%  */

switch class(cfg)
    case 'wlanHTConfig'
        validateattributes(cfg,{'wlanHTConfig'},{'scalar'},mfilename, ...
            'format configuration object');
    case 'wlanVHTConfig'
        % Function for VHT only
        validateattributes(cfg,{'wlanVHTConfig'},{'scalar'},mfilename, ...
            'format configuration object');
    otherwise
        error('Unsupported wlanConfiguration class.')
end

% Number of spatial streams
switch class(cfg)
    case 'wlanHTConfig'
        numSpatialStreams = cfg.NumSpaceTimeStreams;
        ofdmInfo = wlan.internal.wlanGetOFDMConfig(cfg.ChannelBandwidth,'Long', ...
            'HT',cfg.NumSpaceTimeStreams);
    case 'wlanVHTConfig'
        numSpatialStreams = cfg.NumSpaceTimeStreams/(double(cfg.STBC)+1);
        ofdmInfo = wlan.internal.wlanGetOFDMConfig(cfg.ChannelBandwidth,'Long', ...
            'VHT',cfg.NumSpaceTimeStreams);
    otherwise
        error('Unsupported wlanConfiguration class.')
end

for i = 1:numSpatialStreams
    % Plot equalized data symbols
    tmp = eqSym(:,:,i);
    hCon{i}(tmp(:))
    % Plot equalized pilot symbols. Bug: Do not display pilots because pilots cannot be drawn without release() which will flush the data symbols.
    %     tmp = eqPilotSym(:,:,i);
    %     release(hCon{i});
    %     hCon{i}(tmp(:))
    hCon{i}.Title = ['Equalized Data Symbols, Packet:' num2str(pktNum) ...
        ', Spatial Stream:' num2str(i)];

    % Plot EVM
    figure(hEVM{i});
    subplot(211);   % EVM in percentage
    hEVMAx = gca;
    % Get the previous upper YLimit and if the maximum EVM in the current
    % packet is greater then increase the limit
    prevLim = hEVMAx.YLim(2);
    currentLim = ceil(max(subcarrierEVM(:,:,i)));
    if currentLim>prevLim
        lim = [0 currentLim];
    else
        lim = [0 prevLim];
    end
    
    % Plot the RMS EVM across subcarriers
    plotInd = ofdmInfo.DataIndices-ofdmInfo.FFTLength/2-1;
    plot(hEVMAx,plotInd,subcarrierEVM(:,:,i),'bo'); hold on;
    plotInd = ofdmInfo.PilotIndices-ofdmInfo.FFTLength/2-1;
    plot(hEVMAx,plotInd,subcarrierPilotEVM(:,:,i),'go');
    ylim(hEVMAx,lim);
    title(hEVMAx,['RMS EVM, Packet:' num2str(pktNum) ...
        ', Spatial Stream:' num2str(i)]);
    ylabel(hEVMAx,'EVM (%)');
    xlabel(hEVMAx,'Subcarrier Index');
    grid(hEVMAx,'on');
    
    subplot(212);   % EVM in dB
    subcarrierEVMdB = 20*log10(subcarrierEVM/100);
    subcarrierPilotEVMdB = 20*log10(subcarrierPilotEVM/100);
    hEVMAx = gca;    
    % Get the previous upper YLimit and if the maximum EVM in the current
    % packet is greater then increase the limit
    prevLim = hEVMAx.YLim(2);
    currentLim = floor(min(subcarrierEVMdB(:,:,i))-1);
    if currentLim<prevLim
        lim = [currentLim 0];
    else
        lim = [prevLim 0];
    end
    
    % Plot the RMS EVM across subcarriers
    plotInd = ofdmInfo.DataIndices-ofdmInfo.FFTLength/2-1;
    plot(hEVMAx,plotInd,subcarrierEVMdB(:,:,i),'bo');hold on;
    plotInd = ofdmInfo.PilotIndices-ofdmInfo.FFTLength/2-1;
    plot(hEVMAx,plotInd,subcarrierPilotEVMdB(:,:,i),'go');
    ylim(hEVMAx,lim); legend('Data', 'Pilot', 'Location', 'best')
    ylabel(hEVMAx,'EVM (dB)');
    xlabel(hEVMAx,'Subcarrier Index');
    grid(hEVMAx,'on');
end
drawnow;
end