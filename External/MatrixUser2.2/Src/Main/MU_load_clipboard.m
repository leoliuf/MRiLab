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




% load image matrix from system clipboard

function MU_load_clipboard(handles)


try
    tKit        = java.awt.Toolkit.getDefaultToolkit();
    cbrd        = tKit.getSystemClipboard(); % get clipboard handle
    reqObj      = java.lang.Object;
    img         = cbrd.getContents(reqObj);
    Dflavor    = img.getTransferDataFlavors();
    imgDfvr     = java.awt.datatransfer.DataFlavor.imageFlavor;
    if(Dflavor(1).equals(imgDfvr))  % check if it is image data
        imarr = img.getTransferData(java.awt.datatransfer.DataFlavor.imageFlavor); % image caught!!
        filehandle = java.io.File('__clpbrdimg_temp.bmp');
        javax.imageio.ImageIO.write(imarr,'bmp',filehandle);
        imdata = imread('__clpbrdimg_temp.bmp','bmp'); % temporary file
        delete('__clpbrdimg_temp.bmp'); % temp file removed
    else
        error('MatrixUser can not fetch system clipboard matrix.');
    end
    
    if ~MU_load_matrix('cpd', imdata, 1)
        error('Loading image from clipboard failed!');
    end
    
catch me
    error_msg{1,1}='Error!!! Getting image information from system clipboard aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end


end