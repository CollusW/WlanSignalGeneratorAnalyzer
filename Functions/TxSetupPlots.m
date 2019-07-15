function [hSF,hCon,hEVM] = TxSetupPlots(cfgWlan)
% /*!
%  *  @brief     This function is used to wlan tx plot setup.
%  *  @details   Create measurement tx plots.
%  *  @param[out] hSF, 1x1 figure handler for spectral flatness test.
%  *  @param[out] hCon,  1x1 constellation handller cell.
%  *  @param[out] hEVM, 1x1 EVM handler cell.
%  *  @param[in] cfgWlan,    1x1 wlan configration object.
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.26.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.26. Collus Wang,  first draft inherited from matlab 2017a helper fuction vhtTxSetupPlots.m}
%  * @remark   { revision history: V1.1, 2017.09.23. Collus Wang,  re-arrange figure layouts.}
%  */

% Scale and position plots on the screen
res = get(0,'ScreenSize');
if (res(3)>1280)
    xpos = fix(res(3)*[1/2 3/4 1/4 1/4]);
    ypos = fix(res(4)*[1/16 1/2]);
    xsize = xpos(2)-xpos(1)-20;
    ysize = fix(xsize*5/6);
    repositionPlots = true;
else
    repositionPlots = false;
end

% Spectral flatness diagram
hSF = figure; 
title('Spectral Flatness, Packet: 1');
grid('on');
hSF.Visible = 'Off';
if repositionPlots
    hSF.Position = [xpos(1) ypos(1) xsize ysize];
end

% Number of spatial streams
switch class(cfgWlan)
    case 'wlanHTConfig'
        numSS = cfgWlan.NumSpaceTimeStreams;
    case 'wlanVHTConfig'
        numSS = cfgWlan.NumSpaceTimeStreams/(double(cfgVHT.STBC)+1);
    otherwise
        error('Unsupported wlanConfiguration class.')
end


% Reference constellation symbols
refConst = helperReferenceSymbols(cfgWlan);

% Constellation diagram and EVM per subcarrier plot for each spatial stream
hCon = cell(numSS,1);
hEVM = cell(numSS,1);
for i = 1:numSS
    % Constellation diagram per spatial stream
    hCon{i} = comm.ConstellationDiagram;
    hCon{i}.ReferenceConstellation = refConst;
    hCon{i}.Title = 'Equalized Data Symbols, Packet:1, Spatial Stream:1';
    
    % EVM per subcarrier per spatial stream
    hEVM{i} = figure;
    title('RMS EVM, Packet:1, Spatial Stream:1');
    grid('on');
    hEVM{i}.Visible = 'Off';
    if repositionPlots
        hCon{i}.Position = [xpos(2) ypos(2) xsize ysize];
        hEVM{i}.Position = [xpos(3) ypos(1) xsize ysize];
    end
end

end

