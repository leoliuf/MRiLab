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



function MU_func3DProj(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);
%% pre-projection
[Selection,ok] = listdlg('ListString',{'Z-Axis','X-Axis','Y-Axis'}, ...
                         'SelectionMode','single',...
                         'PromptString','Rotation Axis',...
                         'Name','Axis');
if ok==0
    warndlg('3D projection is cancelled.');
    return;
end
switch Selection
    case 1 % axial
        TMatrix = handles.TMatrix;
    case 2 % sagittal
        TMatrix = permute(handles.TMatrix,[3 1 2]);
    case 3 % coronal
        TMatrix = permute(handles.TMatrix,[3 2 1]);
end
[trow,tcol,tlayer] = size(TMatrix);

angle = inputdlg({'Initial angle (degrees)', 'End angle (degrees)', 'Rotation angle increment (degrees)'},'Projection Angle',1,{'0','360','60'});
if isempty(angle)
    warndlg('3D projection is cancelled.');
    return;
end
try % test for angle info
    if str2double(angle{1}) > str2double(angle{2})
        error('?');
    end
    for i = str2double(angle{1}) : str2double(angle{3}) : str2double(angle{2})
    end
catch me
    errordlg('Input angle information is invalid.');
    return;
end


[Selection,ok] = listdlg('ListString',{'Max Intensity','Min Intensity','Average Intenstity','Sum Slices','Median Intensity','Standard Deviation'}, ...
                         'SelectionMode','single',...
                         'PromptString','Projection Methods',... 
                         'Name','Projection');
if ok==0
    warndlg('3D projection is cancelled.');
    return;
end
switch Selection
    case 1
        PMethod = 'max';
    case 2
        PMethod = 'min';
    case 3
        PMethod = 'mean';
    case 4
        PMethod = 'sum';
    case 5
        PMethod = 'median';
    case 6
        PMethod = 'std';
end


[Selection,ok] = listdlg('ListString',{'nearest','bilinear','bicubic'}, ...
                         'SelectionMode','single',...
                         'PromptString','Interpolation Methods',...
                         'Name','Interpolation');
if ok==0
    warndlg('3D projection is cancelled.');
    return;
end
switch Selection
    case 1
        IMethod = 'nearest';
    case 2
        IMethod = 'bilinear';
    case 3
        IMethod = 'bicubic';
end

pause(0.1);
%% projection process
step = str2double(angle{1}) : str2double(angle{3}) : str2double(angle{2});
PMatrix=cell(length(step),1);
prow=zeros(length(step),1);
pcol=zeros(length(step),1);
ind=1;
for j = step
    MU_update_waitbar(handles.Progress_axes,ind,length(step));
    T2Matrix=imrotate(TMatrix(:,:,1),j,IMethod,'loose');
    [row,col]=size(T2Matrix);
    TTMatrix=zeros(row,col,tlayer,class(TMatrix));
    
    for i=1:tlayer
        T2Matrix=imrotate(TMatrix(:,:,i),j,IMethod,'loose');
        TTMatrix(:,:,i)=T2Matrix;
    end
        
    switch PMethod
        case 'max'
            PMatrix{ind} = max(TTMatrix,[],1);
        case 'min'
            PMatrix{ind} = min(TTMatrix,[],1);
        case 'mean'
            PMatrix{ind} = mean(TTMatrix,1);
        case 'sum'
            PMatrix{ind} = sum(TTMatrix,1);
        case 'median'
            PMatrix{ind} = median(TTMatrix,1);
        case 'std'
            PMatrix{ind} = cast(std(double(TTMatrix),0,1),class(TMatrix));
    end
    
    msize = size(PMatrix{ind});
    if length(msize) > 2
        msize(msize==1) = [];
        msize = [ num2str(msize(1)) num2str(msize(2:end),',%d')];
        eval(['PMatrix{ind}=reshape(PMatrix{ind},[' msize ']);']);
    end
    
    msize = size(PMatrix{ind});
    prow(ind)=msize(1);
    pcol(ind)=msize(2);
    ind=ind+1;
end
axes(handles.Matrix_display_axes);

PPMatrix=zeros(max(prow)+mod(max(prow),2),max(pcol)+mod(max(pcol),2),length(step),class(TMatrix));
for i = 1: length(step)
    PPMatrix(end/2-floor(prow(i)/2)+1:end/2+ceil(prow(i)/2),end/2-floor(pcol(i)/2)+1:end/2+ceil(pcol(i)/2),i)=PMatrix{i};
end

%% post-projection
MatrixName=get(handles.Matrix_name_edit,'String');
if ~MU_load_matrix([MatrixName '_3pj'], PPMatrix, 1)
    errordlg('3D reslice failed!');
end

guidata(handles.MU_matrix_display, handles);

end