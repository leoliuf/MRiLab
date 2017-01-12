function asSetAllWindows(CW)
global asObjs
for i = 1 : length(asObjs)
    asObjs(i).window.setCW(CW);
end