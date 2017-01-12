function c = gray_periodic(N,range)
% returns a colormap ranging from
% black over white to black
if nargin < 2
    range = [0,1];
    if nargin < 1
        N = 64;
    end
end

equalStartEnd = false;
inc = 2*(range(2) - range(1))/N;

if equalStartEnd
    c1 = range(1) : inc : range(2)-inc;
    c2 = range(2)-inc : -inc: range(1);
else        
    c1 = range(1):inc:range(2);
    c2 = range(2)-inc : -inc : range(1)+inc;
end
c = [c1, c2];

c = repmat(c',[1,3]);
end



