

function [Ker,KGrid] = DoCalcKBKernel(KSample, KernelWidth, OverGrid)
% calculate the Kaiser-Bessel kernel for gridding based on Jackson et al. & Beatty et al.

% calculate beta value based on Beatty et al. 2005
a = OverGrid;
W = KernelWidth;
beta = pi*sqrt((W^2/a^2)*(a-0.5)^2-0.8);

% kernal grid
KGrid = linspace(0, 1, KSample) * (W/2);

% calculate KB kernel at one side
Ker = KaiserBessel(KGrid, W, beta);
Ker = Ker/max(Ker); % normalize


function y = KaiserBessel(u,W,beta)
x = beta*sqrt(1-(2*u./W).^2);
y = besseli(0,x)./W;


