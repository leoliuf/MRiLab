function asSetAllSelections(selection)
global asObjs
for i = 1 : length(asObjs)
    asObjs(i).selection.setValue(selection);
end