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



function MU_funcModify(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

MU_enable('off',[],handles);
Seg_h=impoly;

fcn=makeConstrainToRectFcn('impoly',[0.5 handles.V.DimSize(2)+0.4],[0.5 handles.V.DimSize(1)+0.4]);
setPositionConstraintFcn(Seg_h,fcn);

wait(Seg_h);
if ~isvalid(Seg_h) % detect when main display is deleted
    return;
end
MU_enable('on',[],handles);
BW=createMask(Seg_h);

Input = inputdlg('Please input a filling value.','Input Value',1,{num2str(0)});
if isempty(Input)
    warndlg('Matrix value modification was cancelled.');
    return;
end

try
    handles.BMatrix(BW~=0)=str2num(Input{1});
    % replace process
    if numel(handles.V.DimSize) <3
        handles.TMatrix=handles.BMatrix;
    else
        eval(['handles.TMatrix(:,:' num2str(handles.V.DimPointer(3:end),',%d') ') = handles.BMatrix;']); % background matrix
    end
    
    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
catch me
    errordlg('The input value is invalid.');
    return;
end

guidata(handles.MU_matrix_display, handles);

end