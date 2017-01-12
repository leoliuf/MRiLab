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



function varargout = MU_3D_Render(varargin)
% MU_THD_RENDER MATLAB code for MU_3D_Render.fig
%      MU_THD_RENDER, by itself, creates a new MU_THD_RENDER or raises the existing
%      singleton*.
%
%      H = MU_THD_RENDER returns the handle to a new MU_THD_RENDER or the handle to
%      the existing singleton*.
%
%      MU_THD_RENDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_THD_RENDER.M with the given input arguments.
%
%      MU_THD_RENDER('Property','Value',...) creates a new MU_THD_RENDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_3D_Render_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_3D_Render_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_3D_Render

% Last Modified by GUIDE v2.5 29-Sep-2013 13:06:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_3D_Render_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_3D_Render_OutputFcn, ...
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


% --- Executes just before MU_3D_Render is made visible.
function MU_3D_Render_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_3D_Render (see VARARGIN)

handles.main_h=varargin{1};
TMatrix=handles.main_h.TMatrix;

try
    
f = inputdlg('Please specify matrix aspect ratio in three dimensions [x y z].','Aspect Ratio',1,{'[1 1 1]'});
if isempty(f)
    error('3D rendering is cancelled.');
end
eval(['f =' f{1} ';']);
AspR = f;
    
if numel(TMatrix)>100000
    f = inputdlg('Reducing matrix volume produces faster rendering, please specify sample voxel interval in three dimensions [x y z].','Reduce Volume',1,{'[4 4 4]'});
    if isempty(f)
        error('3D rendering is cancelled.');
    end
    eval(['fsize =' f{1} ';']);
    TMatrix = reducevolume(TMatrix,fsize);
end

[Smooth,ok] = listdlg('ListString',{'3D Box smooth','3D Gaussian smooth','No smooth'}, ...
                    'SelectionMode','single',...
                    'PromptString','Perform smoothing for matrix?',... 
                    'Name','Smooth');
if ok==0
   error('3D rendering is cancelled.');
end

switch Smooth
    case 1
        f = inputdlg({'Filter size:'},'3D Box Smooth',1,{'[3 3 3]'});
        if isempty(f)
        error('3D rendering is cancelled.');
        end
        eval(['fsize =' f{1} ';']);
        TMatrix = smooth3(TMatrix,'box', fsize);
    case 2
        f = inputdlg({'Filter size:','Gaussian standard deviation:'},'3D Gaussian Smooth',1,{'[3 3 3]','0.65'});
        if isempty(f)
        error('3D rendering is cancelled.');
        end
        eval(['fsize =' f{1} ';']);
        TMatrix = smooth3(TMatrix, 'gaussian', fsize, str2double(f{2}));
end


[f,ok] = listdlg('ListString',{'OpenGL','zbuffer','painters'}, ...
                    'SelectionMode','single',...
                    'PromptString',{'Choose renderer', 'painters: Matlab default', 'zbuffer: faster', 'OpenGL: fastest'}, ...
                    'Name','Renderer');
if ok==0
   error('3D rendering is cancelled.');
end

switch f
    case 1
        renderer = 'OpenGL';
    case 2
        renderer = 'zbuffer';
    case 3
        renderer = 'painters';
end

catch me
    error_msg{1,1}='3D rendering preprocessing failed. Input information is invalid.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    delete(hObject);
    return;
end

pause(0.1);
%-----------------------------Pre-process for matrix
TMatrix(isnan(TMatrix))=0;
TMatrix(isinf(TMatrix))=0;
Max_D=max(TMatrix(:));
Min_D=min(TMatrix(:));
[row,col,layer]=size(TMatrix);

%-----------------------------Initialization for variables
V=struct(...
        'Layer',layer,...
        'Row',row,...
        'Column',col,...
        'Max_D',Max_D,...
        'Min_D',Min_D,...
        'Show_threshold',Min_D+(Max_D-Min_D)*0.3,...
        'Show_opacity',1,...
        'Show_connectivity',1,...
        'Viewpoint',[-36 50],...
        'AspectRatio',AspR,...
        'Color_map',handles.main_h.V.Color_map,...
        'FaceColor','red',...
        'BoxFlag','on',...
        'PatchPercent',1, ...
        'ConnectFlag',0, ...
        'Renderer',renderer ...
        );
%-----------------------------End

%------------------------------------------Volume Check
L=zeros(size(TMatrix));
L(TMatrix>=Min_D)=1;

[L,num]=bwlabeln(L);
idxSize=zeros(num,1);
for i=1:num
    idx=find(L==i);
    idxSize(i)=length(idx);
    if length(idx)>=V.Show_connectivity
        L(idx)=1;
    else
        L(idx)=0;
    end
    MU_update_waitbar(handles.Progress_axes,i,num);
end
largest=max(idxSize);
handles.idxMask=L.*TMatrix;
handles.idxSize=idxSize;
%------------------------------------------End
%-----------------------------Initialization for figure
handles.V=V;
handles.TMatrix=TMatrix;
handles.output=hObject;

MergeM=get(handles.main_h.Matrix_name_edit,'String');
set(handles.Matrix_name_text,'String',MergeM);
set(handles.Connectivity_slider,'Min',1);
set(handles.Connectivity_slider,'Max',largest-1);
set(handles.Connectivity_slider,'Value',V.Show_connectivity);
set(handles.Connectivity_text,'String',['>=' num2str(V.Show_connectivity)]);

set(handles.Threshold_slider,'Min',Min_D+(Max_D-Min_D)*0.00001);
set(handles.Threshold_slider,'Max',Max_D-(Max_D-Min_D)*0.00001);
set(handles.Threshold_slider,'Value',V.Show_threshold);
set(handles.Threshold_text,'String',['>=' num2str(V.Show_threshold)]);

set(handles.Opacity_slider,'Min',0.01);
set(handles.Opacity_slider,'Max',1);
set(handles.Opacity_slider,'Value',V.Show_opacity);
set(handles.Opacity_text,'String',['=' num2str(V.Show_opacity)]);

set(handles.Color_map_popmenu,'Value',get(handles.main_h.Color_map_popmenu,'Value'));
set(gcf,'Renderer',renderer);

MU_update_3D_render(handles.Matrix_render_axes,handles,1);

cameratoolbar(gcf);
handles=guidata(hObject);
guidata(hObject, handles);
%-----------------------------End



% --- Outputs from this function are returned to the command line.
function varargout = MU_3D_Render_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on slider movement.
function Connectivity_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Connectivity_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
handles.V.Show_connectivity=round(get(hObject,'Value'));
set(handles.Connectivity_text,'String',['>=' num2str(handles.V.Show_connectivity)]);
MU_update_3D_render(handles.Matrix_render_axes,handles,1);
handles=guidata(hObject);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function Connectivity_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Connectivity_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Threshold_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
handles.V.Show_threshold=get(hObject,'Value');
set(handles.Threshold_text,'String',['>=' num2str(handles.V.Show_threshold)]);
MU_update_3D_render(handles.Matrix_render_axes,handles,1);
handles=guidata(hObject);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Threshold_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Opacity_slider_Callback(hObject, eventdata, handles)
% hObject    handle to Opacity_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
handles.V.Show_opacity=get(hObject,'Value');
set(handles.Opacity_text,'String',['=' num2str(handles.V.Show_opacity)]);
alpha(handles.V.Show_opacity);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Opacity_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Opacity_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function Save_image_button_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Save_image_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

MU_save_image(handles.Matrix_render_axes);


% --- Executes on mouse motion over figure - except title and menu.
function MU_3D_render_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MU_3D_render (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% figure(handles.MU_3D_render); %Turn to this figure;
% point=get(gca,'currentpoint');
% pointfront=round(point(1,:));
% x=round(pointfront(1));
% y=round(pointfront(2));
% z=round(pointfront(3));
% if x>0 & y>0 & z>0 & x<=handles.V.Column & y<=handles.V.Row & z<=handles.V.Layer
%     coordinate=['x: ' num2str(x) '  y: ' num2str(y) '  z: ' num2str(z) '  Value: ' num2str(handles.TMatrix(y,x,z))];
%     set(handles.Coordinate_text,'String',coordinate);
% end


% --- Executes on selection change in Color_map_popmenu.
function Color_map_popmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Color_map_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
contents=cellstr(get(hObject,'String'));
handles.V.Color_map=contents{get(hObject,'Value')};
MU_update_3D_render(handles.Matrix_render_axes,handles,2);
handles=guidata(hObject);
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


% --- Executes on button press in SurfaceColor_pushbutton.
function SurfaceColor_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SurfaceColor_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
FaceColorList ={'interp','red','[1,.75,.65]','[0.9961,0.7333,0.2118]','green','blue','yellow','cyan','magenta'};
handles.V.FaceColor = FaceColorList{mod(find(strcmp(handles.V.FaceColor,FaceColorList)==1),length(FaceColorList))+1};
MU_update_3D_render(handles.Matrix_render_axes,handles,3);
handles=guidata(hObject);
guidata(hObject, handles);


% --- Executes on button press in RedPatch_pushbutton.
function RedPatch_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RedPatch_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
handles.V.PatchPercent=max(0.1,handles.V.PatchPercent-0.2);
MU_update_3D_render(handles.Matrix_render_axes,handles,0);
handles=guidata(hObject);
guidata(hObject, handles);


% --- Executes on button press in AddPatch_pushbutton.
function AddPatch_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddPatch_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
handles.V.PatchPercent=min(1,handles.V.PatchPercent+0.2);
MU_update_3D_render(handles.Matrix_render_axes,handles,0);
handles=guidata(hObject);
guidata(hObject, handles);


% --- Executes on button press in Connectivity_togglebutton.
function Connectivity_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Connectivity_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Connectivity_togglebutton

handles.V.ConnectFlag = ~handles.V.ConnectFlag;
if handles.V.ConnectFlag
    set(handles.Connectivity_slider,'Enable','on');
    MU_update_3D_render(handles.Matrix_render_axes,handles,1);
    handles=guidata(hObject);
else
    set(handles.Connectivity_slider,'Enable','off');
end
guidata(hObject, handles);


% --- Executes on button press in ShowBox_pushbutton.
function ShowBox_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ShowBox_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el]=view;
handles.V.Viewpoint=[az,el];
if strcmp(handles.V.BoxFlag,'on')
    handles.V.BoxFlag='off';
else
    handles.V.BoxFlag='on';
end
MU_update_3D_render(handles.Matrix_render_axes,handles,4);
handles=guidata(hObject);
guidata(hObject, handles);
