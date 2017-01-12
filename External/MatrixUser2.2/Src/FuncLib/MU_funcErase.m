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



function MU_funcErase(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

global Figure_handles;

handles.V.ROI=struct(...
                     'ROI_flag', 0,...
                     'ROI_mov',[],...
                     'ROI_Stat_h', [],...    
                     'ROI_h', [] ...
                     );
handles.Mask=zeros(size(handles.TMatrix),'int8');
handles.V2=struct(...   % image fusion
                'Foreground_matrix',[],...
                'F_lower',[],...
                'F_upper',[],...
                'Backgroud_F',[],...
                'Foregroud_F',[],...
                'Include0',[],...
                'Color_map',[],...
                'Color_bar',[]...
                );

handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
if handles.Slicer==1
    MU_display2_handles=guidata(Figure_handles.MU_display2);
    MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
end
guidata(handles.MU_matrix_display, handles);
MU_enable('on',[],handles);

end