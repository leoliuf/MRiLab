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



%Create 3D rendering
function MU_update_3D_render(axes_handle,h,flag)
    
Show_threshold=h.V.Show_threshold;
Show_opacity=h.V.Show_opacity;
Show_connectivity=h.V.Show_connectivity;

switch flag
    case 1 % thresholding
        %------------------------------------------Volume Check
        L=zeros(size(h.TMatrix));
        L(h.TMatrix>=Show_threshold)=1;
        
        if h.V.ConnectFlag
            [L,num]=bwlabeln(L);
            h.idxSize=zeros(num,1);
            for i=1:num
                idx=find(L==i);
                h.idxSize(i)=length(idx);
                if length(idx)>=Show_connectivity
                    L(idx)=1;
                else
                    L(idx)=0;
                end
                MU_update_waitbar(h.Progress_axes,i,num);
            end
        end
        
        h.idxMask=L.*h.TMatrix;
        guidata(axes_handle,h);
        %------------------------------------------End
    case 2 % colormap
        colormap(h.V.Color_map);
        guidata(axes_handle,h);
        return;
    case 3 % red surface
        try
            set(h.V.p,'FaceColor',h.V.FaceColor);
        catch me
            eval(['FaceColor=' h.V.FaceColor ';']);
            set(h.V.p,'FaceColor',FaceColor);
        end
        guidata(axes_handle,h);
        return;
    case 4 % box
        box(axes_handle,h.V.BoxFlag);
        guidata(axes_handle,h);
        return;
    otherwise % others
        % do nothing
end
set(h.MaxCon_text,'string',['@' num2str(max(h.idxSize))]);
%------------------------------------------Rendering

cla(axes_handle);
axes(axes_handle);
h.V.p=patch(isosurface(h.idxMask,Show_threshold,'noshare'),'EdgeColor','none');
try
    set(h.V.p,'FaceColor',h.V.FaceColor);
catch me
    eval(['FaceColor=' h.V.FaceColor ';']);
    set(h.V.p,'FaceColor',FaceColor);
end
h.V.pp=patch(isocaps(h.idxMask,Show_threshold),'FaceColor','interp','EdgeColor','none');
set(h.V.pp,'AmbientStrength',0.6);
set(h.V.p,'SpecularColorReflectance',0,'SpecularExponent',50);
if h.V.PatchPercent~=1
    reducepatch(h.V.p,h.V.PatchPercent);
    reducepatch(h.V.pp,h.V.PatchPercent);
end
isocolors(h.TMatrix,h.V.p);
isocolors(h.TMatrix,h.V.pp);
isonormals(h.idxMask,h.V.p);
% isonormals(h.idxMask,h.V.pp);
alpha(Show_opacity);

% set(axes_handle,'YDir','rev');
zlabel(axes_handle,'Z');
xlabel(axes_handle,'X');
ylabel(axes_handle,'Y');

view(h.V.Viewpoint);
daspect(h.V.AspectRatio);
lightangle(h.V.Viewpoint(1),h.V.Viewpoint(2));
lighting phong;

box(axes_handle,h.V.BoxFlag);
colormap(h.V.Color_map);
colorbar;
axis ([1 h.V.Column 1 h.V.Row 1 h.V.Layer h.V.Min_D h.V.Max_D]);
% axis tight;
%------------------------------------------End
guidata(axes_handle,h);

if Show_connectivity > max(h.idxSize)
    warndlg('No object will be rendered, consider reduce connectivity value or threshold value.');
end

end