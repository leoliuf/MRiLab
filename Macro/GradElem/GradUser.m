
function G=GradUser(p)
%create gradient profile from data file

global VMgd
global VObj

load(p.GradFile); % load gradient profile file
Interp=p.Interp;
GradLine=p.GradLine;

% Initialize display grid
xgrid=VMgd.xgrid;
ygrid=VMgd.ygrid;
zgrid=VMgd.zgrid;

Mxdims=size(VObj.Rho);
max_xgrid=((Mxdims(2)-1)/2)*VObj.XDimRes;
max_ygrid=((Mxdims(1)-1)/2)*VObj.YDimRes;
max_zgrid=((Mxdims(3)-1)/2)*VObj.ZDimRes;
min_xgrid=(-(Mxdims(2)-1)/2)*VObj.XDimRes;
min_ygrid=(-(Mxdims(1)-1)/2)*VObj.YDimRes;
min_zgrid=(-(Mxdims(3)-1)/2)*VObj.ZDimRes;

[row,col,layer,com] = size(G);

[Gradx,Grady,Gradz]=meshgrid(linspace(min_xgrid, max_xgrid, col),...
                             linspace(min_ygrid, max_ygrid, row),...
                             linspace(min_zgrid, max_zgrid, layer));

G2(:,:,:,1)=ba_interp3(Gradx,Grady,Gradz,G(:,:,:,1),xgrid,ygrid,zgrid,Interp);
G2(:,:,:,2)=ba_interp3(Gradx,Grady,Gradz,G(:,:,:,2),xgrid,ygrid,zgrid,Interp);
G2(:,:,:,3)=ba_interp3(Gradx,Grady,Gradz,G(:,:,:,3),xgrid,ygrid,zgrid,Interp);
G2(isinf(G2)) = 0;

G=G2;


end