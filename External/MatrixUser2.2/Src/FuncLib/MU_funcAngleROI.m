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



function MU_funcAngleROI(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

MU_enable('off',[],handles);
ROI_h=impoly;
MU_enable('on',[],handles);

p=getPosition(ROI_h);
if max(p(:,1))>handles.V.Column | max(p(:,2))>handles.V.Row | min(p(:,1))<1 | min(p(:,2))<1
    delete(ROI_h);     
    errordlg('Out of range subscript.');     
    return; 
end

ROI_Stat_h=zeros(1,length(p(:,1)));

p2=circshift(p,[1,0]);
p3=circshift(p,[-1,0]);
dp=p-p2;
dp2=p-p3;
for i=1:length(p(:,1))
    theta = acos(dot(dp(i,:),dp2(i,:))./(norm(dp(i,:)).*norm(dp2(i,:))))*180/pi;
    ROI_Stat_h(i)=text(p(i,1),p(i,2),{['Angle: ' num2str(theta)]},'FontSize',10,'Color','g');
end

handles.V.ROI=struct(...
                     'ROI_flag', 7,...
                     'ROI_mov',[],...  % ROI movement track
                     'ROI_Stat_h', ROI_Stat_h,...    
                     'ROI_h', ROI_h ...
                     );

guidata(handles.MU_matrix_display, handles);
addNewPositionCallback(ROI_h,@(p) MU_ROI_stat(p,ROI_h,[],handles));
fcn=makeConstrainToRectFcn('impoly',[0.5 handles.V.Column+0.4],[0.5 handles.V.Row+0.4]);
setPositionConstraintFcn(ROI_h,fcn);

end