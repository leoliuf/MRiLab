
function [GAmp,GTime]=GxRadial(p)

global VCtl;
global VObj;
global VVar;

t1Start=p.t1Start;
t2Middle=p.t2Middle;
t3Start=p.t3Start;
tRamp=p.tRamp;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;
Gx3Sign=p.Gx3Sign;

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

GxAmp=(1/FOV)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*(FOV/Res));
[GAmp1,GTime1]=StdTrap(t1Start-tRamp,          ...
                       t1Start+tHalf+tRamp,    ...
                       t1Start,                          ...
                       t1Start+tHalf,                    ...
                       GxAmp*cos(AngInc * (VVar.PhaseCount - 1))*Gx1Sign,2,2,2);
[GAmp2,GTime2]=StdTrap(t2Middle+VCtl.TEAnchorTime-tHalf-tRamp, ...
                       t2Middle+VCtl.TEAnchorTime+tHalf+tRamp, ...
                       t2Middle+VCtl.TEAnchorTime-tHalf,               ...
                       t2Middle+VCtl.TEAnchorTime+tHalf,               ...
                       GxAmp*cos(AngInc * (VVar.PhaseCount - 1))*Gx2Sign,2,2,2);
[GAmp3,GTime3]=StdTrap(t3Start-tRamp,            ...
                       t3Start+tHalf+tRamp,      ...
                       t3Start,                          ...
                       t3Start+tHalf,                    ...
                       GxAmp*cos(AngInc * (VVar.PhaseCount - 1))*Gx3Sign,2,2,2);
                   
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


end
