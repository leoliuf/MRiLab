
function DoMultiEchoChk

global VCtl

if VCtl.TEPerTR ==1
    return;
end

if ~isfield(VCtl,'ME_TEs')
    error('Please load MultiEcho tab. Multiple TE values must be provided before proceeding.');
end

if VCtl.TEPerTR ~= length(VCtl.ME_TEs)
    error('The number of TE values must match TEPerTR.');
end

end