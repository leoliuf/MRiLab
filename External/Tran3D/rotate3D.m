
function Tr_Im=rotate3D(Im, T, R)
% rotate 3D volume by T & R

[row,col,layer] = size(Im);
Tr_Im = tformarray(Im, T, R, [1 2 3], [1 2 3], [row, col,layer], [], []);

end