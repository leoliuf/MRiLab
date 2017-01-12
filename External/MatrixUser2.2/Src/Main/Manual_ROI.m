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



function Manual_ROI(Matrix,Disp_Matrix_Name,Init_Slice,Contrast_Interval)

% Mannual ROI selection

%--------------------------------------------Initializtion
%-----------------------------Pre-process for matrix
[Row,Column,Layer,TPs]= size(Matrix);
Matrix=double(Matrix);
Matrix(isnan(Matrix))=0;
Matrix(isinf(Matrix))=0;
Max_D=max(max(max(max(Matrix))));
Min_D=min(min(min(min(Matrix))));
Slice=Init_Slice;
ROI_Slice=0;
Time_Point=1;
route=[0,0];
ROI_sig=zeros(1,TPs);
ROI=0;
Line=[0 0];
mask=[];
Xlim=[0.5 512.5];
Ylim=[0.5 512.5];
%-----------------------------End

%-----------------------------Windows Contrast Change
Contrast_Low=Min_D;
Contrast_High=Max_D;
Contrast_Change=0;
%-----------------------------End

%-----------------------------Window 2
Handle2=figure('Name', 'Kinetic Profile of Voxel');
VLine=axes;
plot(VLine,1:TPs,zeros(1,TPs),'o-','MarkerFaceColor','green','Color','green','LineWidth',4,'MarkerSize',10);
set(VLine,'Color','black','FontSize',20);
axis(VLine,[1 TPs Min_D Max_D]);
ylabel(VLine,'Signal Intensity','FontSize',24);
xlabel(VLine,'Time Point','FontSize',24);
%-----------------------------End

%-----------------------------Window 1
Handle=figure('KeyReleaseFcn',@WindowKeyRelease,'KeyPressFcn',@WindowKeyPress, 'WindowScrollWheelFcn',@MouseScrollWheel,...
              'WindowButtonDownFcn',@MouseClick,'WindowButtonMotionFcn',{@MouseMove,flag},'Name', ['Display ' Disp_Matrix_Name ' DCE-MR Image']);
set(Handle,'Pointer','crosshair');
imagesc(Matrix(:,:,Slice,Time_Point),[Contrast_Low Contrast_High]);
colormap gray;
xlabel(['Slice #' num2str(Slice) '  ROI Slice #' num2str(ROI_Slice)],'FontSize',18);
title ('Post-Contrast Image 1','FontSize',20);
axis square;
colorbar;
%-----------------------------End
%--------------------------------------------End

function MouseClick(Temp,Event)
    flag=1;
    ROI_Slice=Slice;
    if ROI~=0
        delete(ROI);
        delete(Line(2));
        ROI_sig=zeros(1,TPs);
    end
    route=[0,0];
    set(gcf,'WindowButtonUpFcn',{@MouseUp});
    set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});
end

function MouseUp(Temp,Event)
    %------------------------------------------Prevent Single Click
    if max(size(route(:,1)))==1
        ROI=0;
        ROI_Slice=0;
        ROI_sig=zeros(1,TPs);
        xlabel(['Slice #' num2str(Slice) '  ROI Slice #' num2str(ROI_Slice)],'FontSize',18);
        flag=0;
        set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});
        return;
    end
    %------------------------------------------End

    route(1,:)=[];
    if route(end,1)==route(1,1) & route(end,2)==route(1,2)
        route(end,:)=[];
    end

    %------------------------------------------Prevent Out of Bounder
    if ~isempty(find(route(:,1)<1 | route(:,2)<1 | route(:,1)>Row | route(:,2)>Column))
        ROI=0;
        ROI_Slice=0;
        ROI_sig=zeros(1,TPs);
        xlabel(['Slice #' num2str(Slice) '  ROI Slice #' num2str(ROI_Slice)],'FontSize',18);
        flag=0;
        set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});
        return;
    end
    %------------------------------------------End

    line([route(:,2); route(1,2)],[route(:,1); route(1,1)],'Color','r');
    b_mask=boundary([route ; route(1,:)],[min(route(:,2)) max(route(:,2)) min(route(:,1)) max(route(:,1))]);
    mask=imfill(b_mask,'holes');
    %-------------------------------------------Plot ROI signal
    for i=1:TPs
        TMatrix=Matrix(:,:,Slice,i);
        v_mask=mask.*TMatrix(min(route(:,1)): max(route(:,1)), min(route(:,2)): max(route(:,2)));
        ROI_sig(i)=mean(v_mask(v_mask~=0));
    end
    plot(VLine,1:TPs,ROI_sig,'o-','MarkerFaceColor','red','Color','red','LineWidth',4,'MarkerSize',10);
    set(VLine,'Color','black','FontSize',20);
    axis(VLine,[1 TPs Min_D Max_D]);
    ylabel(VLine,'Signal Intensity','FontSize',24);
    xlabel(VLine,'Time Point','FontSize',24);
    %-------------------------------------------End
    %-------------------------------------------Show ROI
    [R,C]=find(mask~=0);
    ROI=scatter(get(Handle,'CurrentAxes'),C+min(route(:,2))-1,R+min(route(:,1))-1,'ro','filled');
    xlabel(['Slice #' num2str(Slice) '  ROI Slice #' num2str(ROI_Slice)],'FontSize',18);
    %-------------------------------------------End
    flag=0;
    set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});

end

function MouseMove(Temp,Event,flag)
    point=get(gca,'currentpoint');
    x=round(point(1));
    y=round(point(3));
    caxis=get(gca);
    Xlim=caxis.XLim;
    Ylim=caxis.YLim;
    if x>0 & y>0 & x<=Column & y<=Row
        if sum(ROI_sig)~=0
            Line=plot(VLine,1:TPs,squeeze(Matrix(y,x,Slice,:)),1:TPs,ROI_sig);
            set(Line(1),'Marker','o','LineStyle','-','MarkerFaceColor','green','Color','green','LineWidth',4,'MarkerSize',10);
            set(Line(2),'Marker','o','LineStyle','-','MarkerFaceColor','red','Color','red','LineWidth',4,'MarkerSize',10);
            set(VLine,'Color','black','FontSize',20);
            axis(VLine,[1 TPs Min_D Max_D]);
            ylabel(VLine,'Signal Intensity','FontSize',24);
            xlabel(VLine,'Time Point','FontSize',24);
        else
            plot(VLine,1:TPs,squeeze(Matrix(y,x,Slice,:)),'o-','MarkerFaceColor','green','Color','green','LineWidth',4,'MarkerSize',10);
            set(VLine,'Color','black','FontSize',20);
            axis(VLine,[1 TPs Min_D Max_D]);
            ylabel(VLine,'Signal Intensity','FontSize',24);
            xlabel(VLine,'Time Point','FontSize',24);
        end
    end
    
    if flag==1
        if route(end,1)~=y | route(end,2)~=x
            hold on;
            if max(size(route(:,1)))>=2
                line(route(2:end,2),route(2:end,1),'Color','r');
            end
            route(end+1,:)=[y,x];
        end
    end
end

function WindowKeyPress(Temp,Event)
        %------------------------------Windows Contrast Change
        if Event.Character=='l'
            Contrast_Change=-1;
        elseif Event.Character=='u'
            Contrast_Change=1;
        end
        %------------------------------End

        %------------------------------DCE-MR Image Change
        if str2num(Event.Character)>=1 & str2num(Event.Character)<=9
             clf;
             Time_Point=str2num(Event.Character);
             imagesc(Matrix(:,:,Slice,Time_Point),[Contrast_Low Contrast_High]);
             zoom reset;
             set(gca,'XLim',Xlim,'YLim',Ylim);
             colormap gray;
             xlabel(['Slice #' num2str(Slice) '  ROI Slice #' num2str(ROI_Slice)],'FontSize',18);
             if str2num(Event.Character)==0
                title ('Pre-Contrast Image','FontSize',20);
             else
                title (['Post-Contrast Image ' num2str(Time_Point)],'FontSize',20);
             end
             axis square;
             colorbar;
        end
        %------------------------------End
        hold on;
        ROI=0;
        %-------------------------------------------Show ROI
        if Contrast_Change==0 & Slice==ROI_Slice & ~isempty(mask)
           [R,C]=find(mask~=0);
           ROI=scatter(get(Handle,'CurrentAxes'),C+min(route(:,2))-1,R+min(route(:,1))-1,'ro','filled');
           line([route(:,2); route(1,2)],[route(:,1); route(1,1)],'Color','r');
        end
        %-------------------------------------------End
        hold off;

end

function WindowKeyRelease(Temp,Event)
        Contrast_Change=0;

end

function MouseScrollWheel (Temp,Event)
        clf;
        if Contrast_Change==0
            Slice = Slice + Event.VerticalScrollCount;
            if Slice < 1
               Slice = 1;
            end
            if Slice > Layer
               Slice = Layer;
            end
        end
        if Contrast_Change==-1
            Contrast_Low=Contrast_Low + Event.VerticalScrollCount*Contrast_Interval;
        end
        if Contrast_Change==1
            Contrast_High=Contrast_High + Event.VerticalScrollCount*Contrast_Interval;
        end

        imagesc(Matrix(:,:,Slice,Time_Point),[Contrast_Low Contrast_High]); 
        zoom reset;
        set(gca,'XLim',Xlim,'YLim',Ylim);
        colormap gray;
        xlabel(['Slice #' num2str(Slice) '  ROI Slice #' num2str(ROI_Slice)],'FontSize',18);
        if Time_Point==0
            title ('Pre-Contrast Image','FontSize',20);
        else
            title (['Post-Contrast Image ' num2str(Time_Point)],'FontSize',20);
        end
        axis square;
        colorbar;
        hold on;
        ROI=0;
        %-------------------------------------------Show ROI
        if Slice==ROI_Slice & ~isempty(mask)
           [R,C]=find(mask~=0);
           ROI=scatter(get(Handle,'CurrentAxes'),C+min(route(:,2))-1,R+min(route(:,1))-1,'ro','filled');
           line([route(:,2); route(1,2)],[route(:,1); route(1,1)],'Color','r');
        end
        %-------------------------------------------End
        hold off;

end

function b_mask=boundary(route,limt)
        dist=sqrt(diff(route(:,1)).^2+diff(route(:,2)).^2);
        [X,Y]=meshgrid(limt(1):limt(2),limt(3):limt(4));
        b_mask=zeros(size(X));
        for i=1:max(size(dist))
            if dist(i)<=1.415
                continue;
            end
            p1=route(i,:);
            p2=route(i+1,:);
            dist_mask=abs((p2(2)-p1(2)).*(p1(1)-Y)-(p1(2)-X).*(p2(1)-p1(1)))./sqrt((p2(2)-p1(2))^2+(p2(1)-p1(1))^2);
            b_mask(dist_mask<=0.7075 & X>=min([p1(2) p2(2)]) & X<=max([p1(2) p2(2)]) & Y>=min([p1(1) p2(1)]) & Y<=max([p1(1) p2(1)]))=1;
        end
        for i=1:max(size(dist))+1
            b_mask(route(i,1)-limt(3)+1,route(i,2)-limt(1)+1)=1;
        end
end

end