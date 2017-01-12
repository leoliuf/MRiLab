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



function MU_calc_matrix(handles)

try
    MergeM=get(handles.Matrix_name_edit,'String');
    TMatrix=evalin('base', ['[' MergeM ']']);
    
    if ~isreal(TMatrix)
        MU_Matrix_Display(MergeM,'Magnitude');
        MU_Matrix_Display(MergeM,'Phase');
        display([char(39) MergeM char(39) ' is complex matrix.']);
        delete(handles.MU_matrix_display);
        return;
    end

    % initialize display & more
    handles=MU_display_initialize(handles.MU_matrix_display,handles,MergeM,TMatrix);
    if isempty(handles)
        return;
    end

    handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
catch me
    error_msg{1,1}='Syntax ERROR!!! Calculating matrices failed.';
    error_msg{2,1}=me.message;
    error_msg{3,1}='---------------------------------------------------------------------';
    error_msg{4,1}='Note: ';
    error_msg{5,1}='Support matrix concatenation & recombination ';
    error_msg{6,1}='  Source matrices must be in BASE WORKSPACE.';
    error_msg{7,1}='  Use coma for row seperator, semicoma for column seperator.';
    error_msg{8,1}='  Use zeros(size(?)) for zero padding.';
    error_msg{9,1}='Example: ';
    error_msg{10,1}='  A,B;C,D';
    error_msg{11,1}='  A*100,B;C,D';
    error_msg{12,1}='  A*100,B;C,zeros(size(C))';
    error_msg{13,1}='Support valid Matlab matrix calculation expression';
    error_msg{14,1}='Example: ';
    error_msg{15,1}='  A+B';
    error_msg{16,1}='  sin(A)+cos(B),A';
    error_msg{17,1}='  A.*B,B.^2';
    error_msg{18,1}='---------------------------------------------------------------------';
    errordlg(error_msg);
    return;
end
guidata(handles.MU_matrix_display, handles);


end