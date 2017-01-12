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



function MU_func3DSlicer(Temp,Event,handles)
global Figure_handles;
if isfield(Figure_handles,'MU_display2')
    if ishandle(Figure_handles.MU_display2)
        close(Figure_handles.MU_display2); % close slicer
    end
end
handles = guidata(handles.MU_matrix_display);

handles.Slicer=1;
handles.V.Localizer.Local_switch=1;
handles.SMatrix=permute(handles.TMatrix,[3 1 2]); % Sagittal Matrix
handles.CMatrix=permute(handles.TMatrix,[3 2 1]); % Coronal Matrix
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
MU_Matrix_Display_3Plane;
MU_display2_handles=guidata(Figure_handles.MU_display2);
MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
set(handles.MatrixCalc_pushbutton,'Enable','off'); % disable matrix calculation when slicer

guidata(handles.MU_matrix_display, handles);

end