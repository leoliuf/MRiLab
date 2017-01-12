

function varargout = CoilList(varargin)
% SEQLIST_FIGURE M-file for CoilList_figure.fig
%      SEQLIST_FIGURE, by itself, creates a new SEQLIST_FIGURE or raises the existing
%      singleton*.
%
%      H = SEQLIST_FIGURE returns the handle to a new SEQLIST_FIGURE or the handle to
%      the existing singleton*.
%
%      SEQLIST_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEQLIST_FIGURE.M with the given input arguments.
%
%      SEQLIST_FIGURE('Property','Value',...) creates a new SEQLIST_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CoilList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CoilList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above CoilPath_text to modify the response to help CoilList_figure

% Last Modified by GUIDE v2.5 10-Sep-2012 22:20:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CoilList_OpeningFcn, ...
                   'gui_OutputFcn',  @CoilList_OutputFcn, ...
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


% --- Executes just before CoilList_figure is made visible.
function CoilList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CoilList_figure (see VARARGIN)

handles.Simuh=varargin{1};
Category=dir([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Coil']);
ind=1;
for i=1:length(Category)
    if ~strcmp(Category(i).name,'.') & ~strcmp(Category(i).name,'..') & Category(i).isdir
        handles.CategoryDir{ind,1}=Category(i).name;
        ind=ind+1;
    end
end
set(handles.Category_listbox,'String',handles.CategoryDir);

handles.accept = 0;
% Choose default command line output for CoilList_figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CoilList_figure wait for user response (see UIRESUME)
% uiwait(handles.CoilList_figure);


% --- Outputs from this function are returned to the command line.
function varargout = CoilList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in Coil_listbox.
function Coil_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Coil_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Coil_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Coil_listbox

global VMco;
global VCco;
global VCtl;
global VObj;

if ~isempty(get(handles.CoilPath_text,'String'))
    return;
end

if strcmp(handles.CoilList,'Empty')
    return;
end

handles.CoilXMLFile=[handles.Simuh.MRiLabPath filesep ...
                    'Config' filesep ...
                    'Coil' filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.CoilList{get(handles.Coil_listbox,'Value')} filesep...
                    handles.CoilList{get(handles.Coil_listbox,'Value')} '.xml'];
                
handles.CoilXMLDir=[handles.Simuh.MRiLabPath filesep ...
                    'Config' filesep ...
                    'Coil' filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.CoilList{get(handles.Coil_listbox,'Value')}];
                
% update grid
Precisions=get(handles.Precision_popupmenu,'String');
Precision=str2num(Precisions{get(handles.Precision_popupmenu,'Value')});

Mxdims=size(VObj.Rho);
[VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes*(1/Precision):((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                            (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes*(1/Precision):((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                            (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);                            

[pathstr,name,ext]=fileparts(handles.CoilXMLFile);
eval(['[B1x, B1y, B1z, E1x, E1y, E1z, Pos]=' name ';']);
VCco=[];
VMco=[];
handles.B1x=sum(B1x,4);
handles.B1y=sum(B1y,4);
handles.B1=sqrt(handles.B1x.^2+handles.B1y.^2);
Colormaps=get(handles.Colormap_popupmenu,'String');
V=handles.Simuh.AV; % show axial section
V.Color_map=Colormaps{get(handles.Colormap_popupmenu,'Value')};
V.C_upper=max(max(handles.B1(:,:,V.Slice)));
V.C_lower=min(min(handles.B1(:,:,V.Slice)));
DoUpdateImage(handles.Preview_axes,handles.B1,V);
                
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Coil_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Coil_listbox (see GCBO)
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

if ~isempty(get(handles.CoilPath_text,'String'))
    return;
end

if strcmp(handles.CategoryDir,'Empty')
    return;
end

set(handles.Coil_listbox,'Enable','on');

Coil=dir([handles.Simuh.MRiLabPath filesep ...
          'Config' filesep ...
          'Coil' filesep ...
          handles.CategoryDir{get(handles.Category_listbox,'Value')}]);
ind=1;
handles.CoilList=[];
for i=1:length(Coil)
    if ~strcmp(Coil(i).name,'.') & ~strcmp(Coil(i).name,'..')
        handles.CoilList{ind,1}=Coil(i).name;
        ind=ind+1;
    end
end
if ind==1
    handles.CoilList='Empty';
end
set(handles.Coil_listbox,'String',handles.CoilList);
set(handles.Coil_listbox,'Value',1);

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


if isempty(get(handles.CoilPath_text,'String'))
    try
        if strcmp(handles.CoilList{get(handles.Coil_listbox,'Value')},'Empty')
            DoUpdateInfo(handles.Simuh,'No coil is selected!');
            return;
        end
    catch me
        DoUpdateInfo(handles.Simuh,'No coil is selected!');
        return;
    end
end

%----update tabs
CoilType=get(handles.CoilType_popupmenu,'String');
tabs=get(handles.Simuh.CoilSel_tabgroup,'Children');
for i=1:length(tabs)
    if strcmp(get(tabs(i),'Title'),CoilType{get(handles.CoilType_popupmenu,'Value')})
        delete(get(tabs(i),'Children'));
        eval(['handles.Simuh.Coil' get(tabs(i),'Title') 'XMLFile=handles.CoilXMLFile;']);
        eval(['handles.Simuh.Coil' get(tabs(i),'Title') 'XMLDir=handles.CoilXMLDir;']);
        Coil=DoParseXML(handles.CoilXMLFile);
        eval(['handles.Simuh.Coil' get(tabs(i),'Title') 'Struct=Coil;']);
        eval(['Coil_text=uicontrol(handles.Simuh.Coil' get(tabs(i),'Title') '_tab,' '''Style'', ''text'');']);
        set(Coil_text,'FontWeight','bold','FontSize',10,'Position',[0,0,140,20],...
                      'String', Coil.Attributes(1).Value,'TooltipString',handles.CoilXMLFile);
    end
end
%----end
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
DoUpdateInfo(handles.Simuh,'Coil file was successfully loaded!');
handles.accept = 1;
guidata(hObject, handles);
close(handles.CoilList_figure);



% --- Executes on button press in Cancel_pushbutton.
function Cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CoilList_figure_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close CoilList_figure.
function CoilList_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to CoilList_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoDisableButton([],[],handles.Simuh);
if handles.accept == 0
    DoUpdateInfo(handles.Simuh,'Coil file loading was cancelled!');
end
% Hint: delete(hObject) closes the figure
delete(handles.CoilList_figure);


% --- Executes on selection change in CoilType_popupmenu.
function CoilType_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to CoilType_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns CoilType_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CoilType_popupmenu


% --- Executes during object creation, after setting all properties.
function CoilType_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CoilType_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CoilPath_pushbutton.
function CoilPath_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CoilPath_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VCtl;
global VObj;
global VMco;

[filename,pathname,filterindex]=uigetfile({'Coil*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    handles.CoilXMLFile=[pathname filename];
    handles.CoilXMLDir=pathname(1:end-1);
    set(handles.CoilPath_text,'String',[pathname filename]);
    % Add searchig path
    path(path,handles.CoilXMLDir);
    
    % update grid
    Precisions=get(handles.Precision_popupmenu,'String');
    Precision=str2num(Precisions{get(handles.Precision_popupmenu,'Value')});
    [Gxgrid,Gygrid,Gzgrid]=meshgrid((-VCtl.ISO(1)+1)*VObj.XDimRes:VObj.XDimRes*(1/Precision):(VObj.XDim-VCtl.ISO(1))*VObj.XDimRes,...
                                    (-VCtl.ISO(2)+1)*VObj.YDimRes:VObj.YDimRes*(1/Precision):(VObj.YDim-VCtl.ISO(2))*VObj.YDimRes,...
                                    (-VCtl.ISO(3)+1)*VObj.ZDimRes:VObj.ZDimRes:(VObj.ZDim-VCtl.ISO(3))*VObj.ZDimRes);
    VMco.xgrid=Gxgrid;
    VMco.ygrid=Gygrid;
    VMco.zgrid=Gzgrid;
    
    [pathstr,name,ext]=fileparts(handles.CoilXMLFile);
    eval(['[B1x, B1y, B1z, Pos]=' name ';']);
    handles.B1x=sum(B1x,4);
    handles.B1y=sum(B1y,4);
    handles.B1=sqrt(handles.B1x.^2+handles.B1y.^2);
    Colormaps=get(handles.Colormap_popupmenu,'String');
    V=handles.Simuh.AV;
    V.Color_map=Colormaps{get(handles.Colormap_popupmenu,'Value')};
    V.C_upper=max(max(handles.B1(:,:,V.Slice)));
    V.C_lower=min(min(handles.B1(:,:,V.Slice)));
    DoUpdateImage(handles.Preview_axes,handles.B1,V);
else
    errordlg('No Coil was loaded!');
    return;
end
guidata(hObject, handles);


% --- Executes on selection change in Precision_popupmenu.
function Precision_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Precision_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Precision_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Precision_popupmenu


% --- Executes during object creation, after setting all properties.
function Precision_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Precision_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Colormap_popupmenu.
function Colormap_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Colormap_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Colormap_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Colormap_popupmenu


% --- Executes during object creation, after setting all properties.
function Colormap_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Colormap_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Default_pushbutton.
function Default_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Default_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CoilType=get(handles.CoilType_popupmenu,'String');
switch CoilType{get(handles.CoilType_popupmenu,'Value')}
    case 'Tx'
        if isfield(handles.Simuh,'CoilTxXMLFile')
            handles.Simuh=rmfield(handles.Simuh,'CoilTxXMLFile');
            delete(get(handles.Simuh.CoilTx_tab,'Children'));
        end
        DoUpdateInfo(handles.Simuh,'Use default TxCoil!');
    case 'Rx'
        if isfield(handles.Simuh,'CoilRxXMLFile')
            handles.Simuh=rmfield(handles.Simuh,'CoilRxXMLFile');
            delete(get(handles.Simuh.CoilRx_tab,'Children'));
        end
        DoUpdateInfo(handles.Simuh,'Use default RxCoil!');
end
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
handles.accept = 1;
guidata(hObject, handles);
close(handles.CoilList_figure);
