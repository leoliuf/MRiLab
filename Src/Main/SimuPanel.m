

function varargout = SimuPanel(varargin)
% SIMUPANEL M-file for SimuPanel.fig
%      SIMUPANEL, by itself, creates a new SIMUPANEL or raises the existing
%      singleton*.
%
%      H = SIMUPANEL returns the handle to a new SIMUPANEL or the handle to
%      the existing singleton*.
%
%      SIMUPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMUPANEL.M with the given input arguments.
%
%      SIMUPANEL('Property','Value',...) creates a new SIMUPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SimuPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SimuPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SimuPanel

% Last Modified by GUIDE v2.5 07-Jan-2017 20:04:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SimuPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @SimuPanel_OutputFcn, ...
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


% --- Executes just before SimuPanel is made visible.
function SimuPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SimuPanel (see VARARGIN)


%MRiLab('Welcome')
% clc;

disp(' __       __  _______   __  __                 __           ');       
disp('|  \     /  \|       \ |  \|  \               |  \          ');      
disp('| $$\   /  $$| $$$$$$$\ \$$| $$       ______  | $$___       ');
disp('| $$$\ /  $$$| $$__| $$|  \| $$      |      \ | $$    \     '); 
disp('| $$$$\  $$$$| $$    $$| $$| $$       \$$$$$$\| $$$$$$$\    ');
disp('| $$\$$ $$ $$| $$$$$$$\| $$| $$      /      $$| $$  | $$    ');
disp('| $$ \$$$| $$| $$  | $$| $$| $$_____|  $$$$$$$| $$__/ $$    ');
disp('| $$  \$ | $$| $$  | $$| $$| $$     \\$$    $$| $$    $$    ');
disp(' \$$      \$$ \$$   \$$ \$$ \$$$$$$$$ \$$$$$$$ \$$$$$$$     ');
disp('________________________________________________________    ');
disp('Numerical MRI Simulation Package                            ');
disp('Version 1.3                                                 ');
disp('Initializing ... ');

%MRiLab path
handles.MRiLabPath=varargin{1};

%Output Dir
time=clock;
OutputDir=[handles.MRiLabPath filesep 'Output' filesep num2str(time(1)) '-' num2str(time(2)) '-' num2str(time(3)) '-' num2str(time(4)) '-' num2str(time(5))];
if ~isdir(OutputDir)
    mkdir(OutputDir);
    handles.OutputDir=OutputDir;
else
    handles.OutputDir=OutputDir;
end

%BatchSim Init
handles.BatchDir=OutputDir;
handles.BatchFlag=0;
handles.BatchListIdx=[];
handles.BatchList=[];

%System Hardware Check
try
    handles.CPUInfo=DoCPUOSChk;
    if ~isempty(handles.CPUInfo)
        handles.CPU_uimenu=uimenu(handles.SelectPU_uimenu,'Label',handles.CPUInfo.Name);
        set(handles.CPU_uimenu,'Callback',{@Uimenu_ChkFunction, handles.CPU_uimenu});
        set(handles.CPU_uimenu,'Checked','on');
    end
catch me
    handles.CPUInfo.NumThreads = 8; % Open up to 8 threads as default if CPU model is unknown
    handles.CPU_uimenu=uimenu(handles.SelectPU_uimenu,'Label','unknown CPU model');
    set(handles.CPU_uimenu,'Callback',{@Uimenu_ChkFunction, handles.CPU_uimenu});
    set(handles.CPU_uimenu,'Checked','on');
    error_msg{1,1}='Detecting local CPU infomation failed!';
    error_msg{2,1}=me.message;
    warndlg(error_msg);
end

try
    handles.GPUCount=gpuDeviceCount;
    if handles.GPUCount~=0
        for i=1:handles.GPUCount
            handles.GPUInfo=gpuDevice(i);
            GPU_flag = ['GPU' num2str(i) '_uimenu'];
            handles.(GPU_flag)=uimenu(handles.SelectPU_uimenu,'Label',['nVIDIA(R) ' handles.GPUInfo.Name]);
            set(handles.(GPU_flag),'Callback',{@Uimenu_ChkFunction, handles.(GPU_flag)});
            set(handles.(GPU_flag),'Checked','on');
        end
        Uimenu_ChkFunction([],[],handles.GPU1_uimenu); % Set first GPU as default processing unit
    else
        handles.GPU1_uimenu=uimenu(handles.SelectPU_uimenu,'Label','No GPU or unknown GPU model');
        set(handles.GPU1_uimenu,'Callback',{@Uimenu_ChkFunction, handles.GPU1_uimenu});
        error_msg{1,1}='Detecting local GPU infomation failed!';
        warndlg(error_msg);
    end
catch me
    handles.GPU1_uimenu=uimenu(handles.SelectPU_uimenu,'Label','No GPU or unknown GPU model');
    set(handles.GPU1_uimenu,'Callback',{@Uimenu_ChkFunction, handles.GPU1_uimenu});
    error_msg{1,1}='Detecting local GPU infomation failed!';
    error_msg{2,1}=me.message;
    warndlg(error_msg);
end

%Global Variables
global VObj; VObj=[];
global VCtl; VCtl=[];
global VMag; VMag=[];
global VCoi; VCoi=[];
global VMot; VMot=[];
global VVar; VVar=[];

try
    handles.SimuAttrStruct=DoParseXML([handles.MRiLabPath filesep 'PSD' filesep '3D' filesep 'SimuAttr.xml']);
catch ME
    DoUpdateInfo(handles,'SimuAttr.xml file is missing or can not be loaded.');
    % Choose default command line output for SimuPanel
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    close(hObject);
    return;
end
handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(hObject, handles);
for i=1:length(handles.SimuAttrStruct.Children)
    eval(['handles.' handles.SimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',''' handles.SimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.SimuAttrStruct.Children(i).Name '_tab,handles.SimuAttrStruct.Children(' num2str(i) ').Attributes,1,[0.2,0.12,0.01,0.1,0.1,0.05]);']);
    handles=guidata(hObject);
end

% Disable scan button when change settings
fieldname=fieldnames(handles.Attrh1);
for i=1:length(fieldname)/2
    set(handles.Attrh1.(fieldname{i*2}),'Callback',{@DoDisableButton,handles});
end

% Turn off uitab warning
% warning('off', 'last');

handles.CoilSel_tabgroup=uitabgroup(handles.CoilSel_uipanel);
handles.CoilTx_tab=uitab( handles.CoilSel_tabgroup, 'title', 'Tx');
handles.CoilRx_tab=uitab( handles.CoilSel_tabgroup, 'title', 'Rx');

disp('Initialization done. ');

% Choose default command line output for SimuPanel
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SimuPanel wait for user response (see UIRESUME)
% uiwait(handles.SimuPanel_figure);


function Uimenu_ChkFunction(Temp,Event,uimenu_handle)

Children=get(get(uimenu_handle,'Parent'),'Children');
for i=1:length(Children)
    set(Children(i),'Checked','off');
end
set(uimenu_handle,'Checked','on');


% --- Outputs from this function are returned to the command line.
function varargout = SimuPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = [];

% --- Executes on selection change in VObj_listbox.
function VObj_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to VObj_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns VObj_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VObj_listbox

global VObj;
Conts=get(handles.VObj_listbox,'String');
SelCont=Conts{get(handles.VObj_listbox,'Value')};
if isnumeric(VObj.(SelCont))
    d=size(VObj.(SelCont));
    if numel(d)==2
        if d(1)==1 & d(2)==1
                set(handles.VObj_text,'String',num2str(VObj.(SelCont)));
        elseif d(1)==1 | d(2)==1
                set(handles.VObj_text,'String',num2str(VObj.(SelCont)));
        elseif d(1)==0 & d(2)==0
                set(handles.VObj_text,'String','Empty');
        else
            set(handles.VObj_text,'String',['Size: ' num2str(d)]);
        end
    elseif numel(d)==3 | numel(d)==4 | numel(d)==5
            set(handles.VObj_text,'String',['Size: ' num2str(d)]);
    end
elseif ischar(VObj.(SelCont))
    set(handles.VObj_text,'String',VObj.(SelCont));
end


% --- Executes during object creation, after setting all properties.
function VObj_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VObj_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function Coronal_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Coronal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.CV.Slice=round(get(hObject,'Value') );
DoUpdateImage(handles.Coronal_axes,handles.CMatrix,handles.CV);

delete(handles.SagittalFOV);
delete(handles.AxialFOV);
guidata(hObject, handles);
DoDispFOV(handles,[]);
handles=guidata(hObject);
addNewPositionCallback(handles.AxialFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.SagittalFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.CoronalFOV,@(p) DoDispFOV(handles));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Coronal_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Coronal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Sagittal_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Sagittal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.SV.Slice=round(get(hObject,'Value') );
DoUpdateImage(handles.Sagittal_axes,handles.SMatrix,handles.SV);

delete(handles.AxialFOV);
delete(handles.CoronalFOV);
guidata(hObject, handles);
DoDispFOV(handles,[]);
handles=guidata(hObject);
addNewPositionCallback(handles.AxialFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.SagittalFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.CoronalFOV,@(p) DoDispFOV(handles));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Sagittal_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sagittal_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Axial_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Axial_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.AV.Slice=round(get(hObject,'Value') );
DoUpdateImage(handles.Axial_axes,handles.AMatrix,handles.AV);

delete(handles.SagittalFOV);
delete(handles.CoronalFOV);
guidata(hObject, handles);
DoDispFOV(handles,[]);
handles=guidata(hObject);
addNewPositionCallback(handles.AxialFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.SagittalFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.CoronalFOV,@(p) DoDispFOV(handles));

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


% --- Executes on selection change in VObjSpinMap_popupmenu.
function VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to VObjSpinMap_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns VObjSpinMap_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VObjSpinMap_popupmenu

global VObj;
Conts=get(handles.VObjSpinMap_popupmenu,'String');
SelCont=Conts{get(handles.VObjSpinMap_popupmenu,'Value')};
SelMx=VObj.(SelCont);
[row,col,layer,type]=size(SelMx);

Conts=get(handles.VObjType_popupmenu,'String');
if type~=length(Conts)
        conts = {};
    for i = 1:type
        conts{i} = i;
    end
    set(handles.VObjType_popupmenu,'String', conts);
    set(handles.VObjType_popupmenu,'Value', 1);
end

Conts=get(handles.VObjType_popupmenu,'String');
if ischar(Conts)
    Conts={Conts};
end
SelCont=Conts{get(handles.VObjType_popupmenu,'Value')};
img=SelMx(:,:,:,str2double(SelCont)); % preview chosen content

% out_m=DoUpDownSample(img(:,:,ceil(end/2)),ceil(col/2),ceil(row/2),0,2); 
out_m=img(:,:,ceil((end+1)/2)); 
axes(handles.VObjSpinMap_axes);
cla(handles.VObjSpinMap_axes);
imagesc(out_m);
colormap('gray');
axis image;
axis off;
set(handles.SpinMax_text,'String',num2str(max(max(max(SelMx))),'%6.2f'));
set(handles.SpinMin_text,'String',num2str(min(min(min(SelMx))),'%6.2f'));
set(handles.SpinSize_text,'String',num2str(size(SelMx)));

% --- Executes during object creation, after setting all properties.
function VObjSpinMap_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VObjSpinMap_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in View_pushbutton.
function View_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to View_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~strcmp(get(handles.Coronal_uipanel,'Title'),'Coronal')
    warndlg('Please update current session before loading new phantom.');
    return;
end

global VObj;
Conts=get(handles.VObjSpinMap_popupmenu,'String');
SelCont=Conts{get(handles.VObjSpinMap_popupmenu,'Value')};
SelMx=VObj.(SelCont);

Conts=get(handles.VObjType_popupmenu,'String');
if ischar(Conts)
    Conts={Conts};
end
SelCont=Conts{get(handles.VObjType_popupmenu,'Value')};
img=SelMx(:,:,:,str2double(SelCont)); % preview chosen content

[row,col,layer]=size(img);
Min_D=min(min(min(img))); 
Max_D=max(max(max(img)));
handles.AMatrix=img;
handles.SMatrix=permute(handles.AMatrix,[3 1 2]); % Sagittal Matrix
handles.CMatrix=permute(handles.AMatrix,[3 2 1]); % Coronal Matrix
% handles.CMatrix=flipdim(handles.CMatrix,3);
handles.AV=struct(...
                'Slice',ceil((layer+1)/2),...
                'C_lower',Min_D,...
                'C_upper',Max_D,...
                'Axes','off',...
                'Grid','off',...
                'Color_map','Gray'...
                );
handles.SV=struct(...
                'Slice',ceil((col+1)/2),...
                'C_lower',Min_D,...
                'C_upper',Max_D,...
                'Axes','off',...
                'Grid','off',...
                'Color_map','Gray'...
                );
handles.CV=struct(...
                'Slice',ceil((row+1)/2),...
                'C_lower',Min_D,...
                'C_upper',Max_D,...
                'Axes','off',...
                'Grid','off',...
                'Color_map','Gray'...
                );
DoUpdateImage(handles.Axial_axes,handles.AMatrix,handles.AV);
DoUpdateImage(handles.Sagittal_axes,handles.SMatrix,handles.SV);
DoUpdateImage(handles.Coronal_axes,handles.CMatrix,handles.CV);
set(handles.Axial_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer],'Value',ceil((layer+1)/2),'Enable','on');
set(handles.Sagittal_slider,'Min',1,'Max',col,'SliderStep',[1/col, 4/col],'Value',ceil((col+1)/2),'Enable','on');
set(handles.Coronal_slider,'Min',1,'Max',row,'SliderStep',[1/row, 4/row],'Value',ceil((row+1)/2),'Enable','on');

set(handles.Update_pushbutton,'Enable','on');

handles.ISO=[ceil((col+1)/2),ceil((row+1)/2),ceil((layer+1)/2)];
guidata(hObject, handles);
DoDispFOV(handles,[]);
handles=guidata(hObject);
addNewPositionCallback(handles.AxialFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.SagittalFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.CoronalFOV,@(p) DoDispFOV(handles));
handles=guidata(hObject);

guidata(hObject, handles);
DoUpdateInfo(handles,'Viewing virtual object spin map details.');

% --------------------------------------------------------------------
function LoadPhantom_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadPhantom_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SeqList_pushbutton.
function SeqList_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SeqList_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoUpdateInfo(handles,'Loading sequence...');
SeqList(handles);

% --- Executes on button press in CoilList_pushbutton.
function CoilList_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CoilList_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoUpdateInfo(handles,'Loading coil...');
CoilList(handles);

% --- Executes on button press in MotList_pushbutton.
function MotList_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MotList_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoUpdateInfo(handles,'Loading motion...');
MotList(handles);

% --- Executes on button press in MagList_pushbutton.
function MagList_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MagList_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoUpdateInfo(handles,'Loading magnet...');
MagList(handles);

% --- Executes on button press in Update_pushbutton.
function Update_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Update_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reset Coronal view in case used for other display purpose
if ~strcmp(get(handles.Coronal_uipanel,'Title'),'Coronal')
    set(handles.CZ_text,'Visible','on');
    set(handles.CX_text,'Visible','on');
    set(handles.Left_text,'Visible','on');
    set(handles.Right_text,'Visible','on');
    set(handles.Axial_slider,'Visible','on');
    set(handles.Sagittal_slider,'Visible','on');
    set(handles.Coronal_slider,'Visible','on');
    set(handles.AxialFOV,'Visible','on');
    set(handles.SagittalFOV,'Visible','on');
    DoUpdateImage(handles.Coronal_axes,handles.CMatrix,handles.CV);
end

delete(handles.SagittalFOV);
delete(handles.AxialFOV);
if strcmp(get(handles.Coronal_uipanel,'Title'),'Coronal')
    delete(handles.CoronalFOV);
end
set(handles.Coronal_uipanel,'Title','Coronal');

DoDispFOV(handles,[]);
handles=guidata(hObject);
addNewPositionCallback(handles.AxialFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.SagittalFOV,@(p) DoDispFOV(handles));
addNewPositionCallback(handles.CoronalFOV,@(p) DoDispFOV(handles));
DoUpdateInfo(handles,'Updating simulation setting parameters.');

% PreScan process
try
    DoPreScan(handles);
    DoScanSeriesUpd(handles,1);
catch me
    error_msg{1,1}='ERROR!!! PreScan process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    DoUpdateInfo(handles,'Updating simulation setting parameters failed!');
    return;
end
DoUpdateInfo(handles,'Updating simulation setting parameters is complete.');

set(handles.Scan_pushbutton,'Enable','on');
set(handles.Batch_pushbutton,'Enable','on');
set(handles.MotList_pushbutton,'Enable','on');
set(handles.MagList_pushbutton,'Enable','on');
set(handles.CoilList_pushbutton,'Enable','on');
set(handles.GradList_pushbutton,'Enable','on');
set(handles.SeqList_pushbutton,'Enable','on');

set(handles.SpinWatcher_uipushtool,'Enable','on');
set(handles.SARWatcher_uipushtool,'Enable','on');
% set(handles.Seq_uipushtool,'Enable','on');
set(handles.rf_uipushtool,'Enable','on');
set(handles.Coil_uipushtool,'Enable','on');
set(handles.Grad_uipushtool,'Enable','on');
set(handles.Mag_uipushtool,'Enable','on');
set(handles.Mot_uipushtool,'Enable','on');

set(handles.SpinWatcher_uimenu,'Enable','on');
set(handles.SARWatcher_uimenu,'Enable','on');
% set(handles.Seq_uimenu,'Enable','on');
set(handles.rf_uimenu,'Enable','on');
set(handles.Coil_uimenu,'Enable','on');
set(handles.Grad_uimenu,'Enable','on');
set(handles.Mag_uimenu,'Enable','on');
set(handles.Mot_uimenu,'Enable','on');


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function SimuPanel_figure_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to SimuPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Save_pushbutton.
function Save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoUpdateInfo(handles,'Saving scanning attributes into files...');
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.SimuAttrStruct.Children)
    Attrh1=get(tabs(j),'Children');
    for i=1:2:length(Attrh1)
        if ~iscell(get(Attrh1(end-i),'String'))
            handles.SimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh1(end-i),'String');
        else
            handles.SimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh1(end-i),'Value'));
        end
    end
end
try
    DoWriteXML(handles.SimuAttrStruct,[handles.SeqXMLDir filesep 'SimuAttr.xml']);
catch me
    DoWriteXML(handles.SimuAttrStruct,[handles.MRiLabPath filesep 'PSD' filesep '3D' filesep 'SimuAttr.xml']);
end

if length(tabs)>4 % CVs section
    handles.SeqStruct=DoParseXML(handles.SeqXMLFile);
    Attrh1=get(tabs(5),'Children');
    if ~isempty(Attrh1)
        for i=1:2:length(Attrh1)
            handles.SeqStruct.Children(1).Attributes((i+1)/2).Value=get(Attrh1(end-i),'String');
        end
        DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
        % update associated m function
        DoWriteXML2m(handles.SeqStruct,[handles.SeqXMLFile(1:end-3) 'm']);
    end
end

if length(tabs)>5 % Special Tech section
    for j=6:length(tabs)
        Attrh1=get(tabs(j),'Children');
        if ~isempty(Attrh1)
            for i=1:2:length(Attrh1)
                if ~iscell(get(Attrh1(end-i),'String'))
                    eval(['handles.' get(tabs(j),'Title') 'Struct.Attributes((i+1)/2).Value=get(Attrh1(end-i),''String'');']);
                else
                    eval(['handles.' get(tabs(j),'Title') 'Struct.Attributes((i+1)/2).Value(2)=num2str(get(Attrh1(end-i),''Value''));']);
                end
            end
            eval(['DoWriteXML(handles.' get(tabs(j),'Title') 'Struct,''' handles.SeqXMLDir filesep get(tabs(j),'Title') '.xml'');']);
        end
    end
end

if isfield(handles,'SeqXMLFile') % PSD Memo
    fid=fopen([handles.SeqXMLFile(1:end-4) '_Memo.txt'],'wt+');
    Memo=get(handles.PSDMemo_edit,'String');
    if ~isempty(Memo)
        if ischar(Memo)
            Memo=cellstr(Memo);
        end
        for i=1:length(Memo)
            fprintf(fid,'%s\n', Memo{i,1});
        end
    end
    fclose(fid);
end
DoUpdateInfo(handles,'Saving attributes is complete.');

guidata(hObject, handles);

% --- Executes on button press in Scan_pushbutton.
function Scan_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Scan_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VObj;
global VCtl;
global VMag;
global VVar;

set(handles.Scan_pushbutton,'Enable','off');
set(handles.Batch_pushbutton,'Enable','off');
set(hObject,'String','Init...');
pause(0.01);
try
    % Preserve VObj VMag
    VTmpObj=VObj;
    VTmpMag=VMag;
    
    % Create Executing Virtual Structure VOex VMex
    VOex=VObj;
    VOex.Rho(repmat(VMag.FRange,[1,1,1,VObj.TypeNum])==0)=[];
    VOex.T1(repmat(VMag.FRange,[1,1,1,VObj.TypeNum])==0)=[];
    VOex.T2(repmat(VMag.FRange,[1,1,1,VObj.TypeNum])==0)=[];
    VOex.Mz(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    VOex.My(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    VOex.Mx(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    
    VMex=VMag;
    VMex.Gzgrid(VMag.FRange==0)=[];
    VMex.Gygrid(VMag.FRange==0)=[];
    VMex.Gxgrid(VMag.FRange==0)=[];
    VMex.dB0(VMag.FRange==0)=[];
    VMex.dWRnd(repmat(VMag.FRange,[1,1,1,VObj.SpinNum,VObj.TypeNum])==0)=[];
    VMex.dWRnd(isnan(VMex.dWRnd))=0; % NaN is not supported in C code
    
    % Kernel uses Mz to determine SpinMx size
    VOex.Rho=reshape(VOex.Rho,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum]);
    VOex.T1=reshape(VOex.T1,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum]);
    VOex.T2=reshape(VOex.T2,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum]);
    VOex.Mz=reshape(VOex.Mz,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    VOex.Mx=reshape(VOex.Mx,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    VOex.My=reshape(VOex.My,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    
    if isfield(VCtl, 'MT_Flag')
        if strcmp(VCtl.MT_Flag, 'on')
            VOex.K(repmat(VMag.FRange,[1,1,1,(VObj.TypeNum)^2])==0)=[];
            VOex.K=reshape(VOex.K,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),(VObj.TypeNum)^2]);
        end
    end
    
    if isfield(VCtl, 'ME_Flag')
        if strcmp(VCtl.ME_Flag, 'on')
            VOex.K(repmat(VMag.FRange,[1,1,1,(VObj.TypeNum)^2])==0)=[];
            VOex.K=reshape(VOex.K,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),(VObj.TypeNum)^2]);
        end
    end
    
    if isfield(VCtl, 'CEST_Flag')
        if strcmp(VCtl.CEST_Flag, 'on')
            VOex.K(repmat(VMag.FRange,[1,1,1,2*(VObj.TypeNum-1)])==0)=[];
            VOex.K=reshape(VOex.K,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),2*(VObj.TypeNum-1)]);
        end
    end
    
    if isfield(VCtl, 'GM_Flag')
        if strcmp(VCtl.GM_Flag, 'on')
            VOex.K(repmat(VMag.FRange,[1,1,1,VObj.TypeNum, VObj.TypeNum])==0)=[];
            VOex.K=reshape(VOex.K,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.TypeNum,VObj.TypeNum]);
        end
    end
    
    VMex.Gzgrid=reshape(VMex.Gzgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.Gxgrid=reshape(VMex.Gxgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.Gygrid=reshape(VMex.Gygrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.dB0=reshape(VMex.dB0,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VMex.dWRnd=reshape(VMex.dWRnd,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VObj.SpinNum,VObj.TypeNum]);
    
    [row,col,layer]=size(VOex.Mz);
    VVar.ObjLoc = [((col+1)/2)*VOex.XDimRes; ((row+1)/2)*VOex.YDimRes ; ((layer+1)/2)*VOex.ZDimRes]; % Set matrix center as Object position for motion simulation
    VVar.ObjTurnLoc = [((col+1)/2)*VOex.XDimRes; ((row+1)/2)*VOex.YDimRes ; ((layer+1)/2)*VOex.ZDimRes]; % Set matrix center as Object origin for motion simulation
    
    VOex.MaxMz = max(VOex.Mz(:));
    VOex.MaxMy = max(VOex.My(:));
    VOex.MaxMx = max(VOex.Mx(:));
    VOex.MaxRho = max(VOex.Rho(:));
    VOex.MaxT1 = max(VOex.T1(:));
    VOex.MaxT2 = max(VOex.T2(:));
    VOex.MaxdWRnd = max(VMex.dWRnd(:));
    
    % Spin execution
    VObj=VOex;
    VMag=VMex;
    
    DoScanSeriesUpd(handles,2);
    handles=guidata(handles.SimuPanel_figure);
    pause(0.01);
    
    % Scan Process
    set(hObject,'String','Pgen...');
    pause(0.01);
    DoPulseGen(handles); % Generate Pulse line
    VCtl.RunMode=int32(0); % Image scan
    DoDataTypeConv(handles);
    
    VCtl.MaxThreadNum=int32(handles.CPUInfo.NumThreads);
    VCtl.ActiveThreadNum=int32(0);
    
    Exe = 0;
    for i = 1:99 % check first 99 possible GPU device
        if isfield(handles,['GPU' num2str(i) '_uimenu'])
            if strcmp(get(handles.(['GPU' num2str(i) '_uimenu']),'Checked'),'on')
                VCtl.GPUIndex=int32(i-1);
                if isfield(VCtl, 'MT_Flag')
                    if strcmp(VCtl.MT_Flag, 'on')
                        if handles.BatchFlag==1
                            error('DoMTScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoMTScanAtGPU;  % beta MT kernel, only support two-pool MT
                    else
                        if handles.BatchFlag==1
                            error('DoScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoScanAtGPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
                    end
                elseif isfield(VCtl, 'ME_Flag')
                    if strcmp(VCtl.ME_Flag, 'on')
                        if handles.BatchFlag==1
                            error('DoMEScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoMEScanAtGPU;  % beta ME kernel
                    else
                        if handles.BatchFlag==1
                            error('DoScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoScanAtGPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
                    end
                elseif isfield(VCtl, 'CEST_Flag')
                    if strcmp(VCtl.CEST_Flag, 'on')
                        if handles.BatchFlag==1
                            error('DoCESTScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoCESTScanAtGPU;  % beta CEST kernel
                    else
                        if handles.BatchFlag==1
                            error('DoScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoScanAtGPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
                    end
                elseif isfield(VCtl, 'GM_Flag')
                    if strcmp(VCtl.GM_Flag, 'on')
                        if handles.BatchFlag==1
                            error('DoGMScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoGMScanAtGPU;  % beta GM kernel
                    else
                        if handles.BatchFlag==1
                            error('DoScanAtGPU');
                        end
                        set(hObject,'String','Scan...');
                        pause(0.01);
                        DoScanAtGPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
                    end
                else
                    if handles.BatchFlag==1
                        error('DoScanAtGPU');
                    end
                    set(hObject,'String','Scan...');
                    pause(0.01);
                    DoScanAtGPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
                end
                Exe = 1;
                break;
            end
        end
    end
    
    if Exe == 0
        if isfield(handles,'CPU_uimenu')
            if strcmp(get(handles.CPU_uimenu,'Checked'),'on')
                if isfield(VCtl, 'MT_Flag')
                    if strcmp(VCtl.MT_Flag, 'on')
                        error('CPU engine currently doesn''t support Magnetization Transfer model.');
                    end
                elseif isfield(VCtl, 'ME_Flag')
                    if strcmp(VCtl.ME_Flag, 'on')
                        error('CPU engine currently doesn''t support Multiple Pool Exchange model.');
                    end
                elseif isfield(VCtl, 'CEST_Flag')
                    if strcmp(VCtl.CEST_Flag, 'on')
                        error('CPU engine currently doesn''t support Chemical Exchange Saturation Transfer model.');
                    end
                elseif isfield(VCtl, 'GM_Flag')
                    if strcmp(VCtl.GM_Flag, 'on')
                        error('CPU engine currently doesn''t support General Model.');
                    end
                end
                
                if handles.BatchFlag==1
                    error('DoScanAtCPU');
                end
                set(hObject,'String','Scan...');
                pause(0.01);
                DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
            else
                error('No processing unit is selected.');
            end
        else
            error('No processing unit is selected.');
        end
    end
    set(hObject,'String','Post...');
    pause(0.01);
    DoPostScan(handles);
    handles=guidata(handles.SimuPanel_figure);
    DoScanSeriesUpd(handles,3);
    handles=guidata(handles.SimuPanel_figure);
    DoScanSeriesUpd(handles,0);
catch me
    if handles.BatchFlag==1 & strcmp(me.message(1:2),'Do')
        if ~isfield(VCtl,'SeriesName')
            error_msg{1,1}='ERROR!!! No MR sequence is loaded!';
            errordlg(error_msg);
        else
            set(hObject,'String','+Batch');
            handles.Engine=me.message;
            handles.SimName=VCtl.SeriesName;

            DoUpdateBatch(handles);
            
            handles=guidata(handles.SimuPanel_figure);
            handles.BatchFlag=0;
            DoScanSeriesUpd(handles,5);
            handles=guidata(handles.SimuPanel_figure);
            DoScanSeriesUpd(handles,0);
            
            str = get(handles.Batch_pushbutton,'String');
            set(handles.Batch_pushbutton,'String',['\_' num2str(str2num(str(3:end-2))+1) '_/']);
            
        end
    else
        error_msg{1,1}='ERROR!!! Scan process aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        DoScanSeriesUpd(handles,4);
        handles=guidata(handles.SimuPanel_figure);
        DoScanSeriesUpd(handles,0);
    end
end

set(hObject,'String','Scan');
% Recover VObj VMag VCoi
VObj=VTmpObj;
VMag=VTmpMag;


% --------------------------------------------------------------------
function LoadVObj_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVObj_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end

% --------------------------------------------------------------------
function LoadBrainS_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBrainS_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'BrainStandardResolution.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end

% --------------------------------------------------------------------
function LoadBrainH_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBrainH_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'BrainHighResolution.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end

% --- Executes on selection change in Info_listbox.
function Info_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Info_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Info_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Info_listbox

% --- Executes during object creation, after setting all properties.
function Info_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Info_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function Preview_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Preview_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.IV.Slice=round(get(hObject,'Value') );
DoUpdateImage(handles.Preview_axes,handles.Img,handles.IV);
text(0,3,['Slice : ' num2str(handles.IV.Slice)],'Color','g');

% --- Executes during object creation, after setting all properties.
function Preview_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Preview_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function Seq_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Seq_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SeqDesignPanel(handles);


% --------------------------------------------------------------------
function rf_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to rf_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rfDesignPanel(handles);

% --------------------------------------------------------------------
function Coil_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Coil_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CoilDesignPanel(handles);

% --- Executes when user attempts to close SimuPanel_figure.
function SimuPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SimuPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clearvars -global;
if exist([handles.MRiLabPath filesep 'Tmp' filesep 'BatchData.mat'],'file')
    delete([handles.MRiLabPath filesep 'Tmp' filesep 'BatchData.mat']);
end

% try 
%     gpuDevice([]); % deselect GPU, avoid Matlab for heating up GPU when idle?
% catch me
% end

disp('Thank you for using MRiLab.');
% Hint: delete(hObject) closes the figure
delete(hObject);


% --------------------------------------------------------------------
function SavePanel_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoSaveSnapshot(handles.SimuPanel_figure);

% --------------------------------------------------------------------
function Matlab_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Matlab_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://www.mathworks.com/products/matlab/', '-browser');

% --------------------------------------------------------------------
function AboutMRiLab_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to AboutMRiLab_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AboutMRiLab(handles);

% --------------------------------------------------------------------
function ADeveloper_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to ADeveloper_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://www.fliu37.com', '-browser');

% --------------------------------------------------------------------
function SelectPU_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to SelectPU_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MatrixUser_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to MatrixUser_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MatrixUser(handles);


% --------------------------------------------------------------------
function LoadWFP_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadWFP_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'WaterFatPhantom']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function SpinWatcher_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SpinWatcher_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SpinWatcherPanel(handles);


% --------------------------------------------------------------------
function Mag_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Mag_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MagDesignPanel(handles);


% --- Executes when entered data in editable cell(s) in ScanSeries_uitable.
function ScanSeries_uitable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to ScanSeries_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

handles.ScanSeries=get(handles.ScanSeries_uitable,'Data');
guidata(hObject, handles);


% --------------------------------------------------------------------
function CDeveloper_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to CDeveloper_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function PSDMemo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PSDMemo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSDMemo_edit as text
%        str2double(get(hObject,'String')) returns contents of PSDMemo_edit as a double


% --- Executes during object creation, after setting all properties.
function PSDMemo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSDMemo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Setting_uipanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Setting_uipanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Mot_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Mot_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MotDesignPanel(handles);


% --- Executes on selection change in Channel_popupmenu.
function Channel_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Channel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Channel_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Channel_popupmenu

global VImg
global VCtl

Conts=get(handles.Channel_popupmenu,'String');
SelCont=Conts{get(handles.Channel_popupmenu,'Value')};

switch SelCont
    case 'SumofMagn'
        Img = sum(VImg.Mag, 4);
    case 'SumofCplx'
        Img = abs(sum(VImg.Real, 4) + 1i*sum(VImg.Imag,4));
    otherwise
        Img = VImg.Mag(:,:,:,str2num(SelCont),:);
end

Conts=get(handles.Echo_popupmenu,'String');
SelCont=Conts{get(handles.Echo_popupmenu,'Value')};
handles.Img = Img(:,:,:,str2num(SelCont)); % show chosen echo

%  Output image display
handles.IV=struct(...
                'Slice',ceil(VCtl.SliceNum/2),...
                'C_lower',min(min(min(handles.Img))),...
                'C_upper',max(max(max(handles.Img))),...
                'Axes','off',...
                'Grid','off',...
                'Color_map','Gray'...
                );
DoUpdateImage(handles.Preview_axes,handles.Img,handles.IV);
[row,col,layer]=size(handles.Img);
if layer==1
    set(handles.Preview_slider,'Enable','off');
else
    set(handles.Preview_slider,'Enable','on');
    set(handles.Preview_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer],'Value',ceil(layer/2));
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Channel_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Channel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function LoadOP_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadOP_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'OnePoint']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function LoadBrainT_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBrainT_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'BrainTissue.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in GradList_pushbutton.
function GradList_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GradList_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoUpdateInfo(handles,'Loading gradient...');
GradList(handles);


% --------------------------------------------------------------------
function Grad_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Grad_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GradDesignPanel(handles);


% --- Executes on selection change in VObjType_popupmenu.
function VObjType_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to VObjType_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns VObjType_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from VObjType_popupmenu

VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function VObjType_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VObjType_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in ScanSeries_uitable.
function ScanSeries_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to ScanSeries_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if numel(eventdata.Indices)==0
    return;
end

global VImg;

ScanSeries = get(hObject,'Data');
if ~(strcmp(ScanSeries{eventdata.Indices(1), 2}, 'V') | strcmp(ScanSeries{eventdata.Indices(1), 2}, 'B'))
    return;
end

if strcmp(ScanSeries{eventdata.Indices(1), 2}, 'V')
    OutputDir = handles.OutputDir;
end

if strcmp(ScanSeries{eventdata.Indices(1), 2}, 'B')
    OutputDir = handles.BatchDir;
end

% Load chosen image
try
    S = load([OutputDir filesep 'Series' num2str(eventdata.Indices(1)) '.mat']);
    Img = sum(S.VImg.Mag, 4); % show SumofMagn
    handles.Img = Img(:,:,:,1); % show first echo
catch me
    error_msg{1,1}=['Loading image Series' num2str(eventdata.Indices(1)) ' failed.'];
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

%  Update channel selection
VImg = S.VImg;
channel = {'SumofMagn';'SumofCplx'};
for i = 1:size(VImg.Mag,4)
    channel{i+2} = i;
end
set(handles.Channel_popupmenu,'String',channel);
set(handles.Channel_popupmenu,'Value', 1);

%  Update echo selection
echo = {};
for i = 1:size(VImg.Mag,5)
    echo{i} = i;
end
set(handles.Echo_popupmenu,'String',echo);
set(handles.Echo_popupmenu,'Value',1);

% Output image display
[row,col,layer]=size(handles.Img);
handles.IV=struct(...
    'Slice',ceil(layer/2),...
    'C_lower',min(min(min(handles.Img))),...
    'C_upper',max(max(max(handles.Img))),...
    'Axes','off',...
    'Grid','off',...
    'Color_map','Gray'...
    );
DoUpdateImage(handles.Preview_axes,handles.Img,handles.IV);
set(handles.Preview_uipanel,'Title',['Preview : Series' num2str(eventdata.Indices(1))]);
if layer==1
    set(handles.Preview_slider,'Enable','off');
else
    set(handles.Preview_slider,'Enable','on');
    set(handles.Preview_slider,'Min',1,'Max',layer,'SliderStep',[1/layer, 4/layer],'Value',ceil(layer/2));
    text(0,3,['Slice : ' num2str(handles.IV.Slice)],'Color','g');
end
guidata(hObject, handles);


% --- Executes on selection change in Echo_popupmenu.
function Echo_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Echo_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Echo_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Echo_popupmenu

Channel_popupmenu_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function Echo_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Echo_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Parallel_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Parallel_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Help_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Help_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadMT_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMT_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'MT.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function SimuPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SimuPanel_figure (see GCBO)
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


% --------------------------------------------------------------------
function UserGuide_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to UserGuide_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://mrilab.sourceforge.net/manual/MRiLab_User_Guide_v1_3/MRiLab_User_Guide.html', '-browser');

% --------------------------------------------------------------------
function Licensing_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Licensing_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Licensing(handles);

% --------------------------------------------------------------------
function WebResources_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to WebResources_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Demo_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Demo_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://mrilab.sourceforge.net/demo.html', '-browser');

% --------------------------------------------------------------------
function LoadME_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadME_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'ME.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end


% --------------------------------------------------------------------
function MRiLabWebSite_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to MRiLabWebSite_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://mrilab.sourceforge.net/', '-browser');

% --------------------------------------------------------------------
function MRiLabForum_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to MRiLabForum_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://sourceforge.net/p/mrilab/discussion/', '-browser');

% --------------------------------------------------------------------
function MatrixUserWebSite_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to MatrixUserWebSite_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://matrixuser.sourceforge.net/', '-browser');


% --------------------------------------------------------------------
function Design_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Design_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Seq_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Seq_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SeqDesignPanel(handles);

% --------------------------------------------------------------------
function rf_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to rf_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rfDesignPanel(handles);

% --------------------------------------------------------------------
function Coil_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Coil_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CoilDesignPanel(handles);

% --------------------------------------------------------------------
function Grad_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Grad_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GradDesignPanel(handles);

% --------------------------------------------------------------------
function Mag_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Mag_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MagDesignPanel(handles);

% --------------------------------------------------------------------
function Mot_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Mot_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MotDesignPanel(handles);


% --------------------------------------------------------------------
function Tools_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Tools_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MatrixUser_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to MatrixUser_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MatrixUser(handles);

% --------------------------------------------------------------------
function SpinWatcher_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to SpinWatcher_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SpinWatcherPanel(handles);

% --------------------------------------------------------------------
function SARWatcher_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to SARWatcher_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SARWatcherPanel(handles);

% --------------------------------------------------------------------
function SeqConverter_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to SeqConverter_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Phantom_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to Phantom_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VObjDesignPanel(handles);


% --------------------------------------------------------------------
function Phan_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Phan_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
VObjDesignPanel(handles);


% --------------------------------------------------------------------
function LoadVObjXML_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVObjXML_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    DoUpdateInfo(handles,'Loading virtual object XML file...');
    [filename,pathname,filterindex]=uigetfile({'VObj*.xml','XML-files (*.xml)'},'MultiSelect','off');
    handles.VObjXMLFile = [pathname filename];
    VObjDesignPanel(handles);
    guidata(hObject, handles);
catch me
    DoUpdateInfo(handles,'Loading virtual object XML file failed.');
    error_msg{1,1}='ERROR!!! Loading virtual object XML file aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end
DoUpdateInfo(handles,'Virtual object XML file was successfully loaded.');
set(handles.LoadVObjXML_uimenu,'Label',['Load Phantom XML : ' filename]);
set(handles.LoadVObjfromXML_uimenu,'Enable','on');


% --------------------------------------------------------------------
function LoadVObjfromXML_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVObjfromXML_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    LoadFlag=DoLoadPhantom(handles, [handles.VObjXMLFile(1:end-4) '.mat']);
catch me
    DoUpdateInfo(handles,'Loading virtual object from XML file failed.');
    error_msg{1,1}='ERROR!!! Loading phantom from XML aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in Display_pushbutton.
function Display_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Display_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VObj
Conts=get(handles.VObjSpinMap_popupmenu,'String');
SelCont=Conts{get(handles.VObjSpinMap_popupmenu,'Value')};
assignin('base', SelCont, VObj.(SelCont));
MU_Matrix_Display(SelCont,'Magnitude');


% --------------------------------------------------------------------
function BatchSim_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to BatchSim_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BatchSim(handles);


% --------------------------------------------------------------------
function BatchSim_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to BatchSim_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BatchSim(handles);


% --- Executes on button press in Batch_pushbutton.
function Batch_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Batch_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BatchFlag=1;
set(handles.Batch_pushbutton,'Enable','off');
Scan_pushbutton_Callback(handles.Scan_pushbutton, eventdata, handles);


% --------------------------------------------------------------------
function SARWatcher_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SARWatcher_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SARWatcherPanel(handles);

% --------------------------------------------------------------------
function LoadMPO_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMPO_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('https://sourceforge.net/projects/mrilab/files/Phantoms/', '-browser');

% --------------------------------------------------------------------
function LoadCEST_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadCEST_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'CEST.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end

% --------------------------------------------------------------------
function LoadGM_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadGM_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

LoadFlag=DoLoadPhantom(handles,[handles.MRiLabPath filesep 'Resources' filesep 'VObj' filesep 'GM.mat']);

if LoadFlag==1
    VObjSpinMap_popupmenu_Callback(hObject, eventdata, handles)
end
