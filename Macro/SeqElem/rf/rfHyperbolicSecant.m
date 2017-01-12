
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfHyperbolicSecant(p)
%create a hyperbolic secant adiabatic inversion rf pulse starting from tStart and ending at tEnd
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
Adiab=p.Adiab; % Adiabaticity
rfPhase=p.rfPhase;
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

Beta=(TBP/(tEnd-tStart))*pi/Adiab;

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);
rfAmp=MaxB1.*sech(Beta.*(rfTime-(tEnd-tStart)/2-tStart)); % rf amplitude modulation
rfFreq=-Beta.*Adiab.*tanh(Beta.*(rfTime-(tEnd-tStart)/2-tStart))/(2*pi); % rf frequency modulation
rfPhase=(rfPhase)*ones(size(rfTime)); % rf Phase
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