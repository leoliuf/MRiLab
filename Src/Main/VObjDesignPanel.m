
function varargout = VObjDesignPanel(varargin)
% VOBJDESIGNPANEL MATLAB code for VObjDesignPanel.fig
%      VOBJDESIGNPANEL, by itself, creates a new VOBJDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = VOBJDESIGNPANEL returns the handle to a new VOBJDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      VOBJDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOBJDESIGNPANEL.M with the given input arguments.
%
%      VOBJDESIGNPANEL('Property','Value',...) creates a new VOBJDESIGNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VObjDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VObjDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VObjDesignPanel

% Last Modified by GUIDE v2.5 26-Feb-2014 00:23:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @VObjDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @VObjDesignPanel_OutputFcn, ...
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

% --- Executes just before VObjDesignPanel is made visible.
function VObjDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VObjDesignPanel (see VARARGIN)

handles.Simuh=varargin{1};
% Load Pulse element list
try
    handles.VObjElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'VObjElem' filesep 'VObjElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.VObjElemListStruct);
    handles.VObjElemListTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkVObjElemListTreeNode,handles});
    set(handles.VObjElemListTree.getUIContainer,'Units','normalized');
    set(handles.VObjElemListTree.getUIContainer,'Position',[0.0,0.4,0.2,0.58]);
    handles.Attrh1=[];
catch ME
    errordlg('VObj element list can not be loaded!');
    close(hObject);
    return;
end

%Load tabs for VObj Simulation
try
    handles.VObjSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'VObjElem' filesep 'VObjSimuAttr.xml']);
catch ME
    errordlg('VObjSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.VObjDesignPanel_figure,handles);
for i=1:length(handles.VObjSimuAttrStruct.Children)
    eval(['handles.' handles.VObjSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.VObjSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.VObjSimuAttrStruct.Children(i).Name '_tab,handles.VObjSimuAttrStruct.Children(' num2str(i) ').Attributes,2,[0.2,0.15,0.0,0.15,0.15,0.05]);']);
    handles=guidata(handles.VObjDesignPanel_figure);
end

%Open current loaded VObj XML file
if isfield(handles.Simuh,'VObjXMLFile')
    import javax.swing.*
    import javax.swing.tree.*;
    handles.VObjStruct=DoParseXML(handles.Simuh.VObjXMLFile);
    handles.VObjXMLFile=handles.Simuh.VObjXMLFile;
    DoWriteXML2m(handles.VObjStruct,[handles.VObjXMLFile(1:end-3) 'm']);
    %     guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.VObjStruct);
    handles.VObjTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.VObjTree.getUIContainer,'Units','normalized');
    set(handles.VObjTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.VObjTreeModel=DefaultTreeModel(Root);
    handles.VObjTree.setModel(handles.VObjTreeModel);
    try
        DoPlotVObj(handles);
%         handles=guidata(hObject);
    catch me
        error_msg{1,1}='ERROR!!! Displaying 3D object aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
    end
    
end

% cameratoolbar(gcf);

view(handles.VObj_axes,3);

% Choose default command line output for VObjDesignPanel
handles.input=varargin;
handles.output=hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes VObjDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.VObjDesignPanel_figure);


function ChkVObjElemListTreeNode(tree, value, handles)

handles=guidata(handles.VObjDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.VObjElemListStruct';
if Level=='0'
    eval(['handles.VObjElemNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.VObjElemNode=' Node ';']);
end
guidata(handles.VObjDesignPanel_figure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = VObjDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --------------------------------------------------------------------
function LoadVObj_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVObj_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadVObjXMLFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadVObjFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

[filename,pathname,filterindex]=uigetfile({'VObj*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    handles.VObjStruct=DoParseXML(fullfile(pathname,filename));
    handles.VObjXMLFile=fullfile(pathname,filename);
    guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.VObjStruct);
    handles.VObjTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.VObjTree.getUIContainer,'Units','normalized');
    set(handles.VObjTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.VObjTreeModel=DefaultTreeModel(Root);
    handles.VObjTree.setModel(handles.VObjTreeModel);
    % Add searchig path
    path(path,pathname);
else
    errordlg('No VObj XML is loaded!');
    return;
end
guidata(hObject, handles);

function ChkNode(tree, value, handles)

handles=guidata(handles.VObjDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.VObjStruct';
if Level=='0'
    eval(['handles.VObjNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.VObjNode=' Node ';']);
end
handles.VObjNodeLvl=Node;
handles.SelNode=SelNode;

if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end

set(handles.VObjAttri_uipanel,'Title',['''' char(SelNode.getName) ''' VObj Attribute'],'Unit','normalized');
DoEditValue(handles,handles.VObjAttri_uipanel,handles.VObjNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);



% --- Executes on button press in DelNode_pushbutton.
function DelNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.VObjNode.Name
        case 'MRiLabVObj'
            errordlg('MRiLabVObj Root can not be deleted!');
            return;
        case {'Geometry' 'Property'}
            errordlg([handles.VObjNode.Name ' can not be deleted alone, object is incomplete!']);
            return;
    end
    
%     eval([handles.VObjNodeLvl '=[];']);
%     nN=handles.SelNode.getNextSibling;
%     while ~isempty(nN)
%         Level=nN.getValue;
%         Level(end)=[];
%         nN.setValue(Level);
%         nN=nN.getNextSibling;
%     end
%     guidata(hObject, handles);
%     pause(0.1);
%     
%     % remove node
%     handles.VObjTree.setSelectedNode(handles.SelNode.getParent);
%     handles.VObjTreeModel.removeNodeFromParent(handles.SelNode);
%     
%     DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);

    % remove object & reload root
    eval([handles.VObjNodeLvl '=[];']);
    DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);

    Root=DoConvStruct2Tree(handles.VObjStruct);
    handles.VObjTreeModel=DefaultTreeModel(Root);
    handles.VObjTree.setModel(handles.VObjTreeModel);
    handles.VObjTree.setSelectedNode(Root);
    handles.ResetAxes = 1;

    guidata(hObject, handles);
    return;

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
    ChkVObjElemListTreeNode(handles.VObjElemListTree, [], handles); % In case VObjElem.xml updated
    handles=guidata(handles.VObjDesignPanel_figure);
    switch handles.VObjNode.Name
        case {'MRiLabVObj'}
            % add node
            SelNode=handles.VObjElemListTree.SelectedNodes;
            SelNode=SelNode(1);
            AddedNode=SelNode.clone;
            switch char(AddedNode.getName)
                case {'VObjElem'}
                    errordlg([char(AddedNode.getName) ' can not be added!']);
                    return;
                case {'Geometry' 'Property'}
                    errordlg([char(AddedNode.getName) ' can not be added alone, object is incomplete!']);
                    return;
            end
            handles.VObjTreeModel.insertNodeInto(AddedNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.VObjTree.setSelectedNode(AddedNode); % expand to show added child
            handles.VObjTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=AddedNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                AddedNode.setValue([Level; Level(end)+1]);
                eval([handles.VObjNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.VObjElemNode;']);
                DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);
            else
                nP=AddedNode.getParent;
                Level=nP.getValue;
                AddedNode.setValue([Level; 1]);
                eval([handles.VObjNodeLvl '.Children=handles.VObjElemNode;']);
                DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);
            end
            
            % reload root from XML for properly displaying added Object
            if strcmp(handles.VObjNode.Name,'MRiLabVObj')
                handles.VObjStruct=DoParseXML(handles.VObjXMLFile);
                Root=DoConvStruct2Tree(handles.VObjStruct);
                handles.VObjTreeModel=DefaultTreeModel(Root);
                handles.VObjTree.setModel(handles.VObjTreeModel);
                handles.VObjTree.setSelectedNode(Root);
                handles.ResetAxes = 1;
            end

        otherwise
            errordlg(['VObj Element can not be added under ' handles.VObjNode.Name '!']);
            return;
    end
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in UpdateVObjXML_pushbutton.
function UpdateVObjXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateVObjXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update VObj XML file
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        switch get(handles.Attrh1.(Attrh1name{i+1}),'Style')
            case 'edit'
                handles.VObjNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            case 'checkbox'
                if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
                    handles.VObjNode.Attributes((i+1)/2).Value='^1';
                else
                    handles.VObjNode.Attributes((i+1)/2).Value='^0';
                end
            case 'popupmenu'
                handles.VObjNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh1.(Attrh1name{i+1}),'Value'));
        end
    end
    eval([handles.VObjNodeLvl '=handles.VObjNode;']);
    DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);
    % update associated m function
    DoWriteXML2m(handles.VObjStruct,[handles.VObjXMLFile(1:end-3) 'm']);
end

% update VObjSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.VObjSimuAttrStruct.Children)
    Attrh2=get(tabs(j),'Children');
    for i=1:2:length(Attrh2)
        if ~iscell(get(Attrh2(end-i),'String'))
            handles.VObjSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh2(end-i),'String');
        else
            handles.VObjSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh2(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.VObjSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'VObjElem' filesep 'VObjSimuAttr.xml']);

guidata(hObject, handles);



% --- Executes on button press in CopSelNode_pushbutton.
function CopNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CopSelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.VObjNode.Name
        case 'MRiLabVObj'
            errordlg('MRiLabVObj Root can not be copied!');
            return;
        case {'Geometry' 'Property'}
            errordlg([handles.VObjNode.Name ' can not be copied alone, object is incomplete!']);
            return;
    end
    handles.CopSelNode=handles.SelNode.clone;
    handles.CopVObjNode=handles.VObjNode;
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
    switch handles.VObjNode.Name
        case {'MRiLabVObj'}
            % paste node
            handles.VObjTreeModel.insertNodeInto(handles.CopSelNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.VObjTree.setSelectedNode(handles.CopSelNode); % expand to show added child
            handles.VObjTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=handles.CopSelNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; Level(end)+1]);
                eval([handles.VObjNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CopVObjNode;']);
                DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);
            else
                nP=handles.CopSelNode.getParent;
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; 1]);
                eval([handles.VObjNodeLvl '.Children=handles.CopVObjNode;']);
                DoWriteXML(handles.VObjStruct,handles.VObjXMLFile);
            end
            
            % reload root from XML for properly displaying added Object
            if strcmp(handles.VObjNode.Name,'MRiLabVObj')
                handles.VObjStruct=DoParseXML(handles.VObjXMLFile);
                Root=DoConvStruct2Tree(handles.VObjStruct);
                handles.VObjTreeModel=DefaultTreeModel(Root);
                handles.VObjTree.setModel(handles.VObjTreeModel);
                handles.VObjTree.setSelectedNode(Root);
                handles.ResetAxes = 1;
            end
            
        otherwise
            errordlg(['VObj Element can not be added under ' handles.VObjNode.Name '!']);
            return;
    end
    handles.CopSelNode=[];
    handles.CopVObjNode=[];
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in VObjRender_pushbutton.
function VObjRender_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to VObjRender_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoPlotVObj(handles);
catch me
    error_msg{1,1}='Error occurred at displaying 3D object.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end
set(hObject,'Enable','on');
set(hObject,'String','Render');

% --------------------------------------------------------------------
function SavePanel_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoSaveSnapshot(handles.VObjDesignPanel_figure);


% --- Executes when user attempts to close VObjDesignPanel_figure.
function VObjDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to VObjDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --------------------------------------------------------------------
function Cursor_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Cursor_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'dcm')
    handles.dcm=datacursormode(handles.VObjDesignPanel_figure);
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

handles=guidata(handles.VObjDesignPanel_figure);
pos = get(event_obj,'Position');
pos(1)=round((pos(1)+VCtl.ISO(1)*VObj.XDimRes)/VMmg.xdimres);
pos(2)=round((pos(2)+VCtl.ISO(2)*VObj.YDimRes)/VMmg.ydimres);
pos(3)=round((pos(3)+VCtl.ISO(3)*VObj.ZDimRes)/VMmg.zdimres);

output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)],...
    ['Z: ',num2str(pos(3),4)],...
    ['Value: ',num2str(handles.dB0(pos(2),pos(1),pos(3)),4)]};


% --------------------------------------------------------------------
function NewVObj_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewVObj_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewVObjXMLFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewVObjFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter NEW VObj name:','Enter NEW VObj note:'};
dlg_title = 'Input for creating new VObj';
num_lines = 1;
def = {'VObj_CustomSphere','Customized 3D Sphere Virtual Object'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    warndlg('No new VObj XML file is created!');
    return
end
if isempty(answer{1})
    warndlg('No new VObj XML file is created!');
    return
end
if ~strcmp(answer{1}(1:5),'VObj_')
    warndlg('VObj name must have a prefix ''VObj_'', please rename your VObj!');
    return
end
vobjpath=uigetdir(pwd,'Specify a saving path for new VObj XML file.');
if vobjpath==0
    warndlg('You have to specify a saving path!');
    return;
end

% Create new VObj file
mkdir([vobjpath filesep answer{1}]); % make folder
copyfile([handles.Simuh.MRiLabPath filesep 'Config' filesep 'VObj' filesep 'Head' filesep 'VObj_SphereHead' filesep 'VObj_SphereHead.xml'],...
         [vobjpath filesep answer{1} filesep answer{1} '.xml']); % copy VObj temple
% Add searchig path
path(path,[vobjpath filesep answer{1}]);
% Load new VObj file
import javax.swing.*;
import javax.swing.tree.*;
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end
handles.VObjStruct=DoParseXML([vobjpath filesep answer{1} filesep answer{1} '.xml']);
for i=1:length(handles.VObjStruct.Attributes)
    if strcmp(handles.VObjStruct.Attributes(i).Name,'Name')
        handles.VObjStruct.Attributes(i).Value = answer{1};
    elseif strcmp(handles.VObjStruct.Attributes(i).Name,'Notes')
        handles.VObjStruct.Attributes(i).Value = answer{2};
    end
end
DoWriteXML(handles.VObjStruct,[vobjpath filesep answer{1} filesep answer{1} '.xml']); %update new VObj file
handles.VObjXMLFile=[vobjpath filesep answer{1} filesep answer{1} '.xml'];
DoWriteXML2m(handles.VObjStruct,[handles.VObjXMLFile(1:end-3) 'm']);
guidata(hObject, handles);
Root=DoConvStruct2Tree(handles.VObjStruct);
handles.VObjTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
set(handles.VObjTree.getUIContainer,'Units','normalized');
set(handles.VObjTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
handles.VObjTreeModel=DefaultTreeModel(Root);
handles.VObjTree.setModel(handles.VObjTreeModel);
cla(handles.VObj_axes);
guidata(hObject, handles);

% render object
VObjRender_pushbutton_Callback(handles.VObjRender_pushbutton, eventdata, handles);

% create phantom .mat
VObjCreate_pushbutton_Callback(handles.VObjCreate_pushbutton, eventdata, handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function VObjDesignPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to VObjDesignPanel_figure (see GCBO)
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


% --- Executes on button press in VObjCreate_pushbutton.
function VObjCreate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to VObjCreate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Create...');
pause(0.01);
try
    DoWriteXML2m(DoParseXML(handles.VObjXMLFile),[handles.VObjXMLFile(1:end-3) 'm']);
    clear functions;  % remove the M-functions from the memory
    [pathstr,name,ext]=fileparts(handles.VObjXMLFile);
    eval(['[Obj, VObj]=' name '(1);']);
    save(handles.VObjXMLFile(1:end-4),'VObj');
catch me
    error_msg{1,1}='Error occurred at generating virtual 3D object (VObj).';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end
set(hObject,'Enable','on');
set(hObject,'String','Create');
