

function varargout = GradList(varargin)
% GRADLIST MATLAB code for GradList.fig
%      GRADLIST, by itself, creates a new GRADLIST or raises the existing
%      singleton*.
%
%      H = GRADLIST returns the handle to a new GRADLIST or the handle to
%      the existing singleton*.
%
%      GRADLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRADLIST.M with the given input arguments.
%
%      GRADLIST('Property','Value',...) creates a new GRADLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GradList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GradList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GradList

% Last Modified by GUIDE v2.5 24-May-2013 14:12:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GradList_OpeningFcn, ...
                   'gui_OutputFcn',  @GradList_OutputFcn, ...
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


% --- Executes just before GradList_figure is made visible.
function GradList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GradList_figure (see VARARGIN)

handles.Simuh=varargin{1};
Category=dir([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Grad']);
ind=1;
for i=1:length(Category)
    if ~strcmp(Category(i).name,'.') & ~strcmp(Category(i).name,'..') & Category(i).isdir
        handles.CategoryDir{ind,1}=Category(i).name;
        ind=ind+1;
    end
end
set(handles.Category_listbox,'String',handles.CategoryDir);

handles.accept = 0;
% Choose default command line output for GradList_figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GradList_figure wait for user response (see UIRESUME)
% uiwait(handles.GradList_figure);


% --- Outputs from this function are returned to the command line.
function varargout = GradList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in Grad_listbox.
function Grad_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Grad_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Grad_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Grad_listbox

if ~isempty(get(handles.GradPath_text,'String'))
    return;
end

if strcmp(handles.GradList,'Empty')
    return;
end

handles.GradXMLFile=[handles.Simuh.MRiLabPath filesep ...
                    'Config' filesep ...
                    'Grad' filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.GradList{get(handles.Grad_listbox,'Value')} filesep...
                    handles.GradList{get(handles.Grad_listbox,'Value')} '.xml'];
                
handles.GradXMLDir=[handles.Simuh.MRiLabPath filesep ...
                    'Config' filesep ...
                    'Grad' filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.GradList{get(handles.Grad_listbox,'Value')}];

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Grad_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Grad_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Category_listbox.
function Category_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Category_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Category_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Category_listbox

if ~isempty(get(handles.GradPath_text,'String'))
    return;
end

if strcmp(handles.CategoryDir,'Empty')
    return;
end

set(handles.Grad_listbox,'Enable','on');

Grad=dir([handles.Simuh.MRiLabPath filesep ...
          'Config' filesep ...
          'Grad' filesep ...
          handles.CategoryDir{get(handles.Category_listbox,'Value')}]);
ind=1;
handles.GradList=[];
for i=1:length(Grad)
    if ~strcmp(Grad(i).name,'.') & ~strcmp(Grad(i).name,'..')
        handles.GradList{ind,1}=Grad(i).name;
        ind=ind+1;
    end
end
if ind==1
    handles.GradList='Empty';
end
set(handles.Grad_listbox,'String',handles.GradList);
set(handles.Grad_listbox,'Value',1);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Category_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Category_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Accept_pushbutton.
function Accept_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Accept_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(get(handles.GradPath_text,'String'))
    try
        if strcmp(handles.GradList{get(handles.Grad_listbox,'Value')},'Empty')
            DoUpdateInfo(handles.Simuh,'No gradient is selected!');
            return;
        end
    catch me
        DoUpdateInfo(handles.Simuh,'No gradient is selected!');
        return;
    end
end

%----update gradient selection
handles.Simuh.GradXMLFile=handles.GradXMLFile;
handles.Simuh.GradXMLDir=handles.GradXMLDir;
Grad=DoParseXML(handles.GradXMLFile);
handles.Simuh.GradStruct=Grad;
Grad_text=uicontrol(handles.Simuh.GradSel_uipanel,'Style','text');
set(Grad_text,'FontWeight','bold','FontSize',10,'Position',[0,0,140,18],...
    'String', Grad.Attributes(1).Value,'TooltipString',handles.GradXMLFile);
%----end
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
DoUpdateInfo(handles.Simuh,'Grad file was successfully loaded!');
handles.accept = 1;
guidata(hObject, handles);
close(handles.GradList_figure);



% --- Executes on button press in Cancel_pushbutton.
function Cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GradList_figure_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close GradList_figure.
function GradList_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to GradList_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoDisableButton([],[],handles.Simuh);
if handles.accept == 0
    DoUpdateInfo(handles.Simuh,'Grad file loading was cancelled!');
end
% Hint: delete(hObject) closes the figure
delete(handles.GradList_figure);


% --- Executes on button press in GradPath_pushbutton.
function GradPath_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GradPath_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filterindex]=uigetfile({'Grad*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    handles.GradXMLFile=[pathname filename];
    handles.GradXMLDir=pathname(1:end-1);
    set(handles.GradPath_text,'String',[pathname filename]);
    % Add searchig path
    path(path,handles.GradXMLDir);
    
else
    errordlg('No Grad was loaded!');
    return;
end
guidata(hObject, handles);


% --- Executes on button press in Default_pushbutton.
function Default_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Default_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles.Simuh,'GradXMLFile')
    handles.Simuh=rmfield(handles.Simuh,'GradXMLFile');
    delete(get(handles.Simuh.GradSel_uipanel,'Children'));
    guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
end
DoUpdateInfo(handles.Simuh,'Use default Gradient!');
handles.accept = 1;
guidata(hObject, handles);
close(handles.GradList_figure);
