%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)



classdef asValueChangerClass < handle
    
    properties (GetAccess = private, SetAccess = private)
        
        pos = [0 0 .6 1.6]; % standard position
        % [left bottom width height]
        
        % handles
        fh      = 0;     % parent figure handle
        ph      = 0;     % panel handle
        pbh_up  = 0;     % pushbutton handle 'up'
        pbh_down= 0;     % pushbutton handle 'down'
        eth     = 0;     % edit text handle
        pbh_dim = 0;     % pushbutton handle 'dim'
        cmh     = 0;     % context menu handle
        flipCmh = 0;     % flip context menu handle
        lockCmh = 0;     % lock context menu handle
        plotTagCmh=0;    % plot dimension context menu handle
        
        userCb   = '';   % user definde Callback
        id       = 0;    % optional user defined id
        kpf      = '';   % user def keyPressFunction
        
        colonDimTag = 0;  % can be 1, 2 or 0 (deaktivated)
        
        colonDim1Callback = [];
        colonDim2Callback = [];
        plotDimCallback   = [];
        
        stdTextColor     = 'black';
        
        %         tag0Color = [0.8314;0.8157;0.7843];
        tag0Color = 'black'
        %         tag1Color = [102/255;204/255;153/255];
        tag1Color = 'blue';
        tag2Color = [205/255;0;0];
        plotDimColor = 'white';
        
        considerColon = true;
        enabled = true;
        
        str = '1';   % copy of the string in obj.eth
        
        min     = 1;     % string minimum
        max     = 99;    % standard maximum;
        
        data      = [];    % asDataClass object
    end
    properties (GetAccess = public, SetAccess = private)
        colonStr = ':';
    end
    
    methods
        
        function obj = asValueChangerClass(parent_fh, varargin)
            obj.fh = parent_fh;
            
            % evaluate varagin
            if nargin > 1
                for i=1:floor(length(varargin)/2)
                    option=varargin{i*2-1};
                    option_value=varargin{i*2};
                    switch lower(option)
                        case 'position'
                            obj.pos = option_value;
                        case 'min'
                            obj.min = option_value;
                        case 'max'
                            obj.max = option_value;
                        case 'id'
                            obj.id = option_value;
                        case 'callback'
                            obj.userCb = option_value;
                        case 'keypressfcn'
                            obj.kpf = option_value;
                        case 'considercolon'
                            obj.considerColon = option_value;
                        case 'initstring'
                            obj.str = option_value;
                        case 'contextmenu'
                            obj.cmh = option_value;
                        case 'colondim1callback'
                            obj.colonDim1Callback = option_value;
                        case 'colondim2callback'
                            obj.colonDim2Callback = option_value;
                        case 'plotdimcallback'
                            obj.plotDimCallback = option_value;
                        case 'colondimtag'
                            obj.colonDimTag = option_value;
                        case 'dataobject'
                            obj.data = option_value;
                        otherwise
                            warning('asValueChangerClass:unknownOption',...
                                'unknown option [%s]!\n',option);
                    end
                end
            end
            
            
            % assure init string to be within range
            obj.str = obj.validateStr(obj.str);
            
            % parent panel
            obj.ph       = uipanel(obj.fh,'Units','centimeters', ...
                'Position',obj.pos);
            
            
            % + button
            obj.pbh_up   = uicontrol(obj.ph,'Style','pushbutton','String','+',...
                'Units','normalized',...
                'Position',[0 3/4 1 1/4 ],...
                'KeyPressFcn',@(src, evnt)obj.keyPressCb(src, evnt),...
                'Callback', @(src, evnt)obj.up() );
            
            % text edit field
            obj.eth      = uicontrol(obj.ph,'Style','edit','String',obj.str,...
                'Units','normalized',...
                'Position',[0 2/4 1 1/4],...
                'KeyPressFcn',@(src, evnt)obj.keyPressCb(src, evnt),...
                'Callback',@(src,evnt)obj.cb,...
                'String',obj.str,...
                'ForegroundColor',obj.stdTextColor,...
                'TooltipString',obj.str);
            
            
            % colon dimension button
            vCorr = 0;
            obj.pbh_dim  = uicontrol(obj.ph,'Style','pushbutton','String',obj.str,...
                'Units','normalized',...
                'Position',[0 0/4-vCorr 1 1/4],...
                'String',obj.max,...
                'TooltipString',num2str(obj.max),...
                'callback',@(src,evnt)obj.setColonDimTag(1),...
                'ButtonDownFcn', @(src,evnt)obj.setColonDimTag(2));
            
            
            switch obj.colonDimTag
                case 1
                    set(obj.pbh_dim,'ForegroundColor',obj.tag1Color);
                case 2
                    set(obj.pbh_dim,'ForegroundColor',obj.tag2Color);
            end
            
            % - button
            obj.pbh_down = uicontrol(obj.ph,'Style','pushbutton','String','-',...
                'Units','normalized',...
                'Position',[0 1/4 1 1/4],...
                'KeyPressFcn',@(src, evnt)obj.keyPressCb(src, evnt),...
                'Callback', @(src, evnt)obj.down() );
            
            
            % context menu
            if ~isempty(obj.cmh)
                obj.cmh = copyobj(obj.cmh,gcf);
                obj.plotTagCmh = uimenu(obj.cmh,'Label','Set as plot dim'   ,...
                    'callback',@(src,evnt)obj.plotDimCallback(obj.id),...
                    'Position',1);
                obj.lockCmh = uimenu(obj.cmh,'Label','Lock'   ,...
                    'callback',@(src,evnt)lockCb(obj),...
                    'Position',2);
                
                % navigation
                uimenu(obj.cmh,'Label','Set to ''1'' (page up)'   ,...
                    'callback',@(src,evnt)obj.setStr('1',true),...
                    'Position',3,...
                    'Separator','on');                
                uimenu(obj.cmh,'Label','Set to ''end'' (page up)'   ,...
                    'callback',@(src,evnt)obj.setStr('end',true),...
                    'Position',4);                
                
                
                obj.flipCmh = uimenu(obj.cmh,'Label','Flip subscripts'   ,...
                    'callback',@(src,evnt)obj.flipsubs(),...
                    'Position',5);
                
                % destructive operations
                uimenu(obj.cmh,'Label',['Flip dimension ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.flipDim(obj.id),...
                    'Position',6);
                uimenu(obj.cmh,'Label',['Sum of squares dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.sumSqr(obj.id),...
                    'Position',7);
                uimenu(obj.cmh,'Label',['max dim ', num2str(obj.id),' (destructive)'] ,...
                    'callback',@(src,evnt)obj.data.max(obj.id),...
                    'Position',8);
                
                
                set(obj.pbh_up,'uicontextmenu',obj.cmh);
                set(obj.pbh_down,'uicontextmenu',obj.cmh);
                set(obj.eth,'uicontextmenu',obj.cmh);
            end
            
            % lock context menu callback
            function lockCb(obj)
                onOffState = get(obj.lockCmh,'Label');
                switch onOffState
                    case 'Lock'                    
                        % change context menu entry label to "Unlock"
                        set(obj.lockCmh,'Label','Unlock')
                        
                        % disable value changer
                        obj.enable(false);
                        
                        %...but re-enable the lock button in the context
                        %menu
%                         set(obj.cmh,'Visible','on');
                        set(obj.lockCmh,'Visible','on');
                    
                    case 'Unlock'
                        % change context menu entry label to "Lock"
                        set(obj.lockCmh,'Label','Lock')
                        
                        % (re-) enable value changer
                        obj.enable(true);
                        
                    otherwise
                        %nop
                end
            end
            
            
        end
        
        function up(obj)
            if obj.enabled
                num = obj.str2validNum(get(obj.eth,'String'));
                obj.setStrForce(num2str(obj.str2validNum(num + 1)));
                obj.runUserCb;
            end
        end
        
        function down(obj)
            if obj.enabled
                num = obj.str2validNum(get(obj.eth,'String'));
                obj.setStrForce(num2str(obj.str2validNum(num - 1)));
                obj.runUserCb;
            end
        end
        
        function setColonDimTag(obj, tag, suppressCallback)
            % colon dimension tag marks value changer dimension as one of the image
            % axis dimensions. A colon dimension does not change it's value on 'up' and 'down' method calls.
            % Valid tags are:
            %   0 : dimension is NOT a colon dimension
            %   1 : dimendion is colon dimension 1
            %   2 : dimendion is colon dimension 2
            
            if obj.enabled
                if nargin < 3
                    suppressCallback = false;
                end
                if obj.colonDimTag == tag
                    if tag ~= 0
                        obj.setColonDimTag(0);
                    end
                else
                    
                    obj.colonDimTag = tag;
                    switch tag
                        case 1
                            set(obj.pbh_dim,'ForegroundColor',obj.tag1Color);
                            obj.colonDim1Callback(obj.id);
                            obj.setStrForce(obj.colonStr);
                        case 2
                            set(obj.pbh_dim,'ForegroundColor',obj.tag2Color);
                            obj.colonDim2Callback(obj.id);
                            obj.setStrForce(obj.colonStr);
                        case 0
                            set(obj.pbh_dim,'ForegroundColor',obj.tag0Color);
                            if strcmp(obj.getStr,obj.colonStr)
                                obj.setStrForce(num2str(ceil(obj.max/2)));
                            end
                        otherwise
                            disp('invalid tag number');
                    end
                    
                    if ~suppressCallback
                        obj.runUserCb;
                    end
                end
            end
        end
        
        function setPlotDimTag(obj, value)
            switch value
                case true
                    set(obj.plotTagCmh,'checked','on');
                    %                     set(obj.eth,'ForegroundColor',obj.stdTextColor)
                    set(obj.pbh_dim,'BackgroundColor',obj.plotDimColor)
                case false
                    set(obj.plotTagCmh,'checked','off');
                    %                     set(obj.eth,'ForegroundColor',obj.stdTextColor)
                    set(obj.pbh_dim,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'))
            end
        end
        
        function tag = getPlotDimTag(obj)
            switch(get(obj.plotTagCmh,'checked'))
                case 'on'
                    tag = true;
                case 'off'
                    tag = false;
            end
        end
        
        function id = getId(obj)
            id = obj.id;
        end
        
        function tag = getColonDimTag(obj)
            tag = obj.colonDimTag;
        end
        
        function str = getStr(obj)
            str = obj.str;
        end
        
        function setStr(obj, str, runCallback)            
            if obj.enabled
                vStr = obj.validateStr(str);
                if obj.getColonDimTag && ~strcmp(vStr,obj.colonStr)
                    obj.setColonDimTag(0,true);
                end                
                obj.setStrForce(vStr);
                if nargin > 2 && runCallback == true
                    obj.runUserCb();
                end
            end
        end
        
        function pos = getPos(obj)
            pos = obj.pos;
        end
        
        function ph = getPanelH(obj)
            ph = obj.ph;
        end
        
        function flipsubs(obj, suppressCallback)
            if obj.enabled
                if nargin < 2
                    suppressCallback = false;
                end
                flipToggle = ~obj.getFlipToggle;
                if(flipToggle)
                    obj.colonStr = 'end:-1:1';
                    set(obj.flipCmh,'Checked','on');
                else
                    obj.colonStr = ':';
                    set(obj.flipCmh,'Checked','off');
                end
                if obj.colonDimTag > 0
                    obj.setStrForce(obj.colonStr);
                    if ~suppressCallback
                        obj.runUserCb;
                    end
                end
            end
        end
        
        function select(obj)
            if obj.enabled
                % focus the edit text uicontrol
                uicontrol(obj.eth);
            end
        end
        
        function toggle = getFlipToggle(obj)
            toggle = false;
            tstr = get(obj.flipCmh,'Checked');
            if strcmp(tstr,'on')
                toggle = true;
            end
        end
        
        function bool = isSelected(obj)
            bool = false;
            selectedUihandle = get(get(obj.fh,'Parent'),'CurrentObject');
            if selectedUihandle == obj.eth
                bool = true;
            end
        end
        
        function enable(obj, state)
            obj.enabled = state;
            onOff = arrShow.boolToOnOff(state);
            set(obj.pbh_up,'Enable',onOff);
            set(obj.pbh_down,'Enable',onOff);
            set(obj.eth,'Enable',onOff);
            %             set(obj.eth,'BackgroundColor',get(0,'defaultuicontrolbackgroundcolor'));
            set(obj.pbh_dim,'Enable',onOff);
%             set(obj.cmh,'Visible',onOff);
            set(get(obj.cmh,'Children'),'Visible',onOff);               
        end
        
        function delete(obj)
            if ishandle(obj.ph)
                delete(obj.ph);
            end
        end
    end
    
    methods (Access = private)
        
        function setStrForce(obj, str)
            % sets string without validity check
            obj.str = str;
            set(obj.eth,'String',obj.str);
            set(obj.eth,'TooltipString',obj.str);
            
        end
        
        function runUserCb(obj)
            if ~isempty(obj.userCb)
                cb = obj.userCb;
                cb(obj.id);
            end
        end
        
        function vStr = validateStr(obj,str)
            
            % check if the string contains 'cnt' (center)
            cntPos = findstr(str,'cnt');
            if cntPos > 0
                % replace 'cnt' by max/2
                str1 = str(1:cntPos-1);
                str2 = str(cntPos+3:end);
                str = [str1, num2str(floor(obj.max/2)),str2];
            end
            
            % check if the string contains 'end'
            endPos = findstr(str,'end');
            if endPos > 0
                % replace 'end' by max
                str1 = str(1:endPos-1);
                str2 = str(endPos+3:end);
                str = [str1, num2str(obj.max),str2];
            end
            
            
            % check if the string contains '/'
            slPos = findstr(str,'/');
            if slPos > 0
                
                %take string after the slash as divisor
                divi = -1;
                try
                    divi = str2double(str(slPos + 1 : end));
                catch me
                    fprintf('invalid string format\n');
                end
                
                if divi > 0
                    inBlock = ceil(obj.max / divi);
                    outBlock = floor((obj.max - inBlock) / 2);
                    vStr = [num2str(outBlock + 1),':',num2str(outBlock + inBlock)];
                else
                    vStr = num2str(obj.str2validNum(str));
                end
                return;
            end
            
            
            
            % check if the string contains a colon
            colPos = findstr(str,':');
            
            if length(colPos) > 1 % we have more than one colon in the string
                
                % no proper check implemented yet... so drop a warning if
                % this is a colon dimension
                if obj.colonDimTag > 0
                    warning('asValueChangerClass:validateString',...
                        'multiple colons in selection string might result in wrong interpretation of the cursor position');
                end
                vStr = str;
                
                
            else    % we have one or no colon in the string
                
                %                 if colPos == 0
                if isempty(colPos)
                    % we have no colon at all...
                    vStr = num2str(obj.str2validNum(str));
                    
                    
                else % we have 1 colon
                    
                    if colPos == 1 && length(str) == colPos(1)
                        % if there's no number in front or behind the colon,
                        %   just return one colon.
                        vStr = ':';
                        
                    else
                        if colPos > 1
                            % devide string in substrings before and after the
                            % colon
                            str1 = str(   1        : colPos - 1);
                            str2 = str( colPos + 1 : end       );
                            
                            num1 = obj.str2validNum(str1);
                            
                            num2 = obj.str2validNum(str2);
                            if num1 < num2
                                vStr = strcat(num2str(num1), ':', num2str(num2));
                            else
                                vStr = num2str(num1);
                            end
                        end
                    end
                    
                end
            end
            
            
        end
        
        function nr = str2validNum(obj, value)
            % check, if the value is a number
            if isnumeric(value)
                nr = value;
            else
                % try to extract a valid number from string
                nr = str2num(value);
                if isempty(nr) || length(nr) > 1
                    % if the conversion fails, return the object's minimum number
                    nr = obj.min;
                    return
                end
                
            end
            
            % check, if the number is within object's validity range...
            % If not, return the limits respectively
            if nr > obj.max
                nr = obj.max;
            else
                if nr < obj.min;
                    nr = obj.min;
                end
            end
        end
        
        function cb(obj)
            % standard callback for the editText uiobject
            obj.setStrForce(obj.validateStr(get(obj.eth,'String')));
            obj.runUserCb;
        end
        
        function keyPressCb(obj,src, evnt)
            
            switch evnt.Key
                case 'uparrow'
                    obj.up;
                case 'add'
                    obj.up;
                case 'subtract'
                    obj.down;
                case 'downarrow'
                    obj.down;
                case 'pageup'
                    obj.setStrForce(num2str(obj.min));
                    obj.runUserCb;
                case 'pagedown'
                    obj.setStrForce(num2str(obj.max));
                    obj.runUserCb;
            end
            
            if ~isempty(obj.kpf) % execute user defined keyPressCallback
                fun = obj.kpf;
                fun(src, evnt);
            end
        end
        
    end
    
end