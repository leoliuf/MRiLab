
function [GAmp,GTime]=GzSelective(p)

global VCtl;

t2Start=p.t2Start;
t2End=p.t2End;
tRamp=p.tRamp;
Gz1Sign=p.Gz1Sign;
Gz2Sign=p.Gz2Sign;
Gz3Sign=p.Gz3Sign;
GzAmp=p.GzAmp;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

% prephasing
[GAmp1,GTime1]=StdTrap(0,         ...
                       (t2End-t2Start)/2+2*tRamp,       ...
                       tRamp,                       ...
                       (t2End-t2Start)/2+tRamp,                     ...
                       Gz1Sign*GzAmp,2,2,2);

% slice selection
[GAmp2,GTime2]=StdTrap(t2Start-tRamp,    ...
                       t2End+tRamp,      ...
                       t2Start,   ...
                       t2End,     ...
                       Gz2Sign*GzAmp,2,2,2);
% phase rewinding
[GAmp3,GTime3]=StdTrap(0,         ...
                       (t2End-t2Start)/2+2*tRamp,       ...
                       tRamp,                       ...
                       (t2End-t2Start)/2+tRamp,                     ...
                       Gz3Sign*GzAmp,2,2,2);
                   
GAmp=GAmp2;
GTime=GTime2;

if Gz1Sign~=0
    GAmp=[GAmp1, GAmp];
    GTime=[t2Start-tRamp-GTime1(end)+GTime1, GTime];
end

if Gz3Sign~=0
    GAmp=[GAmp, GAmp3];
    GTime=[GTime, t2End+tRamp+GTime3];
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
