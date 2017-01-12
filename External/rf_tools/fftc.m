%
%  fft wrt the center of the array, instead of the first sample
%

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University
  
function y=fftc(x)

y = fftshift(fft(fftshift(x)));

