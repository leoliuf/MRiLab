function showwindow(name,state)
%SHOWWINDOW Change the state of a window.
%   SHOWWINDOW(NAME,STATE) changes the state of the window with a certain NAME
%   to the specified STATE.  STATE must be one of the following:
%
%   'hide','shownormal','normal','showminimized','showmaximized','maximize',
%   'shownoactivate','show','minimize','showminnoactive','showna','restore',
%   'showdefault','forceminimize','max'
%
%   This page describes the difference between these states:
%
%   <http://msdn.microsoft.com/library/en-us/winui/winui/windowsuserinterface/windowing/windows/windowreference/windowfunctions/showwindow.asp>
%
%   FORCEMINIMIZE Windows 2000/XP: Minimizes a window, even if the thread that
%   owns the window is hung. This flag should only be used when minimizing
%   windows from a different thread.
% 
%   HIDE Hides the window and activates another window.
% 
%   MAXIMIZE Maximizes the specified window.
% 
%   MINIMIZE Minimizes the specified window and activates the next top-level
%   window in the Z order.
% 
%   RESTORE Activates and displays the window. If the window is minimized or
%   maximized, the system restores it to its original size and position. An
%   application should specify this flag when restoring a minimized window.
% 
%   SHOW Activates the window and displays it in its current size and position. 
% 
%   SHOWDEFAULT Sets the show state based on the SW_ value specified in the
%   STARTUPINFO structure passed to the CreateProcess function by the program
%   that started the application. 
% 
%   SHOWMAXIMIZED Activates the window and displays it as a maximized window.
% 
%   SHOWMINIMIZED Activates the window and displays it as a minimized window.
% 
%   SHOWMINNOACTIVE Displays the window as a minimized window. This value is
%   similar to SW_SHOWMINIMIZED, except the window is not activated.
% 
%   SHOWNA Displays the window in its current size and position. This value is
%   similar to SW_SHOW, except the window is not activated.
% 
%   SHOWNOACTIVATE Displays a window in its most recent size and position. This
%   value is similar to SW_SHOWNORMAL, except the window is not actived.
% 
%   SHOWNORMAL Activates and displays a window. If the window is minimized or
%   maximized, the system restores it to its original size and position. An
%   application should specify this flag when displaying the window for the
%   first time.
%
%   Examples:
%   >> showwindow('MATLAB','minimize')
%   >> showwindow('','minimize')
%   >> figure(4); showwindow('Figure No. 4','maximize'); text(.5,.5,'Simoneau')

% Matthew J. Simoneau
% Copyright 2003 The MathWorks, Inc.

if ~ispc
    % The Task Manager is only on Windows.
    return;
end

if ~libisloaded(mfilename);
    loadlibrary('user32.dll',@userproto,'alias',mfilename);
end


% From WINUSER.H (via WINDOWS.H):
% ShowWindow() Commands
switch state
    case 'hide', flag = 0;
    case 'shownormal', flag = 1;
    case 'normal', flag = 1;
    case 'showminimized', flag = 2;
    case 'showmaximized', flag = 3;
    case 'maximize', flag = 3;
    case 'shownoactivate', flag = 4;
    case 'show', flag = 5 ;
    case 'minimize', flag = 6 ;
    case 'showminnoactive', flag = 7 ;
    case 'showna', flag = 8 ;
    case 'restore', flag = 9 ;
    case 'showdefault', flag = 10;
    case 'forceminimize', flag = 11;
    case 'max', flag = 11;
    otherwise, error('Unknown state "%s".',state);
end

h = calllib(mfilename,'FindWindowA',[],name);
calllib(mfilename,'ShowWindow',h,flag);


%===============================================================================
function [fcns,structs,enuminfo] = userproto

fcns=[]; structs=[]; enuminfo=[]; fcns.alias={};

%  HWND _stdcall FindWindowA(LPCSTR,LPCSTR); 
fcns.name{1} = 'FindWindowA';
fcns.calltype{1} = 'stdcall';
fcns.LHS{1} = 'voidPtr';
fcns.RHS{1} = {'int8Ptr', 'string'};

%  BOOL _stdcall ShowWindow(HWND,int); 
fcns.name{2} = 'ShowWindow';
fcns.calltype{2} = 'stdcall';
fcns.LHS{2} = 'int32';
fcns.RHS{2} = {'voidPtr', 'int32'};
