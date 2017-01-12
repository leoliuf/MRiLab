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



function MU_funcExtract(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

[Type,ok] = listdlg('ListString',{'Free-hand shape','Polygon shape','Circle shape'}, ...
                     'SelectionMode','single',...
                     'PromptString','Choose region shape',... 
                     'Name','Shape');
if ok==0
    warndlg('Extracting matrix is cancelled.');
    return;
end

MU_enable('off',[],handles);
switch Type
    case 1
        ROI_h=imfreehand;
    case 2
        ROI_h=impoly;
    case 3
        ROI_h=imellipse;
end
wait(ROI_h);
MU_enable('on',[],handles);

p=round(getPosition(ROI_h));

switch Type
    case 1
        p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
    case 2
        p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
end

if p(1)+p(3)>handles.V.Column | p(2)+p(4)>handles.V.Row | p(1)<1 | p(2)<1
    delete(ROI_h);     
    errordlg('Out of range subscript.');     
    return; 
end

BW=createMask(ROI_h);
BW=BW(p(2):p(2)+p(4),p(1):p(1)+p(3));

if numel(handles.V.DimSize)>=3
    dim = inputdlg(['Please specify up to which dimension to extract (2 ~ ' num2str(numel(handles.V.DimSize)) ').'],'Specify Dimension',1,{num2str(numel(handles.V.DimSize))});
    if isempty(dim)
        warndlg('Extracting was cancelled.');
        return;
    end
    try
        if str2double(dim{1})<2 | str2double(dim{1})>numel(handles.V.DimSize)
            errordlg('The input dimension is invalid.');
            return;
        end
        if str2double(dim{1}) == 2
            TMatrix=handles.TMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3),handles.V.Slice);
            
        else
            if str2double(dim{1})+1>numel(handles.V.DimSize)
                dimFlag =[];
            else
                dimFlag=num2str(handles.V.DimPointer(str2double(dim{1})+1:end),',%u');
            end
            eval(['TMatrix=handles.TMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3)' repmat(',:', [1 str2double(dim{1})-2]) dimFlag ');']);
            TSize=size(TMatrix);
            TSize(1)=1;
            TSize(2)=1;
            BW=repmat(BW,TSize);
        end
    catch me
        errordlg('The input dimension is invalid.');
        return;
    end
    
else
    TMatrix=handles.TMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3));
end

MatrixName=get(handles.Matrix_name_edit,'String');
TMatrix = cast(double(TMatrix).*BW, class(TMatrix)); % convert back to whatever original
if ~MU_load_matrix([MatrixName '_ext'], TMatrix, 1)
    errordlg('Matrix extracting failed!');
end


end