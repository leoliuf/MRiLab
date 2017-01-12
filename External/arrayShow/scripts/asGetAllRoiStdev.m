function asGetAllRoiStdev()

global asObjs
for i = 1 : length(asObjs)
    [m,s] = asObjs(i).roi.getMeanAndStd;
    fprintf('%f\n',s);
end
