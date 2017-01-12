
function [mask, fvc]=VObjEllipsoid(p,x,y,z,flag)
%create 3D ellipsoid virtual object

% Initialize parameters
RadiusX=p.RadiusX;
RadiusY=p.RadiusY;
RadiusZ=p.RadiusZ;
CenterX=p.CenterX;
CenterY=p.CenterY;
CenterZ=p.CenterZ;
FaceNum=p.FaceNum;

% Generate ellipsoid coordinate
[X,Y,Z] = ellipsoid(CenterX,CenterY,CenterZ,RadiusX,RadiusY,RadiusZ,FaceNum);

fvc = surf2patch(X,Y,Z);

if flag~=1 % Render object only
    mask=0;
    return;
end

mask = vert2mask(fvc.vertices,x,y,z);
   
end