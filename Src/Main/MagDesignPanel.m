
function varargout = MagDesignPanel(varargin)
% MAGNETDESIGNPANEL MATLAB code for MagDesignPanel.fig
%      MAGNETDESIGNPANEL, by itself, creates a new MAGNETDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = MAGNETDESIGNPANEL returns the handle to a new MAGNETDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      MAGNETDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAGNETDESIGNPANEL.M with the given input arguments.
%
%      MAGNETDESIGNPANEL('Property','Value',...) creates a new MAGNETDESIGNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MagDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MagDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MagDesignPanel

% Last Modified by GUIDE v2.5 17-Apr-2014 16:33:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MagDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @MagDesignPanel_OutputFcn, ...
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

% --- Executes just before MagDesignPanel is made visible.
function MagDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MagDesignPanel (see VARARGIN)
global VCtl;
global VObj;
global VMmg;

handles.Simuh=varargin{1};
% Load Pulse element list
try
    handles.MagElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'MagElem' filesep 'MagElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.MagElemListStruct);
    handles.MagElemListTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkMagElemListTreeNode,handles});
    set(handles.MagElemListTree.getUIContainer,'Units','normalized');
    set(handles.MagElemListTree.getUIContainer,'Position',[0.0,0.4,0.2,0.58]);
    handles.Attrh1=[];
catch ME
    errordlg('Mag element list can not be loaded!');
    close(hObject);
    return;
end

%Load tabs for Mag Simulation
try
    handles.MagSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'MagElem' filesep 'MagSimuAttr.xml']);
catch ME
    errordlg('MagSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.MagDesignPanel_figure,handles);
for i=1:length(handles.MagSimuAttrStruct.Children)
    eval(['handles.' handles.MagSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.MagSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.MagSimuAttrStruct.Children(i).Name '_tab,handles.MagSimuAttrStruct.Children(' num2str(i) ').Attributes,2,[0.2,0.15,0.0,0.15,0.15,0.05]);']);
    handles=guidata(handles.MagDesignPanel_figure);
end

% Create grid and display structure
VMmg.xdimres=str2num(get(handles.Attrh2.('XDimRes'),'String'));
VMmg.ydimres=str2num(get(handles.Attrh2.('YDimRes'),'String'));
VMmg.zdimres=str2num(get(handles.Attrh2.('ZDimRes'),'String'));

Mxdims=size(VObj.Rho);
[VMmg.xgrid,VMmg.ygrid,VMmg.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VMmg.xdimres:((Mxdims(2)-1)/2)*VObj.XDimRes,...
    (-(Mxdims(1)-1)/2)*VObj.YDimRes:VMmg.ydimres:((Mxdims(1)-1)/2)*VObj.YDimRes,...
    (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VMmg.zdimres:((Mxdims(3)-1)/2)*VObj.ZDimRes);

VMmg.axes=handles.MagField_axes;
handles.IV=struct(...
    'xslice',(handles.Simuh.SV.Slice - (Mxdims(2)-1)/2)* VObj.XDimRes,...
    'yslice',(handles.Simuh.CV.Slice - (Mxdims(1)-1)/2)* VObj.YDimRes,...
    'zslice',(handles.Simuh.AV.Slice - (Mxdims(3)-1)/2)* VObj.ZDimRes ...
    );
view(handles.MagField_axes,3);

%Open current loaded Mag XML file
if isfield(handles.Simuh,'MagXMLFile')
    import javax.swing.*
    import javax.swing.tree.*;
    handles.MagStruct=DoParseXML(handles.Simuh.MagXMLFile);
    handles.MagXMLFile=handles.Simuh.MagXMLFile;
    DoWriteXML2m(handles.MagStruct,[handles.MagXMLFile(1:end-3) 'm']);
    %     guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.MagStruct);
    handles.MagTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.MagTree.getUIContainer,'Units','normalized');
    set(handles.MagTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.MagTreeModel=DefaultTreeModel(Root);
    handles.MagTree.setModel(handles.MagTreeModel);
    try
        DoPlotMagFie(handles);
        set(handles.Forwards_pushbutton,'Enable','on');
        set(handles.Backwards_pushbutton,'Enable','on');
        set(handles.Display_pushbutton,'Enable','on');
        handles=guidata(hObject);
    catch me
        error_msg{1,1}='ERROR!!! Displaying dB0 field aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
    end
    
end

% Choose default command line output for MagDesignPanel
handles.input=varargin;
handles.output=hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MagDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.MagDesignPanel_figure);


function ChkMagElemListTreeNode(tree, value, handles)

handles=guidata(handles.MagDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.MagElemListStruct';
if Level=='0'
    eval(['handles.MagElemNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.MagElemNode=' Node ';']);
end
guidata(handles.MagDesignPanel_figure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MagDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --------------------------------------------------------------------
function LoadMag_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMag_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadMagFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMagFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

[filename,pathname,filterindex]=uigetfile({'Mag*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    handles.MagStruct=DoParseXML(fullfile(pathname,filename));
    handles.MagXMLFile=fullfile(pathname,filename);
    guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.MagStruct);
    handles.MagTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.MagTree.getUIContainer,'Units','normalized');
    set(handles.MagTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.MagTreeModel=DefaultTreeModel(Root);
    handles.MagTree.setModel(handles.MagTreeModel);
    % Add searchig path
    path(path,pathname);
else
    errordlg('No Mag is loaded!');
    return;
end
guidata(hObject, handles);

function ChkNode(tree, value, handles)

handles=guidata(handles.MagDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.MagStruct';
if Level=='0'
    eval(['handles.MagNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.MagNode=' Node ';']);
end
handles.MagNodeLvl=Node;
handles.SelNode=SelNode;

if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end

set(handles.MagAttri_uipanel,'Title',['''' char(SelNode.getName) ''' Mag Attribute'],'Unit','normalized');
if SelNode.isLeaf | SelNode.isRoot
    if strcmp(char(SelNode.getName),'Specials')
        DoEditValue(handles,handles.MagAttri_uipanel,handles.MagNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    else
        DoEditValue(handles,handles.MagAttri_uipanel,handles.MagNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    end
else
    guidata(handles.MagDesignPanel_figure, handles);
end


% --- Executes on button press in DelNode_pushbutton.
function DelNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.MagNode.Name
        case 'MRiLabMag'
            errordlg('MRiLabMag Root can not be deleted!');
            return;
    end
    
    eval([handles.MagNodeLvl '=[];']);
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
    handles.MagTree.setSelectedNode(handles.SelNode.getParent);
    handles.MagTreeModel.removeNodeFromParent(handles.SelNode);
    
    DoWriteXML(handles.MagStruct,handles.MagXMLFile);
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
    ChkMagElemListTreeNode(handles.MagElemListTree, [], handles); % In case MagElem.xml updated
    handles=guidata(handles.MagDesignPanel_figure);
    switch handles.MagNode.Name
        case {'MRiLabMag'}
            % add node
            SelNode=handles.MagElemListTree.SelectedNodes;
            SelNode=SelNode(1);
            AddedNode=SelNode.clone;
            switch char(AddedNode.getName)
                case {'MagElem'}
                    errordlg([char(AddedNode.getName) ' can not be added!']);
                    return;
            end
            handles.MagTreeModel.insertNodeInto(AddedNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.MagTree.setSelectedNode(AddedNode); % expand to show added child
            handles.MagTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=AddedNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                AddedNode.setValue([Level; Level(end)+1]);
                eval([handles.MagNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.MagElemNode;']);
                DoWriteXML(handles.MagStruct,handles.MagXMLFile);
            else
                nP=AddedNode.getParent;
                Level=nP.getValue;
                AddedNode.setValue([Level; 1]);
                eval([handles.MagNodeLvl '.Children=handles.MagElemNode;']);
                DoWriteXML(handles.MagStruct,handles.MagXMLFile);
            end
        otherwise
            errordlg(['Mag Element can not be added under ' handles.MagNode.Name '!']);
            return;
    end
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in UpdateMagXML_pushbutton.
function UpdateMagXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateMagXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update Mag XML file
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        switch get(handles.Attrh1.(Attrh1name{i+1}),'Style')
            case 'edit'
                handles.MagNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            case 'checkbox'
                if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
                    handles.MagNode.Attributes((i+1)/2).Value='^1';
                else
                    handles.MagNode.Attributes((i+1)/2).Value='^0';
                end
            case 'popupmenu'
                handles.MagNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh1.(Attrh1name{i+1}),'Value'));
        end
    end
    eval([handles.MagNodeLvl '=handles.MagNode;']);
    DoWriteXML(handles.MagStruct,handles.MagXMLFile);
    % update associated m function
    DoWriteXML2m(handles.MagStruct,[handles.MagXMLFile(1:end-3) 'm']);
end

% update MagSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.MagSimuAttrStruct.Children)
    Attrh2=get(tabs(j),'Children');
    for i=1:2:length(Attrh2)
        if ~iscell(get(Attrh2(end-i),'String'))
            handles.MagSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh2(end-i),'String');
        else
            handles.MagSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh2(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.MagSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'MagElem' filesep 'MagSimuAttr.xml']);

guidata(hObject, handles);



% --- Executes on button press in CopSelNode_pushbutton.
function CopNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CopSelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.MagNode.Name
        case 'MRiLabMag'
            errordlg('MRiLabMag Root can not be copied!');
            return;
    end
    handles.CopSelNode=handles.SelNode.clone;
    handles.CopMagNode=handles.MagNode;
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
    switch handles.MagNode.Name
        case {'MRiLabMag'}
            % paste node
            handles.MagTreeModel.insertNodeInto(handles.CopSelNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.MagTree.setSelectedNode(handles.CopSelNode); % expand to show added child
            handles.MagTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=handles.CopSelNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; Level(end)+1]);
                eval([handles.MagNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CopMagNode;']);
                DoWriteXML(handles.MagStruct,handles.MagXMLFile);
            else
                nP=handles.CopSelNode.getParent;
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; 1]);
                eval([handles.MagNodeLvl '.Children=handles.CopMagNode;']);
                DoWriteXML(handles.MagStruct,handles.MagXMLFile);
            end
        otherwise
            errordlg(['Mag Element can not be added under ' handles.MagNode.Name '!']);
            return;
    end
    handles.CopSelNode=[];
    handles.CopMagNode=[];
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in MagExecute_pushbutton.
function MagExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MagExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoPlotMagFie(handles);
    set(handles.Forwards_pushbutton,'Enable','on');
    set(handles.Backwards_pushbutton,'Enable','on');
    set(handles.Display_pushbutton,'Enable','on');
catch me
    error_msg{1,1}='Error occurred at displaying dB0 field.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end
set(hObject,'Enable','on');
set(hObject,'String','Execute');

% --------------------------------------------------------------------
function SavePanel_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoSaveSnapshot(handles.MagDesignPanel_figure);


% --- Executes when user attempts to close MagDesignPanel_figure.
function MagDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MagDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
DoUpdateSlice(handles.MagField_axes,handles.dB0,handles.IV,'Mag');
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
DoUpdateSlice(handles.MagField_axes,handles.dB0,handles.IV,'Mag');
guidata(hObject, handles);


% --------------------------------------------------------------------
function Cursor_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Cursor_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'dcm')
    handles.dcm=datacursormode(handles.MagDesignPanel_figure);
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
global VMmg;

handles=guidata(handles.MagDesignPanel_figure);
pos = get(event_obj,'Position');
pos(1)=round((pos(1)+VCtl.ISO(1)*VObj.XDimRes)/VMmg.xdimres);
pos(2)=round((pos(2)+VCtl.ISO(2)*VObj.YDimRes)/VMmg.ydimres);
pos(3)=round((pos(3)+VCtl.ISO(3)*VObj.ZDimRes)/VMmg.zdimres);

output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)],...
    ['Z: ',num2str(pos(3),4)],...
    ['Value: ',num2str(handles.dB0(pos(2),pos(1),pos(3)),4)]};


% --------------------------------------------------------------------
function NewMag_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewMag_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewMagFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewMagFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter NEW mag name:','Enter NEW mag note:'};
dlg_title = 'Input for creating new mag';
num_lines = 1;
def = {'Mag_CustomHead','Customized dB0 Field Head Magnet'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    warndlg('No new mag file is created!');
    return
end
if isempty(answer{1})
    warndlg('No new mag file is created!');
    return
end
if ~strcmp(answer{1}(1:4),'Mag_')
    warndlg('Mag name must have a prefix ''Mag_'', please rename your mag!');
    return
end
magpath=uigetdir(pwd,'Specify a saving path for new mag file.');
if magpath==0
    warndlg('You have to specify a saving path!');
    return;
end

% Create new mag file
mkdir([magpath filesep answer{1}]); % make folder
copyfile([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Mag' filesep 'Head' filesep 'Mag_LinearHead' filesep 'Mag_LinearHead.xml'],...
    [magpath filesep answer{1} filesep answer{1} '.xml']); % copy mag temple
% Add searchig path
path(path,[magpath filesep answer{1}]);
% Load new mag file
import javax.swing.*;
import javax.swing.tree.*;
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end
handles.MagStruct=DoParseXML([magpath filesep answer{1} filesep answer{1} '.xml']);
for i=1:length(handles.MagStruct.Attributes)
    if strcmp(handles.MagStruct.Attributes(i).Name,'Name')
        handles.MagStruct.Attributes(i).Value = answer{1};
    elseif strcmp(handles.MagStruct.Attributes(i).Name,'Notes')
        handles.MagStruct.Attributes(i).Value = answer{2};
    end
end
DoWriteXML(handles.MagStruct,[magpath filesep answer{1} filesep answer{1} '.xml']); %update new mag file
handles.MagXMLFile=[magpath filesep answer{1} filesep answer{1} '.xml'];
DoWriteXML2m(handles.MagStruct,[handles.MagXMLFile(1:end-3) 'm']);
guidata(hObject, handles);
Root=DoConvStruct2Tree(handles.MagStruct);
handles.MagTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
set(handles.MagTree.getUIContainer,'Units','normalized');
set(handles.MagTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
handles.MagTreeModel=DefaultTreeModel(Root);
handles.MagTree.setModel(handles.MagTreeModel);
cla(handles.MagField_axes);
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function MagDesignPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MagDesignPanel_figure (see GCBO)
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

assignin('base', 'dB0', handles.dB0);
MU_Matrix_Display('dB0','Magnitude');
