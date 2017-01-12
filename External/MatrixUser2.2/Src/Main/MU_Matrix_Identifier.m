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



function flags=MU_Matrix_Identifier(matrices)

matrix_names=fieldnames(matrices);
for i=1:max(size(matrix_names))
        if strcmp(class(matrices.(matrix_names{i})),'double')
            d=size(matrices.(matrix_names{i}));
            if numel(d)==2
                    if d(1)==1 & d(2)==1
                            flag=0;
                    elseif d(1)==1 | d(2)==1
                            flag=1;
                    else
                            flag=2;
                    end
            elseif numel(d)==3
                    flag=3;
            elseif numel(d)==4
                    flag=4;
            elseif numel(d)>4
                    flag=-1;
            end
            flags.(matrix_names{i})=flag;
            
        else
            flags.(matrix_names{i})=-2;
        end
end
end