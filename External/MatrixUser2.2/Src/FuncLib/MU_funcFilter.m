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



function MU_funcFilter(Temp,Event,handles)
handles=guidata(handles.MU_matrix_display);

[Type,ok] = listdlg('ListString',{'Averaging filter','Circular averaging filter (pillbox)','Gaussian lowpass filter', ...
                                  '2D Laplacian operator','Laplacian of Gaussian filter',...
                                  'Linear motion of a camera','Prewitt edge-emphasizing filter', ...
                                  'Sobel edge-emphasizing filter','Unsharp contrast enhancement filter', ...
                                  '2D median filter'}, ...
                     'SelectionMode','single',...
                     'PromptString','Filter Type',... 
                     'Name','Type');
if ok==0
    warndlg('Filtering is cancelled.');
    return;
end

try
    switch Type
        case 1
            f = inputdlg({'Filter size:'},'Averaging Filter',1,{'[3 3]'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            eval(['fsize =' f{1} ';']);
            h = fspecial('average', fsize);
        case 2
            f = inputdlg({'Disk radius:'},'Circular Averaging Filter (pillbox)',1,{'5'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            h = fspecial('disk', str2double(f{1}));
        case 3
            f = inputdlg({'Filter size:','Gaussian standard deviation:'},'Gaussian Lowpass Filter',1,{'[3 3]','0.5'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            eval(['fsize =' f{1} ';']);
            h = fspecial('gaussian', fsize, str2double(f{2}));
        case 4
            f = inputdlg({'Shape of the Laplacian (alpha factor 0-1):'},'2D Laplacian',1,{'0.2'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            h = fspecial('laplacian', str2double(f{1}));
        case 5
            f = inputdlg({'Filter size:','Gaussian standard deviation:'},'Laplacian of Gaussian Filter',1,{'[5 5]','0.5'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            eval(['fsize =' f{1} ';']);
            h = fspecial('log', fsize, str2double(f{2}));
        case 6
            f = inputdlg({'The motion length in pixels:','The angle of camera in degrees:'},'Linear Motion of A Camera',1,{'9','0'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            h = fspecial('motion', str2double(f{1}), str2double(f{2}));
        case 7
            f = inputdlg({'Input 1 for horizontal emphasis, 0 for vertical emphasis:'},'Prewitt Filter',1,{'1'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            h = fspecial('prewitt');
            if str2double(f{1}) == 1
            elseif str2double(f{1}) == 0
                h = h';
            else
                warndlg('Wrong input value for this filter.');
                return;
            end
        case 8
            f = inputdlg({'Input 1 for horizontal emphasis, 0 for vertical emphasis:'},'Sobel Filter',1,{'1'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            h = fspecial('sobel');
            if str2double(f{1}) == 1
            elseif str2double(f{1}) == 0
                h = h';
            else
                warndlg('Wrong input value for this filter.');
                return;
            end
        case 9
            f = inputdlg({'Shape of the Laplacian (alpha factor 0-1):'},'Unsharp Contrast Enhancement',1,{'0.2'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            h = fspecial('unsharp', str2double(f{1}));
        case 10
            f = inputdlg({'Filter size:'},'2D Median Filter',1,{'[3 3]'});
            if isempty(f)
                warndlg('Filtering is cancelled.');
                return;
            end
            eval(['fsize =' f{1} ';']);
    end
catch me
    errordlg('Creating filter structure failed. Input value is invalid.');
    return;
end

choice = questdlg('Apply to all slices?','All Slices','No','Yes','No');
if isempty(choice)
    warndlg('Adding noise is cancelled.');
    return;
end

% Handle response
try
    switch choice
        case 'No'
            switch Type
                case 10
                    handles.TMatrix(:,:,handles.V.Slice) = medfilt2(handles.BMatrix, fsize);
                otherwise
                    handles.TMatrix(:,:,handles.V.Slice) = imfilter(handles.BMatrix,h,'replicate');
            end
        case 'Yes'
            switch Type
                case 10
                    if length(handles.V.DimSize)>2
                        for i= 1: handles.V.DimSize(3)
                            handles.TMatrix(:,:,i) = medfilt2(handles.TMatrix(:,:,i),fsize);
                            MU_update_waitbar(handles.Progress_axes,i,handles.V.DimSize(3));
                        end
                    else
                        handles.TMatrix = medfilt2(handles.BMatrix,fsize);
                    end
                otherwise
                    if length(handles.V.DimSize)>2
                        for i= 1: handles.V.DimSize(3)
                            handles.TMatrix(:,:,i) = imfilter(handles.TMatrix(:,:,i),h,'replicate');
                            MU_update_waitbar(handles.Progress_axes,i,handles.V.DimSize(3));
                        end
                    else
                        handles.TMatrix = imfilter(handles.BMatrix,h,'replicate');
                    end
            end
    end
catch me
    errordlg('Filtering process aborted. Error occurs!');
    return;
end

MergeM=get(handles.Matrix_name_edit,'String');
set(handles.Matrix_name_edit,'String',[MergeM '_flr']);

% update current display matrix
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(handles.MU_matrix_display, handles);

end