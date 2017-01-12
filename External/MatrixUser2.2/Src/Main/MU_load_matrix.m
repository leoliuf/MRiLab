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



% load matrix to base workspace
% open a new display with given matrix and matrix name if newWindowOpenFlag=1

function Flag=MU_load_matrix(matrixName, matrix, newWindowOpenFlag)

matrixList = evalin('base', 'who');
if ~isempty(matrixList)
    currentFlag=strcmp(matrixList,matrixName);
    if sum(currentFlag)~=0 % existing matrix 
       newName = inputdlg([char(39) matrixName ''' already exists in the base workspace. Input NEW matrix name, otherwise will overwrite existing matrix.'],'Overwrite',1,{matrixName});
       if isempty(newName)
           warndlg('Matrix name input was cancelled. You must provide an matrix name.');
           Flag = 0; % fail
           return;
       end
       if ~isempty(newName)
           matrixName = newName{1};
       end
    end
end

inputFlag=1;
while inputFlag==1
    try
        eval([matrixName '= 1;']);
        inputFlag = 0;
    catch me
        newName = inputdlg('The input name is invalid. Please input a valid matlab name.','Invalid Name',1,{matrixName});
        if isempty(newName)
            warndlg('Matrix name input was cancelled. You must provide an matrix name.');
            Flag = 0; % fail
            return;
        end
        if ~isempty(newName)
            matrixName = newName{1};
        end
    end
end

try
    assignin('base', matrixName, matrix);
catch me
    error_msg{1,1}='ERROR!!! Matrix creation aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    Flag = 0; % fail
    return;
end
display([char(39) matrixName ''' has been created in the base workspace.']);
Flag = 1; % OK

if newWindowOpenFlag
    if isreal(matrix)
        MU_Matrix_Display(matrixName,'Real');
    else
        MU_Matrix_Display(matrixName,'Magnitude');
        MU_Matrix_Display(matrixName,'Phase');
    end
end

end