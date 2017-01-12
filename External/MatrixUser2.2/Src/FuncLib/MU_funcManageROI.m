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



function MU_funcManageROI(Temp,Event,handles)
global Figure_handles;
MU_main_handles=guidata(Figure_handles.MU_main);
handles=guidata(Figure_handles.MU_display);

if ~isempty(MU_main_handles.V.ROIs)
    MU_ROI_Manage(handles);
else
    warndlg('No ROI exists.');
end

end