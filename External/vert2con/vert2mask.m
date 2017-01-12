
function mask = vert2mask(vertices,x,y,z)
% VERT2MASK - convert a set of 3D convexhull vertices into a 3D volume mask

[A,b] = vert2con(vertices);
p=[x(:),y(:),z(:)]';
p=bsxfun(@le,A*p,b);
p=min(p);
mask=reshape(p,size(x));

end