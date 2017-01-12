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




% link silder bar and edit for matrix dimension
% update current matrix according to dimension pointer

function MU_linkSliderEditDim(Temp,Event,active_handle,slider_handle,edit_handle,dimFlag)
handles = guidata(active_handle);

% sync silder bar and edit
switch get(active_handle,'Style')
    case 'slider'
        set(edit_handle,'String',num2str(round(get(slider_handle,'Value'))));
        set(slider_handle,'Value',round(get(slider_handle,'Value')));
    case 'edit'
        editValue = round(str2double(get(edit_handle,'String')));
        if editValue<=get(slider_handle,'Max') & editValue>=get(slider_handle,'Min')
            set(slider_handle,'Value',editValue);
            set(edit_handle,'String',editValue);
        else
            set(edit_handle,'String',num2str(round(get(slider_handle,'Value'))));
        end
end

% update current display matrix
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,dimFlag);
guidata(handles.MU_matrix_display, handles);


end