
function [GAmp,GTime]=GzAreaTrapezoid2(p) % unit m-1
% Trapezoid with prescribed area & maximum slew rate & maximum gradient amp
% note: don't support ramp sampling

global VCtl
global VObj

tStart=p.tStart; % start time
Area=abs(p.Area);   % trapezoid area m-1
Duplicates=max(1,p.Duplicates);
DupSpacing=max(0,p.DupSpacing);

Area=Area/(VObj.Gyro/(2*pi));
GzAmp=VCtl.MaxGrad;   % Gz amplitude
if Area/GzAmp < VCtl.MinUpdRate
    tEnd=VCtl.MinUpdRate + tStart;
    GzAmp=Area/VCtl.MinUpdRate;   % Gz amplitude
else
    tEnd=Area/GzAmp + tStart;
end

tRamp=max(VCtl.MinUpdRate,GzAmp/VCtl.MaxSlewRate);   % ramp time

[GAmp,GTime]=StdTrap(tStart-tRamp, ...
                     tEnd+tRamp,   ...
                     tStart,               ...
                     tEnd,                 ...
                     GzAmp*sign(p.Area),2,2,2);

[GTime,m,n]=unique(GTime);
GAmp=GAmp(m);

% Create Duplicates
if Duplicates~=1 & DupSpacing ~=0
    GAmp=repmat(GAmp,[1 Duplicates]);
    TimeOffset = repmat(0:DupSpacing:(Duplicates-1)*DupSpacing,[length(GTime) 1]);
    GTime=repmat(GTime,[1 Duplicates]) + (TimeOffset(:))';
end

end
