% h = msinc(n,m)
%
%  Returns a hamming windowed sinc of length n, with m sinc-cycles,
%  which means a time-bandwidth of 4*m
%

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University

function ms = msinc(n,m)

x = [-n/2:(n-1)/2]/(n/2);
snc = sin(m*2*pi*x+0.00001)./(m*2*pi*x+0.00001);
ms = snc.*(0.54+0.46*cos(pi*x));
ms = ms*4*m/(n);
