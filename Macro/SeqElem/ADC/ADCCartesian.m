
function [GAmp,GTime]=ADCCartesian(p)

global VCtl;
global VObj;

tMiddle=p.tMiddle;
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

% acqusition lobs
GxAmp=(1/VCtl.FOVFreq)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*VCtl.RFreq);
[GAmp1,GTime1]=StdTrap(tMiddle+VCtl.TEAnchorTime-tHalf-VCtl.MinUpdRate, ...
                       tMiddle+VCtl.TEAnchorTime+tHalf+VCtl.MinUpdRate, ...
                       tMiddle+VCtl.TEAnchorTime-tHalf,               ...
                       tMiddle+VCtl.TEAnchorTime+tHalf,               ...
                       1,2,VCtl.ResFreq,2);

GAmp=[GAmp1];
GTime=[GTime1];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    GAmp=repmat(GAmp,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(GTime) 1]);
    GTime=repmat(GTime,[1 Duplicates]) + (TimeOffset(:))';
end

end




