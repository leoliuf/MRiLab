
function [T, R]=rotate3DT(v, theta)
% Generate TFORM for rotating 3D volume with an angle of theta along any spatial vector v;
% Im input 3D matrix
% v  rotating axis
% theta rotating angle

% T TFORM structure
% R resampling structure
% Note: by default the center voxel in Im was set as rotating origin.

global VVar
global VObj

T1 = [1 0 0 0
      0 1 0 0
      0 0 1 0
      -VVar.ObjLoc(2)/VObj.YDimRes, -VVar.ObjLoc(1)/VObj.XDimRes, -VVar.ObjLoc(3)/VObj.ZDimRes 1]; % forward translate matrix
 
T2 = angvec2tr(theta, v); % 3D rotate matrix

T3= [1 0 0 0
     0 1 0 0
     0 0 1 0
     VVar.ObjLoc(2)/VObj.YDimRes, VVar.ObjLoc(1)/VObj.XDimRes, VVar.ObjLoc(3)/VObj.ZDimRes 1]; % backward translate matrix

T = T1*T2*T3; % total transform matrix

T = maketform('affine', T);
R = makeresampler('cubic', 'fill');


