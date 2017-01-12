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



function MU_func3DReslice(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

MU_enable('off',[],handles);
ROI_h=imline;
wait(ROI_h);
if ~isvalid(ROI_h) % detect when main display is deleted
    return;
end
MU_enable('on',[],handles);

p=getPosition(ROI_h);

dp=p(2,:)-p(1,:);
dp2=[0,1];
theta = acos(dot(dp,dp2)./(norm(dp).*norm(dp2)))*180/pi;

if p(2,1) <= p(1,1)
    theta=-theta;
end

[Selection,ok] = listdlg('ListString',{'nearest','bilinear','bicubic'}, ...
                         'SelectionMode','single',...
                         'PromptString','Interpolation Methods',...
                         'Name','Interpolation');
pause(0.1);
if ok==0
    warndlg('Reslice is cancelled.');
    return;
end

switch Selection
    case 1
        method = 'nearest';
    case 2
        method = 'bilinear';
    case 3
        method = 'bicubic';
end

TMatrix=imrotate(handles.TMatrix(:,:,1),-theta,method,'loose');
[row,col]=size(TMatrix);
TTMatrix=zeros(row,col,handles.V.DimSize(3),class(TMatrix));
for i=1:handles.V.DimSize(3)
    TMatrix=imrotate(handles.TMatrix(:,:,i),-theta,method,'loose');
    TTMatrix(:,:,i)=TMatrix;
    MU_update_waitbar(handles.Progress_axes,i,handles.V.DimSize(3));
end

axes(handles.Matrix_display_axes);
TTMatrix=permute(TTMatrix,[3 2 1]);
MatrixName=get(handles.Matrix_name_edit,'String');

if ~MU_load_matrix([MatrixName '_rsl'], TTMatrix, 1)
    errordlg('3D reslice failed!');
end

guidata(handles.MU_matrix_display, handles);

end