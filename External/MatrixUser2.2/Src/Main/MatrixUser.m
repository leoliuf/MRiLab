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



function varargout = MatrixUser(varargin)
% MATRIXUSER M-Load_Mat_file for MatrixUser.fig
%      MATRIXUSER, by itself, creates a new MATRIXUSER or raises the existing
%      singleton*.
%
%      H = MATRIXUSER returns the handle to a new MATRIXUSER or the handle to
%      the existing singleton*.
%
%      MATRIXUSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATRIXUSER.M with the given input arguments.
%
%      MATRIXUSER('Property','Value',...) creates a new MATRIXUSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MatrixUser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MatrixUser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MatrixUser

% Last Modified by GUIDE v2.5 03-Oct-2013 14:33:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MatrixUser_OpeningFcn, ...
                   'gui_OutputFcn',  @MatrixUser_OutputFcn, ...
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


% --- Executes just before MatrixUser is made visible.
function MatrixUser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to MatrixUser (see VARARGIN)

global Figure_handles;

Figure_handles.MU_main=hObject;
[pathstr,name,ext]=fileparts(mfilename('fullpath'));
handles.path=pathstr;
handles.V.ROIs=[];

% Try to load MRiLab image series
if ~isempty(varargin)
    Figure_handles.Simuh=varargin{1};
    h=waitbar(0,'Reading image series-------->');
    files=dir(Figure_handles.Simuh.OutputDir);
    if max(size(files))>=3
        for i=3:max(size(files))
            waitbar((i-2)/(max(size(files))-2),h,['Reading image series--------> ' num2str(max(size(files))-2) ': Series #' num2str(i-2)]);
            file_name=files(i).name;
            try
                load([Figure_handles.Simuh.OutputDir filesep file_name],'-mat','VImg');
                assignin('base', [file_name(1:end-4) '_Mag'], VImg.Mag);
                assignin('base', [file_name(1:end-4) '_Phase'], VImg.Phase);
                assignin('base', [file_name(1:end-4) '_Sig'], VImg.Sx+1i*VImg.Sy);
            catch me
            end
        end
    end
    close(h);
end

% List workspace content
MU_update_list(handles);

% Choose default command line output for MatrixUser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes MatrixUser wait for user response (see UIRESUME)
% uiwait(handles.MatrixUser);

% --- Outputs from this function are returned to the command line.
function varargout = MatrixUser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function Load_Mat_file_Callback(hObject, eventdata, handles)

[filename,pathname,filterindex]=uigetfile({'*.mat','MAT-files (*.mat)'},'MultiSelect','off');
if filename~=0
    uiimport([pathname filename]);
end

% --------------------------------------------------------------------
function Load_DICOM_file_Callback(hObject, eventdata, handles)

[filename,pathname,filterindex]=uigetfile({'*.*','All files (*.*)'},'MultiSelect','on');
if iscell(filename)
    MU_Load_DICOM_File(hObject, eventdata, handles,filename,pathname);
elseif filename~=0
    MU_Load_DICOM_File(hObject, eventdata, handles,filename,pathname);
end

% --------------------------------------------------------------------
function Load_Bin_file_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Bin_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filterindex]=uigetfile({'*.*','All files (*.*)'},'MultiSelect','off');
if filename~=0
    MU_Load_Binary_File(hObject, eventdata, handles,filename,pathname);
end

% --------------------------------------------------------------------
function Load_batch_DICOM_file_Callback(hObject, eventdata, handles)
% hObject    handle to Load_batch_DICOM_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path=uigetdir;
if path==0
    return;
end
MU_Load_DICOM_File_Batch(hObject, eventdata, handles,path);

% --------------------------------------------------------------------
function Load_NIfTI_file_Callback(hObject, eventdata, handles)
% hObject    handle to Load_NIfTI_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%path(path,[handles.path filesep '..' filesep 'External' filesep 'spm8']);

try
    [filename,pathname,filterindex]=uigetfile({'*.nii','NIfTI-files (*.nii)'},'MultiSelect','off');
    if filename~=0
        [pathstr, name, ext]=fileparts(filename);
        [img,mat]=MU_load_nifti([pathname filename]);
        % img - a 3d (or 4d) matlab image matrix
        % mat - affine matrix describing voxel size & position

        if ~MU_load_matrix(name, img, 1)
            error('Loading matrix from NIfTI file failed!');
        end

        if ~MU_load_matrix([name '_affine'], mat, 0)
            error('Loading affine matrix from NIfTI file failed!');
        end
    end
catch me
    error_msg{1,1}='ERROR!!! Loading .nii file aborted.';
    error_msg{2,1}=me.message;
    error_msg{3,1}='Some spm8 MEX files are needed, you could download spm8 from';
    error_msg{4,1}='http://www.fil.ion.ucl.ac.uk/spm/software/spm8/';
    error_msg{5,1}='or you can download MatrixUser full version with ALL MEX included from';
    error_msg{6,1}='http://sourceforge.net/projects/matrixuser/';
    errordlg(error_msg);
end

% --- Executes on selection change in Matrix_list.
function Matrix_list_Callback(hObject, eventdata, handles)

% Update matrix list
MU_update_list(handles);

contents=get(handles.Matrix_list,'String');
currentMatrix=contents{get(handles.Matrix_list,'Value')};
if strcmp(currentMatrix,'Workspace is empty!')
    return;
end
selected_matrix= evalin('base', [currentMatrix ';']);

dimSize = size(selected_matrix);
set(handles.Matrix_size_text,'String',num2str(dimSize)); %Calculate matrix size
set(handles.Matrix_type_text,'String',class(selected_matrix)); %Calculate matrix type

if isnumeric(selected_matrix) %Calculate matrix range
        maxV=max(selected_matrix);
        minV=min(selected_matrix);
        for i=2:max(size(dimSize))
                maxV=max(maxV);
                minV=min(minV);
        end
        set(handles.Matrix_range_text,'String',['[ ' num2str(minV) ' , ' num2str(maxV) ' ]']);
else
        set(handles.Matrix_range_text,'String',[]);
end


% --- Executes during object creation, after setting all properties.
function Matrix_list_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Matrix_display_button.
function Matrix_display_button_Callback(hObject, eventdata, handles)

contents=get(handles.Matrix_list,'String');
currentMatrix=contents{get(handles.Matrix_list,'Value')};    
selected_matrix= evalin('base', [currentMatrix ';']);

if isnumeric(selected_matrix)
    dimSize = size(selected_matrix);
    if numel(dimSize)==2
        if dimSize(1)==1 & dimSize(2)==1
            errordlg('Single value can not be plotted!'); % display one point
        elseif dimSize(1)==1 | dimSize(2)==1
            if isreal(selected_matrix)
                figure;
                plot(selected_matrix,'-o');   % display one line
            else
                contents=get(handles.Complex_list,'String');
                complexFlag=contents{get(handles.Complex_list,'Value')};    
                figure;
                switch complexFlag
                    case 'Magnitude'
                        plot(abs(selected_matrix),'-o');   % display one line
                    case 'Phase'
                        plot(angle(selected_matrix),'-o');   % display one line
                    case 'Real'
                        plot(real(selected_matrix),'-o');   % display one line
                    case 'Imaginary'
                        plot(imag(selected_matrix),'-o');   % display one line
                end
            end
        else
            MU_Matrix_Display; % display 2D
        end
    else
        MU_Matrix_Display; % display multi-dimensional
    end
    return;
end

if isstruct(selected_matrix)
    figure('Resize','off','position',[100 120 560 550],'Name',['Structure Inspection : ' currentMatrix],'MenuBar','none');
    cstr=MU_readStruct(selected_matrix);
    Struct_d=uicontrol('Style', 'listbox', 'String', '','Position', [50  20  460  510]);
    set(Struct_d,'String',cstr);
    return;
end

errordlg(['Current MatrixUser doesn''t support analyzing ' class(selected_matrix) ' class!']);

% --- Executes when user attempts to close MatrixUser.
function MatrixUser_CloseRequestFcn(hObject, eventdata, handles)

clearvars -global Figure_handles;

% Hint: delete(hObject) closes the figure
delete(hObject);

% --------------------------------------------------------------------
function About_MU_Callback(hObject, eventdata, handles)
% hObject    handle to About_MU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
About_MU(hObject, eventdata, handles);

% --- Executes on button press in Slicer_checkbox.
function Slicer_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Slicer_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Slicer_checkbox


% --------------------------------------------------------------------
function ADeveloper_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to ADeveloper_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('http://www.fliu37.com', '-browser');


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Matrix_list.
function Matrix_list_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Matrix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MatrixUser_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MatrixUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse motion over figure - except title and menu.
function MatrixUser_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MatrixUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update matrix list
MU_update_list(handles);


% --- Executes on selection change in Complex_list.
function Complex_list_Callback(hObject, eventdata, handles)
% hObject    handle to Complex_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Complex_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Complex_list


% --- Executes during object creation, after setting all properties.
function Complex_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Complex_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Load_Clipboard_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Clipboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_load_clipboard(handles);


% --------------------------------------------------------------------
function Load_ScreenShot_Callback(hObject, eventdata, handles)
% hObject    handle to Load_ScreenShot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MU_load_screenshot(handles);


% --- Executes on button press in Array_show_button.
function Array_show_button_Callback(hObject, eventdata, handles)
% hObject    handle to Array_show_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents=get(handles.Matrix_list,'String');
currentMatrix=contents{get(handles.Matrix_list,'Value')};    
selected_matrix= evalin('base', [currentMatrix ';']);

if isnumeric(selected_matrix) & strcmp(class(selected_matrix),'double')
    as(selected_matrix);
    return;
end

if isstruct(selected_matrix)
    figure('Resize','off','position',[100 120 560 550],'Name',['Structure Inspection : ' currentMatrix],'MenuBar','none');
    cstr=MU_readStruct(selected_matrix);
    Struct_d=uicontrol('Style', 'listbox', 'String', '','Position', [50  20  460  510]);
    set(Struct_d,'String',cstr);
    return;
end

errordlg(['Your chosen tool currently doesn''t support analyzing ' class(selected_matrix) ' class!']);
