function asCloseAll
objs = arrShow.findAllObjects();
objs = [objs,arrShow.findAllObjects()];
if ~isempty(objs)
    objs.close;
    delete(objs);
end
evalin('base','clear global asObjs');