
function [Grad,t]=StdTrap(tStart,tEnd,tUp,tDown,gAmp,sUp,sFlat,sDown)

%tStart trap start time
%tEnd trap end time
%tUp time for up ramp
%tDown time for down ramp
%s* increment steps (for down, up and flat)
%gAmp trapezoid amplitude

[Grad1,gt1]=ramp(tStart,tUp,sUp,0,gAmp);%upramp
[Grad2,gt2]=rect(tUp,tDown,sFlat,gAmp);% flattop
[Grad3,gt3]=ramp(tDown,tEnd,sDown,gAmp,0);%downramp

Grad=[Grad1, Grad2, Grad3];
t=[gt1, gt2, gt3];

[t,m,n]=unique(t);
Grad=Grad(m);

end

function [Grad,t]=ramp(t1,t2,step,amp1,amp2)

t=linspace(t1,t2,step);
Grad=linspace(amp1,amp2,step); %ramp


end

function [Grad,t]=rect(t1,t2,step,amp)

t=linspace(t1,t2,step);
Grad=amp*ones(size(t)); % rectangle


end



