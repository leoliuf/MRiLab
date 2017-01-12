
function Plugin_RTRecon

global VCtl
global VImg
global VSig

if ~isfield(VCtl, 'RTR_Flag')
    return;
end

if ~strcmp(VCtl.RTR_Flag, 'on')
    return;
end

Simuh=guidata(VCtl.h.TimeWait_text);
DoUpdateInfo(Simuh,'Real time reconstructing images...');
try 
    %%  Do image reconstruction
    ExecFlag=DoImgRecon(Simuh);
    if ExecFlag==0
        error('Real time image recon is incomplete!');
    end
    DoUpdateInfo(Simuh,'Real time image recon is complete.');

    %% Output K-space plot
    if strcmp(VCtl.PlotK_Flag, 'on')
        [az,el] = view(Simuh.Coronal_axes);
        axes(Simuh.Coronal_axes);
        cla(Simuh.Coronal_axes);
        plot3(VSig.Kx(:),VSig.Ky(:),VSig.Kz(:),'w-');
        grid on;
        set(gca,'Color','k','xcolor','c','ycolor','c','zcolor','c');
        set(gca,'ydir','reverse');
        xlabel('Kx','Color','w');
        ylabel('Ky','Color','w');
        zlabel('Kz','Color','w');
        axis tight;
        box on;
        set(Simuh.Coronal_axes,'view',[az,el]);
        set(Simuh.CZ_text,'Visible','off');
        set(Simuh.CX_text,'Visible','off');
        set(Simuh.Left_text,'Visible','off');
        set(Simuh.Right_text,'Visible','off');
        set(Simuh.Axial_slider,'Visible','off');
        set(Simuh.Sagittal_slider,'Visible','off');
        set(Simuh.Coronal_slider,'Visible','off');
        set(Simuh.AxialFOV,'Visible','off');
        set(Simuh.SagittalFOV,'Visible','off');
        set(Simuh.Coronal_uipanel,'Title','Real Time K-space');
    end
    
    %%  Output image display
    Slice=round(get(Simuh.Preview_slider,'Value'));
    if Slice==0
       set(Simuh.Preview_slider,'Value',1);
    end
    
    Img = sum(VImg.Mag, 4); % show SumofMagn
    Simuh.Img = Img(:,:,:,1); % show first echo
    Simuh.IV=struct(...
        'Slice', min(max(1,Slice), VCtl.SliceNum),...
        'C_lower',min(min(min(Simuh.Img))),...
        'C_upper',max(max(max(Simuh.Img))),...
        'Axes','off',...
        'Grid','off',...
        'Color_map','Gray'...
        );
    DoUpdateImage(Simuh.Preview_axes,Simuh.Img,Simuh.IV);
    set(Simuh.Preview_uipanel,'Title',['Preview : Series' num2str(Simuh.ScanSeriesInd) '...']);
    [row,col,layer]=size(Simuh.Img);
    if layer==1
        set(Simuh.Preview_slider,'Enable','off');
    else
        set(Simuh.Preview_slider,'Enable','on');
        set(Simuh.Preview_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer]);
    end
    
    %% Update handles
    guidata(Simuh.SimuPanel_figure, Simuh);
    pause(VCtl.DelayTime);
catch me
    DoUpdateInfo(Simuh,'Real time image recon is incomplete!');
end

end