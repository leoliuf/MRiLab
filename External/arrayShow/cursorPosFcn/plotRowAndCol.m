function plotRowAndCol(asObj, pos)

img = asObj.getSelectedImages(false);
mi = asObj.statistics.getMin;
ma = asObj.statistics.getMax;
if ~isreal(mi);
    mi = min([real(mi), imag(mi)]);
    ma = max([real(ma), imag(ma)]);
end
yLimits = [mi, ma];

% disable continuous row and column plot in asObj if the figure is closed
fh = gcf;
set(fh,'CloseRequestFcn',@(src, evnt)closeReqCb(src,asObj));

% create col plot
subplot(2,1,1);
cPlot(img(pos(1),:)');
ylim(yLimits);
xlim([1,size(img,2)]);
ylabel('pixel intensity');
xlabel('column');

% create plot title
title(['Pixel ( ',num2str(pos(1)),' / ',num2str(pos(2)),' )']);

% create plot figure title
set(fh,'name',['RowAndCol-Plot: ',asObj.getFigureTitle]);

% create row plot
subplot(2,1,2);
cPlot(img(:,pos(2)));
ylabel('pixel intensity');
xlabel('row');
ylim(yLimits);
xlim([1,size(img,1)]);
end

function closeReqCb(src, asObj)
    if isvalid(asObj)
        asObj.cursor.togglePlotRowAndCol(false)
    end
    delete(src);
end