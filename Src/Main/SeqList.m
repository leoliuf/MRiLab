

function varargout = SeqList(varargin)
% SEQLIST_FIGURE M-file for SeqList_figure.fig
%      SEQLIST_FIGURE, by itself, creates a new SEQLIST_FIGURE or raises the existing
%      singleton*.
%
%      H = SEQLIST_FIGURE returns the handle to a new SEQLIST_FIGURE or the handle to
%      the existing singleton*.
%
%      SEQLIST_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEQLIST_FIGURE.M with the given input arguments.
%
%      SEQLIST_FIGURE('Property','Value',...) creates a new SEQLIST_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SeqList_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SeqList_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SeqList_figure

% Last Modified by GUIDE v2.5 23-Jun-2012 10:51:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SeqList_OpeningFcn, ...
                   'gui_OutputFcn',  @SeqList_OutputFcn, ...
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


% --- Executes just before SeqList_figure is made visible.
function SeqList_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SeqList_figure (see VARARGIN)

handles.Simuh=varargin{1};
Dimension=dir([handles.Simuh.MRiLabPath filesep 'PSD']);
ind=1;
for i=length(Dimension):-1:1
    if ~strcmp(Dimension(i).name,'.') & ~strcmp(Dimension(i).name,'..') & Dimension(i).isdir
        handles.DimensionDir{ind,1}=Dimension(i).name;
        ind=ind+1;
    end
end
set(handles.Dim_popupmenu,'String',handles.DimensionDir);
Category=dir([handles.Simuh.MRiLabPath filesep ...
              'PSD' filesep ...
              handles.DimensionDir{get(handles.Dim_popupmenu,'Value')}]);
ind=1;
for i=1:length(Category)
    if ~strcmp(Category(i).name,'.') & ~strcmp(Category(i).name,'..') & Category(i).isdir
        handles.CategoryDir{ind,1}=Category(i).name;
        ind=ind+1;
    end
end
set(handles.Category_listbox,'String',handles.CategoryDir);

SpecialTech=dir([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SpecialTech']);

ind=1;
for i=1:length(SpecialTech)
    if ~strcmp(SpecialTech(i).name,'.') & ~strcmp(SpecialTech(i).name,'..') & ~(SpecialTech(i).isdir)
        handles.Special(ind).Name=SpecialTech(i).name(1:end-4);
        handles.Special(ind).Value=[ '^0'...
                                     handles.Simuh.MRiLabPath filesep ...
                                     'Macro' filesep ...
                                     'SpecialTech' filesep ...
                                     SpecialTech(i).name];
        ind=ind+1;
    end
end

DoEditValue(handles,handles.Special_uipanel,handles.Special,1,[0.2,0.04,0.0,0.1,0.1,0.05]);
handles=guidata(hObject);

handles.accept = 0;
% Choose default command line output for SeqList_figure
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SeqList_figure wait for user response (see UIRESUME)
% uiwait(handles.SeqList_figure);


% --- Outputs from this function are returned to the command line.
function varargout = SeqList_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Dim_popupmenu.
function Dim_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Dim_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Dim_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Dim_popupmenu
if ~isempty(get(handles.PSDPath_text,'String'))
    return;
end

Category=dir([handles.Simuh.MRiLabPath filesep ...
              'PSD' filesep ...
              handles.DimensionDir{get(handles.Dim_popupmenu,'Value')}]);
ind=1;
handles.CategoryDir=[];
for i=1:length(Category)
    if ~strcmp(Category(i).name,'.') & ~strcmp(Category(i).name,'..') & Category(i).isdir
        handles.CategoryDir{ind,1}=Category(i).name;
        ind=ind+1;
    end
end
if ind==1
    handles.CategoryDir='Empty';
end
set(handles.Category_listbox,'String',handles.CategoryDir);
set(handles.Category_listbox,'Value',1);
handles.SeqList='Empty';
set(handles.Seq_listbox,'String','Empty');
set(handles.Seq_listbox,'Value',1);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Dim_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dim_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Seq_listbox.
function Seq_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Seq_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Seq_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Seq_listbox

if ~isempty(get(handles.PSDPath_text,'String'))
    return;
end

if strcmp(handles.SeqList,'Empty')
    return;
end

handles.SeqXMLFile=[handles.Simuh.MRiLabPath filesep ...
                    'PSD' filesep ...
                    handles.DimensionDir{get(handles.Dim_popupmenu,'Value')} filesep ...
                    handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                    handles.SeqList{get(handles.Seq_listbox,'Value')} filesep...
                    handles.SeqList{get(handles.Seq_listbox,'Value')} '.xml'];
                
handles.SeqXMLDir=[handles.Simuh.MRiLabPath filesep ...
                   'PSD' filesep ...
                   handles.DimensionDir{get(handles.Dim_popupmenu,'Value')} filesep ...
                   handles.CategoryDir{get(handles.Category_listbox,'Value')} filesep ...
                   handles.SeqList{get(handles.Seq_listbox,'Value')}];
               
handles.SpecialTechDir=[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SpecialTech'];

Files=dir(handles.SeqXMLDir);   
ind=0;
for j=1:length(Files)
    if ~Files(j).isdir & strcmp(Files(j).name,'SimuAttr.xml')
        ind=ind+1;
    end
end
if ind==0
    copyfile([handles.Simuh.MRiLabPath filesep ...
              'PSD' filesep ...
              handles.DimensionDir{get(handles.Dim_popupmenu,'Value')} ...
              filesep 'SimuAttr.xml'],...
             [handles.SeqXMLDir filesep 'SimuAttr.xml']);
end

Seq=DoParseXML(handles.SeqXMLFile);
handles.Simuh.SeqStruct=Seq;
if ~isempty(handles.Attrh1) % reset special tech flag
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        set(handles.Attrh1.(Attrh1name{i}),'Value',0);
    end
end
for i=1:length(Seq.Children(2).Attributes) % add special tech file
    try 
        if strcmp(Seq.Children(2).Attributes(i).Value,'^1')
            set(handles.Attrh1.(Seq.Children(2).Attributes(i).Name),'Value',1);
            ind=0;
            for j=1:length(Files)
                if ~Files(j).isdir & strcmp(Files(j).name,[Seq.Children(2).Attributes(i).Name '.xml'])
                    ind=ind+1;
                end
            end
            if ind==0
                copyfile([handles.SpecialTechDir filesep Seq.Children(2).Attributes(i).Name '.xml'],...
                         [handles.SeqXMLDir filesep Seq.Children(2).Attributes(i).Name '.xml']);
            end
        end
        
    catch me
       DoUpdateInfo(handles.Simuh,['No special setting is designed for ''' Seq.Children(2).Attributes(i).Name ''' !']);
    end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Seq_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Seq_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Category_listbox.
function Category_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Category_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Category_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Category_listbox

if ~isempty(get(handles.PSDPath_text,'String'))
    return;
end

if strcmp(handles.CategoryDir,'Empty')
    return;
end

set(handles.Seq_listbox,'Enable','on');

Seq=dir([handles.Simuh.MRiLabPath filesep ...
              'PSD' filesep ...
              handles.DimensionDir{get(handles.Dim_popupmenu,'Value')} filesep...
              handles.CategoryDir{get(handles.Category_listbox,'Value')}]);
ind=1;
handles.SeqList=[];
for i=1:length(Seq)
    if ~strcmp(Seq(i).name,'.') & ~strcmp(Seq(i).name,'..')
        handles.SeqList{ind,1}=Seq(i).name;
        ind=ind+1;
    end
end
if ind==1
    handles.SeqList='Empty';
end
set(handles.Seq_listbox,'String',handles.SeqList);
set(handles.Seq_listbox,'Value',1);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Category_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Category_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Accept_pushbutton.
function Accept_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Accept_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VCtl;

if isempty(get(handles.PSDPath_text,'String'))
    try
        if strcmp(handles.SeqList{get(handles.Seq_listbox,'Value')},'Empty')
            DoUpdateInfo(handles.Simuh,'No sequence is selected!');
            return;
        end
    catch me
        DoUpdateInfo(handles.Simuh,'No sequence is selected!');
        return;
    end
end
try
    handles.Simuh.SimuAttrStruct=DoParseXML([handles.SeqXMLDir filesep 'SimuAttr.xml']);
catch ME
    DoUpdateInfo(handles.Simuh,'SimuAttr.xml file is missing or can not be loaded!');
    return;
end

%----clear tabs
tabs=get(handles.Simuh.Setting_tabgroup,'Children');
for i=1:length(tabs)
    delete(get(tabs(i),'Children'));
end
delete(tabs);
delete(handles.Simuh.Setting_tabgroup);
handles.Simuh.Attrh1=[];
handles.Simuh.Setting_tabgroup=[];
%----end

%----reload new tabs
handles.Simuh.Setting_tabgroup=uitabgroup(handles.Simuh.Setting_uipanel);
guidata(handles.Simuh.SimuPanel_figure,handles.Simuh);
for i=1:length(handles.Simuh.SimuAttrStruct.Children)
    eval(['handles.Simuh.' handles.Simuh.SimuAttrStruct.Children(i).Name '_tab=uitab( handles.Simuh.Setting_tabgroup,' '''title'',' '''' handles.Simuh.SimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles.Simuh,handles.Simuh.' handles.Simuh.SimuAttrStruct.Children(i).Name '_tab,handles.Simuh.SimuAttrStruct.Children(' num2str(i) ').Attributes,1,[0.2,0.12,0.01,0.1,0.1,0.05]);']);
    handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
end

Seq=DoParseXML(handles.SeqXMLFile);
handles.Simuh.CVs_tab=uitab(handles.Simuh.Setting_tabgroup,'title','CVs','Units','points');
DoEditValue(handles.Simuh,handles.Simuh.CVs_tab,Seq.Children(1).Attributes,1,[0.2,0.12,0.01,0.1,0.1,0.05]);
handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
            try
                eval(['handles.Simuh.' Attrh1name{i+1} 'Struct=DoParseXML([handles.SeqXMLDir filesep Attrh1name{i+1} ''.xml'']);']);
            catch me
                copyfile([handles.SpecialTechDir filesep Attrh1name{i+1} '.xml'],...
                         [handles.SeqXMLDir filesep Attrh1name{i+1} '.xml']);
                eval(['handles.Simuh.' Attrh1name{i+1} 'Struct=DoParseXML([handles.SeqXMLDir filesep Attrh1name{i+1} ''.xml'']);']);
            end
            eval(['handles.Simuh.' Attrh1name{i+1} '_tab=uitab( handles.Simuh.Setting_tabgroup,' '''title'',' '''' Attrh1name{i+1} ''',''Units'',''normalized'');']);
            eval(['DoEditValue(handles.Simuh,handles.Simuh.' Attrh1name{i+1} '_tab,handles.Simuh.' Attrh1name{i+1} 'Struct.Attributes,1,[0.2,0.12,0.01,0.1,0.1,0.05]);']);
            handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
        end
    end
end
handles.Simuh.SeqXMLFile=handles.SeqXMLFile;
handles.Simuh.SeqXMLDir=handles.SeqXMLDir;
handles.Simuh.SpecialTechDir=handles.SpecialTechDir;

fieldname=fieldnames(handles.Simuh.Attrh1);
for i=1:length(fieldname)/2
    set(handles.Simuh.Attrh1.(fieldname{i*2}),'Callback',{@DoDisableButton,handles.Simuh});
end

%----end
%----load PSD memo
fid=fopen([handles.SeqXMLFile(1:end-4) '_Memo.txt'],'r');
if fid==-1
    set(handles.Simuh.PSDMemo_edit,'String','PSD Memo is not available!');
else
    tline = fgetl(fid);
    i=1;
    while ischar(tline)
        Memo{i,1}=tline;
        tline = fgetl(fid);
        i=i+1;
    end
    if i==1
        set(handles.Simuh.PSDMemo_edit,'String','PSD Memo is empty!');
    else
        set(handles.Simuh.PSDMemo_edit,'String',Memo);
    end
    fclose(fid);
end
%----end
set(handles.Simuh.PSD_text,'String', ['PSD : ' Seq.Attributes(1).Value],'TooltipString',handles.Simuh.SeqXMLFile);
DoUpdateInfo(handles.Simuh,'Seq file was successfully loaded!');
DoScanSeriesUpd(handles.Simuh,0);
VCtl=rmfield(VCtl, 'RefSNR'); % Prepare for SNR calculation
handles.accept = 1;
set(handles.Simuh.SeqList_pushbutton,'Enable','off');
set(handles.Simuh.Seq_uipushtool,'Enable','on');
set(handles.Simuh.Seq_uimenu,'Enable','on');
guidata(hObject, handles);
close(handles.SeqList_figure);


% --- Executes on button press in Cancel_pushbutton.
function Cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SeqList_figure_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes when user attempts to close SeqList_figure.
function SeqList_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SeqList_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoDisableButton([],[],handles.Simuh);
if handles.accept == 0
    DoUpdateInfo(handles.Simuh,'Seq file loading was cancelled!');
end
% Hint: delete(hObject) closes the figure
delete(handles.SeqList_figure);

% --- Executes on button press in PSDPath_pushbutton.
function PSDPath_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PSDPath_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname,filterindex]=uigetfile({'PSD*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    set(handles.PSDPath_text,'String',[pathname filename]);
    handles.SeqXMLFile=[pathname filename];
    handles.SeqXMLDir=pathname(1:end-1);
    handles.SpecialTechDir=[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SpecialTech'];
    % Add searchig path
    path(path,handles.SeqXMLDir);
    
    Files=dir(handles.SeqXMLDir);
    ind=0;
    for j=1:length(Files)
        if ~Files(j).isdir & strcmp(Files(j).name,'SimuAttr.xml')
            ind=ind+1;
        end
    end
    if ind==0
        copyfile([handles.Simuh.MRiLabPath filesep ...
                 'PSD' filesep ...
                 handles.DimensionDir{get(handles.Dim_popupmenu,'Value')} ...
                 filesep 'SimuAttr.xml'],...
                 [handles.SeqXMLDir filesep 'SimuAttr.xml']);
    end
    
    Seq=DoParseXML(handles.SeqXMLFile);
    handles.Simuh.SeqStruct=Seq;
    if ~isempty(handles.Attrh1) % reset special tech flag
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            set(handles.Attrh1.(Attrh1name{i}),'Value',0);
        end
    end
    for i=1:length(Seq.Children(2).Attributes) % add special tech file
        try
            if strcmp(Seq.Children(2).Attributes(i).Value,'^1')
                set(handles.Attrh1.(Seq.Children(2).Attributes(i).Name),'Value',1);
                ind=0;
                for j=1:length(Files)
                    if ~Files(j).isdir & strcmp(Files(j).name,[Seq.Children(2).Attributes(i).Name '.xml'])
                        ind=ind+1;
                    end
                end
                if ind==0
                    copyfile([handles.SpecialTechDir filesep Seq.Children(2).Attributes(i).Name '.xml'],...
                             [handles.SeqXMLDir filesep Seq.Children(2).Attributes(i).Name '.xml']);
                end
            end
        catch me
            DoUpdateInfo(handles.Simuh,['No special setting is designed for ''' Seq.Children(2).Attributes(i).Name ''' !']);
        end
    end
    set(handles.PSDPath_text,'String',[pathname filename]);
else
    errordlg('No Seq was loaded!');
    return;
end
guidata(hObject, handles);
