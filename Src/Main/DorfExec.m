
function ExecFlag=DorfExec(handles)

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
    fieldname=fieldnames(handles.Attrh0);
    for i=1:length(fieldname)/2
        switch get(handles.Attrh0.(fieldname{i*2}),'Style')
            case 'edit'
                eval(['RF.' fieldname{i*2} '=[' get(handles.Attrh0.(fieldname{i*2}),'String') '];']);
            case 'popupmenu'
                TAttr=get(handles.Attrh0.(fieldname{i*2}),'String');
                eval(['RF.' fieldname{i*2} '=''' TAttr{get(handles.Attrh0.(fieldname{i*2}),'Value')}  ''';']);
        end
    end
    
    % Prescan config
    DoPreScan(handles.Simuh);
    
    % Create SpinWatcher VOrf
    if strcmp(RF.Freq_Flag,'on') % spatial-spectral analysis
        if strcmp(RF.Spat_Flag,'on') % 2D spatial analysis
            error('Freq_Flag is incompatible with Spat_Flag! Turn Spat_Flag to off.');
        end
        set(handles.SliProfile_uipanel,'Title','Spin Response : Spatial-Spectral');
        Freq=linspace(RF.FreqDownLimit,RF.FreqUpLimit,RF.FreqRes)/VCtl.B0;
        
        VOrf=VObj;
        VOrf.Gyro=RF.Gyro;
        VOrf.ChemShift=Freq;
        VOrf.SpinNum=1;
        VOrf.TypeNum=length(Freq);
        VOrf.XDim=1;
        VOrf.YDim=1;
        VOrf.ZDim=RF.ZSpin;
        VOrf.XDimRes=1e-3;
        VOrf.YDimRes=1e-3;
        VOrf.ZDimRes=RF.ZSpinGap;
        VOrf=rmfield(VOrf, 'Rho');
        VOrf=rmfield(VOrf, 'T1');
        VOrf=rmfield(VOrf, 'T2');
        VOrf=rmfield(VOrf, 'T2Star');
        VOrf=rmfield(VOrf, 'Type');
        for i=1:VOrf.TypeNum
            VOrf.Rho(:,:,1:RF.ZSpin,i)=RF.Rho(1);
            VOrf.T1(:,:,1:RF.ZSpin,i)=RF.T1(1);
            VOrf.T2(:,:,1:RF.ZSpin,i)=RF.T2(1);
            VOrf.T2Star(:,:,1:RF.ZSpin,i)=0;
        end
        VOrf=rmfield(VOrf, 'Mx');
        VOrf=rmfield(VOrf, 'My');
        VOrf=rmfield(VOrf, 'Mz');
        VOrf.Mx= zeros(1,1,VOrf.ZDim,VOrf.SpinNum,VOrf.TypeNum);
        VOrf.My= zeros(1,1,VOrf.ZDim,VOrf.SpinNum,VOrf.TypeNum);
        VOrf.Mz= zeros(1,1,VOrf.ZDim,VOrf.SpinNum,VOrf.TypeNum);
        for i=1:VOrf.TypeNum
            VOrf.Mz(:,:,:,:,i)= ones(1,1,RF.ZSpin,VOrf.SpinNum,1).*(RF.Rho(1)./VOrf.SpinNum);
        end
    elseif strcmp(RF.Spat_Flag,'on') % 2D spatial analysis
        set(handles.SliProfile_uipanel,'Title','Spin Response : 2D Spatial');
        VOrf=VObj;
        VOrf.Gyro=RF.Gyro;
        VOrf.ChemShift=RF.ChemShift(1);
        VOrf.SpinNum=1;
        VOrf.TypeNum=1;
        VOrf.XDim=RF.XSpin;
        VOrf.YDim=RF.YSpin;
        VOrf.ZDim=1;
        VOrf.XDimRes=RF.XSpinGap;
        VOrf.YDimRes=RF.YSpinGap;
        VOrf.ZDimRes=1e-3;
        VOrf=rmfield(VOrf, 'Rho');
        VOrf=rmfield(VOrf, 'T1');
        VOrf=rmfield(VOrf, 'T2');
        VOrf=rmfield(VOrf, 'T2Star');
        VOrf=rmfield(VOrf, 'Type');

        VOrf.Rho(1:RF.YSpin,1:RF.XSpin,1,1)=RF.Rho(1);
        VOrf.T1(1:RF.YSpin,1:RF.XSpin,1,1)=RF.T1(1);
        VOrf.T2(1:RF.YSpin,1:RF.XSpin,1,1)=RF.T2(1);
        VOrf.T2Star(1:RF.YSpin,1:RF.XSpin,1,1)=0;

        VOrf=rmfield(VOrf, 'Mx');
        VOrf=rmfield(VOrf, 'My');
        VOrf=rmfield(VOrf, 'Mz');
        VOrf.Mx= zeros(VOrf.YDim,VOrf.XDim,1,VOrf.SpinNum,VOrf.TypeNum);
        VOrf.My= zeros(VOrf.YDim,VOrf.XDim,1,VOrf.SpinNum,VOrf.TypeNum);
        VOrf.Mz= zeros(VOrf.YDim,VOrf.XDim,1,VOrf.SpinNum,VOrf.TypeNum);
        for i=1:VOrf.TypeNum
            VOrf.Mz(:,:,:,:,i)= ones(VOrf.YDim,VOrf.XDim,1,VOrf.SpinNum,1).*(RF.Rho(i)./VOrf.SpinNum);
        end
    else  % normal 1D analysis
        set(handles.SliProfile_uipanel,'Title','Spin Response : 1D Spatial');
        VOrf=VObj;
        VOrf.Gyro=RF.Gyro;
        VOrf.ChemShift=RF.ChemShift;
        VOrf.SpinNum=1;
        VOrf.TypeNum=RF.TypeNum;
        VOrf.XDim=1;
        VOrf.YDim=1;
        VOrf.ZDim=RF.ZSpin;
        VOrf.XDimRes=1e-3;
        VOrf.YDimRes=1e-3;
        VOrf.ZDimRes=RF.ZSpinGap;
        VOrf=rmfield(VOrf, 'Rho');
        VOrf=rmfield(VOrf, 'T1');
        VOrf=rmfield(VOrf, 'T2');
        VOrf=rmfield(VOrf, 'T2Star');
        VOrf=rmfield(VOrf, 'Type');
        for i=1:VOrf.TypeNum
            VOrf.Rho(:,:,1:RF.ZSpin,i)=RF.Rho(i);
            VOrf.T1(:,:,1:RF.ZSpin,i)=RF.T1(i);
            VOrf.T2(:,:,1:RF.ZSpin,i)=RF.T2(i);
            VOrf.T2Star(:,:,1:RF.ZSpin,i)=0;
        end
        VOrf=rmfield(VOrf, 'Mx');
        VOrf=rmfield(VOrf, 'My');
        VOrf=rmfield(VOrf, 'Mz');
        VOrf.Mx= zeros(1,1,VOrf.ZDim,VOrf.SpinNum,VOrf.TypeNum);
        VOrf.My= zeros(1,1,VOrf.ZDim,VOrf.SpinNum,VOrf.TypeNum);
        VOrf.Mz= zeros(1,1,VOrf.ZDim,VOrf.SpinNum,VOrf.TypeNum);
        for i=1:VOrf.TypeNum
            VOrf.Mz(:,:,:,:,i)= ones(1,1,RF.ZSpin,VOrf.SpinNum,1).*(RF.Rho(i)./VOrf.SpinNum);
        end
    end

    if strcmp(RF.Spat_Flag,'on') % 2D analysis
        % Gradient Grid
        VMrf=VMag;
        VMrf=rmfield(VMrf, 'Gxgrid');
        VMrf=rmfield(VMrf, 'Gygrid');
        VMrf=rmfield(VMrf, 'Gzgrid');
        VMrf=rmfield(VMrf, 'dB0');
        VMrf=rmfield(VMrf, 'dWRnd');
        VMrf=rmfield(VMrf, 'FRange');

        [VMrf.Gxgrid,VMrf.Gygrid,VMrf.Gzgrid]=meshgrid((-RF.XCenter+1)*RF.XSpinGap:RF.XSpinGap:(RF.XSpin-RF.XCenter)*RF.XSpinGap, ...
                                                       (-RF.YCenter+1)*RF.YSpinGap:RF.YSpinGap:(RF.YSpin-RF.YCenter)*RF.YSpinGap,1);
        VMrf.dB0=ones([RF.YSpin RF.XSpin 1])*RF.dB0;
        VMrf.dWRnd=zeros(size(VOrf.Mz));
        VMrf.FRange=ones(size(VOrf.Rho));

        % Coil
        VCrf=VCoi;
        VCrf.TxCoilmg  = ones([RF.YSpin RF.XSpin 1]);  % Unit B1+ for rf analysis
        VCrf.TxCoilpe  = zeros([RF.YSpin RF.XSpin 1]);
        VCrf.TxCoilNum = 1;
        
    else % spatial-spectral analysis or 1D analysis
        % Gradient Grid
        VMrf=VMag;
        VMrf=rmfield(VMrf, 'Gxgrid');
        VMrf=rmfield(VMrf, 'Gygrid');
        VMrf=rmfield(VMrf, 'Gzgrid');
        VMrf=rmfield(VMrf, 'dB0');
        VMrf=rmfield(VMrf, 'dWRnd');
        VMrf=rmfield(VMrf, 'FRange');

        [VMrf.Gxgrid,VMrf.Gygrid,VMrf.Gzgrid]=meshgrid(0,0,(-RF.ZCenter+1)*RF.ZSpinGap:RF.ZSpinGap:(RF.ZSpin-RF.ZCenter)*RF.ZSpinGap); % assume constant unit gradient in GzSS
        VMrf.dB0=ones([1 1 RF.ZSpin])*RF.dB0;
        VMrf.dWRnd=zeros(size(VOrf.Mz));
        VMrf.FRange=ones(size(VOrf.Rho));

        % Coil
        VCrf=VCoi;
        VCrf.TxCoilmg  = ones([1 1 RF.ZSpin]);  % Unit B1+ for rf analysis
        VCrf.TxCoilpe  = zeros([1 1 RF.ZSpin]);
        VCrf.TxCoilNum = 1;
        
    end
    %% Spin execution
    VObj=VOrf;
    VMag=VMrf;
    VCoi=VCrf;
    
    % Generate Pulse line
    if isfield(handles,'rfNode')
        for parai=1:length(handles.rfNode.Attributes)
            if ~isempty(handles.rfNode.Attributes(parai).Value)
                switch handles.rfNode.Attributes(parai).Value(1)
                    case '$'
                        eval(['AttributeOpt={' handles.rfNode.Attributes(parai).Value(3:end) '};']);
                        eval(['p.' handles.rfNode.Attributes(parai).Name '=AttributeOpt{' handles.rfNode.Attributes(parai).Value(2) '};']);
                    otherwise
                        if ~strcmp(handles.rfNode.Attributes(parai).Name,'Notes')
                            eval(['p.' handles.rfNode.Attributes(parai).Name '=' handles.rfNode.Attributes(parai).Value ';']);
                        else
                            eval(['p.' handles.rfNode.Attributes(parai).Name '=''' handles.rfNode.Attributes(parai).Value ''';']);
                        end
                end
                
            else
                eval(['p.' handles.rfNode.Attributes(parai).Name '=[];']);
            end
        end
        VVar.TRCount=1; % may used for rfUser
        eval(['[rfAmp,rfPhase,rfFreq,rfCoil,rfTime]=' handles.rfNode.Name '(p);']);
    else
        errordlg('Please choose a rf wave type (e.g. rfSinc)!');
        ExecFlag=0;
        %recover VObj VMag VCoi
        VObj=VTmpObj;
        VMag=VTmpMag;
        VCoi=VTmpCoi;
        return
    end
    
    if strcmp(RF.Spat_Flag,'off')
        if isfield(handles,'GzNode')
            for parai=1:length(handles.GzNode.Attributes)
                if ~isempty(handles.GzNode.Attributes(parai).Value)
                    switch handles.GzNode.Attributes(parai).Value(1)
                        case '$'
                            eval(['AttributeOpt={' handles.GzNode.Attributes(parai).Value(3:end) '};']);
                            eval(['p.' handles.GzNode.Attributes(parai).Name '=AttributeOpt{' handles.GzNode.Attributes(parai).Value(2) '};']);
                        otherwise
                            if ~strcmp(handles.GzNode.Attributes(parai).Name,'Notes')
                                eval(['p.' handles.GzNode.Attributes(parai).Name '=' handles.GzNode.Attributes(parai).Value ';']);
                            else
                                eval(['p.' handles.GzNode.Attributes(parai).Name '=''' handles.GzNode.Attributes(parai).Value ''';']);
                            end
                    end
                    
                else
                    eval(['p.' handles.GzNode.Attributes(parai).Name '=[];']);
                end
            end
            VVar.TRCount=1; % may used for GzUser
            eval(['[GzAmp,GzTime]=' handles.GzNode.Name '(p);']);
        else
            GzAmp=[0 RF.ConstantGrad RF.ConstantGrad 0];
            GzTime=[0 VCtl.MinUpdRate max(rfTime)-VCtl.MinUpdRate max(rfTime)];
            warndlg('Please choose a GzSS gradient type (e.g. GzSelective), otherwise constant gradient (i.e. ConstantGrad) will be used!');
        end
        
    else
        if isfield(handles,'GyNode')
            for parai=1:length(handles.GyNode.Attributes)
                if ~isempty(handles.GyNode.Attributes(parai).Value)
                    switch handles.GyNode.Attributes(parai).Value(1)
                        case '$'
                            eval(['AttributeOpt={' handles.GyNode.Attributes(parai).Value(3:end) '};']);
                            eval(['p.' handles.GyNode.Attributes(parai).Name '=AttributeOpt{' handles.GyNode.Attributes(parai).Value(2) '};']);
                        otherwise
                            if ~strcmp(handles.GyNode.Attributes(parai).Name,'Notes')
                                eval(['p.' handles.GyNode.Attributes(parai).Name '=' handles.GyNode.Attributes(parai).Value ';']);
                            else
                                eval(['p.' handles.GyNode.Attributes(parai).Name '=''' handles.GyNode.Attributes(parai).Value ''';']);
                            end
                    end
                    
                else
                    eval(['p.' handles.GyNode.Attributes(parai).Name '=[];']);
                end
            end
            VVar.TRCount=1; % may used for GyUser
            eval(['[GyAmp,GyTime]=' handles.GyNode.Name '(p);']);
        else
            GyAmp=[0 RF.ConstantGrad RF.ConstantGrad 0];
            GyTime=[0 VCtl.MinUpdRate max(rfTime)-VCtl.MinUpdRate max(rfTime)];
            warndlg('Please choose a GyPE gradient type, otherwise constant gradient (i.e. ConstantGrad) will be used!');
        end
        
        if isfield(handles,'GxNode')
            for parai=1:length(handles.GxNode.Attributes)
                if ~isempty(handles.GxNode.Attributes(parai).Value)
                    switch handles.GxNode.Attributes(parai).Value(1)
                        case '$'
                            eval(['AttributeOpt={' handles.GxNode.Attributes(parai).Value(3:end) '};']);
                            eval(['p.' handles.GxNode.Attributes(parai).Name '=AttributeOpt{' handles.GxNode.Attributes(parai).Value(2) '};']);
                        otherwise
                            if ~strcmp(handles.GxNode.Attributes(parai).Name,'Notes')
                                eval(['p.' handles.GxNode.Attributes(parai).Name '=' handles.GxNode.Attributes(parai).Value ';']);
                            else
                                eval(['p.' handles.GxNode.Attributes(parai).Name '=''' handles.GxNode.Attributes(parai).Value ''';']);
                            end
                    end
                    
                else
                    eval(['p.' handles.GxNode.Attributes(parai).Name '=[];']);
                end
            end
            VVar.TRCount=1; % may used for GxUser
            eval(['[GxAmp,GxTime]=' handles.GxNode.Name '(p);']);
        else
            GxAmp=[0 RF.ConstantGrad RF.ConstantGrad 0];
            GxTime=[0 VCtl.MinUpdRate max(rfTime)-VCtl.MinUpdRate max(rfTime)];
            warndlg('Please choose a GxR gradient type, otherwise constant gradient (i.e. ConstantGrad) will be used!');
        end
    end
    
    if strcmp(RF.Spat_Flag,'on') % 2D analysis
        SEt=[0 max([rfTime, GxTime, GyTime])]; % SEt time landmark must start from 0
        SEflag=repmat([0 0 0 0 0 0]',[1 2]);
        rfflag=repmat([1 0 0 0 0 0]',[1 max(size(rfTime))]);
        Gyflag=repmat([0 0 1 0 0 0]',[1 max(size(GyTime))]);
        Gxflag=repmat([0 0 0 1 0 0]',[1 max(size(GxTime))]);
        
        ts=[SEt rfTime GyTime GxTime];
        flags=[SEflag rfflag Gyflag Gxflag];
        [ts,ind]=sort(ts);
        uts=unique(ts);
        flags=flags(:,ind);
        
        rfAmp(abs(rfAmp)<eps)=0;
        VSeq.rfAmpLine=rfAmp;
        VSeq.rfPhaseLine=rfPhase;
        VSeq.rfFreqLine=rfFreq;
        VSeq.rfCoilLine=ones(size(rfCoil)); % default single-Tx
        VSeq.GzAmpLine=0;
        VSeq.GyAmpLine=GyAmp;
        VSeq.GxAmpLine=GxAmp;
        VSeq.ADCLine=0;
        VSeq.ExtLine=0;
        VSeq.utsLine=uts;
        VSeq.tsLine=ts;
        VSeq.flagsLine=flags;
        
        % Initialize Mx, My, Mz, Muts in VSig
        VSig.Mx= zeros(VObj.YDim,VObj.XDim,1,1,VObj.TypeNum, max(size(VSeq.utsLine)));
        VSig.My= zeros(VObj.YDim,VObj.XDim,1,1,VObj.TypeNum, max(size(VSeq.utsLine)));
        VSig.Mz= zeros(VObj.YDim,VObj.XDim,1,1,VObj.TypeNum, max(size(VSeq.utsLine)));
        VSig.Muts=zeros(max(size(VSeq.utsLine)),1);
        
    else % spatial-spectral analysis or 1D analysis
        
        SEt=[0 max(max(rfTime),max(GzTime))]; % SEt time landmark must start from 0
        SEflag=repmat([0 0 0 0 0 0]',[1 2]);
        rfflag=repmat([1 0 0 0 0 0]',[1 max(size(rfTime))]);
        Gzflag=repmat([0 1 0 0 0 0]',[1 max(size(GzTime))]);
        
        ts=[SEt rfTime GzTime];
        flags=[SEflag rfflag Gzflag];
        [ts,ind]=sort(ts);
        uts=unique(ts);
        flags=flags(:,ind);
        
        rfAmp(abs(rfAmp)<eps)=0;
        VSeq.rfAmpLine=rfAmp;
        VSeq.rfPhaseLine=rfPhase;
        VSeq.rfFreqLine=rfFreq;
        VSeq.rfCoilLine=ones(size(rfCoil)); % default single-Tx
        VSeq.GzAmpLine=GzAmp;
        VSeq.GyAmpLine=0;
        VSeq.GxAmpLine=0;
        VSeq.ADCLine=0;
        VSeq.ExtLine=0;
        VSeq.utsLine=uts;
        VSeq.tsLine=ts;
        VSeq.flagsLine=flags;
        
        % Initialize Mx, My, Mz, Muts in VSig
        VSig.Mx= zeros(1,1,VObj.ZDim,1,VObj.TypeNum, max(size(VSeq.utsLine)));
        VSig.My= zeros(1,1,VObj.ZDim,1,VObj.TypeNum, max(size(VSeq.utsLine)));
        VSig.Mz= zeros(1,1,VObj.ZDim,1,VObj.TypeNum, max(size(VSeq.utsLine)));
        VSig.Muts=zeros(max(size(VSeq.utsLine)),1);
        
    end
    
    VSig.Mx(:,:,:,:,:,1)=VObj.Mx;
    VSig.My(:,:,:,:,:,1)=VObj.My;
    VSig.Mz(:,:,:,:,:,1)=VObj.Mz;
    VSig.Muts(1)=0;
    
    % Simulation Process
    try
        VCtl.CS=double(VObj.ChemShift*VCtl.B0);
        VCtl.RunMode=int32(1); % Spin scan
        VCtl.MaxThreadNum=int32(handles.Simuh.CPUInfo.NumThreads);
        DoDataTypeConv(handles.Simuh);
        DoScanAtCPU; % global (VSeq,VObj,VCtl,VMag,VCoi,VVar,VSig) are needed 
    catch me
        error_msg{1,1}='ERROR!!! rf execution process aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        ExecFlag=0;
        %recover VObj VMag VCoi
        VObj=VTmpObj;
        VMag=VTmpMag;
        VCoi=VTmpCoi;
        return;
    end
    
    %modify sequence line for display purpose
    if strcmp(RF.Spat_Flag,'on') % 2D analysis
        handles.rfAmp=[0 rfAmp 0];
        handles.rfPhase=[0 rfPhase 0];
        handles.rfFreq=[0 rfFreq 0];
        handles.rfTime=[SEt(1) rfTime SEt(2)];
        handles.GyAmp=[0 GyAmp 0];
        handles.GyTime=[SEt(1) GyTime SEt(2)];
        handles.GxAmp=[0 GxAmp 0];
        handles.GxTime=[SEt(1) GxTime SEt(2)];
    else % spatial-spectral analysis or 1D analysis
        handles.rfAmp=[0 rfAmp 0];
        handles.rfPhase=[0 rfPhase 0];
        handles.rfFreq=[0 rfFreq 0];
        handles.rfTime=[SEt(1) rfTime SEt(2)];
        handles.GzAmp=[0 GzAmp 0];
        handles.GzTime=[SEt(1) GzTime SEt(2)];
    end
    
    if strcmp(RF.Freq_Flag,'on')
        handles.Mx=permute(VSig.Mx,[3, 5, 6, 1, 2, 4]).*double(VObj.SpinNum);
        handles.My=permute(VSig.My,[3, 5, 6, 1, 2, 4]).*double(VObj.SpinNum);
        handles.Mz=permute(VSig.Mz,[3, 5, 6, 1, 2, 4]).*double(VObj.SpinNum);
        handles.Mx=handles.Mx(:,:,:,1,1,1);
        handles.My=handles.My(:,:,:,1,1,1);
        handles.Mz=handles.Mz(:,:,:,1,1,1);
        handles.Muts=VSig.Muts;
        handles.Freq=Freq;
    elseif strcmp(RF.Spat_Flag,'on')
        handles.Mx=permute(VSig.Mx,[1, 2, 6, 3, 4, 5]).*double(VObj.SpinNum);
        handles.My=permute(VSig.My,[1, 2, 6, 3, 4, 5]).*double(VObj.SpinNum);
        handles.Mz=permute(VSig.Mz,[1, 2, 6, 3, 4, 5]).*double(VObj.SpinNum);
        handles.Mx=handles.Mx(:,:,:,1,1,1);
        handles.My=handles.My(:,:,:,1,1,1);
        handles.Mz=handles.Mz(:,:,:,1,1,1);
        handles.Muts=VSig.Muts;
    else
        handles.Mx=VSig.Mx.*double(VObj.SpinNum);
        handles.My=VSig.My.*double(VObj.SpinNum);
        handles.Mz=VSig.Mz.*double(VObj.SpinNum);
        handles.Muts=VSig.Muts;
    end
    
    handles.Freq_Flag=RF.Freq_Flag;
    handles.Spat_Flag=RF.Spat_Flag;
    handles.Gxgrid=VMag.Gxgrid;
    handles.Gygrid=VMag.Gygrid;
    handles.Gzgrid=VMag.Gzgrid;
catch me
    error_msg{1,1}='ERROR!!! rf execution process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    ExecFlag=0;
    %recover VObj VMag VCoi
    VObj=VTmpObj;
    VMag=VTmpMag;
    VCoi=VTmpCoi;
    return;
end

%recover VObj VMag VCoi
VObj=VTmpObj;
VMag=VTmpMag;
VCoi=VTmpCoi;

guidata(handles.rfDesignPanel_figure, handles);
ExecFlag=1;

end