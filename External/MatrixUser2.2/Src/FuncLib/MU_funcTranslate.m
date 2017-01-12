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



function MU_funcTranslate(Temp,Event,handles)
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

Input = inputdlg('Please input a translation vector [x,y,z].','Input Value',1,{'[1,1,0]'});
if isempty(Input)
    warndlg('Matrix translation was cancelled.');
    return;
end

try
    eval(['Vector=' Input{1} ';']);
    handles.TMatrix=circshift(handles.TMatrix,[round(Vector(2)) round(Vector(1)) round(Vector(3))]);
    handles.Mask=circshift(handles.Mask,round(Vector));
    MergeM=get(handles.Matrix_name_edit,'String');
    set(handles.Matrix_name_edit,'String',[MergeM '_trn']);
    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
catch me
    errordlg('The input translation vector is invalid.');
    return;
end

guidata(handles.MU_matrix_display, handles);

end