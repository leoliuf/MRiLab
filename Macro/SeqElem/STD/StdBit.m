
function [Grad,t]=StdBit(tStart,tEnd,gAmp)

%create a minimum signal pulse starting from tStart
%tStart signal pulse start time
%tEnd   signal pulse end time

[Grad,t]=StdRect(tStart,tEnd,gAmp,3); % signal bit
Grad(1)=0;
Grad(end)=0;

end