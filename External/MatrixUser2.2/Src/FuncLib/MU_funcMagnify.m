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



function MU_funcMagnify(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);


MSize = inputdlg('Please specify the size of magnified region (pixels).','Specify Size',1,{'30'});
if isempty(MSize)
    warndlg('Magnifier was cancelled.');
    return;
end

try
    handles.MSize = str2double(MSize{1});
    A=handles.BMatrix(1:handles.MSize,1:handles.MSize); % quick test for size
    handles.MSize = max(2,handles.MSize - mod(handles.MSize,2)); % even value for size, minimum 2
    figure('Name', 'Instant Magnifier');
    imagesc(zeros(handles.MSize,handles.MSize));
catch me
    errordlg('Input size is invalid.');
    return;
end
handles.MHandle = get(gca,'Children');
colormap(handles.V.Color_map);
axis off;

guidata(handles.MU_matrix_display, handles);


end
