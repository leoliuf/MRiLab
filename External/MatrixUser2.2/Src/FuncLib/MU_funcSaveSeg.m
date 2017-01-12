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



function MU_funcSaveSeg(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

[filename,pathname]=uiputfile({'*.mat','MAT-files (*.mat)'},'Save segmentation','Untitiled.mat');
if filename==0
    return;
end
Segs=handles.V.Segs;
Mask=handles.Mask;
save([pathname filename],'Segs','Mask');

end