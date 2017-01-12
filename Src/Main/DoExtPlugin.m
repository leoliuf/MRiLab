
function DoExtPlugin

% entry function for extended plugin based on Ext flag
global VVar
global VObj
global VMag
global VCoi
global VCtl

switch VVar.Ext
%% System Reserved Ext Flags (Positive)   
    case 0  % normal status
        % do nothing
    case 1 % reset K space location
        Plugin_ResetK;
    case 2 % reverse K space location
        Plugin_ReverseK;
    case 3 % lock K space location
        Plugin_LockK;
    case 4 % release K space location
        Plugin_ReleaseK;
    case 5 % calculate remaining scan time
        Plugin_Timer;
    case 6 % ideal spoiler, dephase Mxy
        Plugin_IdealSpoiler;
    case 7 % rfRef, demodulate signal phase referring to rf phase at ADC
        Plugin_rfRef;
    case 8 % trigger object motion
        Plugin_ExecuteMotion;
    case 9 % real time image recon
        Plugin_RTRecon;
%% User Defined Ext Flags (Negative)
% add user defined Ext flags here using case
% e.g.    case -5











end

%% Convert double to float
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
    end
end
VMag.dB0=single(VMag.dB0);
VMag.dWRnd=single(VMag.dWRnd);
VMag.Gzgrid=single(VMag.Gzgrid);
VMag.Gygrid=single(VMag.Gygrid);
VMag.Gxgrid=single(VMag.Gxgrid);
VCoi.TxCoilmg=single(VCoi.TxCoilmg);
VCoi.TxCoilpe=single(VCoi.TxCoilpe);
VCoi.RxCoilx=single(VCoi.RxCoilx);
VCoi.RxCoily=single(VCoi.RxCoily);


end