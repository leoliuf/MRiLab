
function [GAmp,GTime]=ADCFSE(p)

global VCtl;
global VObj;

tMiddle=p.tMiddle;

% acqusition lobs
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);
tRamp=VCtl.MinUpdRate;

TimeOffset = (tMiddle+VCtl.TEAnchorTime)-floor(VCtl.FSE_ETL/2)*VCtl.FSE_ESP;
GAmp=zeros(1, VCtl.FSE_ETL * (VCtl.ResFreq + 2));
GTime=zeros(1, VCtl.FSE_ETL * (VCtl.ResFreq + 2));
for i = 1: VCtl.FSE_ETL                  
    [GAmpt,GTimet]=StdTrap(TimeOffset + (i-1)*VCtl.FSE_ESP -tHalf -tRamp, ...
                           TimeOffset + (i-1)*VCtl.FSE_ESP +tHalf +tRamp, ...
                           TimeOffset + (i-1)*VCtl.FSE_ESP -tHalf, ...
                           TimeOffset + (i-1)*VCtl.FSE_ESP +tHalf, ...
                           1,2,VCtl.ResFreq,2);
    GAmp((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GAmpt;
    GTime((i-1)*(VCtl.ResFreq + 2)+1 : i*(VCtl.ResFreq + 2))=GTimet;
end
                   
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end




