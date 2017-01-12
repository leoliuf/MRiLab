
function DoDisableButton(varargin)

handles=varargin{3};
handles=guidata(handles.SimuPanel_figure);

set(handles.Scan_pushbutton,'Enable','off');
set(handles.Batch_pushbutton,'Enable','off');

end