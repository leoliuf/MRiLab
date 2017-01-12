
function DoPreScan(Simuh)

global VObj;
global VCtl;
global VMag;
global VCoi;
global VMot;
global VVar;
global VSig;

global VMmg;
global VMco;
global VMgd;
%% VCtl Virtual Timing+ Parameters

if isfield(VCtl,'RefSNR')
    RefSNR=VCtl.RefSNR;
end

VCtl=[]; % update VCtl

if exist('RefSNR','var')
    VCtl.RefSNR=RefSNR;
end

fieldname=fieldnames(Simuh.Attrh1);
for i=1:length(fieldname)/2
    try
        switch get(Simuh.Attrh1.(fieldname{i*2}),'Style')
            case 'edit'
                eval(['VCtl.' fieldname{i*2} '=[' get(Simuh.Attrh1.(fieldname{i*2}),'String') '];']);
            case 'popupmenu'
                TAttr=get(Simuh.Attrh1.(fieldname{i*2}),'String');
                eval(['VCtl.' fieldname{i*2} '=''' TAttr{get(Simuh.Attrh1.(fieldname{i*2}),'Value')}  ''';']);
        end
    catch me
    end
end

% FOV & resolution
if isfield(VCtl,'R_SpokeNum') % 2D radial
    VCtl.RFreq=VCtl.FOVFreq/VCtl.ResFreq;
    VCtl.FOVPhase=VCtl.FOVFreq; % square pixel
    VCtl.ResPhase=VCtl.ResFreq;
    VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
    VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
    VCtl.RSlice=VCtl.SliceThick;
    VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
    if strcmp(VCtl.R_AngPattern,'Linear')
        VCtl.TrajType='radial';
    else
        VCtl.TrajType='goldenangle';
    end
    VCtl.FirstPhNum = VCtl.R_SpokeNum;
    VCtl.SecondPhNum = VCtl.SliceNum;
    set(Simuh.Attrh1.SliceNum,'String',num2str(VCtl.SliceNum));
elseif isfield(VCtl,'S_ShotNum') % 2D spiral
    VCtl.RFreq=VCtl.FOVFreq/VCtl.ResFreq;
    VCtl.FOVPhase=VCtl.FOVFreq; % square pixel
    VCtl.ResPhase=VCtl.ResFreq;
    VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
    VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
    VCtl.RSlice=VCtl.SliceThick;
    VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
    VCtl.TrajType='spiral';
    VCtl.FirstPhNum = VCtl.S_ShotNum;
    VCtl.SecondPhNum = VCtl.SliceNum;
    set(Simuh.Attrh1.SliceNum,'String',num2str(VCtl.SliceNum));
elseif isfield(VCtl,'EPI_ShotNum') % EPI
    VCtl.ResFreq = VCtl.ResFreq + ~mod(VCtl.ResFreq,2); % guarantee odd number of Kx sample points for sampling echo peak when Kx = 0
    VCtl.RFreq=VCtl.FOVFreq/(VCtl.ResFreq - 1);
    VCtl.EPI_ETL = VCtl.EPI_ETL - mod(VCtl.EPI_ETL,2); % guarantee even number of Ky sample points for Ky = 0
    VCtl.ResPhase = VCtl.EPI_ETL*VCtl.EPI_ShotNum;
    VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
    VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
    VCtl.RSlice=VCtl.SliceThick;
    VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
    VCtl.TrajType='epi';
    VCtl.FirstPhNum = VCtl.EPI_ShotNum;
    VCtl.SecondPhNum = VCtl.SliceNum;
    set(Simuh.Attrh1.ResFreq,'String',num2str(VCtl.ResFreq - 1));
    set(Simuh.Attrh1.SliceNum,'String',num2str(VCtl.SliceNum));
    set(Simuh.Attrh1.EPI_ETL,'String',num2str(VCtl.EPI_ETL));
elseif isfield(VCtl, 'FSE_ShotNum') % FSE
    VCtl.ResFreq = VCtl.ResFreq + ~mod(VCtl.ResFreq,2); % guarantee odd number of Kx sample points for sampling echo peak when Kx = 0
    VCtl.RFreq=VCtl.FOVFreq/(VCtl.ResFreq - 1);
    VCtl.FSE_ETL = VCtl.FSE_ETL - mod(VCtl.FSE_ETL,2); % guarantee even number of Ky sample points for Ky = 0
    VCtl.ResPhase = VCtl.FSE_ETL*VCtl.FSE_ShotNum;
    VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
    VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
    VCtl.RSlice=VCtl.SliceThick;
    VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
    VCtl.TrajType='cartesian';
    VCtl.FirstPhNum = VCtl.FSE_ShotNum;
    VCtl.SecondPhNum = VCtl.SliceNum;
    set(Simuh.Attrh1.ResFreq,'String',num2str(VCtl.ResFreq - 1));
    set(Simuh.Attrh1.SliceNum,'String',num2str(VCtl.SliceNum));
    set(Simuh.Attrh1.FSE_ETL,'String',num2str(VCtl.FSE_ETL));
else  % Cartesian
    VCtl.ResFreq = VCtl.ResFreq + ~mod(VCtl.ResFreq,2); % guarantee odd number of Kx sample points for sampling echo peak when Kx = 0
    VCtl.RFreq=VCtl.FOVFreq/(VCtl.ResFreq - 1);
    VCtl.ResPhase = VCtl.ResPhase - mod(VCtl.ResPhase,2); % guarantee even number of Ky sample points for Ky = 0
    VCtl.RPhase=VCtl.FOVPhase/VCtl.ResPhase;
    VCtl.SliceNum = max(1,VCtl.SliceNum - mod(VCtl.SliceNum,2)); % guarantee even number of Kz sample points for Kz = 0
    VCtl.RSlice=VCtl.SliceThick;
    VCtl.FOVSlice=VCtl.SliceNum*VCtl.SliceThick;
    VCtl.TrajType='cartesian';
    VCtl.FirstPhNum = VCtl.ResPhase;
    VCtl.SecondPhNum = VCtl.SliceNum;
    set(Simuh.Attrh1.ResFreq,'String',num2str(VCtl.ResFreq - 1));
    set(Simuh.Attrh1.ResPhase,'String',num2str(VCtl.ResPhase));
    set(Simuh.Attrh1.SliceNum,'String',num2str(VCtl.SliceNum));
end

% Others
VCtl.FlipAng=VCtl.FlipAng; % degree
VCtl.TEAnchorTime=0;
VCtl.ISO=Simuh.ISO;
VCtl.CS=VObj.ChemShift*VCtl.B0;
VCtl.h.TimeWait_text=Simuh.TimeWait_text;
% VCtl.h.TimeBar_text=Simuh.TimeBar_text;
VCtl.h.TimeBar_axes=Simuh.TimeBar_axes;
VCtl.h.SimuPanel_figure=Simuh.SimuPanel_figure;
VObj.SpinNum=VCtl.SpinPerVoxel; % Controllable Spin number in each voxel
                                % Transfer VCtl to VObj, should have better
                                % way to do this ??

if isfield(VCtl,'DP_Flag') % calculate total number of TR
    if strcmp(VCtl.DP_Flag,'on')
        VCtl.TRNum=VCtl.FirstPhNum*VCtl.SecondPhNum+VCtl.DP_Num; % regular TR + dummy pulse
    else
        VCtl.TRNum=VCtl.FirstPhNum*VCtl.SecondPhNum;
    end
else
    VCtl.TRNum=VCtl.FirstPhNum*VCtl.SecondPhNum;
end

switch VCtl.ScanPlane
    case 'Axial'
        if strcmp(VCtl.FreqDir,'S/I')
            set(Simuh.Attrh1.FreqDir,'Value',1);
            VCtl.FreqDir='A/P';
        end
    case 'Sagittal'
        if strcmp(VCtl.FreqDir,'L/R')
            set(Simuh.Attrh1.FreqDir,'Value',3);
            VCtl.FreqDir='S/I';
        end
    case 'Coronal'
        if strcmp(VCtl.FreqDir,'A/P')
            set(Simuh.Attrh1.FreqDir,'Value',2);
            VCtl.FreqDir='L/R';
        end
end

DoSNRCalc(Simuh); % Calculate SNR
DoMultiEchoChk; % Check for multi echo setting

%% VMag Virtual Magnetic Field
Mxdims=size(VObj.Rho);
if numel(Mxdims)==2
    if Mxdims(1)==1 | Mxdims(2)==1
        Mxdims(1)=1;
        Mxdims(2)=1;
        Mxdims(3)=1;
    end
end
VMag=struct(                                      ...
           'FRange',    ones([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
           'dB0',       zeros([Mxdims(1), Mxdims(2), Mxdims(3)]),    ...
           'dWRnd',     zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]), ...
           'Gzgrid',    zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
           'Gygrid',    zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
           'Gxgrid',    zeros([Mxdims(1), Mxdims(2), Mxdims(3)]) ...
          );

% Gradient Grid             
if isfield(Simuh,'GradXMLFile')
    [VMgd.xgrid,VMgd.ygrid,VMgd.zgrid]=meshgrid((-VCtl.ISO(1)+1)*VObj.XDimRes:VObj.XDimRes:(VObj.XDim-VCtl.ISO(1))*VObj.XDimRes,...
                                                (-VCtl.ISO(2)+1)*VObj.YDimRes:VObj.YDimRes:(VObj.YDim-VCtl.ISO(2))*VObj.YDimRes,...
                                                (-VCtl.ISO(3)+1)*VObj.ZDimRes:VObj.ZDimRes:(VObj.ZDim-VCtl.ISO(3))*VObj.ZDimRes); 
    
    [pathstr,name,ext]=fileparts(Simuh.GradXMLFile);
    eval(['[GxR,GyPE,GzSS]=' name ';']);
    
    % Calculate G*grid based on gradient profile, gradient integral
    if isempty(find(GxR ~=0, 1))
        Gxgrid = VMgd.xgrid;
    else
        TmpGxR=GxR(:,:,:,1);
        TmpGxR(VMgd.xgrid<=0) = 0;
        Gxgrid = cumsum(TmpGxR,2) .* VObj.XDimRes;
        TmpGxR=GxR(:,:,:,1);
        TmpGxR(VMgd.xgrid>=0) = 0;
        Gxgrid = Gxgrid + flipdim(cumsum(flipdim(-TmpGxR,2),2),2) .* VObj.XDimRes;
        
        TmpGxR=GxR(:,:,:,2);
        TmpGxR(VMgd.ygrid<=0) = 0;
        Gxgrid = Gxgrid + cumsum(TmpGxR,1).* VObj.YDimRes;
        TmpGxR=GxR(:,:,:,2);
        TmpGxR(VMgd.ygrid>=0) = 0;
        Gxgrid = Gxgrid + flipdim(cumsum(flipdim(-TmpGxR,1),1),1) .* VObj.YDimRes;
        
        TmpGxR=GxR(:,:,:,3);
        TmpGxR(VMgd.zgrid<=0) = 0;
        Gxgrid = Gxgrid + cumsum(TmpGxR,3) .* VObj.ZDimRes;
        TmpGxR=GxR(:,:,:,3);
        TmpGxR(VMgd.zgrid>=0) = 0;
        Gxgrid = Gxgrid + flipdim(cumsum(flipdim(-TmpGxR,3),3),3) .* VObj.ZDimRes;
        
    end
    
    if isempty(find(GyPE ~=0, 1))
        Gygrid = VMgd.ygrid;
        
    else
        TmpGyPE=GyPE(:,:,:,1);
        TmpGyPE(VMgd.xgrid<=0) = 0;
        Gygrid = cumsum(TmpGyPE,2) .* VObj.XDimRes;
        TmpGyPE=GyPE(:,:,:,1);
        TmpGyPE(VMgd.xgrid>=0) = 0;
        Gygrid = Gygrid + flipdim(cumsum(flipdim(-TmpGyPE,2),2),2) .* VObj.XDimRes;
        
        TmpGyPE=GyPE(:,:,:,2);
        TmpGyPE(VMgd.ygrid<=0) = 0;
        Gygrid = Gygrid + cumsum(TmpGyPE,1) .* VObj.YDimRes;
        TmpGyPE=GyPE(:,:,:,2);
        TmpGyPE(VMgd.ygrid>=0) = 0;
        Gygrid = Gygrid + flipdim(cumsum(flipdim(-TmpGyPE,1),1),1) .* VObj.YDimRes;
        
        TmpGyPE=GyPE(:,:,:,3);
        TmpGyPE(VMgd.zgrid<=0) = 0;
        Gygrid = Gygrid + cumsum(TmpGyPE,3) .* VObj.ZDimRes;
        TmpGyPE=GyPE(:,:,:,3);
        TmpGyPE(VMgd.zgrid>=0) = 0;
        Gygrid = Gygrid + flipdim(cumsum(flipdim(-TmpGyPE,3),3),3) .* VObj.ZDimRes;
        
    end
    
    if isempty(find(GzSS ~=0, 1))
        Gzgrid = VMgd.zgrid;
        
    else
        TmpGzSS=GzSS(:,:,:,1);
        TmpGzSS(VMgd.xgrid<=0) = 0;
        Gzgrid = cumsum(TmpGzSS,2) .* VObj.XDimRes;
        TmpGzSS=GzSS(:,:,:,1);
        TmpGzSS(VMgd.xgrid>=0) = 0;
        Gzgrid = Gzgrid + flipdim(cumsum(flipdim(-TmpGzSS,2),2),2) .* VObj.XDimRes;
        
        TmpGzSS=GzSS(:,:,:,2);
        TmpGzSS(VMgd.ygrid<=0) = 0;
        Gzgrid = Gzgrid + cumsum(TmpGzSS,1) .* VObj.YDimRes;
        TmpGzSS=GzSS(:,:,:,2);
        TmpGzSS(VMgd.ygrid>=0) = 0;
        Gzgrid = Gzgrid + flipdim(cumsum(flipdim(-TmpGzSS,1),1),1) .* VObj.YDimRes;
        
        TmpGzSS=GzSS(:,:,:,3);
        TmpGzSS(VMgd.zgrid<=0) = 0;
        Gzgrid = Gzgrid + cumsum(TmpGzSS,3) .* VObj.ZDimRes;
        TmpGzSS=GzSS(:,:,:,3);
        TmpGzSS(VMgd.zgrid>=0) = 0;
        Gzgrid = Gzgrid + flipdim(cumsum(flipdim(-TmpGzSS,3),3),3) .* VObj.ZDimRes;
        
    end
    
else
    [Gxgrid,Gygrid,Gzgrid]=meshgrid((-VCtl.ISO(1)+1)*VObj.XDimRes:VObj.XDimRes:(VObj.XDim-VCtl.ISO(1))*VObj.XDimRes,...
                                    (-VCtl.ISO(2)+1)*VObj.YDimRes:VObj.YDimRes:(VObj.YDim-VCtl.ISO(2))*VObj.YDimRes,...
                                    (-VCtl.ISO(3)+1)*VObj.ZDimRes:VObj.ZDimRes:(VObj.ZDim-VCtl.ISO(3))*VObj.ZDimRes); 
end
                            
AP1=max(2,str2num(get(Simuh.AP1_text,'string')));
AP2=min(Mxdims(1),str2num(get(Simuh.AP2_text,'string')));
SI1=max(2,str2num(get(Simuh.SI1_text,'string')));
SI2=min(Mxdims(3),str2num(get(Simuh.SI2_text,'string')));
LR1=max(2,str2num(get(Simuh.LR1_text,'string')));
LR2=min(Mxdims(2),str2num(get(Simuh.LR2_text,'string')));
switch VCtl.ScanPlane
    case 'Axial'
        if  strcmp(VCtl.FreqDir,'A/P')
            VMag.Gxgrid=Gygrid;
            VMag.Gygrid=Gxgrid;
            VMag.Gzgrid=Gzgrid;
            if strcmp(VCtl.NoFreqAlias,'on')
                VMag.FRange(1:AP1-1,:,:)=0;
                VMag.FRange(AP2:end,:,:)=0;
            end
            if strcmp(VCtl.NoPhaseAlias,'on')
                VMag.FRange(:,1:LR1-1,:)=0;
                VMag.FRange(:,LR2:end,:)=0;
            end
        else
            VMag.Gxgrid=Gxgrid;
            VMag.Gygrid=Gygrid;
            VMag.Gzgrid=Gzgrid;
            if strcmp(VCtl.NoFreqAlias,'on')
                VMag.FRange(:,1:LR1-1,:)=0;
                VMag.FRange(:,LR2:end,:)=0;
            end
            if strcmp(VCtl.NoPhaseAlias,'on')
                VMag.FRange(1:AP1-1,:,:)=0;
                VMag.FRange(AP2:end,:,:)=0;
            end
        end
        if isfield(VCtl,'NoSliceAlias')
            if strcmp(VCtl.NoSliceAlias,'on')
                VMag.FRange(:,:,1:SI1-1)=0;
                VMag.FRange(:,:,SI2:end)=0;
            end
        end

    case 'Sagittal'
        if  strcmp(VCtl.FreqDir,'S/I')
            VMag.Gxgrid=Gzgrid;
            VMag.Gygrid=Gygrid;
            VMag.Gzgrid=Gxgrid;
            if strcmp(VCtl.NoFreqAlias,'on')
                VMag.FRange(:,:,1:SI1-1)=0;
                VMag.FRange(:,:,SI2:end)=0;
            end
            if strcmp(VCtl.NoPhaseAlias,'on')
                VMag.FRange(1:AP1-1,:,:)=0;
                VMag.FRange(AP2:end,:,:)=0;
            end
        else
            VMag.Gxgrid=Gygrid;
            VMag.Gygrid=Gzgrid;
            VMag.Gzgrid=Gxgrid;
            if strcmp(VCtl.NoFreqAlias,'on')
                VMag.FRange(1:AP1-1,:,:)=0;
                VMag.FRange(AP2:end,:,:)=0;
            end
            if strcmp(VCtl.NoPhaseAlias,'on')
                VMag.FRange(:,:,1:SI1-1)=0;
                VMag.FRange(:,:,SI2:end)=0;
            end

        end
        if isfield(VCtl,'NoSliceAlias')
            if strcmp(VCtl.NoSliceAlias,'on')
                VMag.FRange(:,1:LR1-1,:)=0;
                VMag.FRange(:,LR2:end,:)=0;
            end
        end
    case 'Coronal'
        if  strcmp(VCtl.FreqDir,'L/R')
            VMag.Gxgrid=Gxgrid;
            VMag.Gygrid=Gzgrid;
            VMag.Gzgrid=Gygrid;
            if strcmp(VCtl.NoFreqAlias,'on')
                VMag.FRange(:,1:LR1-1,:)=0;
                VMag.FRange(:,LR2:end,:)=0;
            end
            if strcmp(VCtl.NoPhaseAlias,'on')
                VMag.FRange(:,:,1:SI1-1)=0;
                VMag.FRange(:,:,SI2:end)=0;
            end
        else
            VMag.Gxgrid=Gzgrid;
            VMag.Gygrid=Gxgrid;
            VMag.Gzgrid=Gygrid;
            if strcmp(VCtl.NoFreqAlias,'on')
                VMag.FRange(:,:,1:SI1-1)=0;
                VMag.FRange(:,:,SI2:end)=0;
            end
            if strcmp(VCtl.NoPhaseAlias,'on')
                VMag.FRange(:,1:LR1-1,:)=0;
                VMag.FRange(:,LR2:end,:)=0;
            end
        end
        if isfield(VCtl,'NoSliceAlias')
            if strcmp(VCtl.NoSliceAlias,'on')
                VMag.FRange(1:AP1-1,:,:)=0;
                VMag.FRange(AP2:end,:,:)=0;
            end
        end
end

if VObj.SpinNum >1
    InddWRnd=linspace(0.01,0.99,VObj.SpinNum);
    for j=1:VObj.TypeNum
        for i=1:VObj.SpinNum
            VMag.dWRnd(:,:,:,i,j)=(1./VObj.T2Star(:,:,:,j)-1./VObj.T2(:,:,:,j)).*tan(pi.*(InddWRnd(i)-1/2));
            % need large number of spins for stimulating T2* effect,
            % insufficient number of spins may cause in-accurate simulation
        end
    end
end

if isfield(Simuh,'MagXMLFile')
    [VMmg.xgrid,VMmg.ygrid,VMmg.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                                (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                                (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);
    [pathstr,name,ext]=fileparts(Simuh.MagXMLFile);
    eval(['dB0=' name ';']);
    VMag.dB0=dB0;
end

switch VCtl.Shim   % B0 shimming
    case 'Auto'
        % do nothing
    case 'Manual'
        DoManualShim;
end

%% VObj Virtual Object
VObj.Mx=zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]);
VObj.My=zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]);
VObj.Mz=zeros([Mxdims(1), Mxdims(2), Mxdims(3), VObj.SpinNum, VObj.TypeNum]);
for i=1:VObj.TypeNum
    VObj.Mz(:,:,:,:,i)=repmat(double(VObj.Rho(:,:,:,i))/double(VObj.SpinNum),[1,1,1,VObj.SpinNum]);
end

%% VSig Virtual Signal
VSig.Mx=VObj.Mx;
VSig.My=VObj.My;
VSig.Mz=VObj.Mz;
VSig.Muts=0;

%% VCoi Virtual Coils
% B1Level: linear scale factor for B1. The input B1+ field with magnitude of this number produces nominal flip angle
% E1Level: linear scale factor for E1. The input E1+ field is scaled by an factor of nominal rf amplitude normalzed by this number
VCoi=struct( ...
            'TxCoilNum', 1, ...
            'RxCoilNum', 1, ...
            'TxCoilDefault',1,... % use default Tx Coil
            'RxCoilDefault',1,... % use default Rx Coil
            'TxCoilmg',ones([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'TxCoilpe',zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'RxCoilx',ones([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'RxCoily',zeros([Mxdims(1), Mxdims(2), Mxdims(3)]), ...
            'TxE1x',0,...
            'TxE1y',0,...
            'TxE1z',0,...
            'RxE1x',0,...
            'RxE1y',0,...
            'RxE1z',0 ...
            );
if isfield(Simuh,'CoilTxXMLFile')
    [VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                                (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                                (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);
    
    VMco.xgrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
    VMco.ygrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
    VMco.zgrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
    VMco.xgrid=reshape(VMco.xgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
    VMco.ygrid=reshape(VMco.ygrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
    VMco.zgrid=reshape(VMco.zgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
    
    [pathstr,name,ext]=fileparts(Simuh.CoilTxXMLFile);
    eval(['[B1x, B1y, B1z, E1x, E1y, E1z, Pos]=' name ';']);
    if strcmp(VCtl.MultiTransmit,'off')
        VCoi.TxCoilmg=abs(sum(B1x+1i*B1y,4))./VCtl.B1Level; % total B+ field magnitude after normalization
        VCoi.TxCoilpe=angle(sum(B1x+1i*B1y,4)); % total B+ field phase
        VCoi.TxCoilNum=1;
        VCoi.TxE1x=sum(E1x,4)./VCtl.E1Level; % E+ field x component after normalization
        VCoi.TxE1y=sum(E1y,4)./VCtl.E1Level; % E+ field y component after normalization
        VCoi.TxE1z=sum(E1z,4)./VCtl.E1Level; % E+ field z component after normalization
    else
        VCoi.TxCoilmg=abs(B1x+1i*B1y)./VCtl.B1Level; % B+ field magnitude after normalization
        VCoi.TxCoilpe=angle(B1x+1i*B1y); % B+ field phase
        VCoi.TxCoilNum=length(Pos(:,1));
        VCoi.TxE1x=E1x./VCtl.E1Level; % E+ field x component after normalization
        VCoi.TxE1y=E1y./VCtl.E1Level; % E+ field y component after normalization
        VCoi.TxE1z=E1z./VCtl.E1Level; % E+ field z component after normalization
    end
    VCoi.TxCoilDefault = 0;
end

if isfield(Simuh,'CoilRxXMLFile')
    if ~isfield(Simuh,'CoilTxXMLFile')
        [VMco.xgrid,VMco.ygrid,VMco.zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                                    (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                                    (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);
                                                
        VMco.xgrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
        VMco.ygrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
        VMco.zgrid(repmat(VMag.FRange,[1,1,1,VCoi.RxCoilNum])==0)=[];
        VMco.xgrid=reshape(VMco.xgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
        VMco.ygrid=reshape(VMco.ygrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);
        VMco.zgrid=reshape(VMco.zgrid,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),VCoi.RxCoilNum]);                            
    end

    [pathstr,name,ext]=fileparts(Simuh.CoilRxXMLFile);
    eval(['[B1x, B1y, B1z, E1x, E1y, E1z, Pos]=' name ';']);
    VCoi.RxCoilx=B1x./VCtl.B1Level; % B- field x component after normalization
    VCoi.RxCoily=B1y./VCtl.B1Level; % B- field y component after normalization
    VCoi.RxCoilNum=length(Pos(:,1));
    VCoi.RxCoilDefault = 0;
    VCoi.RxE1x=E1x./VCtl.E1Level; % E- field x component after normalization
    VCoi.RxE1y=E1y./VCtl.E1Level; % E- field y component after normalization
    VCoi.RxE1z=E1z./VCtl.E1Level; % E- field z component after normalization
end

%% VMot Virtual Motion
VMot=struct( ...
            't', 0, ...
            'ind', 1, ...
            'Disp', [0;0;0], ...
            'Axis', [1;0;0], ...
            'Ang', 0  ...          
            );
if isfield(Simuh,'MotXMLFile')
    [pathstr,name,ext]=fileparts(Simuh.MotXMLFile);
    eval(['[t, ind, Disp, Axis, Ang]=' name ';']);
    VMot.t=t;
    VMot.ind=ind;
    VMot.Disp=Disp;
    VMot.Axis=Axis;
    VMot.Ang =Ang;
end

%% VVar Virtual Pulse Packet Initialization
VVar=struct(                          ...
    'rfAmp',        zeros(VCoi.TxCoilNum, 1), ...
    'rfPhase',      zeros(VCoi.TxCoilNum, 1), ...
    'rfFreq',       zeros(VCoi.TxCoilNum, 1), ...
    'rfCoil',       0, ...
    'rfRef',        0,              ...
    'GzAmp',        0,              ...
    'GyAmp',        0,              ...
    'GxAmp',        0,              ...
    'ADC',          0,              ...
    'Ext',          0,              ...
    't',            0,              ...
    'dt',           0,              ...
    'rfi',          0,              ...
    'Gzi',          0,              ...
    'Gyi',          0,              ...
    'Gxi',          0,              ...
    'ADCi',         0,              ...
    'Exti',         0,              ...
    'utsi',         0,              ...
    'Kz',           0,              ...
    'Ky',           0,              ...
    'Kx',           0,              ...
    'SliceCount',   0,              ...
    'PhaseCount',   0,              ...
    'TRCount',      0,              ...
    'ObjLoc',       [0;0;0],        ...  % Object location
    'ObjTurnLoc',   [0;0;0],        ...  % Object turning point location
    'ObjAng',       0,              ...  % Object rotating angle
    'ObjMotInd',    0,              ...  % Object motion section index
    'gpuFetch',     0               ...  % Flag for fetching GPU data at extended process 
    );

end