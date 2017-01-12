
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfSLR(p)
%create a SLR rf pulse starting from tStart
%  Inputs for dzrf are:
%    np -- number of points.         (required)
%    tb -- time-bandwidth product    (required)
%    ptype -- pulse type.  Options are:
%      st  -- small tip angle         (default)
%      ex  -- pi/2 excitation pulse
%      se  -- pi spin-echo pulse
%      sat -- pi/2 saturation pulse
%      inv -- inversion pulse
%    ftype -- filter design method.  Options are:
%      ms  -- Hamming windowed sinc (an msinc)
%      pm  -- Parks-McClellan equal ripple
%      ls  -- Least Squares           (default)
%      min -- Minimum phase (factored pm)
%      max -- Maximum phase (reversed min)
%    d1 -- Passband ripple        (default = 0.01)
%    d2 -- Stopband ripple        (default = 0.01)
%    pclsfrac -- pcls tolerance   (default = 1.5)  

tStart=p.tStart;
tEnd=p.tEnd;
dt=p.dt;
FA=p.FA;
TBP=p.TBP;
rfFreq=p.rfFreq;
rfPhase=p.rfPhase;
PRipple=p.PRipple;
SRipple=p.SRipple;
PulseType=p.PulseType;
FilterType=p.FilterType;
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

rfTime=linspace(tStart,tEnd,ceil((tEnd-tStart)/dt)+1);
rf = dzrf(ceil((tEnd-tStart)/dt)+1,TBP,PulseType,FilterType,PRipple,SRipple,1.5);
rfAmp = real(rf);
rfAmp = DoB1Scaling(rfAmp,dt,FA)*rfAmp; %B1 Scaling

rfPhase=(rfPhase)*ones(size(rfTime));
rfFreq=(rfFreq)*ones(size(rfTime));
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