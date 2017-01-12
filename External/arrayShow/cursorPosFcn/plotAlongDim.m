function plotAlongDim(asObj,pos,plotDim)


% settings --------------
STAT_Y = 1;   % static y scale
STAT_Y_MODE = 2; % 1 scale image statistic object
                 % 2 scale from global min an max
                 % 3 manual
MANUAL_YLIM = [0,1]; % used only if STAT_Y_MODE = 3


PLOT_STD      = false;  % plot errorbars in ROI mode
DISPLAY_STATS = true;  % BETA: Print some statistics

% complex plot representations
CPLOT_MODE = 3; % 1 = magnitude and phase,
                % 2 = real and imag
                % 3 = real and imag in one window
        % ONLY MODE 3 SUPPORTED YET!!!

START_AT_ZERO = true;   % always start plots at zero point rather than first available TE       

DO_NOT_USE_ROIS = false;    % ignore rois in image and always plot single pixel positions
                
% ----------------------                



% check if we should plot ROI means rather than single pixel values
if DO_NOT_USE_ROIS || isempty(asObj.roi) || ~isvalid(asObj.roi)
    use_roi_mean = false;
else    
    use_roi_mean = true;
end



% get all images in asObject
s = asObj.getAllImages;


% check validity of plotDim
sel = asObj.selection.getValueAsCell;
colDims = sort(asObj.selection.getColonDims);
if isempty(plotDim)
    fprintf('no plot dimension given\n');
    asObj.cursor.togglePlotAlongDim(false);
    return;
end
if plotDim > length(sel)
    fprintf('Selected plot dimension (%d) > number of dims (%d)\n', plotDim, length(sel));
    asObj.cursor.togglePlotAlongDim(false);
    return;    
end
if plotDim == colDims(1) || plotDim == colDims(2)
    fprintf('Selected plot dimension (%d) is not allowed to be a colon dim\n', plotDim);
    asObj.cursor.togglePlotAlongDim(false);
    return;    
end

% create a selection string for the current cursor position and the
% plotDimension
if use_roi_mean
    sel{colDims(1)} = ':';   % if we have a roi, get the complete images 
    sel{colDims(2)} = ':';    
else
    sel{colDims(1)} = num2str(pos(1));    
    sel{colDims(2)} = num2str(pos(2));
end
sel{plotDim} = ':';
selStr = '';
for i = 1 : length(sel)
    selStr = [selStr,sel{i},','];
end
selStr(end) = []; % remove last comma from string
eval(['s=s(',selStr,');']); % get selection


% get selected complex part
cplxFun = asObj.complexSelect.getFunPointer;
isComplexPhasePlot = false;
if strcmp(asObj.complexSelect.getSelection,'Pha') && use_roi_mean
    isComplexPhasePlot = true; % to avoid phase wrapping problems when 
                               % deriving a mean phase value of a roi, we
                               % need to keep the data complex at this
                               % point
else    
    s = cplxFun(s);            % for all selections except phase, we apply 
                               % the selection before possible roi summations
end


% if we want to use the ROI, derive mean within ROI area
if use_roi_mean
    remainingDims = 1:length(size(s));
    remainingDims([colDims,plotDim]) = [];
	s = permute(s,[colDims,plotDim,remainingDims]); % make colon dims the first dimensions
    s = squeeze(s);
    si = size(s);
    StDev = zeros(1, si(1,3));
    roiMask = asObj.roi.createMask;   % apply mask to all images
    s = bsxfun(@times,s,roiMask);
    
    % get the standart deviation
    for i = 1:1:si(1,3)
        StDev(i) = std(nonzeros(s(:,:,i)));
    end
    
    % derive means
    s = squeeze(sum(sum(s,1),2))/asObj.roi.getN;            
    
    if isComplexPhasePlot
        s = cplxFun(s); % if we are dealing with a phase plot, we have to 
                        % derive the phase from the mean complex value now
    end
else
    roiMask = [];
    s = squeeze(s);
end



% if this is the first call...
if isempty(asObj.UserData) ||...
        ~isfield(asObj.UserData,'plotFigHandle') ||...
        ~ishandle(asObj.UserData.plotFigHandle)||...
        ~strcmp(get(asObj.UserData.plotFigHandle,'UserData'),'plotFig')
    
    % create plot window below asObject    
    figPos = asObj.getFigureOuterPosition;
    figPos(2) = figPos(2) - figPos(4) - 26;
    asObj.UserData.plotFigHandle = figure('OuterPosition',figPos,...
        'MenuBar','figure',...
        'ToolBar','none',...
        'UserData','plotFig',...
        'name',asObj.getFigureTitle,...
        'IntegerHandle','off',...
        'CloseRequestFcn',@(src, evnt)closeReqCb(src,asObj));    
    asObj.UserData.plotAxisHandle = axes('parent',asObj.UserData.plotFigHandle);

    
    % lead asObj to calculate and store the global min and max
    updateGlobalRange(asObj,plotDim);
    
    
    % store current complex selection (so that we can recognize possible
    % changes later)
    asObj.UserData.cplxSelection = asObj.complexSelect.getSelection;
    
    % set focus to new plot figure
    figure(asObj.getFigureHandle);    
end

% check, if the complex selection has changed
if ~strcmp(asObj.complexSelect.getSelection, asObj.UserData.cplxSelection)
    % if so, recalculate global minima and maxima
    updateGlobalRange(asObj,plotDim);
    asObj.UserData.cplxSelection = asObj.complexSelect.getSelection;    
end

% create x ticks
if isfield(asObj.UserData,'TE')
    x = asObj.UserData.TE;
else
    N = length(s);
    x = 1 : N;
end

% set plot start x
if START_AT_ZERO
    xStart =0;
else
    xStart = x(1);
end


% get the axis handle for the plot
ah = asObj.UserData.plotAxisHandle;


% plot
if isfield(asObj.UserData,'map') 
    datatipStyle = 'x';
else
    datatipStyle = 'x-';
end
if isreal(s)
    if use_roi_mean && PLOT_STD
        errorbar(x, s, StDev, datatipStyle,'parent',ah);     
    else
        plot(ah,x,s,datatipStyle);    
    end
    ylabel(ah,asObj.complexSelect.getSelection);    
else    
    % complex plot (real and imaginary part)
    cPlot(x,s,'mode',CPLOT_MODE,'parent',ah,datatipStyle);
%     cPlot(s,'x-','parent',ah);    
    ylabel(ah,'real / imag    (blue / green)');
end
xlim(ah,[xStart,x(end)]);    


% set ylim from global mini and maximum
if STAT_Y
    switch(STAT_Y_MODE)
        case 1
            YLIM = [asObj.statistics.getMin, asObj.statistics.getMax];    
            if ~isreal(YLIM)
                YLIM(1) = min(real(YLIM(1)),imag(YLIM(1)));
                YLIM(2) = max(real(YLIM(2)),imag(YLIM(2)));
            end
        case 2
            YLIM = asObj.UserData.range;
        case 3
            YLIM = MANUAL_YLIM;
    end
    ylim(ah,YLIM);            
end


% annotations
if use_roi_mean
    title(ah,sprintf('ROI mean values over dim %d',plotDim));
else
    title(ah,sprintf('Pixel %d / %d over dim %d',pos(1),pos(2),plotDim));
end


% BETA: Print some statistics
if isreal(s) && DISPLAY_STATS  % only supported for real values yet
    mi = min(s);
    ma = max(s);
    me = mean(s);
    ra = ma - mi;
    str = sprintf('\nMin  : %2.2f\nMax  : %2.2f\nRange: %2.2f\nMean : %2.2f',mi,ma,ra,me);    
%     fprintf([str,'\n']);
%     text(0,YLIM(1)',str,'Parent',ah,'VerticalAlignment','bottom');
    text(0,0,str,'Parent',ah,'VerticalAlignment','bottom');
end

end

function updateGlobalRange(asObj,plotDim)
    fprintf('getting global minimum and maximum...');
    th = tic;
    all = asObj.getAllImages;
    
    % (BETA) isolate nonColonDim & nonPlotDim dimension...
    % The current implementation does not call this function at selection
    % changes. This can causes problems, when selection is changed.
    if(true)
        sel = asObj.selection.getValueAsCell;
        sel{plotDim} = ':';
        selStr = '';
        for i = 1 : length(sel)
            selStr = [selStr,sel{i},','];
        end
        selStr(end) = []; % remove last comma from string
        eval(['all=all(',selStr,');']); % get selection
    end

    % get selected complex part
    cplxFun = asObj.complexSelect.getFunPointer;
    all = cplxFun(all);
    
    if isreal(all)
        mi = min(all(:));
        ma = max(all(:));
    else
        mir = min(real(all(:)));
        mar = max(real(all(:)));

        mii = min(imag(all(:)));
        mai = max(imag(all(:)));

        mi = min(mir,mii);
        ma = max(mar,mai);
    end
    asObj.UserData.range = [mi,ma];
    fprintf('   done in %f\n',toc(th));
end
   
function closeReqCb(src, asObj)
    if isvalid(asObj)
        asObj.cursor.togglePlotAlongDim(false)
    end
    delete(src);
end