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




function varargout = MU_ROI_Manage(varargin)
% MU_ROI_MANAGE MATLAB code for MU_ROI_Manage.fig
%      MU_ROI_MANAGE, by itself, creates a new MU_ROI_MANAGE or raises the existing
%      singleton*.
%
%      H = MU_ROI_MANAGE returns the handle to a new MU_ROI_MANAGE or the handle to
%      the existing singleton*.
%
%      MU_ROI_MANAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_ROI_MANAGE.M with the given input arguments.
%
%      MU_ROI_MANAGE('Property','Value',...) creates a new MU_ROI_MANAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_ROI_Manage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_ROI_Manage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_ROI_Manage

% Last Modified by GUIDE v2.5 22-Sep-2013 19:53:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_ROI_Manage_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_ROI_Manage_OutputFcn, ...
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


% --- Executes just before MU_ROI_Manage is made visible.
function MU_ROI_Manage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_ROI_Manage (see VARARGIN)

global Figure_handles;
MU_main_handles=guidata(Figure_handles.MU_main);

set(handles.ROI_uitable,'Data',MU_main_handles.V.ROIs(:,1));
set(handles.Show_pushbutton,'Enable','off');

% Choose default command line output for MU_ROI_Manage
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_ROI_Manage wait for user response (see UIRESUME)
% uiwait(handles.MU_roi_manage_figure);


% --- Outputs from this function are returned to the command line.
function varargout = MU_ROI_Manage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Show_pushbutton.
function Show_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Show_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Figure_handles;
MU_main_handles=guidata(Figure_handles.MU_main);
main_h=guidata(Figure_handles.MU_display);

if strcmp(MU_main_handles.V.ROIs{handles.ROIInd,1},'imfreehand')
    oper = 'impoly';
else
    oper = MU_main_handles.V.ROIs{handles.ROIInd,1};
end

eval(['ROI_h=' oper '(main_h.Matrix_display_axes,MU_main_handles.V.ROIs{handles.ROIInd,3});']);
p=round(getPosition(ROI_h));
p2=getPosition(ROI_h);

BW=createMask(ROI_h);
axes(main_h.Matrix_display_axes);

if strcmp(oper,'impoly')
    p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
    p2=[min(p2(:,1)) min(p2(:,2)) max(p2(:,1))-min(p2(:,1)) max(p2(:,2))-min(p2(:,2))];
end
try
    TTMatrix=main_h.BMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3));
    TTMatrix=TTMatrix(double(BW(p(2):p(2)+p(4),p(1):p(1)+p(3)))~=0);
catch me
    delete(ROI_h);
    errordlg('Selected ROI exceeds current matrix dimension.');
    return;
end
ROI_Stat_h=text(p(1)+p(3),p(2)+p(4),{[' ROI#: ' num2str(handles.ROIInd) ' copy']; ...
                                     [' mean: ' num2str(mean(double(TTMatrix(:))))]; ...
                                     [' sd:' num2str(std(double(TTMatrix(:))))]; ...
                                     [' sd(%):' num2str(abs(std(double(TTMatrix(:)))./mean(double(TTMatrix(:)))*100))]},...
                                     'FontSize',10,'Color','r');
main_h.ROIData=TTMatrix;
guidata(Figure_handles.MU_display,main_h);

if strcmp(oper,'impoly')
    setVerticesDraggable(ROI_h,0);
else
    setResizable(ROI_h,0);
end
fcn=makeConstrainToRectFcn(oper,[p2(1) p2(1)+p2(3)],[p2(2) p2(2)+p2(4)]);
setPositionConstraintFcn(ROI_h,fcn);
guidata(hObject, handles);

% --- Executes when entered data in editable cell(s) in ROI_uitable.
function ROI_uitable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to ROI_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in ROI_uitable.
function ROI_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to ROI_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
% Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata.Indices)
    return;
end

global Figure_handles;
MU_main_handles=guidata(Figure_handles.MU_main);
main_h=guidata(Figure_handles.MU_display);

handles.ROIInd=eventdata.Indices(1);
Pos=MU_main_handles.V.ROIs{handles.ROIInd,3};
axes(main_h.Matrix_display_axes);
text(Pos(1,1),Pos(1,2),num2str(handles.ROIInd),'Color','r','FontSize',18);

set(handles.Show_pushbutton,'Enable','on');
    
guidata(hObject, handles);


% --- Executes on mouse motion over figure - except title and menu.
function MU_roi_manage_figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MU_roi_manage_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Figure_handles;

if ~isfield(Figure_handles,'MU_main');
    close(hObject);
    return;
end
MU_main_handles=guidata(Figure_handles.MU_main);
set(handles.ROI_uitable,'Data',MU_main_handles.V.ROIs(:,1));
guidata(hObject, handles);


% --------------------------------------------------------------------
function ROI_uitable_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ROI_uitable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
