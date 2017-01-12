
function [GAmp,GTime]=ADCUser(p)

global VVar;

load(p.ADCFile); % load ADC file, ADC file needs to contain GAmp, GTime
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

GAmp=GAmp(min(end,VVar.TRCount),:);
GTime=GTime(min(end,VVar.TRCount),:);

GAmp(GAmp~=0)=1;
GAmp(1)=0;
GAmp(end)=0;

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    GAmp=repmat(GAmp,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(GTime) 1]);
    GTime=repmat(GTime,[1 Duplicates]) + (TimeOffset(:))';
end

end