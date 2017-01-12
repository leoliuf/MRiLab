
function Plugin_rfRef
global VVar
global VCtl

% Pass rf phase information to kernel for signal demodulation at ADC
if strcmp(VCtl.MultiTransmit,'off')
    VVar.rfRef=VVar.rfPhase(1); % why (1) is necessary, if VVar.rfPhase is just a single number. Could it be because it's 
                                % initialized using zeros(VCtl.TxCoilNum, 1)?
else
    VVar.rfRef=VVar.rfPhase(VCtl.MasterTxCoil);
end

end