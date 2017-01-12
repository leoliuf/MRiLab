
function [GAmp,GTime]=GxCartesian(p)

global VCtl;
global VObj;

t1Start=p.t1Start;
t2Middle=p.t2Middle;
t3Start=p.t3Start;
tRamp=p.tRamp;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;
Gx3Sign=p.Gx3Sign;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

% frequency encoding
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);
[GAmp1,GTime1]=StdTrap(t1Start-tRamp,            ...
                       t1Start+tHalf+tRamp,      ...
                       t1Start,                          ...
                       t1Start+tHalf,                    ...
                       GxAmp*Gx1Sign,2,2,2);
[GAmp2,GTime2]=StdTrap(t2Middle+VCtl.TEAnchorTime-tHalf-tRamp, ...
                       t2Middle+VCtl.TEAnchorTime+tHalf+tRamp, ...
                       t2Middle+VCtl.TEAnchorTime-tHalf,               ...
                       t2Middle+VCtl.TEAnchorTime+tHalf,               ...
                       GxAmp*Gx2Sign,2,2,2);

[GAmp3,GTime3]=StdTrap(t3Start-tRamp,            ...
                       t3Start+tHalf+tRamp,      ...
                       t3Start,                          ...
                       t3Start+tHalf,                    ...
                       GxAmp*Gx3Sign,2,2,2);
                   
GAmp=GAmp2;
GTime=GTime2;

if Gx1Sign~=0
    GAmp=[GAmp1, GAmp];
    GTime=[GTime1, GTime];
end

if Gx3Sign~=0
    GAmp=[GAmp, GAmp3];
    GTime=[GTime, GTime3];
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
