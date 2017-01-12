function plotCol(asObj, pos)

currImg = asObj.getSelectedImages(false);
figure;
cPlot(currImg(:,pos(2)));

% create plot title
title(['Col ', num2str(pos(2))]);

% create plot figure title
set(gcf,'name',['Col-Plot: ',asObj.getFigureTitle()]);
end
