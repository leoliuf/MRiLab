function h = dzls(nf,tb,d1,d2);
%
%    h = dzls(n,tbw,d1,d2)
%
%        nf = filter length
%        tb = time-bandwidth
%        d1 = pass band ripple
%        d2 = stop band ripple
%  
%  dzls designs a least squares filter. 

%  written by John Pauly, Feb 26, 1992
%  (c) Leland Stanford Junior University

di = dinf(d1,d2);
w = di/tb;
f = [0 (1-w)*(tb/2) (1+w)*(tb/2) (nf/2)]/(nf/2);
m = [1 1 0 0];
w = [1 d1/d2];

h = firls(nf-1,f,m,w);

