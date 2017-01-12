
function [GAmp,GTime]=GxTrapezoid(p)

tStart=p.tStart; % start time ms
tEnd=p.tEnd;     % end time ms
tRamp=p.tRamp;   % ramp duration time ms
sRamp=p.sRamp;   % ramp steps 
GxAmp=p.GxAmp;   % Gx amplitude
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

[GAmp,GTime]=StdTrap(tStart-tRamp, ...
                     tEnd+tRamp,   ...
                     tStart,               ...
                     tEnd,                 ...
                     GxAmp,max(2,sRamp),2,max(2,sRamp));

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    GAmp=repmat(GAmp,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(GTime) 1]);
    GTime=repmat(GTime,[1 Duplicates]) + (TimeOffset(:))';
end

end
