function userCursorPosFcn(asObj, pos, plotDim)
% Entry function for user-defined cursor position callbacks.
% Use it to call your own cursor position dependent functions.
% A shortcut to edit this file is included to the context menu of the
% arrShow main window.
%
% This function is called from the asObj when pressing 'c', 'C'
% or when selecting the respective option via context menu.
%
% pos = [posY, posX] contains the current cursor position,
% plotDim is the "plot dimension" selected in the data selection panel
    try
        
          % put user cursor position functions here -------------
          
          
          
          
          
          
          
          
          
          
          
          

          % ---some examples:
%           disp(pos);          
          plotRow(asObj, pos);
%           plotAlongDim(asObj,pos,plotDim);                    
          
          % -----------------------------------------------------
          
                   
          
                   


    catch err
        disp(err);
        disp(err.message);
    end
end


