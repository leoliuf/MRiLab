
function DoPlotGradFie(handles)

global VMgd;
global VCtl;
global VObj;
%--------Display Parameters
fieldname=fieldnames(handles.Attrh2);
for i=1:length(fieldname)/2
    try 
        eval(['SD.' fieldname{i*2} '=' get(handles.Attrh2.(fieldname{i*2}),'String') ';']);
    catch me
        TAttr=get(handles.Attrh2.(fieldname{i*2}),'String');
        eval(['SD.' fieldname{i*2} '=''' TAttr{get(handles.Attrh2.(fieldname{i*2}),'Value')}  ''';']);
    end
end
handles.SD=SD;
%--------End

% update grid
VMgd.xdimres=str2num(get(handles.Attrh2.('XDimRes'),'String'));
VMgd.ydimres=str2num(get(handles.Attrh2.('YDimRes'),'String'));
VMgd.zdimres=str2num(get(handles.Attrh2.('ZDimRes'),'String'));
[VMgd.xgrid,VMgd.ygrid,VMgd.zgrid]=meshgrid((-VCtl.ISO(1)+1)*VObj.XDimRes:VMgd.xdimres:(VObj.XDim-VCtl.ISO(1))*VObj.XDimRes,...
                                            (-VCtl.ISO(2)+1)*VObj.YDimRes:VMgd.ydimres:(VObj.YDim-VCtl.ISO(2))*VObj.YDimRes,...
                                            (-VCtl.ISO(3)+1)*VObj.ZDimRes:VMgd.zdimres:(VObj.ZDim-VCtl.ISO(3))*VObj.ZDimRes); 

DoWriteXML2m(DoParseXML(handles.GradXMLFile),[handles.GradXMLFile(1:end-3) 'm']);
clear functions;  % remove the M-functions from the memory
[pathstr,name,ext]=fileparts(handles.GradXMLFile);
eval(['[GxR,GyPE,GzSS]=' name ';']);
eval(['handles.G=' SD.GradLine ';'])
if isempty(find(handles.G ~=0, 1))
    warndlg(['Constant unit gradient is used for ' SD.GradLine '.']);
    return;
end

% calculate grid based on gradient
TmpG=handles.G(:,:,:,1);
TmpG(VMgd.xgrid<=0) = 0;
handles.G(:,:,:,4) = cumsum(TmpG,2) .* VMgd.xdimres;
TmpG=handles.G(:,:,:,1);
TmpG(VMgd.xgrid>=0) = 0;
handles.G(:,:,:,4) = handles.G(:,:,:,4) + flipdim(cumsum(flipdim(-TmpG,2),2),2) .* VMgd.xdimres;

TmpG=handles.G(:,:,:,2);
TmpG(VMgd.ygrid<=0) = 0;
handles.G(:,:,:,4) = handles.G(:,:,:,4) + cumsum(TmpG,1).* VMgd.ydimres;
TmpG=handles.G(:,:,:,2);
TmpG(VMgd.ygrid>=0) = 0;
handles.G(:,:,:,4) = handles.G(:,:,:,4) + flipdim(cumsum(flipdim(-TmpG,1),1),1) .* VMgd.ydimres;

TmpG=handles.G(:,:,:,3);
TmpG(VMgd.zgrid<=0) = 0;
handles.G(:,:,:,4) = handles.G(:,:,:,4) + cumsum(TmpG,3) .* VMgd.zdimres;
TmpG=handles.G(:,:,:,3);
TmpG(VMgd.zgrid>=0) = 0;
handles.G(:,:,:,4) = handles.G(:,:,:,4) + flipdim(cumsum(flipdim(-TmpG,3),3),3) .* VMgd.zdimres;

handles.IV.Colormap=SD.Colormap;
handles.IV.DispMode=SD.DispMode;
DoUpdateSlice(handles.GradField_axes,handles.G,handles.IV,'Grad');
guidata(handles.GradDesignPanel_figure,handles);             
                         

end