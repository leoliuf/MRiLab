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



function MU_funcFreeROI(Temp,Event,handles)
global Figure_handles;
MU_main_handles=guidata(Figure_handles.MU_main);
handles = guidata(handles.MU_matrix_display);

MU_enable('off',[],handles);
ROI_h=imfreehand;
MU_enable('on',[],handles);

MU_main_handles.V.ROIs{end+1,1}='imfreehand';
MU_main_handles.V.ROIs{end,2}=ROI_h;
MU_main_handles.V.ROIs{end,3}=getPosition(ROI_h);
ROI_ind=length(MU_main_handles.V.ROIs(:,1));

p=round(getPosition(ROI_h));
if max(p(:,1))>handles.V.Column | max(p(:,2))>handles.V.Row | min(p(:,1))<1 | min(p(:,2))<1
    delete(ROI_h);     
    errordlg('Out of range subscript.');     
    return; 
end
BW=createMask(ROI_h); 
p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
TTMatrix=handles.BMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3));
TTMatrix=TTMatrix(double(BW(p(2):p(2)+p(4),p(1):p(1)+p(3)))~=0);
ROI_Stat_h=text(p(1)+p(3),p(2)+p(4),{[' ROI#: ' num2str(ROI_ind)]; ...
                                     [' mean: ' num2str(mean(double(TTMatrix(:))))]; ...
                                     [' sd:' num2str(std(double(TTMatrix(:))))]; ...
                                     [' sd(%):' num2str(abs(std(double(TTMatrix(:)))./mean(double(TTMatrix(:)))*100))]},...
                                     'FontSize',10,'Color','g');
                                 
handles.V.ROI=struct(...
                     'ROI_flag', 1,...
                     'ROI_mov',[],...  % ROI movement track
                     'ROI_Stat_h', ROI_Stat_h,... % ROI stats
                     'ROI_h', ROI_h ... % ROI handle
                     );
handles.ROIData=TTMatrix;
guidata(handles.MU_matrix_display, handles);
guidata(Figure_handles.MU_main,MU_main_handles);

addNewPositionCallback(ROI_h,@(p) MU_ROI_stat(p,ROI_h,ROI_ind,handles));
fcn=makeConstrainToRectFcn('imfreehand',[0.5 handles.V.Column+0.4],[0.5 handles.V.Row+0.4]);
setPositionConstraintFcn(ROI_h,fcn);

end
