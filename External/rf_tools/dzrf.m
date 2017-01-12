function rf = dzrf(np,tb,ptype,ftype,d1,d2,pclsfrac)
%   rf = dzrf(np,tb,ptype,ftype,d1,d2,pclsfrac)
%
%  Designs an rf pulse.  There are a lot of options, most of
%  which have defaults.  For example, a reasonable 100 sample
%  tb=4 spin-echo pulse can be designed with
%
%   rf = dzrf(100,4,'se')
%
%  Inputs are:
%    np -- number of points.         (required)
%    tb -- time-bandwidth product    (required)
%    ptype -- pulse type.  Options are:
%      st  -- small tip angle         (default)
%      ex  -- pi/2 excitation pulse
%      se  -- pi spin-echo pulse
%      sat -- pi/2 saturation pulse
%      inv -- inversion pulse
%    ftype -- filter design method.  Options are:
%      ms  -- Hamming windowed sinc (an msinc)
%      pm  -- Parks-McClellan equal ripple
%      ls  -- Least Squares           (default)
%      min -- Minimum phase (factored pm)
%      max -- Maximum phase (reversed min)
%    d1 -- Passband ripple        (default = 0.01)
%    d2 -- Stopband ripple        (default = 0.01)
%    pclsfrac -- pcls tolerance   (default = 1.5)  

%  written by John Pauly, 1992
%  (c) Board of Trustees, Leland Stanford Junior University

if (nargin < 7), pclsfrac = 1.5; end;
if nargin < 5, d1 = 0.01; d2 = 0.01; end;
if nargin < 4, ftype = 'ls'; end;
if nargin < 3, ptype = 'st'; end;

if strcmp(ptype,'st'),
   bsf = 1;
elseif strcmp(ptype,'ex'),
   bsf = sqrt(1/2);
   d1 = sqrt(d1/2);
   d2 = d2/sqrt(2);
elseif strcmp(ptype,'se'),
   bsf = 1;
   d1 = d1/4;
   d2 = sqrt(d2);
elseif strcmp(ptype,'inv'),
   bsf = 1;
   d1 = d1/8;
   d2 = sqrt(d2/2);
elseif strcmp(ptype,'sat'),
   bsf = sqrt(1/2);
   d1 = d1/2;
   d2 = sqrt(d2);
else
   disp(['Unrecognized Pulse Type -- ',ptype]);
   disp('  Recognized types are st, ex, se, inv, and sat');
   return;
end;

if strcmp(ftype,'ms'),
   b = msinc(np,tb/4);
elseif strcmp(ftype,'pm'),
   b = dzlp(np,tb,d1,d2);
elseif strcmp(ftype,'min'),
   b = dzmp(np,tb,d1,d2);
   b = b(np:-1:1);
elseif strcmp(ftype,'max'),
   b = dzmp(np,tb,d1,d2);
elseif strcmp(ftype,'ls'),
   b = dzls(np,tb,d1,d2);
else
   disp(['Unrecognized Filter Design Method -- ' ftype]);
   disp(['  Options: ms, pm, min, max, and ls']);
   return;
end;

if strcmp(ptype,'st'),
   rf = b;
else
   b = bsf*b;
   rf = b2rf(b);
end;



