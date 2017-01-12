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



function varargout = MU_Plot(varargin)
% MU_PLOT MATLAB code for MU_Plot.fig
%      MU_PLOT, by itself, creates a new MU_PLOT or raises the existing
%      singleton*.
%
%      H = MU_PLOT returns the handle to a new MU_PLOT or the handle to
%      the existing singleton*.
%
%      MU_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_PLOT.M with the given input arguments.
%
%      MU_PLOT('Property','Value',...) creates a new MU_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_Plot

% Last Modified by GUIDE v2.5 24-Sep-2013 12:14:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Plot_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Plot_OutputFcn, ...
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

% --- Executes just before MU_Plot is made visible.
function MU_Plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_Plot (see VARARGIN)

% Choose default command line output for MU_Plot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_Plot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MU_Plot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Keep_pushbutton.
function Keep_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Keep_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on button press in Copy_pushbutton.
function Copy_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Copy_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataObjs = findobj(handles.Plot_axes,'Type','line');
xdata = get(dataObjs, 'XData'); %data from low-level grahics objects
ydata = get(dataObjs, 'YData');

clipboard('copy', [xdata(:), ydata(:)]);


% --- Executes on button press in List_pushbutton.
function List_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to List_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=figure('Resize','off','position',[100 120 200 550],'Name','Voxel List','MenuBar','none');

dataObjs = findobj(handles.Plot_axes,'Type','line');
xdata = get(dataObjs, 'XData'); %data from low-level grahics objects
ydata = get(dataObjs, 'YData');

uitable('Parent',h,'Data',[xdata(:), ydata(:)],'ColumnName',{'X-Data','Y-Data'},'RowName',[],... 
        'Position',[5  10  195  530]);

% --- Executes on button press in Save_pushbutton.
function Save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataObjs = findobj(handles.Plot_axes,'Type','line');
xdata = get(dataObjs, 'XData'); %data from low-level grahics objects
ydata = get(dataObjs, 'YData');

try
    Flag = MU_load_matrix('data_plt', [xdata(:), ydata(:)], 0);
catch me
    error_msg{1,1}='ERROR!!! Saving plot data aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end
