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



% update current matrix according to dimension pointer

function MU_update_matrix(Temp,Event,handles,dimFlag)
handles = guidata(handles.MU_matrix_display);

if dimFlag ==3 % update current 2D matrix for display
    handles.V.Slice=str2double(get(handles.Dim3_edit,'String'));
    handles.V.DimPointer(3)=handles.V.Slice;
else % update current 3D matrix according to higher dimension pointer
    for i=4:2+numel(get(handles.MDimension_tabgroup,'Children')) 
        handles.V.DimPointer(i)=str2double(get(handles.(['Dim' num2str(i) '_edit']),'String'));
    end
    
    try
        handles.TMatrix = evalin('base', [handles.V.Current_matrix '(:,:,:' num2str(handles.V.DimPointer(4:end),',%d') ');']);
    catch me
        error_msg{1,1}='ERROR!!! Matrix update aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        return;
    end
end
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles);
guidata(handles.MU_matrix_display, handles);

end