
function ExecFlag=DoSARWatchExec(handles)

global VObj;
global VMag;
global VCoi;
global VCtl;
global VSig;
global VSeq;
global VVar;

%preserve VObj
VTmpObj=VObj;

handles.Simuh=guidata(handles.Simuh.SimuPanel_figure);
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
    
    if SW.N_Second<VCtl.TR
        error('''N_Second'' needs to be no less than one TR.');
    end
    
    % Prescan config
    DoPreScan(handles.Simuh);
    DoUpdateBar(handles.TimeBar_axes,10,40);
    
    if ~isequal(size(VCoi.TxE1x(:,:,:,1)),[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))])
        error('E1+ map is not available or invalid.');
    end
    
    % Create Executing Virtual Structure VOsw
    VOsw=VObj;
    VOsw.MassDen(VMag.FRange==0)=[];
    VOsw.ECon(repmat(VMag.FRange,[1,1,1,3])==0)=[];
    
    % Kernel uses Mz to determine SpinMx size
    VOsw.MassDen=reshape(VOsw.MassDen,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3)))]);
    VOsw.ECon=reshape(VOsw.ECon,[max(max(sum(VMag.FRange,1))),max(max(sum(VMag.FRange,2))),max(max(sum(VMag.FRange,3))),3]);
    
    % Spin execution
    VObj=VOsw;

    if sum(VObj.MassDen(VObj.MassDen~=0))*(VObj.XDimRes*VObj.YDimRes*VObj.ZDimRes)*0.01<SW.N_Gram/1000
        error(['''N_Gram'' needs to be less than ' num2str(sum(VObj.MassDen(VObj.MassDen~=0))*(VObj.XDimRes*VObj.YDimRes*VObj.ZDimRes)*10) 'g (1% of the total mass).']);
    end
    
    % Generate Pulse line
    DoPulseGen(handles.Simuh);
    DoUpdateBar(handles.TimeBar_axes,20,40);
    
    % Initialize SAR, Muts in VSig & VVar
    seq=VSeq.utsLine;
    dseq=diff(seq);
    dseq(dseq<0)=0;
    tSeqEnd=sum(dseq); % sequence end time point
    if isinf(SW.N_Second)
        tStart=0;
        tEnd=tSeqEnd;
        tSample=unique([tStart, tEnd]);
    else
        tEnd=max(0,SW.tStart):SW.dt:min(tSeqEnd,SW.tEnd); % prepare SAR sampling time point
        tStart=tEnd-SW.N_Second;
        tStart(tStart<0)=0;
        tStart(tEnd==0)=[];
        tEnd(tEnd==0)=[];
        if isempty(tEnd) | isempty(tStart)
            error('Input sample time is invalid.');
        end
        tSample=unique([tStart, tEnd]);
    end
    
    [row,col,layer]=size(VObj.MassDen);
    VSig.tSample=tSample;
    VSig.tRealSample=zeros(size(tSample));
    VSig.SAR=zeros([[row,col,layer] length(tSample)]);
    VSig.Muts=zeros(max(size(VSeq.utsLine)),1);
    VVar.SAR=zeros([[row,col,layer] 3]);
    
    % Simulation Process
    fprintf('Calculating unaveraged local SAR...\n');
    try
        % convert data type
        DoDataTypeConv(handles.Simuh);
        VObj.MassDen=single(VObj.MassDen);
        VObj.ECon=single(VObj.ECon);
        VCoi.TxE1x=single(VCoi.TxE1x);
        VCoi.TxE1y=single(VCoi.TxE1y);
        VCoi.TxE1z=single(VCoi.TxE1z);
        VSig.SAR=single(VSig.SAR);
        VVar.SAR=single(VVar.SAR);
        
        % calculate dissipated power
        VCtl.MaxThreadNum=int32(handles.Simuh.CPUInfo.NumThreads);
        VVar.SARi=int32(0);
        DoCalSARAtCPU;
        
        % calculate unaveraged SAR
        SAR=zeros([size(VObj.MassDen) length(tEnd)]);
        Power=zeros([size(VObj.MassDen) length(tEnd)]);
        tSARSample=zeros(size(tEnd));
        tSARSecond=zeros(size(tEnd));
        for i=1:length(tEnd)
            if tEnd(i)>max(VSig.tRealSample)
                SAR(:,:,:,i:end)=[];
                tSARSample(i:end)=[];
                break;
            end
            idx1 = find(tSample==tStart(i));
            idx2 = find(tSample==tEnd(i));
            tSARSecond(i) = VSig.tRealSample(idx2)-VSig.tRealSample(idx1);
            % Collins et.al. MRM 2001 and Tang et.al. PIERS 2007
            SAR(:,:,:,i)=((VSig.SAR(:,:,:,idx2) - VSig.SAR(:,:,:,idx1))/(VSig.tRealSample(idx2)-VSig.tRealSample(idx1)))./(2*VObj.MassDen);
            Power(:,:,:,i)=((VSig.SAR(:,:,:,idx2) - VSig.SAR(:,:,:,idx1))/(VSig.tRealSample(idx2)-VSig.tRealSample(idx1)))*(VObj.XDimRes*VObj.YDimRes*VObj.ZDimRes/2);
            tSARSample(i)=VSig.tRealSample(idx2);
        end
        SAR(isnan(SAR))=0;
        fprintf('Calculating unaveraged local SAR completed.\n');
        DoUpdateBar(handles.TimeBar_axes,30,40);
        
    catch me
        error_msg{1,1}='ERROR!!! SAR calculation process aborted.';
        error_msg{2,1}=me.message;
        errordlg(error_msg);
        ExecFlag=0;
        
        %recover VObj
        VObj=VTmpObj;
        return;
    end
    
    %N-gram average SAR
    if SW.N_Gram~=0
        fprintf('Calculating %f-gram local SAR...\n', SW.N_Gram);
%         aveSAR=zeros(size(SAR));
%         avePower=zeros(size(Power));
%         aveKGram=zeros(size(SAR));
        % Carluccio et.al. TBME 2013
        [aveSAR,avePower]=DoSARAverageAtCPU(SAR,Power,double(VObj.MassDen),VObj.XDimRes,VObj.YDimRes,VObj.ZDimRes,SW.N_Gram);
%         for i=1:size(SAR,4)
%             [aveSAR(:,:,:,i),avePower(:,:,:,i),aveKGram(:,:,:,i)]=DoSARAverage(SAR(:,:,:,i),Power(:,:,:,i),VObj.MassDen*(VObj.XDimRes*VObj.YDimRes*VObj.ZDimRes),SW.N_Gram/1000);
%             fprintf('(%d/%d) %f-gram local SAR at time point %fs completed.\n', i, size(SAR,4), SW.N_Gram, tSARSample(i));
%             DoUpdateBar(handles.TimeBar_axes,i,size(SAR,4));
%             pause(0.001);
%         end
    else
        aveSAR=SAR;
        avePower=Power;
%         aveKGram=zeros(size(SAR));
    end
    
    handles.SW = SW;
    handles.aveSAR = aveSAR;
    handles.avePower = avePower;
%     handles.aveKGram = aveKGram;
    handles.tSAR = tEnd; % prescribed sample point
    handles.tSARSample = tSARSample; % actual sample point
    handles.tSARSecond = tSARSecond; % actual N_Second
    handles.MassDen = VObj.MassDen;
    
    DoUpdateBar(handles.TimeBar_axes,40,40);
catch me
    error_msg{1,1}='ERROR!!! SAR calculation process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    ExecFlag=0;
    
    %recover VObj
    VObj=VTmpObj;
    return;
end

%recover VObj
VObj=VTmpObj;

guidata(handles.SARWatcherPanel_figure, handles);
ExecFlag=1;

end