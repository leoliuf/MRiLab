
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfBIR(p)
%create a BIR adiabatic excitation rf pulse starting from tStart and ending at tEnd
%tStart rf start time
%tEnd rf end time
%dt rf sample time
%rfPhase rf phase
%rfFreq rf off-res freq

tStart=p.tStart;
tEnd=p.tEnd;
dt=p.dt;
MaxB1=p.MaxB1; % Maximum B1
MaxFreq=p.MaxFreq; % Frequency modulation amplitude
BIRFlag=p.BIRFlag;
Lambda=p.Lambda;
Beta=p.Beta;
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

tEnd=tEnd-tStart;
tStart=0; % time scale shift to 0

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);

switch BIRFlag
    case 'BIR-1'
        Zeta=pi/(tEnd-tStart);
        rfTime1=rfTime(rfTime<(tEnd-tStart)/2);
        rfFreq1=MaxFreq*sin(Zeta*rfTime1); % rf frequency modulation
        rfPhase1=(0)*ones(size(rfTime1));
        rfTime2=rfTime(rfTime>=(tEnd-tStart)/2);
        rfFreq2=-MaxFreq*sin(Zeta*rfTime2); % rf frequency modulation
        rfPhase2=(pi/2)*ones(size(rfTime2));
        
        rfAmp=MaxB1*cos(Zeta*rfTime);
        rfFreq=[rfFreq1 rfFreq2];
        rfPhase=[rfPhase1 rfPhase2];
    case 'BIR-2'
        Zeta=2*pi/(tEnd-tStart);
        rfTime1=rfTime(rfTime<(tEnd-tStart)/4);
        rfPhase1=(0)*ones(size(rfTime1));
        rfTime2=rfTime(rfTime>=(tEnd-tStart)/4 & rfTime<(tEnd-tStart)/2);
        rfPhase2=(pi/2)*ones(size(rfTime2));
        rfTime3=rfTime(rfTime>=(tEnd-tStart)/2);
        rfPhase3=(pi/2+pi)*ones(size(rfTime3));
        
        rfAmp=abs(MaxB1*cos(Zeta*rfTime));
        rfFreq=abs(MaxFreq*sin(Zeta*rfTime));
        rfPhase=[rfPhase1 rfPhase2 rfPhase3];
    case 'BIR-4'
        rfTime1=rfTime(rfTime<(tEnd-tStart)/4);
        rfAmp1=MaxB1*tanh(Lambda*(1-4*rfTime1/(tEnd-tStart)));
        rfFreq1=tan(4*Beta*rfTime1/(tEnd-tStart))/(tan(Beta)*2*pi);
        rfTime2=rfTime(rfTime>=(tEnd-tStart)/4 & rfTime<(tEnd-tStart)/2);
        rfAmp2=MaxB1*tanh(Lambda*(4*rfTime2/(tEnd-tStart)-1));
        rfFreq2=tan(Beta*(4*rfTime2/(tEnd-tStart)-2))/(tan(Beta)*2*pi);
        rfTime3=rfTime(rfTime>=(tEnd-tStart)/2 & rfTime<3*(tEnd-tStart)/4);
        rfAmp3=MaxB1*tanh(Lambda*(3-4*rfTime3/(tEnd-tStart)));
        rfFreq3=tan(Beta*(4*rfTime3/(tEnd-tStart)-2))/(tan(Beta)*2*pi);
        rfTime4=rfTime(rfTime>=3*(tEnd-tStart)/4);
        rfAmp4=MaxB1*tanh(Lambda*(4*rfTime4/(tEnd-tStart)-3));
        rfFreq4=tan(Beta*(4*rfTime4/(tEnd-tStart)-4))/(tan(Beta)*2*pi);
        
        rfAmp=[rfAmp1 rfAmp2 rfAmp3 rfAmp4];
        rfFreq=[rfFreq1 rfFreq2 rfFreq3 rfFreq4];
        rfPhase=0*ones(size(rfTime)); % rf Phase
end

rfTime=rfTime+p.tStart; % time scale shift back
rfCoil=(rfCoil)*ones(size(rfTime));
rfAmp(1)=0;
rfAmp(end)=0;
rfFreq(1)=0;
rfFreq(end)=0;
rfPhase(1)=0;
rfPhase(end)=0;

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    rfAmp=repmat(rfAmp,[1 Duplicates]);
    rfFreq=repmat(rfFreq,[1 Duplicates]);
    rfPhase=repmat(rfPhase,[1 Duplicates]);
    rfCoil=repmat(rfCoil,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(rfTime) 1]);
    rfTime=repmat(rfTime,[1 Duplicates]) + (TimeOffset(:))';
end

end