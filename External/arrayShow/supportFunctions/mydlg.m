function R = mydlg(promt, dlg_title, defAns, pos)
if nargin < 4
    pos = [500 500 210 90];
if nargin < 3
    defAns = '';
    if nargin < 2
        dlg_title = '';
        if nargin < 1
            promt = 'Please enter sth.';
        end
    end
end
end

% Returns a double value.
R = []; % Default, in case user closes GUI.
S.fh = figure('units','pixels',...
    'position',pos,...
    'menubar','none',...
    'numbertitle','off',...
    'name',dlg_title,... % Here is the title.
    'resize','off');
S.ed = uicontrol('style','edit',...
    'units','pix',...
    'position',[10 35 pos(3)-20 30],...
    'backgroundcolor','w',...
    'horizontalalignment','left',...
    'string',defAns,...
    'keypressfcn',{@ed_kpfcn});
S.tx = uicontrol('style','text',...
    'units','pix',...
    'position',[10 65 180 20],...
    'backgroundcolor',get(S.fh,'color'),...
    'horizontalalignment','left',...
    'string',promt); % The prompt
S.pb(1) = uicontrol('style','pushbutton',...
    'units','pix',...
    'position',[95 5 50 25],...
    'string','O.k.',... % The O.k. button.
    'callback',{@pb_call,S});
S.pb(2) = uicontrol('style','pushbutton',...
    'units','pix',...
    'position',[150 5 50 25],...
    'string','Cancel',... % The cancel button.
    'callback',{@pb_call,S});
uicontrol(S.ed) % Put blinking cursor in edit box.
uiwait(S.fh) % Wait till the GUI closes.
if isempty(R)
    R = []; % So we return a double, not an empty string or nan.
else
%     R = str2double(R);
end

    function [] = pb_call(varargin)
    % Callback for pushbuttons.
        if varargin{1}==S.pb(1)
            R = get(S.ed,'string');
        end
        close(S.fh)
    end

    function [] = ed_kpfcn(varargin)
    % Keypressfcn for editbox. Could be modified to delete any input
    % except for 3 or 4.
    switch varargin{2}.Key
        case 'return'
            drawnow
            R = get(S.ed,'string');
            close(S.fh);
        case 'escape'
            R = [];
            close(S.fh);
            
    end  
    end
end 