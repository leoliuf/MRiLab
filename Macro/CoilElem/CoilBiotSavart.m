
function [B1x,B1y,B1z]=CoilBiotSavart(points)
%create B1 field produced by Biot-Savart rule

global VMco

x=points(1,:);
y=points(2,:);
z=points(3,:);

% Initialize display grid
xgrid=VMco.xgrid;
ygrid=VMco.ygrid;
zgrid=VMco.zgrid;

% Initialize constant
mu0 = 4*pi*1e-7;       % Permeability of free space (T*m/A)
I_current = 1;       % Current in the loop (A)
Constant = mu0/(4*pi) * I_current;   % Useful constant

% Initialize B to zero
B1x = zeros(size(xgrid));
B1y = zeros(size(xgrid));
B1z = zeros(size(xgrid));

for i=1:length(x)-1
    
    % Compute components of segment vector dl
    dlx = x(i+1)-x(i);
    dly = y(i+1)-y(i);
    dlz = z(i+1)-z(i);
    
    % Compute the location of the midpoint of a segment
    xc = (x(i+1)+x(i))/2;
    yc = (y(i+1)+y(i))/2;
    zc = (z(i+1)+z(i))/2;
    
    %% segment on loop and observation point)
    rx = xgrid - xc;
    ry = ygrid - yc;
    rz = zgrid - zc;
    
    % Compute r^3 from r vector
    r3 = sqrt(rx.^2 + ry.^2 + rz.^2).^3;
    
    % Compute cross product dl X r
    dlXr_x = dly.*rz - dlz.*ry;
    dlXr_y = dlz.*rx - dlx.*rz;
    dlXr_z = dlx.*ry - dly.*rx;
    
    % Increment sum of magnetic field
    B1x = B1x + Constant.*dlXr_x./r3;
    B1y = B1y + Constant.*dlXr_y./r3;
    B1z = B1z + Constant.*dlXr_z./r3;
    
    
end

end