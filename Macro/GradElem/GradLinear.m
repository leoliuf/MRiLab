
function G=GradLinear(p)
%create gradient profile

global VMgd

% Initialize parameters
GradLine=p.GradLine;
GradX=p.GradX;
GradY=p.GradY;
GradZ=p.GradZ;

% Initialize display grid
xgrid=VMgd.xgrid;
ygrid=VMgd.ygrid;
zgrid=VMgd.zgrid;

G(:,:,:,1) = GradX.*ones(size(xgrid));
G(:,:,:,2) = GradY.*ones(size(ygrid));
G(:,:,:,3) = GradZ.*ones(size(zgrid));
   
end