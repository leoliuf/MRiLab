
function [GAmp,GTime]=GyRadial(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t2Middle=p.t2Middle;
t3Start=p.t3Start;
tRamp=p.tRamp;
Gy1Sign=p.Gy1Sign;
Gy2Sign=p.Gy2Sign;
Gy3Sign=p.Gy3Sign;

% 2D radial encoding
FOV = VCtl.FOVFreq; % choose FOVFreq as real FOV
Res = VCtl.ResFreq; % choose ResFreq as real resolution

switch VCtl.R_AngPattern
    case 'Linear'
       eval(['R_AngRange=' VCtl.R_AngRange ';']);
       AngInc = R_AngRange / VCtl.R_SpokeNum;
    case 'Golden'
       AngInc = 111.246 * (pi/180); % Golden-angle sample
end

GyAmp=(1/FOV)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GyAmp*(FOV/Res));
[GAmp1,GTime1]=StdTrap(t1Start-tRamp,          ...
                       t1Start+tHalf+tRamp,    ...
                       t1Start,                          ...
                       t1Start+tHalf,                    ...
                       GyAmp*sin(AngInc * (VVar.PhaseCount - 1))*Gy1Sign,2,2,2);
[GAmp2,GTime2]=StdTrap(t2Middle+VCtl.TEAnchorTime-tHalf-tRamp, ...
                       t2Middle+VCtl.TEAnchorTime+tHalf+tRamp, ...
                       t2Middle+VCtl.TEAnchorTime-tHalf,               ...
                       t2Middle+VCtl.TEAnchorTime+tHalf,               ...
                       GyAmp*sin(AngInc * (VVar.PhaseCount - 1))*Gy2Sign,2,2,2);
[GAmp3,GTime3]=StdTrap(t3Start-tRamp,            ...
                       t3Start+tHalf+tRamp,      ...
                       t3Start,                          ...
                       t3Start+tHalf,                    ...
                       GyAmp*sin(AngInc * (VVar.PhaseCount - 1))*Gy3Sign,2,2,2);
                   
GAmp=GAmp2;
GTime=GTime2;

if Gy1Sign~=0
    GAmp=[GAmp1, GAmp];
    GTime=[GTime1, GTime];
end

if Gy3Sign~=0
    GAmp=[GAmp, GAmp3];
    GTime=[GTime, GTime3];
end

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);


end
