% MatrixUser, a multi-dimensional matrix analysis software package
% https://sourceforge.net/projects/matrixuser/
% 
% The MatrixUser is a matrix analysis software package developed under Matlab
% Graphical User Interface Developing Environment (GUIDE). It features 
% functions that are designed and optimized for working with multi-dimensional
% matrix under Matlab. These functions typically includes functions for 
% multi-dimensional matrix display, matrix (image stack) analysis and matrix 
% processing.
%
% Author:
%   Fang Liu <leoliuf@gmail.com>
%   University of Wisconsin-Madison
%   Aug-30-2014



function MU_update_func_control(handles)

% if isfield(handles,'Function_tabgroup')
%     return;
% end

% refresh function tabgroup
if isfield(handles,'Function_tabgroup')
    tabs=get(handles.Function_tabgroup,'Children');
    for i=1:length(tabs)
        delete(get(tabs(i),'Children'));
    end
    delete(handles.Function_tabgroup);
    handles = rmfield(handles,'Function_tabgroup');
end

% initialize function bench tabgroup
handles.Function_tabgroup=uitabgroup(handles.Function_uipanel);
handles.FuncStruct=MU_parseXML([handles.path filesep '..' filesep 'FuncLib' filesep 'FuncLib.xml']);
for i=1:numel(handles.FuncStruct.Children)
    handles.(['Func_' handles.FuncStruct.Children(1,i).Name '_tab'])=uitab( handles.Function_tabgroup,'title',handles.FuncStruct.Children(1,i).Name,'Units','normalized');
    s=1; % loop counter for function button
    for j=1:numel(handles.FuncStruct.Children(1,i).Children)
        if strcmp(handles.FuncStruct.Children(1,i).Children(1,j).Attributes(1,4).Value(1),'@') % dimension only sign @
            if numel(handles.V.DimSize)~= str2num(handles.FuncStruct.Children(1,i).Children(1,j).Attributes(1,4).Value(2:end))
                continue;
            end
        else
            if numel(handles.V.DimSize)> str2num(handles.FuncStruct.Children(1,i).Children(1,j).Attributes(1,4).Value)
                continue;
            end
        end
        pushbutton_handle= uicontrol(handles.(['Func_' handles.FuncStruct.Children(1,i).Name '_tab']),'Style', 'pushbutton','Units','normalized',...
                                    'Position', [(s-1)*0.06+0.01 0 0.06 0.9],'TooltipString',handles.FuncStruct.Children(1,i).Children(1,j).Attributes(1,2).Value);  % create pushbutton
        
        MU_icon(pushbutton_handle,[handles.path filesep '..' filesep '..' filesep 'Resource' filesep 'Icon' filesep handles.FuncStruct.Children(1,i).Children(1,j).Attributes(1,3).Value]); % load icon
        
        eval(['set(pushbutton_handle, ''Callback'',{@' handles.FuncStruct.Children(1,i).Children(1,j).Attributes(1,1).Value ',handles});']); % map callback function
        
        handles.(['Func_' handles.FuncStruct.Children(1,i).Name '_' handles.FuncStruct.Children(1,i).Children(1,j).Name '_pushbutton']) = pushbutton_handle;
        s=s+1;
    end
end

% turn off uitab warning
warning('off');
guidata(handles.MU_matrix_display, handles);

end