%      Copyright (C) 2009-2013 Biomedizinische NMR Forschungs GmbH
%                     http://www.biomednmr.mpg.de
%            Author: Tilman Johannes Sumpf <tsumpf@gwdg.de>
%
%       Distributed under the Boost Software License, Version 1.2.
%          (See accompanying file LICENSE_1_0.txt or copy at
%                 http://www.boost.org/LICENSE_1_0.txt)


function newObj = as(arr, varargin)
% Shortcut for "arrShow.appendToGlobalAsArray(arr, varargin)"

% auto title
if nargin > 1 && length(varargin) == 1
    % if only one additional argument is given, assume this to be the
    % desired figure title.
    % (This is an exception in the standard varargin syntax, but it's convenient)
    varargin = [{'inputname'}, varargin];    
else
    % per default use the name of the inputvariable "arr" as a title
    % (the 'auto title' is added at the beginning of the varargin vector 
    %  such that it will be overwritten if another inputname is explicitly given)
    varargin = [varargin, {'inputname'}, {inputname(1)}];    
end

% use global list of relatives per default
varargin = [varargin, {'useglobalarray'}, {true}];




% call arrShow
if nargout == 1
    newObj = arrShow.appendToGlobalAsArray(arr,varargin{:});
else
    arrShow.appendToGlobalAsArray(arr,varargin{:});
end

end