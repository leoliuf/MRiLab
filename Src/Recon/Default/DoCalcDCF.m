
function DCF=DoCalcDCF(Kx, Ky)
% caluclate density compensation factor using Voronoi diagram

% remove duplicated K space points (likely [0,0]) before Voronoi
K = Kx + 1i*Ky;
[K1,m1,n1]=unique(K);
K = K(sort(m1));

% calculate Voronoi diagram
[K2,m2,n2]=unique(K);
Kx = real(K2);
Ky = imag(K2);
Area = voronoiarea(Kx,Ky);

% use area as density estimate
DCF = Area(n1);

% take equal fractional area for repeated locations (likely [0,0])
% n   = n1;
% while ~isempty(n)
%     rep = length(find(n==n(1)));
%     if rep > 1
%         DCF (n1==n(1)) = DCF(n1==n(1))./rep;
%     end
%     n(n==n(1))=[];
% end

% normalize DCF
DCF = DCF ./ max(DCF);

% figure; voronoi(Kx,Ky);


function Area = voronoiarea(Kx,Ky)
% caculate area for each K space point as density estimate

Kxy = [Kx,Ky];
% returns vertices and cells of voronoi diagram
[V,C] = voronoin(Kxy);

% compute area of each ploygon
Area = zeros(1,length(Kx));
for j = 1:length(Kx)
    x = V(C{j},1); 
    y = V(C{j},2);
    % remove vertices outside K space limit including infinity vertices from voronoin
    x1 = x;
    y1 = y;
    ind=find((x1.^2 + y1.^2)>0.25);
    x(ind)=[]; 
    y(ind)=[];
    % calculate area
    lxy = length(x);
    if lxy > 2
        ind=[2:lxy 1];
        A = abs(sum(0.5*(x(ind)-x(:)).*(y(ind)+y(:))));
    else
        A = 0;
    end
    Area(j) = A;
end