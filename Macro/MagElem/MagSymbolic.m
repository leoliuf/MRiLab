
function dB0=MagSymbolic(p)
%create dB0 field

global VMmg

% Initialize parameters
Equation=p.Equation;

% Initialize display grid
X=VMmg.xgrid;
Y=VMmg.ygrid;
Z=VMmg.zgrid;

try
    eval(['dB0=' Equation ';']);
catch me
    dB0 = zeros(size(VMmg.xgrid));
    error_msg{1,1}='ERROR!!! Creating dB0 field using symbolic equation fails!';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end

end