function asSetAllTitlesToImageString
global asObjs
for i = 1 : length(asObjs)
%     asObjs(i).roi.setPosition(pos);
    asObjs(i).toggleTitleAsImageText;
end
