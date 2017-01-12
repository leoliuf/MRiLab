
function DoPlotDiagm(handles)

global VCtl;
global VVar;

TmpTR=VCtl.TR; % Dummy reserve
TmpFlipAng=VCtl.FlipAng;

%--------Display Parameters
fieldname=fieldnames(handles.Attrh2);
for i=1:length(fieldname)/2
    try 
        eval(['SD.' fieldname{i*2} '=' get(handles.Attrh2.(fieldname{i*2}),'String') ';']);
    catch me
        TAttr=get(handles.Attrh2.(fieldname{i*2}),'String');
        eval(['SD.' fieldname{i*2} '=''' TAttr{get(handles.Attrh2.(fieldname{i*2}),'Value')}  ''';']);
    end
end
%--------End
DoWriteXML2m(DoParseXML(handles.SeqXMLFile),[handles.SeqXMLFile(1:end-3) 'm']);
clear functions;  % remove the M-functions from the memory
[pathstr,name,ext]=fileparts(handles.SeqXMLFile);

DP=0; % Dummy pulse preparing control, set DP=0 for preparing dummy pulse
VVar.SliceCount=0;
VVar.PhaseCount=0;
VVar.TRCount=0;
s=1;
j=1;

if isfield(VCtl,'DP_Flag')
    if SD.TRStart>VCtl.DP_Num
        DP=1;
    end
end

TimeOffset = 0;
while s<=VCtl.SecondPhNum
    VVar.SliceCount=s;
    while j<=VCtl.FirstPhNum
        VVar.PhaseCount=j;
        VVar.TRCount=VVar.TRCount+1;
        
        VCtl.PlotSeq = 0; % Turn off PlotSeq flag for generating waveform
        %PSD function
        if isfield(VCtl,'DP_Flag')
            if VVar.TRCount<SD.TRStart | VVar.TRCount>SD.TREnd % limit simulation within TR range
                j=j+1;
                continue;
            end
            
            % Run dummy pulse setting
            if strcmp(VCtl.DP_Flag,'on') & DP==0
                VCtl.TR=VCtl.DP_TR;
                VCtl.FlipAng=VCtl.DP_FlipAng;
            else
                VCtl.TR=TmpTR;
                VCtl.FlipAng=TmpFlipAng;
            end
            
            eval(['[rfAmp,rfPhase,rfFreq,rfCoil,GzAmp,GyAmp,GxAmp,ADC,Ext,uts,ts,flags]=' name ';']);
            
            if VVar.TRCount==SD.TRStart
                rfAmps=[0 rfAmp 0];
                rfPhases=[0 rfPhase 0];
                rfFreqs=[0 rfFreq 0];
                rfCoils=[0 rfCoil 0];
                GzAmps=[0 GzAmp 0];
                GyAmps=[0 GyAmp 0];
                GxAmps=[0 GxAmp 0];
                ADCs=[0 ADC 0];
                Exts=[0 Ext 0];
                
                SEt=ts(sum(flags)==0);
                rfTime=[SEt(1) ts(flags(1,:)==1) SEt(end)]+ TimeOffset;
                GzTime=[SEt(1) ts(flags(2,:)==1) SEt(end)]+ TimeOffset;
                GyTime=[SEt(1) ts(flags(3,:)==1) SEt(end)]+ TimeOffset;
                GxTime=[SEt(1) ts(flags(4,:)==1) SEt(end)]+ TimeOffset;
                ADCTime=[SEt(1) ts(flags(5,:)==1) SEt(end)]+ TimeOffset;
                ExtTime=[SEt(1) ts(flags(6,:)==1) SEt(end)]+ TimeOffset;
            else
                
                rfAmps(end+1:end+length(rfAmp)+2)=[0 rfAmp 0];
                rfPhases(end+1:end+length(rfPhase)+2)=[0 rfPhase 0];
                rfFreqs(end+1:end+length(rfFreq)+2)=[0 rfFreq 0];
                rfCoils(end+1:end+length(rfCoil)+2)=[0 rfCoil 0];
                GzAmps(end+1:end+length(GzAmp)+2)=[0 GzAmp 0];
                GyAmps(end+1:end+length(GyAmp)+2)=[0 GyAmp 0];
                GxAmps(end+1:end+length(GxAmp)+2)=[0 GxAmp 0];
                ADCs(end+1:end+length(ADC)+2)=[0 ADC 0];
                Exts(end+1:end+length(Ext)+2)=[0 Ext 0];
                
                SEt=ts(sum(flags)==0);
                rfTime(end+1:end+length(find(flags(1,:)==1))+2)=[SEt(1) ts(flags(1,:)==1) SEt(end)]+ TimeOffset;
                GzTime(end+1:end+length(find(flags(2,:)==1))+2)=[SEt(1) ts(flags(2,:)==1) SEt(end)]+ TimeOffset;
                GyTime(end+1:end+length(find(flags(3,:)==1))+2)=[SEt(1) ts(flags(3,:)==1) SEt(end)]+ TimeOffset;
                GxTime(end+1:end+length(find(flags(4,:)==1))+2)=[SEt(1) ts(flags(4,:)==1) SEt(end)]+ TimeOffset;
                ADCTime(end+1:end+length(find(flags(5,:)==1))+2)=[SEt(1) ts(flags(5,:)==1) SEt(end)]+ TimeOffset;
                ExtTime(end+1:end+length(find(flags(6,:)==1))+2)=[SEt(1) ts(flags(6,:)==1) SEt(end)]+ TimeOffset;
            end
            
            % Calculate time offset
            VCtl.PlotSeq = 1; % Turn on PlotSeq flag for offseting time point based on TR
            eval(['[rfAmp,rfPhase,rfFreq,rfCoil,GzAmp,GyAmp,GxAmp,ADC,Ext,uts,ts,flags]=' name ';']);
            TimeOffset = TimeOffset + (ts(2) - ts(1));
            
            % Prepare dummy pulse
            if strcmp(VCtl.DP_Flag,'on') & DP==0
                
                GzAmps=GzAmps*0;
                GyAmps=GyAmps*0;
                GxAmps=GxAmps*0;
                ADCs=ADCs*0;
                %  Exts=Exts*0;
                
                if VVar.TRCount==VCtl.DP_Num
                    s=1;
                    j=1;
                    DP=1;
                    break;
                end
            end
        else
            if VVar.TRCount<SD.TRStart | VVar.TRCount>SD.TREnd % limit simulation within TR range
                j=j+1;
                continue;
            end
            
            eval(['[rfAmp,rfPhase,rfFreq,rfCoil,GzAmp,GyAmp,GxAmp,ADC,Ext,uts,ts,flags]=' name ';']);
            
            if VVar.TRCount==SD.TRStart
                rfAmps=[0 rfAmp 0];
                rfPhases=[0 rfPhase 0];
                rfFreqs=[0 rfFreq 0];
                rfCoils=[0 rfCoil 0];
                GzAmps=[0 GzAmp 0];
                GyAmps=[0 GyAmp 0];
                GxAmps=[0 GxAmp 0];
                ADCs=[0 ADC 0];
                Exts=[0 Ext 0];
                
                SEt=ts(sum(flags)==0);
                rfTime=[SEt(1) ts(flags(1,:)==1) SEt(end)]+TimeOffset;
                GzTime=[SEt(1) ts(flags(2,:)==1) SEt(end)]+TimeOffset;
                GyTime=[SEt(1) ts(flags(3,:)==1) SEt(end)]+TimeOffset;
                GxTime=[SEt(1) ts(flags(4,:)==1) SEt(end)]+TimeOffset;
                ADCTime=[SEt(1) ts(flags(5,:)==1) SEt(end)]+TimeOffset;
                ExtTime=[SEt(1) ts(flags(6,:)==1) SEt(end)]+TimeOffset;
            else
                
                rfAmps(end+1:end+length(rfAmp)+2)=[0 rfAmp 0];
                rfPhases(end+1:end+length(rfPhase)+2)=[0 rfPhase 0];
                rfFreqs(end+1:end+length(rfFreq)+2)=[0 rfFreq 0];
                rfCoils(end+1:end+length(rfCoil)+2)=[0 rfCoil 0];
                GzAmps(end+1:end+length(GzAmp)+2)=[0 GzAmp 0];
                GyAmps(end+1:end+length(GyAmp)+2)=[0 GyAmp 0];
                GxAmps(end+1:end+length(GxAmp)+2)=[0 GxAmp 0];
                ADCs(end+1:end+length(ADC)+2)=[0 ADC 0];
                Exts(end+1:end+length(Ext)+2)=[0 Ext 0];
                
                SEt=ts(sum(flags)==0);
                rfTime(end+1:end+length(find(flags(1,:)==1))+2)=[SEt(1) ts(flags(1,:)==1) SEt(end)]+TimeOffset;
                GzTime(end+1:end+length(find(flags(2,:)==1))+2)=[SEt(1) ts(flags(2,:)==1) SEt(end)]+TimeOffset;
                GyTime(end+1:end+length(find(flags(3,:)==1))+2)=[SEt(1) ts(flags(3,:)==1) SEt(end)]+TimeOffset;
                GxTime(end+1:end+length(find(flags(4,:)==1))+2)=[SEt(1) ts(flags(4,:)==1) SEt(end)]+TimeOffset;
                ADCTime(end+1:end+length(find(flags(5,:)==1))+2)=[SEt(1) ts(flags(5,:)==1) SEt(end)]+TimeOffset;
                ExtTime(end+1:end+length(find(flags(6,:)==1))+2)=[SEt(1) ts(flags(6,:)==1) SEt(end)]+TimeOffset;
            end
            
            % Calculate time offset
            VCtl.PlotSeq = 1; % Turn on PlotSeq flag for offseting time point based on TR
            eval(['[rfAmp,rfPhase,rfFreq,rfCoil,GzAmp,GyAmp,GxAmp,ADC,Ext,uts,ts,flags]=' name ';']);
            TimeOffset = TimeOffset + (ts(2) - ts(1));
        end
        j=j+1;
    end
    if s==1 & j==1 & DP==1
        continue;
    end
    j=1;
    s=s+1;
end

Coil=unique(rfCoils);
Coil(Coil==0)=[];

if handles.ResetAxes == 1
    handles.ResetAxes = 0;
    rfaxis = [0 VCtl.TR];
else
    rfaxis = axis(handles.Ext_axes);
    tabs=get(handles.rf_tabgroup,'Children');
    for i=1:length(tabs)
        delete(get(tabs(i),'Children'));
    end
    delete(tabs);
    delete(handles.rf_tabgroup);
end
handles.rfAxes=[];
handles.rfCoil=Coil;
handles.rfCurrentCoil=Coil(1);
handles.rf_tabgroup=uitabgroup(handles.rf_uipanel);
switch SD.LineMarker
    case 'on'
        linetype='''wo-'', ''MarkerSize'',3';
    case 'off'
        linetype='''w''';
end
for i = 1: length(Coil)
    ind = find(rfCoils==0 | rfCoils==Coil(i));
    Amps = rfAmps(ind);
    Phases = rfPhases(ind);
    Freqs = rfFreqs(ind);
    Time = rfTime(ind);
    maxAmps = max(abs(Amps));
    maxPhases = max(abs(Phases));
    maxFreqs = max(abs(Freqs));
    eval(['rfAmps' num2str(Coil(i)) '= Amps;']);
    eval(['rfPhases' num2str(Coil(i)) '= Phases;']);
    eval(['rfFreqs' num2str(Coil(i)) '= Freqs;']);
    eval(['rfTime' num2str(Coil(i)) '= Time;']);
    eval(['handles.rf' num2str(Coil(i)) '_tab=uitab(handles.rf_tabgroup,' '''title'',' '''rf' num2str(Coil(i))  ''',''Units'',''normalized'');']);
    eval(['handles.rf' num2str(Coil(i)) '_axes=axes(''parent'', handles.rf' num2str(Coil(i))  '_tab,''Position'',[0 0.6 1 0.3]);']);
    eval(['handles.rfPhase' num2str(Coil(i)) '_axes=axes(''parent'', handles.rf' num2str(Coil(i))  '_tab,''Position'',[0 0.3 1 0.3]);']);
    eval(['handles.rfFreq' num2str(Coil(i)) '_axes=axes(''parent'', handles.rf' num2str(Coil(i))  '_tab,''Position'',[0 0.0 1 0.3]);']);
    eval(['handles.rfAxes(end+1:end+3) =[handles.rf' num2str(Coil(i)) '_axes ' 'handles.rfPhase' num2str(Coil(i)) '_axes ' 'handles.rfFreq' num2str(Coil(i)) '_axes' '];']);
    
    if maxAmps==0
        eval(['plot(handles.rf' num2str(Coil(i)) '_axes,rfTime' num2str(Coil(i)) ',0*rfTime' num2str(Coil(i)) ',' linetype ',''linewidth'',1);']);
    else
        eval(['plot(handles.rf' num2str(Coil(i)) '_axes,rfTime' num2str(Coil(i)) ',rfAmps' num2str(Coil(i)) '/maxAmps,' linetype ',''linewidth'',1);']);
    end
    if maxPhases==0
        eval(['plot(handles.rfPhase' num2str(Coil(i)) '_axes,rfTime' num2str(Coil(i)) ',0*rfTime' num2str(Coil(i)) ',' linetype ',''linewidth'',1);']);
    else
        eval(['plot(handles.rfPhase' num2str(Coil(i)) '_axes,rfTime' num2str(Coil(i)) ',rfPhases' num2str(Coil(i)) '/maxPhases,' linetype ',''linewidth'',1);']);
    end
    if maxFreqs==0
        eval(['plot(handles.rfFreq' num2str(Coil(i)) '_axes,rfTime' num2str(Coil(i)) ',0*rfTime' num2str(Coil(i)) ',' linetype ',''linewidth'',1);']);
    else
        eval(['plot(handles.rfFreq' num2str(Coil(i)) '_axes,rfTime' num2str(Coil(i)) ',rfFreqs' num2str(Coil(i)) '/maxFreqs,' linetype ',''linewidth'',1);']);
    end

    eval(['set(handles.rf' num2str(Coil(i)) '_axes,''XLim'',[rfaxis(1) rfaxis(2)],''YLim'',[-1.5 1.5]);']);
    eval(['set(handles.rf' num2str(Coil(i)) '_axes,''YTick'',[],''XTick'',[],''Box'',''off'',''Color'',''k'');']);
    eval(['set(handles.rfPhase' num2str(Coil(i)) '_axes,''YTick'',[],''XTick'',[],''Box'',''off'',''Color'',''k'');']);
    eval(['set(handles.rfFreq' num2str(Coil(i)) '_axes,''YTick'',[],''XTick'',[],''Box'',''off'',''Color'',''k'');']);
     
    eval(['handles.rfAmps' num2str(Coil(i)) '=rfAmps;']);
    eval(['handles.rfPhases' num2str(Coil(i)) '=rfPhases;']);
    eval(['handles.rfFreqs' num2str(Coil(i)) '=rfFreqs;']);
    eval(['handles.rfTime' num2str(Coil(i)) '=rfTime;']);
    
end

eval(['handles.rf_axes=handles.rf' num2str(Coil(1)) '_axes;']);
eval(['handles.rfAmps=handles.rfAmps' num2str(Coil(1)) ';']);
eval(['handles.rfPhases=handles.rfPhases' num2str(Coil(1)) ';']);
eval(['handles.rfFreqs=handles.rfFreqs' num2str(Coil(1)) ';']);
eval(['handles.rfTime=handles.rfTime' num2str(Coil(1)) ';']);

VVar.SliceCount=0;
VVar.PhaseCount=0;
VVar.TRCount=0;

if strcmp(SD.Moments,'on')
%     GzAmps=cumsum(GzAmps);
%     GyAmps=cumsum(GyAmps);
%     GxAmps=cumsum(GxAmps);
end

if max(abs(GzAmps))==0
    eval(['plot(handles.Gz_axes,GzTime'',0*GzTime'',' linetype ',''linewidth'',1);']);
else
    eval(['plot(handles.Gz_axes,GzTime'',GzAmps''./max(max(abs(GzAmps))),' linetype ',''linewidth'',1);']);
end
if max(abs(GyAmps))==0
    eval(['plot(handles.Gy_axes,GyTime'',0*GyTime'',' linetype ',''linewidth'',1);']);
else
    eval(['plot(handles.Gy_axes,GyTime'',GyAmps''./max(max(abs(GyAmps))),' linetype ',''linewidth'',1);']);
end
if max(abs(GxAmps))==0
    eval(['plot(handles.Gx_axes,GxTime'',0*GxTime'',' linetype ',''linewidth'',1);']);
else
    eval(['plot(handles.Gx_axes,GxTime'',GxAmps''./max(max(abs(GxAmps))),' linetype ',''linewidth'',1);']);
end
if max(abs(ADCs))==0
    eval(['plot(handles.ADC_axes,ADCTime'',0*ADCTime'',' linetype ',''linewidth'',1);']);
else
    eval(['plot(handles.ADC_axes,ADCTime'',ADCs''./max(max(abs(ADCs))),' linetype ',''linewidth'',1);']);
end
if max(abs(Exts))==0
    eval(['plot(handles.Ext_axes,ExtTime'',0*ExtTime'',' linetype ',''linewidth'',1);']);
else
    eval(['plot(handles.Ext_axes,ExtTime'',Exts''./max(max(abs(Exts))),' linetype ',''linewidth'',1);']);
end

linkaxes([handles.rfAxes handles.Gz_axes handles.Gy_axes handles.Gx_axes handles.ADC_axes handles.Ext_axes],'xy');
set(handles.Gz_axes,'YTick',[],'XTick',[],'Box','off','Color','k');
set(handles.Gy_axes,'YTick',[],'XTick',[],'Box','off','Color','k');
set(handles.Gx_axes,'YTick',[],'XTick',[],'Box','off','Color','k');
set(handles.ADC_axes,'YTick',[],'XTick',[],'Box','off','Color','k');
set(handles.Ext_axes,'YTick',[],'Box','off','Color','k','xcolor','w');
set(handles.Ext_axes,'XTickLabel',get(handles.Ext_axes,'XTick')*1000); %ms

handles.GzAmps=GzAmps;
handles.GyAmps=GyAmps;
handles.GxAmps=GxAmps;
handles.ADCs=ADCs;
handles.Exts=Exts;

handles.GzTime=GzTime;
handles.GyTime=GyTime;
handles.GxTime=GxTime;
handles.ADCTime=ADCTime;
handles.ExtTime=ExtTime;

guidata(handles.SeqDesignPanel_figure,handles);

end