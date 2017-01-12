function y = trapmf(x, params)
%TRAPMF Trapezoidal membership function.
%   TRAPMF(X, PARAMS) returns a matrix which is the trapezoidal
%   membership function evaluated at X. PARAMS = [A B C D] is a 4-element
%   vector that determines the break points of this membership function.
%   We require that A <= B and C <= D. If B >= C, this membership
%   function becomes a triangular membership function that could have
%   a height less than unity. (See the example below.)
%
%   For example:
%
%       x = (0:0.1:10)';
%       y1 = trapmf(x, [2 3 7 9]);
%       y2 = trapmf(x, [3 4 6 8]);
%       y3 = trapmf(x, [4 5 5 7]);
%       y4 = trapmf(x, [5 6 4 6]);
%       plot(x, [y1 y2 y3 y4]);
%       set(gcf, 'name', 'trapmf', 'numbertitle', 'off');
%
%   See also DSIGMF, EVALMF, GAUSS2MF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF,
%   SIGMF, SMF, TRIMF, ZMF.

%   Roger Jang, 6-28-93, 10-5-93, 4-14-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.22 $  $Date: 2002/04/14 22:21:13 $

if nargin ~= 2
    error('Two arguments are required by the trapezoidal MF.');
elseif length(params) < 4
    error('The trapezoidal MF needs at least four parameters.');
end

a = params(1); b = params(2); c = params(3); d = params(4);

if a > b,
    error('Illegal parameter condition: a > b');
elseif c > d,
    error('Illegal parameter condition: c > d');
end

y1 = zeros(size(x));
y2 = zeros(size(x));

% Compute y1
index = find(x >= b);
if ~isempty(index),
    y1(index) = ones(size(index));
end
index = find(x < a);
if ~isempty(index),
    y1(index) = zeros(size(index));
end
index = find(a <= x & x < b);
if ~isempty(index) & a ~= b,
    y1(index) = (x(index)-a)/(b-a);
end

% Compute y2
index = find(x <= c);
if ~isempty(index),
    y2(index) = ones(size(index));
end
index = find(x > d);
if ~isempty(index),
    y2(index) = zeros(size(index));
end
index = find(c < x & x <= d);
if ~isempty(index) & c ~= d,
    y2(index) = (d-x(index))/(d-c);
end

% Compute y
y = min(y1, y2);
