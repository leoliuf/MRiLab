
function varargout = CoilDesignPanel(varargin)
% CoilDESIGNPANEL M-file for CoilDesignPanel.fig
%      CoilDESIGNPANEL, by itself, creates a new CoilDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = CoilDESIGNPANEL returns the handle to a new CoilDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      CoilDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CoilDESIGNPANEL.M with the given input arguments.
%
%      CoilDESIGNPANEL('Property','Value',...) creates a new CoilDESIGNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CoilDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CoilDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CoilDesignPanel

% Last Modified by GUIDE v2.5 17-Apr-2014 19:26:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CoilDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @CoilDesignPanel_OutputFcn, ...
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


% --- Executes just before CoilDesignPanel is made visible.
function CoilDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CoilDesignPanel (see VARARGIN)
global VCtl;
global VObj;
global VMco;

handles.Simuh=varargin{1};
% Load coil element list
try
    handles.CoilElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'CoilElem' filesep 'CoilElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.CoilElemListStruct);
    handles.CoilElemListTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkCoilElemListTreeNode,handles});
    set(handles.CoilElemListTree.getUIContainer,'Units','normalized');
    set(handles.CoilElemListTree.getUIContainer,'Position',[0.0,0.4,0.2,0.58]);
    handles.Attrh1=[];
catch ME
    errordlg('Coil element list can not be loaded!');
    close(hObject);
    return;
end

%Load tabs for coil simulation
try
    handles.CoilSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'CoilElem' filesep 'CoilSimuAttr.xml']);
catch ME
    errordlg('CoilSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.CoilDesignPanel_figure,handles);
for i=1:length(handles.CoilSimuAttrStruct.Children)
    eval(['handles.' handles.CoilSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.CoilSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.CoilSimuAttrStruct.Children(i).Name '_tab,handles.CoilSimuAttrStruct.Children(' num2str(i) ').Attributes,2,[0.2,0.15,0.0,0.15,0.15,0.05]);']);
    handles=guidata(handles.CoilDesignPanel_figure);
end

% Create grid and display structure
VMco.xdimres=str2num(get(handles.Attrh2.('XDimRes'),'String'));
VMco.ydimres=str2num(get(handles.Attrh2.('YDimRes'),'String'));
VMco.zdimres=str2num(get(handles.Attrh2.('ZDimRes'),'String'));

Mxdims=size(VObj.Rho);
[VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VMco.xdimres:((Mxdims(2)-1)/2)*VObj.XDimRes,...
    (-(Mxdims(1)-1)/2)*VObj.YDimRes:VMco.ydimres:((Mxdims(1)-1)/2)*VObj.YDimRes,...
    (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VMco.zdimres:((Mxdims(3)-1)/2)*VObj.ZDimRes);
VMco.axes=handles.CoilSen_axes;
handles.IV=struct(...
    'xslice',(handles.Simuh.SV.Slice - (Mxdims(2)-1)/2)* VObj.XDimRes,...
    'yslice',(handles.Simuh.CV.Slice - (Mxdims(1)-1)/2)* VObj.YDimRes,...
    'zslice',(handles.Simuh.AV.Slice - (Mxdims(3)-1)/2)* VObj.ZDimRes ...
    );
view(handles.CoilSen_axes,3);

if verLessThan('matlab','8.5')
    % Code to run in MATLAB R2015a and earlier here
    %Open current loaded Coil XML file
    if strcmp(get(handles.Simuh.CoilTx_tab,'Visible'),'on')
        if isfield(handles.Simuh,'CoilTxXMLFile')
            CoilXMLFile = handles.Simuh.CoilTxXMLFile;
        end
    end
    
    if strcmp(get(handles.Simuh.CoilRx_tab,'Visible'),'on')
        if isfield(handles.Simuh,'CoilRxXMLFile')
            CoilXMLFile = handles.Simuh.CoilRxXMLFile;
        end
    end
else
    % Code to run in MATLAB R2015a and later here
    tabtitle=get(get(handles.Simuh.CoilSel_tabgroup,'SelectedTab'),'Title');
    if strcmp(tabtitle,'Tx')
        if isfield(handles.Simuh,'CoilTxXMLFile')
            CoilXMLFile = handles.Simuh.CoilTxXMLFile;
        end
    elseif strcmp(tabtitle,'Rx')
        if isfield(handles.Simuh,'CoilRxXMLFile')
            CoilXMLFile = handles.Simuh.CoilRxXMLFile;
        end
    end
end

if exist('CoilXMLFile','var')
    import javax.swing.*
    import javax.swing.tree.*;
    handles.CoilStruct=DoParseXML(CoilXMLFile);
    handles.CoilXMLFile=CoilXMLFile;
    DoWriteXML2m(handles.CoilStruct,[handles.CoilXMLFile(1:end-3) 'm']);
    %     guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.CoilStruct);
    handles.CoilTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.CoilTree.getUIContainer,'Units','normalized');
    set(handles.CoilTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.CoilTreeModel=DefaultTreeModel(Root);
    handles.CoilTree.setModel(handles.CoilTreeModel);
    try
        DoPlotCoilSen(handles);
        set(handles.Undock_pushbutton,'Enable','on');
        set(handles.Display_pushbutton,'Enable','on');
        set(handles.Forwards_pushbutton,'Enable','on');
        set(handles.Backwards_pushbutton,'Enable','on');
        handles=guidata(hObject);
    catch me
        error_msg{1,1}='ERROR!!! Displaying B1 field aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
    end
    
end


% Choose default command line output for CoilDesignPanel
handles.input=varargin;
handles.output=hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CoilDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.CoilDesignPanel_figure);


function ChkCoilElemListTreeNode(tree, value, handles)

handles=guidata(handles.CoilDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.CoilElemListStruct';
if Level=='0'
    eval(['handles.CoilElemNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.CoilElemNode=' Node ';']);
end
guidata(handles.CoilDesignPanel_figure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = CoilDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --------------------------------------------------------------------
function LoadCoil_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadCoil_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadCoilFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadCoilFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

[filename,coilpathname,filterindex]=uigetfile({'Coil*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    handles.CoilStruct=DoParseXML(fullfile(coilpathname,filename));
    handles.CoilXMLFile=fullfile(coilpathname,filename);
    guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.CoilStruct);
    handles.CoilTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.CoilTree.getUIContainer,'Units','normalized');
    set(handles.CoilTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.CoilTreeModel=DefaultTreeModel(Root);
    handles.CoilTree.setModel(handles.CoilTreeModel);
    cla(handles.CoilSen_axes);
    clear global VCco;
    % Add searchig path
    path(path,coilpathname);
else
    errordlg('No Coil is loaded!');
    return;
end
guidata(hObject, handles);

function ChkNode(tree, value, handles)

handles=guidata(handles.CoilDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end
Node='handles.CoilStruct';
if Level=='0'
    eval(['handles.CoilNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.CoilNode=' Node ';']);
end
handles.CoilNodeLvl=Node;
handles.SelNode=SelNode;

if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end

set(handles.CoilAttri_uipanel,'Title',['''' char(SelNode.getName) ''' Coil Attribute'],'Unit','normalized');
if SelNode.isLeaf | SelNode.isRoot
    if strcmp(char(SelNode.getName),'Specials')
        DoEditValue(handles,handles.CoilAttri_uipanel,handles.CoilNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    else
        DoEditValue(handles,handles.CoilAttri_uipanel,handles.CoilNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    end
else
    guidata(handles.CoilDesignPanel_figure, handles);
end


% --- Executes on button press in DelNode_pushbutton.
function DelNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.CoilNode.Name
        case 'MRiLabCoil'
            errordlg('MRiLabCoil Root can not be deleted!');
            return;
    end
    
    eval([handles.CoilNodeLvl '=[];']);
    nN=handles.SelNode.getNextSibling;
    while ~isempty(nN)
        Level=nN.getValue;
        Level(end)=[];
        nN.setValue(Level);
        nN=nN.getNextSibling;
    end
    guidata(hObject, handles);
    pause(0.1);
    
    % remove node
    handles.CoilTree.setSelectedNode(handles.SelNode.getParent);
    handles.CoilTreeModel.removeNodeFromParent(handles.SelNode);
    
    DoWriteXML(handles.CoilStruct,handles.CoilXMLFile);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in AddNode_pushbutton.
function AddNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to AddNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    ChkCoilElemListTreeNode(handles.CoilElemListTree, [], handles); % In case CoilElem.xml updated
    handles=guidata(handles.CoilDesignPanel_figure);
    switch handles.CoilNode.Name
        case {'MRiLabCoil'}
            % add node
            SelNode=handles.CoilElemListTree.SelectedNodes;
            SelNode=SelNode(1);
            AddedNode=SelNode.clone;
            switch char(AddedNode.getName)
                case {'CoilElem'}
                    errordlg([char(AddedNode.getName) ' can not be added!']);
                    return;
            end
            handles.CoilTreeModel.insertNodeInto(AddedNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.CoilTree.setSelectedNode(AddedNode); % expand to show added child
            handles.CoilTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=AddedNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                AddedNode.setValue([Level; Level(end)+1]);
                eval([handles.CoilNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CoilElemNode;']);
                DoWriteXML(handles.CoilStruct,handles.CoilXMLFile);
            else
                nP=AddedNode.getParent;
                Level=nP.getValue;
                AddedNode.setValue([Level; 1]);
                eval([handles.CoilNodeLvl '.Children=handles.CoilElemNode;']);
                DoWriteXML(handles.CoilStruct,handles.CoilXMLFile);
            end
        otherwise
            errordlg(['Coil Element can not be added under ' handles.CoilNode.Name '!']);
            return;
    end
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in UpdateCoilXML_pushbutton.
function UpdateCoilXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateCoilXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update Coil XML file
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        switch get(handles.Attrh1.(Attrh1name{i+1}),'Style')
            case 'edit'
                handles.CoilNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            case 'checkbox'
                if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
                    handles.CoilNode.Attributes((i+1)/2).Value='^1';
                else
                    handles.CoilNode.Attributes((i+1)/2).Value='^0';
                end
            case 'popupmenu'
                handles.CoilNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh1.(Attrh1name{i+1}),'Value'));
        end
    end
    eval([handles.CoilNodeLvl '=handles.CoilNode;']);
    DoWriteXML(handles.CoilStruct,handles.CoilXMLFile);
    % update associated m function
    DoWriteXML2m(handles.CoilStruct,[handles.CoilXMLFile(1:end-3) 'm']);
end

% update CoilSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.CoilSimuAttrStruct.Children)
    Attrh2=get(tabs(j),'Children');
    for i=1:2:length(Attrh2)
        if ~iscell(get(Attrh2(end-i),'String'))
            handles.CoilSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh2(end-i),'String');
        else
            handles.CoilSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh2(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.CoilSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'CoilElem' filesep 'CoilSimuAttr.xml']);

guidata(hObject, handles);



% --- Executes on button press in CopSelNode_pushbutton.
function CopNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CopSelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.CoilNode.Name
        case 'MRiLabCoil'
            errordlg('MRiLabCoil Root can not be copied!');
            return;
    end
    handles.CopSelNode=handles.SelNode.clone;
    handles.CopCoilNode=handles.CoilNode;
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end


% --- Executes on button press in PasNode_pushbutton.
function PasNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to PasNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.CoilNode.Name
        case {'MRiLabCoil'}
            % paste node
            handles.CoilTreeModel.insertNodeInto(handles.CopSelNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.CoilTree.setSelectedNode(handles.CopSelNode); % expand to show added child
            handles.CoilTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=handles.CopSelNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; Level(end)+1]);
                eval([handles.CoilNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CopCoilNode;']);
                DoWriteXML(handles.CoilStruct,handles.CoilXMLFile);
            else
                nP=handles.CopSelNode.getParent;
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; 1]);
                eval([handles.CoilNodeLvl '.Children=handles.CopCoilNode;']);
                DoWriteXML(handles.CoilStruct,handles.CoilXMLFile);
            end
        otherwise
            errordlg(['Coil Element can not be added under ' handles.CoilNode.Name '!']);
            return;
    end
    handles.CopSelNode=[];
    handles.CopCoilNode=[];
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in CoilExecute_pushbutton.
function CoilExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CoilExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoPlotCoilSen(handles);
    set(handles.Undock_pushbutton,'Enable','on');
    set(handles.Display_pushbutton,'Enable','on');
    set(handles.Forwards_pushbutton,'Enable','on');
    set(handles.Backwards_pushbutton,'Enable','on');
catch me
    error_msg{1,1}='Error occurred at calculating B1/E1 field.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    set(handles.Undock_pushbutton,'Enable','off');
    set(handles.Display_pushbutton,'Enable','off');
    set(handles.Forwards_pushbutton,'Enable','off');
    set(handles.Backwards_pushbutton,'Enable','off');
end
set(hObject,'Enable','on');
set(hObject,'String','Execute');

% --------------------------------------------------------------------
function SavePanel_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoSaveSnapshot(handles.CoilDesignPanel_figure);


% --- Executes when user attempts to close CoilDesignPanel_figure.
function CoilDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to CoilDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear global VCco;
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in Forwards_pushbutton.
function Forwards_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Forwards_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VObj;
TAttr=get(handles.Attrh2.('Plane'),'String');
switch TAttr{get(handles.Attrh2.('Plane'),'Value')}
    case 'XY'
        handles.IV.zslice=handles.IV.zslice+VObj.ZDimRes;
    case 'XZ'
        handles.IV.yslice=handles.IV.yslice+VObj.YDimRes;
    case 'YZ'
        handles.IV.xslice=handles.IV.xslice+VObj.XDimRes;
end
DoUpdateSlice(handles.CoilSen_axes,handles.F,handles.IV,'Coil');
guidata(hObject, handles);

% --- Executes on button press in Backwards_pushbutton.
function Backwards_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Backwards_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VObj;
TAttr=get(handles.Attrh2.('Plane'),'String');
switch TAttr{get(handles.Attrh2.('Plane'),'Value')}
    case 'XY'
        handles.IV.zslice=handles.IV.zslice-VObj.ZDimRes;
    case 'XZ'
        handles.IV.yslice=handles.IV.yslice-VObj.YDimRes;
    case 'YZ'
        handles.IV.xslice=handles.IV.xslice-VObj.XDimRes;
end
DoUpdateSlice(handles.CoilSen_axes,handles.F,handles.IV,'Coil');
guidata(hObject, handles);


% --------------------------------------------------------------------
function Cursor_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Cursor_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'dcm')
    handles.dcm=datacursormode(handles.CoilDesignPanel_figure);
    datacursormode on
    set(handles.dcm,'updatefcn',{@Cursor_update,handles});
else
    if strcmp(get(handles.dcm,'Enable'),'on')
        set(handles.dcm,'Enable','off');
    else
        set(handles.dcm,'Enable','on');
    end
end
guidata(hObject, handles);

function output_txt = Cursor_update(obj,event_obj,handles)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

global VObj;
global VCtl;
global VMco;

handles=guidata(handles.CoilDesignPanel_figure);
pos = get(event_obj,'Position');
pos(1)=round((pos(1)+VCtl.ISO(1)*VObj.XDimRes)/VMco.xdimres);
pos(2)=round((pos(2)+VCtl.ISO(2)*VObj.YDimRes)/VMco.ydimres);
pos(3)=round((pos(3)+VCtl.ISO(3)*VObj.ZDimRes)/VMco.zdimres);

output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)],...
    ['Z: ',num2str(pos(3),4)],...
    ['Value: ',num2str(handles.F(pos(2),pos(1),pos(3)),4)]};


% --- Executes on button press in Undock_pushbutton.
function Undock_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Undock_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VMco;
TAttr=get(handles.Attrh2.('Plane'),'String');
switch TAttr{get(handles.Attrh2.('Plane'),'Value')}
    case 'XY'
        zmax=max(VMco.zgrid(1,1,:));
        zmin=min(VMco.zgrid(1,1,:));
        zslice=handles.IV.zslice;
        if zslice<zmax & zslice>zmin
            zslice=floor((zslice-zmin)/VMco.zdimres)+1;
            figure;
            quiver(VMco.xgrid(:,:,zslice),VMco.ygrid(:,:,zslice),handles.Fx(:,:,zslice),handles.Fy(:,:,zslice));
            title('Field direction in XY plane');
            set(gca,'YDir','reverse');
            xlabel('X');  ylabel('Y');
            axis image;
        end
    case 'XZ'
        ymax=max(max(max(VMco.ygrid)));
        ymin=min(min(min(VMco.ygrid)));
        yslice=handles.IV.yslice;
        if yslice<ymax & yslice>ymin
            yslice=floor((yslice-ymin)/VMco.ydimres)+1;
            figure;
            quiver(VMco.xgrid(yslice,:,:),VMco.zgrid(yslice,:,:),handles.Fx(yslice,:,:),handles.Fz(yslice,:,:));
            title('Field direction in XZ plane');
            set(gca,'YDir','reverse');
            xlabel('X');  ylabel('Z');
            axis image;
        end
    case 'YZ'
        xmax=max(max(max(VMco.xgrid)));
        xmin=min(min(min(VMco.xgrid)));
        xslice=handles.IV.xslice;
        if xslice<xmax & xslice>xmin
            xslice=floor((xslice-xmin)/VMco.xdimres)+1;
            figure;
            quiver(VMco.ygrid(:,xslice,:),VMco.zgrid(:,xslice,:),handles.Fy(:,xslice,:),handles.Fz(:,xslice,:));
            title('Field direction in YZ plane');
            set(gca,'YDir','reverse');
            xlabel('Y');  ylabel('Z');
            axis image;
        end
end


% --------------------------------------------------------------------
function NewCoil_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewCoil_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewCoilFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewCoilFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter NEW coil name:','Enter NEW coil note:'};
dlg_title = 'Input for creating new coil';
num_lines = 1;
def = {'Coil_0ChHead','0 Chanel Head Coil'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    warndlg('No new coil file is created!');
    return
end
if isempty(answer{1})
    warndlg('No new coil file is created!');
    return
end
if ~strcmp(answer{1}(1:5),'Coil_')
    warndlg('Coil name must have a prefix ''Coil_'', please rename your coil!');
    return
end
coilpath=uigetdir(pwd,'Specify a saving path for new coil file.');
if coilpath==0
    warndlg('You have to specify a saving path!');
    return;
end

% Create new coil file
mkdir([coilpath filesep answer{1}]); % make folder
copyfile([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Coil' filesep 'Head' filesep 'Coil_1ChHead' filesep 'Coil_1ChHead.xml'],...
    [coilpath filesep answer{1} filesep answer{1} '.xml']); % copy coil temple
% Add searchig path
path(path,[coilpath filesep answer{1}]);
% Load new coil file
import javax.swing.*;
import javax.swing.tree.*;
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end
handles.CoilStruct=DoParseXML([coilpath filesep answer{1} filesep answer{1} '.xml']);
for i=1:length(handles.CoilStruct.Attributes)
    if strcmp(handles.CoilStruct.Attributes(i).Name,'Name')
        handles.CoilStruct.Attributes(i).Value = answer{1};
    elseif strcmp(handles.CoilStruct.Attributes(i).Name,'Notes')
        handles.CoilStruct.Attributes(i).Value = answer{2};
    end
end
DoWriteXML(handles.CoilStruct,[coilpath filesep answer{1} filesep answer{1} '.xml']); %update new coil file
handles.CoilXMLFile=[coilpath filesep answer{1} filesep answer{1} '.xml'];
DoWriteXML2m(handles.CoilStruct,[handles.CoilXMLFile(1:end-3) 'm']);
guidata(hObject, handles);
Root=DoConvStruct2Tree(handles.CoilStruct);
handles.CoilTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
set(handles.CoilTree.getUIContainer,'Units','normalized');
set(handles.CoilTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
handles.CoilTreeModel=DefaultTreeModel(Root);
handles.CoilTree.setModel(handles.CoilTreeModel);
cla(handles.CoilSen_axes);
clear global VCco;
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function CoilDesignPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to CoilDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tempaxes = gca;
try
    if strcmp(get(gcf,'Selectiontype'),'alt')
        figure 			% Create a new figure
        ax_new = axes; 
        copyaxes(tempaxes, ax_new);
    end
catch me
end


% --- Executes on button press in Display_pushbutton.
function Display_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Display_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Conts=get(handles.Attrh2.FieldType,'String');
SelCont=Conts{get(handles.Attrh2.FieldType,'Value')};
switch SelCont
    case 'B1Field'
        Conts=get(handles.Attrh2.Mode,'String');
        SelCont=Conts{get(handles.Attrh2.Mode,'Value')};
        assignin('base', ['B1_' SelCont], handles.F);
        MU_Matrix_Display(['B1_' SelCont],'Magnitude');
    case 'E1Field'
        assignin('base', 'E1_Magnitude', handles.F);
        MU_Matrix_Display('E1_Magnitude','Magnitude');
end
