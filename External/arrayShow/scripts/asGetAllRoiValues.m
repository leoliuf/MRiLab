function asGetAllRoiValues(includeTitle)
if nargin < 1
    includeTitle = false;
end

global asObjs
for i = 1 : length(asObjs)
    [m,s] = asObjs(i).roi.getMeanAndStd;
    
    if includeTitle
        t = asObjs(i).getFigureTitle;
        fprintf('%s, %f, %f\n',t,m,s);
    else
        fprintf(' %f, %f\n',m,s);
    end
end
