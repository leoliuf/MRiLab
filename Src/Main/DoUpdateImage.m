
%update image display in figures
function DoUpdateImage(axes_handle,Matrix,V) 
try
    axes(axes_handle);
    cbar=findobj(gcf,'tag','Colorbar');
    
    if ~verLessThan('matlab','8.5')
        % Code to run in MATLAB R2015a and later here
        delete(allchild(axes_handle));
    else
        cla(axes_handle);
    end
    
    imagesc(Matrix(:, :, V.Slice),[V.C_lower V.C_upper]);
    colormap(V.Color_map);
    if ~isempty(cbar)
        colorbar
    end
    set(axes_handle,'XGrid',V.Grid,'YGrid',V.Grid);
    axis image;
    axis(V.Axes);
catch me
%     error_msg{1,1}='ERROR!!! Displaying chosen image failed.';
%     error_msg{2,1}=me.message;
%     errordlg(error_msg);
end
end