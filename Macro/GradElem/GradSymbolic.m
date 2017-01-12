
function G=GradSymbolic(p)
%create gradient profile

global VMgd

% Initialize parameters
GradLine=p.GradLine;
GradXEqu=p.GradXEqu;
GradYEqu=p.GradYEqu;
GradZEqu=p.GradZEqu;

% Initialize display grid
X=VMgd.xgrid;
Y=VMgd.ygrid;
Z=VMgd.zgrid;

try
    eval(['G(:,:,:,1)=' GradXEqu ';']);
    eval(['G(:,:,:,2)=' GradYEqu ';']);
    eval(['G(:,:,:,3)=' GradZEqu ';']);
catch me
    G = zeros(size(VMgd.xgrid));
    error_msg{1,1}='ERROR!!! Creating gradient profile using symbolic equation fails!';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
end

end