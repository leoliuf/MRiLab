% dimp -- calculate D infinity for a minimum phase filter

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University

function d=dimp(d1,d2)

d = 0.5*dinf(2*d1,0.5*d2.*d2);


