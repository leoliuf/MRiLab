
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfTanhTan(p)
%create a Tanh/Tan adiabatic inversion rf pulse starting from tStart and ending at tEnd
%tStart rf start time
%tEnd rf end time
%dt rf sample time
%rfPhase rf phase
%rfFreq rf off-res freq

tStart=p.tStart;
tEnd=p.tEnd;
dt=p.dt;
MaxB1=p.MaxB1; % Maxium B1
TBP=p.TBP; % Time bandwidth product
rfPhase=p.rfPhase;
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

tEnd=tEnd-tStart;
tStart=0; % time scale shift to 0

Zeta=10;
Kappa=atan(20);
A=TBP*pi/(tEnd-tStart);

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);

rfTime1=rfTime(rfTime<(tEnd-tStart)/2);
rfAmp1=MaxB1.*tanh((2*Zeta.*rfTime1)/(tEnd-tStart)); % rf amplitude modulation
rfFreq1=A.*(tan(Kappa*(1-2*rfTime1/(tEnd-tStart)))/tan(Kappa))/(2*pi); % rf frequency modulation
rfTime2=(tEnd-tStart)-rfTime(rfTime>=(tEnd-tStart)/2);
rfAmp2=MaxB1.*tanh((2*Zeta.*rfTime2)/(tEnd-tStart)); % rf amplitude modulation
rfFreq2=-A.*(tan(Kappa*(1-2*rfTime2/(tEnd-tStart)))/tan(Kappa))/(2*pi); % rf frequency modulation

rfAmp=[rfAmp1 rfAmp2];
rfFreq=[rfFreq1 rfFreq2];
rfPhase=(rfPhase)*ones(size(rfTime)); % rf Phase

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