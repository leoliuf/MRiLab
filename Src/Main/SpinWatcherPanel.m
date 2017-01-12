
function varargout = SpinWatcherPanel(varargin)
% SPINWATCHERPANEL MATLAB code for SpinWatcherPanel.fig
%      SPINWATCHERPANEL, by itself, creates a new SPINWATCHERPANEL or raises the existing
%      singleton*.
%
%      H = SPINWATCHERPANEL returns the handle to a new SPINWATCHERPANEL or the handle to
%      the existing singleton*.
%
%      SPINWATCHERPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPINWATCHERPANEL.M with the given input arguments.
%
%      SPINWATCHERPANEL('Property','Value',...) creates a new SPINWATCHERPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpinWatcherPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpinWatcherPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpinWatcherPanel

% Last Modified by GUIDE v2.5 20-Jan-2014 16:21:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SpinWatcherPanel_OpeningFcn, ...
    'gui_OutputFcn',  @SpinWatcherPanel_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpinWatcherPanel is made visible.
function SpinWatcherPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpinWatcherPanel (see VARARGIN)

global VObj
handles.Simuh=varargin{1};

%Load tabs for Spin Property & Environment
try
    handles.SpinWatchAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SpinWatchAttr.xml']);
catch ME
    errordlg('SpinWatchAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.SpinWatcherPanel_figure,handles);
for i=1:length(handles.SpinWatchAttrStruct.Children)
    eval(['handles.' handles.SpinWatchAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.SpinWatchAttrStruct.Children(i).Name ''',''Units'',''points'');']);
    eval(['DoEditValue(handles,handles.' handles.SpinWatchAttrStruct.Children(i).Name '_tab,handles.SpinWatchAttrStruct.Children(' num2str(i) ').Attributes,1,[0.2,0.12,0.0,0.1,0.1,0.05]);']);
    handles=guidata(handles.SpinWatcherPanel_figure);
end

%Fill tab parameters
ISO=handles.Simuh.ISO;
set(handles.Attrh1.LocX,'String',num2str(ISO(1)));
set(handles.Attrh1.LocY,'String',num2str(ISO(2)));
set(handles.Attrh1.LocZ,'String',num2str(ISO(3)));
set(handles.Attrh1.SpinPerVoxel,'String',num2str(VObj.SpinNum));
set(handles.Attrh1.TypeNum,'String',num2str(VObj.TypeNum));
set(handles.Attrh1.Gyro,'String',num2str(VObj.Gyro));
set(handles.Attrh1.ChemShift,'String',num2str(VObj.ChemShift));
set(handles.Attrh1.Rho,'String',num2str(VObj.Rho(ISO(2),ISO(1),ISO(3),:)));
set(handles.Attrh1.T1,'String',num2str(VObj.T1(ISO(2),ISO(1),ISO(3),:)));
set(handles.Attrh1.T2,'String',num2str(VObj.T2(ISO(2),ISO(1),ISO(3),:)));
set(handles.Attrh1.T2Star,'String',num2str(VObj.T2Star(ISO(2),ISO(1),ISO(3),:)));

%Load axial image for spin location
handles.AMatrix=handles.Simuh.AMatrix;
[row,col,layer]=size(handles.AMatrix);
handles.AV=handles.Simuh.AV;
Grid=get(handles.Attrh1.Grid,'String');
Axes=get(handles.Attrh1.Axes,'String');
handles.AV.Grid=Grid{get(handles.Attrh1.Grid,'Value')};
handles.AV.Axes=Axes{get(handles.Attrh1.Axes,'Value')};
DoUpdateImage(handles.Axial_axes,handles.AMatrix,handles.AV);
ISOHighlight=get(handles.Attrh1.ISOHighlight,'String');
if handles.AV.Slice==ISO(3) & strcmp(ISOHighlight{get(handles.Attrh1.ISOHighlight,'Value')},'on')
    hold on
    scatter(ISO(1),ISO(2),'ro','filled');
    hold off
end
set(handles.Axial_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer],'Value',handles.AV.Slice);

% Choose default command line output for SpinWatcherPanel
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpinWatcherPanel wait for user response (see UIRESUME)
% uiwait(handles.SpinWatcherPanel_figure);


% --- Outputs from this function are returned to the command line.
function varargout = SpinWatcherPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SpinExecute_pushbutton.
function SpinExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SpinExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
ExecFlag=DoSpinWatchExec(handles);
set(handles.Simuh.TimeWait_text,'String', ['Est. Time Left :  ' '~' ' : ' '~' ' : ' '~']);
handles=guidata(handles.SpinWatcherPanel_figure);
if ExecFlag==0
    set(hObject,'Enable','on');
    set(hObject,'String','Execute');
    return;
end
handles.PauseFlag=0;
set(handles.Undock_pushbutton,'Enable','on');
set(handles.Export_pushbutton,'Enable','on');
set(handles.Leftend_pushbutton,'Enable','on');
set(handles.Rightend_pushbutton,'Enable','on');
set(handles.Pause_pushbutton,'Enable','on');
set(handles.Right_pushbutton,'Enable','on');
set(handles.DoubleRight_pushbutton,'Enable','on');
set(handles.Watcher_slider,'Enable','on');
set(handles.Pause_pushbutton,'String','X');

%% Display
% Spin Rotation
Mx=handles.Mx(:,:,:,:,:,1);
My=handles.My(:,:,:,:,:,1);
Mz=handles.Mz(:,:,:,:,:,1);
WindowSize=str2double(get(handles.Attrh1.WindowSize,'String'));
colorpick = linspace(0,1,str2double(get(handles.Attrh1.TypeNum,'String')));
for i=1:str2double(get(handles.Attrh1.TypeNum,'String'))
    spinver=quiver3(handles.SpinRot_axes,squeeze(handles.Gxgrid),squeeze(handles.Gygrid),squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,i)),squeeze(My(:,:,:,:,i)),squeeze(Mz(:,:,:,:,i)));
    set(spinver,'AutoScale','off');
    hold(handles.SpinRot_axes,'on');
    plot(handles.Mxy_axes,handles.Muts(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep)),handles.MxySum(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep),i),'Color',[0 colorpick(i) 0]);
    hold(handles.Mxy_axes,'on');
    plot(handles.Mz_axes,handles.Muts(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep)),handles.MzSum(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep),i),'Color',[0 0 colorpick(i)]);
    hold(handles.Mz_axes,'on');
end
hold(handles.SpinRot_axes,'off');
hold(handles.Mxy_axes,'off');
hold(handles.Mz_axes,'off');
set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[-1 1]);
xlabel(handles.SpinRot_axes,'X axis');
ylabel(handles.SpinRot_axes,'Y axis');
zlabel(handles.SpinRot_axes,'Z axis');
set(handles.SpinRot_axes,'view',[134,24]);

set(handles.Mxy_axes,'YGrid','on','XGrid','off','XTick',[],'XLim',[handles.Muts(1) handles.Muts(min(WindowSize,handles.MutsStep))],'YLim', [handles.MinMxySum handles.MaxMxySum]);
set(handles.Mz_axes,'YGrid','on','XGrid','off','XLim',[handles.Muts(1) handles.Muts(min(WindowSize,handles.MutsStep))],'YLim', [handles.MinMzSum handles.MaxMzSum]);

set(handles.Watcher_slider,'Min',1);
set(handles.Watcher_slider,'Max',handles.MutsStep);
set(handles.Watcher_slider,'Value',1);

set(hObject,'Enable','on');
set(hObject,'String','Execute');
guidata(handles.SpinWatcherPanel_figure, handles);

% --- Executes on button press in UpdateAttrXML_pushbutton.
function UpdateAttrXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateAttrXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update SpinWatchAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.SpinWatchAttrStruct.Children)
    Attrh1=get(tabs(j),'Children');
    for i=1:2:length(Attrh1)
        if ~iscell(get(Attrh1(end-i),'String'))
            handles.SpinWatchAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh1(end-i),'String');
        else
            handles.SpinWatchAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh1(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.SpinWatchAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SpinWatchAttr.xml']);


% --- Executes on slider movement.
function Watcher_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Watcher_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

[az,el] = view(handles.SpinRot_axes);
WatcherStep=round(get(handles.Watcher_slider,'Value'));
WindowSize=str2double(get(handles.Attrh1.WindowSize,'String'));

Mx=handles.Mx(:,:,:,:,:,WatcherStep);
My=handles.My(:,:,:,:,:,WatcherStep);
Mz=handles.Mz(:,:,:,:,:,WatcherStep);
colorpick = linspace(0,1,str2double(get(handles.Attrh1.TypeNum,'String')));
for j=1:str2double(get(handles.Attrh1.TypeNum,'String'))
    spinver=quiver3(handles.SpinRot_axes,squeeze(handles.Gxgrid),squeeze(handles.Gygrid),squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),squeeze(My(:,:,:,:,j)),squeeze(Mz(:,:,:,:,j)));
    set(spinver,'AutoScale','off');
    hold(handles.SpinRot_axes,'on');
    if WatcherStep > WindowSize
        plot(handles.Mxy_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MxySum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 colorpick(j) 0]);
        hold(handles.Mxy_axes,'on');
        plot(handles.Mz_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MzSum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 0 colorpick(j)]);
        hold(handles.Mz_axes,'on');
    end
end
hold(handles.SpinRot_axes,'off');
hold(handles.Mxy_axes,'off');
hold(handles.Mz_axes,'off');
set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[-1 1]);
xlabel(handles.SpinRot_axes,'X axis');
ylabel(handles.SpinRot_axes,'Y axis');
zlabel(handles.SpinRot_axes,'Z axis');
set(handles.SpinRot_axes,'view',[az,el]);

if WatcherStep > WindowSize
    set(handles.Mxy_axes,'YGrid','on','XGrid','off','XTick',[],'XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMxySum handles.MaxMxySum]);
    set(handles.Mz_axes,'YGrid','on','XGrid','off','XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMzSum handles.MaxMzSum]);
end


% --- Executes during object creation, after setting all properties.
function Watcher_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Watcher_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Right_pushbutton.
function Right_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Right_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el] = view(handles.SpinRot_axes);
WindowSize=str2double(get(handles.Attrh1.WindowSize,'String'));
Starti=round(get(handles.Watcher_slider,'Value'));
for i=Starti+1:handles.MutsStep
    handles=guidata(hObject);
    if handles.PauseFlag==1
        return;
    end
    set(handles.Watcher_slider,'Value',i);
    WatcherStep=round(get(handles.Watcher_slider,'Value'));
    
    Mx=handles.Mx(:,:,:,:,:,WatcherStep);
    My=handles.My(:,:,:,:,:,WatcherStep);
    Mz=handles.Mz(:,:,:,:,:,WatcherStep);
    colorpick = linspace(0,1,str2double(get(handles.Attrh1.TypeNum,'String')));
    for j=1:str2double(get(handles.Attrh1.TypeNum,'String'))
        spinver=quiver3(handles.SpinRot_axes,squeeze(handles.Gxgrid),squeeze(handles.Gygrid),squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),squeeze(My(:,:,:,:,j)),squeeze(Mz(:,:,:,:,j)));
        set(spinver,'AutoScale','off');
        hold(handles.SpinRot_axes,'on');
        if WatcherStep > WindowSize
            plot(handles.Mxy_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MxySum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 colorpick(j) 0]);
            hold(handles.Mxy_axes,'on');
            plot(handles.Mz_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MzSum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 0 colorpick(j)]);
            hold(handles.Mz_axes,'on');
        end
    end
    hold(handles.SpinRot_axes,'off');
    hold(handles.Mxy_axes,'off');
    hold(handles.Mz_axes,'off');
    set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[-1 1]);
    xlabel(handles.SpinRot_axes,'X axis');
    ylabel(handles.SpinRot_axes,'Y axis');
    zlabel(handles.SpinRot_axes,'Z axis');
    set(handles.SpinRot_axes,'view',[az,el]);
    if WatcherStep > WindowSize
        set(handles.Mxy_axes,'YGrid','on','XGrid','off','XTick',[],'XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMxySum handles.MaxMxySum]);
        set(handles.Mz_axes,'YGrid','on','XGrid','off','XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMzSum handles.MaxMzSum]);
    end
    
    pause(0.1);
end



% --- Executes on button press in DoubleRight_pushbutton.
function DoubleRight_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DoubleRight_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el] = view(handles.SpinRot_axes);
WindowSize=str2double(get(handles.Attrh1.WindowSize,'String'));
Starti=round(get(handles.Watcher_slider,'Value'));
for i=Starti+1:handles.MutsStep
    handles=guidata(hObject);
    if handles.PauseFlag==1
        return;
    end
    set(handles.Watcher_slider,'Value',i);
    WatcherStep=round(get(handles.Watcher_slider,'Value'));
    
    Mx=handles.Mx(:,:,:,:,:,WatcherStep);
    My=handles.My(:,:,:,:,:,WatcherStep);
    Mz=handles.Mz(:,:,:,:,:,WatcherStep);
    colorpick = linspace(0,1,str2double(get(handles.Attrh1.TypeNum,'String')));
    for j=1:str2double(get(handles.Attrh1.TypeNum,'String'))
        spinver=quiver3(handles.SpinRot_axes,squeeze(handles.Gxgrid),squeeze(handles.Gygrid),squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),squeeze(My(:,:,:,:,j)),squeeze(Mz(:,:,:,:,j)));
        set(spinver,'AutoScale','off');
        hold(handles.SpinRot_axes,'on');
        if WatcherStep > WindowSize
            plot(handles.Mxy_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MxySum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 colorpick(j) 0]);
            hold(handles.Mxy_axes,'on');
            plot(handles.Mz_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MzSum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 0 colorpick(j)]);
            hold(handles.Mz_axes,'on');
        end
    end
    hold(handles.SpinRot_axes,'off');
    hold(handles.Mxy_axes,'off');
    hold(handles.Mz_axes,'off');
    set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[-1 1]);
    xlabel(handles.SpinRot_axes,'X axis');
    ylabel(handles.SpinRot_axes,'Y axis');
    zlabel(handles.SpinRot_axes,'Z axis');
    set(handles.SpinRot_axes,'view',[az,el]);
    if WatcherStep > WindowSize
        set(handles.Mxy_axes,'YGrid','on','XGrid','off','XTick',[],'XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMxySum handles.MaxMxySum]);
        set(handles.Mz_axes,'YGrid','on','XGrid','off','XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMzSum handles.MaxMzSum]);
    end
    
    pause(0.001);
end

% --- Executes on button press in Leftend_pushbutton.
function Leftend_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Leftend_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el] = view(handles.SpinRot_axes);
set(handles.Watcher_slider,'Value',1);
WatcherStep=round(get(handles.Watcher_slider,'Value'));
WindowSize=str2double(get(handles.Attrh1.WindowSize,'String'));

Mx=handles.Mx(:,:,:,:,:,WatcherStep);
My=handles.My(:,:,:,:,:,WatcherStep);
Mz=handles.Mz(:,:,:,:,:,WatcherStep);
colorpick = linspace(0,1,str2double(get(handles.Attrh1.TypeNum,'String')));
for j=1:str2double(get(handles.Attrh1.TypeNum,'String'))
    spinver=quiver3(handles.SpinRot_axes,squeeze(handles.Gxgrid),squeeze(handles.Gygrid),squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),squeeze(My(:,:,:,:,j)),squeeze(Mz(:,:,:,:,j)));
    set(spinver,'AutoScale','off');
    hold(handles.SpinRot_axes,'on');
    
    plot(handles.Mxy_axes,handles.Muts(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep)),handles.MxySum(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep),j),'Color',[0 colorpick(j) 0]);
    hold(handles.Mxy_axes,'on');
    plot(handles.Mz_axes,handles.Muts(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep)),handles.MzSum(1:min(min(WindowSize,handles.MutsStep),handles.MutsStep),j),'Color',[0 0 colorpick(j)]);
    hold(handles.Mz_axes,'on');
    
end
hold(handles.SpinRot_axes,'off');
hold(handles.Mxy_axes,'off');
hold(handles.Mz_axes,'off');
set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[-1 1]);
xlabel(handles.SpinRot_axes,'X axis');
ylabel(handles.SpinRot_axes,'Y axis');
zlabel(handles.SpinRot_axes,'Z axis');
set(handles.SpinRot_axes,'view',[az,el]);

set(handles.Mxy_axes,'YGrid','on','XGrid','off','XTick',[],'XLim',[handles.Muts(1) handles.Muts(min(WindowSize,handles.MutsStep))],'YLim', [handles.MinMxySum handles.MaxMxySum]);
set(handles.Mz_axes,'YGrid','on','XGrid','off','XLim',[handles.Muts(1) handles.Muts(min(WindowSize,handles.MutsStep))],'YLim', [handles.MinMzSum handles.MaxMzSum]);



% --- Executes on button press in Rightend_pushbutton.
function Rightend_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rightend_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el] = view(handles.SpinRot_axes);
set(handles.Watcher_slider,'Value',handles.MutsStep);
WatcherStep=round(get(handles.Watcher_slider,'Value'));
WindowSize=str2double(get(handles.Attrh1.WindowSize,'String'));

Mx=handles.Mx(:,:,:,:,:,WatcherStep);
My=handles.My(:,:,:,:,:,WatcherStep);
Mz=handles.Mz(:,:,:,:,:,WatcherStep);
colorpick = linspace(0,1,str2double(get(handles.Attrh1.TypeNum,'String')));
for j=1:str2double(get(handles.Attrh1.TypeNum,'String'))
    spinver=quiver3(handles.SpinRot_axes,squeeze(handles.Gxgrid),squeeze(handles.Gygrid),squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),squeeze(My(:,:,:,:,j)),squeeze(Mz(:,:,:,:,j)));
    set(spinver,'AutoScale','off');
    hold(handles.SpinRot_axes,'on');
    if WatcherStep > WindowSize
        plot(handles.Mxy_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MxySum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 colorpick(j) 0]);
        hold(handles.Mxy_axes,'on');
        plot(handles.Mz_axes,handles.Muts(WatcherStep-WindowSize+1:WatcherStep),handles.MzSum(WatcherStep-WindowSize+1:WatcherStep,j),'Color',[0 0 colorpick(j)]);
        hold(handles.Mz_axes,'on');
    end
end
hold(handles.SpinRot_axes,'off');
set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[-1 1]);
xlabel(handles.SpinRot_axes,'X axis');
ylabel(handles.SpinRot_axes,'Y axis');
zlabel(handles.SpinRot_axes,'Z axis');
set(handles.SpinRot_axes,'view',[az,el]);
if WatcherStep > WindowSize
    set(handles.Mxy_axes,'YGrid','on','XGrid','off','XTick',[],'XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMxySum handles.MaxMxySum]);
    set(handles.Mz_axes,'YGrid','on','XGrid','off','XLim',[handles.Muts(WatcherStep-WindowSize+1) handles.Muts(WatcherStep)],'YLim', [handles.MinMzSum handles.MaxMzSum]);
end

% --- Executes on slider movement.
function Axial_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Axial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.AV.Slice=round(get(hObject,'Value') );
Grid=get(handles.Attrh1.Grid,'String');
Axes=get(handles.Attrh1.Axes,'String');
handles.AV.Grid=Grid{get(handles.Attrh1.Grid,'Value')};
handles.AV.Axes=Grid{get(handles.Attrh1.Axes,'Value')};
DoUpdateImage(handles.Axial_axes,handles.AMatrix,handles.AV);
ISOHighlight=get(handles.Attrh1.ISOHighlight,'String');
if handles.AV.Slice==handles.Simuh.ISO(3) & strcmp(ISOHighlight{get(handles.Attrh1.ISOHighlight,'Value')},'on')
    hold on;
    scatter(handles.Simuh.ISO(1),handles.Simuh.ISO(2),'ro','filled');
    hold off;
end
set(handles.Attrh1.LocZ,'String',num2str(handles.AV.Slice))
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Axial_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --------------------------------------------------------------------
function Cursor_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Cursor_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'dcm')
    handles.dcm=datacursormode(handles.SpinWatcherPanel_figure);
    datacursormode on
    set(handles.dcm,'updatefcn',{@Cursor_update,handles});
else
    if strcmp(get(handles.dcm,'Enable'),'on')
        set(handles.dcm,'Enable','off');
    else
        set(handles.dcm,'Enable','on');
    end
end
guidata(hObject, handles);


function output_txt = Cursor_update(obj,event_obj,handles)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

global VObj

pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

ISO=[pos(1) pos(2) str2double(get(handles.Attrh1.LocZ,'String'))];
set(handles.Attrh1.LocX,'String',num2str(ISO(1)));
set(handles.Attrh1.LocY,'String',num2str(ISO(2)));
set(handles.Attrh1.LocZ,'String',num2str(ISO(3)));
set(handles.Attrh1.SpinPerVoxel,'String',num2str(VObj.SpinNum));
set(handles.Attrh1.TypeNum,'String',num2str(VObj.TypeNum));
set(handles.Attrh1.Gyro,'String',num2str(VObj.Gyro));
set(handles.Attrh1.ChemShift,'String',num2str(VObj.ChemShift));
set(handles.Attrh1.Rho,'String',num2str(VObj.Rho(ISO(2),ISO(1),ISO(3),:)));
set(handles.Attrh1.T1,'String',num2str(VObj.T1(ISO(2),ISO(1),ISO(3),:)));
set(handles.Attrh1.T2,'String',num2str(VObj.T2(ISO(2),ISO(1),ISO(3),:)));
set(handles.Attrh1.T2Star,'String',num2str(VObj.T2Star(ISO(2),ISO(1),ISO(3),:)));


% --- Executes on button press in Export_pushbutton.
function Export_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Export_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assignin('base','Mx',handles.Mx);
assignin('base','My',handles.My);
assignin('base','Mz',handles.Mz);
assignin('base','MxySum',handles.MxySum);
assignin('base','MzSum',handles.MzSum);
assignin('base','Muts',handles.Muts);

warndlg('Spin rotation data was exported to Matlab base workspace!');


% --------------------------------------------------------------------
function SavePanel_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoSaveSnapshot(handles.SpinWatcherPanel_figure);


% --- Executes on button press in Pause_pushbutton.
function Pause_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Pause_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.PauseFlag==1
    handles.PauseFlag=0;
    set(hObject,'String','X');
else
    handles.PauseFlag=1;
    set(hObject,'String','O');
end

guidata(hObject, handles);


% --- Executes on button press in Undock_pushbutton.
function Undock_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Undock_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure; plot(repmat(handles.Muts,[1 max(size(handles.MzSum(1,:)))]),handles.MzSum);
legend(gca,'show');
xlabel('Time');
ylabel('Mz')
grid on;
figure; plot(repmat(handles.Muts,[1 max(size(handles.MxySum(1,:)))]),handles.MxySum);
legend(gca,'show');
xlabel('Time');
ylabel('|Mxy|')
grid on;


% --- Executes when user attempts to close SpinWatcherPanel_figure.
function SpinWatcherPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SpinWatcherPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isfield(handles,'PauseFlag')
    if handles.PauseFlag==1
        delete(hObject);
    else
        warndlg('Please pause spin animation before closing the window (i.e. press X).');
    end
else
    delete(hObject);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function SpinWatcherPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SpinWatcherPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tempaxes = gca;
try
    if strcmp(get(gcf,'Selectiontype'),'alt')
        figure 			% Create a new figure
        ax_new = axes; 
        copyaxes(tempaxes, ax_new);
    end
catch me
end
