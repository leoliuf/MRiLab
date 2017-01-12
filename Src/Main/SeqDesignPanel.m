
function varargout = SeqDesignPanel(varargin)
% SEQDESIGNPANEL M-file for SeqDesignPanel.fig
%      SEQDESIGNPANEL, by itself, creates a new SEQDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = SEQDESIGNPANEL returns the handle to a new SEQDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      SEQDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEQDESIGNPANEL.M with the given input arguments.
%
%      SEQDESIGNPANEL('Property','Value',...) creates a new SEQDESIGNPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SeqDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SeqDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SeqDesignPanel

% Last Modified by GUIDE v2.5 10-Apr-2014 19:24:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SeqDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @SeqDesignPanel_OutputFcn, ...
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


% --- Executes just before SeqDesignPanel is made visible.
function SeqDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SeqDesignPanel (see VARARGIN)

global VCtl;
handles.Simuh=varargin{1};
% Load Pulse element list
try
    handles.SeqElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.SeqElemListStruct);
    handles.SeqElemListTree=uitree('V0','Root',Root,'SelectionChangeFcn',{@ChkSeqElemListTreeNode,handles});
    set(handles.SeqElemListTree.getUIContainer,'Units','normalized');
    set(handles.SeqElemListTree.getUIContainer,'Position',[0.0,0.58,0.15,0.4]);
    
    handles.Attrh1=[];
catch ME
    errordlg('Seq element list can not be loaded!');
    close(hObject);
    return;
end

%Load tabs for Seq Simulation
try
    handles.SeqSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqSimuAttr.xml']);
catch ME
    errordlg('SeqSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.SeqDesignPanel_figure,handles);
for i=1:length(handles.SeqSimuAttrStruct.Children)
    eval(['handles.' handles.SeqSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.SeqSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.SeqSimuAttrStruct.Children(i).Name '_tab,handles.SeqSimuAttrStruct.Children(' num2str(i) ').Attributes,2,[0.50,0.50,0.0,0.05,0.05,0.02]);']);
    handles=guidata(handles.SeqDesignPanel_figure);
end

%Open current loaded Seq XML file
if isfield(handles.Simuh,'SeqXMLFile')
    import javax.swing.*
    import javax.swing.tree.*;
    handles.SeqStruct=DoParseXML(handles.Simuh.SeqXMLFile);
    handles.SeqXMLFile=handles.Simuh.SeqXMLFile;
    DoWriteXML2m(handles.SeqStruct,[handles.SeqXMLFile(1:end-3) 'm']);
    %     guidata(hObject, handles);
    Root=DoConvStruct2Tree(handles.SeqStruct);
    handles.SeqTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.SeqTree.getUIContainer,'Units','normalized');
    set(handles.SeqTree.getUIContainer,'Position',[0.158,0.58,0.17,0.4]);
    handles.SeqTreeModel=DefaultTreeModel(Root);
    handles.SeqTree.setModel(handles.SeqTreeModel);
    handles.ResetAxes = 1;
    try
        DoPlotDiagm(handles);
        set(handles.Checker_togglebutton,'Enable','on');
        set(handles.LeftEnd_pushbutton,'Enable','on');
        set(handles.Left_pushbutton,'Enable','on');
        set(handles.Zoomout_pushbutton,'Enable','on');
        set(handles.Ori_pushbutton,'Enable','on');
        set(handles.All_pushbutton,'Enable','on');
        set(handles.Zoomin_pushbutton,'Enable','on');
        set(handles.Right_pushbutton,'Enable','on');
        set(handles.RightEnd_pushbutton,'Enable','on');
        set(handles.Kspace_pushbutton,'Enable','on');
        handles=guidata(hObject);
    catch me
        error_msg{1,1}='ERROR!!! Plotting sequence waveform aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
    end
end

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% Choose default command line output for SeqDesignPanel
handles.input=varargin;
handles.output=hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SeqDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.SeqDesignPanel_figure);


function ChkSeqElemListTreeNode(tree, value, handles)

handles=guidata(handles.SeqDesignPanel_figure);
handles.SeqElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqElem.xml']); %In case SeqElem.xml updated
SelNode=tree.SelectedNodes;
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.SeqElemListStruct';
if Level=='0'
    eval(['handles.SeqElemNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.SeqElemNode=' Node ';']);
end
guidata(handles.SeqDesignPanel_figure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SeqDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --- Executes on button press in Ori_pushbutton.
function Ori_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Ori_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global VCtl;
Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[Xlim(1) Xlim(1)+VCtl.TR],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));


% --- Executes on button press in Zoomin_pushbutton.
function Zoomin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Zoomin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[Xlim(1)+(Xlim(2)-Xlim(1))/4 Xlim(2)-(Xlim(2)-Xlim(1))/4],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --- Executes on button press in Zoomout_pushbutton.
function Zoomout_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Zoomout_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[Xlim(1)-(Xlim(2)-Xlim(1)) Xlim(2)+(Xlim(2)-Xlim(1))],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --- Executes on button press in Right_pushbutton.
function Right_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Right_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[Xlim(1)+(Xlim(2)-Xlim(1))/10 Xlim(2)+(Xlim(2)-Xlim(1))/10],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --- Executes on button press in Left_pushbutton.
function Left_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Left_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[Xlim(1)-(Xlim(2)-Xlim(1))/10 Xlim(2)-(Xlim(2)-Xlim(1))/10],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --- Executes on button press in Kspace_pushbutton.
function Kspace_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Kspace_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoTrajK(handles);
catch me
    error_msg{1,1}='Error occurred at plotting K-Space trajectory.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end
set(hObject,'Enable','on');
set(hObject,'String','K-Space');

% --------------------------------------------------------------------
function LoadSeq_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSeq_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadSeqFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSeqFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;
global VCtl;

[filename,pathname,filterindex]=uigetfile({'PSD*.xml','XML-files (*.xml)'},'MultiSelect','off');
if filename~=0
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    
    handles.SeqStruct=DoParseXML(fullfile(pathname,filename));
    handles.SeqXMLFile=fullfile(pathname,filename);
    %     guidata(hObject, handles);
    
    try
        set(handles.rf_axes,'XLim',[0 VCtl.TR]);
        DoPlotDiagm(handles);
        set(handles.Checker_togglebutton,'Enable','on');
        set(handles.LeftEnd_pushbutton,'Enable','on');
        set(handles.Left_pushbutton,'Enable','on');
        set(handles.Zoomout_pushbutton,'Enable','on');
        set(handles.Ori_pushbutton,'Enable','on');
        set(handles.All_pushbutton,'Enable','on');
        set(handles.Zoomin_pushbutton,'Enable','on');
        set(handles.Right_pushbutton,'Enable','on');
        set(handles.RightEnd_pushbutton,'Enable','on');
        set(handles.Kspace_pushbutton,'Enable','on');
        handles=guidata(hObject);
    catch me
        error_msg{1,1}='ERROR!!! Plotting seq diagram aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        return;
    end
    
    Root=DoConvStruct2Tree(handles.SeqStruct);
    handles.SeqTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
    set(handles.SeqTree.getUIContainer,'Units','normalized');
    set(handles.SeqTree.getUIContainer,'Position',[0.158,0.58,0.17,0.4]);
    handles.SeqTreeModel=DefaultTreeModel(Root);
    handles.SeqTree.setModel(handles.SeqTreeModel);
    % Add searchig path
    path(path,pathname);
else
    errordlg('No Seq is loaded!');
    return;
end
guidata(hObject, handles);

function ChkNode(tree, value, handles)

handles=guidata(handles.SeqDesignPanel_figure);
SelNode=handles.SeqTree.SelectedNodes;
if isempty(SelNode)
    return;
end
SelNode=SelNode(1);
Level=SelNode.getValue;
if ~ischar(Level)
    LevelChg=diff(Level,1);
    Level([LevelChg; -1]==1)=[];
end

Node='handles.SeqStruct';
if Level=='0'
    eval(['handles.SeqNode=' Node ';']);
else
    for i=1:length(Level)
        Node=[Node '.Children(' num2str(Level(i)) ')'];
    end
    eval(['handles.SeqNode=' Node ';']);
end
handles.SeqNodeLvl=Node;
handles.SelNode=SelNode;

if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end

if strcmp(char(SelNode.getName),'CVs')
    handles.SelCVs=1;
else
    handles.SelCVs=0;
end

set(handles.SeqAttri_uipanel,'Title',['''' char(SelNode.getName) ''' Attribute'],'Unit','normalized');
if SelNode.isLeaf | SelNode.isRoot | strcmp(char(SelNode.getName),'Pulses')
    if strcmp(char(SelNode.getName),'Specials')
        DoEditValue(handles,handles.SeqAttri_uipanel,handles.SeqNode.Attributes,1,[0.8,0.1,0.0,0.05,0.05,0.02]);
    else
        DoEditValue(handles,handles.SeqAttri_uipanel,handles.SeqNode.Attributes,1,[0.4,0.6,0.0,0.05,0.05,0.008]);
    end
else
    guidata(handles.SeqDesignPanel_figure, handles);
end


% --- Executes on button press in DelNode_pushbutton.
function DelNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.SeqNode.Name
        case 'MRiLabSeq'
            errordlg('MRiLabSeq Root can not be deleted!');
            return;
        case {'CVs' 'SE' 'Specials'}
            errordlg(['MRiLabSeq basic structure ' handles.SeqNode.Name ' can not be deleted!']);
            return;
        case {'rf' 'GzSS' 'GyPE' 'GxR' 'ADC' 'Ext'}
            errordlg(['MRiLabSeq basic Pulse line ' handles.SeqNode.Name ' can not be deleted!']);
            return;
        case {'Pulses'}
            if handles.SelNode.getParent.getChildCount == 3
                errordlg(['Minimum number of one Pulses is required!']);
                return;
            end
            
            % remove Pulses & reload root
            eval([handles.SeqNodeLvl '=[];']);
            DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
            
            Root=DoConvStruct2Tree(handles.SeqStruct);
            handles.SeqTreeModel=DefaultTreeModel(Root);
            handles.SeqTree.setModel(handles.SeqTreeModel);
            handles.SeqTree.setSelectedNode(Root);
            handles.ResetAxes = 1;
            
            guidata(hObject, handles);
            return;
    end
    
    eval([handles.SeqNodeLvl '=[];']);
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
    handles.SeqTree.setSelectedNode(handles.SelNode.getParent);
    handles.SeqTreeModel.removeNodeFromParent(handles.SelNode);
    
    DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
    
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
    ChkSeqElemListTreeNode(handles.SeqElemListTree, [], handles); % In case SeqElem.xml updated
    handles=guidata(handles.SeqDesignPanel_figure);
    switch handles.SeqNode.Name
        case {'rf' 'GzSS' 'GyPE' 'GxR' 'ADC' 'Ext'}
            % add node
            SelNode=handles.SeqElemListTree.SelectedNodes;
            SelNode=SelNode(1);
            AddedNode=SelNode.clone;
            switch char(AddedNode.getName)
                case {'SeqElem' 'rf' 'GzSS' 'GyPE' 'GxR' 'ADC' 'Ext'}
                    errordlg([char(AddedNode.getName) ' can not be added!']);
                    return;
            end
            handles.SeqTreeModel.insertNodeInto(AddedNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.SeqTree.setSelectedNode(AddedNode); % expand to show added child
            handles.SeqTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=AddedNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                AddedNode.setValue([Level; Level(end)+1]);
                eval([handles.SeqNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.SeqElemNode;']);
                DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
            else
                nP=AddedNode.getParent;
                Level=nP.getValue;
                AddedNode.setValue([Level; 1]);
                eval([handles.SeqNodeLvl '.Children=handles.SeqElemNode;']);
                DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
            end
        otherwise
            errordlg(['Elementary Pulse can not be added under ' handles.SeqNode.Name '!']);
            return;
    end
    guidata(hObject, handles);
    
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end
% --- Executes on button press in CopSelNode_pushbutton.
function CopNode_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to CopSelNode_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

import javax.swing.*
import javax.swing.tree.*;

try
    switch handles.SeqNode.Name
        case 'MRiLabSeq'
            errordlg('MRiLabSeq Root can not be copied!');
            return;
        case {'CVs' 'SE' 'Specials'}
            errordlg(['MRiLabSeq basic structure ' handles.SeqNode.Name ' can not be copied!']);
            return;
        case {'rf' 'GzSS' 'GyPE' 'GxR' 'ADC' 'Ext'}
            errordlg(['MRiLabSeq basic Pulse line ' handles.SeqNode.Name ' can not be copied!']);
            return;
    end
    handles.CopSelNode=handles.SelNode.clone;
    handles.CopSeqNode=handles.SeqNode;
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
    switch handles.SeqNode.Name
        case {'rf' 'GzSS' 'GyPE' 'GxR' 'ADC' 'Ext' 'MRiLabSeq'}
            if strcmp(handles.SeqNode.Name,'MRiLabSeq')
                if ~strcmp(handles.CopSeqNode.Name,'Pulses')
                    errordlg(['Elementary Pulse can not be added under MRiLabSeq root!']);
                    return;
                end
            end
            % paste node
            handles.SeqTreeModel.insertNodeInto(handles.CopSelNode,handles.SelNode,handles.SelNode.getChildCount());
            handles.SeqTree.setSelectedNode(handles.CopSelNode); % expand to show added child
            handles.SeqTree.setSelectedNode(handles.SelNode); % insure additional nodes are added to parent
            
            nP=handles.CopSelNode.getPreviousSibling;
            if ~isempty(nP)
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; Level(end)+1]);
                eval([handles.SeqNodeLvl '.Children(' num2str(Level(end)+1) ')=handles.CopSeqNode;']);
                DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
            else
                nP=handles.CopSelNode.getParent;
                Level=nP.getValue;
                handles.CopSelNode.setValue([Level; 1]);
                eval([handles.SeqNodeLvl '.Children=handles.CopSeqNode;']);
                DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
            end
            
            % reload root from XML for properly displaying added Pulses
            if strcmp(handles.SeqNode.Name,'MRiLabSeq')
                if strcmp(handles.CopSeqNode.Name,'Pulses')
                    handles.SeqStruct=DoParseXML(handles.Simuh.SeqXMLFile);
                    Root=DoConvStruct2Tree(handles.SeqStruct);
                    handles.SeqTreeModel=DefaultTreeModel(Root);
                    handles.SeqTree.setModel(handles.SeqTreeModel);
                    handles.SeqTree.setSelectedNode(Root);
                    handles.ResetAxes = 1;
                end
            end
        otherwise
            errordlg(['Elementary Pulse can not be added under ' handles.SeqNode.Name '!']);
            return;
    end
    handles.CopSelNode=[];
    handles.CopSeqNode=[];
    guidata(hObject, handles);
catch me
    error_msg{1,1}='ERROR!!! Node operation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    
end

% --- Executes on button press in UpdateSeqXML_pushbutton.
function UpdateSeqXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateSeqXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update seq XML file & associated m function
if isfield(handles,'SeqXMLFile')
    handles.SeqStruct=DoParseXML(handles.SeqXMLFile);
end
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:2:length(Attrh1name)
        switch get(handles.Attrh1.(Attrh1name{i+1}),'Style')
            case 'edit'
                handles.SeqNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            case 'checkbox'
                if get(handles.Attrh1.(Attrh1name{i+1}),'Value')
                    handles.SeqNode.Attributes((i+1)/2).Value='^1';
                else
                    handles.SeqNode.Attributes((i+1)/2).Value='^0';
                end
            case 'popupmenu'
                handles.SeqNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh1.(Attrh1name{i+1}),'Value'));
        end
        % update CVs tab in SimuPanel
        if handles.SelCVs==1
            set(handles.Simuh.Attrh1.(Attrh1name{i+1}),'String',get(handles.Attrh1.(Attrh1name{i+1}),'String'));
        end
    end
    eval([handles.SeqNodeLvl '=handles.SeqNode;']);
    DoWriteXML(handles.SeqStruct,handles.SeqXMLFile);
    % update associated m function
    DoWriteXML2m(handles.SeqStruct,[handles.SeqXMLFile(1:end-3) 'm']);
    
end

% update SeqSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.SeqSimuAttrStruct.Children)
    Attrh2=get(tabs(j),'Children');
    for i=1:2:length(Attrh2)
        if ~iscell(get(Attrh2(end-i),'String'))
            handles.SeqSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh2(end-i),'String');
        else
            handles.SeqSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh2(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.SeqSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqSimuAttr.xml']);

guidata(hObject, handles);

% --- Executes on button press in SeqExecute_pushbutton.
function SeqExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to SeqExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
try
    DoPlotDiagm(handles);
    set(handles.Checker_togglebutton,'Enable','on');
    set(handles.LeftEnd_pushbutton,'Enable','on');
    set(handles.Left_pushbutton,'Enable','on');
    set(handles.Zoomout_pushbutton,'Enable','on');
    set(handles.Ori_pushbutton,'Enable','on');
    set(handles.All_pushbutton,'Enable','on');
    set(handles.Zoomin_pushbutton,'Enable','on');
    set(handles.Right_pushbutton,'Enable','on');
    set(handles.RightEnd_pushbutton,'Enable','on');
    set(handles.Kspace_pushbutton,'Enable','on');
catch me
    error_msg{1,1}='Error occurred at plotting sequence waveform.';
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
DoSaveSnapshot(handles.SeqDesignPanel_figure);


% --- Executes when user attempts to close SeqDesignPanel_figure.
function SeqDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to SeqDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function SeqDesignPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SeqDesignPanel_figure (see GCBO)
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

if get(handles.Checker_togglebutton,'Value') == 0
    return;
end

axesh=gca;
tpoint=get(axesh,'currentpoint');
Xlim=get(handles.rf_axes,'XLim');
if tpoint(1)<Xlim(1) | tpoint(1)>Xlim(2)
    return;
end

if ~isfield(handles,'XClip')
    handles.XClip=tpoint(1);
else
    handles.XClip(end+1)=tpoint(1);
end

if mod(length(handles.XClip),2)==1
    hold(handles.rf_axes,'on');
    plot(handles.rf_axes,[handles.XClip(end) handles.XClip(end)],[-1.5 1.5],'g-');
    set(gcf,'CurrentAxes',handles.rf_axes);
    text(handles.XClip(end),1.7,['P' num2str(length(handles.XClip))],'Color','g');
    hold(handles.rf_axes,'off');
else
    hold(handles.rf_axes,'on');
    plot(handles.rf_axes,[handles.XClip(end) handles.XClip(end)],[-1.5 1.5],'r-');
    set(gcf,'CurrentAxes',handles.rf_axes);
    text(handles.XClip(end),1.7,['P' num2str(length(handles.XClip))],'Color','r');
    hold(handles.rf_axes,'off');
    set(handles.rf_axes,'XLim',[min(handles.XClip(end-1:end)) max(handles.XClip(end-1:end))],'YLim',[-1.5 1.5]);
    set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms
end

if ~isfield(handles,'PSeries')
    handles.PSeriesInd=1;
end

handles.PSeries(handles.PSeriesInd,:)={num2str(length(handles.XClip)), ...
    num2str(tpoint(1)*1000),...
    get(handles.rfV_text,'String'), ...
    get(handles.GzV_text,'String'), ...
    get(handles.GyV_text,'String'), ...
    get(handles.GxV_text,'String'), ...
    get(handles.ADCV_text,'String'), ...
    get(handles.rfPEV_text,'String'), ...
    get(handles.rfFreqV_text,'String'), ...
    get(handles.ExtV_text,'String')};
handles.PSeriesInd=handles.PSeriesInd+1;
set(handles.P_uitable,'Data',flipud(handles.PSeries));

guidata(hObject, handles);


% --------------------------------------------------------------------
function NewSeq_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewSeq_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NewSeqFile_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to NewSeqFile_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt = {'Enter NEW sequence name:','Enter NEW sequence note:'};
dlg_title = 'Input for creating new sequence';
num_lines = 1;
def = {'PSD_Custom','Customized PSD'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    warndlg('No new sequence file is created!');
    return
end
if isempty(answer{1})
    warndlg('No new sequence file is created!');
    return
end
if ~strcmp(answer{1}(1:4),'PSD_')
    warndlg('Seq name must have a prefix ''PSD_'', please rename your sequence!');
    return
end
seqpath=uigetdir(pwd,'Specify a saving path for new sequence file.');
if seqpath==0
    warndlg('You have to specify a saving path!');
    return;
end

% Create new sequence file
mkdir([seqpath filesep answer{1}]); % make folder
copyfile([handles.Simuh.MRiLabPath filesep 'PSD' filesep '3D' filesep 'GradientEcho' filesep 'PSD_GRE3D' filesep 'PSD_GRE3D.xml'],...
    [seqpath filesep answer{1} filesep answer{1} '.xml']); % copy sequence temple
% Add searchig path
path(path,[seqpath filesep answer{1}]);
% Load new sequence file
import javax.swing.*;
import javax.swing.tree.*;
if ~isempty(handles.Attrh1)
    Attrh1name=fieldnames(handles.Attrh1);
    for i=1:length(Attrh1name)
        delete(handles.Attrh1.(Attrh1name{i}));
    end
    handles.Attrh1=[];
end
handles.SeqStruct=DoParseXML([seqpath filesep answer{1} filesep answer{1} '.xml']);
for i=1:length(handles.SeqStruct.Attributes)
    if strcmp(handles.SeqStruct.Attributes(i).Name,'Name')
        handles.SeqStruct.Attributes(i).Value = answer{1};
    elseif strcmp(handles.SeqStruct.Attributes(i).Name,'Notes')
        handles.SeqStruct.Attributes(i).Value = answer{2};
    end
end
DoWriteXML(handles.SeqStruct,[seqpath filesep answer{1} filesep answer{1} '.xml']); %update new sequence file
handles.SeqXMLFile=[seqpath filesep answer{1} filesep answer{1} '.xml'];
DoWriteXML2m(handles.SeqStruct,[handles.SeqXMLFile(1:end-3) 'm']);
guidata(hObject, handles);
try
    DoPlotDiagm(handles);
    set(handles.Checker_togglebutton,'Enable','on');
    set(handles.LeftEnd_pushbutton,'Enable','on');
    set(handles.Left_pushbutton,'Enable','on');
    set(handles.Zoomout_pushbutton,'Enable','on');
    set(handles.Ori_pushbutton,'Enable','on');
    set(handles.All_pushbutton,'Enable','on');
    set(handles.Zoomin_pushbutton,'Enable','on');
    set(handles.Right_pushbutton,'Enable','on');
    set(handles.RightEnd_pushbutton,'Enable','on');
    set(handles.Kspace_pushbutton,'Enable','on');
    handles=guidata(hObject);
catch me
    error_msg{1,1}='ERROR!!! Plotting sequence diagram aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

Root=DoConvStruct2Tree(handles.SeqStruct);
handles.SeqTree=uitree('V0','Root',Root,'SelectionChangeFcn', {@ChkNode,handles});
set(handles.SeqTree.getUIContainer,'Units','normalized');
set(handles.SeqTree.getUIContainer,'Position',[0.158,0.58,0.17,0.4]);
handles.SeqTreeModel=DefaultTreeModel(Root);
handles.SeqTree.setModel(handles.SeqTreeModel);
guidata(hObject, handles);


% --- Executes on mouse motion over figure - except title and menu.
function SeqDesignPanel_figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to SeqDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.Checker_togglebutton,'Value') == 0
    return;
end
try
    tabs=get(handles.rf_tabgroup,'Children');
catch me
    return;
end
for i=1:length(tabs)
    if verLessThan('matlab','8.5')
        if strcmp(get(tabs(i),'Visible'),'on')
            if handles.rfCurrentCoil ~= handles.rfCoil(i)
                eval(['handles.rf_axes=handles.rf' num2str(handles.rfCoil(i)) '_axes;']);
                eval(['handles.rfAmps=handles.rfAmps' num2str(handles.rfCoil(i)) ';']);
                eval(['handles.rfPhases=handles.rfPhases' num2str(handles.rfCoil(i)) ';']);
                eval(['handles.rfFreqs=handles.rfFreqs' num2str(handles.rfCoil(i)) ';']);
                eval(['handles.rfTime=handles.rfTime' num2str(handles.rfCoil(i)) ';']);
                handles.rfCurrentCoil = handles.rfCoil(i);
                guidata(hObject, handles);
            end
            break;
        end
    else
        tabtitle=get(get(handles.rf_tabgroup,'SelectedTab'),'Title');
        if str2double(tabtitle(3:end))==i
            if handles.rfCurrentCoil ~= handles.rfCoil(i)
                eval(['handles.rf_axes=handles.rf' num2str(handles.rfCoil(i)) '_axes;']);
                eval(['handles.rfAmps=handles.rfAmps' num2str(handles.rfCoil(i)) ';']);
                eval(['handles.rfPhases=handles.rfPhases' num2str(handles.rfCoil(i)) ';']);
                eval(['handles.rfFreqs=handles.rfFreqs' num2str(handles.rfCoil(i)) ';']);
                eval(['handles.rfTime=handles.rfTime' num2str(handles.rfCoil(i)) ';']);
                handles.rfCurrentCoil = handles.rfCoil(i);
                guidata(hObject, handles);
            end
            break;
        end
    end
end

tpoint=get(handles.rf_axes,'currentpoint');
Xlim=get(handles.rf_axes,'XLim');
if tpoint(1)<Xlim(1) | tpoint(1)>Xlim(2)
    set(gcf,'Pointer','arrow');
    return;
end

if tpoint(3)<-22.4 | tpoint(3)>1.5
    set(gcf,'Pointer','arrow');
    return;
end

if tpoint(3)>-22.4 | tpoint(3)<1.5
    set(gcf,'Pointer','fullcross');
    
    set(handles.Time_text,'String',[num2str(tpoint(1)*1000,'%4.5e') 'ms']);
    
    ind=find(tpoint(1)<handles.rfTime);
    if ~isempty(ind)
        set(handles.rfV_text,'String',num2str(handles.rfAmps(ind(1)),'%4.2e'));
        set(handles.rfPEV_text,'String',num2str(handles.rfPhases(ind(1))));
        set(handles.rfFreqV_text,'String',num2str(handles.rfFreqs(ind(1))));
        
        ind=find(tpoint(1)<handles.GzTime);
        set(handles.GzV_text,'String',num2str(handles.GzAmps(ind(1))));
        
        ind=find(tpoint(1)<handles.GyTime);
        set(handles.GyV_text,'String',num2str(handles.GyAmps(ind(1))));
        
        ind=find(tpoint(1)<handles.GxTime);
        set(handles.GxV_text,'String',num2str(handles.GxAmps(ind(1))));
        
        ind=find(tpoint(1)<handles.ADCTime);
        set(handles.ADCV_text,'String',num2str(handles.ADCs(ind(1))));
        
        ind=find(tpoint(1)<handles.ExtTime);
        set(handles.ExtV_text,'String',num2str(handles.Exts(ind(1))));
        
    end
    
end


% --- Executes on button press in All_pushbutton.
function All_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to All_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.rf_axes,'XLim',[handles.rfTime(1) handles.rfTime(end)],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --- Executes on button press in LeftEnd_pushbutton.
function LeftEnd_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to LeftEnd_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[handles.rfTime(1) handles.rfTime(1)+(Xlim(2)-Xlim(1))],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));



% --- Executes on button press in RightEnd_pushbutton.
function RightEnd_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RightEnd_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[handles.rfTime(end)-(Xlim(2)-Xlim(1)) handles.rfTime(end)],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --- Executes on button press in Checker_togglebutton.
function Checker_togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Checker_togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Checker_togglebutton


% --- Executes when selected cell(s) is changed in P_uitable.
function P_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to P_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

P = get(hObject,'Data');
try
    time = str2double(P{eventdata.Indices(1), 2})/1000;
catch me
    return;
end
Xlim=get(handles.rf_axes,'XLim');
set(handles.rf_axes,'XLim',[time time+(Xlim(2)-Xlim(1))],'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

Xlim=get(handles.rf_axes,'XLim');
set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));

% --------------------------------------------------------------------
function EditXML_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to EditXML_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit(handles.SeqXMLFile);

% --------------------------------------------------------------------
function RefreshSeq_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshSeq_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    %refresh current loaded Seq tree
    import javax.swing.*;
    import javax.swing.tree.*;
    
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:length(Attrh1name)
            delete(handles.Attrh1.(Attrh1name{i}));
        end
        handles.Attrh1=[];
    end
    
    handles.SeqStruct=DoParseXML(handles.SeqXMLFile);
    DoWriteXML2m(handles.SeqStruct,[handles.SeqXMLFile(1:end-3) 'm']);
    
    DoPlotDiagm(handles);
    set(handles.Checker_togglebutton,'Enable','on');
    set(handles.LeftEnd_pushbutton,'Enable','on');
    set(handles.Left_pushbutton,'Enable','on');
    set(handles.Zoomout_pushbutton,'Enable','on');
    set(handles.Ori_pushbutton,'Enable','on');
    set(handles.All_pushbutton,'Enable','on');
    set(handles.Zoomin_pushbutton,'Enable','on');
    set(handles.Right_pushbutton,'Enable','on');
    set(handles.RightEnd_pushbutton,'Enable','on');
    set(handles.Kspace_pushbutton,'Enable','on');
    handles=guidata(hObject);
    
    Root=DoConvStruct2Tree(handles.SeqStruct);
    handles.SeqTreeModel=DefaultTreeModel(Root);
    handles.SeqTree.setModel(handles.SeqTreeModel);
    handles.SeqTree.setSelectedNode(Root);
    handles.ResetAxes = 1;
catch me
    error_msg{1,1}='ERROR!!! XML refresh aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end
guidata(hObject, handles);

% --------------------------------------------------------------------
function XML_uimenu_Callback(hObject, eventdata, handles)
% hObject    handle to XML_uimenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Left_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Left_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Left_edit as text
%        str2double(get(hObject,'String')) returns contents of Left_edit as a double

Left=str2num(get(handles.Left_edit,'String'));
Right=str2num(get(handles.Right_edit,'String'));
if Left>=Right
    Xlim=get(handles.rf_axes,'XLim');
    set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
    set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));
    return;
end

set(handles.rf_axes,'XLim',[Left Right]/1000,'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

% --- Executes during object creation, after setting all properties.
function Left_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Left_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Right_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Right_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Right_edit as text
%        str2double(get(hObject,'String')) returns contents of Right_edit as a double

Left=str2num(get(handles.Left_edit,'String'));
Right=str2num(get(handles.Right_edit,'String'));
if Left>=Right
    Xlim=get(handles.rf_axes,'XLim');
    set(handles.Left_edit,'String',num2str(Xlim(1)*1000,'%4.5e'));
    set(handles.Right_edit,'String',num2str(Xlim(2)*1000,'%4.5e'));
    return;
end

set(handles.rf_axes,'XLim',[Left Right]/1000,'YLim',[-1.5 1.5]);
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

% --- Executes during object creation, after setting all properties.
function Right_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Right_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
