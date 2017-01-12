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



function MU_funcRulerROI(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

MU_enable('off',[],handles);
ROI_h=imline;
MU_enable('on',[],handles);

p=getPosition(ROI_h);
try     
    BW=createMask(ROI_h); 
catch me     
    delete(ROI_h);     
    errordlg(me.message);     
    return; 
end
p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
ROI_Stat_h=text(p(1)+p(3),p(2)+p(4),{ ['length: ' num2str(round(sqrt(p(3)^2+p(4)^2))) ' p']},...
                                      'FontSize',10,'Color','g');
handles.V.ROI=struct(...
                     'ROI_flag', 5,...
                     'ROI_mov',[],...  % ROI movement track
                     'ROI_Stat_h', ROI_Stat_h,...    
                     'ROI_h', ROI_h ...
                     );
guidata(handles.MU_matrix_display, handles);                 
addNewPositionCallback(ROI_h,@(p) MU_ROI_stat(p,ROI_h,[],handles));
fcn=makeConstrainToRectFcn('imline',[0.5 handles.V.Column+0.4],[0.5 handles.V.Row+0.4]);
setPositionConstraintFcn(ROI_h,fcn);

end