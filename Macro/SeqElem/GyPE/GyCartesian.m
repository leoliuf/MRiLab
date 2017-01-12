
function [GAmp,GTime]=GyCartesian(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t1End=p.t1End;
t2Start=p.t2Start;
t2End=p.t2End;
tRamp=p.tRamp;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;
% GyOrder=p.GyOrder;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

% if strcmp(GyOrder,'centric')
%     if VVar.PhaseCount==1
%        VVar.PhaseCountTmp = 0;
%     end
%     PhaseCount = (-1)^rem(VVar.PhaseCount-1,2)*(VVar.PhaseCount-1) + VVar.PhaseCountTmp;
%     VVar.PhaseCountTmp    = PhaseCount;
% elseif strcmp(GyOrder,'sequential')
%     PhaseCount = VVar.PhaseCount-VCtl.ResPhase/2-1;
% end

% phase encoding
GydG=1/((VObj.Gyro/(2*pi))*(t1End-t1Start)*VCtl.FOVPhase);
[GAmp1,GTime1]=StdTrap(t1Start-tRamp,     ...
                       t1End+tRamp,       ...
                       t1Start,                   ...
                       t1End,                     ...
                       (VVar.PhaseCount-VCtl.ResPhase/2-1)*GydG*Gy1Sign,2,2,2);
% rephasing
GydG=1/((VObj.Gyro/(2*pi))*(t2End-t2Start)*VCtl.FOVPhase);
[GAmp2,GTime2]=StdTrap(t2Start-tRamp,     ...
                       t2End+tRamp,       ...
                       t2Start,                   ...
                       t2End,                     ...
                       (VVar.PhaseCount-VCtl.ResPhase/2-1)*GydG*Gy2Sign,2,2,2);

GAmp=GAmp1;
GTime=GTime1;

if Gy2Sign~=0
    GAmp=[GAmp, GAmp2];
    GTime=[GTime, GTime2];
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
