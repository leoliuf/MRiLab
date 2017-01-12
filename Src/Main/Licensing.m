function varargout = Licensing(varargin)
% LICENSING MATLAB code for Licensing.fig
%      LICENSING, by itself, creates a new LICENSING or raises the existing
%      singleton*.
%
%      H = LICENSING returns the handle to a new LICENSING or the handle to
%      the existing singleton*.
%
%      LICENSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LICENSING.M with the given input arguments.
%
%      LICENSING('Property','Value',...) creates a new LICENSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Licensing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Licensing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Licensing

% Last Modified by GUIDE v2.5 24-Jan-2014 23:21:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Licensing_OpeningFcn, ...
                   'gui_OutputFcn',  @Licensing_OutputFcn, ...
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


% --- Executes just before Licensing is made visible.
function Licensing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Licensing (see VARARGIN)

handles.Simuh=varargin{1};

%----load license text
fid=fopen([handles.Simuh.MRiLabPath filesep 'License.txt'],'r');
if fid==-1
    set(handles.Licensing_edit,'String','License file is missing!');
else
    tline = fgetl(fid);
    i=1;
    while ischar(tline)
        Memo{i,1}=tline;
        tline = fgetl(fid);
        i=i+1;
    end
    if i==1
        set(handles.Licensing_edit,'String','License file is empty!');
    else
        set(handles.Licensing_edit,'String',Memo);
    end
    
    fclose(fid);
end
%----end

% Choose default command line output for Licensing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Licensing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Licensing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Licensing_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Licensing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Licensing_edit as text
%        str2double(get(hObject,'String')) returns contents of Licensing_edit as a double


% --- Executes during object creation, after setting all properties.
function Licensing_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Licensing_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
