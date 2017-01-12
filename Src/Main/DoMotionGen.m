
function DoMotionGen(handles)

global VMot;

%% Compile PSD XML to m function
DoWriteXML2m(DoParseXML(handles.MotXMLFile),[handles.MotXMLFile(1:end-3) 'm']);
clear functions;  % remove the M-functions from the memory
[pathstr,name,ext]=fileparts(handles.MotXMLFile);

%% Motion displacement signal generation 
eval(['[t, ind, Disp, Axis, Ang]=' name ';']);
 
VMot.t=t;
VMot.ind=ind;
VMot.Disp=Disp;
VMot.Axis=Axis;
VMot.Ang=Ang;

end