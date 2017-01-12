
function DoSNRCalc(Simuh)

global VCtl;

VCtl.SNR=     VCtl.B0*VCtl.RSlice*VCtl.RPhase*VCtl.RFreq*(1/VCtl.NoiseLevel)* ...
         sqrt(VCtl.ResFreq*VCtl.ResPhase*VCtl.SliceNum*VCtl.NEX*(1/VCtl.BandWidth));

if ~isfield(VCtl,'RefSNR')
    VCtl.RefSNR=VCtl.SNR;
end
     
set(Simuh.SNR_text,'String', ['SNR : ' num2str(round((VCtl.SNR./VCtl.RefSNR).*100)) '%']);
     
end