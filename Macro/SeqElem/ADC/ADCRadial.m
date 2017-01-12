



function [GAmp,GTime]=ADCRadial(p)

global VCtl;
global VObj;

tMiddle=p.tMiddle;

% 2D radial encoding
FOV = VCtl.FOVFreq; % choose FOVFreq as real FOV
Res = VCtl.ResFreq; % choose ResFreq as real resolution
ERes = VCtl.R_SampPerSpoke; % choose R_SampPerSpoke as effective radial resolution


GxAmp=(1/FOV)/((VObj.Gyro/(2*pi))*(1/VCtl.BandWidth));
tHalf=1/(2*(VObj.Gyro/(2*pi))*GxAmp*(FOV/Res));
[GAmp1,GTime1]=StdTrap(tMiddle+VCtl.TEAnchorTime-tHalf-VCtl.MinUpdRate, ...
                       tMiddle+VCtl.TEAnchorTime+tHalf+VCtl.MinUpdRate, ...
                       tMiddle+VCtl.TEAnchorTime-tHalf,               ...
                       tMiddle+VCtl.TEAnchorTime+tHalf,               ...
                       1,2,ERes,2);

GAmp=[GAmp1];
GTime=[GTime1];
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

end




