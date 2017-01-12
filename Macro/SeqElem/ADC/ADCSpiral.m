
function [GAmp,GTime]=ADCSpiral(p)

global VCtl;
global VObj;

tStart=p.tStart;

% 2D spiral readout
FOV = VCtl.FOVFreq; % choose FOVFreq as FOV
Res = VCtl.ResFreq; % choose ResFreq as effective resolution

KMax  = Res/ (2*FOV);
ThetaMax = KMax / VCtl.S_Lamda;
Beta = (VObj.Gyro/(2*pi))*(VCtl.S_SlewRate / VCtl.S_Lamda);
a2 = (9*Beta/4)^(1/3);
CLamda = VCtl.S_SlewRate/VCtl.S_SlewRate0;
Ts = ((3*VObj.Gyro*VCtl.S_Gradient)/(4*pi*VCtl.S_Lamda*a2^2))^3;

ThetaTs = (0.5 * Beta * Ts^2)/(CLamda + (Beta/(2 * a2)) * Ts^(4/3));
if ThetaTs < ThetaMax
    Tacq = Ts + ((pi*VCtl.S_Lamda)/(VObj.Gyro * VCtl.S_Gradient))*(ThetaMax^2 - ThetaTs^2);
    t     = Tacq;
else
    Tacq = ((2*pi*FOV)/(3*VCtl.S_ShotNum))*sqrt(pi/(VObj.Gyro*VCtl.S_SlewRate*VCtl.RFreq^3));
    t     = Tacq;
end
                   
[GAmp,GTime]=StdTrap(tStart+VCtl.TEAnchorTime-VCtl.MinUpdRate, ...
                     tStart+VCtl.TEAnchorTime+t+VCtl.MinUpdRate, ...
                     tStart+VCtl.TEAnchorTime,               ...
                     tStart+VCtl.TEAnchorTime+t,               ...
                     1,2,floor(t*VCtl.BandWidth),2);

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);


end
