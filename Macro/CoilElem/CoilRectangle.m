
function [B1x,B1y,B1z,E1x,E1y,E1z,Pos]=CoilRectangle(p)
%create B1 field produced by Biot-Savart loop

global VCco

% Initialize parameters
CoilID=p.CoilID;
PosX=p.PosX;
PosY=p.PosY;
PosZ=p.PosZ;
Azimuth=p.Azimuth;
Elevation=p.Elevation;
Length=p.Length;
Width=p.Width;
Scale=p.Scale;
CurrentDir=p.CurrentDir;

points=[0  0  0  0  0
        1  1 -1 -1  1
        1 -1 -1  1  1]*0.5;

points(2,:)=points(2,:)*Width;
points(3,:)=points(3,:)*Length;

% Divide segment
if CurrentDir==1 % clock-wise
    points=fliplr(points);
elseif CurrentDir==-1 % counterclock-wise
    % do nothing
end

Rotz = [cos(Azimuth) -sin(Azimuth) 0
        sin(Azimuth) cos(Azimuth)  0
        0            0             1];
Roty = [cos(Elevation)  0    -sin(Elevation)
        0               1    0
        sin(Elevation)  0    cos(Elevation)];

points=Rotz*Roty*points;
points=points+repmat([PosX; PosY; PosZ],[1 5]);

% Save loops
VCco.loops{CoilID}=points;

% Calculate B1 field
pause(0.01);
[B1x,B1y,B1z]=CoilBiotSavart(points);
Pos=[PosX, PosY, PosZ];

% Compute scaled vectors of magnetic field direction
B1x = B1x*Scale;
B1y = B1y*Scale;
B1z = B1z*Scale;

% Fake E1 field for this macro
E1x = 0;
E1y = 0;
E1z = 0;
   
end