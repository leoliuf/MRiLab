% dinf -- calculate D infinity for a linear phase filter

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University

function d = dinf(d1,d2)

a1 = 5.309e-3;
a2 = 7.114e-2;
a3 = -4.761e-1;
a4 = -2.66e-3;
a5 = -5.941e-1;
a6 = -4.278e-1;

l10d1 = log10(d1);
l10d2 = log10(d2);

[m1 n1] = size(l10d1);
if (m1<n1),
  l10d1 = l10d1.';
end;
[m2 n2] = size(l10d2);
if (m2<n2),
  l10d2 = l10d2.';
end;

l = length(d2);

d=(a1*l10d1.*l10d1+a2*l10d1+a3)*l10d2'+(a4*l10d1.*l10d1+a5*l10d1+a6)*ones(1,l);
