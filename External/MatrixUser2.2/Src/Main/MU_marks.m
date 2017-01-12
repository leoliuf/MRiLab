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



%Show question mark in figures
function MU_marks(axes_handle,mark)

filepath=mfilename('fullpath');
sep=filesep;
k=strfind(filepath, sep);
path=filepath(1:k(end)-1);

switch mark
    case 'MatrixUser'
        set(gcf,'CurrentAxes',axes_handle);
        MU_logo=imread([path sep '..' sep '..' sep 'Resource' sep 'Icon' sep 'Logo_MatrixUser.png']);
        image(MU_logo);
        axis off;          % Remove axis ticks and numbers
        axis image;        % Set aspect ratio to obtain square pixels
    case 'Question'
        set(gcf,'CurrentAxes',axes_handle);
        MU_logo=imread([path sep '..' sep '..' sep 'Resource' sep 'Icon' sep 'Logo_Question.png']);
        image(MU_logo);
        axis image;        % Set aspect ratio to obtain square pixels
        axis off;          % Remove axis ticks and numbers
end

end