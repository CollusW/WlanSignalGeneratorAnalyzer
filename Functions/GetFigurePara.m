function figurePara = GetFigurePara(figureType)
% /*!
%  *  @brief     This function is used to generate figure information including: position.
%  *  @details   
%  *  @param[out] figurePara. 1x1 struct. 
%  *  @param[in] figureType,  string. specify figure type.
%  *  @pre       
%  *  @bug       Null
%  *  @warning   Null
%  *  @author    Collus Wang
%  *  @version   1.0
%  *  @date       2017.09.23.
%  *  @copyright Collus Wang all rights reserved.
%  * @remark   { revision history: V1.0, 2017.09.23. Collus Wang,  first draft }
%  */
res = get(0,'ScreenSize');
if (res(3)>1280)
    switch figureType
        case 'TimeDomain'
            xpos = 5;
            ypos = fix(res(4)/2)-20;
            xsize = fix(res(3)/2)-10;
            ysize = fix(res(4)/2)-50;
        case 'Constellation'
            xpos = 5;
            ypos = fix(res(4)/16);
            xsize = fix(res(3)/4)-20;
            ysize = fix(xsize*5/6);
        case 'SpectrumMask'
            xpos = fix(res(3)/2);
            ypos = fix(res(4)/2)-20;
            xsize = fix(res(3)/2)-10;
            ysize = fix(res(4)/2)-50;
        case 'DialogResult'
            xpos = fix(res(3)/4*3);
            ypos = fix(res(4)/16);
            xsize = fix(res(3)/4)-20;
            ysize = fix(xsize*5/6);
        otherwise
            error('Unsupported figure type.')
    end
    figurePara.repositionPlots = true;
    figurePara.Position = [xpos, ypos, xsize, ysize];
else
    figurePara.repositionPlots = false;
end
end

