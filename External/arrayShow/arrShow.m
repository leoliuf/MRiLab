%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


classdef arrShow < handle
    % arrShow Image viewer
    % obj = arrShow(imageArray) displays the image in imageArray in an arrayShow GUI
    % and returns an instance of the arrShow class. Most properties of the GUI
    % (image contrast, cursor position, ROI ...) can also be created and controlled
    % by object methods, e.g. obj.createRoi(roiPos); or obj.window.setCW([center, width]);
    %
    % Hint: don't call the arrShow constructor directly but use the function
    % "as" instead. All arrayShow instances are hereby collected in a global
    % workspace array "asObjs" which can be used e.g. for batch tasks.
    
    
    properties (Access = public)
        data            = [];               % object containing the data and data operations
        selection       = [];               % asSelectionClass object containing the valueChanger array
        complexSelect   = [];               % cmplxChooser object
        statistics      = [];               % image statistics object
        cursor          = [];               % cursor position object
        infotext        = [];               % info text object
        window          = [];               % image windowing object
        roi             = [];               % region of interest object
        imageText       = [];               % image text object
        
        UserData        = [];               % this is not used within this class
                                            % and may be set and
                                            % changed for arbitrary purpose
    end
    
    
    properties (Access = protected)
        
        % debug messeges
        %msg = @fprintf;                    % use fprintf for debugging
        msg = @nop;                         % use nop as default
        
        % icons
        icons = [];
        
        % main figure
        fh              = 0;                % figure handle
        title           = '';               % figure title
        figurePosition  = [];
        
        userCallback = [];                  % callback is executed at the end of updFig,
                                            % e.g. when the selected image or
                                            % selected complex part has changed       
        
        linkedToWorkspaceArray  = false;    % is set to true if input array is a variable in workspace
        workspaceArrayName      = '';       % name of the input array in workspace (will be set automatically)
        
        arrShowPath = '';                   % root path of the arrShowClass
        cMapStdPath = '';                   % standard path for colormaps
        
        fcmh    = struct;                   % struct of figure context menu handle
        
        fph     = 0;                        % figure panel handle
        bph     = 0;                        % bottom panal handle               
        cph     = 0 ;                       % control panel handle
        cpcmh   = struct;                   % control panel context menu handle
        mbh     = struct;                   % menu bar handle
        tbh     = struct;                   % tool bar handle                        
        
        ih   = [];                          % image handle
                                            %  (this is an array of N handles, if we display
                                            %    N images)
                
        postProcFun = [];                   % postprocessing function handle
                
        mouseWindowingActive         = false;
        mouseWindowingReferencePoint = [];
        processingCallback           = false;
        
        relatives     = [];                 % list of other arrShow objects in current environment
        noRelatives   = 0;                  % number of relatives
        useGlobalArray= false;              % if set to true, no individual relatives list is populated within this object and
                                            % the global workspace array
                                            % asObjs is used instead. Also
                                            % no update button will be
                                            % created in this case
        
        sendWdwSize         = false;        % send main figure window size to relatives
        titleAsImageText    = false;        % draw the title as a text within the images
        
        saveInfosAtImageExport      = true; % if true, a description text file is created when exporting images (containing dinensions, norm, i.e.)
        
        playAlongDim                = false;
        
        stdColormap     = 'Gray(256)';         % standard colormap
        phaseColormap   = 'martin_phase(256)'; % standard colormap for phase display        
        
        stdCmapMightBeModified = false;     % The matlab colormapeditor allows for altering the colormap
        phaCmapMightBeModified = false;     % even after the program returns from the function call
                                            % 'colormapeditor'. The 'cmapMightBeModified' workaround causes
                                            % arrayShow to retrieve the potentially modified from the
                                            % figure handle during updFig.                
    end
    
    properties (Constant)
        % image export presets
        RESIZE_AXES_FOR_SCREENSHOTS = false;
        
        % panel positions
        CMPLX_SEL_POS  = [5/6, 0, 1/6, 1]; % relative position and size of the complexSelect in the top Panel
        STATISTICS_POS = [4/6, 0, 1/6, 1]; % relative position and size of the statistics in the top Panel
        INFOTEXT_POS   = [2/6, 0, 1/6, 1];
        WINDOWING_POS  = [3/6, 0, 1/6, 1]; 
        
        % sizes
        CP_HEIGHT = 2.2;  % fixed height for the controlPanel (in centimeters)
        BP_HEIGHT = .5;   % fixed height for the bottom panel(in centimeters)
        FP_HEIGHT = 18;   % initial height for the figurePanel
        
        % arrShow version
        VERSION = 0.1;
    end
    
    methods (Access = public)
        function obj = arrShow(arr, varargin)
                        
            % evaluate varagin
            CW = [];
            userFigurePosition = [];
            selectedImageStr = '';
            imageTextVal = [];
            initComplexSelect = [];
            infoText = '';
            if nargin > 1
                if length(varargin) ==1
                    obj.title = varargin{1};
                    if strcmp(obj.title,inputname(1))
                        obj.workspaceArrayName = inputname(1);
                        obj.linkedToWorkspaceArray = true;
                    end
                end
                for i = 1 : floor(length(varargin)/2)
                    option       = varargin{i*2-1};
                    option_value = varargin{i*2};
                    
                    switch lower(option)
                        case 'title'
                            obj.title        = option_value;
                        case 'info'
                            infoText         = option_value;
                        case 'imagetext'
                            imageTextVal        = option_value;
                        case 'window'
                            CW = option_value;
                        case 'select'
                            selectedImageStr = option_value;
                        case 'complexselect'
                            initComplexSelect = option_value;
                        case {'colormap', 'stdcolormap'}
                            obj.stdColormap = option_value;
                        case 'phasecolormap'
                            obj.phaseColormap = option_value;                            
                        case 'position'
                            userFigurePosition = option_value;
                        case 'inputname'
                            if isempty(obj.title)
                                obj.title = option_value;
                            end
                            if ~isempty(option_value)
                                obj.workspaceArrayName = option_value;
                                obj.linkedToWorkspaceArray = true;
                            end
                        case {'callback','cb'}
                            obj.userCallback =  option_value;
                        case 'useglobalarray'
                            obj.useGlobalArray = option_value;
                        otherwise
                            error('arrShow:varargin','unknown option [%s]!\n',option);
                    end;
                end;
                clear('option','option_value');
                clear('varargin');
                % this is interesting...
                % it seems that the varargin is somehow stored within the
                % object, wasting memory
                % if we don't explicitly delete it here
            end
            
            obj.data = asDataClass(arr, @obj.updFig);
            si       = size(obj.data.dat);
            
            
            % store standard paths
            obj.arrShowPath = fileparts(mfilename('fullpath'));
            obj.cMapStdPath = [obj.arrShowPath, filesep, 'customColormaps'];
            iconPath    = [obj.arrShowPath, filesep, 'icons'];
            
            % load icons
            obj.icons = asIconClass(iconPath);
            
            % create main figure
            fpos = obj.deriveFigurePos();
            obj.fh     = figure('Units','centimeters',...
                'Resize','off',...
                'Position',fpos,...
                'KeyPressFcn',@(src,evnt)obj.keyPressCb(evnt),...
                'CloseRequestFcn',@(src,evnt)obj.closeReq(src),...
                'WindowButtonMotionFcn',@(src, evnt)obj.MouseMovementCb,...
                'WindowButtonDownFcn',@obj.buttonDownCb,...
                'WindowButtonUpFcn',@(src,evnt)obj.buttonUpCb(src),...
                'WindowScrollWheelFcn',@obj.scollWheelCb,...
                'MenuBar','none',...
                'toolbar','none',...
                'IntegerHandle','on');
            
            set(obj.fh,'UserData',obj)  % link this object to main figure
            
            % set title
            if ~isempty(obj.title)
                set(obj.fh,'Name',obj.title);
            end
            
            % change figure icon :-)
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jframe=get(obj.fh,'javaframe');
            jIcon=javax.swing.ImageIcon(fullfile(iconPath,'figure.png'));
            jframe.setFigureIcon(jIcon);
            clear jframe jIcon
            
            % init menu- and toolbar
            obj.initMenuBar();
            obj.initToolBar();
            
            % shortcuts to some dimensions
            fphe = obj.FP_HEIGHT; % home figure height
            cphe = obj.CP_HEIGHT; % control panel (top panel) height
            bphe = obj.BP_HEIGHT; % bottom panel height
            
            % control panel
            obj.cph  = uipanel(obj.fh,'Units','centimeters',...
                'Position',[0, fphe + bphe, fpos(3), cphe],...
                'Interruptible','off',...
                'BusyAction','cancel');
            set(obj.cph,'Units','normalized');
            
            % bottom panel
            obj.bph  = uipanel(obj.fh,'Units','centimeters',...
                'Position',[0, 0, fpos(3), bphe],...
                'Interruptible','off',...
                'BusyAction','cancel' );
            set(obj.bph,'Units','normalized');
            
            % figure panel
            obj.fph   = uipanel(obj.fh,'Units','centimeters',...
                'Position',[0, bphe,  fpos(3), fphe],...
                'Interruptible','off',...
                'BusyAction','cancel');
            set(obj.fph,'Units','normalized');
                                    
            % image statistics object
            obj.statistics = asStatisticsClass(obj.cph, obj.STATISTICS_POS);
            
            % image windowing object
            obj.window = asWindowingClass(...
                obj.cph,...
                obj.WINDOWING_POS,...
                @obj.updFig,...
                @obj.applyToRelatives,...
                @()obj.getColormap('phase',true),...
                obj.icons.send);
            
            % info textbox object
            obj.infotext = asInfoTextClass(obj.cph, obj.INFOTEXT_POS);
            
            % complex part selector
            obj.complexSelect = asCmplxChooserClass(...
                obj.cph,...
                obj.CMPLX_SEL_POS,...
                @obj.updFig,...
                @obj.applyToRelatives,...
                obj.icons.send);
            
            if isreal(obj.data.dat)
                % disable the imag and phase button in the complexSelect
                % object
                obj.complexSelect.lockImagAndPhase;
                
                % select real part per default
                if isempty(initComplexSelect)
                    initComplexSelect = 'Re';
                end
            end
            if ~isempty(initComplexSelect)
                obj.complexSelect.setSelection(initComplexSelect, true);
            end
            

            
            % init the figure context menu (first entries are created
            % within the asCursorPosClass)
            obj.fcmh.base = uicontextmenu;
            
            % cursor position object
            obj.cursor = asCursorPosClass(...
                obj.fh,...
                obj.bph,...
                obj.fcmh,...
                @obj.applyToRelatives,...
                @obj.getCurrentAxesHandle,...
                obj);
            
            % valueChanger array
            initStrings = cell(length(si),1);
            initStrings{1} = ':';
            initStrings{2} = ':';
            for i = 3 : length(si)
                initStrings{i} = '1';
            end
            obj.selection = asSelectionClass(obj.cph, si,...
                'figureUpdateCallback',@obj.updFig,...
                'apply2allCb',@obj.applyToRelatives,...
                'InitStrings',initStrings,...
                'dataObject',obj.data);
            obj.data.linkToSelectionClassObject(obj.selection);
            
            
            % init the control panel context menu and create additional
            % entries in the previously created figure context menu...
            obj.initContextMenus(infoText);
            clear('infoText');
            
            
            set(obj.fh,'HandleVisibility','off');
            % ...we don't want other matlab routines to print stuff on our
            % main figure
            
            
            if ~isempty(selectedImageStr)
                obj.selection.setValue(selectedImageStr,true,true,true);
            end
            
            % if specific figure position is given, resize the gui
            if ~isempty(userFigurePosition)
                obj.setFigurePosition(userFigurePosition);
                obj.fpResize(true);  % manually call resize function
            end
            
            % find relatives
            if ~obj.useGlobalArray
                obj.refreshRelativesList();
                
                % since this object is not yet in the cloud, add it manually to
                % the list
                obj.relatives   = [obj.relatives,obj];
                obj.noRelatives = obj.noRelatives + 1;
                % (this assures that the send2all function does
                % include this object, if the "includeSelf"-toggle is switched
                % on)
            end
            
            % all gui components should be ready by now, so start
            % updateFigure to find the selected array part and convert it
            % to an image object in the axes region
            obj.updFig;  % for new figures, this also seems to be triggered
            % when setting the figure resize function. It
            % might be possible to slightly accelerate startup
            % time by fixing this...
            
            % apply the initial window (center and width setting), if we
            % got one as a constructor input argument
            if ~isempty(CW)
                obj.window.setCW(CW);
            end
            
            % select proper valueChanger object (VCO)
            if length(si) > 2
                obj.selection.selectVco(3);
            end
            
            % save figure pixel position in object property and activate
            % figure resize function
            set(obj.fh,'Units', 'pixel',...
                'ResizeFcn',@(src, evnt)obj.fpResize);
            obj.figurePosition = get(obj.fh,'Position');
            
            
            % write the imagetext
            if ~isempty(imageTextVal)
                
                % deal with special case of a one-dimensional image
                % text cell array and a 3 dimensional image array
                if iscell(imageTextVal) && isvector(imageTextVal)
                    if length(size(obj.data.dat)) == 3
                        imageTextVal = reshape(imageTextVal,[1,1,length(imageTextVal)]);
                    end
                end
                obj.createImageText(imageTextVal);
                obj.updFig
            end
            
            % put focus on complexSelector
            obj.complexSelect.focus;
            
            % activate resize functionality
            set(obj.fh,'Resize','on');
        end
        
        function reloadWorkspaceArray(obj)
            if obj.linkedToWorkspaceArray
                % try to get the workspace array
                try
                    WA = evalin('base',obj.workspaceArrayName);
                catch err
                    if strcmp(err.identifier,'MATLAB:UndefinedFunction')
                        WA = [];
                    else
                        rethrow(err);
                    end
                end
                if isempty(WA)
                    fprintf('workspace variable ''%s'' seems not to be valid anymore\n',obj.workspaceArrayName);
                else
                    obj.data.overwriteImageArray(WA);
                end
            else
                disp('asObject is not linked to a workspace array');
            end
            
        end
        
        function updateWorkspaceArray(obj)
            if obj.linkedToWorkspaceArray
                assignin('base',obj.workspaceArrayName,obj.data.dat);
            end
        end
        
        function overwriteImageArray(obj, arr)
            obj.data.overwriteImageArray(arr);
        end
        
        function refreshRelativesList(obj)
            if obj.useGlobalArray
                obj.msg('global array asObjs is used as list of relatives. Ommitting list refresh!\n');
                return;
            end
            obj.relatives   = arrShow.findAllObjects();
            obj.noRelatives = length(obj.relatives);
            
            % if according options are set, send object properties to
            % relatives
            if obj.sendWdwSize
                obj.sendFigureSize();
            end
            
            %             obj.sendColormapToRelatives(false);
            
            if obj.complexSelect.sendToggleState
                if obj.selection.sendToggleState
                    obj.applyToRelatives('complexSelect.setSelection',false,obj.complexSelect.getSelection(),true);
                else
                    obj.applyToRelatives('complexSelect.setSelection',false,obj.complexSelect.getSelection(),false);
                end
            end
            
            if obj.selection.sendToggleState
                obj.selection.send;
            end
            
            if obj.window.sendAbsWindow
                obj.window.sendAbsWindowToRelatives()
            else
                if obj.window.sendRelWindow
                    obj.window.sendRelWindowToRelatives();
                end
            end
            
            if ~isempty(obj.roi)
                if isvalid(obj.roi)
                    if obj.roi.getSendPositionToggle();
                        obj.roi.callSendPositionCallback;
                    end
                end
            end
        end
        
        function wipeRelativesList(obj)
            obj.relatives   = [];
            obj.noRelatives = 0;
            fprintf('deleted all relatives from list\n');
        end
        
        function sendColormapToRelatives(obj, refreshRelativeList)
            if nargin < 2
                refreshRelativeList = false;
            end
            if refreshRelativeList
                obj.refreshRelativesList();
            end
            obj.applyToRelatives('setColormap',false,obj.getColormap);
        end
        
        function sendAll(obj, bool)
            if nargin < 2
                bool = true;
            end
            obj.selection.toggleSend(bool);
            obj.window.toggleSendRelWindow(bool);
            obj.window.toggleSendAbsWindow(bool);
            obj.complexSelect.toggleSend2all(bool);
            obj.cursor.toggleSend(bool);
            
        end
        
        function printCurrentImage(obj)
            % this is a workaround to print an image without the uipanels
            
            % create a help figure without menues
            helpFigure = figure('MenuBar','none',...
                'ToolBar','none');
            colormap(obj.getColormap);
            
            % copy current axes to the help figure
            ah = obj.getCurrentAxesHandle;
            helpAxes = copyobj(ah,helpFigure);
            set(helpAxes,'Units','normalized','position',[0,0,1,1])
            
            % delete cursor rectangle in helpFigure
            rect = findobj(helpFigure,'type','rectangle');
            delete(rect);
            
            % print helpFigure
            ph = printpreview(helpFigure);
            
            % wait until print dialog is closed
            while(ishandle(ph))
                pause(0.1);
            end
            
            % ...and close the help figure
            if ishandle(helpFigure)
                close(helpFigure);
            end
            
        end
        
        function batchExportDimension(obj,dim)
            dims = obj.selection.getDimensions;
            noDims = length(dims);
            if nargin < 2
                dim = mydlg('Enter dimension','Enter dimension for batch export',num2str(noDims));
                dim = str2double(dim);
                if isnan(dim)
                    return
                end
            end
            if noDims < dim
                disp('invalid dimension number given');
                return;
            end
            filename = arrShow.removeSpecialCharsFromString(obj.title);
            obj.selection.selectVco(dim)
            origValue = obj.selection.getCurrentVcValue;
            obj.selection.setCurrentVcValue(1);
            for i = 1 : dims(dim);
                obj.exportCurrentImage([filename,'_',num2str(i, '%05.5d'),'.png']);
                obj.selection.increaseCurrentVc;
            end
            obj.selection.setCurrentVcValue(origValue);
            disp('Done exporting batch.');
        end
        
        function exportCurrentImage(obj, filename, screenshot, includePanels, includeCursor, scrshotPauseTime)
            if nargin < 6
                scrshotPauseTime = 0;
                if nargin < 5
                    includeCursor = true;
                    if nargin < 4
                        includePanels = false;
                        if nargin < 3
                            screenshot = false;
                            if nargin < 2
                                filename = '';
                            end
                        end
                    end
                end
            end
            
            if isempty(filename)
                % generate filename from title
                filename = arrShow.removeSpecialCharsFromString(obj.title);
                
                [file,path] = uiputfile({'*.png';'*.bmp'},'Save image as', filename);
                if isnumeric(file)
                    return;
                end
                filename = strcat(path, file);
            end
            
            
            if isempty(filename)
                warning('arrShow:exportCurrentImage','image export aborted, no filename given');
            else
                if exist(filename,'file');
                    fprintf('Fig. %d: overwriting existing file: %s\n',obj.fh, filename);
                end
                
                %img = obj.getSelectedImages();
                ah = obj.getCurrentAxesHandle();
                imh = findobj(ah,'type','image');
                img = get(imh,'Cdata');
                
                if screenshot || includePanels
                    % use the matlab getframe routines to capture the image
                    % with all its child-objects.
                    warning('arrShow:exportCurrentImage','output image might not have the exact original image''s resolution');
                    
                    origUnits = get(ah,'units');
                    set(ah,'units','pixel');
                    origPos = get(ah,'position');
                    
                    % show cursor rectangle?
                    if ~includeCursor
                        ud = get(ah,'UserData');
                        if ~isempty(ud) && isfield(ud,'rect') && ~isempty(ud.rect)
                            delete(ud.rect);
                            ud.rect = [];
                            set(ah,'UserData',ud);
                        end
                    end
                    
                    if obj.RESIZE_AXES_FOR_SCREENSHOTS
                        si = size(img) -1;
                        set(ah,'position',[origPos(1:2),si(1:2)]);
                    end
                    
                    % assure that current window is on top of all others
                    if scrshotPauseTime
                        figure(obj.fh);
                        drawnow;
                        pause(scrshotPauseTime);
                    end
                    
                    if includePanels
                        img = getframe(obj.fh);
                    else
                        img = getframe(ah);
                    end
                    
                    set(ah,'position',origPos);
                    set(ah,'units',origUnits);
                    
                    
                    % write image to file
                    imwrite(img.cdata,filename);
                    
                else
                    
                    if size(img,3) == 3
                        % cdata is already in RGB format, so just write it
                        % to file
                        imwrite(img,filename);
                    else
                        % cdata represents intensity values while the
                        % visible representation is windowed and color coded
                        % using the colormap and CLim property of the axes object.
                        % In order to properly save the image we need to
                        % mimic the windowing of the axes object.
                        
                        % get range limitations and center/width values
                        Clim = obj.window.getCLim();
                        CW = obj.window.getCW();
                        
                        % compress image to valid range
                        img(img > Clim(2)) = Clim(2);
                        img(img < Clim(1)) = Clim(1);
                        
                        % scale image according to windowing
                        img = img - Clim(1);
                        img = img / CW(2);
                        
                        % scale image to the range of the current colormap
                        cmap = get(obj.fh,'Colormap');
                        img = img * ( size(cmap,1) - 1) + 1;
                        
                        % write image to file
                        imwrite(img,cmap,filename);
                    end
                end
                
                
                if obj.saveInfosAtImageExport
                    [path,name] = fileparts(filename);
                    obj.exportImageInfos(fullfile(path,[name,'.txt']));
                end
            end
        end
        
        function exportImageInfos(obj, filename, appendToFile)
            if nargin < 3
                appendToFile = false;
                if nargin < 2
                    initName = obj.title;
                    initName(isspace(initName))='_';
                    [file,path] = uiputfile({'*.txt'},'Save image infos in', initName);
                    if isnumeric(file)
                        return;
                    end
                    filename = strcat(path, file);
                end
            end
            
            if ~isempty(filename)
                if appendToFile
                    fid = fopen(filename,'at');
                else
                    fid = fopen(filename,'wt');
                end
                
                % construct output text from title, imageStats and infoText
                CW = obj.window.getCW;
                
                if isempty(CW)
                    CW = [0,0];
                end
                
                % basic informations
                text = {'--Figure title--';...
                    ['''',obj.title,''''];...
                    '';...
                    '--Image dimensions--';...
                    num2str(size(obj.getSelectedImages));...
                    '';...
                    '--selected image--';...
                    obj.selection.getValue();...
                    '';...
                    '--Image stats--'};
                text = [text; obj.statistics.getImageStatsCellString()];
                
                % windowing
                text = [text ; {...
                    '';...
                    '--Image windowing--';...
                    ['center/width = [ ', num2str(CW(1)),' ',num2str(CW(2)),' ]'];...
                    ['colormap     = ',obj.getColormap];...
                    ''}];
                
                % roi
                if ~isempty(obj.roi)
                    if isvalid(obj.roi)
                        roiPos = obj.roi.getPosition;
                        Nvertex = size(roiPos,1);
                        roiPosText = cell(Nvertex,1);
                        for i = 1 : Nvertex
                            roiPosText{i} = [num2str(roiPos(i,1)),'  ',num2str(roiPos(i,2))];
                        end
                        roiStats = obj.roi.getMeanAndStdString;
                        text = [text ; {'--Roi position--'};...
                            roiPosText;...
                            {'';...
                            '--Roi Stats--';...
                            roiStats;...
                            '';}];
                    end
                end
                
                % infotext
                text = [text; {'--InfoText--'};...
                    obj.infotext.getString;...
                    '';];
                
                % date and version informations
                text = [text; 'date : ', humanize.clock(clock,'date')];
                text = [text; 'time : ', humanize.clock(clock,'time')];
                text = [text; 'arrShow ver.: ', num2str(obj.VERSION)];

                
                % write everything to the text file
                for i = 1 : size(text,1);
                    fprintf(fid,'%s\n',text{i});
                end
                
                fclose(fid);
            end
            
        end
        
        function exportColorbar(obj, filename)
            if nargin < 2
                filename = [];
            end
            if isempty(filename)
                % generate filename from title
                filename = arrShow.removeSpecialCharsFromString(obj.title);
                
                [file,path] = uiputfile({'*.eps'},'Save colorbar as', filename);
                if isnumeric(file)
                    return;
                end
                filename = strcat(path, file);
            end
            
            if isempty(filename)
                warning('arrShow:exportColorbar','image export aborted, no filename given');
            else
                if exist(filename,'file');
                    fprintf('Fig. %d: overwriting existing file: %s\n',obj.fh, filename);
                end
                
                % get colorbar handle
                ch = colorbar('peer',obj.getCurrentAxesHandle);
                
                % create a help figure without menues
                helpFigure = figure('MenuBar','none',...
                    'ToolBar','none');
                set(helpFigure,'Units','pixel','position',[800,300,50,300])
                colormap(obj.getColormap());
                
                % copy current axes to the help figure
                helpAxes = copyobj(ch,helpFigure);
                set(helpAxes,'Units','normalized','position',[0.3,0.1,.05,0.8])
                
                set(helpAxes,'fontsize',14)
                
                % write image to file
                print(helpFigure,filename,'-depsc');
                
                % close help window
                delete(helpFigure);
                
                % update figure to possibly remove the colorbar from the main
                % window
                obj.updFig;
            end
            
        end
        
        function bool = isInitialized(obj)
            bool = false([1,length(obj)]); % be pessimistic
            
            for i = 1 : length(obj)
                % check, if the object's figure handle is a valid figure handle
                % in this workspace
                if isvalid(obj) && ishandle(obj(i).fh)
                    type = '';
                    
                    try
                        type = get(obj(i).fh,'Type');
                    end
                    
                    if strcmp(type, 'figure')
                        % check if this object is the same als the object
                        % linked to the figure
                        linkedObject = get(obj(i).fh,'UserData');
                        if obj(i).eq(linkedObject)
                            bool(i) = true;
                        end
                    end
                end
            end
        end
        
        function arr = getAllImages(obj)
            arr = obj.data.dat;
        end
        
        function arr = getSelectedImages(obj, returnAsComplex)
            
            if nargin == 1
                returnAsComplex = false;
            end
            
            % get selected image subscripts
            str = obj.selection.getValue();
            
            if returnAsComplex
                % create a command string from the gathered informations
                command = strcat('squeeze(obj.data.dat(',str,'))');
            else
                % ... get function pointer (to abs(), real(), phase(0...) from complexChooser
                fun = obj.complexSelect.getFunPointer();
                
                % create a command string from the gathered informations
                % (ok, this is kinda ugly and may be replaced by a proper
                % subsref call in the future. However, it works, so ...)
                command = strcat('squeeze(fun(obj.data.dat(',str,')))');
            end
            
            % execute command
            arr = eval(command);
        end
        
        %         function arr = getSelectedImages(obj,returnAsComplex)
        %
        %             if nargin == 1
        %                 returnAsComplex = false;
        %             end
        %
        %             % get selected image subscripts
        %             idx = obj.selection.getValueAsCell;
        %
        %             arr = squeeze(obj.data.dat(idx{:}));
        %
        %             if ~returnAsComplex
        %                 %... get function pointer (to abs(), real(), phase(0...) from complexChooser
        %                 fun = obj.complexSelect.getFunPointer();
        %                 arr = fun(arr);
        %             end
        %         end
        
        
        function dims = getImageDimensions(obj)
            dims = size(obj.data.dat);
        end
        
        function fh  = getFigureHandle(obj)
            fh = obj.fh;
        end
        
        function createInfoTextFromStruct(obj, struct)
            obj.infotext.parseStruct(struct);
        end
        
        function ah  = getCurrentAxesHandle(obj)
            % since the image windowing object nows the lastly selected
            % axes, assume this to be the 'current axes' even if
            % get(fh,'CurrentObject') might already be something else
            ah = obj.window.getAxesHandle();
        end
        
        
        
        
        
        % ----> zoom
        function z = getZoom(obj)
            ah = obj.getCurrentAxesHandle;
            if ishandle(ah)
                yl = ylim(ah);
                xl = xlim(ah);
                z = [yl;xl];
            else
                z = [];
            end
        end
        
        function setZoom(obj,z)
            if isnumeric(z)
                ah = obj.getCurrentAxesHandle;
                switch numel(z)
                    case 1 % scalar zoom factor
                        if z == 0
                            % reset zoom
                            dim = obj.statistics.getDimensions;
                            ylim(ah,0.5 + [0,dim(1)]);
                            xlim(ah,0.5 + [0,dim(2)]);
                        else
                            zoom(obj.fh,z);
                        end
                        return;
                    case 4 % ylim and xlim
                        if all(size(z) == [2,2])
                            ylim(ah,z(1,:));
                            xlim(ah,z(2,:));
                            return;
                        end
                end
            end
            obj.msg('invalid zoom argument\n');
        end
        
        function sendZoom(obj)
            z = obj.getZoom;
            obj.applyToRelatives('setZoom',false,z);
        end
        
        function copyZoom(obj)
            % copy zoom to clipboard
            clipboard('copy',obj.getZoom);
            fprintf('Copied zoom to clipboard\n');
            
        end
        
        function pasteZoom(obj)
            % paste zoom from clipboard
            z = str2num(clipboard('paste'));
            if ~isempty(z)
                if all(size(z) == [2,2])
                    obj.setZoom(z)
                    return
                end
            end
            fprintf('No valid zoom information in clipboard\n');
        end
        
        % <---- zoom
        
        
        function obj = rebuildObject(obj)
            
            for i = 1 : length(obj)
                
                obj(i) = arrShow(obj(i).getAllImages,...
                    'title',          obj(i).getFigureTitle,...
                    'info',           obj(i).infotext.getString,...
                    'window',         obj(i).window.getCW(),...
                    'select',         obj(i).selection.getValue,...
                    'complexselect',  obj(i).complexSelect.getSelection,...
                    'stdcolormap',    obj(i).getColormap('standard'),...
                    'phasecolormap',  obj(i).getColormap('phase'),...
                    'position',       obj(i).getFigurePosition,...
                    'useglobalarray', obj(i).useGlobalArray);
                
                if ~isempty(obj(i).UserData)
                    obj(i).UserData = obj(i).UserData;
                end
                
            end
        end
        
        function setColormap(obj, mapName, mapType, suppressUpdFig)
            % mapType can be 'current, standard or phase'
            
            if nargin < 4
                suppressUpdFig = false;
            end
            if nargin < 3
                mapType = 'current';
            end
            if nargin < 2 || isempty(mapName)

                % this is a workaround... in previous versions, arrShow 
                % could only handle standard colormaps. Therefore 
                % obj.getColormap always returned a string. With the
                % possibility to load custom maps, the map name might not
                % be defined and obj.getColormap returns the actual RGB
                % "lookup table". In future versions, lookup tables and map
                % names will be separated more carefully.
                cMap = obj.getColormap();
                if ~ischar(cMap)
                    cMap = 'gray(256)';
                end
                
                % prompt for a colormap name
                mapName = inputdlg('','Colormap name',1,{cMap});
                if isempty(mapName)
                    return;
                else
                    mapName = mapName{1};
                end
            end
            
            mapType = lower(mapType);
            
            for i = 1 : length(obj)
                switch mapType
                    case 'current'
                        if strcmp(obj.complexSelect.getSelection,'Pha')
                            obj(i).phaseColormap = mapName;
                        else
                            obj(i).stdColormap = mapName;
                        end
                    case 'standard'
                        obj(i).stdColormap = mapName;
                    case 'phase'
                        obj(i).phaseColormap = mapName;
                end
                if ~suppressUpdFig
                    obj(i).updFig();
                end
            end
        end
        
        function cMap = getColormap(obj, mapType, convertToMatrix)            
            % mapType can be 'current, standard or phase'
            
            if nargin < 3
                convertToMatrix = false;
                if nargin < 2
                    mapType = 'current';
                end
            end            
            
            % account for the fact that the cMap might has been altered
            % by the matlab colormapeditor in the meantime
            if (obj.stdCmapMightBeModified ||...
               obj.phaCmapMightBeModified) &&...
               obj.isInitialized()
           
                % retrieve the colormap from the figure
                cMap = colormap(obj.fh);
                
                % store the cMap to this object's properties
                if obj.phaCmapMightBeModified                    
                    obj.setColormap(cMap, 'phase', true);                
                else
                    obj.setColormap(cMap, 'standard', true);             
                end
            end            
            
            
            switch lower(mapType)
                case 'current'
                    if strcmp(obj.complexSelect.getSelection,'Pha')
                        cMap = obj.phaseColormap;
                    else
                        cMap = obj.stdColormap;
                    end
                case 'standard'
                    cMap = obj.stdColormap;
                case 'phase'
                    cMap = obj.phaseColormap;
            end
            
            if convertToMatrix && ischar(cMap)
                set(obj.fh,'HandleVisibility','on');
                cMap   = colormap(cMap);
                set(obj.fh,'HandleVisibility','off');
            end
                
        end
        
        function setPostprocessingFunction(obj,fun)
            if nargin < 2 || isempty(fun)
                obj.postProcFun = [];
                obj.updFig();
            else
                if isa(fun,'function_handle')
                    obj.postProcFun = fun;
                    obj.updFig();
                else
                    disp('invalid argument');
                end
            end
        end
        
        function storeColormap(obj, file)
            % save colormap in a file
            if nargin < 2
                [fname, fpath] = uiputfile('.mat','store custom colormap',obj.cMapStdPath);
                file = [fpath, fname];
            end
            if ~isempty(file) && ~isa(file,'double')                
                cm = colormap(obj.fh);
                save(file,'cm');
            end
        end
        
        function loadColormap(obj, file)
            % load colormap from file
            if nargin < 2
                [fname, fpath] = uigetfile('.mat','load custom colormap',obj.cMapStdPath);
                file = [fpath, fname];
            end
            if ~isempty(file)
                cm = load(file,'cm');
                if isfield(cm,'cm');
                    obj.setColormap(cm.cm);
                end
            end
        end
        
        function showTrueImageSize(obj)
            truesize(obj.fh);
        end
        
        
        % ---->  figure properties
        function pos = getFigurePosition(obj)
            if obj.isInitialized()
                obj.storeFigurePosition
            end
                pos = obj.figurePosition;           
        end
        
        function setFigurePosition(obj,pos)
            if obj.isInitialized()
                originalUnits = get(obj.fh,'Units');
                set(obj.fh,'Units','pixels');
                set(obj.fh,'Position',pos);
                set(obj.fh,'Units',originalUnits);
            end
            obj.figurePosition = pos;
        end
        
        function pos = getFigureOuterPosition(obj)
            originalUnits = get(obj.fh,'Units');
            set(obj.fh,'Units','pixels');
            pos = get(obj.fh,'Outerposition');
            set(obj.fh,'Units',originalUnits);
        end
        
        function setFigureOuterPosition(obj,pos)
            originalUnits = get(obj.fh,'Units');
            set(obj.fh,'Units','pixels');
            set(obj.fh,'Outerposition',pos);
            obj.figurePosition = get(obj.fh,'Position');
            set(obj.fh,'Units',originalUnits);
        end
        
        function storeFigurePosition(obj)
            % unfortunately there is no "positionChangeCallback" option in
            % matlab figures. So the obj.figurePosition property might not
            % be up to date after moving the window around. This method is
            % a workaround to manually store the current figure position
            % e.g. before saving the object to a file
            if obj.isInitialized
                originalUnits = get(obj.fh,'Units');
                set(obj.fh,'Units','pixels');
                obj.figurePosition = get(obj.fh,'Position');
                set(obj.fh,'Units',originalUnits);
            end
        end
        
        function resetFigurePosition(obj)
            fpos = obj.deriveFigurePos();
            originalUnits = get(obj.fh,'Units');
            set(obj.fh,'Units','centimeters');
            set(obj.fh,'Position',fpos);
            
            
            % save position in pixels to object
            set(obj.fh,'Units','pixels');
            obj.figurePosition = get(obj.fh,'Position');
            
            % restore original units
            set(obj.fh,'Units',originalUnits);
            
        end
        
        function siz = getFigureSize(obj)
            pos = obj.getFigurePosition;
            siz = pos(3:end);
        end
        
        function setFigureSize(obj,siz)
            obj.storeFigurePosition
            pos = obj.getFigurePosition;
            if isscalar(siz)
                siz = siz * pos(3:4);
            end
            pos(2) = pos(2) + pos(4) - siz(2);
            pos(3:4) = siz;
            obj.setFigurePosition(pos);
        end
        
        function copyFigureSize(obj)
            % copy zoom to clipboard
            clipboard('copy',obj.getFigureSize);
            fprintf('Copied figure size to clipboard\n');
            
        end
        
        function pasteFigureSize(obj)
            % paste zoom from clipboard
            siz = str2num(clipboard('paste'));
            if ~isempty(siz)
                if all(size(siz) == [1,2])
                    obj.setFigureSize(siz)
                    return
                end
            end
            fprintf('No valid zoom information in clipboard\n');
        end
        
        function sendFigureSize(obj)
            siz = obj.getFigureSize;
            obj.applyToRelatives('setFigureSize',false,siz)
        end
        
        function toggleSendFigureSize(obj, bool)
            if nargin > 1
                set(obj.mbh.sendFigSize,'Checked',arrShow.boolToOnOff(~bool));
            end
            
            switch get(obj.mbh.sendFigSize,'Checked')
                case 'off'
                    obj.sendWdwSize = true;
                    %                     set(obj.cpcmh.sendFigSize,'Checked','on');
                    set(obj.mbh.sendFigSize,'Checked','on');
                    
                    obj.sendFigureSize();
                    
                case 'on'
                    obj.sendWdwSize = false;
                    %                     set(obj.cpcmh.sendFigSize,'Checked','off');
                    set(obj.mbh.sendFigSize,'Checked','off');
            end
        end
        
        function setFigureTitle(obj,title)
            if nargin < 2
                previousTitle = get(obj.fh,'Name');
                title = mydlg('Enter title','Change figure title',previousTitle, [500 500 500 90]);
                if isempty(title)
                    title = previousTitle;
                end
            end
            obj.title = title;
            set(obj.fh,'Name',title);
            if obj.titleAsImageText
                obj.imageText.setString(title);
            end
        end
        
        function title = getFigureTitle(obj)
            %             title = get(obj.fh,'Name');
            title = obj.title;
        end
        
        function putFigureOnTop(obj)
            figure(obj.fh);
        end
        
        function minimizeFigure(obj)
            figureName = ['Figure ',num2str(obj.fh)];
            showwindow(figureName,'minimize');
        end
        % ---->  figure properties
        
        
        
        function ah = getAxesHandle(obj)
            ah = obj.window.getAxesHandle();
        end
        
        
        
        
        function out = applyToRelatives(obj, funName, includeSelf, arg1, arg2, arg3)
            if obj.useGlobalArray
                global asObjs;
                obj.relatives = asObjs;
                obj.noRelatives = length(obj.relatives);
            end
            switch nargin
                case 3
                    cmd = ['obj.relatives(o).',funName,';'];
                case 4
                    cmd = ['obj.relatives(o).',funName,'(arg1);'];
                case 5
                    cmd = ['obj.relatives(o).',funName,'(arg1, arg2);'];
                case 6
                    cmd = ['obj.relatives(o).',funName,'(arg1, arg2, arg3);'];
                    
            end
            o = 1;
            while o <= obj.noRelatives
                if isvalid(obj.relatives(o))
                    if includeSelf || obj.relatives(o) ~= obj
                        if nargout == 1
                            out{o} = eval(cmd);
                        else
                            eval(cmd);
                        end
                    end
                    o = o + 1;
                else
                    obj.relatives(o) = '';
                    obj.noRelatives = obj.noRelatives - 1;
                end
            end
        end
        
        function saveObject(obj, filename)
            if nargin < 2 || isempty(filename)
                % generate filename from title
                filename = arrShow.removeSpecialCharsFromString(obj.title);
                
                [file,path] = uiputfile({'*.mat'},'Save asObjects as', filename);
                if isnumeric(file)
                    return;
                end
                filename = strcat(path, file);
            else
                file = filename;
            end
            
            
            if isempty(filename)
                warning('arrShow:saveObject','object saving aborted, no filename given');
            else
                
                % choose a variable name for the asObjects, which is the filename
                % without the tailing '.mat'
                storeVarName = textscan(file,'%s %s','delimiter','.');
                storeVarName = storeVarName{1}{1};
                
                % remove possible links to relatives and store objects position
                obj.wipeRelativesList;
                obj.storeFigurePosition;
                
                % copy objects to a variable named like the file
                eval([storeVarName, ' = obj;']);
                
                % ...write the variable to harddisk
                fprintf('saving data...   ');
                tic;
                save(filename,storeVarName, '-v7.3');
                fprintf('done in %2.2f seconds.\n',toc);
                
                clear(storeVarName);
            end
        end
        
        function play(obj, framerate)
            % set playAlong dim to true
            obj.playAlongDim = true;
            
            % Replace play button by a pause button
            set(obj.tbh.play,'Tag','Annotation.pause',...
                'TooltipString', 'Pause',...
                'ClickedCallback', @(src, evnt)obj.stop,...
                'CData',obj.icons.pause);
            
            
            % set the framerate
            if nargin < 2
                framerate = 50;
            end
            
            % get the dimensions
            dims = obj.selection.getDimensions();
            
            % assure the plot dim to be selected
            plotDim = obj.selection.getPlotDim();
            if ~isempty(plotDim)
                % select plotDim valueChanger
                obj.selection.selectVco(plotDim);
                
                % assure that we are not at end of dimension
                if str2double(obj.selection.getCurrentVcValue()) == dims(1, plotDim)
                    %...rewind, if we are
                    obj.selection.setCurrentVcValue(1)
                end
                
                % loop
                currFrame = str2double(obj.selection.getCurrentVcValue);
                lastFrame = dims(1, obj.selection.getPlotDim);
                for i = currFrame : lastFrame
                    % check if not to stop the movie
                    if ~obj.playAlongDim
                        break;
                    end
                    obj.selection.increaseCurrentVc();
                    pause(1/framerate);
                end
            end
            
            % Replace pause button by a play button
            set(obj.tbh.play,'Tag','Annotation.play',...
                'TooltipString', 'Play along plot dim',...
                'ClickedCallback', @(src, evnt)obj.play,...
                'CData',obj.icons.play);
            
            % set playAlong dim to true
            obj.playAlongDim = false;
            
            
            
            
        end
        
        function stop(obj)
            obj.playAlongDim = false;
        end
        
        
        function createWorkspaceObject(obj)
            assignin('base','asObj',obj)
            disp('handle object was created in workspace variable ''asObj''');
        end
        
        
        function close(obj)
            N = length(obj);
            ms = obj(1).msg;
            ms('destroying %d objects with handles: ',N);
            for i = 1 : N
                if obj(i).isInitialized
                    ms('%f ',obj(i).fh);
                    obj(i).closeReq(obj(i).fh);
                    %                     delete(obj.fh);
                end
            end
            ms('\n');
        end
        
        
        function createRoi(obj, roiPos)
            if nargin < 2
                roiPos = [];
            end
            if isempty(obj.roi) || ~isvalid(obj.roi)
                if isempty(roiPos)
                    obj.selection.enable(false);  % permit change of selection during ROI creation
                    obj.data.enableDestructiveFunctions(false);
                    obj.complexSelect.enable(false);
                    obj.roi = asRoiClass(obj.getCurrentAxesHandle,roiPos,...
                        @obj.roiCallback);
                    obj.selection.enable(true);
                    obj.complexSelect.enable(true);
                    obj.data.enableDestructiveFunctions(true);
                else
                    obj.roi = asRoiClass(obj.getCurrentAxesHandle,roiPos,...
                        @obj.roiCallback);
                end
            else
                obj.roi.setPosition(roiPos);
            end
        end
        
        function pasteRoi(obj)
            posStr = clipboard('paste');
            roiPos = str2num(posStr);
            if ~isempty(roiPos)
                obj.createRoi(roiPos);
            end
        end
        
        function createImageText(obj, str)
            if nargin < 2
                str = [];
            end
            if isempty(obj.imageText) || ~isvalid(obj.imageText)
                obj.imageText = asImageTextClass(obj.getCurrentAxesHandle,str);
            else
                if iscell(str)
                    % compare if the size of str and the array data fits
                    obj.imageText.storeCellArray(str);
                else
                    obj.imageText.setString(str);
                end
            end
            obj.updFig;
        end
        
        function toggleTitleAsImageText(obj)
            switch get(obj.mbh.titleAsImageText,'Checked')
                case 'off'
                    obj.titleAsImageText = true;
                    obj.createImageText(obj.title);
                    set(obj.mbh.titleAsImageText,'Checked','on');
                case 'on'
                    obj.titleAsImageText = false;
                    set(obj.mbh.titleAsImageText,'Checked','off');
                    if isvalid(obj.imageText)
                        cellSel=obj.selection.getValueAsCell;                        % get the selection string
                        for j=1:1:length(cellSel)
                            if cellSel{j} ==  ':'
                                selDim{j}=num2str(1);
                            else
                                selDim{j}=cellSel{j};
                            end
                        end
                        obj.imageText.updateAxesHandle(obj.getCurrentAxesHandle);
                        obj.imageText.setString('', selDim);
                    end
                    obj.updFig;
            end
        end
        
        function toggleAspectRatio(obj)
            switch get(obj.mbh.aspectRatio,'Checked')
                case 'off'
                    set(obj.mbh.aspectRatio,'Checked','on');
                case 'on'
                    set(obj.mbh.aspectRatio,'Checked','off');
            end
            obj.updFig();
        end
        
        function toggleTrueSize(obj)
            switch get(obj.mbh.trueSize,'Checked')
                case 'off'
                    set(obj.mbh.trueSize,'Checked','on');
                case 'on'
                    set(obj.mbh.trueSize,'Checked','off');
            end
            obj.updFig();
        end
        
        function bool = getTrueSizeToggleState(obj)
            switch get(obj.mbh.trueSize,'Checked')
                case 'off'
                    bool = false;
                case 'on'
                    bool = true;
            end
        end
        
        
        function toggleTextboxVisibility(obj)
            switch get(obj.cpcmh.infoText,'Checked')
                case 'on'
                    obj.infotext.setVisible('off');
                    set(obj.cpcmh.infoText,'Checked','off');
                    set(obj.mbh.infoText,'Checked','off');
                case 'off'
                    obj.infotext.setVisible('on');
                    set(obj.cpcmh.infoText,'Checked','on');
                    set(obj.mbh.infoText,'Checked','on');
            end
        end
        
        function showColorbar(obj, bool)
            if nargin < 2
                bool = true;
            end
            if bool
                % enable colorbar
                sel = obj.complexSelect.getSelection();
                if strcmp(sel,'Com')
                    set(obj.tbh.colorbar,'State','off');
                    disp('colorbar not yet available in complex mode');
                else
                    set(obj.tbh.colorbar,'State','on');
                    colorbar('peer',obj.getCurrentAxesHandle);
                end
            else
                % disable colorbar
                set(obj.tbh.colorbar,'State','off');
                colorbar('peer',obj.getCurrentAxesHandle,'off');
                obj.updFig();
            end
        end
        
    end %(public methods)
    
    methods (Access = private)
        function fpos = deriveFigurePos(obj)
            % some dimensions
            fpH = obj.FP_HEIGHT; % home figure height
            cpH = obj.CP_HEIGHT; % control (top) panel height
            bpH = obj.BP_HEIGHT; % bottom panel height
            
            mH = 3;             % estimated height pf menubar + toolbar in cm
            fH = cpH+fpH+bpH;   % figure height
            
            % screen size in centimeters
            originalUnits = get(0,'Units');
            set(0,'Units','centimeters');
            scrS = get(0,'ScreenSize');
            set(0,'Units',originalUnits);
            
            left = 1/4 * scrS(3);
            %             bot  = 1/5 * scrS(4);
            bot = scrS(4) - fH - mH;
            fpos = [left, bot, fpH, fH ];
        end
        
        function initMenuBar(obj)
            % create menubar -------------
            
            
            % file mennu
            mb_file = uimenu(obj.fh,'Label','File');
            % Data to Workspace
            mb_copy2Ws = uimenu(mb_file,'Label','Copy current image to workspace',...
                'Separator','off');
            if isreal(obj.data.dat)
                set(mb_copy2Ws,'callback',@(src,evnt)obj.copyImg2Ws(true,false));
            else
                uimenu(mb_copy2Ws,'Label','selected complex part' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,false));
                uimenu(mb_copy2Ws,'Label','complex array' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,true));
            end
            uimenu(mb_file,'Label','Copy ALL images to workspace',...
                'callback',@(src,evnt)obj.copyImg2Ws(false,true),...
                'Separator','off');
            uimenu(mb_file,'Label','Create Workspace Obj' ,...
                'callback',@(src,evnt)obj.createWorkspaceObject,...
                'Separator','off');
            uimenu(mb_file,'Label','Clone asObj' ,...
                'callback',@(src,evnt)clone);
            uimenu(mb_file,'Label','Save asObj' ,...
                'callback',@(src,evnt)obj.saveObject());
            
            function clone
                obj.storeFigurePosition;
                as(obj)
            end
            
            % save image
            mb_subExport = uimenu(mb_file,'Label','Export current image to file...',...
                'Separator','on');
            uimenu(mb_subExport,'Label','Original data (Strg + e)',...
                'callback',@(src,evnt)obj.exportCurrentImage('',false,false));
            uimenu(mb_subExport,'Label','Frame with roi',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,false));
            uimenu(mb_subExport,'Label','Frame with panels',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,true));
            
            uimenu(mb_file,'Label','Batch export dimension'   ,...
                'callback',@(src,evnt)obj.batchExportDimension);
            
            uimenu(mb_file,'Label','Export image informations to txt file'   ,...
                'callback',@(src,evnt)obj.exportImageInfos);
            
            uimenu(mb_file,'Label','Export colorbar'   ,...
                'callback',@(src,evnt)obj.exportColorbar);
            
            uimenu(mb_file,'Label','Print current image',...
                'callback',@(src,evnt)obj.printCurrentImage);
            
            uimenu(mb_file,'Label','Close','Callback',@(src, evnt)obj.close,...
                'Separator','on');
            
            
            
            
            
            %Operations menu
            mb_operations = uimenu(obj.fh,'Label','Operations');
            uimenu(mb_operations,'Label','Rot90'   ,...
                'callback',@(src, evnt)obj.data.rot90(1),...
                'Separator','off');
            uimenu(mb_operations,'Label','Rot-90'   ,...
                'callback',@(src, evnt)obj.data.rot90(-1),...
                'Separator','off');
            
            uimenu(mb_operations,'Label','FFT all images (F)'   ,...
                'callback',@(src,evnt)obj.data.fft2All,...
                'Separator','on');
            uimenu(mb_operations,'Label','iFFT all images (D)'   ,...
                'callback',@(src,evnt)obj.data.ifft2All);
            uimenu(mb_operations,'Label','fftshift2 all images (G)'   ,...
                'callback',@(src,evnt)obj.data.fftshift2All);
            
            uimenu(mb_operations,'Label','Squeeze'   ,...
                'callback',@(src,evnt)obj.data.squeeze(),...
                'Separator','on');
            uimenu(mb_operations,'Label','Permute'   ,...
                'callback',@(src,evnt)obj.data.permute());
            mb_coldivi = uimenu(mb_operations,'Label','Set colon dim divisor');
            arrShow.populateColonDimDivisorSubmenu(obj,mb_coldivi);
            uimenu(mb_operations,'Label','Set destructive selection string (S)'   ,...
                'callback',@(src,evnt)obj.data.setDestructiveSelectionString());
            
            
            % tools
            mb_tools = uimenu(obj.fh,'Label','Tools');
            % ROI
            uimenu(mb_tools,'Label','Draw ROI'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.createRoi);
            uimenu(mb_tools,'Label','Paste ROI position'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.pasteRoi);
            uimenu(mb_tools,'Label','Surface plot' ,...
                'callback',@(src,evnt)createSurfacePlot,...
                'Separator','on');
            function createSurfacePlot()
                figure;
                surf(obj.getSelectedImages(false))
            end
            uimenu(mb_tools,'Label','Impixelregion (z)'   ,...
                'Separator','off', 'callback',@(src,evnt)impixelregion(obj.fh));
            
            
            
            
            
            
            % relatives
            mb_relatives = uimenu(obj.fh,'Label','Relatives');
            % shortcut to allObjs commands
            uimenu(mb_relatives,'Label','Lineup (l)' ,'callback',@(src,evnt)asLineup);
            uimenu(mb_relatives,'Label','Show title within image (T)' ,'callback',@(src,evnt)asSetAllTitlesToImageString);
            uimenu(mb_relatives,'Label','Browse (b)' ,'callback',@(src,evnt)ab);
            uimenu(mb_relatives,'Label','Close (ESC)' ,'callback',@(src,evnt)asCloseAll);
            
            if ~obj.useGlobalArray
                uimenu(mb_relatives,'Label','Refresh list of relatives (F5)' ,...
                    'callback',@(src,evnt)obj.refreshRelativesList(),...
                    'Separator', 'on');
            end
            
            
            
            
            % view
            mb_view = uimenu(obj.fh,'Label','View');
            obj.mbh.aspectRatio = uimenu(mb_view,'Label','Keep aspect ratio' ,...
                'callback',@(src,evnt)obj.toggleAspectRatio(),...
                'Checked','on');
            obj.mbh.trueSize = uimenu(mb_view,'Label','Keep true size' ,...
                'callback',@(src,evnt)obj.toggleTrueSize(),...
                'Checked','off');
            
            % zoom
            uimenu(mb_view,'Label','Reset zoom' ,...
                'callback',@(src,evnt)obj.setZoom(0),...
                'Separator','on');
            uimenu(mb_view,'Label','Copy zoom (Ctrl + Shift + c)' ,...
                'callback',@(src,evnt)obj.copyZoom);
            uimenu(mb_view,'Label','Paste zoom (Ctrl + Shift + v)' ,...
                'callback',@(src,evnt)obj.pasteZoom);
            uimenu(mb_view,'Label','Send zoom' ,...
                'callback',@(src,evnt)obj.sendZoom);
            
            
            % colormaps
            cmh_stdCmap = uimenu(mb_view,'Label'  ,'Colormap',...
                'Separator','on');
            obj.populateColormapMenu(cmh_stdCmap, @(map)obj.setColormap(map,'standard'));
            cmh_stdCmap = uimenu(mb_view,'Label'  ,'Phase colormap',...
                'Separator','off');
            obj.populateColormapMenu(cmh_stdCmap, @(map)obj.setColormap(map,'phase'));           
            uimenu(mb_view,'Label','Send colormap','callback',@(src,evnt)obj.sendColormapToRelatives());

            
            uimenu(mb_view,'Label','Create image text' ,...
                'callback',@(src,evnt)obj.createImageText(mydlg),...
                'Separator', 'on');
            
            
            % Figure
            mb_figure = uimenu(obj.fh,'Label','Figure');
            uimenu(mb_figure,'Label','Change title (t)'   ,...
                'callback',@(src,evnt)obj.setFigureTitle);
            obj.mbh.titleAsImageText = uimenu(mb_figure,'Label','Show title within image (ctrl + t)'   ,...
                'callback',@(src,evnt)obj.toggleTitleAsImageText);
            
            obj.mbh.infoText = uimenu(mb_figure,'Label','Show Info Textbox'   ,...
                'checked','off',...
                'callback',@(src,evnt)toggleTextboxVisibility(obj));
            
            uimenu(mb_figure,'Label','Half size (Alt + F2)'   ,...
                'callback',@(src,evnt)obj.setFigureSize([341 444]),...
                'Separator','on');
            uimenu(mb_figure,'Label','Reset figure size (Alt + F1)'   ,...
                'callback',@(src,evnt)obj.resetFigurePosition,...
                'Separator','off');
            
            uimenu(mb_figure,'Label','Copy figure size'   ,...
                'callback',@(src,evnt)obj.copyFigureSize());
            
            uimenu(mb_figure,'Label','Paste figure size'   ,...
                'callback',@(src,evnt)obj.pasteFigureSize());
            
            obj.mbh.sendFigSize = uimenu(mb_figure,'Label','Send figure size'   ,...
                'callback',@(src,evnt)obj.toggleSendFigureSize());
        end
        
        function initToolBar(obj)
            %             % modify toolbar
            %             toolBar  = findall(obj.fh,'Type','uitoolbar');
            %             allTools = allchild(toolBar);
            %             delete(allTools([1:3, 5:10, 12:end])) % ( keepTools 4,11);
            %             set(allTools(11),'Separator','off');
            %             set(allTools(4),'Separator','off');
            
            % create toolbar
            toolBar = uitoolbar(obj.fh);
            obj.tbh.base = toolBar;
            
            obj.tbh.colorbar = uitoggletool('Parent',toolBar,'Tag','Annotation.myInsertColorbar',...
                'TooltipString', 'Insert Colorbar',...
                'ClickedCallback', @(src,evnt)colorbarCb(obj),...
                'CData',obj.icons.colorbar);
            function colorbarCb(obj)
                switch(get(obj.tbh.colorbar,'State'))
                    case 'on'
                        obj.showColorbar(true);
                    case 'off'
                        obj.showColorbar(false);
                end
            end
            
            uitoggletool('Parent',toolBar,'Tag','loration.ZoomOut',...
                'TooltipString', 'Zoom Out',...
                'ClickedCallback', @(src, evnt)putdowntext('zoomin',gcbo),...
                'CData',obj.icons.magnify);
            
            
            % add rotate button
            %             defaultColor = get(0,'defaultuicontrolbackgroundcolor');
            uipushtool('Parent',toolBar,'Tag','Annotation.Rot90',...
                'TooltipString', 'Rot90',...
                'ClickedCallback', @(src, evnt)obj.data.rot90(1),...
                'CData',obj.icons.rotLeft,...
                'Separator','on');
            uipushtool('Parent',toolBar,'Tag','Annotation.Rot-90',...
                'TooltipString', 'Rot-90',...
                'ClickedCallback', @(src, evnt)obj.data.rot90(-1),...
                'CData',obj.icons.rotRight,...
                'Separator','off');
            
            if ~obj.useGlobalArray
                uipushtool('Parent',toolBar,'Tag','Annotation.refreshRelativesList',...
                    'TooltipString', 'Refresh list of relatives (F5)',...
                    'ClickedCallback', @(src, evnt)obj.refreshRelativesList,...
                    'CData',obj.icons.refresh,...
                    'Separator','on');
            end
            uipushtool('Parent',toolBar,'Tag','Annotation.asBrowse',...
                'TooltipString', 'Browse list of relatives (b)',...
                'ClickedCallback', @(src, evnt)ab,...
                'CData',obj.icons.asBrowse);
            
            %             uipushtool('Parent',toolBar,'Tag','Annotation.lineup',...
            %                 'TooltipString', 'Lineup asObjs',...
            %                 'ClickedCallback', @(src, evnt)asLineup,...
            %                 'CData',iconRead(fullfile(obj.iconPath,'lineup.png')));
            
            uipushtool('Parent',toolBar,'Tag','Annotation.lineup',...
                'TooltipString', 'Lineup asObjs',...
                'ClickedCallback', @(src, evnt)arrShow.openLineupDlg,...
                'CData',obj.icons.lineup);
            
            
            uipushtool('Parent',toolBar,'Tag','Annotation.sendNone',...
                'TooltipString', 'Deactivate all sendings',...
                'ClickedCallback', @(src, evnt)obj.sendAll(false),...
                'CData',obj.icons.dontSend);
            
            uipushtool('Parent',toolBar,'Tag','Annotation.createWsObj',...
                'TooltipString', 'Create workspace object',...
                'ClickedCallback', @(src, evnt)obj.createWorkspaceObject,...
                'CData',obj.icons.wsObj,...
                'Separator','on');
            
            if obj.linkedToWorkspaceArray
                uipushtool('Parent',toolBar,'Tag','Annotation.reload',...
                    'TooltipString', 'Reload image array from workspace',...
                    'ClickedCallback', @(src, evnt)obj.reloadWorkspaceArray,...
                    'CData',obj.icons.upload,...
                    'Separator','off');
                uipushtool('Parent',toolBar,'Tag','Annotation.put',...
                    'TooltipString', 'Update image array in workspace',...
                    'ClickedCallback', @(src, evnt)obj.updateWorkspaceArray,...
                    'CData',obj.icons.download);
            else
                %                 uipushtool('Parent',toolBar,'Tag','Annotation.put',...
                %                     'TooltipString', 'Copy all images to workspace',...
                %                     'ClickedCallback', @(src,evnt)obj.copyImg2Ws(false,true),...
                %                     'CData',iconRead(fullfile(obj.iconPath,'download.png')),...
                %                     'Separator','on');
            end
            
            % play and stop buttons
            obj.tbh.play = uipushtool('Parent',toolBar,'Tag','Annotation.play',...
                'TooltipString', 'Play along plot dim',...
                'ClickedCallback', @(src, evnt)obj.play,...
                'CData',obj.icons.play,...
                'Separator','on');
        end
        
        function updateDynamicSqueezeButton(obj)
            
            sel = obj.selection.getDimensions;
            
            if any(sel == 1) && length(sel) > 2
                if ~(isfield(obj.tbh,'squeeze') && ishandle(obj.tbh.squeeze))
                    obj.tbh.squeeze = uipushtool('Parent',obj.tbh.base,'Tag','Annotation.squeeze',...
                        'TooltipString', 'Squeeze image array',...
                        'ClickedCallback', @(src, evnt)squeezeCb(obj),...
                        'CData',obj.icons.squeeze);
                end
            end
            function squeezeCb(obj)
                obj.data.squeeze
                delete(obj.tbh.squeeze);
            end
        end
        
        function initContextMenus(obj, infoText)
            % ---------------------------
            % control panel context menu
            % ---------------------------
            obj.cpcmh.base = uicontextmenu;
            obj.cpcmh.infoText = uimenu(obj.cpcmh.base,'Label','Show Info Textbox'   ,...
                'checked','off',...
                'callback',@(src,evnt)toggleTextboxVisibility(obj));
            
            uimenu(obj.cpcmh.base,'Label','Squeeze'   ,...
                'callback',@(src,evnt)obj.data.squeeze(),...
                'Separator','on');
            uimenu(obj.cpcmh.base,'Label','Permute'   ,...
                'callback',@(src,evnt)obj.data.permute());
            mb_coldivi = uimenu(obj.cpcmh.base,'Label','Set colon dim divisor');
            arrShow.populateColonDimDivisorSubmenu(obj,mb_coldivi);
            uimenu(obj.cpcmh.base,'Label','Set selection string (s)'   ,...
                'callback',@(src,evnt)obj.selection.openSetValueDlg());
            uimenu(obj.cpcmh.base,'Label','Set destructive selection string (S)'   ,...
                'callback',@(src,evnt)obj.data.setDestructiveSelectionString());
            
            set(obj.cph,'uicontextmenu',obj.cpcmh.base);
            
            if ~isempty(infoText)
                obj.infotext.setInfotext(infoText);
                obj.infotext.setVisible('on');
                set(obj.cpcmh.infoText,'Checked','on');
                clear('infoText');
            end
            
            
            
            % ---------------------------
            % figure context menu
            % ---------------------------
            
            % ROI
            uimenu(obj.fcmh.base,'Label','Draw ROI'   ,...
                'Separator','on', 'callback',@(src,evnt)obj.createRoi);
            uimenu(obj.fcmh.base,'Label','Paste ROI position'   ,...
                'Separator','off', 'callback',@(src,evnt)obj.pasteRoi);
            
            % colormaps
            cmh_cmap = uimenu(obj.fcmh.base,'Label'  ,'Colormap','Separator','on');
            obj.populateColormapMenu(cmh_cmap, @(map)obj.setColormap(map,'standard'));
            
            % phase colormap
            cmh_cmap1 = uimenu(obj.fcmh.base,'Label'  ,'Phase colormap');
            obj.populateColormapMenu(cmh_cmap1, @(map)obj.setColormap(map,'phase'));
            
            uimenu(obj.fcmh.base,'Label','Send colormap','callback',@(src,evnt)obj.sendColormapToRelatives());
            
            
            % FFT / iFFT
            uimenu(obj.fcmh.base,'Label','Show 2D FFT (f)'  ,...
                'callback',@(src,evnt)obj.data.fft2SelectedFrames(),...
                'Separator','on');
            uimenu(obj.fcmh.base,'Label','Show 2D iFFT (d)' ,...
                'callback',@(src,evnt)obj.data.ifft2SelectedFrames());
            
            % selected image to Workspace
            cmh_copy2Ws = uimenu(obj.fcmh.base,'Label','Copy current image to workspace',...
                'Separator','on');
            if isreal(obj.data.dat)
                set(cmh_copy2Ws,'callback',@(src,evnt)obj.copyImg2Ws(true,false));
            else
                uimenu(cmh_copy2Ws,'Label','selected complex part' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,false));
                uimenu(cmh_copy2Ws,'Label','complex array' ,...
                    'callback',@(src,evnt)obj.copyImg2Ws(true,true));
            end
            
            % save image
            sub3 = uimenu(obj.fcmh.base,'Label','Export current image to file...');
            uimenu(sub3,'Label','Original data (Strg + e)',...
                'callback',@(src,evnt)obj.exportCurrentImage('',false,false));
            uimenu(sub3,'Label','Frame with roi',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,false));
            uimenu(sub3,'Label','Frame with panels',...
                'callback',@(src,evnt)obj.exportCurrentImage('',true,true));
            uimenu(obj.fcmh.base,'Label','Print current image',...
                'callback',@(src,evnt)obj.printCurrentImage);
            
            % image text
            uimenu(obj.fcmh.base,'Label','Create image text' ,...
                'callback',@(src,evnt)obj.createImageText(mydlg),...
                'Separator', 'on');
            
            set(obj.fph,'uicontextmenu',obj.fcmh.base)
            
        end
        
        function populateColormapMenu(obj, menuHandle, cb)
            uimenu(menuHandle,'Label','Custom...'   ,'callback',@(src,evnt)cb([]));
            uimenu(menuHandle,'Label','Edit current map...'    ,'callback',@(src,evnt)colormapEditorCb(obj));
            uimenu(menuHandle,'Label','Store current map...'   ,'callback',@(src,evnt)obj.storeColormap);
            uimenu(menuHandle,'Label','Load map...'            ,'callback',@(src,evnt)obj.loadColormap);
            
            uimenu(menuHandle,'Label','Gray (g)','callback',@(src,evnt)cb('gray(256)'), 'Separator', 'on');
            uimenu(menuHandle,'Label','Gray periodic','callback',@(src,evnt)cb('gray_periodic(256)'));
            uimenu(menuHandle,'Label','martin_phase','callback',@(src,evnt)cb('martin_phase(256)'));
            uimenu(menuHandle,'Label','Red/Green periodic','callback',@(src,evnt)cb('redgreen_periodic'));
            uimenu(menuHandle,'Label','Jet (j)','callback',@(src,evnt)cb('jet(256)'));
            uimenu(menuHandle,'Label','HSV'   ,'callback' ,@(src,evnt)cb('hsv(256)'));
            uimenu(menuHandle,'Label','Hot'   ,'callback' ,@(src,evnt)cb('hot(256)'));
            uimenu(menuHandle,'Label','Cool'  ,'callback' ,@(src,evnt)cb('cool(256)'));
            uimenu(menuHandle,'Label','Spring','callback' ,@(src,evnt)cb('spring(256)'));
            uimenu(menuHandle,'Label','Summer','callback' ,@(src,evnt)cb('summer(256)'));
            uimenu(menuHandle,'Label','Autumn','callback' ,@(src,evnt)cb('autumn(256)'));
            uimenu(menuHandle,'Label','Winter','callback' ,@(src,evnt)cb('winter(256)'));
            uimenu(menuHandle,'Label','Bone'  ,'callback' ,@(src,evnt)cb('bone(256)'));
            uimenu(menuHandle,'Label','Copper','callback' ,@(src,evnt)cb('copper(256)'));
            uimenu(menuHandle,'Label','Pink'  ,'callback' ,@(src,evnt)cb('pink(256)'));
            uimenu(menuHandle,'Label','Lines' ,'callback' ,@(src,evnt)cb('lines(256)'));            
        end
        
        function colormapEditorCb(obj)
            % The matlab colormapeditor allows for altering the colormap
            % even after the program returns from the function call
            % 'colormapeditor'. The 'cmapMightBeModified' workaround causes
            % arrayShow to retrieve the potentially modified from the
            % figure handle during updFig.
            colormapeditor(obj.fh);
            
            if strcmp(obj.complexSelect.getSelection,'Pha')
                obj.phaCmapMightBeModified = true;
            else
                obj.stdCmapMightBeModified = true;
            end
        end
        
    end
    methods (Access = protected)
        
        function closeReq(obj, src)
            obj.msg('executing close request from handle %d\n',src);
            obj.infotext.closeLargeWindow;
            delete(src);
            delete(obj);
            arrShow.cleanGlobalAsArray
        end
        
        function cpResize(obj)
            % controlPanel resize callback
            % (assures, that the control panel keeps it's height)
            oldUnits = get(obj.cph,'Units');
            
            % set units to centimeters and deactivate resize callback
            set(obj.cph,'Units','Centimeters');
            
            
            pos = get(obj.cph,'Position');
            % pos = [left bot width height]
            
            h = obj.CP_HEIGHT;
            offset = pos(4) - h;
            newBot = pos(2) + offset;
            
            newPos = [pos(1), newBot, pos(3), h];
            
            set(obj.cph,'Position',newPos);
            
            % restore settings
            set(obj.cph,'Units',oldUnits);
            
        end
        
        function bpResize(obj)
            % bottom Panel resize callback
            % (assures, that the position panel keeps it's height)
            oldUnits = get(obj.bph,'Units');
            
            % set units to centimeters and deactivate resize callback
            set(obj.bph,'Units','Centimeters');
            
            pos = get(obj.bph,'Position');
            % pos = [left bot width height]
            
            h = obj.BP_HEIGHT;
            
            newPos = [pos(1), pos(2), pos(3), h];
            
            set(obj.bph,'Position',newPos);
            
            % restore settings
            set(obj.bph,'Units',oldUnits);
        end
        
        function fpResize(obj, suppressImageRedraw)
            % figurePanel resize callback
            %             set(obj.fh,'ResizeFcn',[]);
            
            if nargin < 2
                suppressImageRedraw = false;
            end
            
            % backup unit settings
            fhUnits = get(obj.fh,'Units');
            fpUnits = get(obj.fph,'Units');
            
            % set units to centimeters
            set(obj.fh,'Units','Centimeters');
            set(obj.fph,'Units','Centimeters');
            
            % get new size of the home figure
            pos = get(obj.fh,'Position');
            % pos = [left bot width height]
            
            % create new position vector for the figurePanel
            newPos = [0, obj.BP_HEIGHT, pos(3), pos(4) - obj.CP_HEIGHT - obj.BP_HEIGHT ];
            set(obj.fph,'Position',newPos);
            
            % save pixel position to object
            set(obj.fh,'Units','pixel');
            obj.figurePosition = get(obj.fh,'Position');
            
            % restore unit settings
            set(obj.fh,'Units',fhUnits);
            set(obj.fph,'Units',fpUnits);
            
            % call resize functions for control- and bottom panel
            obj.cpResize;
            obj.bpResize;
            
            if ~suppressImageRedraw
                obj.updFig;
            end
            
            if obj.sendWdwSize
                obj.sendFigureSize;
            end
            
            %             set(obj.fh,'ResizeFcn',@(src, evnt)obj.fpResize);
        end
        
        function updFig(obj)
            % reactivate handle visibility
            set(obj.fh,'HandleVisibility','on');
            
            % if the images are not complex,...
            if isreal(obj.data.dat)
                % disable the imag and phase button in the complexSelect
                % object
                obj.complexSelect.lockImagAndPhase(true);
            else
                obj.complexSelect.unlockImagAndPhase;
            end
            
            
            % get the toggle state of 'keep aspect ratio' context menu
            % entry
            switch get(obj.mbh.aspectRatio,'Checked');
                case 'on'
                    aspectRatio = true;
                case 'off'
                    aspectRatio = false;
            end
            
            % check and copy roi object if necessary
            roiPos = [];
            if ~isempty(obj.roi)
                if isvalid(obj.roi)
                    roiPos = obj.roi.getPosition;
                    delete(obj.roi);
                end
            end
            
            % get selected images
            selCplxImgs = obj.getSelectedImages(true);
            
            % isolate selected complex part
            fun = obj.complexSelect.getFunPointer();
            selImgs = fun(selCplxImgs);
            
            % perform postProcessing
            if isempty(obj.postProcFun)
                ppImgs = selImgs;
            else
                try
                    ppImgs = obj.postProcFun(selImgs);
                catch err
                    disp(err);
                    disp(err.message);
                    ppImgs = selImgs;
                    obj.postProcFun = [];
                end
            end
            
            
            % get true size toggle
            trueSize = obj.getTrueSizeToggleState();
            
            % get previous zoom level
            prevDim  = obj.statistics.getDimensions();
            prevZoom = obj.getZoom();
                        
            
            % get colormap for current complexSelection
            cMap = obj.getColormap;
            
            % reset the modified colormap toggles
            obj.phaCmapMightBeModified = false;                                                            
            obj.stdCmapMightBeModified = false;                    
            
            
            % display the images using brShowAllImgs and save image handle
            [allAxes, obj.ih] = imageCollage(...
                ppImgs,...      % postprocessed images
                obj.fph,...     % figure panel handle
                cMap,...        % colormap
                aspectRatio,...          
                trueSize);
            
            noImgs  = length(obj.ih); % number of currently shown images
            
            % assign the original complex image data to the axes handles
            for i = 1 : noImgs
                ud.cplxImg = selCplxImgs(:,:,i);
                set(allAxes(i),'UserData',ud);
            end
            
            % assign context menu to all new images
            for i = 1 : noImgs
                set(obj.ih(i),'uicontextmenu',obj.fcmh.base);
            end
            
            % update image stats- and image windowing object
            if strcmp(obj.complexSelect.getSelection,'Pha')
                obj.window.toggleUsePhaseCW(true);
            else
                obj.window.toggleUsePhaseCW(false);
            end
            
            for i = length(obj.ih): -1 : 1
                obj.window.linkToImage(obj.ih(i));
            end
            obj.statistics.setImageStats(obj.ih(1));
            
            % apply previous zoom level
            newDim  = obj.statistics.getDimensions();
            if all(newDim == prevDim)
                obj.setZoom(prevZoom);
            end
            
            % draw new roi
            if ~isempty(roiPos)
                obj.createRoi(roiPos)
            end
            
            % update imageText axes handle
            if ~isempty(obj.imageText) && isvalid(obj.imageText)
                % update the axes handle
                obj.imageText.updateAxesHandle(obj.getCurrentAxesHandle);
                if obj.titleAsImageText == false
                    % get the imagetext
                    cellSel = obj.selection.getValueAsCell(true);
                    ImageTextCellSize = obj.imageText.getImageTextCellSizeAsCell; % get the selection string
                    ImageSize = obj.getImageDimensions;
                    % get the cell selector and the set selected (':')
                    % dimensions to one
                    for j=1:1:length(cellSel)
                        if cellSel{j} ==  ':'
                            selDim{j}    =num2str(1);
                            ImageSize(j) = 1;
                        else
                            selDim{j}=cellSel{j};
                        end
                    end
                    % set print the imagetext on the asObj
                    if ~isempty(obj.imageText.getImageTextCellSize)
                        for j=1:1:length(cellSel)
                            ImageTextSize(j)=str2num(ImageTextCellSize{j});
                        end
                        % check if the size of the image text array fits the image
                        % size without x and y directions
                        if ImageSize == ImageTextSize
                            obj.imageText.setString('', selDim);
                        else
                            fprintf(1, 'Warning: ImageTextSize does not fit ImageSize.\n');
                        end
                    else
                        str = obj.imageText.getString;
                        obj.imageText.setString(str);
                    end
                else
                    obj.imageText.setString(obj.title);
                end
            end
            
            % insert colorbar (if according button is enabled)
            if strcmp( get(obj.tbh.colorbar,'State'), 'on')
                colorbar('peer',obj.getCurrentAxesHandle);
            end
            
            % update dynamic squeeze button
            obj.updateDynamicSqueezeButton;
            
            
            % prevent main window from becoming target of other graphic
            % outputs
            set(obj.fh,'HandleVisibility','off');
            
            % update cursor position
            obj.cursor.setPosition(obj.cursor.getPosition(),true);
            
            % run user callback function
            if ~isempty(obj.userCallback)
                obj.userCallback(obj);
            end
            
        end
        
        
        function roiCallback(obj, pos)
            obj.applyToRelatives('createRoi',false,pos);
        end
        
        function keyPressCb(obj,evnt, varargin)
            if ~obj.processingCallback
                obj.processingCallback = true;
                
                % if a control key is pressed, alter event.Key string
                if ~isempty(evnt.Modifier)
                    % combine all modifiers to a single string
                    mod = cell2mat(evnt.Modifier);
                    
                    % search the string for keywords
                    if any(strfind(mod,'shift'))
                        evnt.Key = strcat('s',evnt.Key);
                    end
                    if any(strfind(mod,'control'))
                        evnt.Key = strcat('c',evnt.Key);
                    end
                    if any(strfind(mod,'alt'))
                        evnt.Key = strcat('a',evnt.Key);
                    end
                    
                end
                
                switch evnt.Key
                    
                    % image export
                    case 'ce'
                        obj.exportCurrentImage('',false,false);
                        
                        % figure title
                    case 't'
                        obj.setFigureTitle;
                    case 'st'
                        asSetAllTitlesToImageString();
                    case 'ct'
                        obj.toggleTitleAsImageText();
                        
                        
                        % selected image
                    case 's'
                        obj.selection.openSetValueDlg;
                    case 'ss'
                        obj.data.setDestructiveSelectionString()
                        
                        
                        % complex selector
                    case 'm'
                        obj.complexSelect.setSelection('Abs');
                    case 'sm'
                        obj.complexSelect.setSelection('Com');
                        
                    case 'p'
                        obj.complexSelect.setSelection('Pha');
                    case 'sp'
                        obj.cursor.toggleDrawPhaseCircle();
                        
                    case 'r'
                        obj.complexSelect.setSelection('Re');
                    case 'i'
                        obj.complexSelect.setSelection('Im');
                        
                        
                        
                        % FFT
                    case 'f'    %FFT
                        obj.data.fft2SelectedFrames();
                    case 'sf'
                        obj.data.fft2All(); %FFT all
                        
                    case 'd'    %IFFT
                        obj.data.ifft2SelectedFrames();
                    case 'sd'
                        obj.data.ifft2All(); %IFFT all
                        
                    case 'sg'   % fftshift
                        obj.data.fftshift2All;
                        
                        
                        
                        % cursor position
                    case 'x'
                        obj.cursor.send;
                    case 'sx'
                        obj.cursor.toggleSend();
                        
                        
                        
                        % plotAlontDim
                    case 'v'
                        obj.cursor.plotAlongPlotDim;
                    case 'sv'
                        obj.cursor.togglePlotAlongDim();
                        
                        % user cursor position function
                    case 'sc'
                        obj.cursor.toggleCallUserCursorPosFunc;
                    case 'c'
                        obj.cursor.userCursorPosFcn;
                        
                        
                        % colormap
                    case 'j'
                        obj.setColormap('Jet(256)');
                    case 'g'
                        obj.setColormap('Gray(256)');
                    case 'h'
                        obj.setColormap('hot(256)');
                        
                        % windowing
                    case 'cc'
                        obj.window.copyAbsWindow();
                    case 'cv'
                        obj.window.pasteAbsWindow();
                    case 'co'
                        obj.window.loadAbsWindow();
                        
                        
                        % zoom
                    case 'csc'
                        obj.copyZoom();
                    case 'csv'
                        obj.pasteZoom();
                        
                        
                        
                        % selection
                    case {'uparrow', 'downarrow','leftarrow','rightarrow'}
                        if ~isempty(obj.selection)
                            % make sure, that a valueChangerObject is selected
                            %   ( the keypress will also be captured and evaluated
                            %   by this valueChanger)
                            selObjParent = get(get(obj.fh,'CurrentObject'),'Parent');
                            
                            if(isempty(selObjParent)...
                                    || selObjParent ~= obj.selection.getPanelH)
                                obj.selection.selectVco;
                            end
                            
                        end
                        
                        
                        % selected view range (FOV)
                    case 'a1'
                        obj.selection.setColonDimDivisor(1);
                    case 'a2'
                        obj.selection.setColonDimDivisor(2);
                    case 'a3'
                        obj.selection.setColonDimDivisor(3);
                    case 'a4'
                        obj.selection.setColonDimDivisor(4);
                        
                        
                        
                    case 'z'    %impixelregion (ZOOM)
                        impixelregion(obj.fh);
                        
                        
                        % main window size
                    case 'af1'
                        obj.resetFigurePosition
                    case {'af2','f2'}
                        obj.setFigureSize([341 444]);
                        
                        
                    case {'escape','af4'}   %CLOSE
                        obj.closeReq(obj.fh);
                        return;
                    case 'sescape'
                        asCloseAll;
                        return;
                        
                    case 'f5'   % refresh relatives list
                        obj.refreshRelativesList();
                        
                        
                        
                        
                        % relatives
                    case 'b' % asBrowse
                        ab;
                        
                    case 'l' %lineup
                        asLineup();
                    case 'sl'
                        arrShow.openLineupDlg();
                        
                        
                        
                        
                    otherwise
                        switch evnt.Character
                            % position plots
                            case '-'
                                obj.cursor.plotRow();
                            case '|'
                                obj.cursor.plotCol();
                            case '+'
                                obj.cursor.togglePlotRowAndCol();
                                
                        end
                        
                end
                obj.processingCallback = false;
            end
        end
        
        function scollWheelCb(obj,~,evnt)
            switch evnt.VerticalScrollCount
                case -1  %up
                    if ~isempty(obj.selection)
                        if obj.selection.getCurrentVcColonDimTag == 0
                            obj.selection.increaseCurrentVc();
                        else
                            obj.selection.selectNeighbour(1);
                        end
                    end
                case 1  % down
                    if ~isempty(obj.selection)
                        if obj.selection.getCurrentVcColonDimTag == 0
                            obj.selection.decreaseCurrentVc();
                        else
                            obj.selection.selectNeighbour(-1);
                        end
                    end
            end
        end
        
        function buttonDownCb(obj,src,~)
            if ~ishandle(src)
                % sometimes a button down callback seems to be called
                % after the parent window has already been destroyed.
                % this workaround is to avoid occuring errors due to this
                % not yet fully understood bug...
                return;
            end
            
            switch get(src,'SelectionType')
                
                case 'normal' % left button
                    % get selected uiopject
                    selectedUiObj = get(src,'CurrentObject');
                    
                    if strcmp(get(selectedUiObj,'Type'), 'image')
                        currAxes = get(selectedUiObj,'Parent');
                        lastAxes = obj.window.getAxesHandle();
                        if currAxes ~= lastAxes;
                            % delete cursor rectangle from last Axes
                            ud = get(lastAxes,'UserData');
                            if ~isempty(ud) && isfield(ud,'rect')
                                delete(ud.rect);
                                ud.rect = [];
                            end
                            set(lastAxes,'UserData',ud);
                        end
                        obj.window.linkToImage(selectedUiObj);
                        obj.statistics.setImageStats(selectedUiObj);
                    end
                    
                case 'extend'  % middle button
                    % get selected uiopject
                    selectedUiObj = get(src,'CurrentObject');
                    
                    if strcmp(get(selectedUiObj,'Type'), 'image')
                        obj.window.linkToImage(selectedUiObj);
                        currentAxes = obj.window.getAxesHandle();
                        
                        if obj.window.getIsEnabled();
                            obj.mouseWindowingActive = true;
                            obj.mouseWindowingReferencePoint = get(currentAxes,'CurrentPoint');
                        end
                    end
                    
                case 'alt' % right button
                    if obj.mouseWindowingActive
                        %reset the image windowing
                        obj.resetWindowing();
                        obj.mouseWindowingActive = false;
                        obj.equalizeWindowing();
                    end
                    
                case 'open' %double click
                    obj.window.resetWindowing();
                    obj.mouseWindowingActive = false;
                    obj.equalizeWindowing();
            end
            
        end
                
        function buttonUpCb(obj,src)
            if strcmp(get(src,'SelectionType'),'extend')
                obj.mouseWindowingActive = false;
                obj.equalizeWindowing();                                
            end
        end
        
        function equalizeWindowing(obj)
            selectedImageH = obj.window.getImageHandle;
            for i = 1 : length(obj.ih)
                if obj.ih(i) ~= selectedImageH
                    obj.window.linkToImage(obj.ih(i));
                end
            end
            obj.window.linkToImage(selectedImageH);            
        end
        
        function MouseMovementCb(obj)
            
            if ~obj.processingCallback
                obj.processingCallback = true;
                
                if obj.mouseWindowingActive
                    
                    % get the number of pixels, the cursor has moved
                    currentAxes = obj.window.getAxesHandle();
                    refC   = obj.mouseWindowingReferencePoint;
                    currC  = get(currentAxes,'CurrentPoint');
                    
                    % old arrayShow style
                    % difference(1) = -refC(1,1) + currC(1,1);
                    % difference(2) =  refC(1,2) - currC(1,2);

                    % similar to siemens
                    difference(2) = -refC(1,1) + currC(1,1);
                    difference(1) =  refC(1,2) - currC(1,2);

                    
                    % standardize with image dimensions
                    difference = difference .* [1,4] ./ obj.window.getImageDims();
                    
                    % get current center and  width; standardize with image
                    % width
                    CW = obj.window.getCW();
                    imageWidth = obj.window.getDataWidth();
                    CW = CW / imageWidth;
                    
                    % derive and apply new center and width settings
                    CW = (CW + difference) * imageWidth;
                    obj.window.setCW(CW,false);
                    
                    % set current cursor position as new reference
                    obj.mouseWindowingReferencePoint = currC;
                                        
                else % (~obj.mouseWindowingActive)
                    for i = 1 : length(obj.ih)
                        currAxes = get(obj.ih(i),'Parent');
                        position = get(currAxes,'CurrentPoint');
                        
                        if arrShow.mouseInsideAxes(position, currAxes);
                            x = round(position(1,1));
                            y = round(position(1,2));
                            
                            obj.cursor.setPosition([y,x],false);
                            break;
                        end
                        
                    end
                end
                obj.processingCallback = false;
            end
        end
        
        function copyImg2Ws(obj, onlySelectedImg, returnAsComplex)
            global currImg;
            if onlySelectedImg
                currImg = obj.getSelectedImages(returnAsComplex);
            else
                currImg = obj.data.dat;
            end
            evalin('base','global currImg');
            disp('current image was copied to workspace variable ''currImg''');
            disp('size(currImg) =');
            disp(size(currImg));
        end
        
    end
    
    methods (Static)
        
        function As3Obj = convertAs2Obj(As2Obj)
            
            for i = 1 : length(As2Obj)
                
                As3Obj(i) = arrShow(As2Obj(i).getAllImages,...
                    'Title',   As2Obj(i).getFigureTitle,...
                    'info',    As2Obj(i).infotext.getString,...
                    'window',  As2Obj(i).window.getCW(),...
                    'select',  As2Obj(i).selection.getValue,...
                    'colormap',As2Obj(i).getColormap,...
                    'Position',As2Obj(i).getFigurePosition);
                
                if ~isempty(As2Obj(i).UserData)
                    As3Obj(i).UserData = As2Obj(i).UserData;
                end
                
            end
        end
        
        
        function exportAllGlobalArrayImages()
            global asObjs;
            for i = 1 : length(asObjs)
                filename = asObjs(i).title;
                filename(isspace(filename))='_';
                filename = [filename, '.png'];
                asObjs(i).exportCurrentImage(filename);
            end
        end
        
        function newObject = appendToGlobalAsArray(arr, varargin)
            % this static function allows for creating new instances of the arrShow
            % class within a common global workspace array 'asObjs'
            
            arrShow.cleanGlobalAsArray();
            
            global asObjs;
            
            if isa(arr,'arrShow');
                newObj = arr.rebuildObject;
            else
                if  isa(arr,'arrShow2') || isa(arr,'arrShow3')
                    newObj = arrShow.convertAs2Obj(arr);
                else
                    newObj = arrShow(arr, varargin{:});
                end
            end
            
            asObjs = [asObjs,newObj];
            
            evalin('base','global asObjs');
            
            if nargout == 1
                newObject = newObj;
            end
        end
        
        function cleanGlobalAsArray()
            % This static function deletes all handles in the 'asObjs' array, which
            % refer to already deleted objects.
            
            global asObjs;
            
            if ~isempty(asObjs)
                asObjs(~isvalid(asObjs)) = [];
            end
            
            invInds = false(length(asObjs),1);
            for i = 1 : length(asObjs)
                if ~ishandle(asObjs(i).getFigureHandle)
                    invInds(i) = true;
                end
            end
            asObjs(invInds == true) = [];
            
            if isempty(asObjs)
                clear global asObjs;
            end
        end
        
        function in = mouseInsideAxes(position, axesHandle)
            X = get(axesHandle,'XLim');
            Y = get(axesHandle,'YLim');
            x = position(1,1);
            y = position(1,2);
            
            if ( x < X(1) || x > X(2) ||...
                    y < Y(1) || y > Y(2) )
                in = false;
            else
                in = true;
            end
        end
        
        function objects = findAllObjects()
            whosStr = evalin('base','whos');
            si = size(whosStr);
            
            objects = [];
            for i = 1 : si(1)
                if strcmp( whosStr(i).class , 'arrShow' )
                    newObj = evalin('base', whosStr(i).name);
                    for j = 1 : length(newObj)
                        if isvalid(newObj(j)) && ~isListed(objects, newObj(j))
                            if newObj(j).isInitialized
                                objects = [objects, newObj(j)];
                            end
                        end
                    end
                    
                end
            end
            
            function bool = isListed(list, newObj)
                bool = false;
                for o = 1 : length(list)
                    if list(o).eq(newObj)
                        bool = true;
                        return;
                    end
                end
            end
            
        end
        
        function onOff = boolToOnOff(bool)
            switch bool
                case 1
                    onOff = 'on';
                case 0
                    onOff = 'off';
                otherwise
                    error('arrShow:boolToOnOff','input is not a boolean');
            end
        end
        
        function str = removeSpecialCharsFromString(str)
            % remove special characters from initname
            str(isspace(str))='_';
            for i = 1 : length(str)
                switch(str(i))
                    case '.'
                        str(i) = ',';
                    case ':'
                        str(i) = ';';
                    case '<'
                        str(i) = '(';
                    case '>'
                        str(i) = ')';
                    case{'|', '/', '\', '?'}
                        str(i) = '_';
                end
            end
        end
        function A = icoread(filename,varargin)
            try
                A = imread(filename,varargin{:});
            catch ME
                if strcmp(ME.identifier,'MATLAB:imread:fileOpen');
                    A = ones([64,64,3]);
                else
                    throw(ME);
                end
            end
        end
        
    end
    methods (Static, Access = private)
        function populateColonDimDivisorSubmenu(obj,mb_coldivi)
            uimenu(mb_coldivi,'Label','1 (Alt + 1)','callback',@(src,evnt)obj.selection.setColonDimDivisor(1));
            uimenu(mb_coldivi,'Label','2 (Alt + 2)','callback',@(src,evnt)obj.selection.setColonDimDivisor(2));
            uimenu(mb_coldivi,'Label','3 (Alt + 3)','callback',@(src,evnt)obj.selection.setColonDimDivisor(3));
            uimenu(mb_coldivi,'Label','4 (Alt + 4)','callback',@(src,evnt)obj.selection.setColonDimDivisor(4));
        end
        
        function openLineupDlg()
            global asObjs
            suggestion = ['1x',num2str(length(asObjs))];
            newValue = mydlg('Enter ordering','Lineup ordering Dlg',suggestion);
            if ~isempty(newValue)
                [M,N] = strread(newValue,'%d %d',1,'delimiter','x');
                if isempty(M) || isempty(N)
                    warning('lineupDlg:valueCheck','invalid value');
                    return;
                else
                    asLineup(M,N);
                end
            end
        end
        
        function cPlot(y)
            if isreal(y)
                plot(y);
            else
                plot([real(y),imag(y)]);
                %                     legend('real','imag'); % seems to be quite expensive
            end
        end
        
    end
end
