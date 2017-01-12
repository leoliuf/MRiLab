function asMultiOp(asObjs, op, createNewWindow)
if nargin < 3 
    createNewWindow = false;
end

for i = 1 : length(asObjs)
    curr = asObjs(i).getAllImages;
    eval(['curr = curr',op,';']);
    if createNewWindow
        pos = asObjs(i).getFigureOuterPosition;
        pos(2) = pos(2) - pos(4);
        o = as(asObjs(i));
        o.setMainWindowPosition(pos);
    else
        o = asObjs(i);
    end
    o.overwriteImageArray(curr);    
end
end