classdef asRoiClass < impoly
    properties (Access = private)
        parentAxesHandle   = 0;     % parent axes handle
        parentImageHandle  = 0;     % parent image handle
        parentFigureHandle = 0;
        
        textHandle            = [];
        textContextMenuHandle = [];        
        precision = '%g';      % standard notation is compact
       
        filterStr = ''      % WARNING: test
        
        guiHandle    = struct('figure','text')   
        cmenuHandle  = struct('sendPosition','ignoreZeros');
        
        sendPositionCallback = [];
        sendPositionCallbackId = [];
        
        fullStrToggle = true;  % show full string or just compact form
    end
    
    properties (Access = public)

    end
    
    methods
        function obj = asRoiClass(parentAxesHandle, roiPos, sendPositionCallback)
            if nargin < 2
                roiPos = [];
                if nargin < 1
                    parentAxesHandle = gca;
                end                
            end
            
            obj     = obj@impoly(parentAxesHandle, roiPos);
            obj.setColor('green')
            obj.parentAxesHandle   = parentAxesHandle;
            obj.parentImageHandle  = findall(get(parentAxesHandle,'Children'),'Type','image');
            obj.parentFigureHandle = get(get(obj.parentAxesHandle,'Parent'),'Parent');
            
            if nargin == 3
                obj.sendPositionCallback = sendPositionCallback;                
            end

            obj.updateImpolyContextMenu;
            obj.createTextContextMenu;
            
%             addNewPositionCallback(obj,@(pos)obj.showRoiGui);
%             obj.showRoiGui;
            addNewPositionCallback(obj,@(pos)obj.updateRoiString);
            obj.updateRoiString;
            


        end
                       
        function roi = getRoiData(obj)
            ud = get(obj.parentAxesHandle,'UserData');
            if isempty(ud)
                refImg = get(obj.parentImageHandle,'CData');
            else
                if isfield(ud,'isComplex') && ud.isComplex
                    refImg = ud.cplxImg;
                else
                    refImg = get(obj.parentImageHandle,'CData');
                end
            end
            mask   = obj.createMask;
            roi    = refImg(mask == 1);
            if obj.getIgnoreZerosToggle
                roi = roi(roi~=0);
            end
            if ~isempty(obj.filterStr)
                eval(['roi = roi(roi',obj.filterStr,');']);
            end
            
        end
        
        function [m, s] = getMeanAndStd(obj)
           roi = obj.getRoiData;
           if ~isempty(roi)
               m = mean(roi);
               s = std(roi);
           else
               m = 0;
               s = 0;
           end
        end
        
        function N = getN(obj)
           roi = obj.getRoiData;
           N = numel(roi);               
        end   
        function mini = getMin(obj)
            mini = min(obj.getRoiData);
        end
        function maxi = getMax(obj)
            maxi = max(obj.getRoiData);
        end
            
        function updateRoiString(obj)
            if obj.fullStrToggle            
                obj.drawFullString;
            else
                obj.drawMeanAndStdString;
            end
        end
        
        function str = getMeanAndStdString(obj)
            [m, s] = obj.getMeanAndStd;           
            str = [num2str(m,obj.precision), ' +- ', num2str(s,obj.precision)];
        end

        function drawMeanAndStdString(obj)
            % writes roi statistics as a text in the image window
            if ~isempty(obj.textHandle)
                delete(obj.textHandle);
            end
            obj.textHandle = text(.015,.99,obj.getMeanAndStdString,'Units','normalized','parent',obj.parentAxesHandle,...
                'Color','green','BackgroundColor','Black',...
                'VerticalAlignment','top',...
                'UIContextMenu',obj.textContextMenuHandle);            
        end

        function drawFullString(obj)
            % writes roi statistics as a text in the image window
            if ~isempty(obj.textHandle)
                delete(obj.textHandle);
            end
            str = strvcat(obj.getMeanAndStdString,num2str(obj.getN),num2str(obj.getMin,obj.precision),num2str(obj.getMax,obj.precision));
            obj.textHandle = text(.015,.98,str,'Units','normalized','parent',obj.parentAxesHandle,...
                'Color','green','BackgroundColor','Black',...
                'VerticalAlignment','top',...
                'UIContextMenu',obj.textContextMenuHandle);            
        end
        
        function h = getTextHandle(obj)
            h = obj.textHandle;
        end
        
        
        function bool = guiIsPresent(obj)
            bool = false;
            if ishandle(obj.guiHandle.figure)
                if strcmp(get(obj.guiHandle.figure,'Tag') ,'roiGui')
                    bool = true;
                end
            end
        end
        
        function showRoiGui(obj)         
            if obj.guiIsPresent
                set(obj.guiHandle.text,'String',obj.getMeanAndStdString);                
            else
                pos = [800, 800, 40, 40];
                str = obj.getMeanAndStdString;
                
                obj.guiHandle.figure = figure('MenuBar','none','Toolbar','none',...
                    'Position',pos, 'Tag', 'roiGui');
                obj.guiHandle.text = uicontrol('Style','Text','String',str,'HorizontalAlignment','left',...
                    'Units','normalized','pos',[0 0 1 1],...
                    'parent',obj.guiHandle.figure,'HandleVisibility','on',...
                    'FontUnits','normalized','FontSize',.35);                
            end           
        end
            
        function delete(obj)
            if obj.guiIsPresent
                close(obj.guiHandle.figure);
            end
            if ~isempty(obj.textHandle) && ishandle(obj.textHandle)
                delete(obj.textHandle);
            end                        
        end
            
        function toggle = getSendPositionToggle(obj)
            switch get(obj.cmenuHandle.sendPosition,'Checked')
                case 'on'
                    toggle = true;
                case 'off'
                    toggle = false;
            end
        end

        function toggle = getIgnoreZerosToggle(obj)
            switch get(obj.cmenuHandle.ignoreZeros,'Checked')
                case 'on'
                    toggle = true;
                case 'off'
                    toggle = false;
            end
        end
        
        function setSendPositionToggle(obj, toggle)
            if nargin < 2
                toggle = ~obj.getSendPositionToggle;
            end
            
            switch toggle
                case 1
                    set(obj.cmenuHandle.sendPosition,'Checked','on');                    
                    obj.sendPositionCallbackId = addNewPositionCallback(obj,obj.sendPositionCallback);                    
                    obj.callSendPositionCallback(); % execute callback once
                case 0
                    set(obj.cmenuHandle.sendPosition,'Checked','off');
                    removeNewPositionCallback(obj,obj.sendPositionCallbackId);                                        
            end
        end
        
        function addFilterString(obj,str)
            % WARNING, INCOMPLETE IMPLEMENTATION
            obj.filterStr = str;
            obj.updateRoiString;
        end
            
        function callSendPositionCallback(obj)
            obj.sendPositionCallback(obj.getPosition);
        end
        
        function setIgnoreZerosToggle(obj, toggle)
            if nargin < 2
                toggle = ~obj.getIgnoreZerosToggle;
            end
            
            switch toggle
                case 1
                    set(obj.cmenuHandle.ignoreZeros,'Checked','on');                    
                case 0
                    set(obj.cmenuHandle.ignoreZeros,'Checked','off');
            end
            obj.updateRoiString;
        end
        
    end
    
    methods (Access = private)
        function updateImpolyContextMenu(obj)
            % add some features to the impoly context menu
            
            cmh = obj.getContextMenu;
            
            uimenu(cmh,'Label','Delete ROI'   ,...
                'callback',@(src,evnt)obj.delete);
            
            uimenu(cmh,'Label','Delete all ROIs'   ,...
                'callback',@(src,evnt)evalin('base','asDeleteAllRois'));            

            if ~isempty(obj.sendPositionCallback)
                obj.cmenuHandle.sendPosition = uimenu(cmh,'Label','Send Position'   ,...
                    'callback',@(src,evnt)obj.setSendPositionToggle);
            end
            
            obj.cmenuHandle.ignoreZeros = uimenu(cmh,'Label','Ignore Zeros'   ,...
                'callback',@(src,evnt)obj.setIgnoreZerosToggle,...
                'Checked','on');
            
        end

        function createTextContextMenu(obj)
            % create a context menu to choose between different notations
            % in the image text 
            
            if isempty(obj.textContextMenuHandle)
                obj.textContextMenuHandle = uicontextmenu('Parent',obj.parentFigureHandle);
                
                uimenu(obj.textContextMenuHandle,'Label','Decimal notation'   ,...
                    'callback',@(src,evnt)obj.setNotation('%d'));
                uimenu(obj.textContextMenuHandle,'Label','Fixed-point notation'   ,...
                    'callback',@(src,evnt)obj.setNotation('%2.2f'));
                uimenu(obj.textContextMenuHandle,'Label','Exponential notation'   ,...
                    'callback',@(src,evnt)obj.setNotation('%2.2e'));
                uimenu(obj.textContextMenuHandle,'Label','Compact exponential notation'   ,...
                    'callback',@(src,evnt)obj.setNotation('%g'));
                
            end                                    
        end
        
        function setNotation(obj, precision)
            obj.precision = precision;
            obj.updateRoiString % update text
        end
                    
    end
end