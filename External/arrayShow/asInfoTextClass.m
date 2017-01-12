%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)

classdef asInfoTextClass < handle
    
    properties (GetAccess = private, SetAccess = private)

        ph       = 0;            % panel handle
        cmh      = 0;            % context menu handle
        
        lwfh     = 0;            % large window figure handle
        lwph     = 0;            % large window panel handle        
        
        text = '';
    end
    
    methods
        function obj = asInfoTextClass(parentPanelHandle, panelPosition)
            

            
            obj.ph = uicontrol('Style','edit',...
                'Parent',parentPanelHandle,...
                'Units','normalized',...
                'Position',panelPosition,...
                'Max',2,...
                'HorizontalAlignment','left',...
                'Visible','off',...
                'callback',@(src,evnt)copyInfoTextCb(obj,src));
            
            function copyInfoTextCb(obj,src)
                obj.text = get(src,'String');
                set(obj.ph,'String',obj.text);
                if ishandle(obj.lwfh)
                    if obj.lwfh ~= 0
                        set(obj.lwph,'String',obj.text);
                    end
                end
                
            end
            
            obj.cmh = uicontextmenu;
            uimenu(obj.cmh,'Label','open large window'   ,...
                'callback',@(src,evnt)obj.openLargeWindow);
            uimenu(obj.cmh,'Label','close large window'   ,...
                'callback',@(src,evnt)obj.closeLargeWindow);
            
            
            set(obj.ph,'uicontextmenu',obj.cmh);
            
        end
        
        function setInfotext(obj, infoText)
            % infoText can be either a string or a struct
            if isstruct(infoText) || isobject(infoText)
                obj.parseStruct(infoText);
            else
                    obj.setString(infoText);
            end
        end
        
        
        function setString(obj, str)
            obj.text = str;
            set(obj.ph,'String',obj.text);
        end
        
        function str = getString(obj)
            str = obj.text;
        end
        
        function setVisible(obj, OnOffStr)
            set(obj.ph,'Visible',OnOffStr);
        end
        
        function OnOffStr = getVisible(obj)
            OnOffStr = get(obj.ph,'Visible');
        end
        
        function openLargeWindow(obj)
            parentFigureHandle = get(get(obj.ph,'Parent'),'Parent');
            parentFigureTitle = get(parentFigureHandle,'name');
            lwTitle = sprintf('asO %d: infoText (%s)',parentFigureHandle,parentFigureTitle);
            obj.lwfh = figure( 'MenuBar','none',...
                'ToolBar','none',...
                'NumberTitle','off',...
                'Name',lwTitle);
                        
            
            obj.lwph = uicontrol('Style','edit',...
                'Parent',obj.lwfh,...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Max',2,...
                'HorizontalAlignment','left',...
                'Visible','on',...
                'String', obj.text,...
                'callback',@(src,evnt)copyInfoTextCb(obj,src));
            
            function copyInfoTextCb(obj,src)
                obj.text = get(src,'String');
                set(obj.ph,'String',obj.text);
            end
            
            
        end
        
        function closeLargeWindow(obj)
            if ishandle(obj.lwfh)
                if obj.lwfh ~= 0
                    delete(obj.lwfh);
                end
            end
        end
        
        function parseStruct(obj, struct)
            if isstruct(struct) || isobject(struct)
                
                names = evalc('disp(struct)');
                names = strread(names,'%s','delimiter','\n');
                          
                txt = [ obj.getString;...
                        {'-- struct: --'};...                
                        names;...
                        {'-end struct-'}];
               
                obj.setString(txt);       
                
                clear struct
            else
                error('first argument has to be a struct');
            end
        end
    end
    
    
    methods (Access = private)
        
        function lwCloseRequest(obj) %large window close request
            % ...doesn't work yet
            figure(get(parentPanelHandle,'Parent'));
            obj.setString(get(obj.lwph,'String'));
            delete(obj.lwfh);
        end
        
    end
    
end
