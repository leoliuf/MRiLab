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



function MU_funcMask(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

threshold = inputdlg({'Please input a threshold value. The matrix value above threshold turns into 1, below threahold turns into 0.'},'Threshold Value',1,{num2str(0)});
if isempty(threshold)
    warndlg('Making mask was cancelled.');
    return;
end

dim = inputdlg(['Please specify up to which dimension to make mask (2 ~ ' num2str(numel(handles.V.DimSize)) ').'],'Specify Dimension',1,{num2str(numel(handles.V.DimSize))});
if isempty(dim)
    warndlg('Making mask was cancelled.');
    return;
end

try
    if str2double(dim{1}) == 2
        TMatrix=handles.TMatrix(:,:,handles.V.Slice);
    else
        if str2double(dim{1})+1>numel(handles.V.DimSize)
            dimFlag =[];
        else
            dimFlag=num2str(handles.V.DimPointer(str2double(dim{1})+1:end),',%u');
        end
        eval(['TMatrix=handles.TMatrix(:,:' repmat(',:', [1 str2double(dim{1})-2]) dimFlag ');']);
    end
    TTMatrix=TMatrix;
    if isnan(str2double(threshold{1}))
        error('?');
    end
    TTMatrix(TMatrix>=str2double(threshold{1})) = 1;
    TTMatrix(TMatrix<str2double(threshold{1})) = 0;
catch me
    errordlg('The input value is invalid.');
    return;
end

MatrixName=get(handles.Matrix_name_edit,'String');
if ~MU_load_matrix([MatrixName '_msk'], TTMatrix, 1)
    errordlg('Making mask failed!');
end

guidata(handles.MU_matrix_display, handles);

end