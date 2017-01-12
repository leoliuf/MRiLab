
function [mask, fvc]=VObjSphere(p,x,y,z,flag)
%create 3D sphere virtual object

% Initialize parameters
Radius=p.Radius;
FaceNum=p.FaceNum;
CenterX=p.CenterX;
CenterY=p.CenterY;
CenterZ=p.CenterZ;

% Generate sphere coordinate
[X,Y,Z] = sphere(FaceNum); 
X=X*Radius+CenterX;
Y=Y*Radius+CenterY;
Z=Z*Radius+CenterZ;

fvc = surf2patch(X,Y,Z);

if flag~=1 % Render object only
    mask=0;
    return;
end

mask = vert2mask(fvc.vertices,x,y,z);
   
end