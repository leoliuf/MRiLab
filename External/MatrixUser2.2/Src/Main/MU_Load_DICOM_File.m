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




function varargout = MU_Load_DICOM_File(varargin)
% MU_LOAD_DICOM_FILE M-file for MU_Load_DICOM_File.fig
%      MU_LOAD_DICOM_FILE, by itself, creates a new MU_LOAD_DICOM_FILE or raises the existing
%      singleton*.
%
%      H = MU_LOAD_DICOM_FILE returns the handle to a new MU_LOAD_DICOM_FILE or the handle to
%      the existing singleton*.
%
%      MU_LOAD_DICOM_FILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_LOAD_DICOM_FILE.M with the given input arguments.
%
%      MU_LOAD_DICOM_FILE('Property','Value',...) creates a new MU_LOAD_DICOM_FILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Load_DICOM_File_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Load_DICOM_File_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_Load_DICOM_File

% Last Modified by GUIDE v2.5 18-Sep-2013 17:17:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Load_DICOM_File_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Load_DICOM_File_OutputFcn, ...
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

% --- Executes just before MU_Load_DICOM_File is made visible.
function MU_Load_DICOM_File_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to MU_Load_DICOM_File (see VARARGIN)

%MatrixUser logo
MU_marks(handles.Matrix_preview_axes,'MatrixUser');

set(handles.File_list,'String',varargin{4});
set(handles.File_list,'Max',max(size(varargin{4})));
handles.pathname=varargin{5};


% Choose default command line output for MU_Load_DICOM_File
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_Load_DICOM_File wait for user response (see UIRESUME)
% uiwait(handles.MU_load_DICOM_file);


% --- Outputs from this function are returned to the command line.
function varargout = MU_Load_DICOM_File_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in File_list.
function File_list_Callback(hObject, eventdata, handles)

% Hints: contents = get(hObject,'String') returns File_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from File_list

contents=get(handles.File_list,'String');
if ischar(contents)
        filename=[handles.pathname contents];
else
        selected_files=contents(get(handles.File_list,'Value'));
        filename=[handles.pathname selected_files{1}];
end
try
    info=dicominfo(filename);
    dicom_image=dicomread(filename);
catch me
    warndlg([char(39) filename char(39) ' is not in DICOM format.']);
    return;
end

% dicom_image=double(dicom_image);
set(gcf,'CurrentAxes',handles.Matrix_preview_axes);
imagesc(dicom_image);
colormap gray;
axis off;          % Remove axis ticks and numbers
axis image;        % Set aspect ratio to obtain square pixels

cstr=MU_readStruct(info);
set(handles.DICOM_header_list,'String',cstr);


% --- Executes during object creation, after setting all properties.
function File_list_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in File_check_button.
function File_check_button_Callback(hObject, eventdata, handles)

contents=get(handles.File_list,'String');
if iscell(contents)
    selected_files=contents(get(handles.File_list,'Value'));
    set(handles.Selected_file_list,'String',selected_files);
    set(handles.Selected_file_list,'Max',max(size(selected_files)));
else
    selected_files=contents;
    set(handles.Selected_file_list,'String',selected_files);
    set(handles.Selected_file_list,'Max',1);
end

% --- Executes on button press in File_uncheck_button.
function File_uncheck_button_Callback(hObject, eventdata, handles)

if ~isempty(get(handles.Selected_file_list,'String'))
    contents=get(handles.Selected_file_list,'String');
    if iscell(contents)
        ind=get(handles.Selected_file_list,'Value');
        contents(ind)=[];
        set(handles.Selected_file_list,'String',contents);
    else
        set(handles.Selected_file_list,'String',[]);
    end
end
set(handles.Selected_file_list,'Value',1);


% --- Executes on selection change in Selected_file_list.
function Selected_file_list_Callback(hObject, eventdata, handles)

% Hints: contents = get(hObject,'String') returns Selected_file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Selected_file_list


% --- Executes during object creation, after setting all properties.
function Selected_file_list_CreateFcn(hObject, eventdata, handles)


% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in DICOM_convert_button.
function DICOM_convert_button_Callback(hObject, eventdata, handles)

contents=get(handles.Selected_file_list,'String');

set(handles.DICOM_convert_button,'Enable','off');
set(handles.File_uncheck_button,'Enable','off');
set(handles.File_check_button,'Enable','off');
set(handles.Load_matrix_button,'Enable','off');
set(handles.Edit_matrix_name,'Enable','off');
[created_matrix,created_matrix_name,errflag]=MU_DICOM2Mat(contents,handles.pathname,handles);
set(handles.DICOM_convert_button,'Enable','on');
set(handles.File_uncheck_button,'Enable','on');
set(handles.File_check_button,'Enable','on');
set(handles.Load_matrix_button,'Enable','on');
set(handles.Edit_matrix_name,'Enable','on');

if errflag==1
    return;
elseif errflag==0
    handles.created_matrices.(created_matrix_name)=created_matrix;
    set(handles.Created_matrix_list,'String',fieldnames(handles.created_matrices));
    
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Created_matrix_list_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Edit_matrix_name_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_matrix_button.
function Load_matrix_button_Callback(hObject, eventdata, handles)

if ~isfield(handles,'created_matrices')
    errordlg('No matrix was created!');
    return;
end
if isempty(handles.created_matrices)
    errordlg('No matrix was created!');
    return;
end

created_matrix_name=fieldnames(handles.created_matrices);
for i=1:max(size(created_matrix_name))
    MU_load_matrix(created_matrix_name{i}, handles.created_matrices.(created_matrix_name{i}),0);
end

MU_load_DICOM_file_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close MU_load_DICOM_file.
function MU_load_DICOM_file_CloseRequestFcn(hObject, eventdata, handles)

delete(handles.MU_load_DICOM_file);

% Hint: delete(hObject) closes the figure
% delete(hObject);

% --- Executes during object creation, after setting all properties.
function DICOM_header_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DICOM_header_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Edit_matrix_name_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_matrix_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Edit_matrix_name as text
%        str2double(get(hObject,'String')) returns contents of Edit_matrix_name as a double
