function asGetAllTitles()

global asObjs
for i = 1 : length(asObjs)
    t = asObjs(i).getFigureTitle;
    fprintf('%s\n',t);
    
end
