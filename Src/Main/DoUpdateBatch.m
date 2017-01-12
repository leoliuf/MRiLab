

function DoUpdateBatch(Simuh)

global VSeq
global VObj
global VCtl
global VMag
global VCoi
global VMot
global VVar
global VSig

eval(['VSeq' num2str(Simuh.ScanSeriesInd) '=VSeq;']);
eval(['VObj' num2str(Simuh.ScanSeriesInd) '=VObj;']);
eval(['VCtl' num2str(Simuh.ScanSeriesInd) '=VCtl;']);
eval(['VMag' num2str(Simuh.ScanSeriesInd) '=VMag;']);
eval(['VCoi' num2str(Simuh.ScanSeriesInd) '=VCoi;']);
eval(['VMot' num2str(Simuh.ScanSeriesInd) '=VMot;']);
eval(['VVar' num2str(Simuh.ScanSeriesInd) '=VVar;']);
eval(['VSig' num2str(Simuh.ScanSeriesInd) '=VSig;']);

if ~exist([Simuh.MRiLabPath filesep 'Tmp' filesep 'BatchData.mat'],'file')
    Notes='temporary file used for batch process';
    save([Simuh.MRiLabPath filesep 'Tmp' filesep 'BatchData'], 'Notes');
end

save([Simuh.MRiLabPath filesep 'Tmp' filesep 'BatchData'], ...
    ['VSeq' num2str(Simuh.ScanSeriesInd)], ...
    ['VObj' num2str(Simuh.ScanSeriesInd)], ...
    ['VCtl' num2str(Simuh.ScanSeriesInd)], ...
    ['VMag' num2str(Simuh.ScanSeriesInd)], ...
    ['VCoi' num2str(Simuh.ScanSeriesInd)], ...
    ['VMot' num2str(Simuh.ScanSeriesInd)], ...
    ['VVar' num2str(Simuh.ScanSeriesInd)], ...
    ['VSig' num2str(Simuh.ScanSeriesInd)], ...
    '-append');

Simuh.BatchList{end+1,1}=Simuh.ScanSeriesInd;
Simuh.BatchList{end,2}=Simuh.SimName;
Simuh.BatchList{end,3}=Simuh.Engine;
Simuh.BatchList{end,4}='Dx';
Simuh.BatchListIdx(end+1)=Simuh.ScanSeriesInd;

guidata(Simuh.SimuPanel_figure,Simuh);

end