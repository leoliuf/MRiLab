
function DoPlotVObj(handles)

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

DoWriteXML2m(DoParseXML(handles.VObjXMLFile),[handles.VObjXMLFile(1:end-3) 'm']);
clear functions;  % remove the M-functions from the memory
[pathstr,name,ext]=fileparts(handles.VObjXMLFile);
eval(['[Obj, VObj]=' name '(0);']);

axes(handles.VObj_axes);
[az,el] = view(gca);
cla(handles.VObj_axes);
for i=1:length(Obj(1,:))         
    p(i)=patch(Obj{1,i});
    if isempty(str2num(Obj{2,i}))
        set(p(i),'FaceColor',Obj{2,i},'FaceAlpha',Obj{3,i});
    else
        set(p(i),'FaceColor',str2num(Obj{2,i}),'FaceAlpha',Obj{3,i});
    end
end
view([az,el]);
box(SD.Box);
eval(['grid ' SD.Grid]);
cameratoolbar(SD.CameraTool);
axis image;
set(gca,'XLim',[(-(VObj.XDim-1)/2)*VObj.XDimRes ((VObj.XDim-1)/2)*VObj.XDimRes],...
        'YLim',[(-(VObj.YDim-1)/2)*VObj.YDimRes ((VObj.YDim-1)/2)*VObj.YDimRes],...
        'ZLim',[(-(VObj.ZDim-1)/2)*VObj.ZDimRes ((VObj.ZDim-1)/2)*VObj.ZDimRes]);
set(gca,'YDir','reverse','ZDir','reverse');
xlabel('X');
ylabel('Y');
zlabel('Z');
lighting phong;

end