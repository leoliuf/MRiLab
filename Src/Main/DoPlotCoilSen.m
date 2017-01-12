
function DoPlotCoilSen(handles)

global VMco;
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
VMco.xdimres=str2num(get(handles.Attrh2.('XDimRes'),'String'));
VMco.ydimres=str2num(get(handles.Attrh2.('YDimRes'),'String'));
VMco.zdimres=str2num(get(handles.Attrh2.('ZDimRes'),'String'));

Mxdims=size(VObj.Rho);
[VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VMco.xdimres:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                            (-(Mxdims(1)-1)/2)*VObj.YDimRes:VMco.ydimres:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                            (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VMco.zdimres:((Mxdims(3)-1)/2)*VObj.ZDimRes);

DoWriteXML2m(DoParseXML(handles.CoilXMLFile),[handles.CoilXMLFile(1:end-3) 'm']);
clear functions; % remove the M-functions from the memory
clear -global VCco; % remove previous coil loops
[pathstr,name,ext]=fileparts(handles.CoilXMLFile);
eval(['[B1x, B1y, B1z, E1x, E1y, E1z, Pos]=' name ';']);
handles.IV.Pos=Pos;
handles.IV.CoilDisplay=SD.CoilDisplay;
handles.IV.Colormap=SD.Colormap;

switch SD.FieldType
    case 'B1Field'
        switch SD.CoilShow
            case 'All'
                handles.Fx=sum(B1x,4);
                handles.Fy=sum(B1y,4);
                handles.Fz=sum(B1z,4);
            case 'Current'
                if ~isempty(handles.Attrh1)
                    handles.Fx=B1x(:,:,:,str2num(get(handles.Attrh1.('CoilID'),'String')));
                    handles.Fy=B1y(:,:,:,str2num(get(handles.Attrh1.('CoilID'),'String')));
                    handles.Fz=B1z(:,:,:,str2num(get(handles.Attrh1.('CoilID'),'String')));
                else
                    handles.Fx=sum(B1x,4);
                    handles.Fy=sum(B1y,4);
                    handles.Fz=sum(B1z,4);
                end
        end
        switch SD.Mode
            case 'Magnitude'
                handles.F=sqrt(handles.Fx.^2+handles.Fy.^2);
            case 'Phase'
                handles.F=angle(handles.Fx+1i*handles.Fy);
            case 'Real'
                handles.F=handles.Fx;
            case 'Imaginary'
                handles.F=handles.Fy;
        end
    case 'E1Field'
        switch SD.CoilShow
            case 'All'
                handles.Fx=sum(E1x,4);
                handles.Fy=sum(E1y,4);
                handles.Fz=sum(E1z,4);
            case 'Current'
                if ~isempty(handles.Attrh1)
                    handles.Fx=E1x(:,:,:,str2num(get(handles.Attrh1.('CoilID'),'String')));
                    handles.Fy=E1y(:,:,:,str2num(get(handles.Attrh1.('CoilID'),'String')));
                    handles.Fz=E1z(:,:,:,str2num(get(handles.Attrh1.('CoilID'),'String')));
                else
                    handles.Fx=sum(E1x,4);
                    handles.Fy=sum(E1y,4);
                    handles.Fz=sum(E1z,4);
                end
        end
        handles.F=sqrt(handles.Fx.^2+handles.Fy.^2+handles.Fz.^2);
end

handles.IV.C_upper=SD.CLimUp;
handles.IV.C_lower=SD.CLimDown;
DoUpdateSlice(handles.CoilSen_axes,handles.F,handles.IV,'Coil');
guidata(handles.CoilDesignPanel_figure,handles);                    
                         
end