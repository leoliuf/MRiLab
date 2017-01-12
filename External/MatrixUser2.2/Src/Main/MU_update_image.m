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



%update image display in figures
function varargout=MU_update_image(axes_handle,TMatrix,handles,dimFlag)

if dimFlag ==0 % flag for unknown matrix dimension
    if ~isfield(handles,'MDimension_tabgroup')
        dimFlag = 2;
    else
        dimFlag = 3;
    end
end
try
    if dimFlag <3
        BMatrix=TMatrix{1}; % background Matrix
        FMatrix=TMatrix{2}; % foreground Matrix
        handles.V.Slice = 1;
        handles.BMatrix=BMatrix;
        
        FMatrix=double(FMatrix);
        BMatrix=double(BMatrix);
    else
        handles.V.DimPointer(dimFlag)= str2double(get(handles.(['Dim' num2str(dimFlag) '_edit']),'String'));
        eval(['BMatrix = TMatrix{1}(:,:' num2str(handles.V.DimPointer(3:end),',%d') ');']); % background Matrix
        FMatrix=TMatrix{2}(:,:,handles.V.DimPointer(3)); % foreground Matrix
        handles.V.Slice = handles.V.DimPointer(3);
        handles.BMatrix=BMatrix;
        
        FMatrix=double(FMatrix);
        BMatrix=double(BMatrix);
    end
catch me
    varargout{1}=handles;
    error_msg{1,1}='ERROR!!! Display update aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

try
    
    if ~isempty(findobj(get(gcf,'Children'),'Tag','Colorbar')) % detect colorbar
        Color_bar=1;
    else
        Color_bar=0;
    end
    
    axes(axes_handle);
    cla(axes_handle);
    
    if handles.Imcontrast==1 % keep imcontrast setting if exists
        handles.Imcontrast=0;
        CLim = get(handles.Matrix_display_axes,'CLim');
        
        if get(handles.C_upper_slider,'Max')< CLim(2)
            set(handles.C_upper_slider,'Max',CLim(2));
            set(handles.C_lower_slider,'Max',CLim(2));
        end
        if get(handles.C_lower_slider,'Min')> CLim(1)
            set(handles.C_lower_slider,'Min',CLim(1));
            set(handles.C_upper_slider,'Min',CLim(1));
        end
        set(handles.C_upper_edit,'String',num2str(CLim(2)));
        set(handles.C_lower_edit,'String',num2str(CLim(1)));
        set(handles.C_upper_slider,'Value',CLim(2));
        set(handles.C_lower_slider,'Value',CLim(1));
        handles.V.C_upper=CLim(2);
        handles.V.C_lower=CLim(1);
    end
    
    if isempty(find(FMatrix~=0,1)) & isempty(handles.V2.Foreground_matrix)
        imagesc(BMatrix,double([handles.V.C_lower handles.V.C_upper]));
        colormap(handles.V.Color_map);
    else
        if isempty(handles.V2.Foreground_matrix)
            BImage=repmat(BMatrix,[1 1 3]);
            FImage=FMatrix;
            BImage=max(double(handles.V.C_lower),min(BImage,double(handles.V.C_upper))); % Make sure BImage is in the range of Color Bound
            BImage=(BImage-double(handles.V.C_lower))./double((handles.V.C_upper-handles.V.C_lower));
            RGBImage=BImage;
            RGBImage(:,:,1)=RGBImage(:,:,1)+trapmf(FImage/10,[0.3 0.6 0.9 1]);
            RGBImage(:,:,2)=RGBImage(:,:,2)+trapmf(FImage/10,[0.1 0.3 0.6 0.9]);
            RGBImage(:,:,3)=RGBImage(:,:,3)+trapmf(FImage/10,[0 0.1 0.3 0.6]);
            RGBImage=max(0,min(RGBImage,1)); % Make sure RGBImage is in the range of 0 and 1
            imagesc(RGBImage,double([handles.V.C_lower, handles.V.C_upper]));
            colormap(handles.V.Color_map);
        else
            BImage=repmat(BMatrix,[1 1 3]);
            BImage=max(double(handles.V.C_lower),min(BImage,double(handles.V.C_upper))); % Make sure BImage is in the range of Color Bound
            BImage=(BImage-double(handles.V.C_lower))./double((handles.V.C_upper-handles.V.C_lower));
            mask=repmat(FMatrix,[1 1 3]);
            FMatrix=max(double(handles.V2.F_lower),min(FMatrix,double(handles.V2.F_upper))); % Make sure FMatrix is in the range of Color Bound
            FMatrix=((FMatrix-handles.V2.F_lower)/(handles.V2.F_upper-handles.V2.F_lower))*(64-1)+1;
            FImage=ind2rgb(round(FMatrix),handles.V2.Color_map);
            if handles.V2.Include0 ~=0 % display 0?
                FImage(mask==0)=0;
            end
            RGBImage=BImage*handles.V2.Backgroud_F+FImage*handles.V2.Foregroud_F;
            RGBImage=max(0,min(RGBImage,1)); % Make sure RGBImage is in the range of 0 and 1
            imagesc(RGBImage,double([handles.V.C_lower, handles.V.C_upper]));
            colormap(handles.V.Color_map);
        end
    end
    
    if handles.V.Localizer.Local_switch==1
        handles.V.Localizer.Local_h1=line([handles.V.Localizer.Local_point(1) handles.V.Localizer.Local_point(1)],[1 handles.V.Row],'Color','y');
        handles.V.Localizer.Local_h2=line([1 handles.V.Column],[handles.V.Localizer.Local_point(2) handles.V.Localizer.Local_point(2)],'Color','r');
    end
    
    if Color_bar==1
        Cbarh=colorbar;
        set(Cbarh,'YColor',[0 0 0],'XColor',[0 0 0]);
    end

    axis(handles.V.Axis);
    %     axis off;
    set(axes_handle,'XLim',handles.V.Xlim,'YLim',handles.V.Ylim);
    set(axes_handle,'XGrid',handles.V.Grid,'YGrid',handles.V.Grid);
    
    if isfield(handles,'ROIData')
        handles=rmfield(handles,'ROIData'); % remove ROI effect for histogram
    end
    
    varargout{1}=handles;
catch me
    varargout{1}=handles;
    error_msg{1,1}='ERROR!!! Display update aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

end