
function [Grad,t]=StdRamp(tStart,tEnd,gAmp1,gAmp2,step)

%tStart start time
%tEnd end time
%step increment steps
%gAmp1 starting amplitude
%gAmp2 ending amplitude

t=linspace(tStart,tEnd,step);
Grad=linspace(gAmp1,gAmp2,step); %ramp

end