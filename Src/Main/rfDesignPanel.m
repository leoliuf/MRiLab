
function varargout = rfDesignPanel(varargin)
% RFDESIGNPANEL M-file for rfDesignPanel.fig
%      RFDESIGNPANEL, by itself, creates a new RFDESIGNPANEL or raises the existing
%      singleton*.
%
%      H = RFDESIGNPANEL returns the handle to a new RFDESIGNPANEL or the handle to
%      the existing singleton*.
%
%      RFDESIGNPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RFDESIGNPANEL.M with the given input arguments.
%
%      RFDESIGNPANEL('Property','Value',...) creates a new RFDESIGNPANEL or
%      raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rfDesignPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rfDesignPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above Gz_text to modify the response to help rfDesignPanel

% Last Modified by GUIDE v2.5 20-Jan-2014 15:46:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @rfDesignPanel_OpeningFcn, ...
    'gui_OutputFcn',  @rfDesignPanel_OutputFcn, ...
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


% --- Executes just before rfDesignPanel is made visible.
function rfDesignPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rfDesignPanel (see VARARGIN)

handles.Simuh=varargin{1};
% Load pulse element list
try
    handles.SeqElemListStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqElem.xml']);
    guidata(hObject,handles);
    Root=DoConvStruct2Tree(handles.SeqElemListStruct);
    handles.SeqElemListTree=uitree('v0','Root',Root,'SelectionChangeFcn', {@ChkSeqElemListTreeNode,handles});
    set(handles.SeqElemListTree.getUIContainer,'Units','normalized');
    set(handles.SeqElemListTree.getUIContainer,'Position',[0.0,0.2,0.125,0.8]);
    handles.Attrh0=[];
    handles.Attrh1=[];
    handles.Attrh2=[];
    handles.Attrh3=[];
    handles.Attrh4=[];
catch ME
    errordlg('SeqElem.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.SeqAttri_tabgroup=uitabgroup(handles.SeqAttri_uipanel);
handles.rf_tab=uitab( handles.SeqAttri_tabgroup, 'title', 'rf');
handles.Gz_tab=uitab( handles.SeqAttri_tabgroup, 'title', 'Gz');
handles.Gy_tab=uitab( handles.SeqAttri_tabgroup, 'title', 'Gy');
handles.Gx_tab=uitab( handles.SeqAttri_tabgroup, 'title', 'Gx');

%Load tabs for Spin Property & Gradient
try
    handles.rfSimuAttrStruct=DoParseXML([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'rfSimuAttr.xml']);
catch ME
    errordlg('rfSimuAttr.xml file is missing or can not be loaded!');
    close(hObject);
    return;
end

handles.Setting_tabgroup=uitabgroup(handles.Setting_uipanel);
guidata(handles.rfDesignPanel_figure,handles);
for i=1:length(handles.rfSimuAttrStruct.Children)
    eval(['handles.' handles.rfSimuAttrStruct.Children(i).Name '_tab=uitab( handles.Setting_tabgroup,' '''title'',' '''' handles.rfSimuAttrStruct.Children(i).Name ''',''Units'',''normalized'');']);
    eval(['DoEditValue(handles,handles.' handles.rfSimuAttrStruct.Children(i).Name '_tab,handles.rfSimuAttrStruct.Children(' num2str(i) ').Attributes,0,[0.25,0.25,0.0,0.08,0.08,0.02]);']);
    handles=guidata(handles.rfDesignPanel_figure);
end

%Create tabs for Slice Profile
handles.SliProfile_tabgroup=uitabgroup(handles.SliProfile_uipanel);
handles.MxMyMz_tab=uitab(handles.SliProfile_tabgroup,'title','Mx My Mz','Units','normalized');
handles.MxyMz_tab=uitab(handles.SliProfile_tabgroup,'title','|Mxy| Mz','Units','normalized');
handles.MP_tab=uitab(handles.SliProfile_tabgroup,'title','Mg Pe','Units','normalized');
handles.MxMyMz_axes=axes('parent', handles.MxMyMz_tab,'Position', [0.06 0.1 0.88 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
handles.MxyMz_axes=axes('parent', handles.MxyMz_tab,'Position', [0.06 0.1 0.88 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
handles.MP_axes=axes('parent', handles.MP_tab,'Position', [0.06 0.1 0.88 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);

%Create tabs for XYZ Gradient
handles.G_tabgroup=uitabgroup(handles.Gradient_uipanel);
handles.Gradz_tab=uitab(handles.G_tabgroup,'title','Gz (G/cm)','Units','normalized');
handles.Grady_tab=uitab(handles.G_tabgroup,'title','Gy (G/cm)','Units','normalized');
handles.Gradx_tab=uitab(handles.G_tabgroup,'title','Gx (G/cm)','Units','normalized');
handles.Gz_axes=axes('parent', handles.Gradz_tab,'Position', [0.06 0.1 0.88 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
handles.Gy_axes=axes('parent', handles.Grady_tab,'Position', [0.06 0.1 0.88 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
handles.Gx_axes=axes('parent', handles.Gradx_tab,'Position', [0.06 0.1 0.88 0.85],'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);

% Choose default command line output for rfDesignPanel
handles.output=hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes rfDesignPanel wait for user response (see UIRESUME)
% uiwait(handles.rfDesignPanel_figure);

function ChkSeqElemListTreeNode(tree, value, handles)

handles=guidata(handles.rfDesignPanel_figure);
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

set(handles.SeqAttri_uipanel,'Title',['Checking ''' char(SelNode.getName) '''']);
if SelNode.isLeaf | SelNode.isRoot
    
    if strcmp(handles.SeqElemNode.Name(1:2),'rf') & length(handles.SeqElemNode.Name)>2
        
        if ~isempty(handles.Attrh1)
            Attrh1name=fieldnames(handles.Attrh1);
            for i=1:length(Attrh1name)
                delete(handles.Attrh1.(Attrh1name{i}));
            end
            handles.Attrh1=[];
        end
        handles.rfNode=handles.SeqElemNode;
        handles.rfNodeLvl=Node;
        set(handles.rf_tab,'Title',['rf:' handles.SeqElemNode.Name]);
        DoEditValue(handles,handles.rf_tab,handles.SeqElemNode.Attributes,1,[0.50,0.50,0.0,0.05,0.05,0.005]);
        
        %----load rf memo
        fid=fopen([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'rf' filesep handles.SeqElemNode.Name '_Memo.txt'],'r');
        if fid==-1
            set(handles.rfMemo_edit,'String','rf Memo is not available!');
        else
            tline = fgetl(fid);
            i=1;
            while ischar(tline)
                Memo{i,1}=tline;
                tline = fgetl(fid);
                i=i+1;
            end
            if i==1
                set(handles.rfMemo_edit,'String','rf Memo is empty!');
            else
                set(handles.rfMemo_edit,'String',Memo);
            end
            fclose(fid);
        end
        %----end
        set(handles.UpdateAttrXML_pushbutton,'Enable','on');
     elseif strcmp(handles.SeqElemNode.Name(1:2),'Gz') & length(handles.SeqElemNode.Name)>4
        
        if ~isempty(handles.Attrh2)
            Attrh2name=fieldnames(handles.Attrh2);
            for i=1:length(Attrh2name)
                delete(handles.Attrh2.(Attrh2name{i}));
            end
            handles.Attrh2=[];
        end
        handles.GzNode=handles.SeqElemNode;
        handles.GzNodeLvl=Node;
        set(handles.Gz_tab,'Title',['Gz:' handles.SeqElemNode.Name]);
        DoEditValue(handles,handles.Gz_tab,handles.SeqElemNode.Attributes,2,[0.50,0.50,0.0,0.05,0.05,0.015]);
        set(handles.UpdateAttrXML_pushbutton,'Enable','on');
     elseif strcmp(handles.SeqElemNode.Name(1:2),'Gy') & length(handles.SeqElemNode.Name)>4
         
        if ~isempty(handles.Attrh3)
            Attrh3name=fieldnames(handles.Attrh3);
            for i=1:length(Attrh3name)
                delete(handles.Attrh3.(Attrh3name{i}));
            end
            handles.Attrh3=[];
        end
        handles.GyNode=handles.SeqElemNode;
        handles.GyNodeLvl=Node;
        set(handles.Gy_tab,'Title',['Gy:' handles.SeqElemNode.Name]);
        DoEditValue(handles,handles.Gy_tab,handles.SeqElemNode.Attributes,3,[0.50,0.50,0.0,0.05,0.05,0.015]);
        set(handles.UpdateAttrXML_pushbutton,'Enable','on');
     elseif strcmp(handles.SeqElemNode.Name(1:2),'Gx') & length(handles.SeqElemNode.Name)>4
        
        if ~isempty(handles.Attrh4)
            Attrh4name=fieldnames(handles.Attrh4);
            for i=1:length(Attrh4name)
                delete(handles.Attrh4.(Attrh4name{i}));
            end
            handles.Attrh4=[];
        end
        handles.GxNode=handles.SeqElemNode;
        handles.GxNodeLvl=Node;
        set(handles.Gx_tab,'Title',['Gx:' handles.SeqElemNode.Name]);
        DoEditValue(handles,handles.Gx_tab,handles.SeqElemNode.Attributes,4,[0.50,0.50,0.0,0.05,0.05,0.015]);
        set(handles.UpdateAttrXML_pushbutton,'Enable','on');
    end
else
    guidata(handles.rfDesignPanel_figure, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = rfDesignPanel_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = hObject;


% --- Executes on slider movement.
function rf_slider_Callback(hObject, eventdata, handles)
% hObject    handle to rf_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% set(handles.rf_line,'XData',[get(hObject,'Value'),get(hObject,'Value')]','YData',[min(handles.rfAmp) max(handles.rfAmp)]');


rf_step=round(get(hObject,'Value'));
[az,el] = view(handles.SpinRot_axes);

if strcmp(handles.Freq_Flag,'off') & strcmp(handles.Spat_Flag,'off')
    
    Mx=handles.Mx(:,:,:,:,:,rf_step);
    My=handles.My(:,:,:,:,:,rf_step);
    Mz=handles.Mz(:,:,:,:,:,rf_step);
    Mxy=sqrt(Mx.^2+My.^2);
    Pe=angle(Mx+1i.*My);
    for j=1:str2double(get(handles.Attrh0.TypeNum,'String'))
        spinver=quiver3(handles.SpinRot_axes,handles.Gxgrid,handles.Gygrid,handles.Gzgrid,Mx(:,:,:,:,j),My(:,:,:,:,j),Mz(:,:,:,:,j));
        set(spinver,'AutoScale','off');
        hold(handles.SpinRot_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MxMyMz_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(My(:,:,:,:,j)),'Color',[0 1-(j-1)*0.25 0],'linewidth',2);
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MxyMz_axes,'on');
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MP_axes,'on');
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Pe(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
    end
    hold(handles.SpinRot_axes,'off');
    hold(handles.MxMyMz_axes,'off');
    hold(handles.MxyMz_axes,'off');
    hold(handles.MP_axes,'off');
    
    set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[min(handles.Gzgrid,[],3)-1 max(handles.Gzgrid,[],3)+1]);
    xlabel(handles.SpinRot_axes,'X axis');
    ylabel(handles.SpinRot_axes,'Y axis');
    zlabel(handles.SpinRot_axes,'Z axis (Gradient Direction)');
    set(handles.SpinRot_axes,'view',[az,el]);
    
    set(handles.MxMyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxMyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxMyMz_axes,'Mx','My','Mz');
    
    set(handles.MxyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxyMz_axes,'|Mxy|','Mz');
    
    set(handles.MP_axes,'YLim',[-pi pi],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MP_axes,'YGrid','on','XGrid','on');
    legend(handles.MP_axes,'Mg','Pe');
    
else
    updateSS(handles, rf_step);
end

plot(handles.rf_axes,handles.rfTime,handles.rfAmp,...
    [handles.Muts(rf_step) handles.Muts(rf_step)],[min(handles.rfAmp) max(handles.rfAmp)],'g-','linewidth',2);
set(handles.rf_axes,'YLim',[min(handles.rfAmp) max(handles.rfAmp)],'XLim',[min(handles.rfTime) max(handles.rfTime)]);
set(handles.rf_axes,'YGrid','on','XGrid','on');
%set(handles.SpinRot_axes,'ZTickLabel',get(handles.SpinRot_axes,'ZTick')*10);
%set(handles.MxMyMz_axes,'XTickLabel',get(handles.MxMyMz_axes,'XTick')*100);
set(handles.rf_axes,'XTickLabel',get(handles.rf_axes,'XTick')*1000);
set(handles.rf_axes,'YTickLabel',get(handles.rf_axes,'YTick')*10000);
set(handles.rfFreq_axes,'YTickLabel',get(handles.rfFreq_axes,'YTick')/1000);

% --- Executes during object creation, after setting all properties.
function rf_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rf_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Right_pushbutton.
function Right_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Right_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el] = view(handles.SpinRot_axes);
Starti=round(get(handles.rf_slider,'Value'));
for i=Starti+1:max(size(handles.Muts))
    handles=guidata(hObject);
    if handles.PauseFlag==1
        return;
    end
    set(handles.rf_slider,'Value',i);
    rf_step=round(get(handles.rf_slider,'Value'));
    
    if strcmp(handles.Freq_Flag,'off') & strcmp(handles.Spat_Flag,'off')
        
        Mx=handles.Mx(:,:,:,:,:,rf_step);
        My=handles.My(:,:,:,:,:,rf_step);
        Mz=handles.Mz(:,:,:,:,:,rf_step);
        Mxy=sqrt(Mx.^2+My.^2);
        Pe=angle(Mx+1i.*My);
        for j=1:str2double(get(handles.Attrh0.TypeNum,'String'))
            spinver=quiver3(handles.SpinRot_axes,handles.Gxgrid,handles.Gygrid,handles.Gzgrid,Mx(:,:,:,:,j),My(:,:,:,:,j),Mz(:,:,:,:,j));
            set(spinver,'AutoScale','off');
            hold(handles.SpinRot_axes,'on');
            plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
            hold(handles.MxMyMz_axes,'on');
            plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(My(:,:,:,:,j)),'Color',[0 1-(j-1)*0.25 0],'linewidth',2);
            plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
            
            plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
            hold(handles.MxyMz_axes,'on');
            plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
            
            plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
            hold(handles.MP_axes,'on');
            plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Pe(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        end
        hold(handles.SpinRot_axes,'off');
        hold(handles.MxMyMz_axes,'off');
        hold(handles.MxyMz_axes,'off');
        hold(handles.MP_axes,'off');
        
        set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[min(handles.Gzgrid,[],3)-1 max(handles.Gzgrid,[],3)+1]);
        xlabel(handles.SpinRot_axes,'X axis');
        ylabel(handles.SpinRot_axes,'Y axis');
        zlabel(handles.SpinRot_axes,'Z axis (Gradient Direction)');
        set(handles.SpinRot_axes,'view',[az,el]);
        
        set(handles.MxMyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
        set(handles.MxMyMz_axes,'YGrid','on','XGrid','on');
        legend(handles.MxMyMz_axes,'Mx','My','Mz');
        
        set(handles.MxyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
        set(handles.MxyMz_axes,'YGrid','on','XGrid','on');
        legend(handles.MxyMz_axes,'|Mxy|','Mz');
        
        set(handles.MP_axes,'YLim',[-pi pi],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
        set(handles.MP_axes,'YGrid','on','XGrid','on');
        legend(handles.MP_axes,'Mg','Pe');
        
    else
        updateSS(handles, rf_step);
    end
    
    plot(handles.rf_axes,handles.rfTime,handles.rfAmp,...
        [handles.Muts(rf_step) handles.Muts(rf_step)],[min(handles.rfAmp) max(handles.rfAmp)],'g-','linewidth',2);
    set(handles.rf_axes,'YLim',[min(handles.rfAmp) max(handles.rfAmp)],'XLim',[min(handles.rfTime) max(handles.rfTime)]);
    set(handles.rf_axes,'YGrid','on','XGrid','on');
    %set(handles.SpinRot_axes,'ZTickLabel',get(handles.SpinRot_axes,'ZTick')*10);
    %set(handles.MxMyMz_axes,'XTickLabel',get(handles.MxMyMz_axes,'XTick')*100);
    set(handles.rf_axes,'XTickLabel',get(handles.rf_axes,'XTick')*1000);
    set(handles.rf_axes,'YTickLabel',get(handles.rf_axes,'YTick')*10000);
    set(handles.rfFreq_axes,'YTickLabel',get(handles.rfFreq_axes,'YTick')/1000);
    
    pause(0.1);
end


% --- Executes on button press in DoubleRight_pushbutton.
function DoubleRight_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to DoubleRight_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[az,el] = view(handles.SpinRot_axes);
Starti=round(get(handles.rf_slider,'Value'));
for i=Starti+1:max(size(handles.Muts))
    handles=guidata(hObject);
    if handles.PauseFlag==1
        return;
    end
    set(handles.rf_slider,'Value',i);
    rf_step=round(get(handles.rf_slider,'Value'));
    
    if strcmp(handles.Freq_Flag,'off') & strcmp(handles.Spat_Flag,'off')
        
        Mx=handles.Mx(:,:,:,:,:,rf_step);
        My=handles.My(:,:,:,:,:,rf_step);
        Mz=handles.Mz(:,:,:,:,:,rf_step);
        Mxy=sqrt(Mx.^2+My.^2);
        Pe=angle(Mx+1i.*My);
        for j=1:str2double(get(handles.Attrh0.TypeNum,'String'))
            spinver=quiver3(handles.SpinRot_axes,handles.Gxgrid,handles.Gygrid,handles.Gzgrid,Mx(:,:,:,:,j),My(:,:,:,:,j),Mz(:,:,:,:,j));
            set(spinver,'AutoScale','off');
            hold(handles.SpinRot_axes,'on');
            plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
            hold(handles.MxMyMz_axes,'on');
            plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(My(:,:,:,:,j)),'Color',[0 1-(j-1)*0.25 0],'linewidth',2);
            plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
            
            plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
            hold(handles.MxyMz_axes,'on');
            plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
            
            plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
            hold(handles.MP_axes,'on');
            plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Pe(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        end
        hold(handles.SpinRot_axes,'off');
        hold(handles.MxMyMz_axes,'off');
        hold(handles.MxyMz_axes,'off');
        hold(handles.MP_axes,'off');
        
        set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[min(handles.Gzgrid,[],3)-1 max(handles.Gzgrid,[],3)+1]);
        xlabel(handles.SpinRot_axes,'X axis');
        ylabel(handles.SpinRot_axes,'Y axis');
        zlabel(handles.SpinRot_axes,'Z axis (Gradient Direction)');
        set(handles.SpinRot_axes,'view',[az,el]);
        
        set(handles.MxMyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
        set(handles.MxMyMz_axes,'YGrid','on','XGrid','on');
        legend(handles.MxMyMz_axes,'Mx','My','Mz');
        
        set(handles.MxyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
        set(handles.MxyMz_axes,'YGrid','on','XGrid','on');
        legend(handles.MxyMz_axes,'|Mxy|','Mz');
        
        set(handles.MP_axes,'YLim',[-pi pi],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
        set(handles.MP_axes,'YGrid','on','XGrid','on');
        legend(handles.MP_axes,'Mg','Pe');
        
    else
        updateSS(handles, rf_step);
    end
    
    plot(handles.rf_axes,handles.rfTime,handles.rfAmp,...
        [handles.Muts(rf_step) handles.Muts(rf_step)],[min(handles.rfAmp) max(handles.rfAmp)],'g-','linewidth',2);
    set(handles.rf_axes,'YLim',[min(handles.rfAmp) max(handles.rfAmp)],'XLim',[min(handles.rfTime) max(handles.rfTime)]);
    set(handles.rf_axes,'YGrid','on','XGrid','on');
    %set(handles.SpinRot_axes,'ZTickLabel',get(handles.SpinRot_axes,'ZTick')*10);
    %set(handles.MxMyMz_axes,'XTickLabel',get(handles.MxMyMz_axes,'XTick')*100);
    set(handles.rf_axes,'XTickLabel',get(handles.rf_axes,'XTick')*1000);
    set(handles.rf_axes,'YTickLabel',get(handles.rf_axes,'YTick')*10000);
    set(handles.rfFreq_axes,'YTickLabel',get(handles.rfFreq_axes,'YTick')/1000);
    
    pause(0.001);
end


% --- Executes on button press in Leftend_pushbutton.
function Leftend_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Leftend_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.rf_slider,'Value',1);
rf_step=round(get(handles.rf_slider,'Value'));
[az,el] = view(handles.SpinRot_axes);

if strcmp(handles.Freq_Flag,'off') & strcmp(handles.Spat_Flag,'off')
    
    Mx=handles.Mx(:,:,:,:,:,rf_step);
    My=handles.My(:,:,:,:,:,rf_step);
    Mz=handles.Mz(:,:,:,:,:,rf_step);
    Mxy=sqrt(Mx.^2+My.^2);
    Pe=angle(Mx+1i.*My);
    for j=1:str2double(get(handles.Attrh0.TypeNum,'String'))
        spinver=quiver3(handles.SpinRot_axes,handles.Gxgrid,handles.Gygrid,handles.Gzgrid,Mx(:,:,:,:,j),My(:,:,:,:,j),Mz(:,:,:,:,j));
        set(spinver,'AutoScale','off');
        hold(handles.SpinRot_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MxMyMz_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(My(:,:,:,:,j)),'Color',[0 1-(j-1)*0.25 0],'linewidth',2);
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MxyMz_axes,'on');
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MP_axes,'on');
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Pe(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
    end
    hold(handles.SpinRot_axes,'off');
    hold(handles.MxMyMz_axes,'off');
    hold(handles.MxyMz_axes,'off');
    hold(handles.MP_axes,'off');
    
    set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[min(handles.Gzgrid,[],3)-1 max(handles.Gzgrid,[],3)+1]);
    xlabel(handles.SpinRot_axes,'X axis');
    ylabel(handles.SpinRot_axes,'Y axis');
    zlabel(handles.SpinRot_axes,'Z axis (Gradient Direction)');
    set(handles.SpinRot_axes,'view',[az,el]);
    
    set(handles.MxMyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxMyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxMyMz_axes,'Mx','My','Mz');
    
    set(handles.MxyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxyMz_axes,'|Mxy|','Mz');
    
    set(handles.MP_axes,'YLim',[-pi pi],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MP_axes,'YGrid','on','XGrid','on');
    legend(handles.MP_axes,'Mg','Pe');
    
else
    updateSS(handles, rf_step);
end

plot(handles.rf_axes,handles.rfTime,handles.rfAmp,...
    [handles.Muts(rf_step) handles.Muts(rf_step)],[min(handles.rfAmp) max(handles.rfAmp)],'g-','linewidth',2);
set(handles.rf_axes,'YLim',[min(handles.rfAmp) max(handles.rfAmp)],'XLim',[min(handles.rfTime) max(handles.rfTime)]);
set(handles.rf_axes,'YGrid','on','XGrid','on');
%set(handles.SpinRot_axes,'ZTickLabel',get(handles.SpinRot_axes,'ZTick')*10);
%set(handles.MxMyMz_axes,'XTickLabel',get(handles.MxMyMz_axes,'XTick')*100);
set(handles.rf_axes,'XTickLabel',get(handles.rf_axes,'XTick')*1000);
set(handles.rf_axes,'YTickLabel',get(handles.rf_axes,'YTick')*10000);
set(handles.rfFreq_axes,'YTickLabel',get(handles.rfFreq_axes,'YTick')/1000);

% --- Executes on button press in Rightend_pushbutton.
function Rightend_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Rightend_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.rf_slider,'Value',max(size(handles.Muts)));
rf_step=round(get(handles.rf_slider,'Value'));
[az,el] = view(handles.SpinRot_axes);

if strcmp(handles.Freq_Flag,'off') & strcmp(handles.Spat_Flag,'off')
    
    Mx=handles.Mx(:,:,:,:,:,rf_step);
    My=handles.My(:,:,:,:,:,rf_step);
    Mz=handles.Mz(:,:,:,:,:,rf_step);
    Mxy=sqrt(Mx.^2+My.^2);
    Pe=angle(Mx+1i.*My);
    for j=1:str2double(get(handles.Attrh0.TypeNum,'String'))
        spinver=quiver3(handles.SpinRot_axes,handles.Gxgrid,handles.Gygrid,handles.Gzgrid,Mx(:,:,:,:,j),My(:,:,:,:,j),Mz(:,:,:,:,j));
        set(spinver,'AutoScale','off');
        hold(handles.SpinRot_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MxMyMz_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(My(:,:,:,:,j)),'Color',[0 1-(j-1)*0.25 0],'linewidth',2);
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MxyMz_axes,'on');
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,j)),'Color',[0 0 1-(j-1)*0.25],'linewidth',2);
        hold(handles.MP_axes,'on');
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Pe(:,:,:,:,j)),'Color',[1-(j-1)*0.25 0 0],'linewidth',2);
    end
    hold(handles.SpinRot_axes,'off');
    hold(handles.MxMyMz_axes,'off');
    hold(handles.MxyMz_axes,'off');
    hold(handles.MP_axes,'off');
    
    set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[min(handles.Gzgrid,[],3)-1 max(handles.Gzgrid,[],3)+1]);
    xlabel(handles.SpinRot_axes,'X axis');
    ylabel(handles.SpinRot_axes,'Y axis');
    zlabel(handles.SpinRot_axes,'Z axis (Gradient Direction)');
    set(handles.SpinRot_axes,'view',[az,el]);
    
    set(handles.MxMyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxMyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxMyMz_axes,'Mx','My','Mz');
    
    set(handles.MxyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxyMz_axes,'|Mxy|','Mz');
    
    set(handles.MP_axes,'YLim',[-pi pi],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MP_axes,'YGrid','on','XGrid','on');
    legend(handles.MP_axes,'Mg','Pe');
    
else
    updateSS(handles, rf_step);
end

plot(handles.rf_axes,handles.rfTime,handles.rfAmp,...
    [handles.Muts(rf_step) handles.Muts(rf_step)],[min(handles.rfAmp) max(handles.rfAmp)],'g-','linewidth',2);
set(handles.rf_axes,'YLim',[min(handles.rfAmp) max(handles.rfAmp)],'XLim',[min(handles.rfTime) max(handles.rfTime)]);
set(handles.rf_axes,'YGrid','on','XGrid','on');
set(handles.rf_axes,'XTickLabel',get(handles.rf_axes,'XTick')*1000);
set(handles.rf_axes,'YTickLabel',get(handles.rf_axes,'YTick')*10000);
set(handles.rfFreq_axes,'YTickLabel',get(handles.rfFreq_axes,'YTick')/1000);


% --- Executes on button press in rfExecute_pushbutton.
function rfExecute_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rfExecute_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(hObject,'Enable','off');
set(hObject,'String','Calc...');
pause(0.01);
ExecFlag=DorfExec(handles);
set(handles.Simuh.TimeWait_text,'String', ['Est. Time Left :  ' '~' ' : ' '~' ' : ' '~']);
handles=guidata(handles.rfDesignPanel_figure);
if ExecFlag==0
    set(hObject,'Enable','on');
    set(hObject,'String','Execute');
    return;
end
handles.PauseFlag=0;
set(handles.Leftend_pushbutton,'Enable','on');
set(handles.Rightend_pushbutton,'Enable','on');
set(handles.Pause_pushbutton,'Enable','on');
set(handles.Right_pushbutton,'Enable','on');
set(handles.DoubleRight_pushbutton,'Enable','on');
set(handles.rf_slider,'Enable','on');
%% Display
% rf Response & Spin Rotation
if strcmp(handles.Freq_Flag,'off') & strcmp(handles.Spat_Flag,'off')
    if ~isfield(handles,'MxMyMz_tab')
        %----clear tabs
        tabs=get(handles.SliProfile_tabgroup,'Children');
        for i=1:length(tabs)
            delete(get(tabs(i),'Children'));
        end
        delete(tabs);
        delete(handles.SliProfile_tabgroup);
        handles=rmfield(handles,'Mx_tab');
        %----end
        %----recreate tabs
        handles.SliProfile_tabgroup=uitabgroup(handles.SliProfile_uipanel);
        handles.MxMyMz_tab=uitab(handles.SliProfile_tabgroup,'title','Mx My Mz','Units','normalized');
        handles.MxyMz_tab=uitab(handles.SliProfile_tabgroup,'title','|Mxy| Mz','Units','normalized');
        handles.MP_tab=uitab(handles.SliProfile_tabgroup,'title','Mg Pe','Units','normalized');
        handles.MxMyMz_axes=axes('parent', handles.MxMyMz_tab,'Position', [0.06 0.1 0.88 0.85]);
        handles.MxyMz_axes=axes('parent', handles.MxyMz_tab,'Position', [0.06 0.1 0.88 0.85]);
        handles.MP_axes=axes('parent', handles.MP_tab,'Position', [0.06 0.1 0.88 0.85]);
        %----end
    end
    Mx=handles.Mx(:,:,:,:,:,end);
    My=handles.My(:,:,:,:,:,end);
    Mz=handles.Mz(:,:,:,:,:,end);
    Mxy=sqrt(Mx.^2+My.^2);
    Pe=angle(Mx+1i.*My);
    for i=1:str2double(get(handles.Attrh0.TypeNum,'String'))
        spinver=quiver3(handles.SpinRot_axes,handles.Gxgrid,handles.Gygrid,handles.Gzgrid,Mx(:,:,:,:,i),My(:,:,:,:,i),Mz(:,:,:,:,i));
        set(spinver,'AutoScale','off');
        hold(handles.SpinRot_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mx(:,:,:,:,i)),'Color',[0 0 1-(i-1)*0.25],'linewidth',2);
        hold(handles.MxMyMz_axes,'on');
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(My(:,:,:,:,i)),'Color',[0 1-(i-1)*0.25 0],'linewidth',2);
        plot(handles.MxMyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,i)),'Color',[1-(i-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,i)),'Color',[0 0 1-(i-1)*0.25],'linewidth',2);
        hold(handles.MxyMz_axes,'on');
        plot(handles.MxyMz_axes,squeeze(handles.Gzgrid),squeeze(Mz(:,:,:,:,i)),'Color',[1-(i-1)*0.25 0 0],'linewidth',2);
        
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Mxy(:,:,:,:,i)),'Color',[0 0 1-(i-1)*0.25],'linewidth',2);
        hold(handles.MP_axes,'on');
        plot(handles.MP_axes,squeeze(handles.Gzgrid),squeeze(Pe(:,:,:,:,i)),'Color',[1-(i-1)*0.25 0 0],'linewidth',2);
    end
    hold(handles.SpinRot_axes,'off');
    hold(handles.MxMyMz_axes,'off');
    hold(handles.MxyMz_axes,'off');
    hold(handles.MP_axes,'off');
    set(handles.SpinRot_axes,'YLim',[-1 1],'XLim',[-1 1],'ZLim',[min(handles.Gzgrid,[],3)-1 max(handles.Gzgrid,[],3)+1]);
    xlabel(handles.SpinRot_axes,'X axis');
    ylabel(handles.SpinRot_axes,'Y axis');
    zlabel(handles.SpinRot_axes,'Z axis (Gradient Direction)');
    set(handles.SpinRot_axes,'view',[134,24]);
    
    set(handles.MxMyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    legend(handles.MxMyMz_axes,'Mx','My','Mz');
    set(handles.MxMyMz_axes,'YGrid','on','XGrid','on');
    
    set(handles.MxyMz_axes,'YLim',[-1 1],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MxyMz_axes,'YGrid','on','XGrid','on');
    legend(handles.MxyMz_axes,'|Mxy|','Mz');
    
    set(handles.MP_axes,'YLim',[-pi pi],'XLim',[min(handles.Gzgrid,[],3) max(handles.Gzgrid,[],3)]);
    set(handles.MP_axes,'YGrid','on','XGrid','on');
    legend(handles.MP_axes,'Mg','Pe');
else
    
    if ~isfield(handles,'Mx_tab')
        %----clear tabs
        tabs=get(handles.SliProfile_tabgroup,'Children');
        for i=1:length(tabs)
            delete(get(tabs(i),'Children'));
        end
        delete(tabs);
        delete(handles.SliProfile_tabgroup);
        handles=rmfield(handles,'MxMyMz_tab');
        %----end
        %----recreate tab
        handles.SliProfile_tabgroup=uitabgroup(handles.SliProfile_uipanel);
        handles.Mx_tab=uitab(handles.SliProfile_tabgroup,'title','Mx','Units','normalized');
        handles.My_tab=uitab(handles.SliProfile_tabgroup,'title','My','Units','normalized');
        handles.Mz_tab=uitab(handles.SliProfile_tabgroup,'title','Mz','Units','normalized');
        handles.M_tab=uitab(handles.SliProfile_tabgroup,'title','Mag','Units','normalized');
        handles.P_tab=uitab(handles.SliProfile_tabgroup,'title','Ph','Units','normalized');
        
        handles.Mx_axes=axes('parent', handles.Mx_tab,'Position', [0.06 0.1 0.88 0.85]);
        handles.My_axes=axes('parent', handles.My_tab,'Position', [0.06 0.1 0.88 0.85]);
        handles.Mz_axes=axes('parent', handles.Mz_tab,'Position', [0.06 0.1 0.88 0.85]);
        handles.M_axes=axes('parent', handles.M_tab,'Position', [0.06 0.1 0.88 0.85]);
        handles.P_axes=axes('parent', handles.P_tab,'Position', [0.06 0.1 0.88 0.85]);
        %----end
    end
    
    updateSS(handles, size(handles.Mx, 3));
    set(handles.SpinRot_axes,'view',[134,24]);
end

set(handles.rf_slider,'Min',1);
set(handles.rf_slider,'Max',max(size(handles.Muts)));
set(handles.rf_slider,'Value',max(size(handles.Muts)));

plot(handles.rf_axes,handles.rfTime,handles.rfAmp,[handles.Muts(get(handles.rf_slider,'Value')) handles.Muts(get(handles.rf_slider,'Value'))],[min(handles.rfAmp) max(handles.rfAmp)],'g-','linewidth',2);
plot(handles.rfPhase_axes,handles.rfTime,handles.rfPhase,'linewidth',2);
plot(handles.rfFreq_axes,handles.rfTime,handles.rfFreq,'linewidth',2);

if strcmp(handles.Spat_Flag,'off')
    plot(handles.Gz_axes,handles.GzTime,handles.GzAmp,'linewidth',2);
    set(handles.Gz_axes,'YGrid','on','XGrid','off','XTick',[]);
    set(handles.Gz_axes,'YTickLabel',get(handles.Gz_axes,'YTick')*100);
    linkaxes([handles.rf_axes handles.rfPhase_axes handles.rfFreq_axes handles.Gz_axes],'x');
else
    plot(handles.Gy_axes,handles.GyTime,handles.GyAmp,'linewidth',2);
    set(handles.Gy_axes,'YGrid','on','XGrid','off','XTick',[]);
    set(handles.Gy_axes,'YTickLabel',get(handles.Gy_axes,'YTick')*100);
    plot(handles.Gx_axes,handles.GxTime,handles.GxAmp,'linewidth',2);
    set(handles.Gx_axes,'YGrid','on','XGrid','off','XTick',[]);
    set(handles.Gx_axes,'YTickLabel',get(handles.Gx_axes,'YTick')*100);
    linkaxes([handles.rf_axes handles.rfPhase_axes handles.rfFreq_axes handles.Gy_axes handles.Gx_axes ],'x');
end

set(handles.rf_axes,'YLim',[min(handles.rfAmp) max(handles.rfAmp)],'XLim',[min(handles.rfTime) max(handles.rfTime)]);
set(handles.rf_axes,'YGrid','on','XGrid','on');
set(handles.rfPhase_axes,'YGrid','on','XGrid','off','XTick',[]);
set(handles.rfFreq_axes,'YGrid','on','XGrid','off','XTick',[]);

set(handles.rf_axes,'XTickLabel',get(handles.rf_axes,'XTick')*1000);
set(handles.rf_axes,'YTickLabel',get(handles.rf_axes,'YTick')*10000);
set(handles.rfFreq_axes,'YTickLabel',get(handles.rfFreq_axes,'YTick')/1000);

set(hObject,'Enable','on');
set(hObject,'String','Execute');
guidata(handles.rfDesignPanel_figure, handles);


% --- Executes on button press in UpdateAttrXML_pushbutton.
function UpdateAttrXML_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to UpdateAttrXML_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update SeqElem.xml
if verLessThan('matlab','8.5')
    % Code to run in MATLAB R2015a and earlier here
    idx = get(handles.SeqAttri_tabgroup,'SelectedIndex');
else
    % Code to run in MATLAB R2015a and later here
    tabtitle=get(get(handles.SeqAttri_tabgroup,'SelectedTab'),'Title');
    if tabtitle(1:2) == 'rf'
        idx = 1;
    elseif tabtitle(1:2) == 'Gz'
        idx = 2;
    end
end

if idx==1 % update rf
    if ~isempty(handles.Attrh1)
        Attrh1name=fieldnames(handles.Attrh1);
        for i=1:2:length(Attrh1name)
            
            if ~iscell(get(handles.Attrh1.(Attrh1name{i+1}),'String'))
                handles.rfNode.Attributes((i+1)/2).Value=get(handles.Attrh1.(Attrh1name{i+1}),'String');
            else
                handles.rfNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh1.(Attrh1name{i+1}),'Value'));
            end
        end
        eval([handles.rfNodeLvl '=handles.rfNode;']);
        DoWriteXML(handles.SeqElemListStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqElem.xml']);
    end
    
    fid=fopen([handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'rf' filesep handles.SeqElemNode.Name '_Memo.txt'],'wt+');
    Memo=get(handles.rfMemo_edit,'String');
    if ~isempty(Memo)
        if ischar(Memo)
            Memo=cellstr(Memo);
        end
        for i=1:length(Memo)
            fprintf(fid,'%s\n', Memo{i,1});
        end
    end
    fclose(fid);
    
elseif idx==2 % update GzSS
    if ~isempty(handles.Attrh2)
        Attrh2name=fieldnames(handles.Attrh2);
        for i=1:2:length(Attrh2name)
            
            if ~iscell(get(handles.Attrh2.(Attrh2name{i+1}),'String'))
                handles.GzNode.Attributes((i+1)/2).Value=get(handles.Attrh2.(Attrh2name{i+1}),'String');
            else
                handles.GzNode.Attributes((i+1)/2).Value(2)=num2str(get(handles.Attrh2.(Attrh2name{i+1}),'Value'));
            end
        end
        eval([handles.GzNodeLvl '=handles.GzNode;']);
        DoWriteXML(handles.SeqElemListStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'SeqElem.xml']);
    end
end

% update rfSimuAttr.xml
tabs=get(handles.Setting_tabgroup,'Children');
for j=1:length(handles.rfSimuAttrStruct.Children)
    Attrh0=get(tabs(j),'Children');
    for i=1:2:length(Attrh0)
        if ~iscell(get(Attrh0(end-i),'String'))
            handles.rfSimuAttrStruct.Children(j).Attributes((i+1)/2).Value=get(Attrh0(end-i),'String');
        else
            handles.rfSimuAttrStruct.Children(j).Attributes((i+1)/2).Value(2)=num2str(get(Attrh0(end-i),'Value'));
        end
    end
end
DoWriteXML(handles.rfSimuAttrStruct,[handles.Simuh.MRiLabPath filesep 'Macro' filesep 'SeqElem' filesep 'rfSimuAttr.xml']);

guidata(hObject, handles);


% --------------------------------------------------------------------
function SavePanel_uipushtool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SavePanel_uipushtool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DoSaveSnapshot(handles.rfDesignPanel_figure);


% --- Executes on button press in Pause_pushbutton.
function Pause_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Pause_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.PauseFlag==1
    handles.PauseFlag=0;
    set(hObject,'String','X');
else
    handles.PauseFlag=1;
    set(hObject,'String','O');
end

guidata(hObject, handles);


% --- Executes when user attempts to close rfDesignPanel_figure.
function rfDesignPanel_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to rfDesignPanel_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

if isfield(handles,'PauseFlag')
    if handles.PauseFlag==1
        delete(hObject);
    else
        warndlg('Please pause rf animation before closing the window (i.e. press X).');
    end
else
    delete(hObject);
end



function rfMemo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rfMemo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rfMemo_edit as Gz_text
%        str2double(get(hObject,'String')) returns contents of rfMemo_edit as a double


% --- Executes during object creation, after setting all properties.
function rfMemo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rfMemo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% update spin response for spatial-spectral analysis
function updateSS(handles, rf_step)

Mx=handles.Mx(:,:,rf_step);
My=handles.My(:,:,rf_step);
Mz=handles.Mz(:,:,rf_step);
Mag=sqrt(Mx.^2+My.^2);
Ph=angle(Mx+1i.*My);

axes(handles.Mx_axes);
imagesc(Mx);
colormap gray
colorbar
axes(handles.My_axes);
imagesc(My);
colorbar
axes(handles.Mz_axes);
imagesc(Mz);
colorbar
axes(handles.M_axes);
imagesc(Mag);
colorbar
axes(handles.P_axes);
imagesc(Ph);
colorbar

axes(handles.SpinRot_axes);
[az,el] = view(handles.SpinRot_axes);
cla(handles.SpinRot_axes);

if verLessThan('matlab','8.5')
    % Code to run in MATLAB R2015a and earlier here
    idx = get(handles.SliProfile_tabgroup,'SelectedIndex');
    switch idx
        case 1 % Mx
            surf(double(Mx));
            title('Mx');
        case 2 % My
            surf(double(My));
            title('My');
        case 3 % Mz
            surf(double(Mz));
            title('Mz');
        case 4 % Mag
            surf(double(Mag));
            title('Mag');
        case 5 % Ph
            surf(double(Ph));
            title('Ph');
    end
else
    % Code to run in MATLAB R2015a and later here
    tabtitle=get(get(handles.SliProfile_tabgroup,'SelectedTab'),'Title');
    switch tabtitle
        case 'Mx' % Mx
            surf(double(Mx));
            title('Mx');
        case 'My' % My
            surf(double(My));
            title('My');
        case 'Mz' % Mz
            surf(double(Mz));
            title('Mz');
        case 'Mag' % Mag
            surf(double(Mag));
            title('Mag');
        case 'Ph' % Ph
            surf(double(Ph));
            title('Ph');
    end
end

if strcmp(handles.Freq_Flag,'on')
    xlabel('Frequency');
    ylabel('Distance');
else
    xlabel('X-Distance');
    ylabel('Y-Distance');
end
shading interp;
set(handles.SpinRot_axes,'view',[az,el],'xdir','reverse');


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function rfDesignPanel_figure_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to rfDesignPanel_figure (see GCBO)
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
