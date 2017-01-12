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



function MU_MIP(h)


dim = inputdlg(['Please specify which dimension to perform projection (1 ~ ' num2str(numel(h.V.DimSize)) ').'],'Specify dimension',1,{num2str(min(3,numel(h.V.DimSize)))});
if isempty(dim)
    warndlg('Projection was cancelled.');
    return;
end

[Selection,ok] = listdlg('ListString',{'Max Intensity','Min Intensity','Average Intenstity','Sum Slices','Median Intensity','Standard Deviation'}, ...
                         'SelectionMode','single',...
                         'PromptString','Projection Methods',... 
                         'Name','Projection');
if ok==0
    Selection = 1;
    warndlg('Max intensity projection is used.');
end

try
    switch Selection
        case 1
            eval(['TMatrix=max(h.TMatrix,[],' dim{1} ');']);
        case 2
            eval(['TMatrix=min(h.TMatrix,[],' dim{1} ');']);
        case 3
            eval(['TMatrix=mean(h.TMatrix,' dim{1} ');']);
        case 4
            eval(['TMatrix=sum(h.TMatrix,' dim{1} ');']);
        case 5
            eval(['TMatrix=median(h.TMatrix,' dim{1} ');']);
        case 6
            eval(['TMatrix=cast(std(double(h.TMatrix),0,' dim{1} '),class(h.TMatrix));']);
    end
    msize = size(TMatrix);
    if length(msize) > 2
        msize(msize==1) = [];
        msize = [ num2str(msize(1)) num2str(msize(2:end),',%d')];
        eval(['TMatrix=reshape(TMatrix,[' msize ']);']);
    end
catch me
    errordlg('The input dimension is invalid.');
    return;
end

MatrixName=get(h.Matrix_name_edit,'String');

if ~MU_load_matrix([MatrixName '_prj'], TMatrix, 1)
    errordlg('Projection failed!');
end

end