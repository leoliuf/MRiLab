
function DoGPUFetch

% fetch data from GPU? time consuming!
% VVar.gpuFetch = 1  fetch data from GPU memory to CPU memory
% VVar.gpuFetch = 0  no GPU data fetching

global VVar

switch VVar.Ext
%% System Reserved Ext Flags (Positive)   
    case 6 % ideal spoiler, dephase Mxy
        VVar.gpuFetch = 1;
    case 8 % trigger object motion
        VVar.gpuFetch = 1;
%% User Defined Ext Flags (Negative)
% add user defined Ext flags here using case
% e.g.    case -5
% change VVar.gpuFetch value according to Ext content
% and whether GPU data is needed










end


end