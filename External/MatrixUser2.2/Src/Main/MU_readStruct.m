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



% convert struct variable for display
function cstr=MU_readStruct(structure)
    
    field_names=fieldnames(structure);
    for k=1:max(size(field_names))
        estr=structure.(field_names{k});
        if ischar(estr)
            str=[field_names{k} ' : ' estr];
        elseif isnumeric(estr)
            tmp=estr(1:min(10,end));
            str=[field_names{k} ' : ' num2str((tmp(:))')];
        elseif iscell(estr)
            str=[field_names{k} ' : ' '...Cell...'];
        elseif isstruct(estr)
            str=[field_names{k} ' : ' '...Struct...'];
        elseif islogical(estr)
            str=[field_names{k} ' : ' '...logical...'];
        else
            str=[field_names{k} ' : ' '...'];
        end
        cstr{k}=str;
    end

end