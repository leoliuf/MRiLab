%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef asWindowingClass < handle
    
    properties (GetAccess = private, SetAccess = private)
        
        ph       = [];        % panel handle
        
        ih    = [];   % image handle
        ah    = [];  % axes handle
        
        isComplex = false;
        complexRef = [];
        
        cntSliderH   = [];      % slider handle
        widthSliderH = [];
        
        sendAbsButtonH = [];    %
        sendRelButtonH = [];    %
        keepAbsButtonH = [];    %
        
        cmh = [];      % context menu handle
        
        cntTextH     = [];      % static-text handle for "C"
        widthTextH   = [];      % ...and "W"
        CWTextH      = [];      % ...and "C/W"
        
        % callbacks
        updFigCb      = [];  %
        apply2allCb  = [];   % send to all relatives callback
        getPhaseColormapCb = [];
        
        
        % center and width
        usePhaseCW = false; % individual windowing settings are stored and
        % restored for phase and for magnitude/real/imag
        % views.
        imageCW   = [0,1];  % these values are set to the current slider
        phaseCW   = [0,360];% values (depending on the usePhaseCW state)
        
        initialRelCW = [.5, 1];
        
        % data properties
        imageMin = 0;
        imageMax = 0;
        imageWidth = 0;
        
        phaseMin = -180;
        phaseMax = 180;
        phaseWidth = 360;
        
        imageDims = [];
        
        % toggle states
        keepRelCW       = false;
        keepAbsCW       = false;
        
        % context menu handles
        keepRelCWctxmH  = [];  % handle to context menu entry for keepRelCw
        keepAbsCWctxmH  = [];
        
        limitsOverwritten = false;
        cntLimits   = 0;
        widthLimits = 0;
        
        
        isInitialized = false;
        isEnabled = true;
        
    end
    
    properties (Constant)
        MIN_VALID_WIDTH = 1e-6;
        
        % background colors for keepAbsoluteCW and keepRelativeCW
        BG_COLOR_REL = get(0,'defaultuicontrolbackgroundcolor');
        BG_COLOR_ABS = [205/255;0;0];         % dark red
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        sendAbsWindow = false;
        sendRelWindow = false;
    end
    
    methods (Access = public)
        function obj = asWindowingClass(...
                parentPanelHandle,...
                panelPosition,...
                updFigCb,...
                apply2allCb,...
                getPhaseColormapCb,...
                sendIcon)
            
            obj.updFigCb    = updFigCb;
            obj.apply2allCb = apply2allCb;
            obj.getPhaseColormapCb = getPhaseColormapCb;
            
            
            % create parent panel
            obj.ph = uipanel('visible','on','Units','normalized',...
                'Position',panelPosition,'Parent',parentPanelHandle);
            
            % create send button
            obj.sendAbsButtonH = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.85,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip','send absolute window to relatives',...
                'Callback',@(src,evnt)obj.toggleSendAbsWindow,...
                'String','A',...
                'fontweight','bold',...
                'ForegroundColor', obj.BG_COLOR_ABS,...
                'CData',sendIcon);
            obj.sendRelButtonH = uicontrol('Style','togglebutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.7,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip','send relative window to relatives',...
                'Callback',@(src,evnt)obj.toggleSendRelWindow,...
                'String','R',...
                'fontweight','bold',...
                'ForegroundColor','blue',...
                'CData',sendIcon);
            obj.keepAbsButtonH = uicontrol('Style','pushbutton',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[.55,.75,.15,.25],...
                'SelectionHighlight','off',...
                'tooltip','keep absolute windowing (A), relative windowing (R) or neither (-)',...
                'Callback',@(src,evnt)absButtonCb(obj),...
                'String','A');
            function absButtonCb(obj)
                switch(get(obj.keepAbsButtonH,'String'))
                    case {'A','-'}
                        % toggle to keepRelativeWindow
                        obj.setKeepRelCW(true);
                    case 'R'
                        % toggle to keepAbsWindow
                        obj.setKeepAbsCW(true);
                end
                % note: disabling both options is only possible via context
                % menu as it's probably rarely helpful
            end
            
            
            % create center and width slider
            obj.cntSliderH = uicontrol('Style','slider',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Tag','cntSlider',...
                'Position',[0,.5,1,.24],...
                'Callback',@(src,evnt)obj.sliderCb());
            
            
            obj.widthSliderH = uicontrol('Style','slider',...
                'Parent', obj.ph,...
                'Units','normalized',...
                'Position',[0,.25,1,.24],...
                'Callback',@(src,evnt)obj.sliderCb());
            
            
            % create static annotation text
            obj.cntTextH = uicontrol('Style','Text',...
                'Parent', obj.ph,...
                'String','C/W',...
                'FontSize',8,...
                'Units','normalized',...
                'HorizontalAlignment','left',...
                'Position',[0,.74,.5,.23]);
            
            % create dynamic text for CW values
            obj.CWTextH = uicontrol('Style','Text',...
                'Parent', obj.ph,...
                'String','',...
                'Units','normalized',...
                'FontSize',8,...
                'HorizontalAlignment','center',...
                'Position',[0.01,0,.98,.2]);
            
            % create context menu
            obj.cmh.base = uicontextmenu;
            
            uimenu(obj.cmh.base,'Label','Input center and width',...
                'callback',@(src,evnt)obj.setCW);
            
            uimenu(obj.cmh.base,'Label','Input min and max',...
                'callback',@(src,evnt)obj.setCLim);
            
            obj.cmh.ovrwrLims = uimenu(obj.cmh.base,'Label','Overwrite slider limits',...
                'callback',@(src,evnt)obj.toggleOverwrideSliderLimits);
            
            uimenu(obj.cmh.base,'Label','Activate immediate slider update',...
                'callback',@(src,evnt)obj.activateImmediateUpdate);
            
            uimenu(obj.cmh.base,'Label','Reset windowing (double click)',...
                'callback',@(src,evnt)obj.resetWindowing);
            
            obj.cmh.keepRelCW = uimenu(obj.cmh.base,'Label','Keep relativ windowing',...
                'callback',@(src,evnt)obj.setKeepRelCW,...
                'Checked','off', 'Separator','on');
            
            obj.cmh.keepAbsCW = uimenu(obj.cmh.base,'Label','Keep absolute windowing',...
                'callback',@(src,evnt)obj.setKeepAbsCW,...
                'Checked','off');
            
            uimenu(obj.cmh.base,'Label','Copy absolute windowing (Strg + c)',...
                'callback',@(src,evnt)obj.copyAbsWindow,...
                'Separator','on');
            
            uimenu(obj.cmh.base,'Label','Paste absolute windowing (Strg + v)',...
                'callback',@(src,evnt)obj.pasteAbsWindow);
            
            uimenu(obj.cmh.base,'Label','Load absolute windowing from txt (Strg + o)',...
                'callback',@(src,evnt)obj.loadAbsWindow);
            
            obj.cmh.sendAbsWindow = uimenu(obj.cmh.base,'Label','Send absolute windowing to all relatives' ,...
                'callback',@(src,evnt)obj.toggleSendAbsWindow,...
                'Separator','on');
            obj.cmh.sendRelWindow = uimenu(obj.cmh.base,'Label','Send relative windowing to all relatives' ,...
                'callback',@(src,evnt)obj.toggleSendRelWindow);
            
            
            set(obj.ph,'uicontextmenu',obj.cmh.base);
            set(obj.cntSliderH,'uicontextmenu',obj.cmh.base);
            set(obj.widthSliderH,'uicontextmenu',obj.cmh.base);
            set(obj.cntTextH,'uicontextmenu',obj.cmh.base);
            set(obj.widthTextH,'uicontextmenu',obj.cmh.base);
            set(obj.CWTextH,'uicontextmenu',obj.cmh.base);
            
        end
        
        function toggleUsePhaseCW(obj,bool)
            if obj.isEnabled
                if nargin < 2
                    obj.usePhaseCW = ~obj.usePhaseCW;
                else
                    obj.usePhaseCW = bool;
                end
            end
        end
        
        function linkToImage(obj,ihandle)
            
            obj.ih = ihandle;
            obj.ah  = get(ihandle,'Parent');
            
            if obj.keepRelCW
                relCW = obj.getRelCW();
            else
                if obj.keepAbsCW
                    absCW = obj.getCW();
                end
            end
            
            % get reference image data
            refImage = get(obj.ih,'CData');
            if size(refImage,3) == 3
                % assume that we are dealing with an rgb array, made from a
                % complex image.
                % So get complex image from the axes UserData
                obj.isComplex = true;
                ud = get(obj.ah,'UserData');
                obj.complexRef = ud.cplxImg;
                refImage = abs(obj.complexRef);
            else
                obj.isComplex = false;
            end
            
            % derive new limits and image properties
            mi = min(min(refImage));
            ma = max(max(refImage));
            wi = ma - mi;
            obj.setMinMaxWidth(mi, ma, wi);
            obj.imageDims   = size(refImage);
            
            if wi > obj.MIN_VALID_WIDTH
                
                if ~obj.limitsOverwritten
                    obj.deriveSliderLimits
                end
                
                % set values to slider objects
                set(obj.cntSliderH,'Min',obj.cntLimits(1),'Max',obj.cntLimits(2),'Value',mi + wi/2);
                set(obj.widthSliderH,'Min',obj.widthLimits(1), 'Max',obj.widthLimits(2), 'Value',wi);
                
                if ~obj.isEnabled
                    obj.enable;
                end
                
                if obj.keepRelCW
                    % set the slider to the previous relative center and width setting
                    obj.setRelCW(relCW); %(this is not allowed, if object was disabled before)
                else
                    if ~obj.keepAbsCW
                        % get current windowing from image class
                        CLim   = get(obj.ah,'CLim');
                        obj.setCLim(CLim);
                    else
                        obj.setCW(absCW);
                    end
                end
                
            else
                obj.disable;
            end
            
            if ~obj.isInitialized
                obj.updateCWtext();
                obj.setKeepRelCW(true);
                obj.isInitialized = true;
            end
        end
        
        function toggleOverwrideSliderLimits(obj)
            if obj.limitsOverwritten
                % if on, set to off
                obj.limitsOverwritten = false;
                set(obj.cmh.ovrwrLims,'checked','off');
                
                % recalculate slider limits
                obj.deriveSliderLimits;
                set(obj.cntSliderH,'Min',obj.cntLimits(1),'Max',obj.cntLimits(2));
                set(obj.widthSliderH,'Min',obj.widthLimits(1), 'Max',obj.widthLimits(2));
                
            else
                % else call overwrite method
                obj.overwriteSliderLimits();
            end
        end
        
        function overwriteSliderLimits(obj, cntLimits, widthLimits)
            % if not given as an argument, get CLim from input dialog
            if nargin < 3
                cntLimits(1) = get(obj.cntSliderH,'Min');
                cntLimits(2) = get(obj.cntSliderH,'Max');
                widthLimits(1) = get(obj.widthSliderH,'Min');
                widthLimits(2) = get(obj.widthSliderH,'Max');
                
                defCntAns = [num2str(cntLimits(1)),' , ',num2str(cntLimits(2))];
                defWidthAns = [num2str(widthLimits(1)),' , ',num2str(widthLimits(2))];
                limStr = inputdlg({'center','width'},'Enter min and max values',1,{defCntAns,defWidthAns});
                if ~isempty(limStr)
                    try
                        [cntLimits(1), cntLimits(2)] = strread(limStr{1},'%f%f','delimiter',',');
                        [widthLimits(1), widthLimits(2)] = strread(limStr{2},'%f%f','delimiter',',');
                    catch err
                        if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                            fprintf('incorrect limits format\n');
                        else
                            rethrow(err);
                        end
                    end
                end
            end
            set(obj.cntSliderH,'Min',cntLimits(1),'Max',cntLimits(2));
            set(obj.widthSliderH,'Min',widthLimits(1), 'Max',widthLimits(2));
            
            
            set(obj.cmh.ovrwrLims,'checked','on');
            obj.limitsOverwritten = true;
            obj.cntLimits = cntLimits;
            obj.widthLimits = widthLimits;
            
        end
        
        function setCLim(obj, CLim)
            if obj.isEnabled
                
                % if not given as an argument, get CLim from input dialog
                if nargin < 2
                    CLim = obj.getCLim;
                    CLimStr = mydlg('Enter window limits','Enter window limits',[num2str(CLim(1)),' , ',num2str(CLim(2))]);
                    if ~isempty(CLimStr)
                        try
                            [CLim(1), CLim(2)] = strread(CLimStr,'%f%f','delimiter',',');
                        catch err
                            if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                                fprintf('incorrect CLim format\n');
                            else
                                rethrow(err);
                            end
                        end
                    end
                end
                
                % derive absolute width and center values
                width  = CLim(2) - CLim(1);
                center = CLim(1) + width/2;
                
                % make sure, that values are within valid range
                center = asWindowingClass.limit(center,get(obj.cntSliderH,'Min'),get(obj.cntSliderH,'Max'));
                width  = asWindowingClass.limit(width ,get(obj.widthSliderH,'Min'),get(obj.widthSliderH,'Max'));
                
                % set to slider
                set(obj.cntSliderH,'Value',center);
                set(obj.widthSliderH,'Value',width);
                obj.backupSliderValues();
                
                % derive relative axes limits
                CLim(1)  = center - width/2;
                CLim(2)  = CLim(1) + width;
                
                if obj.isComplex
                    rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                    set(obj.ih,'CData',rgbImg);
                else
                    % set limits to axes
                    set(obj.ah,'CLim',CLim);
                end
            end
        end
        
        function CW = getCW(obj)
            % get center and width
            if obj.usePhaseCW
                CW = obj.phaseCW;
            else
                CW = obj.imageCW;
            end
        end
        
        function relCW = getRelCW(obj)
            if obj.isEnabled
                CW = obj.getCW;
                [mi, ~, wi] = obj.getMinMaxWidth;
                
                % get center and width setting, relative to image width
                relCW(1) = double((CW(1) - mi )/ wi);
                relCW(2) = double(CW(2) / wi);
                
            else
                relCW = obj.initialRelCW;
            end
        end
        
        function activateImmediateUpdate(obj)
            % dirty way of creating a valueAdjustment- java callback
            hJScrollBar = findjobj('depth',15,'nomenu','Class','Slider');
            hJScrollBar(1).AdjustmentValueChangedCallback = @(src, evnt)obj.sliderCb;
            hJScrollBar(2).AdjustmentValueChangedCallback = @(src, evnt)obj.sliderCb;
            clear('hJScrollBar');
        end
        
        function setCW(obj, CW, adaptLimits, apply2relatives)
            if obj.isEnabled
                if nargin < 4
                    apply2relatives = obj.sendAbsWindow || obj.sendRelWindow;
                    if nargin < 3
                        adaptLimits = true;
                    end
                end
                
                % if not given as an argument, get CW from input dialog
                if nargin < 2
                    CW = obj.getCW;
                    CWStr = mydlg('Enter window center and width','Enter window center and width',[num2str(CW(1)),' , ',num2str(CW(2))]);
                    if ~isempty(CWStr)
                        try
                            [CW(1), CW(2)] = strread(CWStr,'%f%f','delimiter',',');
                        catch err
                            if strcmp(err.identifier,'MATLAB:dataread:TroubleReading')
                                fprintf('incorrect CLim format\n');
                            else
                                rethrow(err);
                            end
                        end
                    end
                end
                
                
                % set center and width
                center = CW(1);
                width  = CW(2);
                
                if adaptLimits
                    % adapt slider limits
                    if center < get(obj.cntSliderH,'Min')
                        set(obj.cntSliderH,'Min',center);
                    else
                        if center > get(obj.cntSliderH,'Max')
                            set(obj.cntSliderH,'Max',center);
                        end
                    end
                    
                    if width < get(obj.widthSliderH,'Min')
                        set(obj.widthSliderH,'Min',width);
                    else
                        if width > get(obj.widthSliderH,'Max')
                            set(obj.widthSliderH,'Max',width);
                        end
                    end
                    
                else
                    % make sure, that values are within valid range
                    center = asWindowingClass.limit(center,get(obj.cntSliderH,'Min'),get(obj.cntSliderH,'Max'));
                    width  = asWindowingClass.limit(width ,get(obj.widthSliderH,'Min'),get(obj.widthSliderH,'Max'));
                end
                
                % set to slider
                set(obj.cntSliderH,'Value',center);
                set(obj.widthSliderH,'Value',width);
                obj.backupSliderValues();
                
                % derive axes limits
                CLim(1)  = center - width/2;
                CLim(2)  = CLim(1) + width;
                
                if obj.isComplex
                    rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                    set(obj.ih,'CData',rgbImg);
                else
                    % set limits to axes
                    set(obj.ah,'CLim',CLim);
                end
                
                % update CW text
                obj.updateCWtext();
                
                if apply2relatives
                    if obj.sendAbsWindow
                        obj.apply2allCb('window.setCW',false, CW, adaptLimits,false);
                    else if obj.sendRelWindow
                            relCW = obj.getRelCW;
                            obj.apply2allCb('window.setRelCW', false, relCW, adaptLimits, false);
                        end
                    end
                end
            end
        end
        
        function setRelCW(obj, relCW, adaptLimits, apply2relatives)
            if obj.isEnabled
                if nargin < 4
                    apply2relatives = obj.sendRelWindow;
                    if nargin < 3
                        adaptLimits = true;
                    end
                end
                [mi, ~, wi] = obj.getMinMaxWidth;
                CW = relCW * wi;
                CW(1) = CW(1) + mi;
                obj.setCW(CW, adaptLimits, apply2relatives);
                obj.updateCWtext();
            end
        end
        
        
        function copyAbsWindow(obj)
            clipboard('copy',num2str(obj.getCW));
            fprintf('Copied center and width to clipboard\n');
        end
        
        function pasteAbsWindow(obj)
            pastedCW = str2num(clipboard('paste'));
            if ~isempty(pastedCW)
                if ~any(size(pastedCW) ~= [1,2])
                    obj.setCW(pastedCW);
                    obj.updFigCb();
                    return
                end
            end
            fprintf('No valid center/width information in clipboard\n');
        end
        
        function loadAbsWindow(obj, file)
            if nargin < 2
                [fname, fpath] = uigetfile('*.txt');
                file = [fpath, fname];
            end
            
            if isempty(file) || isnumeric(file)
                return
            else
                % read file
                fid  = fopen(file,'r');
                str = fread(fid,'char=>char');
                fclose(fid);
                
                % find CW strung
                strIdentifier = 'center/width = [';
                pos = strfind(str',strIdentifier);
                if isempty(pos)
                    fprintf('No valid center/width information in clipboard\n');
                    return;
                else
                    pos = pos + length(strIdentifier);
                    [C, W] = strread(str(pos:end),'%f %f',1);
                    obj.setCW([C,W]);
                end
            end
        end
        
        function CLim = getCLim(obj)
            % get current absolute windowing
            CLim   = get(obj.ah,'CLim');
        end
        
        function ah = getAxesHandle(obj)
            ah = obj.ah;
        end
        
        function ih = getImageHandle(obj)
            ih = obj.ih;
        end
        
        function dims = getImageDims(obj)
            dims = obj.imageDims;
        end
        
        function width = getDataWidth(obj)
            if obj.usePhaseCW
                width = obj.phaseWidth;
            else
                width = obj.imageWidth;
            end
        end
        
        function resetWindowing(obj, apply2relatives)
            
            if nargin < 2
                apply2relatives = obj.sendAbsWindow || obj.sendRelWindow;
            end
            
            if obj.isEnabled
                [mi, ma, wi] = obj.getMinMaxWidth;
                CLim = [mi,ma];
                if obj.isComplex
                    rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                    set(obj.ih,'CData',rgbImg);
                else
                    set(obj.ah,'CLim',CLim);
                end
                set(obj.cntSliderH,'Value',mi + wi/2);
                set(obj.widthSliderH,'Value',wi);
                obj.backupSliderValues();
                obj.updateCWtext();
                if apply2relatives
                    obj.apply2allCb('window.resetWindowing',false,false);
                end
            end
        end
        
        function setKeepRelCW(obj,bool)
            if nargin < 2
                obj.keepRelCW = ~obj.keepRelCW;
            else
                obj.keepRelCW = bool;
            end
            
            switch obj.keepRelCW
                case true
                    set(obj.cmh.keepRelCW,'Checked','on');
                    set(obj.keepAbsButtonH,'String','R','BackgroundColor',obj.BG_COLOR_REL);
                    
                    set(obj.cmh.keepAbsCW,'Checked','off'); %disable concurring option
                    obj.keepAbsCW = false;
                case false
                    set(obj.cmh.keepRelCW,'Checked','off');
                    if(~obj.keepAbsCW)
                        % if neither option is set, draw a '-' in
                        % pushbutton
                        set(obj.keepAbsButtonH,'String','-',...
                            'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                    end
            end
            
        end
        
        function setKeepAbsCW(obj,bool)
            if nargin < 2
                obj.keepAbsCW = ~obj.keepAbsCW;
            else
                obj.keepAbsCW = bool;
            end
            
            switch obj.keepAbsCW
                case true
                    set(obj.cmh.keepAbsCW,'Checked','on');
                    set(obj.keepAbsButtonH,'String','A','BackgroundColor',obj.BG_COLOR_ABS);
                    
                    set(obj.cmh.keepRelCW,'Checked','off'); %disable concurring option
                    obj.keepRelCW = false;
                case false
                    set(obj.cmh.keepAbsCW,'Checked','off');
                    if(~obj.keepRelCW)
                        % if neither option is set, draw a '-' in
                        % pushbutton
                        set(obj.keepAbsButtonH,'String','-',...
                            'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
                    end
            end
            
            
        end
        
        
        function disable(obj)
            set(obj.cntSliderH,'Enable', 'off');
            set(obj.widthSliderH,'Enable', 'off');
            set(obj.cntTextH,'Enable', 'off');
            set(obj.widthTextH,'Enable', 'off');
            set(obj.CWTextH,'Enable', 'off');
            obj.isEnabled = false;
        end
        
        function enable(obj)
            set(obj.cntSliderH,'Enable', 'on');
            set(obj.widthSliderH,'Enable', 'on');
            set(obj.cntTextH,'Enable', 'on');
            set(obj.widthTextH,'Enable', 'on');
            set(obj.CWTextH,'Enable', 'on');
            obj.isEnabled = true;
        end
        
        function bool = getIsEnabled(obj)
            bool = obj.isEnabled;
        end
        
        
        
        % ----
        
        function sendAbsWindowToRelatives(obj)
            obj.apply2allCb('window.setCW',false,obj.getCW(),true,false);
        end
        
        function sendRelWindowToRelatives(obj)
            relCW = obj.getRelCW();
            obj.apply2allCb('window.setRelCW',false,relCW,true,false);
        end
        
        function toggleSendAbsWindow(obj,bool)
            if nargin > 1
                set(obj.cmh.sendAbsWindow,'Checked',arrShow.boolToOnOff(~bool));
            end
            switch get(obj.cmh.sendAbsWindow,'Checked')
                case 'off'
                    obj.sendAbsWindow = true;
                    set(obj.cmh.sendAbsWindow,'Checked','on');
                    set(obj.sendAbsButtonH,'value',1);
                    
                    % assure concurring option is disabled
                    set(obj.cmh.sendRelWindow,'Checked','off');
                    set(obj.sendRelButtonH,'value',0);
                    obj.sendRelWindow = false;
                    
                    obj.sendAbsWindowToRelatives();
                case 'on'
                    obj.sendAbsWindow = false;
                    set(obj.cmh.sendAbsWindow,'Checked','off');
                    set(obj.sendAbsButtonH,'value',0);
            end
        end
        
        function toggleSendRelWindow(obj,bool)
            if nargin > 1
                set(obj.cmh.sendRelWindow,'Checked',arrShow.boolToOnOff(~bool));
            end
            switch get(obj.cmh.sendRelWindow,'Checked')
                case 'off'
                    obj.sendRelWindow = true;
                    set(obj.cmh.sendRelWindow,'Checked','on');
                    set(obj.sendRelButtonH,'value',1);
                    
                    % assure concurring option is disabled
                    set(obj.cmh.sendAbsWindow,'Checked','off');
                    obj.sendAbsWindow = false;
                    set(obj.sendAbsButtonH,'value',0);
                    
                    obj.sendRelWindowToRelatives();
                    
                case 'on'
                    obj.sendRelWindow = false;
                    set(obj.cmh.sendRelWindow,'Checked','off');
                    set(obj.sendRelButtonH,'value',0);
            end
        end
        
        
        % ----
    end
    
    
    
    
    methods (Access = private)
        
        function [mi, ma, wi] = getMinMaxWidth(obj)
            if obj.usePhaseCW
                mi = obj.phaseMin;
                ma = obj.phaseMax;
                wi = obj.phaseWidth;
            else
                mi = obj.imageMin;
                ma = obj.imageMax;
                wi = obj.imageWidth;
            end
        end
        function setMinMaxWidth(obj, mi, ma, wi)
            if obj.usePhaseCW
                obj.phaseMax = ma;
                obj.phaseMin = mi;
                obj.phaseWidth  = wi;
            else
                obj.imageMax = ma;
                obj.imageMin = mi;
                obj.imageWidth  = wi;
            end
        end
        
        function updateCWtext(obj)
            if obj.isEnabled
                CW = obj.getCW;
                if CW > 10000
                    format = '%6.1e';
                else
                    if  CW < 10
                        format = '%1.2f';
                    else
                        format = '%6.0f';
                    end
                end
                CWstr = [num2str(CW(1),format) , ' / ' , num2str(CW(2),format) ];
                set(obj.CWTextH, 'String', CWstr);
            end
        end
        
        function sliderCb(obj)
            % get slider values
            currCenter = get(obj.cntSliderH,'Value');
            currWidth  = get(obj.widthSliderH,'Value');
            
            % store
            obj.backupSliderValues;
            
            % derive relative axes limits
            CLim(1)  = currCenter - currWidth/2;
            CLim(2)  = CLim(1) + currWidth;
            
            % set limits to axes
            if obj.isComplex
                rgbImg = complex2rgb(obj.complexRef,256,CLim, obj.getPhaseColormapCb());
                set(obj.ih,'CData',rgbImg);
            else
                % set limits to axes
                set(obj.ah,'CLim',CLim);
            end
            
            obj.updateCWtext();
        end
        
        function deriveSliderLimits(obj)
            % derive standard limits for the slider
            [mi, ma, wi] = obj.getMinMaxWidth;
            
            if mi < 0
                obj.cntLimits(1) = 2 * mi;
            else
                obj.cntLimits(1) = .1 * mi;
            end
            if ma > 0
                obj.cntLimits(2) = 2* ma;
            else
                obj.cntLimits(2) = .1 * ma;
            end
            
            obj.widthLimits(1) = wi/200;
            obj.widthLimits(2) = 4 * wi;
        end
        
        function backupSliderValues(obj)
            CW = [0,0];
            CW(1) = get(obj.cntSliderH,'Value');
            CW(2) = get(obj.widthSliderH,'Value');
            if obj.usePhaseCW
                obj.phaseCW = CW;
            else
                obj.imageCW = CW;
            end
        end
    end
    
    methods (Static)
        function val = limit(val,min,max)
            if val > max
                val = max;
            else
                if val < min
                    val = min;
                end
            end
        end
    end
end
