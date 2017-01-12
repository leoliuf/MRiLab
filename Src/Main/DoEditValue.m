
function DoEditValue(handles,parent_handle,Attributes,AttrhNumber,dims)

% Create Editbox for ajusting attributes at the frame given by parent_handle
% special mark
% '$value' ----popupmenu
% '^value' ----checkbox
% '@' ----static text

TextW=dims(1);
EditW=dims(2);
SpaceW=dims(3);
TextH=dims(4);
EditH=dims(5);
SpaceH=dims(6);

%--old schema
% switch get(parent_handle,'Type')
%     case 'uitab'
%         Position=get(get(get(parent_handle,'Parent'),'Parent'),'Position');
%     case 'uipanel'
%         Position=get(parent_handle,'Position');
% end
% Hpair=floor(Position(4)/(TextH+SpaceH));
% Wpair=floor(Position(3)/(TextW+SpaceW));
%--end

Hpair=floor(1/(TextH+SpaceH));
Wpair=floor(1/(TextW+SpaceW));
ind=1;
for j=1:Wpair
    for i=1:Hpair
        if ind<=length(Attributes)
            Attrh.([Attributes(ind).Name 'Text'])=uicontrol(parent_handle,'Style', 'text', 'String', Attributes(ind).Name,'FontWeight','bold','Units','normalized',...
                                                                    'Position', [(j-1)*(TextW+SpaceW+EditW) (i-1)*(TextH+SpaceH) TextW TextH]);
            eval(['handles.Attrh' num2str(AttrhNumber) '.' Attributes(ind).Name 'Text=Attrh.' Attributes(ind).Name 'Text;']);
            if ~isempty(Attributes(ind).Value)
                switch Attributes(ind).Value(1)
                    case '$'
                        eval(['AttributeOpt={' Attributes(ind).Value(3:end) '};']);
                        Attrh.(Attributes(ind).Name)=uicontrol(parent_handle,'Style', 'popupmenu', 'String', AttributeOpt,'BackgroundColor',[1 1 1],...
                                                                        'Value',str2double(Attributes(ind).Value(2)),'Units','normalized',...
                                                                        'Position', [(j-1)*(TextW+SpaceW+EditW)+TextW (i-1)*(TextH+SpaceH) EditW EditH],...
                                                                        'TooltipString',[Attributes(ind).Name ' : ' Attributes(ind).Value(3:end)]);
                        eval(['handles.Attrh' num2str(AttrhNumber) '.' Attributes(ind).Name '=Attrh.' Attributes(ind).Name ';']);
                    case '^'
                        Attrh.(Attributes(ind).Name)=uicontrol(parent_handle,'Style', 'checkbox', 'String',[],'BackgroundColor',[1 1 1],...
                                                                        'Value',str2double(Attributes(ind).Value(2)),'Units','normalized',...
                                                                        'Position', [(j-1)*(TextW+SpaceW+EditW)+TextW (i-1)*(TextH+SpaceH) EditW EditH],...
                                                                        'TooltipString',[Attributes(ind).Name ' : ' Attributes(ind).Value]);
                        eval(['handles.Attrh' num2str(AttrhNumber) '.' Attributes(ind).Name '=Attrh.' Attributes(ind).Name ';']);
                    case '@'
                        eval(['AttributeOpt=' Attributes(ind).Value(2:end) ';']);
                        Attrh.(Attributes(ind).Name)=uicontrol(parent_handle,'Style', 'text', 'String',AttributeOpt,'Units','normalized',...
                                                                        'Position', [(j-1)*(TextW+SpaceW+EditW)+TextW (i-1)*(TextH+SpaceH) EditW EditH],...
                                                                        'TooltipString',[Attributes(ind).Name ' : ' AttributeOpt]);
                        eval(['handles.Attrh' num2str(AttrhNumber) '.' Attributes(ind).Name '=Attrh.' Attributes(ind).Name ';']);
                    otherwise
                        Attrh.(Attributes(ind).Name)=uicontrol(parent_handle,'Style', 'edit', 'String', Attributes(ind).Value,'Units','normalized','BackgroundColor',[1 1 1],...
                                                                    'Position', [(j-1)*(TextW+SpaceW+EditW)+TextW (i-1)*(TextH+SpaceH) EditW EditH],...
                                                                    'TooltipString',[Attributes(ind).Name ' : ' Attributes(ind).Value]);
                        eval(['handles.Attrh' num2str(AttrhNumber) '.' Attributes(ind).Name '=Attrh.' Attributes(ind).Name ';']);
                end
            else
                Attrh.(Attributes(ind).Name)=uicontrol(parent_handle,'Style', 'edit', 'String', Attributes(ind).Value,'Units','normalized','BackgroundColor',[1 1 1],...
                                                                    'Position', [(j-1)*(TextW+SpaceW+EditW)+TextW (i-1)*(TextH+SpaceH) EditW EditH],...
                                                                    'TooltipString',[Attributes(ind).Name ' : ' Attributes(ind).Value]);
                eval(['handles.Attrh' num2str(AttrhNumber) '.' Attributes(ind).Name '=Attrh.' Attributes(ind).Name ';']);
            end
        end
        ind=ind+1;
    end
end
guidata(parent_handle,handles);
end