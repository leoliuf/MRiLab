
function [GAmp,GTime]=ADCBlock(p)

global VCtl

tStart=p.tStart; % start time ms
tEnd=p.tEnd;     % end time ms
sSample=p.sSample;   % sample steps 
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

if sSample==1
    [GAmp,GTime]=StdBit(tStart,tEnd,1);
else
    [GAmp,GTime]=StdTrap(tStart-VCtl.MinUpdRate, ...
                        tEnd+VCtl.MinUpdRate,   ...
                        tStart,               ...
                        tEnd,                 ...
                        1,2,sSample,2);
end

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    GAmp=repmat(GAmp,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(GTime) 1]);
    GTime=repmat(GTime,[1 Duplicates]) + (TimeOffset(:))';
end

end




