
function [GAmp,GTime]=GxFSE(p)

global VCtl;
global VObj;

t1Start=p.t1Start;
t2Middle=p.t2Middle;
Gx1Sign=p.Gx1Sign;
Gx2Sign=p.Gx2Sign;

GAmp=[];
GTime=[];
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);
tRamp=GxAmp/VCtl.MaxSlewRate;

% prephasing
[GAmp1,GTime1]=StdTrap(t1Start-tRamp,            ...
                       t1Start+tHalf+tRamp,      ...
                       t1Start,                          ...
                       t1Start+tHalf,                    ...
                       GxAmp*Gx1Sign,2,2,2);

GAmp=[GAmp GAmp1];
GTime=[GTime GTime1];

% frequency encoding
TimeOffset = (t2Middle+VCtl.TEAnchorTime)-floor(VCtl.FSE_ETL/2)*VCtl.FSE_ESP;                  
for i = 1: VCtl.FSE_ETL                  
    [GAmpt,GTimet]=StdTrap(TimeOffset + (i-1)*VCtl.FSE_ESP -tHalf -tRamp, ...
                           TimeOffset + (i-1)*VCtl.FSE_ESP +tHalf +tRamp, ...
                           TimeOffset + (i-1)*VCtl.FSE_ESP -tHalf, ...
                           TimeOffset + (i-1)*VCtl.FSE_ESP +tHalf, ...
                           GxAmp*Gx2Sign,2,2,2);
     GAmp=[GAmp GAmpt];
     GTime=[GTime GTimet];

end
                   
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);


end
