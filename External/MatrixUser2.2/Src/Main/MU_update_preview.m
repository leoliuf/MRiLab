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



%update preview in panels
function MU_update_preview(axes_handle,TMatrix,V) 
    
    axes(axes_handle);
    cla(axes_handle);
    imagesc(TMatrix(:, :, V.Slice),[V.C_lower V.C_upper]);
    colormap(V.Color_map);
    if V.Color_bar==1
        colorbar;
    end
    axis image;
    axis off;
end