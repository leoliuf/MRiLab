% MatrixUser, a multi-dimensional matrix analysis software package
% https://sourceforge.net/projects/matrixuser/
% 
% The MatrixUser is a matrix analysis software package developed under Matlab
% Graphical User Interface Developing Environment (GUIDE). It features 
% functions that are designed and optimized for working with multi-dimensional
% matrix under Matlab. These functions typically includes functions for 
% multi-dimensional matrix display, matrix (image stack) analysis and matrix 
% processing.
%
% Author:
%   Fang Liu <leoliuf@gmail.com>
%   University of Wisconsin-Madison
%   Aug-30-2014



function varargout = MU_Load_Binary_File(varargin)
% MU_LOAD_BINARY_FILE MATLAB code for MU_load_binary_file.fig
%      MU_LOAD_BINARY_FILE, by itself, creates a new MU_LOAD_BINARY_FILE or raises the existing
%      singleton*.
%
%      H = MU_LOAD_BINARY_FILE returns the handle to a new MU_LOAD_BINARY_FILE or the handle to
%      the existing singleton*.
%
%      MU_LOAD_BINARY_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_LOAD_BINARY_FILE.M with the given input arguments.
%
%      MU_LOAD_BINARY_FILE('Property','Value',...) creates a new MU_LOAD_BINARY_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Load_Binary_File_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Load_Binary_File_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_load_binary_file

% Last Modified by GUIDE v2.5 14-Sep-2013 16:34:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Load_Binary_File_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Load_Binary_File_OutputFcn, ...
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


% --- Executes just before MU_load_binary_file is made visible.
function MU_Load_Binary_File_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_load_binary_file (see VARARGIN)

handles.fid=fopen([varargin{5} varargin{4}]);

if handles.fid==-1
    MU_Load_Binary_File_CloseRequestFcn;
    errordlg('File can not be opened!');
end

% give ramdon matrix name
set(handles.MxName_edit,'String',['TMx' num2str(round(rand(1).*1000))]);

% Choose default command line output for MU_load_binary_file
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_load_binary_file wait for user response (see UIRESUME)
% uiwait(handles.MU_load_binary_file);


% --- Outputs from this function are returned to the command line.
function varargout = MU_Load_Binary_File_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in MxType_popupmenu.
function MxType_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to MxType_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MxType_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MxType_popupmenu


% --- Executes during object creation, after setting all properties.
function MxType_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MxType_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XDim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to XDim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XDim_edit as text
%        str2double(get(hObject,'String')) returns contents of XDim_edit as a double


% --- Executes during object creation, after setting all properties.
function XDim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XDim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function YDim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to YDim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YDim_edit as text
%        str2double(get(hObject,'String')) returns contents of YDim_edit as a double


% --- Executes during object creation, after setting all properties.
function YDim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YDim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZDim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ZDim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZDim_edit as text
%        str2double(get(hObject,'String')) returns contents of ZDim_edit as a double


% --- Executes during object creation, after setting all properties.
function ZDim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZDim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Offset_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Offset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Offset_edit as text
%        str2double(get(hObject,'String')) returns contents of Offset_edit as a double


% --- Executes during object creation, after setting all properties.
function Offset_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Offset_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Gap_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Gap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gap_edit as text
%        str2double(get(hObject,'String')) returns contents of Gap_edit as a double


% --- Executes during object creation, after setting all properties.
function Gap_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Mach_popupmenu.
function Mach_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Mach_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Mach_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Mach_popupmenu


% --- Executes during object creation, after setting all properties.
function Mach_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mach_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_pushbutton.
function Load_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Load_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
contents=get(handles.MxType_popupmenu,'String');
MxType=contents{get(handles.MxType_popupmenu,'Value')};
contents=get(handles.Mach_popupmenu,'String');
Mach=contents{get(handles.Mach_popupmenu,'Value')};
MxName=get(handles.MxName_edit,'String');
if isempty(MxName)
    errordlg('Please provide an matrix name.');
    return;
end
XDim=get(handles.XDim_edit,'String');
YDim=get(handles.YDim_edit,'String');
ZDim=get(handles.ZDim_edit,'String');
Skip=get(handles.Skip_edit,'String');
Offset=get(handles.Offset_edit,'String');
Gap=get(handles.Gap_edit,'String');

for i=1:str2double(ZDim)
    if i==1
        fseek(handles.fid, str2double(Offset), 'bof');
    end
    try
        TMx(:,:,i)=fread(handles.fid, [str2double(YDim), str2double(XDim)],['*' MxType], str2double(Skip), Mach);
        if i==1
            tMx=TMx;
            TMx=zeros(str2double(YDim),str2double(XDim),str2double(ZDim));
            TMx = cast(TMx, class(tMx)); % convert back to whatever original
            TMx(:,:,1)=tMx;
        end
    catch me
        errordlg('Error occurs when loading file!');
        fclose(handles.fid);
        MU_load_binary_file_CloseRequestFcn(hObject, eventdata, handles);
        return;
    end
    fseek(handles.fid, str2double(Gap), 'cof');
end
fclose(handles.fid);

if ~MU_load_matrix(MxName, TMx, 1)
    errordlg('Loading binary file failed!');
end

MU_load_binary_file_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close MU_load_binary_file.
function MU_load_binary_file_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MU_load_binary_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(handles.MU_load_binary_file);



function Skip_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Skip_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Skip_edit as text
%        str2double(get(hObject,'String')) returns contents of Skip_edit as a double


% --- Executes during object creation, after setting all properties.
function Skip_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Skip_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MxName_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MxName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MxName_edit as text
%        str2double(get(hObject,'String')) returns contents of MxName_edit as a double


% --- Executes during object creation, after setting all properties.
function MxName_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MxName_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
