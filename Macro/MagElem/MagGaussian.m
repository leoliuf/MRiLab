
function dB0=MagGaussian(p)
%create dB0 field

global VMmg

% Initialize parameters
PosX=p.PosX;
PosY=p.PosY;
PosZ=p.PosZ;
DeltaX=p.DeltaX;
DeltaY=p.DeltaY;
DeltaZ=p.DeltaZ;
Scale=p.Scale;

% Initialize display grid
xgrid=VMmg.xgrid;
ygrid=VMmg.ygrid;
zgrid=VMmg.zgrid;

dB0=exp(-1.*((xgrid-PosX).^2/(2*DeltaX^2)+(ygrid-PosY).^2/(2*DeltaY^2)+(zgrid-PosZ).^2/(2*DeltaZ^2))).*Scale;
   
end