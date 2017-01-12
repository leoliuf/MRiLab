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



% load image matrix from system screenshot

function MU_load_screenshot(handles)

try
    import java.awt.*;
    rob=Robot;
    t=java.awt.Toolkit.getDefaultToolkit();
    rec=java.awt.Rectangle(t.getScreenSize());
    img=rob.createScreenCapture(rec);
    filehandle=java.io.File('__scrnsht_temp.bmp');
    javax.imageio.ImageIO.write(img,'bmp',filehandle);
    imdata = imread('__scrnsht_temp.bmp','bmp'); % temporary file
    delete('__scrnsht_temp.bmp'); % temp file removed
    if ~MU_load_matrix('sns', imdata, 1)
        error('Loading image from screenshot failed!');
    end
    
catch me
    error_msg{1,1}='Error!!! Getting image information from system screenshot aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end


end