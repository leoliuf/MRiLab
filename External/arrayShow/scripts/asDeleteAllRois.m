global asObjs
for i = 1 : length(asObjs)
    if isa(asObjs(i).roi,'asRoiClass') &&  isvalid(asObjs(i).roi)
        asObjs(i).roi.delete;
    end
end