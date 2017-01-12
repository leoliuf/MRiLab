
function ExecFlag=DoSpinWatchExec(handles)

global VObj;
global VMag;
global VVar;
global VSeq;
global VCtl;
global VSig;
global VCoi;

%preserve VObj VMag & VCoi
VTmpObj=VObj;
VTmpMag=VMag;
VTmpCoi=VCoi;

handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
DoDisableButton([],[],handles.Simuh);
%% Do spin execution
try
    % Read tab parameters
    fieldname=fieldnames(handles.Attrh1);
    for i=1:length(fieldname)/2
        try
            eval(['SW.' fieldname{i*2} '=[' get(handles.Attrh1.(fieldname{i*2}),'String') '];']);
        catch me
            TAttr=get(handles.Attrh1.(fieldname{i*2}),'String');
            eval(['SW.' fieldname{i*2} '=''' TAttr{get(handles.Attrh1.(fieldname{i*2}),'Value')}  ''';']);
        end
    end
    
    % Prescan config
    DoPreScan(handles.Simuh);
    
    % Create SpinWatcher VOsw, VMsw & VCsw
    VOsw=VObj;
    VOsw.Gyro=SW.Gyro;
    VOsw.ChemShift=SW.ChemShift;
    VOsw.SpinNum=SW.SpinPerVoxel;
    VOsw.TypeNum=SW.TypeNum;
    VOsw.XDim=1;
    VOsw.YDim=1;
    VOsw.ZDim=1;
    VOsw=rmfield(VOsw, 'Rho');
    VOsw=rmfield(VOsw, 'T1');
    VOsw=rmfield(VOsw, 'T2');
    VOsw=rmfield(VOsw, 'T2Star');
    VOsw=rmfield(VOsw, 'Type');
    for i=1:VOsw.TypeNum
        VOsw.Rho(:,:,:,i)=SW.Rho(i);
        VOsw.T1(:,:,:,i)=SW.T1(i);
        VOsw.T2(:,:,:,i)=SW.T2(i);
        VOsw.T2Star(:,:,:,i)=SW.T2Star(i);
    end
            
    if isfield(VCtl, 'MT_Flag')
        if strcmp(VCtl.MT_Flag, 'on')
            K = VOsw.K;
            VOsw=rmfield(VOsw, 'K');
            VOsw.K=K(SW.LocY,SW.LocX,SW.LocZ,:);
        end
    end
    
    if isfield(VCtl, 'ME_Flag')
        if strcmp(VCtl.ME_Flag, 'on')
            K = VOsw.K;
            VOsw=rmfield(VOsw, 'K');
            VOsw.K=K(SW.LocY,SW.LocX,SW.LocZ,:);
        end
    end
    
    if isfield(VCtl, 'CEST_Flag')
        if strcmp(VCtl.CEST_Flag, 'on')
            K = VOsw.K;
            VOsw=rmfield(VOsw, 'K');
            VOsw.K=K(SW.LocY,SW.LocX,SW.LocZ,:);
        end
    end
    
    if isfield(VCtl, 'GM_Flag')
        if strcmp(VCtl.GM_Flag, 'on')
            K = VOsw.K;
            VOsw=rmfield(VOsw, 'K');
            VOsw.K=K(SW.LocY,SW.LocX,SW.LocZ,:);
        end
    end
    
    VOsw=rmfield(VOsw, 'Mx');
    VOsw=rmfield(VOsw, 'My');
    VOsw=rmfield(VOsw, 'Mz');
    VOsw.Mx= zeros(1,1,1,VOsw.SpinNum,VOsw.TypeNum);
    VOsw.My= zeros(1,1,1,VOsw.SpinNum,VOsw.TypeNum);
    for i=1:VOsw.TypeNum
        VOsw.Mz(:,:,:,:,i)= ones(1,1,1,VOsw.SpinNum,1).*(VOsw.Rho(i)./VOsw.SpinNum);
    end
    
    % Gradient Grid
    VMsw=VMag;
    VMsw=rmfield(VMsw, 'Gxgrid');
    VMsw=rmfield(VMsw, 'Gygrid');
    VMsw=rmfield(VMsw, 'Gzgrid');
    VMsw=rmfield(VMsw, 'dB0');
    VMsw=rmfield(VMsw, 'dWRnd');
    VMsw=rmfield(VMsw, 'FRange');
    VMsw.Gxgrid=VMag.Gxgrid(SW.LocY,SW.LocX,SW.LocZ);
    VMsw.Gygrid=VMag.Gygrid(SW.LocY,SW.LocX,SW.LocZ);
    VMsw.Gzgrid=VMag.Gzgrid(SW.LocY,SW.LocX,SW.LocZ);
    if VMag.dB0==0
        VMsw.dB0=0;
    else
        VMsw.dB0=VMag.dB0(SW.LocY,SW.LocX,SW.LocZ);
    end
    if VOsw.SpinNum > 1
        InddWRnd=linspace(0.01,0.99,VOsw.SpinNum);
        for j=1:VOsw.TypeNum
            for i=1:VOsw.SpinNum
                VMsw.dWRnd(:,:,:,i,j)=(1./VOsw.T2Star(:,:,:,j)-1./VOsw.T2(:,:,:,j)).*tan(pi.*(InddWRnd(i)-1/2));
                % need large number of spins for stimulating T2* effect,
                % insufficient number of spins may cause in-accurate simulation
            end
        end
    else
        for j=1:VOsw.TypeNum
            for i=1:VOsw.SpinNum
                VMsw.dWRnd(:,:,:,i,j)= 0;
            end
        end
    end
    VMsw.FRange=1;

    % Coil
    VCsw=VCoi;
    if isfield(handles.Simuh,'CoilTxXMLFile')
        VCsw.TxCoilmg=VCoi.TxCoilmg(SW.LocY - max(1, str2num(get(handles.Simuh.AP1_text,'String'))) + 1, ...   % Align postion with respect to FOV
                                    SW.LocX - max(1, str2num(get(handles.Simuh.LR1_text,'String'))) + 1, ...
                                    SW.LocZ - max(1, str2num(get(handles.Simuh.SI1_text,'String'))) + 1, :);
        VCsw.TxCoilpe=VCoi.TxCoilpe(SW.LocY - max(1, str2num(get(handles.Simuh.AP1_text,'String'))) + 1, ...   % Align postion with respect to FOV
                                    SW.LocX - max(1, str2num(get(handles.Simuh.LR1_text,'String'))) + 1, ...
                                    SW.LocZ - max(1, str2num(get(handles.Simuh.SI1_text,'String'))) + 1, :);
    else
        VCsw.TxCoilmg=VCoi.TxCoilmg(SW.LocY,SW.LocX,SW.LocZ,:);
        VCsw.TxCoilpe=VCoi.TxCoilpe(SW.LocY,SW.LocX,SW.LocZ,:);
    end
    %% Spin execution
    VObj=VOsw;
    VMag=VMsw;
    VCoi=VCsw;
    
    % Generate Pulse line
    DoPulseGen(handles.Simuh);
    
    % Initialize Mx, My, Mz, Muts in VSig
    VSig.Mx= zeros(1,1,1,VOsw.SpinNum,VOsw.TypeNum, max(size(VSeq.utsLine)));
    VSig.My= zeros(1,1,1,VOsw.SpinNum,VOsw.TypeNum, max(size(VSeq.utsLine)));
    VSig.Mz= zeros(1,1,1,VOsw.SpinNum,VOsw.TypeNum, max(size(VSeq.utsLine)));
    VSig.Muts=zeros(max(size(VSeq.utsLine)),1);
    
    VSig.Mx(:,:,:,:,:,1)=VOsw.Mx;
    VSig.My(:,:,:,:,:,1)=VOsw.My;
    VSig.Mz(:,:,:,:,:,1)=VOsw.Mz;
    VSig.Muts(1)=0;
    
    % Simulation Process
    try
        VCtl.CS=double(VObj.ChemShift*VCtl.B0);
        VCtl.RunMode=int32(1); % Spin scan
        VCtl.MaxThreadNum=int32(handles.Simuh.CPUInfo.NumThreads);
        VCtl.ActiveThreadNum=int32(0);
        DoDataTypeConv(handles.Simuh);
        
        if isfield(VCtl, 'MT_Flag')
            if strcmp(VCtl.MT_Flag, 'on')
                VCtl.GPUIndex=int32(0);
                DoMTScanAtGPU;  % beta MT kernel, only support two-pool MT
            else
                DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
            end
        elseif isfield(VCtl, 'ME_Flag')
            if strcmp(VCtl.ME_Flag, 'on')
                VCtl.GPUIndex=int32(0);
                DoMEScanAtGPU;  % beta ME kernel
            else
                DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
            end
        elseif isfield(VCtl, 'CEST_Flag')
            if strcmp(VCtl.CEST_Flag, 'on')
                VCtl.GPUIndex=int32(0);
                DoCESTScanAtGPU;  % beta CEST kernel
            else
                DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
            end
        elseif isfield(VCtl, 'GM_Flag')
            if strcmp(VCtl.GM_Flag, 'on')
                VCtl.GPUIndex=int32(0);
                DoGMScanAtGPU;  % beta GM kernel
            else
                DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
            end
        else
            DoScanAtCPU;  % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed
        end
        
    catch me
        error_msg{1,1}='ERROR!!! Spin execution process aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        ExecFlag=0;
        %recover VObj
        VObj=VTmpObj;
        VMag=VTmpMag;
        VCoi=VTmpCoi;
        return;
    end
    
    % Convert VSig.Mx, VSig.My, VSig.Mz
    VSig.Mx = double(VSig.Mx);
    VSig.My = double(VSig.My);
    VSig.Mz = double(VSig.Mz);
    
    handles.Mx=VSig.Mx.*double(VObj.SpinNum);
    handles.My=VSig.My.*double(VObj.SpinNum);
    handles.Mz=VSig.Mz.*double(VObj.SpinNum);
    handles.Muts=VSig.Muts;
    handles.MutsStep=length(VSig.Muts);
    
    Mx=sum(reshape(VSig.Mx,[VObj.SpinNum,VObj.TypeNum, max(size(VSeq.utsLine))]),1);
    My=sum(reshape(VSig.My,[VObj.SpinNum,VObj.TypeNum, max(size(VSeq.utsLine))]),1);
    Mz=sum(reshape(VSig.Mz,[VObj.SpinNum,VObj.TypeNum, max(size(VSeq.utsLine))]),1); 
    Mx=reshape(Mx,[VObj.TypeNum max(size(VSeq.utsLine))]);
    My=reshape(My,[VObj.TypeNum max(size(VSeq.utsLine))]);
    Mz=reshape(Mz,[VObj.TypeNum max(size(VSeq.utsLine))]);
    Mx=Mx';
    My=My';
    Mz=Mz';
    handles.MxySum=sqrt(Mx.^2+My.^2);
    handles.MzSum=Mz;
    handles.MaxMxySum=max(max(handles.MxySum));
    handles.MaxMzSum=max(max(handles.MzSum));
    handles.MinMxySum=min(min(handles.MxySum));
    handles.MinMzSum=min(min(handles.MzSum));
    handles.Gzgrid=zeros(1,1,1,VObj.SpinNum);
    handles.Gygrid=zeros(1,1,1,VObj.SpinNum);
    handles.Gxgrid=zeros(1,1,1,VObj.SpinNum);
catch me
    error_msg{1,1}='ERROR!!! Spin execution process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    ExecFlag=0;
    %recover VObj
    VObj=VTmpObj;
    VMag=VTmpMag;
    VCoi=VTmpCoi;
    return;
end

%recover VObj
VObj=VTmpObj;
VMag=VTmpMag;
VCoi=VTmpCoi;

guidata(handles.SpinWatcherPanel_figure, handles);
ExecFlag=1;

end