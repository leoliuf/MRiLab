

function Plugin_Timer

global VVar
global VCtl

if VVar.TRCount==1
    tic;
    set(VCtl.h.TimeWait_text,'String', ['Est. Time Left:  ' 'Estimating...']);
    pause(0.0001);
%     set(VCtl.h.TimeBar_text,'String', '0%');
else
    elptime=toc;
    tic;
    lefttime=double(VCtl.TRNum-VVar.TRCount+1)*elptime;
    % Convert seconds to other units
    d = floor(lefttime/86400); % Days
    lefttime = lefttime - d*86400;
    h = floor(lefttime/3600); % Hours
    lefttime = lefttime - h*3600;
    m = floor(lefttime/60); % Minutes
    lefttime = lefttime - m*60;
    s = floor(lefttime); % Seconds
    pause(0.0001);
    set(VCtl.h.TimeWait_text,'String', ['Est. Time Left:  ' num2str(h) ' : ' num2str(m) ' : ' num2str(s)]);
%     set(VCtl.h.TimeBar_text,'String',[num2str((double(VVar.TRCount)/double(VCtl.TRNum))*100, '%02.0f') '%']);
    
    DoUpdateBar(VCtl.h.TimeBar_axes,double(VVar.TRCount),double(VCtl.TRNum));
    pause(0.001);
end

end