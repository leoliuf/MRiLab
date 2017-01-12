
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfBIREF(p)
%create a BIREF adiabatic excitation rf pulse starting from tStart and ending at tEnd
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
BIREFFlag=p.BIREFFlag;
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

tEnd=tEnd-tStart;
tStart=0; % time scale shift to 0

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);

switch BIREFFlag
    case 'BIREF-1'
        Zeta=pi/(tEnd-tStart);
        rfTime1=rfTime(rfTime<(tEnd-tStart)/2);
        rfAmp1=MaxB1*sin(Zeta*rfTime1); % rf frequency modulation
        rfTime2=rfTime(rfTime>=(tEnd-tStart)/2);
        rfAmp2=-MaxB1*sin(Zeta*rfTime2); % rf frequency modulation
        
        rfAmp=[rfAmp1 rfAmp2];
        rfFreq=MaxFreq*abs(cos(Zeta*rfTime));
        rfPhase=0*ones(size(rfTime)); % rf Phase
    case 'BIREF-2a'
        Zeta=pi/(tEnd-tStart);
        rfTime1=rfTime(rfTime<(tEnd-tStart)/2);
        rfFreq1=MaxFreq*sin(Zeta*rfTime1);
        rfTime2=rfTime(rfTime>=(tEnd-tStart)/2);
        rfFreq2=-MaxFreq*sin(Zeta*rfTime2);
        
        rfAmp=MaxB1*abs(cos(Zeta*rfTime));
        rfFreq=[rfFreq1 rfFreq2];
        rfPhase=0*ones(size(rfTime)); % rf Phase
    case 'BIREF-2b'
        Zeta=2*pi/(tEnd-tStart);
        rfTime1=rfTime(rfTime<(tEnd-tStart)/4);
        rfAmp1=MaxB1*abs(cos(Zeta*rfTime1));
        rfFreq1=MaxFreq*sin(Zeta*rfTime1);
        
        rfTime2=rfTime(rfTime>=(tEnd-tStart)/4 & rfTime<(tEnd-tStart)/2);
        rfAmp2=MaxB1*abs(cos(Zeta*rfTime2));
        rfFreq2=-MaxFreq*sin(Zeta*rfTime2);
        
        rfTime3=rfTime(rfTime>=(tEnd-tStart)/2 & rfTime<3*(tEnd-tStart)/4);
        rfAmp3=-MaxB1*cos(Zeta*rfTime3);
        rfFreq3=-MaxFreq*sin(Zeta*rfTime3);
        
        rfTime4=rfTime(rfTime>=3*(tEnd-tStart)/4);
        rfAmp4=-MaxB1*cos(Zeta*rfTime4);
        rfFreq4=MaxFreq*sin(Zeta*rfTime4);
        
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