

function varargout = MagList(varargin)
% MAGNETLIST MATLAB code for MagList.fig
%      MAGNETLIST, by itself, creates a new MAGNETLIST or raises the existing
%      singleton*.
%
%      H = MAGNETLIST returns the handle to a new MAGNETLIST or the handle to
%      the existing singleton*.
%
%      MAGNETLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAGNETLIST.M with the given input arguments.
%
%      MAGNETLIST('Property','Value',...) creates a new MAGNETLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MagList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MagList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MagList

% Last Modified by GUIDE v2.5 01-May-2013 21:32:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MagList_OpeningFcn, ...
                   'gui_OutputFcn',  @MagList_OutputFcn, ...
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


% --- Executes just before MagList_figure is made visible.
function MagList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MagList_figure (see VARARGIN)

handles.Simuh=varargin{1};
Category=dir([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Mag']);
ind=1;
for i=1:length(Category)
    if ~strcmp(Category(i).name,'.') & ~strcmp(Category(i).name,'..') & Category(i).isdir
        handles.CategoryDir{ind,1}=Category(i).name;
        ind=ind+1;
    end
end
set(handles.Category_listbox,'String',handles.CategoryDir);

handles.accept = 0;
% Choose default command line output for MagList_figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MagList_figure wait for user response (see UIRESUME)
% uiwait(handles.MagList_figure);


% --- Outputs from this function are returned to the command line.
function varargout = MagList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in Mag_listbox.
function Mag_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Mag_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Mag_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Mag_listbox

global VMag;
global VMmg;
global VObj;

if ~isempty(get(handles.MagPath_text,'String'))
    return;
end

if strcmp(handles.MagList,'Empty')
    return;
end

handles.MagXMLFile=[handles.Simuh.MRiLabPath filesep ...
                    'Config' filesep ...
                    'Mag' filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.MagList{get(handles.Mag_listbox,'Value')} filesep...
                    handles.MagList{get(handles.Mag_listbox,'Value')} '.xml'];
                
handles.MagXMLDir=[handles.Simuh.MRiLabPath filesep ...
                    'Config' filesep ...
                    'Mag' filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.MagList{get(handles.Mag_listbox,'Value')}];

% update grid
Mxdims=size(VObj.Rho);
[VMmg.xgrid,VMmg.ygrid,VMmg.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                            (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                            (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);    

[pathstr,name,ext]=fileparts(handles.MagXMLFile);
eval(['dB0=' name ';']);
V=handles.Simuh.AV; % show axial section
V.Color_map='jet';
V.C_upper=max(max(dB0(:,:,V.Slice)));
V.C_lower=min(min(dB0(:,:,V.Slice)));
DoUpdateImage(handles.Preview_axes,dB0,V);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Mag_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mag_listbox (see GCBO)
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

if ~isempty(get(handles.MagPath_text,'String'))
    return;
end

if strcmp(handles.CategoryDir,'Empty')
    return;
end

set(handles.Mag_listbox,'Enable','on');

Mag=dir([handles.Simuh.MRiLabPath filesep ...
          'Config' filesep ...
          'Mag' filesep ...
          handles.CategoryDir{get(handles.Category_listbox,'Value')}]);
ind=1;
handles.MagList=[];
for i=1:length(Mag)
    if ~strcmp(Mag(i).name,'.') & ~strcmp(Mag(i).name,'..')
        handles.MagList{ind,1}=Mag(i).name;
        ind=ind+1;
    end
end
if ind==1
    handles.MagList='Empty';
end
set(handles.Mag_listbox,'String',handles.MagList);
set(handles.Mag_listbox,'Value',1);

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


if isempty(get(handles.MagPath_text,'String'))
    try
        if strcmp(handles.MagList{get(handles.Mag_listbox,'Value')},'Empty')
            DoUpdateInfo(handles.Simuh,'No magnet is selected!');
            return;
        end
    catch me
        DoUpdateInfo(handles.Simuh,'No magnet is selected!');
        return;
    end
end

%----update magnet selection
handles.Simuh.MagXMLFile=handles.MagXMLFile;
handles.Simuh.MagXMLDir=handles.MagXMLDir;
Mag=DoParseXML(handles.MagXMLFile);
handles.Simuh.MagStruct=Mag;
Mag_text=uicontrol(handles.Simuh.MagSel_uipanel,'Style','text');
set(Mag_text,'FontWeight','bold','FontSize',10,'Position',[0,0,140,18],...
    'String', Mag.Attributes(1).Value,'TooltipString',handles.MagXMLFile);
%----end
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
DoUpdateInfo(handles.Simuh,'Mag file was successfully loaded!');
handles.accept = 1;
guidata(hObject, handles);
close(handles.MagList_figure);



% --- Executes on button press in Cancel_pushbutton.
function Cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MagList_figure_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close MagList_figure.
function MagList_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MagList_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoDisableButton([],[],handles.Simuh);
if handles.accept == 0
    DoUpdateInfo(handles.Simuh,'Mag file loading was cancelled!');
end
% Hint: delete(hObject) closes the figure
delete(handles.MagList_figure);


% --- Executes on button press in MagPath_pushbutton.
function MagPath_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MagPath_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VMag;
global VMmg;

[filename,pathname,filterindex]=uigetfile({'Mag*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    handles.MagXMLFile=[pathname filename];
    handles.MagXMLDir=pathname(1:end-1);
    set(handles.MagPath_text,'String',[pathname filename]);
    % Add searchig path
    path(path,handles.MagXMLDir);
    
    % update grid
    VMmg.xgrid=VMag.Gxgrid;
    VMmg.ygrid=VMag.Gygrid;
    VMmg.zgrid=VMag.Gzgrid;
    
    [pathstr,name,ext]=fileparts(handles.MagXMLFile);
    eval(['dB0=' name ';']);
    V=handles.Simuh.AV;
    V.Color_map='jet';
    V.C_upper=max(max(dB0(:,:,V.Slice)));
    V.C_lower=min(min(dB0(:,:,V.Slice)));
    DoUpdateImage(handles.Preview_axes,dB0,V);
    
else
    errordlg('No Mag was loaded!');
    return;
end
guidata(hObject, handles);


% --- Executes on button press in Default_pushbutton.
function Default_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Default_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles.Simuh,'MagXMLFile')
    handles.Simuh=rmfield(handles.Simuh,'MagXMLFile');
    delete(get(handles.Simuh.MagSel_uipanel,'Children'));
    guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
end
DoUpdateInfo(handles.Simuh,'Use default Magnet!');
handles.accept = 1;
guidata(hObject, handles);
close(handles.MagList_figure);
