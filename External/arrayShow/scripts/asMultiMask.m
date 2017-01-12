function asMultiMask(asObjs, mask, createNewWindow)
if nargin < 3 
    createNewWindow = false;
end

for i = 1 : length(asObjs)
    curr = asObjs(i).getAllImages;
    curr = ftimes(curr,mask);
    if createNewWindow
        pos = asObjs(i).getFigureOuterPosition;
        pos(2) = pos(2) - pos(4);
        o = as(asObjs(i));
%         o.setMainWindowPosition(pos);
        o.setFigurePosition(pos);       
    else
        o = asObjs(i);
    end
    o.overwriteImageArray(curr);    
end
end