
% --- Update waitbar
function DoUpdateBar(axes_handle,value,total_value)

% prevent matlab from stealing focus when updating bar
set(0,'CurrentFigure',get(axes_handle,'Parent'));
set(gcf,'CurrentAxes',axes_handle);

set(axes_handle,'Visible','on');
% axes(axes_handle);
cla(axes_handle);
axis(axes_handle,[0,total_value,0,1]);
patch([0,value,value,0],[0,0,1,1],'b','FaceAlpha',0.5);
text(0.5,0.5,[num2str((value/total_value)*100, '%02.0f') '%']);
% axis off;

end