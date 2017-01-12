
function DoScanSeriesUpd(Simuh,ScanFlag)
global VCtl
    try
    [pathstr,name,ext]=fileparts(Simuh.SeqXMLFile);
    catch me
        guidata(Simuh.SimuPanel_figure,Simuh);
        return;
    end
    if ~isfield(Simuh,'ScanSeries')
        Simuh.ScanSeriesInd=1;
        Simuh.ScanSeries(1,1:3)={[num2str(Simuh.ScanSeriesInd) ':'],'Dx',name};
    else
        switch ScanFlag
            case 0 % load PSD
               Simuh.ScanSeries(Simuh.ScanSeriesInd,1:3)={[num2str(Simuh.ScanSeriesInd) ':'],'Dx',name};
            case 1 % scan setting
               Simuh.ScanSeries(Simuh.ScanSeriesInd,1:2)={[num2str(Simuh.ScanSeriesInd) ':'],'Dx'};
            case 2 % scanning
               Simuh.ScanSeries(Simuh.ScanSeriesInd,1:2)={[num2str(Simuh.ScanSeriesInd) ':'],'...'};
               VCtl.SeriesName = Simuh.ScanSeries{Simuh.ScanSeriesInd,3};
            case 3 % scan complete
               Simuh.ScanSeries(Simuh.ScanSeriesInd,1:2)={[num2str(Simuh.ScanSeriesInd) ':'],'V'};
               Simuh.ScanSeriesInd=Simuh.ScanSeriesInd+1;
            case 4 % scan fail
               Simuh.ScanSeries(Simuh.ScanSeriesInd,1:2)={[num2str(Simuh.ScanSeriesInd) ':'],'X'};
               Simuh.ScanSeriesInd=Simuh.ScanSeriesInd+1;
            case 5 % add to batch
               Simuh.ScanSeries(Simuh.ScanSeriesInd,1:2)={[num2str(Simuh.ScanSeriesInd) ':'],'B'};
               Simuh.ScanSeriesInd=Simuh.ScanSeriesInd+1;
        end

    end
    set(Simuh.ScanSeries_uitable,'Data',Simuh.ScanSeries);
    set(Simuh.ScanSeries_uitable,'Enable','on');
    guidata(Simuh.SimuPanel_figure,Simuh);
end