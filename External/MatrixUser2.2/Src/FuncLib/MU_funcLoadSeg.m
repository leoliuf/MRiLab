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



function MU_funcLoadSeg(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

[filename,pathname]=uigetfile({'*.mat','MAT-files (*.mat)'},'MultiSelect','off');
if filename==0
    return;
end
load([pathname filename]);
try
    if ~isequal(size(handles.Mask),size(Mask))
        error('Segmentation mask has different matrix size.');
    end
    handles.V.Segs=Segs;
    handles.Mask=Mask;
    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
catch me
    error_msg{1,1}='ERROR!!! Loading segmentation fails.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end
guidata(handles.MU_matrix_display, handles);

end