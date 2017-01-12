
function DoMultiTransmitChk

global VSeq
global VCtl
global VCoi


if strcmp(VCtl.MultiTransmit,'on')
    MaxCoilID=max(VSeq.rfCoilLine);
    if VCoi.TxCoilNum < MaxCoilID
        error('Selected sequence uses more coil elements than current Tx coil can provide. Check sequence ''CoilID'' for correction or choose another Tx coil or turn off MultiTransmit.');
    end
    
    TxCoilID=unique(VSeq.rfCoilLine);
    if isempty(find(TxCoilID==VCtl.MasterTxCoil, 1))
        error('Master Tx coil element must be used. Check sequence ''CoilID'' for correction.');
    end
end

end