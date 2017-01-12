function drawPhaseCircle(asObj, pos)
NOP = 40;       % number of points for the circle
RADIUSDIV = 15;
CIRCCOL = 'blue';

if strcmp(asObj.complexSelect.getSelection,'Pha')
    LINECOL = 'white';
else
    LINECOL = 'cyan';
end

% get properties from object
%             pos = obj.cursor.getPosition;
img = asObj.getSelectedImages(true);
phi = angle(img(pos(1),pos(2)));

ah = asObj.getCurrentAxesHandle;

dim = asObj.getImageDimensions;
radius = max(dim(1:2))/RADIUSDIV;


% derive cartesian coordinates of a line with radius 1 and angle phi\
[Xl,Yl] = pol2cart([0,phi],[0,radius]);

% shift to cursor position
Xl = Xl + pos(2);
Yl = Yl + pos(1);

% derive cartesian coordinates of a unity circle with NOP points
THETA=linspace(0,2*pi,NOP);
RHO=ones(1,NOP) * radius;
[Xc,Yc] = pol2cart(THETA,RHO);

% shift to cursor position
Xc = Xc + pos(2);
Yc = Yc + pos(1);

ud = get(ah,'UserData');
if isfield(ud,'phaseCirc') && ishandle(ud.phaseCirc(1))
    delete(ud.phaseCirc);
end

% plot both
hold(ah,'on');
ud.phaseCirc = plot(Xl,Yl,LINECOL,Xc,Yc,CIRCCOL,'Parent',ah);
hold(ah,'off');
set(ud.phaseCirc,'HitTest','off');
set(ah,'UserData',ud);
end
