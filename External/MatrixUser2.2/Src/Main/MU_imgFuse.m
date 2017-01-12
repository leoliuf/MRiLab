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



% Fuse Image
function MU_imgFuse(Temp,Event,h,Allowed_Foreground)
h.main_h=guidata(h.main_h.MU_matrix_display);

selected_matrix= evalin('base', [Allowed_Foreground{get(h.Matrix_list,'Value')} ';']);
selected_matrix(isnan(selected_matrix))=0;
selected_matrix(isinf(selected_matrix))=0;

set(h.FF,'Value',1-get(h.BF,'Value')); %FF+BF=1

set(h.BF_v,'String',num2str(get(h.BF,'Value')));
set(h.FF_v,'String',num2str(get(h.FF,'Value')));
if get(h.Fu,'Value') > get(h.Fl,'Value')
    set(h.F_u,'String',num2str(get(h.Fu,'Value')));
    set(h.F_l,'String',num2str(get(h.Fl,'Value')));
else
    set(h.Fu,'Value',get(h.Fu,'Max'));
    set(h.Fl,'Value',get(h.Fl,'Min'));
    set(h.F_l,'String',num2str(get(h.Fl,'Value')));
    set(h.F_u,'String',num2str(get(h.Fu,'Value')));
end

contents=cellstr(get(h.Colormap,'String'));
color=contents{get(h.Colormap,'Value')};
caxis([get(h.Fl,'Value') get(h.Fu,'Value')])
cmap=colormap(color);

if get(h.Include0,'Value')==0
    set(h.Include0,'String','Exclude 0');
else
    set(h.Include0,'String','Include 0');
end

V2=struct(...
        'Foreground_matrix',Allowed_Foreground{get(h.Matrix_list,'Value')},...
        'F_lower',get(h.Fl,'Value'),...
        'F_upper',get(h.Fu,'Value'),...
        'Backgroud_F',get(h.BF,'Value'),...
        'Foregroud_F',get(h.FF,'Value'),...
        'Include0',get(h.Include0,'Value'),...
        'Color_map',cmap,...
        'Color_bar',1 ...
        );
selected_matrix(selected_matrix>=get(h.Fu,'Value')& selected_matrix~=0 )=get(h.Fu,'Value');
selected_matrix(selected_matrix<=get(h.Fl,'Value')& selected_matrix~=0 )=get(h.Fl,'Value');
h.main_h.Mask=selected_matrix;
h.main_h.V2=V2;
h.main_h=MU_update_image(h.main_h.Matrix_display_axes,{h.main_h.TMatrix,h.main_h.Mask},h.main_h,0);
% MU_update_ass_image({h.main_h.Matrix_display_axes2,h.main_h.Matrix_display_axes3},{h.main_h.SMatrix,h.main_h.CMatrix},h.main_h);
set(h.main_h.C_upper_edit,'String',num2str(h.main_h.V.C_upper));
set(h.main_h.C_upper_slider,'Value',h.main_h.V.C_upper);
set(h.main_h.C_lower_edit,'String',num2str(h.main_h.V.C_lower));
set(h.main_h.C_lower_slider,'Value',h.main_h.V.C_lower);
guidata(h.main_h.MU_matrix_display,h.main_h);

end