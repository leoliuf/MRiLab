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



function varargout = MU_Matrix_Display_3Plane(varargin)
% MU_MATRIX_DISPLAY_3PLANE M-file for MU_Matrix_Display_3Plane.fig
%      MU_MATRIX_DISPLAY_3PLANE, by itself, creates a new MU_MATRIX_DISPLAY_3PLANE or raises the existing
%      singleton*.
%
%      H = MU_MATRIX_DISPLAY_3PLANE returns the handle to a new MU_MATRIX_DISPLAY_3PLANE or the handle to
%      the existing singleton*.
%
%      MU_MATRIX_DISPLAY_3PLANE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_MATRIX_DISPLAY_3PLANE.M with the given input arguments.
%
%      MU_MATRIX_DISPLAY_3PLANE('Property','Value',...) creates a new MU_MATRIX_DISPLAY_3PLANE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Matrix_Display_3Plane_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Matrix_Display_3Plane_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_Matrix_Display_3Plane

% Last Modified by GUIDE v2.5 20-Sep-2013 16:08:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Matrix_Display_3Plane_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Matrix_Display_3Plane_OutputFcn, ...
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


% --- Executes just before MU_Matrix_Display_3Plane is made visible.
function MU_Matrix_Display_3Plane_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_Matrix_Display_3Plane (see VARARGIN)
global Figure_handles;

Figure_handles.MU_display2=hObject;
filepath=mfilename('fullpath');   % find current running m-file fullpath
sep=filesep;
k=strfind(filepath, sep);
path=filepath(1:k(end)-1);

MU_icon(handles.Sag2Main_pushbutton,[path sep '..' sep '..' sep 'Resource' sep 'Icon' sep 'Exchange.gif']);
MU_icon(handles.Cor2Main_pushbutton,[path sep '..' sep '..' sep 'Resource' sep 'Icon' sep 'Exchange.gif']);

% Choose default command line output for MU_Matrix_Display_3Plane
handles.Parent = Figure_handles.MU_display;
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_Matrix_Display_3Plane wait for user response (see UIRESUME)
% uiwait(MU_display_handles.MU_matrix_display_3Plane);


% --- Outputs from this function are returned to the command line.
function varargout = MU_Matrix_Display_3Plane_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SMatrix_pushbutton.
function SMatrix_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SMatrix_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_display_handles=guidata(handles.Parent);
if MU_display_handles.V.Localizer.Local_switch==0;
    MU_display_handles.V.Localizer.Local_switch=1;
    MU_display_handles=MU_update_image(MU_display_handles.Matrix_display_axes,{MU_display_handles.TMatrix,MU_display_handles.Mask},MU_display_handles,0);
else
    MU_display_handles.V.Localizer.Local_switch=0;
    delete(MU_display_handles.V.Localizer.Local_h1);
    delete(MU_display_handles.V.Localizer.Local_h2);
end
guidata(handles.Parent, MU_display_handles);


% --- Executes on button press in CMatrix_pushbutton.
function CMatrix_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CMatrix_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_display_handles=guidata(handles.Parent);
if MU_display_handles.V.Localizer.Local_switch==0;
    MU_display_handles.V.Localizer.Local_switch=1;
    MU_display_handles=MU_update_image(MU_display_handles.Matrix_display_axes,{MU_display_handles.TMatrix,MU_display_handles.Mask},MU_display_handles,0);
else
    MU_display_handles.V.Localizer.Local_switch=0;
    delete(MU_display_handles.V.Localizer.Local_h1);
    delete(MU_display_handles.V.Localizer.Local_h2);
end
guidata(handles.Parent, MU_display_handles);

% --- Executes on button press in Sag2Main_pushbutton.
function Sag2Main_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Sag2Main_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_display_handles=guidata(handles.Parent);

% initialize MU_display & more
MergeM=get(MU_display_handles.Matrix_name_edit,'String');
MU_display_new_handles=MU_display_initialize(MU_display_handles.MU_matrix_display, ...
                                             MU_display_handles,[MergeM '_s2m'], ...
                                             MU_display_handles.SMatrix);
if isempty(MU_display_new_handles)
    return;
end

MU_display_new_handles.Mask=permute(MU_display_handles.Mask,[3 1 2]);
MU_display_new_handles.SMatrix=permute(MU_display_handles.SMatrix,[3 1 2]); % Sagittal Matrix
MU_display_new_handles.CMatrix=permute(MU_display_handles.SMatrix,[3 2 1]); % Coronal Matrix
MU_display_new_handles.Slicer=1;
MU_display_new_handles.V.Localizer=MU_display_handles.V.Localizer;
MU_display_new_handles.V.Localizer.Local_point=[ceil(MU_display_new_handles.V.DimSize(2)/2) ...
                                                ceil(MU_display_new_handles.V.DimSize(1)/2)];

MU_display_new_handles=MU_update_image(MU_display_new_handles.Matrix_display_axes, ...
                                      {MU_display_new_handles.TMatrix,MU_display_new_handles.Mask},...
                                       MU_display_new_handles,0);
cla(handles.Matrix_display_axes2);
cla(handles.Matrix_display_axes3);
MU_update_ass_image({handles.Matrix_display_axes2,handles.Matrix_display_axes3}, ...
                    {MU_display_new_handles.SMatrix,MU_display_new_handles.CMatrix}, ...
                    MU_display_new_handles);

guidata(handles.Parent, MU_display_new_handles);


% --- Executes on button press in Cor2Main_pushbutton.
function Cor2Main_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cor2Main_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_display_handles=guidata(handles.Parent);

% initialize MU_display & more
MergeM=get(MU_display_handles.Matrix_name_edit,'String');
MU_display_new_handles=MU_display_initialize(MU_display_handles.MU_matrix_display, ...
                                             MU_display_handles,[MergeM '_c2m'], ...
                                             MU_display_handles.CMatrix);
if isempty(MU_display_new_handles)
    return;
end

MU_display_new_handles.Mask=permute(MU_display_handles.Mask,[3 2 1]);
MU_display_new_handles.SMatrix=permute(MU_display_handles.CMatrix,[3 1 2]); % Sagittal Matrix
MU_display_new_handles.CMatrix=permute(MU_display_handles.CMatrix,[3 2 1]); % Coronal Matrix
MU_display_new_handles.Slicer=1;
MU_display_new_handles.V.Localizer=MU_display_handles.V.Localizer;
MU_display_new_handles.V.Localizer.Local_point=[ceil(MU_display_new_handles.V.DimSize(2)/2) ...
                                                ceil(MU_display_new_handles.V.DimSize(1)/2)];

MU_display_new_handles=MU_update_image(MU_display_new_handles.Matrix_display_axes, ...
                                      {MU_display_new_handles.TMatrix,MU_display_new_handles.Mask},...
                                       MU_display_new_handles,0);
cla(handles.Matrix_display_axes2);
cla(handles.Matrix_display_axes3);
MU_update_ass_image({handles.Matrix_display_axes2,handles.Matrix_display_axes3}, ...
                    {MU_display_new_handles.SMatrix,MU_display_new_handles.CMatrix}, ...
                    MU_display_new_handles);

guidata(handles.Parent, MU_display_new_handles);


% --- Executes when user attempts to close MU_matrix_display_3Plane.
function MU_matrix_display_3Plane_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display_3Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Figure_handles
Figure_handles=rmfield(Figure_handles,'MU_display2');

if ~ishandle(handles.Parent)
    delete(hObject);
    return;
end
MU_display_handles=guidata(handles.Parent);
MU_display_handles.V.Localizer.Local_switch=0;
MU_display_handles.Slicer=0;
MU_display_handles=rmfield(MU_display_handles,'SMatrix');
MU_display_handles=rmfield(MU_display_handles,'CMatrix');

try
    delete(MU_display_handles.V.Localizer.Local_h1);
    delete(MU_display_handles.V.Localizer.Local_h2);
catch me
end
set(MU_display_handles.MatrixCalc_pushbutton,'Enable','on'); % enable matrix calculation when slicer if off
guidata(handles.Parent, MU_display_handles);

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on mouse motion over figure - except title and menu.
function MU_matrix_display_3Plane_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display_3Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~ishandle(handles.Parent)
    delete(hObject);
end


% --- Executes during object deletion, before destroying properties.
function MU_matrix_display_3Plane_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display_3Plane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
