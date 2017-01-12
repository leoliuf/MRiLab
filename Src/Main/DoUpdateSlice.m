
%update slice display in figures
function DoUpdateSlice(axes_handle,Matrix,V,Mode)

global VMco;
global VCco;
global VMmg;
global VMgd;

switch Mode
    case 'Coil'
        [az,el] = view(axes_handle);
        cla;
        if size(Matrix,2)>1
            slice(axes_handle,VMco.xgrid,VMco.ygrid,VMco.zgrid,Matrix,V.xslice,V.yslice,V.zslice);
        else
            error('Field map is not available.');
        end
        xlabel('X axis');
        ylabel('Y axis');
        zlabel('Z axis');
        colormap(V.Colormap);
        Cbarh=colorbar;
        set(Cbarh,'YColor',[0 0 0],'XColor',[0 0 0]);
        set(axes_handle,'view',[az,el],'CLim',[V.C_lower V.C_upper]);
        hold(axes_handle,'on');
        scatter3(axes_handle,0,0,0,'filled','dr');
        
        if strcmp(V.CoilDisplay,'on')
            scatter3(axes_handle,V.Pos(:,1),V.Pos(:,2),V.Pos(:,3),'filled','k');
            text(V.Pos(:,1),V.Pos(:,2),V.Pos(:,3),num2cell(1:length(V.Pos(:,1))),'FontSize',18);
            if isfield(VCco,'loops')
                for i=1:length(VCco.loops)
                    loops=VCco.loops{i};
                    if ~isempty(loops)
                        plot3(loops(1,:),loops(2,:),loops(3,:),'k-','LineWidth',2);
                    end
                end
            end
        end
        hold(axes_handle,'off');
        
        set(axes_handle,'XLim',[min(min(min(VMco.xgrid)))*1.5 max(max(max(VMco.xgrid)))*1.5]);
        set(axes_handle,'YLim',[min(min(min(VMco.ygrid)))*1.5 max(max(max(VMco.ygrid)))*1.5]);
        set(axes_handle,'ZLim',[min(min(min(VMco.zgrid)))*1.5 max(max(max(VMco.zgrid)))*1.5]);
        set(axes_handle,'YDir','reverse','ZDir','reverse');
        axis image;
        
    case 'Mag'
        
        [az,el] = view(axes_handle);
        slice(axes_handle,VMmg.xgrid,VMmg.ygrid,VMmg.zgrid,Matrix,V.xslice,V.yslice,V.zslice);
        xlabel('X axis');
        ylabel('Y axis');
        zlabel('Z axis');
        colormap(V.Colormap);
        Cbarh=colorbar;
        set(Cbarh,'YColor',[0 0 0],'XColor',[0 0 0]);
        set(axes_handle,'view',[az,el]);
        hold(axes_handle,'on');
        scatter3(axes_handle,0,0,0,'filled','dr');
        hold(axes_handle,'off');
        set(axes_handle,'XLim',[min(min(min(VMmg.xgrid)))*1 max(max(max(VMmg.xgrid)))*1]);
        set(axes_handle,'YLim',[min(min(min(VMmg.ygrid)))*1 max(max(max(VMmg.ygrid)))*1]);
        set(axes_handle,'ZLim',[min(min(min(VMmg.zgrid)))*1 max(max(max(VMmg.zgrid)))*1]);
        set(axes_handle,'YDir','reverse','ZDir','reverse');
        axis image;
        
     case 'Grad'
        
         [az,el] = view(axes_handle);

         switch V.DispMode
             case 'Both'
                 % display gradient
                 quiver3(axes_handle,VMgd.xgrid,VMgd.ygrid,VMgd.zgrid,Matrix(:,:,:,1),Matrix(:,:,:,2),Matrix(:,:,:,3));
                 hold(axes_handle,'on');
                 % display grid after transform
                 slice(axes_handle,VMgd.xgrid,VMgd.ygrid,VMgd.zgrid,Matrix(:,:,:,4),V.xslice,V.yslice,V.zslice);
                 colormap(V.Colormap);
                 Cbarh=colorbar;
                 set(Cbarh,'YColor',[0 0 0],'XColor',[0 0 0]);
                 
             case 'Gradient'
                 % display gradient
                 quiver3(axes_handle,VMgd.xgrid,VMgd.ygrid,VMgd.zgrid,Matrix(:,:,:,1),Matrix(:,:,:,2),Matrix(:,:,:,3));
                 hold(axes_handle,'on');
                 
             case 'Grid'
                 % display grid after transform
                 slice(axes_handle,VMgd.xgrid,VMgd.ygrid,VMgd.zgrid,Matrix(:,:,:,4),V.xslice,V.yslice,V.zslice);
                 hold(axes_handle,'on');
                 colormap(V.Colormap);
                 Cbarh=colorbar;
                 set(Cbarh,'YColor',[0 0 0],'XColor',[0 0 0]);
         end
         
         scatter3(axes_handle,0,0,0,'filled','dr');
         hold(axes_handle,'off');
         
         xlabel('X axis');
         ylabel('Y axis');
         zlabel('Z axis');
         set(axes_handle,'view',[az,el]);
         set(axes_handle,'XLim',[min(min(min(VMgd.xgrid)))*1 max(max(max(VMgd.xgrid)))*1]);
         set(axes_handle,'YLim',[min(min(min(VMgd.ygrid)))*1 max(max(max(VMgd.ygrid)))*1]);
         set(axes_handle,'ZLim',[min(min(min(VMgd.zgrid)))*1 max(max(max(VMgd.zgrid)))*1]);
         set(axes_handle,'YDir','reverse','ZDir','reverse');
         axis image;
        
end


end