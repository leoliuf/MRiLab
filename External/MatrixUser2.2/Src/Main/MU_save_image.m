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



% save image to file from axes
function MU_save_image(axes_handle)

[filename,pathname,FilterIndex]=uiputfile({ '*.bmp','Windows Bitmap (*.bmp)';...
                                '*.hdf','Hierarchical Data Format (*.hdf)';...
                                '*.jpg','Joint Photographic Experts Group (*.jpg)';...
                                '*.pbm','Portable Bitmap (*.pbm)';...
                                '*.pgm','Portable Graymap (*.pgm)';...
                                '*.png','Portable Network Graphics (*.png)';...
                                '*.pnm','Portable Anymap (*.pnm)';...
                                '*.ppm','Portable Pixmap (*.ppm)';...
                                '*.ras','Sun Raster (*.ras)';...
                                '*.tif','Tagged Image File Format (*.tif)'},...
                                'Save image','Untitled.bmp');
if filename==0
        return;
end

F=getframe(axes_handle);  % Only want to get axes.
imwrite(F.cdata,[pathname, filename]);  % Write the image.

end