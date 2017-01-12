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



function MU_enable(flag,Exception,handles)

if strcmp(flag,'on')
    nflag='off';
else
    nflag='on';
end

flaglist={
          'Mouse_wheel'
          'MDimension_tabgroup'
          'Function_tabgroup'
          'MatrixCalc_pushbutton'
          'Upload_pushbutton'
          'Color_map_popmenu'
          'C_upper_slider'
          'C_lower_slider'
          'C_upper_edit'
          'C_lower_edit'
          };

for i=1:max(size(flaglist))
    % mouse wheel
    if strcmp(flaglist{i},'Mouse_wheel')
        if strcmp(flag,'off')
            handles.Wheel = 0;
        else
            handles.Wheel = 1;
        end
        continue;
    end
    
    try
        Type = get(handles.(flaglist{i}),'Type');
    catch me
        continue;
    end
    if strcmp(Type,'uitabgroup')
%         jTabGroup = getappdata(handle(handles.(flaglist{i})),'JTabbedPane');
        if strcmp(flag,'off')
%             jTabGroup.setEnabled(false);  % disable all tabs
            set(handles.(flaglist{i}),'Visible','off');
        else
%             jTabGroup.setEnabled(true);  % enable all tabs
            set(handles.(flaglist{i}),'Visible','on');
        end
        continue;
    end
    if strcmp(Type,'uitab')
        if strcmp(flag,'off')
            set(handles.(flaglist{i}),'Visible','off');
        else
            set(handles.(flaglist{i}),'Visible','on');
        end
        continue;
    end
    eval(['set(handles.' flaglist{i} ',' char(39) 'Enable' char(39) ',' char(39) flag char(39) ');']);
end
if ~isempty(Exception)
    for i=1:max(size(Exception))
        
        if strcmp(Exception{i},'Mouse_wheel')
            if strcmp(nflag,'off')
                handles.Wheel = 0;
            else
                handles.Wheel = 1;
            end
            continue;
        end
        
        Type = get(handles.(Exception{i}),'Type');
        if strcmp(Type,'uitabgroup')
%             jTabGroup = getappdata(handle(handles.(Exception{i})),'JTabbedPane');
            if strcmp(nflag,'off')
%                 jTabGroup.setEnabled(false);  % disable all tabs
                set(handles.(flaglist{i}),'Visible','off');
            else
%                 jTabGroup.setEnabled(true);  % enable all tabs
                set(handles.(flaglist{i}),'Visible','on');
            end
            continue;
        end
        eval(['set(handles.' Exception{i} ',' char(39) 'Enable' char(39) ',' char(39) nflag char(39) ');']);
    end
end
guidata(handles.MU_matrix_display, handles);