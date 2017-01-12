function asGetAllRoiMeans()

global asObjs
for i = 1 : length(asObjs)
    [m,s] = asObjs(i).roi.getMeanAndStd;
    fprintf('%f\n',m);
%     fprintf('%s\n',num2str(m));
end
