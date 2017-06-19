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




function varargout = MU_Load_DICOM_File_Batch(varargin)
% MU_LOAD_DICOM_FILE_BATCH MATLAB code for MU_Load_DICOM_File_Batch.fig
%      MU_LOAD_DICOM_FILE_BATCH, by itself, creates a new MU_LOAD_DICOM_FILE_BATCH or raises the existing
%      singleton*.
%
%      H = MU_LOAD_DICOM_FILE_BATCH returns the handle to a new MU_LOAD_DICOM_FILE_BATCH or the handle to
%      the existing singleton*.
%
%      MU_LOAD_DICOM_FILE_BATCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MU_LOAD_DICOM_FILE_BATCH.M with the given input arguments.
%
%      MU_LOAD_DICOM_FILE_BATCH('Property','Value',...) creates a new MU_LOAD_DICOM_FILE_BATCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MU_Load_DICOM_File_Batch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MU_Load_DICOM_File_Batch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MU_Load_DICOM_File_Batch

% Last Modified by GUIDE v2.5 09-Apr-2011 20:02:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MU_Load_DICOM_File_Batch_OpeningFcn, ...
                   'gui_OutputFcn',  @MU_Load_DICOM_File_Batch_OutputFcn, ...
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


% --- Executes just before MU_Load_DICOM_File_Batch is made visible.
function MU_Load_DICOM_File_Batch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MU_Load_DICOM_File_Batch (see VARARGIN)

%MatrixUser logo
MU_marks(handles.Matrix_preview_axes,'MatrixUser');

V=struct(...
        'Slice',[],...
        'Layer',[],...
        'Row',[],...
        'Column',[],...
        'C_lower',[],...
        'C_upper',[],...
        'Color_map','Jet',...
        'Color_bar',0 ...
        );
handles.flag3D=0; %switch for wheelscroll
handles.V=V;

%----------------------------------------------------Loading DICOM files & pre-processing
files=dir(varargin{4});
slice_num=0;
series_num_pre=0;
tmpvalue=0;
tmp='tmpvalue';
pre_tmp=tmp;
h=waitbar(0,'DICOM to Mat file-------->');
sep=filesep;

for i=3:max(size(files))
        waitbar((i-2)/(max(size(files))-2),h,['DICOM to Mat file--------> ' num2str(max(size(files))-2) ': File #' num2str(i-2)]);
        file_name=files(i).name;
        try 
            info=dicominfo([varargin{4} sep file_name]);
        catch me
            display([char(39) varargin{4} sep file_name char(39) ' is not in DICOM format. Conversion failed.']);
            if i==max(size(files)) & ~strcmp(tmp,'tmpvalue')
                [a,ind]=sort(image_pos(:,1),'ascend');
                eval(['handles.created_matrices.' tmp '=' tmp '(:,:,ind);']);
            end
            continue;
        end
        if info.SeriesNumber~=series_num_pre
            hdr=struct(...
                      'Header',info...
                        );
            try 
                hdr.ProtocolName=info.ProtocolName;
            catch me
                hdr.ProtocolName=[];
            end
            try 
                hdr.SeriesNumber=info.SeriesNumber;
            catch me
                hdr.SeriesNumber=[];
            end
            try 
                hdr.SeriesDescription=info.SeriesDescription;
            catch me
                hdr.SeriesDescription=[];
            end
            try 
                hdr.SequenceName=info.SequenceName;
            catch me
                hdr.SequenceName=[];
            end
            try 
                hdr.FA=info.FlipAngle;
            catch me
                hdr.FA=[];
            end
            try 
                hdr.TR=info.RepetitionTime;
            catch me
                hdr.TR=[];
            end
            try 
                hdr.TE=info.EchoTime;
            catch me
                hdr.TE=[];
            end
            try 
                hdr.TI=info.InversionTime;
            catch me
                hdr.TI=[];
            end
            try 
                hdr.PixelBandwidth=info.PixelBandwidth;
            catch me
                hdr.PixelBandwidth=[];
            end
            try 
                hdr.PixelSpacing=info.PixelSpacing;
            catch me
                hdr.PixelSpacing=[];
            end
            try 
                hdr.SliceThickness=info.SliceThickness;
            catch me
                hdr.SliceThickness=[];
            end

            tmp2=['MU' num2str(info.SeriesNumber) regexprep(info.SeriesDescription,'[^\/w'']','') '_hdr'];
            eval([tmp2 '=hdr;'] );
            
            if ~strcmp(pre_tmp,'tmpvalue')
                [a,ind]=sort(image_pos(:,1),'ascend');
                eval(['handles.created_matrices.' pre_tmp '=' pre_tmp '(:,:,ind);']);
            else
                eval(['handles.created_matrices.' pre_tmp '=' pre_tmp ';']);
            end
             
            eval(['handles.created_matrices.' tmp2 '=' tmp2 ';']);
            eval(['clear ' pre_tmp ';']); % clear tmp matrix and save memory
            tmp=['MU' num2str(info.SeriesNumber) regexprep(info.SeriesDescription,'[^\/w'']','')];
            pre_tmp=tmp;
            slice_num=1;
            image_pos=[];
        end
        try 
            eval([tmp '(:,:,' num2str(slice_num) ')=dicomread(' char(39) varargin{4} sep file_name char(39) ');']);
            image_pos(end+1,:)=info.InstanceNumber;
        catch me
            display(['Reading DICOM file ''' varargin{4} sep file_name ''' failed.']);
        end
        if i==max(size(files))
            [a,ind]=sort(image_pos(:,1),'ascend');
            eval(['handles.created_matrices.' tmp '=' tmp '(:,:,ind);']);
        end
        
        slice_num=slice_num+1;
        series_num_pre=info.SeriesNumber;

end
if ~isfield(handles,'created_matrices')
    warndlg('No matrix was created!');
    
    close(h);
    delete(hObject);
    return;
end
handles.created_matrices=rmfield(handles.created_matrices,'tmpvalue');
close(h);
%--------------------------------------------------End


handles.Matrix_names=fieldnames(handles.created_matrices);
set(handles.Available_matrix_list,'String',handles.Matrix_names);
set(handles.Available_matrix_list,'Max',max(size(handles.Matrix_names)));


% Choose default command line output for MU_Load_DICOM_File_Batch
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MU_Load_DICOM_File_Batch wait for user response (see UIRESUME)
% uiwait(handles.MU_load_DICOM_file_batch);


% --- Outputs from this function are returned to the command line.
function varargout = MU_Load_DICOM_File_Batch_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function Selected_matrix_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Selected_matrix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Available_matrix_list.
function Available_matrix_list_Callback(hObject, eventdata, handles)
% hObject    handle to Available_matrix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents=get(hObject,'String');

if max(size(get(hObject,'Value')))>1
        return;
end

if mod(get(hObject,'Value'),2)==1
        selected_matrix_header=handles.created_matrices.(contents{get(hObject,'Value')});
        selected_matrix=handles.created_matrices.(contents{get(hObject,'Value')+1});
        [d(1) d(2) d(3)]=size(selected_matrix);
else
        selected_matrix_header=handles.created_matrices.(contents{get(hObject,'Value')-1});
        selected_matrix=handles.created_matrices.(contents{get(hObject,'Value')});
        [d(1) d(2) d(3)]=size(selected_matrix);
end

set(handles.Matrix_name_text,'String',contents{get(hObject,'Value')});       
set(handles.SeriesNumber_text,'String',selected_matrix_header.SeriesNumber);              
set(handles.ProtocolName_text,'String',selected_matrix_header.ProtocolName);  
set(handles.SequenceName_text,'String',selected_matrix_header.SequenceName);                     
set(handles.PixelBandwidth_text,'String',selected_matrix_header.PixelBandwidth);          
set(handles.PixelSpacing_text,'String',selected_matrix_header.PixelSpacing);                       
set(handles.SliceThickness_text,'String',selected_matrix_header.SliceThickness);
set(handles.FA_text,'String',selected_matrix_header.FA);              
set(handles.TR_text,'String',selected_matrix_header.TR);                       
set(handles.TE_text,'String',selected_matrix_header.TE);
set(handles.TI_text,'String',selected_matrix_header.TI);                       


handles.V.Slice=max(round(d(3)/2),1);
handles.V.Layer=d(3);
handles.V.C_upper=max(max(max(selected_matrix)));
handles.V.C_lower=min(min(min(selected_matrix)));
handles.TMatrix=selected_matrix;
handles.flag3D=1;
guidata(hObject, handles); 
MU_update_preview(handles.Matrix_preview_axes,handles.TMatrix,handles.V);   %Matrix preview
uicontrol(handles.FA_text); %focus to axes



% --- Executes during object creation, after setting all properties.
function Available_matrix_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Available_matrix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Matrix_check_button.
function Matrix_check_button_Callback(hObject, eventdata, handles)
% hObject    handle to Matrix_check_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents=get(handles.Available_matrix_list,'String');
selected_files=contents(get(handles.Available_matrix_list,'Value'));
set(handles.Selected_matrix_list,'String',selected_files);



% --- Executes on scroll wheel click while the figure is in focus.
function MU_load_DICOM_file_batch_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to MU_load_DICOM_file_batch (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

if handles.flag3D==0
    return;
end

handles.V.Slice = handles.V.Slice + eventdata.VerticalScrollCount;
if handles.V.Slice < 1
    handles.V.Slice = 1;
end
if handles.V.Slice > handles.V.Layer
    handles.V.Slice = handles.V.Layer;
end
MU_update_preview(handles.Matrix_preview_axes,handles.TMatrix,handles.V);
guidata(hObject, handles);


% --- Executes when user attempts to close MU_load_DICOM_file_batch.
function MU_load_DICOM_file_batch_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MU_load_DICOM_file_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

delete(handles.MU_load_DICOM_file_batch);


% --- Executes on button press in Load_matrix_button.
function Load_matrix_button_Callback(hObject, eventdata, handles)
% hObject    handle to Load_matrix_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected_matrices=get(handles.Selected_matrix_list,'String');
if isempty(selected_matrices)
    errordlg('No matrix is selected');
    return;
end

for i=1:max(size(selected_matrices))
    MU_load_matrix(selected_matrices{i}, handles.created_matrices.(selected_matrices{i}),0);
end

MU_load_DICOM_file_batch_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes on selection change in Selected_matrix_list.
function Selected_matrix_list_Callback(hObject, eventdata, handles)
% hObject    handle to Selected_matrix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Selected_matrix_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Selected_matrix_list
