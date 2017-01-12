function phasePlot(asObj,pos)
INCLUDEMAG = true;
% YLIM = [-180,180];
YLIM = [-90,90];
s = asObj.getAllImages;
sel = asObj.selection.getValueAsCell;

switch length(sel)
    case 3        
        s = squeeze(   s( pos(1), pos(2),:) );        
    case 4
        sel4 = str2double(sel{4});
        s = squeeze(   s( pos(1), pos(2),:, sel4) );
    case 5
        sel3 = str2double(sel{3});
        sel4 = str2double(sel{4});        
        s = squeeze(   s( pos(1), pos(2),sel3, sel4,:) );
end
p = angle(s) * 180/pi;
NE = length(s);
x = 1 : NE;

xodd = x(1:2:end);
xeven = x(2:2:end);
podd = p(1:2:end);
peven = p(2:2:end);


% create plot window below asObject
if isempty(asObj.UserData) ||...
        ~isfield(asObj.UserData,'plotFigHandle') ||...
        ~ishandle(asObj.UserData.plotFigHandle)||...
        ~strcmp(get(asObj.UserData.plotFigHandle,'UserData'),'plotFig')
    
    figPos = asObj.getFigureOuterPosition;
    figPos(2) = figPos(2) - figPos(4) - 26;
    asObj.UserData.plotFigHandle = figure('OuterPosition',figPos,...
        'MenuBar','figure',...
        'ToolBar','none',...
        'UserData','plotFig',...
        'name',asObj.getFigureTitle);    
    asObj.UserData.plotAxisHandle = axes;
    figure(asObj.getFigureHandle);    
end
ah = asObj.UserData.plotAxisHandle;


if INCLUDEMAG
   m = abs(s);     
   ra = YLIM(2) - YLIM(1);
   m = (m * ra *.99 / m(1)) + YLIM(1); % norm to pixel decay max
%     m = (m * ra *.99 /asObj.statistics.getMax) + YLIM(1); % norm to image max
   
   plot(ah,xodd,podd,'x',xeven,peven,'o',x,p,'-',x,m,'*');
   ytit = 'signal / phase [au / deg]';
else
    plot(ah,xodd,podd,'x',xeven,peven,'o',x,p,'-');
%     plot(x,p,'x-');
    ytit = 'phase [deg]';
end
ylim(ah,YLIM);
title(ah,sprintf('Pixel %d / %d',pos(1),pos(2)));
xlabel(ah,'echo number');
ylabel(ah,ytit);
% legend('odd echoes','even echoes','both')


end