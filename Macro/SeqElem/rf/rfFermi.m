
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfFermi(p)
%create a gaussian shape rf pulse starting from tStart and ending at tEnd
%tStart rf start time
%tEnd rf end time
%FA rf actual flip angle
%dt rf sample time
%rfPhase rf phase
%rfFreq rf off-res freq

tStart=p.tStart;
tEnd=p.tEnd;
PW=p.PW; % Pulse Width
FA=p.FA;
dt=p.dt;
rfPhase=p.rfPhase;
rfFreq=p.rfFreq;
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);
TW=((tEnd-tStart)-2*PW)/13.81; % Transition Width

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);
rfAmp=1./(1+exp((abs(rfTime-(tEnd-tStart)/2-tStart)-PW)/TW)); % Fermi rf
rfAmp(1)=0;
rfAmp(end)=0;
rfAmp=DoB1Scaling(rfAmp,dt,FA)*rfAmp; % B1 Scaling

rfPhase=(rfPhase)*ones(size(rfTime));
rfFreq=(rfFreq)*ones(size(rfTime));
rfCoil=(rfCoil)*ones(size(rfTime));
rfPhase(1)=0;
rfPhase(end)=0;
rfFreq(1)=0;
rfFreq(end)=0;

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