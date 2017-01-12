
function [B1x,B1y,B1z,E1x,E1y,E1z,Pos]=CoilCircle(p)
%create B1 field produced by Biot-Savart loop

global VCco

% Initialize parameters
CoilID=p.CoilID;
PosX=p.PosX;
PosY=p.PosY;
PosZ=p.PosZ;
Azimuth=p.Azimuth;
Elevation=p.Elevation;
Radius=p.Radius;
Segment=p.Segment;
Scale=p.Scale;
CurrentDir=p.CurrentDir;

% Divide segment
if CurrentDir==1 % clock-wise
    theta=linspace(0,2*pi,Segment+1);
elseif CurrentDir==-1 % counterclock-wise
    theta=linspace(0,-2*pi,Segment+1);
end

N=[cos(Elevation)*cos(Azimuth) cos(Elevation)*sin(Azimuth) sin(Elevation)];
N=N/norm(N);
v=null(N);
ang=atan2(dot(cross(v(:,1),v(:,2)),N),dot(cross(v(:,1),N),cross(v(:,2),N))); % determine angle direction
v(:,1)=(ang/abs(ang))*v(:,1); % match angle direction
points=repmat([PosX PosY PosZ]',1,size(theta,2))+Radius*(v(:,1)*cos(theta)+v(:,2)*sin(theta));

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