
function [GAmp,GTime]=GzCartesian(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start; %ms
t1End=p.t1End; %ms
t2Start=p.t2Start;
t2End=p.t2End;
tRamp=p.tRamp;
Gz1Sign=p.Gz1Sign;
Gz2Sign=p.Gz2Sign;
% GzOrder=p.GzOrder;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

% if strcmp(GzOrder,'centric')
%     if VVar.SliceCount==1 & VVar.PhaseCount==1
%        SliceCount = (-1)^rem(VVar.SliceCount-1,2)*(VVar.SliceCount-1);
%        VVar.SliceCountTmp = 0;
%     elseif VVar.PhaseCount~=1
%        SliceCount = VVar.SliceCountTmp;
%     else
%        SliceCount = (-1)^rem(VVar.SliceCount-1,2)*(VVar.SliceCount-1) + VVar.SliceCountTmp;
%        VVar.SliceCountTmp = SliceCount;
%     end
% elseif strcmp(GzOrder,'sequential')
%     SliceCount = VVar.SliceCount-floor(VCtl.SliceNum/2)-1;
% end

% phase encoding
GzdG=1/((VObj.Gyro/(2*pi))*(t1End-t1Start)*VCtl.FOVSlice);
[GAmp1,GTime1]=StdTrap(t1Start-tRamp, ...
                       t1End+tRamp,   ...
                       t1Start,               ...
                       t1End,                 ...
                       (VVar.SliceCount-floor(VCtl.SliceNum/2)-1)*GzdG*Gz1Sign,2,2,2); % use floor to make Kz = 0 when VCtl.SliceNum=1
% rephasing
GzdG=1/((VObj.Gyro/(2*pi))*(t2End-t2Start)*VCtl.FOVSlice);
[GAmp2,GTime2]=StdTrap(t2Start-tRamp, ...
                       t2End+tRamp,   ...
                       t2Start,               ...
                       t2End,                 ...
                       (VVar.SliceCount-floor(VCtl.SliceNum/2)-1)*GzdG*Gz2Sign,2,2,2);

GAmp=GAmp1;
GTime=GTime1;

if Gz2Sign~=0
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
