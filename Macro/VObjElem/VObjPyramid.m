
function [mask, fvc]=VObjPyramid(p,x,y,z,flag)
%create 3D pyramid virtual object

% Initialize parameters
Height=p.Height;
Length=p.Length;
CenterX=p.CenterX;
CenterY=p.CenterY;
CenterZ=p.CenterZ;

% Generate pyramid coordinate
vertices = [1 0 0
            0 1 0
            -1 0 0
            0 -1 0
            0 0 1];
vertices(1:4,:)=vertices(1:4,:)/sqrt(2)*Length;
vertices(5,:)=vertices(5,:)*Height;
faces = [1 2 5
         2 3 5
         3 4 5
         4 1 5
         1 3 2
         1 3 4];

vertices(:,1)=vertices(:,1)+CenterX;
vertices(:,2)=vertices(:,2)+CenterY;
vertices(:,3)=vertices(:,3)+CenterZ;

fvc.vertices=vertices;
fvc.faces=faces;

if flag~=1 % Render object only
    mask=0;
    return;
end

mask = vert2mask(fvc.vertices,x,y,z);
   
end