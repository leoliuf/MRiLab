%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)

function asBrowse(objs) 

if nargin < 1 || isempty(objs)
    objs = arrShow.findAllObjects;
    tit = 'asBrowse( global asObjs array )';
    par.workOnGlobalArray = true;
else
    tit = ['asBrowse(',inputname(1),')'];
    par.workOnGlobalArray = false;
end

if isempty(objs)
    error('asBrowse:noObjs','no arrShow objects found');
end

par.objs       = objs;
par.objsBackup = objs;

% create main figure
par.figureHandle = figure(  'MenuBar','none',...
    'Name',tit,...
    'NumberTitle','off',...
    'Visible','off');
set(par.figureHandle,'WindowKeyPressFcn',@(src, evnt)abKeyPressCb(evnt, par.figureHandle));

% set heigth of the figure to 1 to avoid GUI "flashing effect"
pos = get(par.figureHandle,'position');
set(par.figureHandle,'position',[pos(1:3),1]);

% create toolbar
iconpath = [fileparts(mfilename('fullpath')), filesep, 'icons'];
toolBar = uitoolbar(par.figureHandle);
uipushtool('Parent',toolBar,'Tag','Annotation.refreshRelativesList',...
    'TooltipString', 'Refresh list of relatives',...
    'ClickedCallback', @(src,evnt)refreshTable(par.figureHandle),...
    'CData',iconRead(fullfile(iconpath,'refresh.png')));
uipushtool('Parent',toolBar,'Tag','Annotation.sortByFigureNumber',...
    'TooltipString', 'Sort asObjs array by figure number',...
    'ClickedCallback', @(src,evnt)sortByFigureNumber(par.figureHandle));


% create header
ColumnName  = {'Show','Focus','Title', 'dim', 'norm', 'min', 'mean', 'max'};
noCols      = length(ColumnName);
par.noCols  = noCols;
RowName     = 'numbered';

% set editable
columneditable      = false(1,noCols);
columneditable(1)   = ~par.workOnGlobalArray; % show-column is only
                                              % editable only if we are not 
                                              % working on the global 
                                              % asObjs array
columneditable(3)   = true;     % the title-column


% create context menu -----------------------
par.cMenuHandle = uicontextmenu;
uimenu(par.cMenuHandle,'Label','Lineup objects' ,...
    'callback',@(src,evnt)lineupCb(par.figureHandle));
uimenu(par.cMenuHandle,'Label','Minimize figure' ,...
    'callback',@(src,evnt)minimizeCb(par.figureHandle));
uimenu(par.cMenuHandle,'Label','Close' ,...
    'callback',@(src,evnt)closeCb(par.figureHandle));

% multi object operations
uimenu(par.cMenuHandle,'Label','Difference to last selected' ,...
    'callback',@(src,evnt)diffCb(par.figureHandle),...
    'Separator','on');
uimenu(par.cMenuHandle,'Label','Abs wdw from last selected' ,...
    'callback',@(src,evnt)absWdwCb(par.figureHandle));
uimenu(par.cMenuHandle,'Label','Compare infotext' ,...
    'callback',@(src,evnt)compareInfotext(par.figureHandle));



uimenu(par.cMenuHandle,'Label','Create WS object' ,'Separator','on',...
    'callback',@(src,evnt)createWorkspaceObject(par.figureHandle));
uimenu(par.cMenuHandle,'Label','Save selected objects' ,...
    'callback',@(src,evnt)saveSelectedObjects(par.figureHandle));

% cmenu: export selected images
sub2 = uimenu(par.cMenuHandle,'Label','Export selected objects current image');
uimenu(sub2,'Label','use title as filename' ,...
    'callback',@(src,evnt)exportImages(par.figureHandle,'.png',false,false));
uimenu(sub2,'Label','use title and add appendix' ,...
    'callback',@(src,evnt)exportImages(par.figureHandle,'.png',true,false));
uimenu(sub2,'Label','use title, add appendix and include overlays' ,...
    'callback',@(src,evnt)exportImages(par.figureHandle,'.png',true,true));

uimenu(par.cMenuHandle,'Label','batch export' ,...
    'callback',@(src,evnt)batchExport(par.figureHandle));



% cmenu: title manipulation
sub1 = uimenu(par.cMenuHandle,'Label','all titles...' ,...
    'Separator','on');
uimenu(sub1,'Label','change' ,...
    'callback',@(src,evnt)changeAllTitles(par.figureHandle,'replace'));
uimenu(sub1,'Label','add to end' ,...
    'callback',@(src,evnt)changeAllTitles(par.figureHandle,'end'));
uimenu(sub1,'Label','add to beginning' ,...
    'callback',@(src,evnt)changeAllTitles(par.figureHandle,'start'));
uimenu(sub1,'Label','delete N chars from beginning' ,...
    'callback',@(src,evnt)deleteCharsFromTitles(par.figureHandle,'start'),...
    'Separator','on');
uimenu(sub1,'Label','delete N chars from end' ,...
    'callback',@(src,evnt)deleteCharsFromTitles(par.figureHandle,'end'));

uimenu(par.cMenuHandle,'Label','selected images' ,...
    'callback',@(src,evnt)setSelectedImages(par.figureHandle));



uimenu(par.cMenuHandle,'Label','Refresh table' ,...
    'callback',@(src,evnt)refreshTable(par.figureHandle),...
    'Separator','on');

% ----------------------------------------


% create table
par.tableHandle = uitable('ColumnName',ColumnName,...
    'RowName',RowName,...
    'ColumnEditable', columneditable,...
    'Units','normalized',...
    'Position',[0,0,1,1],...
    'UIContextMenu',par.cMenuHandle,...
    'Enable','on',...
    'HitTest','on',...
    'SelectionHighlight','off',...
    'CellEditCallback',@(src,evnt)cellEditCb(par.figureHandle,evnt),...
    'CellSelectionCallback',@(src,evnt)cellSelectCb(par.figureHandle,evnt));
%'FontName','FixedWidth');


% Set all column width except the first to 'auto'
cWidth = cell([1,noCols]);
for i = 2 : noCols
    cWidth{i} = 'auto';
end

% create an empty selection
par.selection = [];

% write parameter to main figure userData
set(par.figureHandle,'UserData',par);

% create table data
updateTableData(par.figureHandle);

% enable GUI visibility (I'd like to do that after updating the column
% width. However, this doen't seem to work properly as the table property 
% "extend" doesn't seem to be correctly calculated within an invisible 
% figure :-/ )
set(par.figureHandle,'Visible','on');

% set first column size to length the longest title
updateColumnWidth(par.figureHandle)

set(par.figureHandle,'HandleVisibility','off');
end




% -----------------------------------------
% table related functions
% -----------------------------------------


function refreshTable(fh)
if ishandle(fh)
    set(fh,'HandleVisibility','on');
    updateTableData(fh);
    updateColumnWidth(fh);
    set(fh,'HandleVisibility','off');
end
end

function sortByFigureNumber(fh)
par = get(fh,'UserData');
if(par.workOnGlobalArray)
    % find new objects
    objs = arrShow.findAllObjects;
    N = length(objs);
    figureNumbers = zeros(N,1);
    
    for i = 1 : N
        figureNumbers(i) = objs(i).getFigureHandle;
    end
    
    [~,inds] = sort(figureNumbers);
    
    objs = objs(inds);
    
    global asObjs 
    asObjs = objs;
end
refreshTable(fh);
end

function updateTableData(fh)
% set first cSize to length the longest title
par = get(fh,'UserData');

if(par.workOnGlobalArray)
    % find new objects
    objs = arrShow.findAllObjects;
else
    % restore destroyed objects from backup
    objs = par.objs;
    invinds = find(~isvalid(objs));
    objs(invinds) = par.objsBackup(invinds);
    %         objs(~isvalid(objs)) = [];
end

noObjs = length(objs);
par.objs = objs;
set(fh,'UserData',par);


% create data cells
Data = cell([noObjs, par.noCols]);
for i = 1 : noObjs
    
    % cell1: 'Show'
    Data{i,1} = objs(i).isInitialized;
    
    % cell2: 'Fig'
    Data{i,2} = num2str(objs(i).getFigureHandle);
    
    % cell3: 'Title'
    Data{i,3} = objs(i).getFigureTitle;
    
    % cell4: 'Dims'
    Data{i,4} = num2str(objs(i).getImageDimensions);
    
    % cell 5 - 8: min mean max norm
    if objs(i).isInitialized
        stats = objs(i).statistics.getImageStats;
        Data{i,5} = num2str(stats(4)); % norm
        Data{i,6} = num2str(stats(1)); % min
        Data{i,7} = num2str(stats(2)); % mean
        Data{i,8} = num2str(stats(3)); % max
    else
        for j = 5 : 8
            Data{i,j} = '';
        end
    end
end
set(par.tableHandle,'Data',Data);
end

function updateColumnWidth(fh)
% set first cSize to length the longest title

% fixed size for the 'show'-column
cWidth{1} = 33;

% fixed size for the 'focus'-column
cWidth{2} = 35;

par      = get(fh,'UserData');
Data     = get(par.tableHandle,'Data');
if ispc
    charSize = 10; %pixel
else
    charSize = 11; %pixel
end
maxWidth = 40 * charSize;
minWidth = 6 * charSize;
noChars  = findMaxLength(Data,3) + 1; % leave one additional char space
if isempty(noChars)
    noChars = 1; % this strange line is necessary, because if 'findMaxLength'
    %    returns [], than ([] + 1) stays [] in matlab...
end
cWidth{3} = noChars * charSize;
cWidth{3} = min(cWidth{3}, maxWidth);
cWidth{3} = max(cWidth{3}, minWidth);
set(par.tableHandle,'ColumnWidth',cWidth);

adaptWindowSize(fh);
end


function cellEditCb(fh, evnt)
% callback is executed whenever a table entry has been

% get selection
index = evnt.Indices;

if ~isempty(index)
    selRow = index(end,1); % selected row
    selCol = index(end,2); % selected column
    
    % save selection to par struct
    par           = get(fh,'UserData');
    par.selection = index;
    set(fh,'UserData',par);
    
    % figure out, what column has been changed and call the according
    % function
    switch selCol
        
        case 1 % the 'show'-column
            toggleShowSelectedFigure(fh);
            
        case 3 % the title column
            Data     = get(par.tableHandle,'Data');
            newTitle = Data{selRow,selCol};
            selObj   = getSelectedObjects(fh);
            selObj.setFigureTitle(newTitle);
            updateColumnWidth(fh);
            
        otherwise
            %nop
    end
end

end

function cellSelectCb(fh, evnt)

% get selection
index = evnt.Indices;

if ~isempty(index)
    par = get(fh,'UserData');
    
    if isempty(par.selection)
        prevSelect = [];
    else
        prevSelect = par.selection(:,1);
    end
    
    newSelect =  elementsNotInArr2(index(:,1),prevSelect);
    if isempty(newSelect)
        newSelect = index(:,1);
    end
    
    if length(newSelect) == 1
        lastSelect = newSelect;
    else
        if ~isempty(prevSelect) && prevSelect(end) < newSelect(end)
            lastSelect = newSelect(end);
        else
            lastSelect = newSelect(1);
        end
    end
    par.selection = index;
    par.lastSelectedRow = lastSelect;
    
    set(fh,'UserData',par);
    
    % check if row 2 is selected
    if index(end,2) == 2
        putWindowOnTop(par,index(end,1));
    end
end
end

function adaptWindowSize(fh)
par = get(fh,'UserData');

origTableUnits = get(par.tableHandle,'Units');
origFigureUnits= get(fh,'Units');

set(par.tableHandle,'Units','pixels');
tableSize = get(par.tableHandle,'Extent');
set(par.tableHandle,'Units',origTableUnits);

set(fh,'Units','pixels');
figureSize= get(fh,'Position');

h1 = figureSize(4);
b1 = figureSize(2);
h2 = tableSize(4);
b2 = b1 - (h2 - h1);

figureSize(2) = b2;
figureSize(3:4) = tableSize(3:4);

set(fh, 'Position', figureSize);

set(fh,'Units',origFigureUnits);

end

function putWindowOnTop(par,selectedRow)
% check, if the selected window is initialized
selObj = par.objs(selectedRow);

if ~isvalid(selObj)
    % restore backup
    par.objs(selectedRow) = par.objsBackup(selectedRow);
    
    % set table boolean to false
    Data = get(par.tableHandle,'Data');
    Data{selectedRow,1} = false;
    set(par.tableHandle,'Data',Data);
else
    if selObj.isInitialized
        % put selected asObj on top
        selObj.putFigureOnTop;
    end
end
end


function l = findMaxLength( cellArr, col)
noRows = size(cellArr,1);
l = [];
for i = 1 : noRows
    l = max([ length(cellArr{i,col}) , l]);
end
end

function selObj = getSelectedObjects(fh)
par   = get(fh,'UserData');
index = par.selection;
selObj = par.objs(index(:,1));
end


% -----------------------------------------
% functions to manipulate arrShow objects
% -----------------------------------------

function createWorkspaceObject(fh)
selObjs = getSelectedObjects(fh);
selObjs(end).createWorkspaceObject;
end

function changeAllTitles(fh, mode)

newText = inputdlg;

% get selected objects
selObjs = getSelectedObjects(fh);

for i = 1 : length(selObjs)
    switch mode
        case 'replace'
            newTitle = newText{1};
        case 'start'
            newTitle = [newText{1},selObjs(i).getFigureTitle];
        case 'end'
            newTitle = [selObjs(i).getFigureTitle, newText{1}];
    end
    if iscell(newTitle)
        newTitle = cell2mat(newTitle);
    end
    selObjs(i).setFigureTitle(newTitle);
end
refreshTable(fh);
end

function deleteCharsFromTitles(fh,mode)
noChars = inputdlg;
noChars = str2num(noChars{1});

% get selected objects
selObjs = getSelectedObjects(fh);

for i = 1 : length(selObjs)
    fullTitle = selObjs(i).getFigureTitle;
    switch mode
        case 'start'
            newTitle = fullTitle(noChars +1 : end);
        case 'end'
            newTitle = fullTitle(1 : end - noChars);
    end
    if iscell(newTitle)
        newTitle = cell2mat(newTitle);
    end
    selObjs(i).setFigureTitle(newTitle);
end
refreshTable(fh);

end

function exportImages(fh, fileExtension, addAppendix, saveRoi)

if addAppendix
    appendix = inputdlg;
    appendix = appendix{1};
else
    appendix = '';
end


% get selected objects
selObjs = getSelectedObjects(fh);

for i = 1 : length(selObjs)
    initName = selObjs(i).getFigureTitle;
    
    % remove special characters from initname
    initName(isspace(initName))='_';
    for j = 1 : length(initName)
        switch(initName(j))
            case '.'
                initName(j) = ',';
            case ':'
                initName(j) = ';';
            case '<'
                initName(j) = '(';
            case '>'
                initName(j) = ')';
            case{'|', '/', '\', '?'}
                initName(j) = '_';
        end
    end
    
    initName = [initName, appendix];
    
    selObjs(i).exportCurrentImage([initName,fileExtension], saveRoi);
end


end

function saveSelectedObjects(fh)
initName = 'asObjects';

% promt user tu pick a filename
[fileName, filePath] = uiputfile({'*.mat'},'Save asObjects as', initName);

if fileName == 0
    return;
end
% choose a variable name for the asObjects, which is the filename
% without the tailing '.mat'
storeVarName = textscan(fileName,'%s %s','delimiter','.');
storeVarName = storeVarName{1}{1};

% get selected objects
selObjs = getSelectedObjects(fh);

% remove possible links to relatives and store objects position
for i = 1 : length(selObjs)
    selObjs(i).wipeRelativesList;
    selObjs(i).storeFigurePosition;
end

% copy objects to a variable named like the file
eval([storeVarName, ' = selObjs;']);

% ...write the variable to harddisk
fprintf('saving data...   ');
tic;
save(fullfile(filePath,fileName),storeVarName, '-v7.3');
fprintf('done in %2.2f seconds.\n',toc);
end

function setSelectedImages(fh)
% get selected objects
selObjs = getSelectedObjects(fh);

% get selection string
str = inputdlg('Enter selection','',1,{selObjs(1).selection.getValue});

if ~isempty(str)
    for i = 1 : length(selObjs)
        selObjs(i).selection.setValue(str{1});
    end
end
end

function toggleShowSelectedFigure(fh)

par   = get(fh,'UserData');
index = par.selection;
Data  = get(par.tableHandle,'Data');


selObj = par.objs(index(end,1));

if par.workOnGlobalArray
    % check, if the selected window is not already deleted
    if isvalid(selObj)
        % close it
        selObj.close;
    end
    % refresh table data
    refreshTable(fh);
    
else
    
    if isvalid(selObj)
        
        if selObj.isInitialized
            % close it
            selObj.close;
            
            % set table boolean to false
            Data{index(end,1),1} = false;
            
            % restore backup
            par.objs(index(end,1)) = par.objsBackup(index(end,1));
        else
            % rebuild object
            newObj = selObj.rebuildObject;            
            par.objs(index(end,1))= newObj;
            
            % append to global array
            arrShow.cleanGlobalAsArray();
            evalin('base','global asObjs');
            global asObjs;
            asObjs = [asObjs,newObj];
            
            % set table boolean to true
            Data{index(end,1),1} = true;
        end
    else
        % restore backup
        par.objs(index(end,1)) = par.objsBackup(index(end,1));
        
        % set table boolean to false
        Data{index(end,1),1} = false;
        
    end
    set(par.tableHandle,'Data',Data);
    set(fh,'UserData',par);
end

end

function minimizeCb(fh)
par = get(fh,'UserData');

% get selected rows
sel = par.selection(:,1);

for i = 1 : length(sel)
    par.objs(sel(i)).minimizeFigure;
end

end

function lineupCb(fh)
par = get(fh,'UserData');

% get selected rows
sel = par.selection(:,1);

% treat the last selected object as reference
refObj = par.objs(par.lastSelectedRow);

asLineup([refObj,par.objs(sel)]);

end

function diffCb(fh)
par = get(fh,'UserData');

% get selected rows
sel = par.selection(:,1);

% treat the last selected object as reference
refObj = par.objs(par.lastSelectedRow);

asMultiDiffMaps([refObj,par.objs(sel)]);

refreshTable(fh);

end

function compareInfotext(fh)
par = get(fh,'UserData');

% get selected rows
sel = par.selection(:,1);

% check number of selected objects
if length(sel) > 2
    fprintf('need exactly 2 selected asObjs\n');
    return
end

% get objects
obj1 = par.objs(sel(1));
obj2 = par.objs(sel(2));

% create temporary info text files
mfn =mfilename('fullpath'); % get mfile name and oath
mfn = fileparts(mfn); % isolate path
fi1 = fullfile(mfn,'infotextTemp1.txt');
fi2 = fullfile(mfn,'infotextTemp2.txt');

% add current figure numbers to the beginning of the files
fid = fopen(fi1,'wt');
fprintf(fid,'Figure: %d\n\n',obj1.getFigureHandle);
fclose(fid);
fid = fopen(fi2,'wt');
fprintf(fid,'Figure: %d\n\n',obj2.getFigureHandle);
fclose(fid);

% append infotext to files
obj1.exportImageInfos(fi1,true);
obj2.exportImageInfos(fi2,true);


% compare files
visdiff(fi1,fi2);

% delete temporary files 
% this unfortunately does not work since it drives visdiff into trouble...
% delete([mfn,filesep,'infotextTemp*.txt']);


end

function batchExport(fh)

    % get batch export dimension    
    dim = mydlg('Enter dimension','Enter dimension for batch export',3);
    dim = str2double(dim);
    if isnan(dim)
        return
    end            
    
    % get selected objects
    selObjs = getSelectedObjects(fh);
    
    wh = waitbar(0);
    noObjs = length(selObjs);
    for i = 1 : noObjs
        waitbar(i/noObjs,wh);
        selObjs(i).batchExportDimension(dim);
    end
    if ~isempty(wh) && ishandle(wh)
        close(wh);
    end
end
function absWdwCb(fh)
par = get(fh,'UserData');

% get selected objs
selObjs = par.objs(par.selection(:,1));

% treat the last selected object as reference
refObj = par.objs(par.lastSelectedRow);

refCW = refObj.window.getCW;
for i = 1 : length(selObjs)
    selObjs(i).window.setCW(refCW);
end

end

function closeCb(fh)
par = get(fh,'UserData');

% get selected rows
sel = par.selection(:,1);

par.objs(sel).close;

refreshTable(fh)

end

function el = elementsNotInArr2(arr1, arr2)
l1 = length(arr1);
l2 = length(arr2);
for i = 1 : l1
    for j = 1 : l2;
        if arr1(i) == arr2(j)
            arr1(i) = -1;
        end
    end
end
el = arr1(arr1~=-1);
end


function abKeyPressCb(evnt, fh)
switch evnt.Key
    case 'f5'   % refresh relatives list
        refreshTable(fh);
end

end