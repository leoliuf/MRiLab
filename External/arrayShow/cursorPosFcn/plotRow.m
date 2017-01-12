function plotRow(asObj, pos)

currImg = asObj.getSelectedImages(false);
figure;
cPlot(currImg(pos(1),:)');

% create plot title
title(['Row ', num2str(pos(1))]);

% create plot figure title
set(gcf,'name',['Row-Plot: ',asObj.getFigureTitle()]);

end
