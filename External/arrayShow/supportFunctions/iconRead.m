function cdata = iconRead(filename,guessalpha)
% ICONREAD read an image file and convert it to CData for a HG icon.
%
% CDATA=ICONREAD(FILENAME)
%   Read an image file and convert it to CData with automatic transparency
%   handling. If the image has transparency data, PNG files sometimes do,
%   the transparency data is used. If the image has no CData, the top left
%   pixel is treated as the transparent color.
%
% CDATA=ICONREAD(FILENAME, FALSE)
%   Same as above but supress the usage of the top left pixel for images
%   with no transparency data. This may require the caller to handle the
%   transparency explicitly. View the contents of this m-file for an
%   example of how to handle transparency.
%
% Example:
%
% icon = fullfile(matlabroot,'toolbox','matlab','icons','matlabicon.gif');
% uitoggletool('CData',iconread(icon));
%
% See also IMREAD.

% Copyright 1984-2007 The MathWorks, Inc.

if nargin < 2
    guessalpha = true;
end

[p,f,ext] = fileparts(filename);
% if this is a mat-file, look for the varible cdata (or something like it)
if isequal(lower(ext),'.mat')
    cdata = [];
    s = whos('-file',filename);
    for i=1:length(s)
        if ~isempty(strfind(lower(s(i).name), 'cdata'))
            data = load(filename,s(i).name);
            cdata = data.(s(i).name);
        end
    end
    return
end

try
    [cdata,map,alpha] = imread(filename);
catch me
    if strcmp(me.identifier,'MATLAB:imread:fileOpen')
        disp('error reading icon file');
        cdata = [];
    else
        rethrow(me);        
    end
end
if isempty(cdata)
    return;
end

if isempty(map)
    if isinteger(cdata)
        cname = class(cdata);
        cdata=double(cdata);
        cdata = cdata/double(intmax(cname));
    else
        cdata=double(cdata);
        cdata = cdata/255;
    end
else
    cdata = ind2rgb(cdata,map);
end

if isempty(alpha)
    if ~guessalpha
        return;
    end
    % guess the alpha pixel by using the top left pixel in the icon
    ap1 = cdata(1,1,1);
    ap2 = cdata(1,1,2);
    ap3 = cdata(1,1,3);
    alpha = cdata(:,:,1) == ap1 & cdata(:,:,2) == ap2 & cdata(:,:,3) == ap3;
    alpha = ~alpha;
end

% process alpha data
r = cdata(:,:,1);
r(alpha == 0) = NaN;
g = cdata(:,:,2);
g(alpha == 0) = NaN;
b = cdata(:,:,3);
b(alpha == 0) = NaN;
cdata = cat(3,r,g,b);
