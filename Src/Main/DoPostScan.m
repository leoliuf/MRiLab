
function DoPostScan(Simuh)

global VCtl
global VImg
global VCoi

DoUpdateInfo(Simuh,'Scan is complete!');
set(Simuh.TimeWait_text,'String', ['Est. Time Left :  ' '~' ' : ' '~' ' : ' '~']);

%% Signal Post-Processing
%  Add noise
DoAddNoise;

%% Image reconstruction
if strcmp(VCtl.AutoRecon,'on')
    
    %  Do image reconstruction
    DoUpdateInfo(Simuh,'Reconstructing images...');
    ExecFlag=DoImgRecon(Simuh);
    if ExecFlag==0
        error('Image recon is incomplete!');
    end
    DoUpdateInfo(Simuh,'Image recon is complete.');
    
    %  Enable channel selection
    channel = {'SumofMagn';'SumofCplx'};
    for i = 1:VCoi.RxCoilNum
        channel{i+2} = i;
    end
    set(Simuh.Channel_popupmenu,'String',channel);
    set(Simuh.Channel_popupmenu,'Enable','on');
    
    %  Enable echo selection
    echo = {};
    for i = 1:size(VImg.Mag,5)
        echo{i} = i;
    end
    set(Simuh.Echo_popupmenu,'String',echo);
    set(Simuh.Echo_popupmenu,'Enable','on');
    
    %  Output image display
    set(Simuh.Channel_popupmenu,'Value', 1);
    set(Simuh.Echo_popupmenu,'Value', 1);
    Simuh=guidata(Simuh.SimuPanel_figure);
    Img = sum(VImg.Mag, 4); % show SumofMagn
    Simuh.Img = Img(:,:,:,1); % show first echo
    Simuh.IV=struct(...
        'Slice',ceil(VCtl.SliceNum/2),...
        'C_lower',min(min(min(Simuh.Img))),...
        'C_upper',max(max(max(Simuh.Img))),...
        'Axes','off',...
        'Grid','off',...
        'Color_map','Gray'...
        );
    DoUpdateImage(Simuh.Preview_axes,Simuh.Img,Simuh.IV);
    set(Simuh.Preview_uipanel,'Title',['Preview : Series' num2str(Simuh.ScanSeriesInd)]);
    [row,col,layer]=size(Simuh.Img);
    if layer==1
        set(Simuh.Preview_slider,'Enable','off');
    else
        set(Simuh.Preview_slider,'Enable','on');
        set(Simuh.Preview_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer],'Value',ceil(layer/2));
    end
    guidata(Simuh.SimuPanel_figure, Simuh);
    
    % Saving output
    DoUpdateInfo(Simuh,'Saving recon images & data & info...');
    DoSaveOutput(Simuh);
    DoUpdateInfo(Simuh,'Image data saving is complete!');
    
else
    % Saving output
    TmpVImg = VImg;
    VImg = []; % clear VImg
    DoUpdateInfo(Simuh,'Saving signal data & info...');
    DoSaveOutput(Simuh);
    DoUpdateInfo(Simuh,'Signal data saving is complete!');
    VImg = TmpVImg;
    
end

end