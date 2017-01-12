
function [GAmp,GTime]=GzSelective2(p)

global VCtl;

t2Start=p.t2Start;
t2End=p.t2End;
tRamp=p.tRamp;
tGz1=p.tGz1;
tGz3=p.tGz3;
Gz1Amp=p.Gz1Amp;
Gz2Amp=p.Gz2Amp;
Gz3Amp=p.Gz3Amp;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

% left crusher
[GAmp1,GTime1]=StdTrap(0,            ...
                       tGz1+2*tRamp, ...
                       tRamp,        ...
                       tGz1+tRamp,   ...
                       Gz1Amp,2,2,2);
                   
% slice selection
[GAmp2,GTime2]=StdRect(t2Start, ...
                       t2End,   ...
                       Gz2Amp,2);

% right crusher
[GAmp3,GTime3]=StdTrap(0,             ...
                       tGz3+2*tRamp,  ...
                       tRamp,         ...
                       tGz3+tRamp,    ...
                       Gz3Amp,2,2,2);
                   
GAmp=GAmp2;
GTime=GTime2;

if Gz1Amp~=0 & tGz1~=0;
    GAmp1(end) = GAmp2(1);
    GAmp=[GAmp1, GAmp];
    GTime=[t2Start-GTime1(end)+GTime1, GTime];
else
    GAmp=[0 GAmp];
    GTime=[GTime(1)-tRamp GTime];
end

if Gz3Amp~=0 & tGz3~=0;
    GAmp3(1) = GAmp2(end);
    GAmp=[GAmp, GAmp3];
    GTime=[GTime, t2End+GTime3];
else
    GAmp=[GAmp 0];
    GTime=[GTime GTime(end)+tRamp];
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

