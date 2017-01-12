%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)



classdef asStatisticsClass < handle
    
    properties (GetAccess = private, SetAccess = private)
    
        pph     = 0;            % parent panel handle
        ph      = 0;            % panel handle
        panPos     = [0 0 1 1]  % panel position
        
        enabled = true;
        isComplex = false;
        
        precision = '%2.4g';
        
        fontSize = 8;
        
        % text handles for 'dynamic text'
        thDim   = 0;
        thMin   = 0;
        thMean  = 0;
        thMax   = 0;
        thNorm  = 0;
        
        % text handles for 'static text'
        sthDim   = 0;
        sthMin   = 0;
        sthMean  = 0;
        sthMax   = 0;
        sthNorm  = 0;
        
        
        % image stats
        imgDim     = 0;
        imgMin     = 0;
        imgMinPos  = [0,0];
        imgMean    = 0;
        imgMax     = 0;
        imgMaxPos  = [0,0];
        imgNorm    = 0;
                
    end
    
    properties(Constant)
        MIN_VALID_RANGE = 1e-6;        
    end
    
    methods
        function obj = asStatisticsClass(parentPanelHandle, panelPosition)
            
            obj.pph    = parentPanelHandle;
            obj.panPos = panelPosition;
            
            % create parent panel
            obj.ph = uipanel('visible','on','Units','normalized',...
                'Position',obj.panPos,'Parent',parentPanelHandle);
            
            % Create static text objects for min, mean and max
            stw = 1/3;   % static textfield width
            th  = 1/5;   % textfield heigth
            obj.sthDim = uicontrol('Style','Text','String','Dim :','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[0 4/5 stw th],'parent',obj.ph,'HandleVisibility','on');
            obj.sthMin = uicontrol('Style','Text','String','Min :','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[0 3/5 stw th],'parent',obj.ph,'HandleVisibility','on');
            obj.sthMean= uicontrol('Style','Text','String','Mean:','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[0 2/5 stw th],'parent',obj.ph,'HandleVisibility','on');
            obj.sthMax = uicontrol('Style','Text','String','Max :','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[0 1/5 stw th],'parent',obj.ph,'HandleVisibility','on');
            obj.sthNorm= uicontrol('Style','Text','String','L2  :','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[0 0   stw th],'parent',obj.ph,'HandleVisibility','on');
            
            % Create editable text objects for min, mean and max
            etw = 1 - stw;  % editable text filed width
            obj.thDim = uicontrol('Style','Text','String','0.0','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[stw 4/5 etw th],'parent',obj.ph,'HandleVisibility','on');
            obj.thMin = uicontrol('Style','Text','String','0.0','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[stw 3/5 etw th],'parent',obj.ph,'HandleVisibility','on');
            obj.thMean= uicontrol('Style','Text','String','0.0','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[stw 2/5 etw th],'parent',obj.ph,'HandleVisibility','on');
            obj.thMax = uicontrol('Style','Text','String','0.0','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[stw 1/5 etw th],'parent',obj.ph,'HandleVisibility','on');
            obj.thNorm= uicontrol('Style','Text','String','0.0','HorizontalAlignment','left','FontSize',obj.fontSize,...
                'Units','normalized','pos',[stw 0   etw th],'parent',obj.ph,'HandleVisibility','on');
            
            
        end
        
        
        
        function range = getImageRange(obj)
            range = str2double(get(obj.thMax,'String')) - str2double(get(obj.thMin,'String'));
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
        
        function setImageStats(obj,refImg)
            obj.isComplex = false;
            if ishandle(refImg)
                axesH = get(refImg,'Parent');                
                refImg = get(refImg,'CData');
                if size(refImg,3) == 3
                    % assume that we are dealing with an rgb array, made from a
                    % complex image.
                    % So get complex image from the axes UserData
                    ud = get(axesH,'UserData');
                    refImg = ud.cplxImg;
                    obj.isComplex = true;
                end
            end

            obj.imgDim = size(refImg);
            refVect = refImg(:);
            obj.imgNorm= norm(refVect,2);
            if obj.isComplex
                % treat real and imaginary part separately
                obj.imgMin = min(real(refVect))  + 1i * min(imag(refVect));
                obj.imgMean= mean(real(refVect)) + 1i * mean(imag(refVect));
                obj.imgMax = max(real(refVect))  + 1i * max(imag(refVect));
                
                % not implementet yet
                obj.imgMinPos = [-1,-1];                
                obj.imgMaxPos = [-1,-1];
                
            else
                obj.imgMin = min (refVect);
                obj.imgMean= mean(refVect);
                obj.imgMax = max (refVect);
                
                % min and max positions
                imgMinInd = find(refVect == obj.imgMin,1,'first');
                imgMaxInd = find(refVect == obj.imgMax,1,'first');
                [py,px]= ind2sub(obj.imgDim,imgMinInd);
                obj.imgMinPos = [py,px];
                [py,px]= ind2sub(obj.imgDim,imgMaxInd);
                obj.imgMaxPos = [py,px];

            end
            obj.updateImageStats();
            
            if obj.getImageRange < obj.MIN_VALID_RANGE
                set(obj.thMin,'ForegroundColor','red');
                set(obj.thMax,'ForegroundColor','red');
            else
                set(obj.thMin,'ForegroundColor','black');
                set(obj.thMax,'ForegroundColor','black');
            end
            clear refVect refImg
        end
        
        function delete(obj)
            if ishandle(obj.ph)
                delete(obj.ph);
            end
            clear obj;
        end
        
        function str = getImageStatsString(obj)
            str = strvcat(...
                ['min  = ', get(obj.thDim ,'String')],...
                ['min  = ', get(obj.thMin ,'String')],...
                ['mean = ', get(obj.thMean,'String')],...
                ['max  = ', get(obj.thMax ,'String')],...
                ['L2   = ', get(obj.thNorm,'String')]);
        end
        
        function str = getImageStatsCellString(obj)
            str = {...
                ['dim  = ', get(obj.thDim ,'String')];...
                ['min  = ', get(obj.thMin ,'String')];...
                ['mean = ', get(obj.thMean,'String')];...
                ['max  = ', get(obj.thMax ,'String')];...
                ['L2   = ', get(obj.thNorm,'String')]};
        end
        
        function stats = getImageStats(obj)
            stats = [ obj.getMin;
                obj.getMean;
                obj.getMax;
                obj.getNorm];
        end
        
        function min = getMin(obj)
            min = obj.imgMin;
        end
        function min = getMean(obj)
            min = obj.imgMean;
        end
        function min = getMax(obj)
            min = obj.imgMax;
        end
        function min = getNorm(obj)
            min = obj.imgNorm;
        end
        function dim = getDimensions(obj)
            dim = obj.imgDim;
        end
    end
    methods (Access = private)
        function updateImageStats(obj)
            obj.setDimStr (num2str(obj.imgDim));
            obj.setNormStr(num2str(obj.imgNorm,obj.precision));
            if obj.isComplex
                obj.setMinStr ('-');
                obj.setMeanStr('-');
                obj.setMaxStr ('-');                
            else
                minStr        = num2str(obj.imgMin, obj.precision);
                minTooltipStr = sprintf('%s @ %d / %d',minStr,obj.imgMinPos(1),obj.imgMinPos(2));
                obj.setMinStr (minStr,minTooltipStr);
                
                obj.setMeanStr(num2str(obj.imgMean,obj.precision));

                maxStr        = num2str(obj.imgMax, obj.precision);
                maxTooltipStr = sprintf('%s @ %d / %d',maxStr,obj.imgMaxPos(1),obj.imgMaxPos(2));
                obj.setMaxStr (maxStr,maxTooltipStr);

            end
        end
        function setDimStr(obj, dim)
            if ~obj.enabled
                obj.enableText();
            end
            if ischar(dim)
                str = dim;
            else
                str = num2str(dim(1));
                for i = 2 : length(dim)
                    str = [str,' x ',num2str(dim(i))];
                end
            end
            set(obj.thDim,'String',str,'TooltipString',str);
            set(obj.sthDim,'TooltipString',str);
        end
        
        function setMinStr(obj,str,toolTipStr)
            if ~obj.enabled
                obj.enableText();
            end
            if nargin < 3
                toolTipStr = str;
            end
            set(obj.thMin,'String',str,'TooltipString',toolTipStr);
            set(obj.sthMin,'TooltipString',toolTipStr);
        end
        
        function setMeanStr(obj,str)
            if ~obj.enabled
                obj.enableText();
            end
            set(obj.thMean,'String',str,'TooltipString',str);
            set(obj.sthMean,'TooltipString',str);
        end
        
        function setMaxStr(obj,str,toolTipStr)
            if ~obj.enabled
                obj.enableText();
            end
            if nargin < 3
                toolTipStr = str;
            end            
            set(obj.thMax,'String',str,'TooltipString',toolTipStr);
            set(obj.sthMax,'TooltipString',toolTipStr);
        end
        
        function setNormStr(obj,str)
            if ~obj.enabled
                obj.enableText();
            end
            set(obj.thNorm,'String',str,'TooltipString',str);
            set(obj.sthNorm,'TooltipString',str);
        end
    end
end
