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



function Masks=Mmask(Matrix,Init_Slice,Contrast_Interval)

% Mannual mask delineation for 3D image
%--------------------------------------------Initializtion
%-----------------------------Pre-process for matrix
[Row,Column,Layer]= size(Matrix);
Matrix=double(Matrix);
Matrix(isnan(Matrix))=0;
Matrix(isinf(Matrix))=0;
Max_D=max(max(max(Matrix)));
Min_D=min(min(min(Matrix)));
route=[0,0];
ROI=0;
Masks=zeros(size(Matrix));
Line=[0 0];
mask=[];
Slice=Init_Slice;
%-----------------------------End

%-----------------------------Windows Contrast Change
Contrast_Low=Min_D;
Contrast_High=Max_D;
Contrast_Change=0;
%-----------------------------End

%-----------------------------Window 1
Handle=figure;
set(Handle,'KeyReleaseFcn',@WindowKeyRelease,...
           'KeyPressFcn',@WindowKeyPress,...
           'WindowScrollWheelFcn',@MouseScrollWheel,...
           'WindowButtonDownFcn',@MouseClick,...
           'WindowButtonMotionFcn',{@MouseMove,flag});
set(Handle,'Pointer','crosshair');
imagesc(Matrix(:,:,Slice),[Contrast_Low Contrast_High]);
colormap gray;
%axis square;
colorbar;
xlabel(['Slice #' num2str(Slice)],'FontSize',18);
%------------------------------End
%--------------------------------------------End
function MouseClick(Temp,Event)
    flag=1;
    if ROI~=0
        delete(ROI);
        delete(Line(2));
    end
    route=[0,0];
    set(gcf,'WindowButtonUpFcn',{@MouseUp});
    set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});
end

function MouseUp(Temp,Event)
    %------------------------------------------Prevent Single Click
    if max(size(route(:,1)))==1
        ROI=0;
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
        flag=0;
        set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});
        return;
    end
    %------------------------------------------End

    line([route(:,2); route(1,2)],[route(:,1); route(1,1)],'Color','r');
    b_mask=boundary([route ; route(1,:)],[min(route(:,2)) max(route(:,2)) min(route(:,1)) max(route(:,1))]);
    mask=imfill(b_mask,'holes');
    flag=0;
    set(gcf,'WindowButtonMotionFcn',{@MouseMove,flag});

end

function MouseMove(Temp,Event,flag)
    point=get(gca,'currentpoint');
    x=round(point(1));
    y=round(point(3));
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
        elseif Event.Character=='s'
            [R,C]=find(mask~=0);
            for i=1:max(size(R))
                Masks(R(i)+min(route(:,1))-1,C(i)+min(route(:,2))-1,Slice)=1;
            end
        end
        %------------------------------End
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
        imagesc(Matrix(:,:,Slice),[Contrast_Low Contrast_High]); 
        colormap gray;
        %axis square;
        colorbar;
        xlabel(['Slice #' num2str(Slice)],'FontSize',18);
        hold on;
        ROI=0;
        %-------------------------------------------Show ROI
        if ~isempty(mask)
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

input('Press any key to continue');

end