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



% Save Manual Segmented ROI
function MU_saveManSegROI(Temp,Event,h)

global Matrices;
global Matrix_names;
global Main_figure_handles;

Matrices.(get(h.Mask_name,'String'))= h.main_h.Mask;
Matrix_names=fieldnames(Matrices);
set(Main_figure_handles.Matrix_list,'String',Matrix_names);

delete(h.Manual_Seg);


end