
function [t, Disp, Axis, Ang]=MotRotate(p)
%create motion vector for rotating object

% Initialize parameters
tStart    = p.tStart;
tEnd      = p.tEnd;
dt        = p.dt;
Axis      = p.Axis;
Angle     = p.Angle;

% Create motion track
t = tStart : dt : tEnd;
eval(['Ang = ' Angle ';']);
Axis = Axis * ones(1,length(t));

Disp = [];


end