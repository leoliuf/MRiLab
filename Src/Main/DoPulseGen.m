
function DoPulseGen(Simuh)

global VCtl;
global VVar;
global VSeq;

VCtl.PlotSeq = 0;  % Turn off PlotSeq flag for generating waveform
TmpTR=VCtl.TR; % Dummy reserve
TmpFlipAng=VCtl.FlipAng;

%% Compile PSD XML to m function
DoWriteXML2m(DoParseXML(Simuh.SeqXMLFile),[Simuh.SeqXMLFile(1:end-3) 'm']);
clear functions;  % remove the M-functions from the memory
[pathstr,name,ext]=fileparts(Simuh.SeqXMLFile);

%% Pulse & Gradient signal generation
DP=0; % Dummy pulse preparing control, set DP=0 for preparing dummy pulse
VVar.SliceCount=0;
VVar.PhaseCount=0;
VVar.TRCount=0;
s=1;
j=1;

% Pulsegen loop
while s<=VCtl.SecondPhNum
    VVar.SliceCount=s;
    while j<=VCtl.FirstPhNum
        VVar.PhaseCount=j;
        VVar.TRCount=VVar.TRCount+1;
        
        if isfield(VCtl,'DP_Flag')  % Run Dummy pulse setting
            if strcmp(VCtl.DP_Flag,'on') & DP==0
                VCtl.TR=VCtl.DP_TR;
                VCtl.FlipAng=VCtl.DP_FlipAng;
            else
                VCtl.TR=TmpTR;
                VCtl.FlipAng=TmpFlipAng;
            end
        end
        
        eval(['[rfAmp,rfPhase,rfFreq,rfCoil,GzAmp,GyAmp,GxAmp,ADC,Ext,uts,ts,flags]=' name ';']);
        if VVar.TRCount==1 & DP==0
            rfAmpLine=rfAmp;
            rfPhaseLine=rfPhase;
            rfFreqLine=rfFreq;
            rfCoilLine=rfCoil;
            GzAmpLine=GzAmp;
            GyAmpLine=GyAmp;
            GxAmpLine=GxAmp;
            ADCLine=ADC;
            ExtLine=Ext;
            utsLine=uts;
            tsLine=ts;
            flagsLine=flags;
        else
            rfAmpLine(end+1:end+length(rfAmp))=rfAmp;
            rfPhaseLine(end+1:end+length(rfPhase))=rfPhase;
            rfFreqLine(end+1:end+length(rfFreq))=rfFreq;
            rfCoilLine(end+1:end+length(rfFreq))=rfCoil;
            GzAmpLine(end+1:end+length(GzAmp))=GzAmp;
            GyAmpLine(end+1:end+length(GyAmp))=GyAmp;
            GxAmpLine(end+1:end+length(GxAmp))=GxAmp;
            ADCLine(end+1:end+length(ADC))=ADC;
            ExtLine(end+1:end+length(Ext))=Ext;
            utsLine(end+1:end+length(uts))=uts;
            tsLine(end+1:end+length(ts))=ts;
            flagsLine(:,end+1:end+length(flags(1,:)))=flags;
        end
        
        if isfield(VCtl,'DP_Flag')  % Prepare dummy pulse
            if strcmp(VCtl.DP_Flag,'on') & DP==0
                
                GzAmpLine=GzAmpLine*0;
                GyAmpLine=GyAmpLine*0;
                GxAmpLine=GxAmpLine*0;
                ADCLine=ADCLine*0;
                %                 ExtLine=ExtLine*0;
                
                if VVar.TRCount==VCtl.DP_Num
                    s=1;
                    j=1;
                    DP=1;
                    break;
                end
            end
        end
        j=j+1;
    end
    if s==1 & j==1 & DP==1
        continue;
    end
    j=1;
    s=s+1;
end

VVar.SliceCount=0;
VVar.PhaseCount=0;
VVar.TRCount=0;

VSeq.rfAmpLine=rfAmpLine;
VSeq.rfPhaseLine=rfPhaseLine;
VSeq.rfFreqLine=rfFreqLine;
VSeq.GzAmpLine=GzAmpLine;
VSeq.GyAmpLine=GyAmpLine;
VSeq.GxAmpLine=GxAmpLine;
VSeq.ADCLine=ADCLine;
VSeq.ExtLine=ExtLine;
VSeq.utsLine=utsLine;
VSeq.tsLine=tsLine;
VSeq.flagsLine=flagsLine;

if strcmp(VCtl.MultiTransmit,'off')
    VSeq.rfCoilLine=ones(size(rfCoilLine)); % force to convert rfCoilLine to 1 for single Tx
else
    VSeq.rfCoilLine=rfCoilLine;
end

% Do multi-Tx transmitting check and configuration
DoMultiTransmitChk;

% Do grad amplitude & slew rate check
ExecFlag = DoGradChk;
if ExecFlag==0
    VSeq=[];
    error('Gradient check failed!');
end

% Do update rate check
ExecFlag = DoUpdRateChk;
if ExecFlag==0
    VSeq=[];
    error('Update rate check failed!');
end
    

end