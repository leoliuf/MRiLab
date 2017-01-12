%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef asCursorPosClass < handle
    
    properties (Constant)
        CURSOR_STD    = 'arrow';         % shape of mouse cursor in standard mode
        CURSOR_PLOT   = 'fullcrosshair'; % shape of cursor when being in plot mode
        
        POSITV_COLOR  = 'black';         % color for positive values
        NEGATIV_COLOR = [205/255;0;0];   % color for negative values        
    end
    
    properties (GetAccess = private, SetAccess = private)
        
        % handles
        fh  = [];    % parent figure handle
        ph  = [];    % parent panel handle
        th  = [];    % text handles
        sbh = [];    % send button handle
        cmh = [];    % contextMenu handles
        fcmh = [];   % figure contextMenu handles
        
        cursorColor= 'blue';        % color of the rectangle wrapping the pixel below the mouse cursor
        
        phaseUnit = 'deg'           % can be either 'deg' or 'rad'
        
        precision = 'auto'
        autoPrecisionLimit = 5;
        
        % callback functions
        apply2allCb               = [];   % send to all relatives callback
        getCurrentAxesHandleCb    = [];
        
        sendCursorOnMovement      = false;
        drawPhaseCircOnMovement   = false;
        plotRowAndColOnMovement   = false;
        plotAlongDimOnMovement    = false;
        callUserCursorPosFunc     = false;
        
        userFcn     = @userCursorPosFcn;
        
        position = [1,1];  % initial cursor position
        
        enabled = true;
        
        asObj = [];
    end
    
    methods
        function obj = asCursorPosClass(...
                parentFigureHandle,...
                parentPanelHandle,...
                figureContextMenuHandle,...
                apply2allCb,...
                getCurrentAxesHandleCb,...
                asObj)
                
            
            obj.fh                      = parentFigureHandle;
            obj.ph                      = parentPanelHandle;
            obj.fcmh                    = figureContextMenuHandle;
            obj.apply2allCb             = apply2allCb;
            obj.getCurrentAxesHandleCb  = getCurrentAxesHandleCb;
            obj.asObj = asObj;
            
            
            % backup panel unit settings
            phUnits = get(obj.ph,'Units');
            
            % set panel units to centimeters
            set(obj.ph,'Units','Centimeters');
            
            % init context menus
            obj.initContextMenus();
            
            % activate initial standard phaseunit
            obj.setPhaseUnit(obj.phaseUnit);
            
            % send cursor button  ..
            pos(3:4) = [0.0223, 1.0086];
            pos(1:2) = [1-pos(3),0];
            
            iconpath     = [fileparts(mfilename('fullpath')), filesep, 'icons'];
            defaultColor = get(0,'defaultuicontrolbackgroundcolor');
            sendIco      = arrShow.icoread(fullfile(iconpath,'send.png'),...
                'BackgroundColor',defaultColor);
            
            obj.sbh = uicontrol('Style','togglebutton',...
                'Parent',obj.ph,...
                'Units','normalized',...
                'Position',pos,...
                'tooltip','send cursor to relatives',...
                'Callback',@(src,evnt)obj.toggleSend(),...
                'CData',sendIco,...
                'BackgroundColor',defaultColor);
            
            
            
            
            % text objects
            t = {'Y / X :', 1   ;...
                ' '       , 1   ;...
                '/'       , .2  ;...
                ' '       , 3   ;...
                'Re :'    , .6  ;...
                ' '       , 2   ;...
                'Im :'    , .6  ;...
                ' '       , 2   ;...
                'Abs:'    , .6  ;...
                ' '       , 2   ;...
                'Ph :'    , .6  ;...
                ' '       , 2  };
            
            
            noFields = length(t);
            obj.th = zeros(noFields);
            
            %h  = panelPos(4);   % textfield heigth
            h = .36;
            l  = 0.1;  % left position
            
            for i = 1 : noFields
                w     = t{i,2};
                value = t{i,1};
                
                obj.th(i) = uicontrol('Style','Text','String',value,'HorizontalAlignment','left',...
                    'Units','Centimeters','pos',[l 0 w h],'parent',obj.ph,'HandleVisibility','on',...
                    'uicontextmenu',obj.cmh.base);
                
                l = l + w;
                set(obj.th(i),'Units','normalized');
            end
            
            % restore panel unit settings
            set(obj.ph,'Units',phUnits);
            
        end
        
        function setPrecision(obj, precision)
            % precision of the values in the bottom panel
            obj.precision = precision;
        end
        
        function changePrecisionDlg(obj)
            % open a dialog window to change the precision of the values in
            % the bottom panel
            
            newPrec = mydlg('Enter precision string','Change precision',obj.precision);
            if ~isempty(newPrec)
                % test if a valid string was entered
                if ~strcmp(newPrec,'auto')
                    try
                        num2str(2.3,newPrec);
                    catch me
                        if strcmp(me.identifier, 'MATLAB:num2str:fmtInvalid');
                            fprintf('Invalid precision string format\n');
                            newPrec = [];
                            % promt for reenter
                            obj.changePrecisionDlg();
                        else
                            throw(me);
                        end
                    end
                end
            end
            
            if ~isempty(newPrec)
                obj.precision = newPrec;
            end
        end
        
        function setPhaseUnit(obj, unit)
            switch lower(unit)
                case {'deg', 'degrees'}
                    obj.phaseUnit = 'deg';
                    set(obj.cmh.phaseUnit.deg, 'Checked', 'on');
                    set(obj.cmh.phaseUnit.rad, 'Checked', 'off');
                case {'rad', 'radiants'}
                    obj.phaseUnit = 'rad';
                    set(obj.cmh.phaseUnit.deg, 'Checked', 'off');
                    set(obj.cmh.phaseUnit.rad, 'Checked', 'on');
                otherwise
                    error('asCursorPosClass:togglePhaseUnit','unknown phase unit');
            end
        end
        
        function toggleSend(obj, bool)           
            if nargin > 1
                set(obj.fcmh.toggleSendCursor,'Checked',arrShow.boolToOnOff(~bool));
            end
            switch get(obj.fcmh.toggleSendCursor,'Checked')
                case 'off'
                    obj.sendCursorOnMovement = true;
                    set(obj.fcmh.toggleSendCursor,'Checked','on');
                    set(obj.sbh,'Value',1);
                case 'on'
                    obj.sendCursorOnMovement = false;
                    set(obj.fcmh.toggleSendCursor,'Checked','off');
                    set(obj.sbh,'Value',0);
            end
        end
        
        function send(obj)
            pos = obj.position;
            obj.apply2allCb('cursor.setPosition',false,pos);
        end
        
        function pos = getPosition(obj)
            pos = obj.position;
        end
        
        function setColor(obj,color)
            % store color in object properties
            obj.cursorColor = color;
            
            % if cursor rect is present, change color
            ah = obj.getCurrentAxesHandleCb();
            ud = get(ah,'UserData');
            if ~isempty(ud) && isfield(ud,'rect') && ~isempty(ud.rect)
                set(ud.rect,'EdgeColor',obj.cursorColor);
            end
        end
        
        function setPosition(obj, pos, forceUpdate)
            
            if nargin < 3
                forceUpdate = false;
            end
            
            % check, if position really has changed
            if all(obj.position == pos) && ~forceUpdate
                return;
            end
            if any(isnan(pos))
                return;
            end
            
            % get current axes handle
            ah = obj.getCurrentAxesHandleCb();
            
            % get complex image from the axes handle's UserData field
            ud = get(ah,'UserData');
            img = ud.cplxImg;
            
            % limit cursor position to image matrix dimensions
            [dimY, dimX] = size(img);
            if pos(1) > dimY
                pos(1) = dimY;
            end
            if pos(2) > dimX
                pos(2) = dimX;
            end
            
            % get shortcuts to x and y positions
            posY = pos(1);
            posX = pos(2);
            
            if any(obj.position ~= [posY, posX]) || forceUpdate
                
                % update stored position and the bottom panel text
                obj.position = [posY,posX];
                obj.setPosText([posY, posX],img(posY,posX));
                
                % create / modify cursor position rectangle
                if isempty(ud) || ~isfield(ud,'rect') || isempty(ud.rect)
                    % create cursor position rectangle
                    ud.rect = rectangle('Parent',ah,'Position',[posX-.5, posY-.5, 1,1],'Curvature',[0,0],...
                        'HitTest','off','EdgeColor',obj.cursorColor);
                    set(ud.rect,'HitTest','off');
                    set(ah,'UserData',ud);
                else
                    set(ud.rect,'Position',[posX-.5, posY-.5, 1,1]);
                end
                
                if obj.drawPhaseCircOnMovement
                    obj.drawPhaseCircle;
                end
                if obj.plotRowAndColOnMovement
                    obj.plotRowAndCol;
                end
                if obj.plotAlongDimOnMovement
                    obj.plotAlongPlotDim;
                end
                if obj.callUserCursorPosFunc
                    obj.userCursorPosFcn();
                end
                
                if obj.sendCursorOnMovement
                    obj.apply2allCb('cursor.setPosition',false,[posY,posX]);
                end
            end
        end
        
        function disableText(obj)
            if obj.enabled
                childs = get(obj.ph,'Children');
                for i = 1 : length(childs)
                    set(childs(i),'Enable','off');
                end
                obj.enabled = false;
            end
        end
        
        function enableText(obj)
            if ~obj.enabled
                childs = get(obj.ph,'Children');
                for i = 1 : length(childs)
                    set(childs(i),'Enable','on');
                end
                obj.enabled = true;
            end
        end
        
        function setPosText(obj,pos,value)
            
            % text handle
            t_posY   = obj.th(2);
            t_posX   = obj.th(4);
            t_reVal  = obj.th(6);
            t_imVal  = obj.th(8);
            t_absVal = obj.th(10);
            t_phVal  = obj.th(12);
            
            % get real and abs value
            reVal  = real(value);
            absVal = abs(value);
            
            % set position text
            obj.setValue(t_posY  , pos(1), '', '%d');
            obj.setValue(t_posX  , pos(2), '', '%d');
            
            % set real and abs value text
            obj.setValue(t_reVal , reVal , '', obj.precision);
            obj.setValue(t_absVal, absVal, '', obj.precision);
            
            % if value is complex, write imaginary part and phase text
            if isreal(value)
                obj.setValue(t_imVal, '-');
                obj.setValue(t_phVal, '-');
            else
                imVal  = imag(value);
                
                if strcmp(obj.phaseUnit, 'deg')
                    phVal  = angle(value)*180/pi;
                else
                    phVal  = angle(value);
                end
                
                obj.setValue(t_phVal , phVal, obj.phaseUnit);
                obj.setValue(t_imVal , imVal);
            end
            
        end
        
        
        function row = getRow(obj)
            currImg = obj.getSelectedImagesCb(false);
            pos = obj.getPosition;
            row = currImg(pos(1),:);
        end
        
        function col = getColumn(obj)
            currImg = obj.getSelectedImagesCb(false);
            pos = obj.getPosition;
            col = currImg(:,pos(2));
        end
        

        % shortcuts to frequently used cursor position functions
        function plotRowAndCol(obj)
            plotRowAndCol(obj.asObj, obj.position);
        end
        function plotRow(obj)
            plotRow(obj.asObj, obj.position);
        end
        function plotColumn(obj)
            plotCol(obj.asObj, obj.position);
        end
        function plotAlongPlotDim(obj)
            plotDim = obj.asObj.selection.getPlotDim;
            if isempty(plotDim)
                fprintf('no plot dimension given\n');
                obj.togglePlotAlongDim(false);
            else
                plotAlongDim(obj.asObj, obj.position, plotDim);
            end
        end
        function drawPhaseCircle(obj)
            drawPhaseCircle(obj.asObj, obj.position);
        end
        
        function userCursorPosFcn(obj)           
            userCursorPosFcn(obj.asObj,...
                obj.position,...
                obj.asObj.selection.getPlotDim)
        end

        
        
        % toggles for the frequently used cursor position functions
        function togglePlotRowAndCol(obj, bool)
            if nargin > 1
                set(obj.fcmh.plotRowAndCol,'Checked',arrShow.boolToOnOff(~bool));
            end

            switch get(obj.fcmh.plotRowAndCol,'Checked')
                case 'off'
                    obj.plotRowAndColOnMovement = true;
                    set(obj.fcmh.plotRowAndCol,'Checked','on');
                    set(obj.fh,'Pointer',obj.CURSOR_PLOT);
                case 'on'
                    obj.plotRowAndColOnMovement = false;
                    set(obj.fcmh.plotRowAndCol,'Checked','off');
                    set(obj.fh,'Pointer',obj.CURSOR_STD);
            end
        end
                
        function togglePlotAlongDim(obj, bool)
            if nargin > 1
                set(obj.fcmh.plotAlongDim,'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.fcmh.plotAlongDim,'Checked')
                case 'off'
                    obj.plotAlongDimOnMovement = true;
                    set(obj.fcmh.plotAlongDim,'Checked','on');
                case 'on'
                    obj.plotAlongDimOnMovement = false;
                    set(obj.fcmh.plotAlongDim,'Checked','off');
            end
        end
        
        function toggleDrawPhaseCircle(obj, bool)
            if nargin > 1
                set(obj.fcmh.drawPhaseCircle,'Checked',arrShow.boolToOnOff(~bool));
            end

            switch get(obj.fcmh.drawPhaseCircle,'Checked')
                case 'off'
                    obj.drawPhaseCircOnMovement = true;
                    set(obj.fcmh.drawPhaseCircle,'Checked','on');
                case 'on'
                    obj.drawPhaseCircOnMovement = false;
                    set(obj.fcmh.drawPhaseCircle,'Checked','off');
                    ud = get(obj.getCurrentAxesHandleCb(),'UserData');
                    if isfield(ud, 'phaseCirc') && any(ishandle(ud.phaseCirc))
                        delete(ud.phaseCirc);
                    end
            end
        end
        
        function toggleCallUserCursorPosFunc(obj, bool)
            if nargin > 1
                set(obj.fcmh.cursorPosCb(),'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.fcmh.cursorPosCb(),'Checked')
                case 'off'
                    obj.callUserCursorPosFunc = true;
                    set(obj.fcmh.cursorPosCb(),'Checked','on');
                case 'on'
                    obj.callUserCursorPosFunc = false;
                    set(obj.fcmh.cursorPosCb(),'Checked','off');
            end
        end
        
        
    end
    
    methods (Access = private)
        function initContextMenus(obj)
            
            % bottom panel
            obj.cmh.base = uicontextmenu;
            obj.cmh.phaseUnit.base = uimenu(obj.cmh.base,'Label','Phase unit...');
            obj.cmh.phaseUnit.deg  = uimenu(obj.cmh.phaseUnit.base,'Label','Degrees'   ,...
                'callback',@(src,evnt)setPhaseUnit(obj,'deg'));
            obj.cmh.phaseUnit.rad  = uimenu(obj.cmh.phaseUnit.base,'Label','Radiants'   ,...
                'callback',@(src,evnt)setPhaseUnit(obj,'rad'));
            obj.cmh.precision  = uimenu(obj.cmh.base,'Label','Change precision'   ,...
                'callback',@(src,evnt)changePrecisionDlg(obj));
            
            % also assign to the parent panel
            set(obj.ph,'uicontextmenu',obj.cmh.base);                                    
            
            % main figure
            uimenu(obj.fcmh.base,'Label','Plot row (-)' ,...
                'callback',@(src,evnt)obj.plotRow);
            uimenu(obj.fcmh.base,'Label','Plot column (|)' ,...
                'callback',@(src,evnt)obj.plotColumn);
            obj.fcmh.plotRowAndCol = uimenu(obj.fcmh.base,'Label','Plot row and column continuously (+)' ,...
                'callback',@(src,evnt)obj.togglePlotRowAndCol);
            
            uimenu(obj.fcmh.base,'Label','Plot along plotDim (v)' ,...
                'callback',@(src,evnt)obj.plotAlongPlotDim,...
                'Separator','on');
            
            obj.fcmh.plotAlongDim = uimenu(obj.fcmh.base,'Label','Plot along plotDim continuously (V)' ,...
                'callback',@(src,evnt)obj.togglePlotAlongDim);
            
            % user cursor position callback
            sub4 = uimenu(obj.fcmh.base,'Label', 'User cursor position Function');
            obj.fcmh.cursorPosCb = uimenu(sub4,'Label', 'Toggle continuous call(C)',...
                'Callback', @(src, event)obj.toggleCallUserCursorPosFunc(),...
                'Checked','off');
            uimenu(sub4,'Label', 'Call once (c)',...
                'Callback', @(src, event) obj.userCursorPosFcn());
            uimenu(sub4,'Label', 'Edit callback',...
                'Callback', @(src, event)eval(['edit ',func2str(obj.userFcn)]));
            
            % send cursor position
            obj.fcmh.toggleSendCursor = uimenu(obj.fcmh.base,'Label', 'Send cursor (X)',...
                'Callback', @(src, event)obj.toggleSend(),...
                'Checked',arrShow.boolToOnOff(obj.sendCursorOnMovement),...
                'Separator','off');
            
            
            
            obj.fcmh.drawPhaseCircle = uimenu(obj.fcmh.base,'Label','Draw phase circle continuously (P)' ,...
                'callback',@(src,evnt)obj.toggleDrawPhaseCircle);
            %             % auto enable phase circle plot
            %             if ~isreal(obj.data.dat)
            %                 obj.toggleDrawPhaseCircle();
            %             end
            
        end
        
        function setValue(obj, handle, value, unit, precision)
            if nargin < 5
                precision = obj.precision;
                if nargin < 4
                    unit = '';
                end
            end
            if ischar(value)
                col = 'black';
            else
                if value < 0
                    col = obj.NEGATIV_COLOR;
                else
                    col = obj.POSITV_COLOR;
                end
                if strcmp(precision,'auto')
                    if abs(log(value)/log(10)) > obj.autoPrecisionLimit
                        precision = '%2.2e';
                    else
                        precision = '%2.3f';
                    end
                end
                
                
                value = num2str(value, precision);
            end
            set(handle, 'String', [value, ' ', unit], 'ForegroundColor', col);
        end
    end
end
