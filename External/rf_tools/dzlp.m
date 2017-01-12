% dzlp -- design a linear phase filter by calling remez with the
%         proper arguments

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University

function h = dzlp(n,tb,d1,d2)

di = dinf(d1,d2);
w = di/tb;
f = [0 (1-w)*(tb/2) (1+w)*(tb/2) (n/2)]/(n/2);
m = [1 1 0 0];
w = [1 d1/d2];
if exist('remez'),   % finally, the m script, will call .mex if available
  h = eval('remez(n-1,f,m,w)'); 
else
  disp('No PM routine found!');
end;

