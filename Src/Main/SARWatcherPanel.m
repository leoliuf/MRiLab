function varargout = SARWatcherPanel(varargin)
% SARWATCHERPANEL MATLAB code for SARWatcherPanel.fig
%      SARWATCHERPANEL, by itself, creates a new SARWATCHERPANEL or raises the existing
%      singleton*.
%
%      H = SARWATCHERPANEL returns the handle to a new SARWATCHERPANEL or the handle to
%      the existing singleton*.
%
%      SARWATCHERPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SARWATCHERPANEL.M with the given input arguments.
%
%      SARWATCHERPANEL('Property','Value',...) creates a new SARWATCHERPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SARWatcherPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SARWatcherPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SARWatcherPanel

% Last Modified by GUIDE v2.5 21-Apr-2014 17:55:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SARWatcherPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @SARWatcherPanel_OutputFcn, ...
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


% --- Executes just before SARWatcherPanel is made visible.
function SARWatcherPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SARWatcherPanel (see VARARGIN)

global VObj
handles.Simuh=varargin{1};

%Load tabs for Local SAR Settings
try
    handles.SARWatchAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SARWatchAttr.xml']);
catch ME
    errordlg('SARWatchAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.SARWatcherPanel_figure,handles);
for i=1:length(handles.SARWatchAttrStruct.Children)
    eval(['handles.' handles.SARWatchAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.SARWatchAttrStruct.Children(i).Name ''',''Units'',''points'');']);
    eval(['DoEditValue(handles,handles.' handles.SARWatchAttrStruct.Children(i).Name '_tab,handles.SARWatchAttrStruct.Children(' num2str(i) ').Attributes,1,[0.25,0.2,0.0,0.2,0.2,0.05]);']);
    handles=guidata(handles.SARWatcherPanel_figure);
end

%Create tabs for SAR/Power maps
handles.Map_tabgroup=uitabgroup(handles.Map_uipanel);
handles.SAR_tab=uitab(handles.Map_tabgroup,'title','SAR','Units','normalized');
handles.Power_tab=uitab(handles.Map_tabgroup,'title','Power','Units','normalized');
handles.SAR_axes=axes('parent', handles.SAR_tab,'Position', [0.05 0.05 0.85 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
handles.Power_axes=axes('parent', handles.Power_tab,'Position', [0.05 0.05 0.85 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);

% Choose default command line output for SARWatcherPanel
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SARWatcherPanel wait for user response (see UIRESUME)
% uiwait(handles.SARWatcherPanel_figure);


% --- Outputs from this function are returned to the command line.
function varargout = SARWatcherPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function Time_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.SARDisp=handles.aveSAR(:,:,:,round(get(hObject,'Value')));
DoUpdateImage(handles.SAR_axes,handles.SARDisp,handles.SAR_IV);
text(0,-1.5,['Slice # : ' num2str(handles.SAR_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(round(get(handles.Time_slider,'Value')))) 's'],'Color','k');

handles.PowerDisp=handles.avePower(:,:,:,round(get(hObject,'Value')));
DoUpdateImage(handles.Power_axes,handles.PowerDisp,handles.Power_IV);
text(0,-1.5,['Slice # : ' num2str(handles.Power_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(round(get(handles.Time_slider,'Value')))) 's'],'Color','k');

SARStats(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Slice_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.SAR_IV.Slice=round(get(hObject,'Value') );
DoUpdateImage(handles.SAR_axes,handles.SARDisp,handles.SAR_IV);
text(0,-1.5,['Slice # : ' num2str(handles.SAR_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(round(get(handles.Time_slider,'Value')))) 's'],'Color','k');

handles.Power_IV.Slice=round(get(hObject,'Value') );
DoUpdateImage(handles.Power_axes,handles.PowerDisp,handles.Power_IV);
text(0,-1.5,['Slice # : ' num2str(handles.Power_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(round(get(handles.Time_slider,'Value')))) 's'],'Color','k');

SARStats(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Slice_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in SARExecute_pushbutton.
function SARExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SARExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.TimeBar_axes);
set(handles.TimeBar_axes,'Visible','off');
set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
ExecFlag=DoSARWatchExec(handles);
handles=guidata(handles.SARWatcherPanel_figure);
if ExecFlag==0
    cla(handles.TimeBar_axes);
    set(handles.TimeBar_axes,'Visible','off');
    set(hObject,'Enable','on');
    set(hObject,'String','Execute');
    return;
end
set(handles.Slice_slider,'Enable','on');
set(handles.Time_slider,'Enable','on');
set(handles.Export_pushbutton,'Enable','on');
set(handles.Time_uitable,'Enable','on');

%Display
% slider bar
layer=size(handles.aveSAR,3);
time=size(handles.aveSAR,4);
if layer==1
    set(handles.Slice_slider,'Value',1,'Enable','off');
else
    set(handles.Slice_slider,'Enable','on');
    set(handles.Slice_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer],'Value',ceil(layer/2));
end
if time==1
    set(handles.Time_slider,'Value',1,'Enable','off');
else
    set(handles.Time_slider,'Enable','on');
    set(handles.Time_slider,'Min',1,'Max',time,'SliderStep',[1/time, 4/time],'Value',ceil(time/2));
end

%Show sample table
handles.Sample=num2cell([1:length(handles.tSARSample); handles.tSARSample; handles.tSARSecond]');
set(handles.Time_uitable,'Data',handles.Sample);

%Display SAR/Power map
handles.SAR_IV=struct(...
    'Slice',ceil(layer/2),...
    'C_lower',min(handles.aveSAR(:)),...
    'C_upper',max(handles.aveSAR(:)),...
    'Axes','off',...
    'Grid','off',...
    'Color_map','Hot'...
    );
handles.SARDisp=handles.aveSAR(:,:,:,ceil(time/2));
DoUpdateImage(handles.SAR_axes,handles.SARDisp,handles.SAR_IV);
text(0,-1.5,['Slice # : ' num2str(handles.SAR_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(ceil(time/2))) 's'],'Color','k');
colorbar;

handles.Power_IV=struct(...
    'Slice',ceil(layer/2),...
    'C_lower',min(handles.avePower(:)),...
    'C_upper',max(handles.avePower(:)),...
    'Axes','off',...
    'Grid','off',...
    'Color_map','Hot'...
    );
handles.PowerDisp=handles.avePower(:,:,:,ceil(time/2));
DoUpdateImage(handles.Power_axes,handles.PowerDisp,handles.Power_IV);
text(0,-1.5,['Slice # : ' num2str(handles.Power_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(ceil(time/2))) 's'],'Color','k');
colorbar;

SARStats(handles);

set(hObject,'Enable','on');
set(hObject,'String','Execute');
guidata(handles.SARWatcherPanel_figure, handles);

% --- Executes on button press in Update_pushbutton.
function Update_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Update_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update SARWatchAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.SARWatchAttrStruct.Children)
    Attrh1=get(tabs(j),'Children');
    for i=1:2:length(Attrh1)
        if ~iscell(get(Attrh1(end-i),'String'))
            handles.SARWatchAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh1(end-i),'String');
        else
            handles.SARWatchAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh1(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.SARWatchAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SARWatchAttr.xml']);


% --- Executes on button press in Export_pushbutton.
function Export_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Export_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if verLessThan('matlab','8.5')
    % Code to run in MATLAB R2015a and earlier here
    if strcmp(get(handles.SAR_tab,'Visible'),'on')
        Map = 'SAR';
        map = handles.aveSAR;
    else
        Map = 'Power';
        map = handles.avePower;
    end
else
    % Code to run in MATLAB R2015a and later here
    tabtitle=get(get(handles.Map_tabgroup,'SelectedTab'),'Title');
    if strcmp(tabtitle,'SAR')
        Map = 'SAR';
        map = handles.aveSAR;
    elseif strcmp(tabtitle,'Power')
        Map = 'Power';
        map = handles.avePower;
    end
end

GText=handles.SW.N_Gram;
SText=handles.SW.N_Second;
if GText==0
    GText='unaveraged';
else
    GText=[num2str(GText) 'g'];
    GText=strrep(GText, '.', '_');
end
if isinf(SText)
    SText='alltime';
else
    SText=[num2str(SText) 's'];
    SText=strrep(SText, '.', '_');
end

assignin('base', [Map '_' GText '_' SText], map);
MU_Matrix_Display([Map '_' GText '_' SText],'Magnitude');

function MaxSAR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MaxSAR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxSAR_edit as text
%        str2double(get(hObject,'String')) returns contents of MaxSAR_edit as a double


% --- Executes during object creation, after setting all properties.
function MaxSAR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxSAR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AveSAR_edit_Callback(hObject, eventdata, handles)
% hObject    handle to AveSAR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AveSAR_edit as text
%        str2double(get(hObject,'String')) returns contents of AveSAR_edit as a double


% --- Executes during object creation, after setting all properties.
function AveSAR_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AveSAR_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TotalPower_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TotalPower_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalPower_edit as text
%        str2double(get(hObject,'String')) returns contents of TotalPower_edit as a double


% --- Executes during object creation, after setting all properties.
function TotalPower_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalPower_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function SARWatcherPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SARWatcherPanel_figure (see GCBO)
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


% --- Executes when selected cell(s) is changed in Time_uitable.
function Time_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Time_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if numel(eventdata.Indices)==0
    return;
end

handles.SARDisp=handles.aveSAR(:,:,:,eventdata.Indices(1));
set(handles.Time_slider,'Value',eventdata.Indices(1));
DoUpdateImage(handles.SAR_axes,handles.SARDisp,handles.SAR_IV);
text(0,-1.5,['Slice # : ' num2str(handles.SAR_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(round(get(handles.Time_slider,'Value')))) 's'],'Color','k');

handles.PowerDisp=handles.avePower(:,:,:,eventdata.Indices(1));
DoUpdateImage(handles.Power_axes,handles.PowerDisp,handles.Power_IV);
text(0,-1.5,['Slice # : ' num2str(handles.Power_IV.Slice) ' / Time Point : ' num2str(handles.tSARSample(round(get(handles.Time_slider,'Value')))) 's'],'Color','k');

SARStats(handles);
guidata(hObject, handles);

function SARStats(handles)

maxSAR = max(handles.SARDisp(:));
aveSAR = mean(handles.SARDisp(handles.SARDisp~=0));
totPower = sum(handles.PowerDisp(handles.PowerDisp~=0));
set(handles.MaxSAR_edit,'String',num2str(maxSAR));
set(handles.AveSAR_edit,'String',num2str(aveSAR));
set(handles.TotalPower_edit,'String',num2str(totPower));
