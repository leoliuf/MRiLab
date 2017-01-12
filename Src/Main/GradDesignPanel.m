
function varargout = GradDesignPanel(varargin)
% GRADDESIGNPANEL MATLAB code for GradDesignPanel.fig
%      GRADDESIGNPANEL, by itself, creates a new GRADDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = GRADDESIGNPANEL returns the handle to a new GRADDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      GRADDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRADDESIGNPANEL.M with the given input arguments.
%
%      GRADDESIGNPANEL('Property','Value',...) creates a new GRADDESIGNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GradDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GradDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GradDesignPanel

% Last Modified by GUIDE v2.5 17-Apr-2014 16:37:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GradDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @GradDesignPanel_OutputFcn, ...
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

% --- Executes just before GradDesignPanel is made visible.
function GradDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GradDesignPanel (see VARARGIN)
global VCtl;
global VObj;
global VMgd;

handles.Simuh=varargin{1};
% Load Gradient element list
try
    handles.GradElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'GradElem' filesep 'GradElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.GradElemListStruct);
    handles.GradElemListTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkGradElemListTreeNode,handles});
    set(handles.GradElemListTree.getUIContainer,'Units','normalized');
    set(handles.GradElemListTree.getUIContainer,'Position',[0.0,0.4,0.2,0.58]);
    handles.Attrh1=[];
catch ME
    errordlg('Grad element list can not be loaded!');
    close(hObject);
    return;
end

%Load tabs for Grad Simulation
try
    handles.GradSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'GradElem' filesep 'GradSimuAttr.xml']);
catch ME
    errordlg('GradSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.GradDesignPanel_figure,handles);
for i=1:length(handles.GradSimuAttrStruct.Children)
    eval(['handles.' handles.GradSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.GradSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.GradSimuAttrStruct.Children(i).Name '_tab,handles.GradSimuAttrStruct.Children(' num2str(i) ').Attributes,2,[0.2,0.15,0.0,0.15,0.15,0.05]);']);
    handles=guidata(handles.GradDesignPanel_figure);
end

% Create grid and display structure
VMgd.xdimres=str2num(get(handles.Attrh2.('XDimRes'),'String'));
VMgd.ydimres=str2num(get(handles.Attrh2.('YDimRes'),'String'));
VMgd.zdimres=str2num(get(handles.Attrh2.('ZDimRes'),'String'));

[VMgd.xgrid,VMgd.ygrid,VMgd.zgrid]=meshgrid((-VCtl.ISO(1)+1)*VObj.XDimRes:VMgd.xdimres:(VObj.XDim-VCtl.ISO(1))*VObj.XDimRes,...
    (-VCtl.ISO(2)+1)*VObj.YDimRes:VMgd.ydimres:(VObj.YDim-VCtl.ISO(2))*VObj.YDimRes,...
    (-VCtl.ISO(3)+1)*VObj.ZDimRes:VMgd.zdimres:(VObj.ZDim-VCtl.ISO(3))*VObj.ZDimRes);

VMgd.axes=handles.GradField_axes;
handles.IV=struct(...
    'xslice',0,...
    'yslice',0,...
    'zslice',0 ...
    );
view(handles.GradField_axes,3);

%Open current loaded Grad XML file
if isfield(handles.Simuh,'GradXMLFile')
    import javax.swing.*
    import javax.swing.tree.*;
    handles.GradStruct=DoParseXML(handles.Simuh.GradXMLFile);
    handles.GradXMLFile=handles.Simuh.GradXMLFile;
    DoWriteXML2m(handles.GradStruct,[handles.GradXMLFile(1:end-3) 'm']);
    %     guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.GradStruct);
    handles.GradTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.GradTree.getUIContainer,'Units','normalized');
    set(handles.GradTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.GradTreeModel=DefaultTreeModel(Root);
    handles.GradTree.setModel(handles.GradTreeModel);
    try
        DoPlotGradFie(handles);
        set(handles.Forwards_pushbutton,'Enable','on');
        set(handles.Backwards_pushbutton,'Enable','on');
        handles=guidata(hObject);
    catch me
        error_msg{1,1}='ERROR!!! Displaying gradient field aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
    end
    
end

% Choose default command line output for GradDesignPanel
handles.input=varargin;
handles.output=hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GradDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.GradDesignPanel_figure);


function ChkGradElemListTreeNode(tree, value, handles)

handles=guidata(handles.GradDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.GradElemListStruct';
if Level=='0'
    eval(['handles.GradElemNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.GradElemNode=' Node ';']);
end
guidata(handles.GradDesignPanel_figure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GradDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --------------------------------------------------------------------
function LoadGrad_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadGrad_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadGradFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadGradFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

[filename,pathname,filterindex]=uigetfile({'Grad*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    handles.GradStruct=DoParseXML(fullfile(pathname,filename));
    handles.GradXMLFile=fullfile(pathname,filename);
    guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.GradStruct);
    handles.GradTree=uitree('v0', 'Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.GradTree.getUIContainer,'Units','normalized');
    set(handles.GradTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
    handles.GradTreeModel=DefaultTreeModel(Root);
    handles.GradTree.setModel(handles.GradTreeModel);
    % Add searchig path
    path(path,pathname);
else
    errordlg('No Grad is loaded!');
    return;
end
guidata(hObject, handles);

function ChkNode(tree, value, handles)

handles=guidata(handles.GradDesignPanel_figure);
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.GradStruct';
if Level=='0'
    eval(['handles.GradNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.GradNode=' Node ';']);
end
handles.GradNodeLvl=Node;
handles.SelNode=SelNode;

if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end

set(handles.GradAttri_uipanel,'Title',['''' char(SelNode.getName) ''' Grad Attribute'],'Unit','normalized');
if SelNode.isLeaf | SelNode.isRoot
    if strcmp(char(SelNode.getName),'Specials')
        DoEditValue(handles,handles.GradAttri_uipanel,handles.GradNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    else
        DoEditValue(handles,handles.GradAttri_uipanel,handles.GradNode.Attributes,1,[0.25,0.25,0.0,0.1,0.1,0.05]);
    end
else
    guidata(handles.GradDesignPanel_figure, handles);
end


% --- Executes on button press in DelNode_pushbutton.
function DelNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.GradNode.Name
        case 'MRiLabGrad'
            errordlg('MRiLabGrad Root can not be deleted!');
            return;
    end
    
    eval([handles.GradNodeLvl '=[];']);
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
    handles.GradTree.setSelectedNode(handles.SelNode.getParent);
    handles.GradTreeModel.removeNodeFromParent(handles.SelNode);
    
    DoWriteXML(handles.GradStruct,handles.GradXMLFile);
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
    ChkGradElemListTreeNode(handles.GradElemListTree, [], handles); % In case GradElem.xml updated
    handles=guidata(handles.GradDesignPanel_figure);
    switch handles.GradNode.Name
        case {'MRiLabGrad'}
            % add node
            SelNode=handles.GradElemListTree.SelectedNodes;
            SelNode=SelNode(1);
            AddedNode=SelNode.clone;
            switch char(AddedNode.getName)
                case {'GradElem'}
                    errordlg([char(AddedNode.getName) ' can not be added!']);
                    return;
            end
            handles.GradTreeModel.insertNodeInto(AddedNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.GradTree.setSelectedNode(AddedNode); % expand to show added child
            handles.GradTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=AddedNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                AddedNode.setValue([Level; Level(end)+1]);
                eval([handles.GradNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.GradElemNode;']);
                DoWriteXML(handles.GradStruct,handles.GradXMLFile);
            else
                nP=AddedNode.getParent;
                Level=nP.getValue;
                AddedNode.setValue([Level; 1]);
                eval([handles.GradNodeLvl '.Children=handles.GradElemNode;']);
                DoWriteXML(handles.GradStruct,handles.GradXMLFile);
            end
        otherwise
            errordlg(['Grad Element can not be added under ' handles.GradNode.Name '!']);
            return;
    end
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in UpdateGradXML_pushbutton.
function UpdateGradXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateGradXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update Grad XML file
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        switch get(handles.Attrh1.(Attrh1name{i+1}),'Style')
            case 'edit'
                handles.GradNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            case 'checkbox'
                if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
                    handles.GradNode.Attributes((i+1)/2).Value='^1';
                else
                    handles.GradNode.Attributes((i+1)/2).Value='^0';
                end
            case 'popupmenu'
                handles.GradNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh1.(Attrh1name{i+1}),'Value'));
        end
    end
    eval([handles.GradNodeLvl '=handles.GradNode;']);
    DoWriteXML(handles.GradStruct,handles.GradXMLFile);
    % update associated m function
    DoWriteXML2m(handles.GradStruct,[handles.GradXMLFile(1:end-3) 'm']);
end

% update GradSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.GradSimuAttrStruct.Children)
    Attrh2=get(tabs(j),'Children');
    for i=1:2:length(Attrh2)
        if ~iscell(get(Attrh2(end-i),'String'))
            handles.GradSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh2(end-i),'String');
        else
            handles.GradSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh2(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.GradSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'GradElem' filesep 'GradSimuAttr.xml']);

guidata(hObject, handles);



% --- Executes on button press in CopSelNode_pushbutton.
function CopNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CopSelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.GradNode.Name
        case 'MRiLabGrad'
            errordlg('MRiLabGrad Root can not be copied!');
            return;
    end
    handles.CopSelNode=handles.SelNode.clone;
    handles.CopGradNode=handles.GradNode;
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
    switch handles.GradNode.Name
        case {'MRiLabGrad'}
            % paste node
            handles.GradTreeModel.insertNodeInto(handles.CopSelNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.GradTree.setSelectedNode(handles.CopSelNode); % expand to show added child
            handles.GradTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=handles.CopSelNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; Level(end)+1]);
                eval([handles.GradNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CopGradNode;']);
                DoWriteXML(handles.GradStruct,handles.GradXMLFile);
            else
                nP=handles.CopSelNode.getParent;
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; 1]);
                eval([handles.GradNodeLvl '.Children=handles.CopGradNode;']);
                DoWriteXML(handles.GradStruct,handles.GradXMLFile);
            end
        otherwise
            errordlg(['Grad Element can not be added under ' handles.GradNode.Name '!']);
            return;
    end
    handles.CopSelNode=[];
    handles.CopGradNode=[];
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in GradExecute_pushbutton.
function GradExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to GradExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoPlotGradFie(handles);
    set(handles.Forwards_pushbutton,'Enable','on');
    set(handles.Backwards_pushbutton,'Enable','on');
catch me
    error_msg{1,1}='Error occurred at displaying gradient field.';
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
DoSaveSnapshot(handles.GradDesignPanel_figure);


% --- Executes when user attempts to close GradDesignPanel_figure.
function GradDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to GradDesignPanel_figure (see GCBO)
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
DoUpdateSlice(handles.GradField_axes,handles.G,handles.IV,'Grad');
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
DoUpdateSlice(handles.GradField_axes,handles.G,handles.IV,'Grad');
guidata(hObject, handles);


% --------------------------------------------------------------------
function Cursor_uitoggletool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Cursor_uitoggletool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles,'dcm')
    handles.dcm=datacursormode(handles.GradDesignPanel_figure);
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
global VMgd;

handles=guidata(handles.GradDesignPanel_figure);
pos = get(event_obj,'Position');
pos(1)=round((pos(1)+VCtl.ISO(1)*VObj.XDimRes)/VMgd.xdimres);
pos(2)=round((pos(2)+VCtl.ISO(2)*VObj.YDimRes)/VMgd.ydimres);
pos(3)=round((pos(3)+VCtl.ISO(3)*VObj.ZDimRes)/VMgd.zdimres);

output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)],...
    ['Z: ',num2str(pos(3),4)],...
    ['Value: ',num2str(handles.G(pos(2),pos(1),pos(3)),4)]};


% --------------------------------------------------------------------
function NewGrad_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewGrad_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewGradFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewGradFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter NEW grad name:','Enter NEW grad note:'};
dlg_title = 'Input for creating new grad';
num_lines = 1;
def = {'Grad_CustomHead','Customized Gradient Field for Head'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    warndlg('No new grad file is created!');
    return
end
if isempty(answer{1})
    warndlg('No new grad file is created!');
    return
end
if ~strcmp(answer{1}(1:5),'Grad_')
    warndlg('Grad name must have a prefix ''Grad_'', please rename your grad!');
    return
end
gradpath=uigetdir(pwd,'Specify a saving path for new grad file.');
if gradpath==0
    warndlg('You have to specify a saving path!');
    return;
end

% Create new grad file
mkdir([gradpath filesep answer{1}]); % make folder
copyfile([handles.Simuh.MRiLabPath filesep 'Config' filesep 'Grad' filesep 'Head' filesep 'Grad_LinearHead' filesep 'Grad_LinearHead.xml'],...
    [gradpath filesep answer{1} filesep answer{1} '.xml']); % copy grad temple
% Add searchig path
path(path,[gradpath filesep answer{1}]);
% Load new grad file
import javax.swing.*;
import javax.swing.tree.*;
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end
handles.GradStruct=DoParseXML([gradpath filesep answer{1} filesep answer{1} '.xml']);
for i=1:length(handles.GradStruct.Attributes)
    if strcmp(handles.GradStruct.Attributes(i).Name,'Name')
        handles.GradStruct.Attributes(i).Value = answer{1};
    elseif strcmp(handles.GradStruct.Attributes(i).Name,'Notes')
        handles.GradStruct.Attributes(i).Value = answer{2};
    end
end
DoWriteXML(handles.GradStruct,[gradpath filesep answer{1} filesep answer{1} '.xml']); %update new grad file
handles.GradXMLFile=[gradpath filesep answer{1} filesep answer{1} '.xml'];
DoWriteXML2m(handles.GradStruct,[handles.GradXMLFile(1:end-3) 'm']);
guidata(hObject, handles);
Root=DoConvStruct2Tree(handles.GradStruct);
handles.GradTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
set(handles.GradTree.getUIContainer,'Units','normalized');
set(handles.GradTree.getUIContainer,'Position',[0.205,0.4,0.2,0.58]);
handles.GradTreeModel=DefaultTreeModel(Root);
handles.GradTree.setModel(handles.GradTreeModel);
cla(handles.GradField_axes);
guidata(hObject, handles);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function GradDesignPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to GradDesignPanel_figure (see GCBO)
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
