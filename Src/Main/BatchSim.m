

function varargout = BatchSim(varargin)
% BATCHSIM MATLAB code for BatchSim.fig
%      BATCHSIM, by itself, creates a new BATCHSIM or raises the existing
%      singleton*.
%
%      H = BATCHSIM returns the handle to a new BATCHSIM or the handle to
%      the existing singleton*.
%
%      BATCHSIM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHSIM.M with the given input arguments.
%
%      BATCHSIM('Property','Value',...) creates a new BATCHSIM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BatchSim_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BatchSim_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BatchSim

% Last Modified by GUIDE v2.5 10-Apr-2014 22:31:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BatchSim_OpeningFcn, ...
                   'gui_OutputFcn',  @BatchSim_OutputFcn, ...
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


% --- Executes just before BatchSim is made visible.
function BatchSim_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BatchSim (see VARARGIN)

handles.Simuh=varargin{1};
handles.MotionFcn=1;

% set default output path
set(handles.OutputPath_edit,'String',handles.Simuh.BatchDir,'TooltipString',handles.Simuh.BatchDir);

% load batch list
set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);

% buttons
if isempty(handles.Simuh.BatchList)
    set(handles.Delete_pushbutton,'Enable','off');
    set(handles.Up_pushbutton,'Enable','off');
    set(handles.Down_pushbutton,'Enable','off');
    set(handles.Execute_pushbutton,'Enable','off');
end

% Choose default command line output for BatchSim
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BatchSim wait for user response (see UIRESUME)
% uiwait(handles.BatchSim_figure);


% --- Outputs from this function are returned to the command line.
function varargout = BatchSim_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Execute_pushbutton.
function Execute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Execute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VSeq
global VObj
global VCtl
global VMag
global VCoi
global VMot
global VVar
global VSig

handles.MotionFcn=0;
guidata(hObject, handles);

set(handles.Delete_pushbutton,'Enable','off');
set(handles.Up_pushbutton,'Enable','off');
set(handles.Down_pushbutton,'Enable','off');
set(handles.Execute_pushbutton,'Enable','off');
set(handles.Simuh.Scan_pushbutton,'Enable','off');
set(handles.Simuh.Batch_pushbutton,'Enable','off');
pause(0.01);

% Preserve VObj VMag
VTmpObj=VObj;
VTmpMag=VMag;
% Preserve additional info
OutputDir=handles.Simuh.OutputDir;
ScanSeriesInd=handles.Simuh.ScanSeriesInd;
handles.Simuh.OutputDir=handles.Simuh.BatchDir;

for i=1:length(handles.Simuh.BatchListIdx)
    if ~strcmp(handles.Simuh.BatchList{i,4},'Dx')
        continue;
    end
    try
        handles.Simuh.BatchList{i,4}='...';
        set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);
        pause(0.01);
        handles.Simuh.ScanSeriesInd=handles.Simuh.BatchListIdx(i);
        
        %load settings
        load([handles.Simuh.MRiLabPath filesep 'Tmp' filesep 'BatchData'], ...
            ['VSeq' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VObj' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VCtl' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VMag' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VCoi' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VMot' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VVar' num2str(handles.Simuh.BatchListIdx(i))], ...
            ['VSig' num2str(handles.Simuh.BatchListIdx(i))]);
        
        eval(['VSeq=' 'VSeq' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VObj=' 'VObj' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VCtl=' 'VCtl' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VMag=' 'VMag' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VCoi=' 'VCoi' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VMot=' 'VMot' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VVar=' 'VVar' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        eval(['VSig=' 'VSig' num2str(handles.Simuh.BatchListIdx(i)) ';']);
        
        % do scan
        eval([handles.Simuh.BatchList{i,3} ';']);
        % do post-processing
        DoPostScan(handles.Simuh);
        
        handles.Simuh.BatchList{i,4}='V';
        set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);
        pause(0.01);
    catch me
        error_msg{1,1}=['ERROR!!! Batch scan ''' handles.Simuh.BatchList{i,1} ''' aborted.'];
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        handles.Simuh.BatchList{i,4}='X';
        set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);
        pause(0.01);
        break;
    end
end

set(handles.Delete_pushbutton,'Enable','on');
set(handles.Up_pushbutton,'Enable','on');
set(handles.Down_pushbutton,'Enable','on');
set(handles.Execute_pushbutton,'Enable','on');

% Recover VObj VMag
VObj=VTmpObj;
VMag=VTmpMag;

% Recover additional info
handles.Simuh.OutputDir=OutputDir;
handles.Simuh.ScanSeriesInd=ScanSeriesInd;

handles.MotionFcn=1;
guidata(hObject, handles);
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);


% --- Executes on button press in Up_pushbutton.
function Up_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Up_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'SelIdx')
    return;
end

if handles.SelIdx~=1
    
    tmp=handles.Simuh.BatchList(handles.SelIdx-1,:);
    handles.Simuh.BatchList(handles.SelIdx-1,:)=handles.Simuh.BatchList(handles.SelIdx,:);
    handles.Simuh.BatchList(handles.SelIdx,:)=tmp;
    
    idx=handles.Simuh.BatchListIdx(handles.SelIdx-1);
    handles.Simuh.BatchListIdx(handles.SelIdx-1)=handles.Simuh.BatchListIdx(handles.SelIdx);
    handles.Simuh.BatchListIdx(handles.SelIdx)=idx;

    % load batch list
    set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);
    guidata(hObject, handles);
    guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
    
end


% --- Executes on button press in Down_pushbutton.
function Down_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Down_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'SelIdx')
    return;
end

if handles.SelIdx~=length(handles.Simuh.BatchListIdx)
    
    tmp=handles.Simuh.BatchList(handles.SelIdx+1,:);
    handles.Simuh.BatchList(handles.SelIdx+1,:)=handles.Simuh.BatchList(handles.SelIdx,:);
    handles.Simuh.BatchList(handles.SelIdx,:)=tmp;
    
    idx=handles.Simuh.BatchListIdx(handles.SelIdx+1);
    handles.Simuh.BatchListIdx(handles.SelIdx+1)=handles.Simuh.BatchListIdx(handles.SelIdx);
    handles.Simuh.BatchListIdx(handles.SelIdx)=idx;

    % load batch list
    set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);
    guidata(hObject, handles);
    guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
    
end



% --- Executes on button press in Delete_pushbutton.
function Delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'SelIdx')
    return;
end

handles.Simuh.BatchList(handles.SelIdx,:)=[];
handles.Simuh.BatchListIdx(handles.SelIdx)=[];

% load batch list
set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);
guidata(hObject, handles);
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);

str = get(handles.Simuh.Batch_pushbutton,'String');
set(handles.Simuh.Batch_pushbutton,'String',['\_' num2str(max(0,str2num(str(3:end-2))-1)) '_/']);

if str2num(str(3:end-2))==1
    set(handles.Delete_pushbutton,'Enable','off');
    set(handles.Up_pushbutton,'Enable','off');
    set(handles.Down_pushbutton,'Enable','off');
    set(handles.Execute_pushbutton,'Enable','off');
end


function OutputPath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to OutputPath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of OutputPath_edit as text
%        str2double(get(hObject,'String')) returns contents of OutputPath_edit as a double


% --- Executes during object creation, after setting all properties.
function OutputPath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputPath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OutputPath_pushbutton.
function OutputPath_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OutputPath_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path=uigetdir;
if path==0
    return;
end
handles.Simuh.BatchDir=path;

% set batch output path
set(handles.OutputPath_edit,'String',handles.Simuh.BatchDir,'TooltipString',handles.Simuh.BatchDir);

guidata(hObject, handles);
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);


% --- Executes on mouse motion over figure - except title and menu.
function BatchSim_figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to BatchSim_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.MotionFcn==1
    % load batch list
    handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
    set(handles.Batch_uitable,'Data',handles.Simuh.BatchList);

    if ~isempty(handles.Simuh.BatchList)
        set(handles.Delete_pushbutton,'Enable','on');
        set(handles.Up_pushbutton,'Enable','on');
        set(handles.Down_pushbutton,'Enable','on');
        set(handles.Execute_pushbutton,'Enable','on');
    end

    guidata(hObject, handles);
end


% --- Executes when selected cell(s) is changed in Batch_uitable.
function Batch_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Batch_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if numel(eventdata.Indices)==0
    return;
end
handles.SelIdx = eventdata.Indices(1);

guidata(hObject, handles);
