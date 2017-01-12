
%%%%%%%%%%%%%%%%%%%% MRiLab setup%%%%%%%%%%%%%%%%%%%%%%
function MRiLab

    warning off; % disable warning
    
    [pathstr,name,ext]=fileparts(mfilename('fullpath'));
    addpath(genpath(pathstr));
    % Remove unnessary search path
    rmpath(genpath([pathstr filesep '.git']));
    rmpath(genpath([pathstr filesep 'Doc']));
    % Open MRiLab main panel
    SimuPanel(pathstr);
    clear pathstr name ext
end