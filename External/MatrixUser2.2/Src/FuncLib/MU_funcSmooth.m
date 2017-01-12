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



function MU_funcSmooth(Temp,Event,handles)
handles=guidata(handles.MU_matrix_display);

choice = questdlg('Apply to all slices?','All Slices','No','Yes','No');
if isempty(choice)
    warndlg('Image smoothing is cancelled.');
    return;
end
% Handle response
H =  fspecial('disk');
switch choice
    case 'No'
        handles.TMatrix(:,:,handles.V.Slice) = imfilter(handles.BMatrix,H,'replicate');
    case 'Yes'
        if length(handles.V.DimSize)>2
            for i= 1: handles.V.DimSize(3)
                handles.TMatrix(:,:,i) = imfilter(handles.TMatrix(:,:,i),H,'replicate');
                MU_update_waitbar(handles.Progress_axes,i,handles.V.DimSize(3));
            end
        else
            handles.TMatrix = imfilter(handles.BMatrix,H,'replicate');
        end
end

MergeM=get(handles.Matrix_name_edit,'String');
set(handles.Matrix_name_edit,'String',[MergeM '_smh']);

% update current display matrix
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(handles.MU_matrix_display, handles);

end