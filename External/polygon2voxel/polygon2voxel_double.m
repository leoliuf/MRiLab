function Volume=polygon2voxel_double(FacesA,FacesB,FacesC,VerticesX,VerticesY,VerticesZ,VolumeSize,Wrap)
Vertices=[VerticesX(:) VerticesY(:) VerticesZ(:)]-1;

% List with all vertices coordinates of a face
FaceVertices=[Vertices(FacesA,:) Vertices(FacesB,:) Vertices(FacesC,:)];
Volume=false(VolumeSize);
Volume=DrawSplitFaces(FaceVertices,Volume,Wrap);


function Volume=DrawSplitFaces(FaceVertices,Volume,Wrap)
VolumeSize=size(Volume);
% Calculate squared edge distances
dist1=(FaceVertices(:,1)-FaceVertices(:,4)).*(FaceVertices(:,1)-FaceVertices(:,4))+(FaceVertices(:,2)-FaceVertices(:,5)).*(FaceVertices(:,2)-FaceVertices(:,5))+(FaceVertices(:,3)-FaceVertices(:,6)).*(FaceVertices(:,3)-FaceVertices(:,6));
dist2=(FaceVertices(:,7)-FaceVertices(:,4)).*(FaceVertices(:,7)-FaceVertices(:,4))+(FaceVertices(:,8)-FaceVertices(:,5)).*(FaceVertices(:,8)-FaceVertices(:,5))+(FaceVertices(:,9)-FaceVertices(:,6)).*(FaceVertices(:,9)-FaceVertices(:,6));
dist3=(FaceVertices(:,1)-FaceVertices(:,7)).*(FaceVertices(:,1)-FaceVertices(:,7))+(FaceVertices(:,2)-FaceVertices(:,8)).*(FaceVertices(:,2)-FaceVertices(:,8))+(FaceVertices(:,3)-FaceVertices(:,9)).*(FaceVertices(:,3)-FaceVertices(:,9));
  
% Calculate mFaceVertices(:,1) distance
maxdist=max([dist1(:) dist2(:),dist3(:)],[],2);

% Draw triangle if distance <=0.5 pixel
check=maxdist>0.5;

FVR=FaceVertices(~check,:);
% Select Vertices which must be split
FaceVertices=FaceVertices(check,:);
if(~isempty(FaceVertices))
    dist1=dist1(check); 
    dist2=dist2(check); 
    dist3=dist3(check);

    DX=(FaceVertices(:,1)+FaceVertices(:,4))/2; DY=(FaceVertices(:,2)+FaceVertices(:,5))/2; DZ=(FaceVertices(:,3)+FaceVertices(:,6))/2;
    FA1=[DX,DY,DZ,FaceVertices(:,4),FaceVertices(:,5),FaceVertices(:,6),FaceVertices(:,7),FaceVertices(:,8),FaceVertices(:,9)];
    FB1=[FaceVertices(:,1),FaceVertices(:,2),FaceVertices(:,3),DX,DY,DZ,FaceVertices(:,7),FaceVertices(:,8),FaceVertices(:,9)];

    DX=(FaceVertices(:,1)+FaceVertices(:,7))/2; DY=(FaceVertices(:,2)+FaceVertices(:,8))/2; DZ=(FaceVertices(:,3)+FaceVertices(:,9))/2;
    FA2=[DX,DY,DZ,FaceVertices(:,4),FaceVertices(:,5),FaceVertices(:,6),FaceVertices(:,7),FaceVertices(:,8),FaceVertices(:,9)];
    FB2=[FaceVertices(:,1),FaceVertices(:,2),FaceVertices(:,3),FaceVertices(:,4),FaceVertices(:,5),FaceVertices(:,6),DX,DY,DZ];

    DX=(FaceVertices(:,7)+FaceVertices(:,4))/2; DY=(FaceVertices(:,8)+FaceVertices(:,5))/2; DZ=(FaceVertices(:,9)+FaceVertices(:,6))/2;
    FA3=[FaceVertices(:,1),FaceVertices(:,2),FaceVertices(:,3),DX,DY,DZ,FaceVertices(:,7),FaceVertices(:,8),FaceVertices(:,9)];
    FB3=[FaceVertices(:,1),FaceVertices(:,2),FaceVertices(:,3),FaceVertices(:,4),FaceVertices(:,5),FaceVertices(:,6),DX,DY,DZ];

    DX=(FaceVertices(:,1)+FaceVertices(:,7))/2; DY=(FaceVertices(:,2)+FaceVertices(:,8))/2; DZ=(FaceVertices(:,3)+FaceVertices(:,9))/2;
    FA4=[DX,DY,DZ,FaceVertices(:,4),FaceVertices(:,5),FaceVertices(:,6),FaceVertices(:,7),FaceVertices(:,8),FaceVertices(:,9)];
    FB4=[FaceVertices(:,1),FaceVertices(:,2),FaceVertices(:,3),FaceVertices(:,4),FaceVertices(:,5),FaceVertices(:,6),DX,DY,DZ];

    dist12=dist1>dist2;
    dist12n=~dist12;
    FA1(dist12n,:)=FA3(dist12n,:);
    FB1(dist12n,:)=FB3(dist12n,:);
    FA2(dist12n,:)=FA4(dist12n,:);
    FB2(dist12n,:)=FB4(dist12n,:);
    dist1(dist12n,:)=dist2(dist12n,:);

    dist13=dist1>dist3;
    dist13n=~dist13;
    FA1(dist13n,:)=FA2(dist13n,:);
    FB1(dist13n,:)=FB2(dist13n,:);

    FaceVertices=[FA1;FB1];

    % Split / Draw Vertices
    Volume=DrawSplitFaces(FaceVertices,Volume,Wrap);
end

% Draw remaining faces
FaceVertices=FVR;

if(Wrap==0)
    % Calculate 1D volume indices
    indexA=mindex3(floor(FaceVertices(:,1)+0.5),floor(FaceVertices(:,2)+0.5), floor(FaceVertices(:,3)+0.5), VolumeSize(1), VolumeSize(2), VolumeSize(3), Wrap);
    indexB=mindex3(floor(FaceVertices(:,4)+0.5),floor(FaceVertices(:,5)+0.5), floor(FaceVertices(:,6)+0.5), VolumeSize(1), VolumeSize(2), VolumeSize(3), Wrap);
    indexC=mindex3(floor(FaceVertices(:,7)+0.5),floor(FaceVertices(:,8)+0.5), floor(FaceVertices(:,9)+0.5), VolumeSize(1), VolumeSize(2), VolumeSize(3), Wrap);
    
    % Remove outside vertices
    checkA=(FaceVertices(:,1)<0)|(FaceVertices(:,2)<0)|(FaceVertices(:,3)<0)|(FaceVertices(:,1)>(VolumeSize(1)-1))|(FaceVertices(:,2)>(VolumeSize(2)-1))|(FaceVertices(:,3)>(VolumeSize(3)-1));
    checkB=(FaceVertices(:,4)<0)|(FaceVertices(:,5)<0)|(FaceVertices(:,6)<0)|(FaceVertices(:,4)>(VolumeSize(1)-1))|(FaceVertices(:,5)>(VolumeSize(2)-1))|(FaceVertices(:,6)>(VolumeSize(3)-1));
    checkC=(FaceVertices(:,7)<0)|(FaceVertices(:,8)<0)|(FaceVertices(:,9)<0)|(FaceVertices(:,7)>(VolumeSize(1)-1))|(FaceVertices(:,8)>(VolumeSize(2)-1))|(FaceVertices(:,9)>(VolumeSize(3)-1));
    indexA(checkA)=[];
    indexB(checkB)=[];
    indexC(checkC)=[];
 
    % Draw the vertices
    Volume(indexA)=true;
    Volume(indexB)=true;
    Volume(indexC)=true;
else
     Volume(mindex3(floor(FaceVertices(:,1)+0.5),floor(FaceVertices(:,2)+0.5), floor(FaceVertices(:,3)+0.5), VolumeSize(1), VolumeSize(2), VolumeSize(3), Wrap))=1;
     Volume(mindex3(floor(FaceVertices(:,4)+0.5),floor(FaceVertices(:,5)+0.5), floor(FaceVertices(:,6)+0.5), VolumeSize(1), VolumeSize(2), VolumeSize(3), Wrap))=1;
     Volume(mindex3(floor(FaceVertices(:,7)+0.5),floor(FaceVertices(:,8)+0.5), floor(FaceVertices(:,9)+0.5), VolumeSize(1), VolumeSize(2), VolumeSize(3), Wrap))=1;
end
    
function index=mindex3(x, y, z, sizx, sizy, sizz, Wrap) 
if(Wrap==1)
    % Positive modules 
    x=mod(x,sizx);
    y=mod(y,sizy);
    z=mod(z,sizz);
elseif(Wrap>1)
    % Clamp 
    x=max(x,0); x=min(x,sizx-1);
    y=max(y,0); y=min(y,sizy-1);
    z=max(z,0); z=min(z,sizz-1);
end
index=z*sizx*sizy+y*sizx+x;
% matlab
index=index+1;

    