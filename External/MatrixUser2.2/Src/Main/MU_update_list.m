% MatrixUser, a multi-dimensional matrix analysis software package
% https://sourceforge.net/projects/matrixuser/
% 
% The MatrixUser is a matrix analysis software package developed under Matlab
% Graphical User Interface Developing Environment (GUIDE). It features 
% functions that are designed and optimized for working with multi-dimensional
% matrix under Matlab. These functions typically includes functions for 
% multi-dimensional matrix display, matrix (image stack) analysis and matrix 
% processing.
%
% Author:
%   Fang Liu <leoliuf@gmail.com>
%   University of Wisconsin-Madison
%   Aug-30-2014



function MU_update_list(handles)

matrixList = evalin('base', 'who');
if ~isempty(matrixList)
    contents=get(handles.Matrix_list,'String');
    if ischar(contents) % open MatrixUser main window
        currentFlag=0;
    else
        currentMatrix=contents{get(handles.Matrix_list,'Value')};
        currentFlag=strcmp(matrixList,currentMatrix);
    end
    if sum(currentFlag)==0
       set(handles.Matrix_list,'Value',1);
    else
       set(handles.Matrix_list,'Value',find(currentFlag==1));
    end
    set(handles.Matrix_list,'String',matrixList);
    set(handles.Matrix_display_button,'Enable','on');
    try %MRiLab
        set(handles.Array_show_button,'Enable','on');
    catch me
    end
else
    set(handles.Matrix_list,'Value',1);
    set(handles.Matrix_list,'String',{'Workspace is empty!'});
    set(handles.Matrix_display_button,'Enable','off');
    try %MRiLab
        set(handles.Array_show_button,'Enable','off');
    catch me
    end
end

end