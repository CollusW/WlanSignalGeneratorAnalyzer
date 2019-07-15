function ShowConfiguration(RxSourcePara)
% /*!
%  *  @brief     This function is used to print Rx configuration.
%  *  @details
%  *  @param[in] RxSourcePara,  struct. configuration message of Rx.
%  *  @pre       two waveform must have the same navigation message.
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date      2016.12.12
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0 Zhaonian Wang}
%  */
fprintf('Rx Source settings:\n')
fprintf('\tRx source type: %s\n', RxSourcePara.Mode);
fprintf('\tCenter frequency: %f MHz\n', RxSourcePara.CenterFreq/1e6);
fprintf('\tSample Rate: %f MSPS\n', RxSourcePara.SampleRate/1e6);
fprintf('\tIQ sample Duration: %f ms\n', RxSourcePara.Duration/1e-3);
if isfield(RxSourcePara,'Attenuation')
    fprintf('\tAttenuation: %f dB\n', RxSourcePara.Attenuation);
end

return