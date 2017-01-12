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




function varargout = MU_Seg_Edit(varargin)
% MU_SEG_EDIT MATLAB code for MU_Seg_Edit.fig
%      MU_SEG_EDIT, by itself, creates a new MU_SEG_EDIT or raises the existing
%      singleton*.
%
%      H = MU_SEG_EDIT returns the handle to a new MU_SEG_EDIT or the handle to
%      the existing singleton*.
%
%      MU_SEG_EDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_SEG_EDIT.M with the given input arguments.
%
%      MU_SEG_EDIT('Property','Value',...) creates a new MU_SEG_EDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Seg_Edit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Seg_Edit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_Seg_Edit

% Last Modified by GUIDE v2.5 22-Sep-2013 01:30:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Seg_Edit_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Seg_Edit_OutputFcn, ...
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


% --- Executes just before MU_Seg_Edit is made visible.
function MU_Seg_Edit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_Seg_Edit (see VARARGIN)

handles.main_h=varargin{1};
set(handles.Seg_uitable,'Data',handles.main_h.V.Segs(:,1:3));

set(handles.Edit_pushbutton,'Enable','off');
set(handles.Update_pushbutton,'Enable','off');

% Choose default command line output for MU_Seg_Edit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_Seg_Edit wait for user response (see UIRESUME)
% uiwait(handles.MU_seg_edit_figure);


% --- Outputs from this function are returned to the command line.
function varargout = MU_Seg_Edit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Edit_pushbutton.
function Edit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.main_h=guidata(handles.main_h.MU_matrix_display);
if handles.main_h.V.Segs{handles.SegInd,2}~=handles.main_h.V.Slice
    return;
end

set(handles.Update_pushbutton,'Enable','on');
set(handles.Edit_pushbutton,'Enable','off');
MU_enable('off',[],handles.main_h);
handles.main_h=guidata(handles.main_h.MU_matrix_display);

eval(['handles.ROI_h=' handles.main_h.V.Segs{handles.SegInd,1} '(handles.main_h.Matrix_display_axes,handles.main_h.V.Segs{handles.SegInd,4});']);
Temp=handles.main_h.Mask(:,:,handles.main_h.V.Slice);
BW=createMask(handles.ROI_h);
Temp(BW~=0)=0;
handles.main_h.Mask(:,:,handles.main_h.V.Slice)=Temp;
    
guidata(hObject, handles);
guidata(handles.main_h.MU_matrix_display,handles.main_h);

% --- Executes on button press in Update_pushbutton.
function Update_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Update_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.main_h=guidata(handles.main_h.MU_matrix_display);
if handles.main_h.V.Segs{handles.SegInd,2}~=handles.main_h.V.Slice
    return;
end

set(handles.Update_pushbutton,'Enable','off');
MU_enable('on',[],handles.main_h);
handles.main_h=guidata(handles.main_h.MU_matrix_display);

Data=get(handles.Seg_uitable,'Data');

%deselect uitable ?? dirty code
set(handles.Seg_uitable, 'Data', []);
set(handles.Seg_uitable, 'Data', Data);

Temp=handles.main_h.Mask(:,:,handles.main_h.V.Slice);
BW=createMask(handles.ROI_h);
handles.main_h.V.Segs{handles.SegInd,3}=max(0,Data{handles.SegInd,3});
handles.main_h.V.Segs{handles.SegInd,4}=getPosition(handles.ROI_h);
Temp(BW~=0)=max(0,Data{handles.SegInd,3});

handles.main_h.Mask(:,:,handles.main_h.V.Slice)=Temp;
handles.main_h=MU_update_image(handles.main_h.Matrix_display_axes,{handles.main_h.TMatrix,handles.main_h.Mask},handles.main_h,0);
guidata(hObject, handles);
guidata(handles.main_h.MU_matrix_display,handles.main_h);

% --- Executes when entered data in editable cell(s) in Seg_uitable.
function Seg_uitable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Seg_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in Seg_uitable.
function Seg_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Seg_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
% Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if isempty(eventdata.Indices)
    return;
end

handles.main_h=guidata(handles.main_h.MU_matrix_display);
handles.SegInd=eventdata.Indices(1);
if handles.main_h.V.Segs{handles.SegInd,2}~=handles.main_h.V.Slice
    guidata(hObject, handles);
    return;
end

if eventdata.Indices(2)==1
    Pos=handles.main_h.V.Segs{handles.SegInd,4};
    axes(handles.main_h.Matrix_display_axes);
    text(Pos(1,1),Pos(1,2),num2str(handles.SegInd),'Color','r','FontSize',18);
end

if strcmp(get(handles.Update_pushbutton,'Enable'),'off')
    set(handles.Edit_pushbutton,'Enable','on');
end

guidata(hObject, handles);


% --- Executes on mouse motion over figure - except title and menu.
function MU_seg_edit_figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MU_seg_edit_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~ishandle(handles.main_h.MU_matrix_display);
    close(hObject);
    return;
end

handles.main_h=guidata(handles.main_h.MU_matrix_display);
Data=get(handles.Seg_uitable,'Data');
if length(handles.main_h.V.Segs(:,3)) > length(Data(:,3))
    Data(end+1,3)={1};
end
set(handles.Seg_uitable,'Data',[handles.main_h.V.Segs(:,1:2) Data(:,3)]);
guidata(hObject, handles);
