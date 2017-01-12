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



%Convert DICOM-files to Matlab Matrix (orignally designed for Siemens MR scanner)
function [created_matrix,created_matrix_name,errflag]=MU_DICOM2Mat(filename,pathname,handles)
    
    created_matrix_name=[];
    if isempty(get(handles.Selected_file_list,'String'))
        errordlg('Please choose DICOM file(s) for creating matrix.');
        created_matrix=[];
        errflag=1;
        return;
    elseif isempty(get(handles.Edit_matrix_name,'String'))
        errordlg('Please provide a name for the matrix.');
        created_matrix=[];
        errflag=1;
        return;
    end
    
    try
        if iscell(filename)
            filenum=max(size(filename));
        else
            filenum=1;
            filename={filename};
        end
        for i=1:filenum
            created_matrix(:,:,i)=dicomread([pathname filename{i}]);
            if i==1
                tMx=created_matrix;
                tSize=size(tMx);
                created_matrix=zeros(tSize(1),tSize(2),filenum);
                created_matrix = cast(created_matrix, class(tMx)); % convert back to whatever original
                created_matrix(:,:,1)=tMx;
            end
            
            MU_update_waitbar(handles.DICOM_file_processing_waitbar_axes,i,filenum);
        end
%         created_matrix=double(created_matrix);
    catch me
        set(handles.DICOM_file_processing_waitbar_axes,'Visible','off');
        axes(handles.DICOM_file_processing_waitbar_axes);
        cla;

        errordlg('Ooops!!! DICOM files mismatch, conversion aborts.');
        errflag=1;
        return;
    end
    
    created_matrix_name=get(handles.Edit_matrix_name,'String');
    
    try
        eval([created_matrix_name '= 1;']);
    catch me
        errordlg('The input name is an invalid matlab name.');
        errflag = 1; % fail
        set(handles.DICOM_file_processing_waitbar_axes,'Visible','off');
        axes(handles.DICOM_file_processing_waitbar_axes);
        cla;
        return;
    end
    
    set(handles.Conversion_procedure_text,'String', 'Ready to go !!!');
    set(handles.Selected_file_list,'String', []);
    set(handles.Selected_file_list,'Value', 1);
    set(handles.Edit_matrix_name,'String', []);

    set(handles.DICOM_file_processing_waitbar_axes,'Visible','off');
    axes(handles.DICOM_file_processing_waitbar_axes);
    cla;

    errflag=0;

end