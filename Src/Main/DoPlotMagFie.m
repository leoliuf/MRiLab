
function DoPlotMagFie(handles)

global VMmg;
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
VMmg.xdimres=str2num(get(handles.Attrh2.('XDimRes'),'String'));
VMmg.ydimres=str2num(get(handles.Attrh2.('YDimRes'),'String'));
VMmg.zdimres=str2num(get(handles.Attrh2.('ZDimRes'),'String'));
Mxdims=size(VObj.Rho);
[VMmg.xgrid,VMmg.ygrid,VMmg.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VMmg.xdimres:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                            (-(Mxdims(1)-1)/2)*VObj.YDimRes:VMmg.ydimres:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                            (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VMmg.zdimres:((Mxdims(3)-1)/2)*VObj.ZDimRes);  

DoWriteXML2m(DoParseXML(handles.MagXMLFile),[handles.MagXMLFile(1:end-3) 'm']);
clear functions;  % remove the M-functions from the memory
[pathstr,name,ext]=fileparts(handles.MagXMLFile);
eval(['dB0=' name ';']);
handles.dB0=dB0;
handles.IV.Colormap=SD.Colormap;

DoUpdateSlice(handles.MagField_axes,handles.dB0,handles.IV,'Mag');
guidata(handles.MagDesignPanel_figure,handles);             
                         

end