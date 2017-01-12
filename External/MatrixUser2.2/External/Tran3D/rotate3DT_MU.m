% MatrixUser, a multi-dimensional matrix analysis software package
% https://sourceforge.net/projects/matrixuser/
% 
% The MatrixUser is a matrix analysis software package developed under Matlab
% Graphical User Interface Developing Environment (GUIDE). It features 
% functions that are designed and optimized for working with multi-dimensional
% matrix under Matlab. These functions typically includes functions for 
% multi-dimensional matrix display, matrix (image stack) analysis and matrix 
% processing.
%
% Author:
%   Fang Liu <leoliuf@gmail.com>
%   University of Wisconsin-Madison
%   Aug-30-2014



function [T, R]=rotate3DT_MU(o, v, theta, interp)
% Generate TFORM for rotating 3D volume with an angle of theta along any spatial vector v;
% Im input 3D matrix
% o  rotating origion
% v  rotating axis
% theta rotating angle
% interp interp method

% T TFORM structure
% R resampling structure
% Note: by default the center voxel in Im was set as rotating origin.

T1 = [1 0 0 0
      0 1 0 0
      0 0 1 0
      -o(2), -o(1), -o(3) 1]; % forward translate matrix
 
T2 = angvec2tr(theta, v); % 3D rotate matrix

T3= [1 0 0 0
     0 1 0 0
     0 0 1 0
     o(2), o(1), o(3) 1]; % backward translate matrix

T = T1*T2*T3; % total transform matrix

T = maketform('affine', T);
R = makeresampler(interp, 'fill');


