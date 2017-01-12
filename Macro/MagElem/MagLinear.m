
function dB0=MagLinear(p)
%create dB0 field

global VMmg

% Initialize parameters
GradX=p.GradX;
GradY=p.GradY;
GradZ=p.GradZ;
Scale=p.Scale;

% Initialize display grid
xgrid=VMmg.xgrid;
ygrid=VMmg.ygrid;
zgrid=VMmg.zgrid;

dB0=(xgrid.*GradX+ygrid.*GradY+zgrid.*GradZ).*Scale;

   
end