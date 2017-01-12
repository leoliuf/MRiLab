function [rgb, CLim] = complex2rgb(img, N, CLim, incolormap)

% calculates the cdata from img and the colormap
%
% input arguments:
%       img:            the image as 2D complex data
%       N:              the number of colormap tones as scalar
%       CLim:           the magnitude color limits as 2 element vector
%       incolormap:     the colormap as n-by-3 matrix
%
% output:
%       rgb:            the rgb cdata m-by-n-by-3 matrix
%       CLim:           the colorlimits as 2 element vector


switch nargin
    case 2
        N = 256;
        cmap = martin_phase(N);
        CLim = [];
    case 3
        cmap = martin_phase(N);
    case 4
        if ~ischar(incolormap)
            cmap = incolormap;
        end
    otherwise
end

m = abs(img);   % magnitude
p = angle(img); % phase

    
% get minimum and maximum magnitude value
mi = min(m(:));
ma = max(m(:));

% set the colorlimits
if isempty(CLim)
    CLim = [mi, ma];
end

if round(mi*1e12) == round(ma*1e12) && ma ~= 0    
    % set magnitude value to 1 to show a pure phase map
    m = ones(size(m));
else    
    % scale magnitude image to 0..1
    m(m < CLim(1)) = CLim(1);
    % m(m > CLim(2)) = CLim(2);
    m = (m - CLim(1)) / CLim(2);
    m(m > 1) = 1;
end

% scale p from -pi .. pi to int(1 .. N)
p = (N-1) *(p + pi) / (2*pi);
p = round(p + 1);

% get phase rgb values
p = ind2rgb(p,cmap);

% get grayscale rgb values for m
rgbm = repmat(m,[1,1,3]);

% create weighted phase rgb matrix
rgb = rgbm .* p;

end