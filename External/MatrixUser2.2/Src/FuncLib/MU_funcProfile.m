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



function MU_funcProfile(Temp,Event,handles)
handles = guidata(handles.MU_matrix_display);

MU_enable('off',[],handles);
ROI_h=imline;
MU_enable('on',[],handles);
p=round(getPosition(ROI_h));
p0=p;
try
    BW=createMask(ROI_h);
catch me
    delete(ROI_h);
    errordlg(me.message);
    return;
end
p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
dp=p0(1,:)-p(1:2)+1;
TTMatrix=handles.BMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3));
TTMatrix=TTMatrix(double(BW(p(2):p(2)+p(4),p(1):p(1)+p(3)))~=0);
TTMatrix=double(TTMatrix);

[I,J] = ind2sub(size(BW(p(2):p(2)+p(4),p(1):p(1)+p(3))),find(BW(p(2):p(2)+p(4),p(1):p(1)+p(3))~=0));
Dist=sqrt((I-repmat(dp(2),size(I))).^2+(J-repmat(dp(1),size(J))).^2);
[DistS,ind]=sort(Dist(:));

Plot_handle=MU_Plot;
set(Plot_handle,'Name','1D Profile','DeleteFcn',{@deletefig,ROI_h});
Plot_handles=guidata(Plot_handle);
ROI_Stat_h=Plot_handles.Plot_axes;
plot(ROI_Stat_h,DistS,TTMatrix(ind));
grid(ROI_Stat_h,'on');
ylabel(ROI_Stat_h,'Voxel Value','FontSize',10);
xlabel(ROI_Stat_h,'Voxel Distance','FontSize',10);

handles.V.ROI=struct(...
                     'ROI_flag', 6,...
                     'ROI_mov',[],...  % ROI movement track
                     'ROI_Stat_h', ROI_Stat_h,...    
                     'ROI_h', ROI_h ...
                     );

addNewPositionCallback(ROI_h,@(p) MU_ROI_stat(p,ROI_h,[],handles));
fcn=makeConstrainToRectFcn('imline',[0.5 handles.V.Column+0.4],[0.5 handles.V.Row+0.4]);
setPositionConstraintFcn(ROI_h,fcn);

function deletefig(Temp,Event,ROI_h)
if ROI_h.isvalid == 1
    delete(ROI_h);
end
end


end