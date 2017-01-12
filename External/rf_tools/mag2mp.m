% mag2mp - take the magnitude of the fft of a signal, and return the
%   fft of the analytic signal.
%
% as = mag2mp(ms)
%   as - fft of analytic signal
%   ms - magnitude of analytic signal fft.
%
% If you have a waveform B that you want to the minimum phase
% version of, then
%    1) pad B out by adding zeros up to a factor of 4 or more
%    2) compute C=abs(fft(B))
%    3) compute D=ansigm(C)
%    4) compute E=ifft(D)
% E is the minimum phase function, also zero padded.  The part you want
% should be at the beginning.  You will see echos later on if you didn't
% add enough padding.
  
%  Written by John Pauly, Oct 1989
% (c) Board of Trustees, Leland Stanford Junior University

function [a] = mag2mp(x)

n = length(x);
xl = log(x);                        % log of mag spectrum
xlf = fft(xl);                      % 
xlfp(1) = xlf(1);                   % keep DC the same
xlfp(2:(n/2)) = 2*xlf(2:(n/2));     % double positive freqs
xlfp((n/2+1)) = xlf((n/2+1));       % keep half Nyquist the same,too
xlfp((n/2+2):n) = 0*xlf((n/2+2):n); % zero neg freqs
xlaf = ifft(xlfp);                  % 
a = exp(xlaf);                      % complex exponentiation


