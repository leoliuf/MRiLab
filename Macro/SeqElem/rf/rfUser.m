
function [rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=rfUser(p)
%create a rf pulse from data file
%rfGain rfGain of the rectangle
%rfPhase rf phase
%rfFreq rf off-res freq
%rfTime rf time

global VVar;

load(p.rfFile); % load rf pulse file, rf file needs to contain rfAmp,rfPhase,rfFreq,rfTime
rfCoil=p.CoilID;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

rfAmp=rfAmp(min(end,VVar.TRCount),:);
rfTime=rfTime(min(end,VVar.TRCount),:);

if ~exist('rfPhase','var')
    rfPhase=(0)*ones(size(rfTime));
else
    rfPhase=rfPhase(min(end,VVar.TRCount),:);
end
if ~exist('rfFreq','var')
    rfFreq=(0)*ones(size(rfTime));
else
    rfFreq=rfFreq(min(end,VVar.TRCount),:);
end

rfCoil=(rfCoil)*ones(size(rfTime));
rfAmp(1)=0;
rfAmp(end)=0;
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