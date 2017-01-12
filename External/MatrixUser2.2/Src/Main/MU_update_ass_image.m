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



%update ass_image display in figures
function varargout=MU_update_ass_image(axes_handles,TMatrix,h)

global Figure_handles;

SMatrix=TMatrix{1}; % Sagittal Matrix
CMatrix=TMatrix{2}; % Coronal Matrix

if isempty(get(get(axes_handles{1},'Children')))
    axes(axes_handles{1});
    cla(axes_handles{1});
    imagesc(SMatrix(:, :, h.V.Localizer.Local_point(1)),[h.V.C_lower h.V.C_upper]);
    colormap(h.V.Color_map);
    axis image;
    axis off;
    
    axes(axes_handles{2});
    cla(axes_handles{2});
    imagesc(CMatrix(:, :, h.V.Localizer.Local_point(2)),[h.V.C_lower h.V.C_upper]);
    colormap(h.V.Color_map);
    axis image;
    axis off;
    
    MU_display_handles=guidata(Figure_handles.MU_display);
    axes(MU_display_handles.Matrix_display_axes);
    
else
    
    set(get(axes_handles{1},'Children'),'CData',SMatrix(:, :, h.V.Localizer.Local_point(1)));
    set(axes_handles{1},'CLim',[h.V.C_lower h.V.C_upper]);
    colormap(axes_handles{1},h.V.Color_map);
    drawnow;
    
    set(get(axes_handles{2},'Children'),'CData',CMatrix(:, :, h.V.Localizer.Local_point(2)));
    set(axes_handles{2},'CLim',[h.V.C_lower h.V.C_upper]);
    colormap(axes_handles{2},h.V.Color_map);
    drawnow;
    
end

varargout{1}=h;
end