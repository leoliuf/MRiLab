function rebuildAsObjs
evalin('base','global asObjs');
global asObjs;

for i = 1 :length(asObjs)
   asObjs(i) = asObjs(i).rebuildObject;
end