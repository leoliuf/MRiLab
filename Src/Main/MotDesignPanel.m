
function varargout = MotDesignPanel(varargin)
% MOTIONDESIGNPANEL MATLAB code for MotDesignPanel.fig
%      MOTIONDESIGNPANEL, by itself, creates a new MOTIONDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = MOTIONDESIGNPANEL returns the handle to a new MOTIONDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      MOTIONDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTIONDESIGNPANEL.M with the given input arguments.
%
%      MOTIONDESIGNPANEL('Property','Value',...) creates a new MOTIONDESIGNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MotDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MotDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MotDesignPanel

% Last Modified by GUIDE v2.5 11-Jul-2013 22:48:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MotDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @MotDesignPanel_OutputFcn, ...
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

% --- Executes just before MotDesignPanel is made visible.
function MotDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MotDesignPanel (see VARARGIN)

handles.Simuh=varargin{1};
% Load Pulse element list
try
    handles.MotElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'MotElem' filesep 'MotElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.MotElemListStruct);
    handles.MotElemListTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkMotElemListTreeNode,handles});
    set(handles.MotElemListTree.getUIContainer,'Units','normalized');
    set(handles.MotElemListTree.getUIContainer,'Position',[0.0,0.4,0.2,0.58]);
    handles.Attrh1=[];
catch ME
    errordlg('Mot element list can not be loaded!');
    close(hObject);
    return;
end

%Load tabs for Mot Simulation
try
    handles.MotSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'MotElem' filesep 'MotSimuAttr.xml']);
catch ME
    errordlg('MotSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.MotDesignPanel_figure,handles);
for i=1:length(handles.MotSimuAttrStruct.Children)
    eval(['handles.' handles.MotSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.MotSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.MotSimuAttrStruct.Children(i).Name '_tab,handles.MotSimuAttrStruct.Children(' num2str(i) ').Attributes,2,[0.2,0.15,0.0,0.15,0.15,0.05]);']);
    handles=guidata(handles.MotDesignPanel_figure);
end

%Open current loaded Mot XML file
if isfield(handles.Simuh,'MotXMLFile')
    import javax.swing.*
    import javax.swing.tree.*;
    handles.MotStruct=DoParseXML(handles.Simuh.MotXMLFile);
    handles.MotXMLFile=handles.Simuh.MotXMLFile;
    DoWriteXML2m(handles.MotStruct,[handles.MotXMLFile(1:end-3) 'm']);
    %     guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.MotStruct);
    handles.MotTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.MotTree.getUIContainer,'Units','normalized');
    set(handles.MotTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.MotTreeModel=DefaultTreeModel(Root);
    handles.MotTree.setModel(handles.MotTreeModel);
    %     DoPlotMotFie(handles);
    %     handles=guidata(hObject);
end

% Choose default command line output for MotDesignPanel
handles.input=varargin;
handles.output=hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MotDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.MotDesignPanel_figure);


function ChkMotElemListTreeNode(tree, value, handles)

handles=guidata(handles.MotDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.MotElemListStruct';
if Level=='0'
    eval(['handles.MotElemNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.MotElemNode=' Node ';']);
end
guidata(handles.MotDesignPanel_figure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MotDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --------------------------------------------------------------------
function LoadMotFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadMotFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

[filename,pathname,filterindex]=uigetfile({'Mot*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    handles.MotStruct=DoParseXML(fullfile(pathname,filename));
    handles.MotXMLFile=fullfile(pathname,filename);
    guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.MotStruct);
    handles.MotTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.MotTree.getUIContainer,'Units','normalized');
    set(handles.MotTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.MotTreeModel=DefaultTreeModel(Root);
    handles.MotTree.setModel(handles.MotTreeModel);
    % Add searchig path
    path(path,pathname);
else
    errordlg('No Mot is loaded!');
    return;
end
guidata(hObject, handles);

function ChkNode(tree, value, handles)

handles=guidata(handles.MotDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.MotStruct';
if Level=='0'
    eval(['handles.MotNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.MotNode=' Node ';']);
end
handles.MotNodeLvl=Node;
handles.SelNode=SelNode;

if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end

set(handles.MotAttri_uipanel,'Title',['''' char(SelNode.getName) ''' Mot Attribute'],'Unit','normalized');
if SelNode.isLeaf | SelNode.isRoot
    if strcmp(char(SelNode.getName),'Specials')
        DoEditValue(handles,handles.MotAttri_uipanel,handles.MotNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    else
        DoEditValue(handles,handles.MotAttri_uipanel,handles.MotNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    end
else
    guidata(handles.MotDesignPanel_figure, handles);
end


% --- Executes on button press in DelNode_pushbutton.
function DelNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.MotNode.Name
        case 'MRiLabMot'
            errordlg('MRiLabMot Root can not be deleted!');
            return;
    end
    
    eval([handles.MotNodeLvl '=[];']);
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
    handles.MotTree.setSelectedNode(handles.SelNode.getParent);
    handles.MotTreeModel.removeNodeFromParent(handles.SelNode);
    
    DoWriteXML(handles.MotStruct,handles.MotXMLFile);
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
    ChkMotElemListTreeNode(handles.MotElemListTree, [], handles); % In case MotElem.xml updated
    handles=guidata(handles.MotDesignPanel_figure);
    switch handles.MotNode.Name
        case {'MRiLabMot'}
            % add node
            SelNode=handles.MotElemListTree.SelectedNodes;
            SelNode=SelNode(1);
            AddedNode=SelNode.clone;
            switch char(AddedNode.getName)
                case {'MotElem'}
                    errordlg([char(AddedNode.getName) ' can not be added!']);
                    return;
            end
            handles.MotTreeModel.insertNodeInto(AddedNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.MotTree.setSelectedNode(AddedNode); % expand to show added child
            handles.MotTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=AddedNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                AddedNode.setValue([Level; Level(end)+1]);
                eval([handles.MotNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.MotElemNode;']);
                DoWriteXML(handles.MotStruct,handles.MotXMLFile);
            else
                nP=AddedNode.getParent;
                Level=nP.getValue;
                AddedNode.setValue([Level; 1]);
                eval([handles.MotNodeLvl '.Children=handles.MotElemNode;']);
                DoWriteXML(handles.MotStruct,handles.MotXMLFile);
            end
        otherwise
            errordlg(['Mot Element can not be added under ' handles.MotNode.Name '!']);
            return;
    end
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in UpdateMotXML_pushbutton.
function UpdateMotXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateMotXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update Mot XML file
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        switch get(handles.Attrh1.(Attrh1name{i+1}),'Style')
            case 'edit'
                handles.MotNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            case 'checkbox'
                if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
                    handles.MotNode.Attributes((i+1)/2).Value='^1';
                else
                    handles.MotNode.Attributes((i+1)/2).Value='^0';
                end
        end
    end
    eval([handles.MotNodeLvl '=handles.MotNode;']);
    DoWriteXML(handles.MotStruct,handles.MotXMLFile);
    % update associated m function
    DoWriteXML2m(handles.MotStruct,[handles.MotXMLFile(1:end-3) 'm']);
end

% update MotSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.MotSimuAttrStruct.Children)
    Attrh2=get(tabs(j),'Children');
    for i=1:2:length(Attrh2)
        if ~iscell(get(Attrh2(end-i),'String'))
            handles.MotSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh2(end-i),'String');
        else
            handles.MotSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh2(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.MotSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'MotElem' filesep 'MotSimuAttr.xml']);

guidata(hObject, handles);



% --- Executes on button press in CopSelNode_pushbutton.
function CopNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CopSelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.MotNode.Name
        case 'MRiLabMot'
            errordlg('MRiLabMot Root can not be copied!');
            return;
    end
    handles.CopSelNode=handles.SelNode.clone;
    handles.CopMotNode=handles.MotNode;
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
    switch handles.MotNode.Name
        case {'MRiLabMot'}
            % paste node
            handles.MotTreeModel.insertNodeInto(handles.CopSelNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.MotTree.setSelectedNode(handles.CopSelNode); % expand to show added child
            handles.MotTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=handles.CopSelNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; Level(end)+1]);
                eval([handles.MotNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CopMotNode;']);
                DoWriteXML(handles.MotStruct,handles.MotXMLFile);
            else
                nP=handles.CopSelNode.getParent;
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; 1]);
                eval([handles.MotNodeLvl '.Children=handles.CopMotNode;']);
                DoWriteXML(handles.MotStruct,handles.MotXMLFile);
            end
        otherwise
            errordlg(['Mot Element can not be added under ' handles.MotNode.Name '!']);
            return;
    end
    handles.CopSelNode=[];
    handles.CopMotNode=[];
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in MotExecute_pushbutton.
function MotExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to MotExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoMotionGen(handles);
catch me
    error_msg{1,1}='Error occurred at generating motion trajectory.';
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
DoSaveSnapshot(handles.MotDesignPanel_figure);


% --- Executes when user attempts to close MotDesignPanel_figure.
function MotDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to MotDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewMotFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewMotFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter NEW Mot name:','Enter NEW Mot note:'};
dlg_title = 'Input for creating new Mot';
num_lines = 1;
def = {'Mot_CustomHead','Customized Head Motion'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    warndlg('No new Mot file is created!');
    return
end
if isempty(answer{1})
    warndlg('No new Mot file is created!');
    return
end
if ~strcmp(answer{1}(1:4),'Mot_')
    warndlg('Mot name must have a prefix ''Mot_'', please rename your Mot!');
    return
end
Motpath=uigetdir(pwd,'Specify a saving path for new Mot file.');
if Motpath==0
    warndlg('You have to specify a saving path!');
    return;
end

% Create new Mot file
mkdir([Motpath filesep answer{1}]); % make folder
copyfile([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Mot' filesep 'Head' filesep 'Mot_ShiftHead' filesep 'Mot_ShiftHead.xml'],...
    [Motpath filesep answer{1} filesep answer{1} '.xml']); % copy Mot temple
% Add searchig path
path(path,[Motpath filesep answer{1}]);
% Load new Mot file
import javax.swing.*;
import javax.swing.tree.*;
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end
handles.MotStruct=DoParseXML([Motpath filesep answer{1} filesep answer{1} '.xml']);
for i=1:length(handles.MotStruct.Attributes)
    if strcmp(handles.MotStruct.Attributes(i).Name,'Name')
        handles.MotStruct.Attributes(i).Value = answer{1};
    elseif strcmp(handles.MotStruct.Attributes(i).Name,'Notes')
        handles.MotStruct.Attributes(i).Value = answer{2};
    end
end
DoWriteXML(handles.MotStruct,[Motpath filesep answer{1} filesep answer{1} '.xml']); %update new Mot file
handles.MotXMLFile=[Motpath filesep answer{1} filesep answer{1} '.xml'];
DoWriteXML2m(handles.MotStruct,[handles.MotXMLFile(1:end-3) 'm']);
guidata(hObject, handles);
Root=DoConvStruct2Tree(handles.MotStruct);
handles.MotTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
set(handles.MotTree.getUIContainer,'Units','normalized');
set(handles.MotTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
handles.MotTreeModel=DefaultTreeModel(Root);
handles.MotTree.setModel(handles.MotTreeModel);
guidata(hObject, handles);


% --- Executes on button press in Play_pushbutton.
function Play_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Play_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

DoPlay3DMotion(handles);
