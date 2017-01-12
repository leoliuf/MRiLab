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



function MU_funcMovie(Temp,Event,handles)
handles=guidata(handles.MU_matrix_display);

if length(handles.V.DimSize)==2
    warndlg('At least 3D matrix is needed for generating movie.');
    return;
end

dimFlag = ['[:' repmat(',:', [1 length(handles.V.DimSize)-1]) ']'];
dim = inputdlg(['Please specify dimension flag for generating movie. Use '':'' to include all content in the dimension; Use ''start:end'' to include parts of the content in the dimension.'],'Specify Dimension Flag',1,{dimFlag});
if isempty(dim)
    warndlg('Making movie was cancelled.');
    return;
end

movie = inputdlg({'Please specify the frame rate (fps).', 'Please specify the movie quality (lowest 0 - 100 highest)'},'About Movie',1,{'30' ,'75'});
if isempty(movie)
    warndlg('Making movie was cancelled.');
    return;
end

MergeM=get(handles.Matrix_name_edit,'String');
name = inputdlg(['Please input an name for the movie file.'],'Specify File Name',1,{[MergeM '_mov']});
if isempty(dim)
    warndlg('Making movie was cancelled.');
    return;
end

pause(0.1);
try 
    eval(['TMatrix=handles.TMatrix(' dim{1}(2:end-1) ');']);
    TSize=size(TMatrix);
    TMatrix=TMatrix(:,:,:);
    dimSize=size(TMatrix);
    TMatrix=reshape(TMatrix,[dimSize(1) dimSize(2) 1 dimSize(3)]);
    
    if isempty(handles.V2.Foreground_matrix) % no overlay
        
        Colormap = colormap(handles.Matrix_display_axes);
        TMatrix=double(TMatrix);
        TMatrix(TMatrix<=double(handles.V.C_lower)) = double(handles.V.C_lower);
        TMatrix(TMatrix>=double(handles.V.C_upper)) = double(handles.V.C_upper);
        TMatrix=TMatrix-double(handles.V.C_lower);
        TMatrix=(TMatrix./double(handles.V.C_upper - handles.V.C_lower))*(length(Colormap(:,1))-1)+1;
        
        M=immovie(TMatrix,Colormap);
        
    else % if overlay
        BImage=double(repmat(TMatrix,[1 1 3 1]));
        BImage=max(double(handles.V.C_lower),min(BImage,double(handles.V.C_upper))); % Make sure BImage is in the range of Color Bound
        BImage=(BImage-double(handles.V.C_lower))./double((handles.V.C_upper-handles.V.C_lower));
        
        eval(['mask=double(handles.Mask(' dim{1}(2:end-1) '));']); % multi-dimensional mask??????
        TSize2=size(mask);
        if length(TSize)>length(TSize2) & length(TSize2)==2
            mask=repmat(mask,[1,1,prod(TSize(3:end))]);
        elseif length(TSize)>length(TSize2) & length(TSize2)==3
            mask=repmat(mask,[1,1,1,prod(TSize(4:end))]);
        end
        mask=mask(:,:,:); 
        FMatrix=((max(double(handles.V2.F_lower),min(mask,double(handles.V2.F_upper)))-handles.V2.F_lower)/(handles.V2.F_upper-handles.V2.F_lower))*(64-1)+1; % Make sure FMatrix is in the range of Color Bound
        FImage=ind2rgb(round(FMatrix(:)),handles.V2.Color_map);
        if handles.V2.Include0 ~=0
            FImage(repmat(mask(:),[1 1 3])==0)=0;
        end
        FImage=reshape(FImage,[size(FMatrix) 3]);
        FImage=permute(FImage,[1 2 4 3]);
        RGBImage=BImage* handles.V2.Backgroud_F+FImage* handles.V2.Foregroud_F;
        RGBImage=max(0,min(RGBImage,1)); % Make sure RGBImage is in the range of 0 and 1
        
        M=immovie(RGBImage);
    end
    
    writerObj=VideoWriter(name{1});
    writerObj.FrameRate=str2double(movie{1});
    writerObj.Quality=str2double(movie{2});
    open(writerObj);
    writeVideo(writerObj,M);
    msgbox(['Movie file ' char(39) writerObj.Filename char(39) ' has been generated at ' char(39) writerObj.Path char(39) '.'],'Movie File');
    close(writerObj);
catch me
    error_msg{1,1}='Making movie failed! Error occured during movie generation process.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

% update current display matrix
handles=MU_update_image(handles.Matrix_display_axes,{handles.TMatrix,handles.Mask},handles,0);
guidata(handles.MU_matrix_display, handles);

end