
function [t, Disp, Axis, Ang]=MotTranslate(p)
%create motion vector for translating object

% Initialize parameters
tStart         = p.tStart;
tEnd           = p.tEnd;
dt             = p.dt;
Direction      = p.Direction;
Displacement   = p.Displacement;

% Create motion track
t = tStart : dt : tEnd;
eval(['Disp = ' Displacement ';']);
Disp = (Direction./norm(Direction))* Disp;

Axis = [];
Ang = [];

   
end