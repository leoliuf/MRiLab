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



function MU_funcFlipV(Temp,Event,handles)
handles=guidata(handles.MU_matrix_display);

if ~isempty(handles.V.Segs)
    choice = questdlg('Segmentation mask is detected, transform operation will reset them, preceed?','Mask Reset', ...
                      'No, go save mask','Yes','No, go save mask');
    if isempty(choice)
        warndlg('Transform is cancelled.');
        return;
    end
    % Handle response
    switch choice
        case 'No, go save mask'
            warndlg('Save your mask before transform.');
            return;
    end
    
    handles.Mask=handles.Mask*0;
    handles.V.Segs=[];
end

% close 3D slicer
global Figure_handles
if isfield(Figure_handles,'MU_display2')
    slicer_display_handles=guidata(Figure_handles.MU_display2);
    if Figure_handles.MU_display == slicer_display_handles.Parent
        close(Figure_handles.MU_display2);
    end
end

handles.TMatrix=flipdim(handles.TMatrix,1);
handles.Mask=flipdim(handles.Mask,1);

MergeM=get(handles.Matrix_name_edit,'String');
set(handles.Matrix_name_edit,'String',[MergeM '_fpv']);

% update current display matrix
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(handles.MU_matrix_display, handles);

end