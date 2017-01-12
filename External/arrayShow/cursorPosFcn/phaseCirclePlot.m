function phaseCirclePlot(obj)

    DRAWCIRC = true;
    NOP = 40;       % number of points for the circle
    RADIUSDIV = 20;

    % get properties from object
    pos = obj.getCursorPosition;
    img = obj.getSelectedImages(true);
    phi = angle(img(pos(1),pos(2)));
    
    ah = obj.getCurrentAxesHandle;
    
    dim = obj.getImageDimensions;
    radius = sqrt(prod(dim))/RADIUSDIV;

    
    % derive cartesian coordinates of a line with radius 1 and angle phi\        
    [Xl,Yl] = pol2cart([0,phi],[0,radius]);
    
    % shift to cursor position    
    Xl = Xl + pos(2);
    Yl = Yl + pos(1);

    
    if DRAWCIRC
        % derive cartesian coordinates of a unity circle with NOP points
        THETA=linspace(0,2*pi,NOP);
        RHO=ones(1,NOP) * radius;
        [Xc,Yc] = pol2cart(THETA,RHO);

        % shift to cursor position
        Xc = Xc + pos(2);
        Yc = Yc + pos(1);
    end    
    
    ud = get(ah,'UserData');
    if isfield(ud,'phaseCirc')
        delete(ud.phaseCirc);
    end

    % plot both
    hold(ah,'on');
    if DRAWCIRC
        ud.phaseCirc = plot(Xl,Yl,Xc,Yc,'Parent',ah);
    else
        ud.phaseCirc = plot(Xl,Yl,'Parent',ah);
    end
    hold(ah,'off');
    set(ah,'UserData',ud);

end



