function [ macPara] = GenMacPara()
% /*!
%  *  @brief     This function is used to generate MAC parameters.
%  *  @details   If noise power/total power > Threshold, signal is considered invalid. 
%  *  @param[out] macPara, 1x1 struct. MAC parameter structure.
%  *  @param[in] 
%  *  @pre       First initialize the system.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.08.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.08.23. Collus Wang,  first draft }
%  */

macPara = [];

% 
% SSID = 'TEST_BEACON'; % Network SSID
% beaconInterval = 100; % In Time units (TU)
% band = 5;             % Band, 5 or 2.4 GHz
% chNum = 52;           % Channel number, corresponds to 5260MHz
% 
% % Generate Beacon frame
% [mpduBits,fc] = helperGenerateBeaconFrame(chNum, band, beaconInterval, SSID);


end

