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



function MU_funcImTool(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);
try
    BMatrix=handles.BMatrix;
    imtool(BMatrix);
    colormap(handles.V.Color_map);
    set(gca,'Clim',[handles.V.C_lower handles.V.C_upper]);
catch me
    error_msg{1,1}='ERROR!!! imtool is not working in this Matlab version.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end

end