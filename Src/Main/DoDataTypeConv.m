
function DoDataTypeConv(Simuh)
% Keep in mind when double data is converted to double, data precision is reduced,
% sometimes may cause wired rounding error, especially may happen in pulse
% generation section where two different entry time points mistakenly merge to one.
% To maintain better calculation accuracy, need to convert data to double
% type explicitly using double().

global VObj;
global VMag;
global VCoi;
global VMot;
global VCtl;
global VVar;
global VSig;
global VSeq;


% Signal Initialization
SignalNum=numel(find(VSeq.ADCLine==1));
VSig.Sx=double(zeros(1,SignalNum*VObj.TypeNum*VCoi.RxCoilNum));
VSig.Sy=double(zeros(1,SignalNum*VObj.TypeNum*VCoi.RxCoilNum));
VSig.Kz=double(zeros(1,SignalNum));
VSig.Ky=double(zeros(1,SignalNum));
VSig.Kx=double(zeros(1,SignalNum));
VSig.Mz=single(VSig.Mz);
VSig.My=single(VSig.My);
VSig.Mx=single(VSig.Mx);
VSig.Muts=double(VSig.Muts);
VSig.SignalNum=int32(SignalNum);

%% Data Type Conversion
VObj.Gyro=double(VObj.Gyro);
VObj.ChemShift=double(VObj.ChemShift);
VObj.Mz=single(VObj.Mz);
VObj.My=single(VObj.My);
VObj.Mx=single(VObj.Mx);
VObj.Rho=single(VObj.Rho);
VObj.T1=single(VObj.T1);
VObj.T2=single(VObj.T2);

if isfield(VCtl, 'MT_Flag')
    if strcmp(VCtl.MT_Flag, 'on')
        VObj.K=single(VObj.K);
    end
end

if isfield(VCtl, 'ME_Flag')
    if strcmp(VCtl.ME_Flag, 'on')
        VObj.K=single(VObj.K);
    end
end

if isfield(VCtl, 'CEST_Flag')
    if strcmp(VCtl.CEST_Flag, 'on')
        VObj.K=single(VObj.K);
    end
end

if isfield(VCtl, 'GM_Flag')
    if strcmp(VCtl.GM_Flag, 'on')
        VObj.K=single(VObj.K);
        VObj.TypeFlag=double(VObj.TypeFlag);
    end
end

VObj.SpinNum=int32(VObj.SpinNum);
VObj.TypeNum=int32(VObj.TypeNum);

VMag.FRange=double(VMag.FRange);
VMag.dB0=single(VMag.dB0);
VMag.dWRnd=single(VMag.dWRnd);
VMag.Gzgrid=single(VMag.Gzgrid);
VMag.Gygrid=single(VMag.Gygrid);
VMag.Gxgrid=single(VMag.Gxgrid);

VCoi.TxCoilmg=single(VCoi.TxCoilmg);
VCoi.TxCoilpe=single(VCoi.TxCoilpe);
VCoi.RxCoilx=single(VCoi.RxCoilx);
VCoi.RxCoily=single(VCoi.RxCoily);
VCoi.TxCoilNum=int32(VCoi.TxCoilNum);
VCoi.RxCoilNum=int32(VCoi.RxCoilNum);
VCoi.TxCoilDefault=double(VCoi.TxCoilDefault);
VCoi.RxCoilDefault=double(VCoi.RxCoilDefault);

VMot.t=double(VMot.t);
VMot.ind=double(VMot.ind);
VMot.Disp=double(VMot.Disp);
VMot.Axis=double(VMot.Axis);
VMot.Ang=double(VMot.Ang);

VCtl.CS=double(VCtl.CS);
VCtl.TRNum=int32(VCtl.TRNum);
% VCtl.RunMode=int32(VCtl.RunMode);

VVar.t=double(VVar.t);
VVar.dt=double(VVar.dt);
VVar.rfAmp=double(VVar.rfAmp);
VVar.rfPhase=double(VVar.rfPhase);
VVar.rfFreq=double(VVar.rfFreq);
VVar.rfCoil=double(VVar.rfCoil);
VVar.rfRef=double(VVar.rfRef);
VVar.GzAmp=double(VVar.GzAmp);
VVar.GyAmp=double(VVar.GyAmp);
VVar.GxAmp=double(VVar.GxAmp);
VVar.ADC=double(VVar.ADC);
VVar.Ext=double(VVar.Ext);
VVar.Kz=double(VVar.Kz);
VVar.Ky=double(VVar.Ky);
VVar.Kx=double(VVar.Kx);
VVar.ObjLoc=double(VVar.ObjLoc);
VVar.ObjTurnLoc=double(VVar.ObjTurnLoc);
VVar.ObjMotInd=double(VVar.ObjMotInd);
VVar.ObjAng=double(VVar.ObjAng);
VVar.gpuFetch=double(VVar.gpuFetch);
VVar.utsi=int32(VVar.utsi);
VVar.rfi=int32(VVar.rfi);
VVar.Gzi=int32(VVar.Gzi);
VVar.Gyi=int32(VVar.Gyi);
VVar.Gxi=int32(VVar.Gxi);
VVar.ADCi=int32(VVar.ADCi);
VVar.Exti=int32(VVar.Exti);
VVar.SliceCount=int32(1);
VVar.PhaseCount=int32(1);
VVar.TRCount=int32(1);

VSeq.utsLine=double(VSeq.utsLine);
VSeq.tsLine=double(VSeq.tsLine);
VSeq.rfAmpLine=double(VSeq.rfAmpLine);
VSeq.rfPhaseLine=double(VSeq.rfPhaseLine);
VSeq.rfFreqLine=double(VSeq.rfFreqLine);
VSeq.rfCoilLine=double(VSeq.rfCoilLine);
VSeq.GzAmpLine=double(VSeq.GzAmpLine);
VSeq.GyAmpLine=double(VSeq.GyAmpLine);
VSeq.GxAmpLine=double(VSeq.GxAmpLine);
VSeq.ADCLine=double(VSeq.ADCLine);
VSeq.ExtLine=double(VSeq.ExtLine);
VSeq.flagsLine=double(VSeq.flagsLine);

end