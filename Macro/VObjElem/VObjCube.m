
function [mask, fvc]=VObjCube(p,x,y,z,flag)
%create 3D cube virtual object

% Initialize parameters
Length=p.Length;
CenterX=p.CenterX;
CenterY=p.CenterY;
CenterZ=p.CenterZ;

% Generate cube coordinate
vertices = [1 1 -1; 
            -1 1 -1; 
            -1 1 1; 
            1 1 1; 
            -1 -1 1;
            1 -1 1; 
            1 -1 -1;
            -1 -1 -1] * 0.5 * Length;

faces = [1 2 3 4; 
         4 3 5 6; 
         6 7 8 5; 
         1 2 8 7; 
         6 7 1 4; 
         2 3 5 8];

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