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



function MU_funcFreeSeg(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

handles.V.Color_map='Gray';
set(handles.Color_map_popmenu,'Value',1);
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
MU_enable('off',[],handles);
Seg_h=imfreehand;
wait(Seg_h);
if ~isvalid(Seg_h) % detect when main display is deleted
    return;
end
handles.V.Segs{end+1,1}='impoly';
handles.V.Segs{end,2}=handles.V.Slice;
handles.V.Segs{end,3}=1;
handles.V.Segs{end,4}=getPosition(Seg_h);
MU_enable('on',{'Color_map_popmenu'},handles);
BW=createMask(Seg_h);
Temp=handles.Mask;
Temp2=Temp(:,:,handles.V.Slice);
Temp2(BW~=0)=1;
Temp(:,:,handles.V.Slice)=Temp2;
handles.Mask=Temp;
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
handles.V.ROI=struct(...
                     'ROI_flag', 7,...
                     'ROI_mov',[],...  % ROI movement track
                     'ROI_Stat_h', [],...    
                     'ROI_h', Seg_h ...
                     );
guidata(handles.MU_matrix_display, handles);

end