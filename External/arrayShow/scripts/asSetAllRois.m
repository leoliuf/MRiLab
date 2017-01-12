function asSetAllRois(pos)
global asObjs
for i = 1 : length(asObjs)
%     asObjs(i).roi.setPosition(pos);
    asObjs(i).createRoi(pos);
end
