
function [B1x,B1y,B1z,E1x,E1y,E1z,Pos]=CoilUser(p)
%create B1 field from data file

global VMco
global VObj

load(p.B1File); % load B1 file
load(p.E1File); % load E1 file
CoilID=p.CoilID;
PosX=p.PosX;
PosY=p.PosY;
PosZ=p.PosZ;
Interp=p.Interp;

% Initialize display grid
xgrid=VMco.xgrid;
ygrid=VMco.ygrid;
zgrid=VMco.zgrid;

Mxdims=size(VObj.Rho);
max_xgrid=((Mxdims(2)-1)/2)*VObj.XDimRes;
max_ygrid=((Mxdims(1)-1)/2)*VObj.YDimRes;
max_zgrid=((Mxdims(3)-1)/2)*VObj.ZDimRes;
min_xgrid=(-(Mxdims(2)-1)/2)*VObj.XDimRes;
min_ygrid=(-(Mxdims(1)-1)/2)*VObj.YDimRes;
min_zgrid=(-(Mxdims(3)-1)/2)*VObj.ZDimRes;

[row,col,layer] = size(B1x);

[B1Gx,B1Gy,B1Gz]=meshgrid(linspace(min_xgrid, max_xgrid, col),...
                          linspace(min_ygrid, max_ygrid, row),...
                          linspace(min_zgrid, max_zgrid, layer));

B1x=ba_interp3(B1Gx,B1Gy,B1Gz,B1x,xgrid,ygrid,zgrid,Interp);
B1y=ba_interp3(B1Gx,B1Gy,B1Gz,B1y,xgrid,ygrid,zgrid,Interp);
B1z=ba_interp3(B1Gx,B1Gy,B1Gz,B1z,xgrid,ygrid,zgrid,Interp);
B1x(isinf(B1x)) = 0;
B1y(isinf(B1y)) = 0;
B1z(isinf(B1z)) = 0;

E1x=ba_interp3(B1Gx,B1Gy,B1Gz,E1x,xgrid,ygrid,zgrid,Interp);
E1y=ba_interp3(B1Gx,B1Gy,B1Gz,E1y,xgrid,ygrid,zgrid,Interp);
E1z=ba_interp3(B1Gx,B1Gy,B1Gz,E1z,xgrid,ygrid,zgrid,Interp);
E1x(isinf(E1x)) = 0;
E1y(isinf(E1y)) = 0;
E1z(isinf(E1z)) = 0;

Pos=[PosX, PosY, PosZ];


end