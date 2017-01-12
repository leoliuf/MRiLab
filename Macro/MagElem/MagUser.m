
function dB0=MagUser(p)
%create dB0 field from data file

global VMmg
global VObj

load(p.MagFile); % load dB0 file
Interp=p.Interp;

% Initialize display grid
xgrid=VMmg.xgrid;
ygrid=VMmg.ygrid;
zgrid=VMmg.zgrid;

Mxdims=size(VObj.Rho);
max_xgrid=((Mxdims(2)-1)/2)*VObj.XDimRes;
max_ygrid=((Mxdims(1)-1)/2)*VObj.YDimRes;
max_zgrid=((Mxdims(3)-1)/2)*VObj.ZDimRes;
min_xgrid=(-(Mxdims(2)-1)/2)*VObj.XDimRes;
min_ygrid=(-(Mxdims(1)-1)/2)*VObj.YDimRes;
min_zgrid=(-(Mxdims(3)-1)/2)*VObj.ZDimRes;

[row,col,layer] = size(dB0);

[Magx,Magy,Magz]=meshgrid(linspace(min_xgrid, max_xgrid, col),...
                          linspace(min_ygrid, max_ygrid, row),...
                          linspace(min_zgrid, max_zgrid, layer));

dB0=ba_interp3(Magx,Magy,Magz,dB0,xgrid,ygrid,zgrid,Interp);
dB0(isinf(dB0)) = 0;


end