
function [Grad,t]=StdRect(tStart,tEnd,gAmp,step)

%tStart start time
%tEnd end time
%step increment steps
%gAmp amplitude

t=linspace(tStart,tEnd,step);
Grad=gAmp*ones(size(t)); % rectangle


end