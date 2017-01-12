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



function MU_funcAxis(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);


AType={'on','off','auto','manual','tight','fill','ij','xy','equal','image','square','vis3d','normal'};
[Type,ok] = listdlg('ListString',AType, ...
                         'SelectionMode','single',...
                         'PromptString','Axis Appearance',... 
                         'Name','Axis');
if ok==0
    warndlg('Changing axis is cancelled.');
    return;
end
handles.V.Axis=AType(Type);

handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(handles.MU_matrix_display, handles);

end