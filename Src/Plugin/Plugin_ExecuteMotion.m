
function Plugin_ExecuteMotion

global VObj
global VMot
global VVar
global VMag
global VCtl
% global Traj

%% Locate motion track, do nothing if no motion track
if length(VMot.t) == 1
    return;
end

time = double(VVar.t)+ (double(VVar.TRCount)-1) * VCtl.TR;
mot_t= double(VMot.t);
[C,I] = min(abs(mot_t-time)); % find time point in the motion track

%% Execute translation for object
if ~isempty(VMot.Disp)
    if VVar.ObjMotInd == VMot.ind(I)
        ObjTraj = VVar.ObjLoc - VVar.ObjTurnLoc;
        Displacement  = VMot.Disp(:,I) - ObjTraj;
    else
        Displacement  = VMot.Disp(:,I);
        VVar.ObjTurnLoc = VVar.ObjLoc ;
    end
    VVar.ObjLoc = VVar.ObjLoc + Displacement;
    step= round(Displacement./[VObj.XDimRes; VObj.YDimRes; VObj.ZDimRes]);
    
    if sum(step~=0)
        
        VObj.Mz=circshift(VObj.Mz,[step(2), step(1), step(3)]);
        VObj.My=circshift(VObj.My,[step(2), step(1), step(3)]);
        VObj.Mx=circshift(VObj.Mx,[step(2), step(1), step(3)]);
        VObj.Rho=circshift(VObj.Rho,[step(2), step(1), step(3)]);
        VObj.T1=circshift(VObj.T1,[step(2), step(1), step(3)]);
        VObj.T2=circshift(VObj.T2,[step(2), step(1), step(3)]);
        VMag.dWRnd=circshift(VMag.dWRnd,[step(2), step(1), step(3)]);
        
%         disp(['Phantom Motion: [ ' num2str(step') ' ]']);
        %             if isempty(Traj)
        %                 Traj=step';
        %             else
        %                 Traj(end+1,:)=step';
        %             end
        %
%                 figure; imagesc(VObj.Rho(:,:,1));
%         VVar.ObjLoc
    end
    
end

%% Execute rotation for object
if ~isempty(VMot.Ang)
    RotationAngle = VMot.Ang(1,I)-VVar.ObjAng;
    VVar.ObjAng = VMot.Ang(1,I);
    
    if RotationAngle~=0
        axis = VMot.Axis(:,I);
        [T, R]=rotate3DT(axis, RotationAngle);
        
        VObj.Mz =rotate3D(VObj.Mz, T, R);
        VObj.My =rotate3D(VObj.My, T, R);
        VObj.Mx =rotate3D(VObj.Mx, T, R);
        VObj.Rho =rotate3D(VObj.Rho, T, R);
        VObj.T1 =rotate3D(VObj.T1, T, R);
        VObj.T2 =rotate3D(VObj.T2, T, R);
        VMag.dWRnd =rotate3D(VMag.dWRnd, T, R);
        
        VObj.Mz(VObj.Mz < 0) = 0;
        VObj.My(VObj.My < 0) = 0;
        VObj.Mx(VObj.Mx < 0) = 0;
        VObj.Rho(VObj.Rho < 0) = 0;
        VObj.T1(VObj.T1 < 0) = 0;
        VObj.T2(VObj.T2 < 0) = 0;
        VMag.dWRnd(VMag.dWRnd < 0) = 0;

        VObj.Mz(VObj.Mz > VObj.MaxMz) = VObj.MaxMz;
        VObj.My(VObj.My > VObj.MaxMy) = VObj.MaxMy;
        VObj.Mx(VObj.Mx > VObj.MaxMx) = VObj.MaxMx;
        VObj.Rho(VObj.Rho > VObj.MaxRho) = VObj.MaxRho;
        VObj.T1(VObj.T1 > VObj.MaxT1) = VObj.MaxT1;
        VObj.T2(VObj.T2 > VObj.MaxT2) = VObj.MaxT2;
        VMag.dWRnd(VMag.dWRnd > VObj.MaxdWRnd) = VObj.MaxdWRnd;
        
        
%         VVar.ObjLoc
%                 figure; imagesc(VObj.Rho(:,:,1));
    end
    
end

VVar.ObjMotInd = VMot.ind(I);

end