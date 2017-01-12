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



function MU_funcImContrast(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

try
    imcontrast(handles.Matrix_display_axes);
    handles.Imcontrast = 1;
catch me
    error_msg{1,1}='ERROR!!! imcontrast is not working in this Matlab version.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end

guidata(handles.MU_matrix_display,handles);

end