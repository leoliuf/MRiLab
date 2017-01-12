
function [mask, fvc]=VObjCylinder(p,x,y,z,flag)
%create 3D cylinder virtual object

% Initialize parameters
Radius=p.Radius;
FaceNum=p.FaceNum;
Length=p.Length;
CenterX=p.CenterX;
CenterY=p.CenterY;
CenterZ=p.CenterZ;

% Generate cylinder coordinate
[X,Y,Z] = cylinder(Radius,FaceNum); 
X=X+CenterX;
Y=Y+CenterY;
Z=(Z-0.5)*Length/2+CenterZ;

fvc = surf2patch(X,Y,Z);

if flag~=1 % Render object only
    mask=0;
    return;
end

mask = vert2mask(fvc.vertices,x,y,z);
   
end