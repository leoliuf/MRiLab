%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef asImageTextClass < handle
    properties (Access = private)
        parentAxesHandle   = 0;     % parent axes handle
        parentFigureHandle = 0;
        
        
        textHandle            = [];        
        textContextMenuHandle = [];
        textColor   = 'white';
        textBgColor = 'black';

        autoWrapText = true;
        
        cmenuHandle  = struct();     
        ImageTextCell = {};
        ImageTextCellSize = [];
    end
    
    properties (Access = protected)
        string = [];
    end
    
    properties (Access = public)

    end
    
    methods
        function obj = asImageTextClass(parentAxesHandle, str)
            if nargin < 2
                str = '';
                if nargin < 1
                    parentAxesHandle = gca;
                end
            end
            
            obj.parentAxesHandle   = parentAxesHandle;            
            obj.parentFigureHandle = get(get(obj.parentAxesHandle,'Parent'),'Parent');            
            obj.createTextContextMenu();
            
            if iscell(str)
                obj.parseCellArray(str)
            else
                obj.string = str;
            end

        end
                       
        function setString(obj, str, dimSelector)
            if nargin < 3
                if ~isempty(obj.textHandle) && ishandle(obj.textHandle)
                    delete(obj.textHandle);
                end
                if isempty(str)
                    str='';
                end
                
                obj.string = str;
                obj.textHandle = text(.01,.01,str,'Units','normalized','parent',obj.parentAxesHandle,...
                    'Color',obj.textColor,'BackgroundColor',obj.textBgColor,...
                    'VerticalAlignment','bottom',...
                    'interpreter','none',...
                    'UIContextMenu',obj.textContextMenuHandle);       
                if obj.autoWrapText
                    obj.wrapText;
                end
            else
                if ~isempty(obj.ImageTextCell)       % check if the cell array is not empty
                    if ~isempty(obj.textHandle) && ishandle(obj.textHandle)
                        delete(obj.textHandle);
                    end
                    if length(dimSelector) == ndims(obj.ImageTextCell)          % check if the dimensions fit, if not set str='';
                        for j=1:1:length(dimSelector)
                            numdimSel(j)=str2num(dimSelector{j});
                        end
                        if numdimSel <= obj.ImageTextCellSize
                            % convert dimSelector from cell to string
                            dimSelStr=dimSelector{1};
                            for j=2:1:length(dimSelector)
                                dimSelStr=[dimSelStr ',', dimSelector{j}];
                            end
                            str=eval(['obj.ImageTextCell{', dimSelStr, '}']);
                        else
                            str='';
                        end
                    else
                        str='';
                    end
                end
                 % check it str is a string and write it if true
                if ischar(str)                 
                    obj.string=str;
                    obj.textHandle = text(.01,.01,str,'Units','normalized','parent',obj.parentAxesHandle,...
                    'Color',obj.textColor,'BackgroundColor',obj.textBgColor,...
                    'VerticalAlignment','bottom',...
                    'interpreter','none',...
                    'UIContextMenu',obj.textContextMenuHandle);       
                    if obj.autoWrapText
                        obj.wrapText;
                    end
                else
                    error(' ImageTextCell contains non string entries.');
                end
            end     
        end
            
        function parseCellArray(obj, cellArray)
        % this function parses a cell array and writes the first entry in
        % the cell array to the image
           if iscell(cellArray)
               obj.ImageTextCell = cellArray;
               obj.ImageTextCellSize= size(cellArray);
           end
        end

        function wrapText(obj)
            str = get(obj.textHandle,'String');
            if iscell(str)
                cellStr = {strcat(str{:})};
            else
                cellStr{1} = str;
            end
            
            % ugly workaround to use textwrap
            parentPanel = get(obj.parentAxesHandle,'Parent');
            textPanel = uicontrol('Style','Text','units','normalized',...
                'parent',parentPanel,'Position',[.01,.01,.8,.9]);
            [outstring,newpos] = textwrap(textPanel,cellStr);
            delete(textPanel);
            
            set(obj.textHandle,'String',outstring)
        end
        
        function str = getString(obj)
            str = obj.string;
        end
        
        function Size = getImageTextCellSize(obj)
            Size = obj.ImageTextCellSize;
        end
        
        function size = getImageTextCellSizeAsCell(obj) 
            size=cell(1, length(obj.ImageTextCellSize));
            for j=1:1:length(obj.ImageTextCellSize)
                size{j} = num2str(obj.ImageTextCellSize(j));
            end
        end
        
        function edit(obj)
            if ~iscell(obj.string)
                prevCellStr{1} = obj.string;
            else
                prevCellStr{1} = strvcat(obj.string{:});
            end
            newStr = inputdlg('Enter image text','Change image text',3,prevCellStr,'on');
            if ~isempty(newStr)                
                obj.setString(newStr);
            end
        end
        
        function updateAxesHandle(obj, parentAxesHandle)
            obj.parentAxesHandle = parentAxesHandle;
%             obj.setString(obj.string);
        end
        
        function callSendPositionCallback(obj)
            obj.sendPositionCallback(obj.getPosition);
        end

        function delete(obj)
            if ~isempty(obj.textHandle) && ishandle(obj.textHandle)
                delete(obj.textHandle);
            end                        
        end
                
    end
    
    methods (Access = private)

        function createTextContextMenu(obj)            
            if isempty(obj.textContextMenuHandle)                
                
                obj.textContextMenuHandle = uicontextmenu('Parent',obj.parentFigureHandle);                
                
                uimenu(obj.textContextMenuHandle,'Label','Edit text'   ,...                    
                    'callback',@(src,evnt)obj.edit());                
                uimenu(obj.textContextMenuHandle,'Label','Delete text'   ,...
                    'callback',@(src,evnt)obj.delete);                
                
            end                                    
        end            
    end
end