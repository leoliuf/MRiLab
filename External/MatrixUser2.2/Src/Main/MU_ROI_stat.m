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



function MU_ROI_stat(p,ROI_h,ROI_ind,handles)
global Figure_handles;
MU_main_handles=guidata(Figure_handles.MU_main);

if handles.V.ROI.ROI_flag==5 % line ROI
    p=getPosition(ROI_h);
    set(handles.V.ROI.ROI_Stat_h,'position',[p(2),p(4)],'string',{['length: ' num2str(round(sqrt(((p(2)-p(1))^2+(p(4)-p(3))^2)))) ' p']});
elseif handles.V.ROI.ROI_flag==6 % line profile
    p=round(getPosition(ROI_h));
    p0=p;
    BW=createMask(ROI_h); 
    p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
    dp=p0(1,:)-p(1:2)+1;
    TTMatrix=handles.BMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3));
    TTMatrix=TTMatrix(double(BW(p(2):p(2)+p(4),p(1):p(1)+p(3)))~=0);
    TTMatrix=double(TTMatrix);
    
    [I,J] = ind2sub(size(BW(p(2):p(2)+p(4),p(1):p(1)+p(3))),find(BW(p(2):p(2)+p(4),p(1):p(1)+p(3))~=0));
    Dist=sqrt((I-repmat(dp(2),size(I))).^2+(J-repmat(dp(1),size(J))).^2); % distance, assume square pixel
    [DistS,ind]=sort(Dist(:));

    plot(handles.V.ROI.ROI_Stat_h,DistS,TTMatrix(ind));
    grid(handles.V.ROI.ROI_Stat_h,'on');
    ylabel(handles.V.ROI.ROI_Stat_h,'Voxel Value','FontSize',10);
    xlabel(handles.V.ROI.ROI_Stat_h,'Voxel Distance','FontSize',10);
elseif handles.V.ROI.ROI_flag==7 % angle
    p=getPosition(ROI_h);
    p2=circshift(p,[1,0]);
    p3=circshift(p,[-1,0]);
    dp=p-p2;
    dp2=p-p3;
    for i=1:length(p(:,1))
        theta = acos(dot(dp(i,:),dp2(i,:))./(norm(dp(i,:)).*norm(dp2(i,:))))*180/pi;
        set(handles.V.ROI.ROI_Stat_h(i),'position',[p(i,1),p(i,2)],'string',{['Angle: ' num2str(theta)]},'FontSize',10,'Color','g');
    end
else
    p=round(p);
    if min(size(p))~=1
        p=[min(p(:,1)) min(p(:,2)) max(p(:,1))-min(p(:,1)) max(p(:,2))-min(p(:,2))];
    end
    BW=createMask(ROI_h); 
    TTMatrix=handles.BMatrix(p(2):p(2)+p(4),p(1):p(1)+p(3));
    TTMatrix=TTMatrix(double(BW(p(2):p(2)+p(4),p(1):p(1)+p(3)))~=0);
    handles.ROIData=TTMatrix;
    set(handles.V.ROI.ROI_Stat_h,'position',[p(1)+p(3),p(2)+p(4)],'string',{[' ROI#: ' num2str(ROI_ind)]; ...
                                                                            [' mean: ' num2str(mean(double(TTMatrix(:))))]; ...
                                                                            [' sd:' num2str(std(double(TTMatrix(:))))]; ...
                                                                            [' sd(%):' num2str(abs(std(double(TTMatrix(:)))./mean(double(TTMatrix(:))))*100)]});
    MU_main_handles.V.ROIs{ROI_ind,3}=getPosition(ROI_h);
end
guidata(handles.MU_matrix_display, handles);
guidata(Figure_handles.MU_main,MU_main_handles);