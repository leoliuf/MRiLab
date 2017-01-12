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



% --- Updata waitbar for processing DICOM files

function MU_update_waitbar(axes_handle,value,total_value)

axes(axes_handle);
cla(axes_handle);
axis(axes_handle,[0,total_value,0,1]);
patch([0,value,value,0],[0,0,1,1],'r');
% axis off;

if value==1 & value~=total_value
    set(axes_handle,'Visible','on');
elseif value==total_value
    set(axes_handle,'Visible','off');
    axes(axes_handle);
    cla(axes_handle);
end

end