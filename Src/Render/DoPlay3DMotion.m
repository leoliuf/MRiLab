
function DoPlay3DMotion(handles)

global VMot;
global VObj;
%--------Display Parameters
fieldname=fieldnames(handles.Attrh2);
for i=1:length(fieldname)/2
    try 
        eval(['SD.' fieldname{i*2} '=' get(handles.Attrh2.(fieldname{i*2}),'String') ';']);
    catch me
        TAttr=get(handles.Attrh2.(fieldname{i*2}),'String');
        eval(['SD.' fieldname{i*2} '=''' TAttr{get(handles.Attrh2.(fieldname{i*2}),'Value')}  ''';']);
    end
end
handles.SD=SD;
%--------End

%--------Open VRML & Initialize
vrobject = vrworld('Mot3DModel.wrl','new');
open(vrobject);
fig=vrfigure(vrobject);
viewpoint = vrnode(vrobject, SD.ViewPoint); % Set default viewpoint
viewpoint.set_bind = 1;
viewpoint.position = viewpoint.position * SD.ZoomOut; % Set default viewpoint distance
object=vrnode(vrobject, 'Sphere');
object.scale = object.scale .*[VObj.XDim*VObj.XDimRes,VObj.YDim*VObj.YDimRes,VObj.ZDim*VObj.ZDimRes];
%--------End

for j = 1:SD.Repeat
    
    %--------Initialize variables for tracking motion path
    ObjLoc=[0;0;0];
    ObjTurnLoc=[0;0;0];
    ObjMotInd=0;
    %--------End
    
    for i=2:SD.Sample:length(VMot.t)
        
        if ~isempty(VMot.Disp)
            Disp=VMot.Disp(:,i);
            Disp(2)=-Disp(2); % Matlab image coordinate is oppsite againt VMRL coordinate in Y direction
            if ObjMotInd == VMot.ind(i)
                ObjTraj = ObjLoc - ObjTurnLoc;
                Displacement  = Disp - ObjTraj;
            else
                Displacement  = Disp;
                ObjTurnLoc = ObjLoc;
            end
            ObjLoc = ObjLoc + Displacement;
        end
        
        %% time interval
        pause((VMot.t(i)-VMot.t(i-1)));
        
        %% translate
        if ~isempty(VMot.Disp)
            object.translation=Disp' + ObjTurnLoc'; % Matlab image coordinate is oppsite againt VMRL coordinate in Y direction
        end
        
        %% rotate
        if ~isempty(VMot.Ang)
            object.rotation=[VMot.Axis(:,i)', -VMot.Ang(:,i)]; % Matlab image coordinate is oppsite againt VMRL coordinate in Y direction
        end
        
        vrdrawnow;
        ObjMotInd = VMot.ind(i);
    end
end



end