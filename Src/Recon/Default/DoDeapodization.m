
function Deapod=DoDeapodization(GridSize, KernelWidth, OverGrid)
% correct apodization caused by convolution, using ifft of Kaiser-Bessel
% kernel on Jackson et al. 1991

% calculate beta value based on Beatty et al. 2005
a = OverGrid;
W = KernelWidth;
beta = pi*sqrt((W^2/a^2)*(a-0.5)^2-0.8);

[xgrid,ygrid]=meshgrid(linspace(-0.5,0.5, GridSize-1), ...
                       linspace(-0.5,0.5, GridSize-1));
Deapod = sin(sqrt(pi^2*W^2*(xgrid.^2 + ygrid.^2) - beta^2)) ./ sqrt(pi^2*W^2*(xgrid.^2 + ygrid.^2) - beta^2);
DeapodMax = max(Deapod(:));
Deapod = Deapod./DeapodMax; % normalize
% Deapod (Deapod < 0.05) = 0.05; % attenuate sidelob, using 5% threshold

end