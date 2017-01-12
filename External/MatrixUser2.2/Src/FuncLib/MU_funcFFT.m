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



function MU_funcFFT(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

if numel(handles.V.DimSize)>=3
    dim = inputdlg(['Please specify up to which dimension to FFT (2 ~ ' num2str(numel(handles.V.DimSize)) ').'],'Specify Dimension',1,{num2str(numel(handles.V.DimSize))});
    if isempty(dim)
        warndlg('FFT was cancelled.');
        return;
    end
    if str2double(dim{1})<2 | str2double(dim{1})>numel(handles.V.DimSize)
        errordlg('The input dimension is invalid.');
        return;
    end
    try
        if str2double(dim{1}) == 2
            TMatrix=fftshift(ifftn(fftshift(handles.TMatrix(:,:,handles.V.Slice))));
        else
            if str2double(dim{1})+1>numel(handles.V.DimSize)
                dimFlag =[];
            else
                dimFlag=num2str(handles.V.DimPointer(str2double(dim{1})+1:end),',%u');
            end
            eval(['TMatrix=fftshift(ifftn(fftshift(handles.TMatrix(:,:' repmat(',:', [1 str2double(dim{1})-2]) dimFlag '))));']);
        end
    catch me
        errordlg('The input dimension is invalid.');
        return;
    end
    
else
    TMatrix=fftshift(ifftn(fftshift(handles.TMatrix(:,:,handles.V.Slice))));
end

MatrixName=get(handles.Matrix_name_edit,'String');

if ~MU_load_matrix([MatrixName '_fft'], TMatrix, 1)
    errordlg('FFT matrix failed!');
end


end