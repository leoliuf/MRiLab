
function LoadFlag=DoLoadPhantom(Simuh,StdPhantom)

global VObj;
LoadFlag=0;

if nargin==1
    
    DoUpdateInfo(Simuh,'Loading virtual object...');
    [filename,pathname,filterindex]=uigetfile({'*.mat','MAT-files (*.mat)'},'MultiSelect','off');
    if filename~=0
        Matrices=uiimport([pathname filename]);
        if isfield(Matrices, 'VObj')
            VObj=Matrices.VObj;
            VObjPro=fieldnames(Matrices.VObj);
            set(Simuh.VObj_listbox,'String',VObjPro);
            VObjSpinMapind=1;
            for i=1:length(VObjPro)
                d=size(VObj.(VObjPro{i}));
                if numel(d)==2
                    if d(1)==1 & d(2)==1
                        % do nothing for one point
                    elseif d(1)==1 | d(2)==1
                        % do nothing for one line
                    elseif d(1)~=0 & d(2)~=0
                        VObjSpinMap(VObjSpinMapind,1)=VObjPro(i);
                        VObjSpinMapind=VObjSpinMapind+1;
                    end
                elseif numel(d)==3 | numel(d)==4
                    VObjSpinMap(VObjSpinMapind,1)=VObjPro(i);
                    VObjSpinMapind=VObjSpinMapind+1;
                end
            end
        else
            DoUpdateInfo(Simuh,'No Virtual Object was found.');
            return;
        end
    else
        DoUpdateInfo(Simuh,'No Virtual Object was loaded.');
        return;
    end
    set(Simuh.VObjSpinMap_popupmenu,'String',VObjSpinMap);
    if get(Simuh.VObjSpinMap_popupmenu,'Value') > length(VObjSpinMap)
        set(Simuh.VObjSpinMap_popupmenu,'Value',1);
    end
    set(Simuh.VObjSpinMap_popupmenu,'Enable','on');
    set(Simuh.VObjType_popupmenu,'Enable','on','Value',1);
    set(Simuh.View_pushbutton,'Enable','on');
    set(Simuh.Display_pushbutton,'Enable','on');
    set(Simuh.VObj_listbox,'Enable','on','Value',1);
    set(Simuh.VObj_text,'String',[]);
    guidata(Simuh.SimuPanel_figure, Simuh);
    DoUpdateInfo(Simuh,'Virtual object was successfully loaded');
    LoadFlag=1;
    
else
    
    DoUpdateInfo(Simuh,'Loading standard phantom...');
    load(StdPhantom);
    VObjPro=fieldnames(VObj);
    set(Simuh.VObj_listbox,'String',VObjPro);
    VObjSpinMapind=1;
    for i=1:length(VObjPro)
        d=size(VObj.(VObjPro{i}));
        if numel(d)==2
            if d(1)==1 & d(2)==1
                % do nothing for one point
            elseif d(1)==1 | d(2)==1
                % do nothing for one line
            elseif d(1)~=0 & d(2)~=0
                VObjSpinMap(VObjSpinMapind,1)=VObjPro(i);
                VObjSpinMapind=VObjSpinMapind+1;
            end
        elseif numel(d)==3 | numel(d)==4
            VObjSpinMap(VObjSpinMapind,1)=VObjPro(i);
            VObjSpinMapind=VObjSpinMapind+1;
        end
    end
    set(Simuh.VObjSpinMap_popupmenu,'String',VObjSpinMap);
    if get(Simuh.VObjSpinMap_popupmenu,'Value') > length(VObjSpinMap)
        set(Simuh.VObjSpinMap_popupmenu,'Value',1);
    end
    set(Simuh.VObjSpinMap_popupmenu,'Enable','on');
    set(Simuh.VObjType_popupmenu,'Enable','on','Value',1);
    set(Simuh.View_pushbutton,'Enable','on');
    set(Simuh.Display_pushbutton,'Enable','on');
    set(Simuh.VObj_listbox,'Enable','on','Value',1);
    set(Simuh.VObj_text,'String',[]);
    
    guidata(Simuh.SimuPanel_figure, Simuh);
    DoUpdateInfo(Simuh,'Standard phantom was successfully loaded.');
    LoadFlag=1;
    
end

