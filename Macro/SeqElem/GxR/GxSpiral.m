
function [GAmp,GTime]=GxSpiral(p)

global VCtl;
global VObj;
global VVar;

tStart=p.tStart;
dt = p.dt;

% 2D spiral encoding
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
    t1 = 0:dt:Ts;
    Theta1 = (0.5 * Beta * t1.^2)./(CLamda + (Beta/(2 * a2)) * t1.^(4/3));
    
    Tacq = t1(end) + ((pi*VCtl.S_Lamda)/(VObj.Gyro * VCtl.S_Gradient))*(ThetaMax^2 - Theta1(end)^2);
    t2 = t1(end):dt:Tacq;
    Theta2 = sqrt(Theta1(end)^2 + (VObj.Gyro / (pi * VCtl.S_Lamda))*VCtl.S_Gradient*(t2 - t1(end)));
    
    Theta = [Theta1(1:end-1) Theta2];
    t     = [t1(1:end-1)     t2];
    
else
    Tacq = ((2*pi*FOV)/(3*VCtl.S_ShotNum))*sqrt(pi/(VObj.Gyro*VCtl.S_SlewRate*VCtl.RFreq^3));
    t1 = 0:dt:Tacq;
    Theta1 = (0.5 * Beta * t1.^2)./(CLamda + (Beta/(2 * a2)) * t1.^(4/3));
    
    Theta = Theta1;
    t     = t1;
end

DTheta = [0 diff(Theta)./diff(t)];

GAmp = ((2*pi)/(VObj.Gyro))*VCtl.S_Lamda*DTheta.*(cos(Theta + (VVar.PhaseCount-1)*(2*pi/VCtl.S_ShotNum)) ...
                                         - Theta.*sin(Theta + (VVar.PhaseCount-1)*(2*pi/VCtl.S_ShotNum)));
GTime = tStart + VCtl.TEAnchorTime + t;

GTime = [GTime GTime(end) + max(VCtl.MinUpdRate,abs(GAmp(end)/VCtl.S_SlewRate))];
GAmp = [GAmp 0];
                   
[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);


end
