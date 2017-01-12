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



function varargout = MU_Matrix_Display(varargin)
% MU_MATRIX_DISPLAY MATLAB code for MU_Matrix_Display.fig
%      MU_MATRIX_DISPLAY, by itself, creates a new MU_MATRIX_DISPLAY or raises the existing
%      singleton*.
%
%      H = MU_MATRIX_DISPLAY returns the handle to a new MU_MATRIX_DISPLAY or the handle to
%      the existing singleton*.
%
%      MU_MATRIX_DISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_MATRIX_DISPLAY.M with the given input arguments.
%
%      MU_MATRIX_DISPLAY('Property','Value',...) creates a new MU_MATRIX_DISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Matrix_Display_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Matrix_Display_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_Matrix_Display

% Last Modified by GUIDE v2.5 24-Sep-2013 18:26:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Matrix_Display_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Matrix_Display_OutputFcn, ...
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


% --- Executes just before MU_Matrix_Display is made visible.
function MU_Matrix_Display_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_Matrix_Display (see VARARGIN)


global Figure_handles;

% label main figure handle
Figure_handles.MU_display=hObject;
if isfield(Figure_handles,'MU_main') % compatible with MRiLab
    MU_main_handles=guidata(Figure_handles.MU_main);
end

% find current running m-file fullpath
filepath=mfilename('fullpath');   
sep=filesep;
k=strfind(filepath, sep);
path=filepath(1:k(end)-1);
handles.path = path;

% target selected matrix
if isempty(varargin)
    contents=get(MU_main_handles.Matrix_list,'String');
    currentMatrix=contents{get(MU_main_handles.Matrix_list,'Value')};
    contents=get(MU_main_handles.Complex_list,'String');
    complexFlag=contents{get(MU_main_handles.Complex_list,'Value')};
else
    currentMatrix=varargin{1};
    complexFlag=varargin{2};
end
TMatrix= evalin('base', [currentMatrix ';']);
if ~isreal(TMatrix)
    switch complexFlag
        case 'Magnitude'
            TMatrix = abs(TMatrix);
            currentMatrix = ['abs(' currentMatrix ')'];
        case 'Phase'
            TMatrix = angle(TMatrix);
            currentMatrix = ['angle(' currentMatrix ')'];
        case 'Real'
            TMatrix = real(TMatrix);
            currentMatrix = ['real(' currentMatrix ')'];
        case 'Imaginary'
            TMatrix = imag(TMatrix);
            currentMatrix = ['imag(' currentMatrix ')'];
    end
end
% initialize display & more
handles=MU_display_initialize(hObject,handles,currentMatrix,TMatrix);
if isempty(handles)
    return;
end

handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(hObject, handles);

% UIWAIT makes MU_Matrix_Display wait for user response (see UIRESUME)
% uiwait(handles.MU_matrix_display);

% --- Outputs from this function are returned to the command line.
function varargout = MU_Matrix_Display_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on selection change in Color_map_popmenu.
function Color_map_popmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Color_map_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents=cellstr(get(hObject,'String'));
handles.V.Color_map=contents{get(hObject,'Value')};
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Color_map_popmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Color_map_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function C_upper_slider_Callback(hObject, eventdata, handles)
% hObject    handle to C_upper_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global Figure_handles;

if get(hObject,'Value')>handles.V.C_lower
    handles.V.C_upper=(get(hObject,'Value'));
else
    set(handles.C_upper_slider,'Value',handles.V.C_upper);
    return;
end

set(handles.C_upper_edit,'String',num2str(handles.V.C_upper));
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
if handles.Slicer==1
    MU_display2_handles=guidata(Figure_handles.MU_display2);
    MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function C_upper_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_upper_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function C_lower_slider_Callback(hObject, eventdata, handles)
% hObject    handle to C_lower_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global Figure_handles;

if get(hObject,'Value')<handles.V.C_upper
    handles.V.C_lower=(get(hObject,'Value'));
else
    set(handles.C_lower_slider,'Value',handles.V.C_lower);
    return;
end

set(handles.C_lower_edit,'String',num2str(handles.V.C_lower));
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
if handles.Slicer==1
    MU_display2_handles=guidata(Figure_handles.MU_display2);
    MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function C_lower_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_lower_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on scroll wheel click while the figure is in focus.
function MU_matrix_display_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'MDimension_tabgroup') | ~handles.Wheel
    return;
end

if verLessThan('matlab','8.5')
    % Code to run in MATLAB R2015a and earlier here
    i = get(handles.MDimension_tabgroup,'SelectedIndex')+2;
else
    % Code to run in MATLAB R2015a and later here
    tabtitle=get(get(handles.MDimension_tabgroup,'SelectedTab'),'Title');
    i = str2num(tabtitle(4:end)); %#ok<ST2NM>
end

if strcmp(get(handles.(['Dim' num2str(i) '_edit']),'Enable'),'off')
    return;
end
sliderValue = get(handles.(['Dim' num2str(i) '_slider']),'Value');
sliderValue = sliderValue - eventdata.VerticalScrollCount;
if sliderValue>= get(handles.(['Dim' num2str(i) '_slider']),'Min') & sliderValue<= get(handles.(['Dim' num2str(i) '_slider']),'Max')
    set(handles.(['Dim' num2str(i) '_slider']),'Value',sliderValue);
    set(handles.(['Dim' num2str(i) '_edit']),'String',sliderValue);
    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,i);
    guidata(hObject, handles);
end

% --- Executes on mouse motion over figure - except title and menu.
function MU_matrix_display_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Figure_handles;
Figure_handles.MU_display = hObject;

tpoint=get(handles.Matrix_display_axes,'currentpoint');
x=round(tpoint(1));
y=round(tpoint(3));

try % avoid matlab system callback error
    z=handles.V.Slice;
catch me
    return;
end

handles.V.DimPointer(1)=y;
handles.V.DimPointer(2)=x;
if x>0 & y>0 & x<=handles.V.Column & y<=handles.V.Row
    
    if isempty(handles.V2.Foreground_matrix) % update coordinate
        eval(['value=handles.TMatrix' '(' num2str(handles.V.DimPointer(1)) num2str(handles.V.DimPointer(2:end),',%u') ');']);
        set(handles.Coordinate_text,'String',['Coordinate=[' num2str(handles.V.DimPointer(1)) num2str(handles.V.DimPointer(2:end), ',%u') '] Value=' num2str(value)]);
    else
        eval(['value=handles.TMatrix' '(' num2str(handles.V.DimPointer(1)) num2str(handles.V.DimPointer(2:end),',%u') ');']);
        eval(['value2=handles.Mask' '(' num2str(handles.V.DimPointer(1)) num2str(handles.V.DimPointer(2:min(3,numel(handles.V.DimSize))),',%u') ');']);
        set(handles.Coordinate_text,'String',['Coordinate=[' num2str(handles.V.DimPointer(1)) num2str(handles.V.DimPointer(2:end), ',%u') '] Background=' num2str(value) ' Foreground=' num2str(value2)]);
    end
    % update kinetic curve when Localizer is unmoved and ROI function is unused
    if ~isempty(handles.KHandle) & handles.KFlag
        for i=1:numel(handles.KHandle)
            CurvePointer = handles.V.DimPointer;
            CurvePointer(handles.KDim(i)) = -1;
            CurvePointer = num2str(CurvePointer,',%d');
            CurvePointer = strrep(CurvePointer, '-1', ':');
            eval(['handles.KCurve{i}=squeeze(handles.TMatrix(' CurvePointer(2:end) '));']);
            refreshdata(handles.KHandle(i),'caller');
            drawnow;
        end
    end
    % update magnifier if possible
    if ~isempty(handles.MHandle) & ishandle(handles.MHandle)
        handles.MMatrix = handles.MPad;
        handles.MMatrix(max(1,handles.MSize/2+1-y):min(handles.MSize/2+handles.V.Row-y,handles.MSize),max(1,handles.MSize/2+1-x):min(handles.MSize/2+handles.V.Column-x,handles.MSize)) = ...
                        handles.BMatrix(max(1,y-handles.MSize/2+1):min(handles.V.Row,y+handles.MSize/2),max(1,x-handles.MSize/2+1):min(handles.V.Column,x+handles.MSize/2));
        set(handles.MHandle,'CData',handles.MMatrix);
        set(get(handles.MHandle,'Parent'),'CLim',[handles.V.C_lower handles.V.C_upper]);
        colormap(get(handles.MHandle,'Parent'),handles.V.Color_map);
        drawnow;
    end
end
handles.V.Xlim=get(handles.Matrix_display_axes,'XLim');
handles.V.Ylim=get(handles.Matrix_display_axes,'YLim');
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MU_matrix_display_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tpoint=get(handles.Matrix_display_axes,'currentpoint');
x=round(tpoint(1));
y=round(tpoint(3));
handles.V.ROI.ROI_mov(end+1,:)=[x,y];
handles.V.Localizer.Local_flag=1;
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MU_matrix_display_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Figure_handles;

tpoint=get(handles.Matrix_display_axes,'currentpoint');
x=round(tpoint(1));
y=round(tpoint(3));
handles.V.ROI.ROI_mov(end+1,:)=[x,y];

if strcmp('alt',get(gcbf, 'SelectionType'))
    if handles.KFlag==1
        handles.KFlag=0;
        warndlg('Disable live dimension profile inspection.');
    else
        handles.KFlag=1;
        warndlg('Enable live dimension profile inspection.');
    end
end
    
if handles.V.Localizer.Local_flag==1 & handles.V.Localizer.Local_switch==1 & sum(abs(handles.V.ROI.ROI_mov(end-1,:)-[x,y]))==0 %updata Localizer
    set(gcf,'CurrentAxes',handles.Matrix_display_axes);
    if isempty(handles.V.Localizer.Local_h1)
            handles.V.Localizer.Local_h1=line([x x],[1 handles.V.Row],'Color','y');
            handles.V.Localizer.Local_h2=line([1 handles.V.Column],[y y],'Color','r');
    end
    set(handles.V.Localizer.Local_h1,'XData',[x x],'YData',[1 handles.V.Row]);
    set(handles.V.Localizer.Local_h2,'XData',[1 handles.V.Column],'YData',[y y]);
    handles.V.Localizer.Local_point=[x y];
    handles.V.Localizer.Local_flag=0;
    if handles.Slicer==1
        MU_display2_handles=guidata(Figure_handles.MU_display2);
        MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
    end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function Save_image_button_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Save_image_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
MU_save_image(handles.Matrix_display_axes);


% --- Executes when user attempts to close MU_matrix_display.
function MU_matrix_display_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

delete(hObject);

% --- Executes on button press in Upload_pushbutton.
function Upload_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Upload_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_uploadTmp(handles);

% MU_setting_windows(4,handles); % (old method)

% --- Executes on button press in MatrixCalc_pushbutton.
function MatrixCalc_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MatrixCalc_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_calc_matrix(handles);


function C_upper_edit_Callback(hObject, eventdata, handles)
% hObject    handle to C_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C_upper_edit as text
%        str2double(get(hObject,'String')) returns contents of C_upper_edit as a double

global Figure_handles;

try
    C_upper=str2double(get(hObject,'String'));
    if C_upper>get(handles.C_lower_slider,'Value')
        set(handles.C_upper_slider,'Max',C_upper);
        set(handles.C_upper_slider,'Value',C_upper);
    else
        set(handles.C_upper_edit,'String',num2str(get(handles.C_upper_slider,'Value')));
    end
    
    handles.V.C_upper=get(handles.C_upper_slider,'Value');
    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
    if handles.Slicer==1
        MU_display2_handles=guidata(Figure_handles.MU_display2);
        MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
    end
catch me
end
guidata(hObject, handles);



function C_lower_edit_Callback(hObject, eventdata, handles)
% hObject    handle to C_lower_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of C_lower_edit as text
%        str2double(get(hObject,'String')) returns contents of C_lower_edit as a double

global Figure_handles;

try
    C_lower=str2double(get(hObject,'String'));
    if C_lower<get(handles.C_upper_slider,'Value')
        set(handles.C_lower_slider,'Min',C_lower);
        set(handles.C_lower_slider,'Value',C_lower);
    else
        set(handles.C_lower_edit,'String',num2str(get(handles.C_lower_slider,'Value')));
    end
    
    handles.V.C_lower=get(handles.C_lower_slider,'Value');
    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
    if handles.Slicer==1
        MU_display2_handles=guidata(Figure_handles.MU_display2);
        MU_update_ass_image({MU_display2_handles.Matrix_display_axes2,MU_display2_handles.Matrix_display_axes3},{handles.SMatrix,handles.CMatrix},handles);
    end
catch me
end
guidata(hObject, handles);


% --- Executes on key press with focus on MU_matrix_display and none of its controls.
function MU_matrix_display_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on MU_matrix_display or any of its controls.
function MU_matrix_display_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to MU_matrix_display (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

