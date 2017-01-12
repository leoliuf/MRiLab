%function SARave = SARavesphnp (MaterialDensity, SAR, a, b, c, grams)
% 
%SARavesphnp is a tool designed to compute the n-grams spatial 
%average SAR using adaptive spherical masks, having as input:
% 
%MaterialDensity-> the 3D matrix containing the 3D spatial distribution
%                  of the material density distribution
%SAR-> the 3D matrix describing the 3D spatial SAR distribution
%a, b, c-> the x, y, z, cell resolution in meters (commonly 2 mm each)
%grams-> the mass in grams of the volumes where 
%        the SAR average is computed (commonly 1g or 10g)
% 
%This tool has been presented in international symposia and published in
%the article:
%G. Carluccio, D. Erricolo, S. Oh, C. M. Collins, 
%"An Approach to Rapid Calculation of Temperature Change in Tissue Using
%Spatial Filters to Approximate Effects of Thermal Conduction",
%in IEEE Trans. on Biomedical Engin., (Early View).
%Please consider citing this article if you have found this tool useful.
% 
%Giuseppe Carluccio, PhD
%E-mail: giuseppe.carluccio@nyumc.org
%Department of Radiology, New York University

function SARave = SARavesphnp (MaterialDensity, SAR, a, b, c, grams)



si = size(SAR);
SARave= zeros(si(1), si(2), si(3));

dist=1;

for Slice = 1:si(3)
    SARave(:,:,Slice) = aversphSAR2 (MaterialDensity, SAR, a, b, c, Slice, dist, grams);
    compl = 100*Slice/si(3);
    %Delete next line if you do not want to have printed information of the
    %status of the computation
    fprintf('%.2f %% Completed\n', compl);
end

end

function avesphSAR= aversphSAR2(Material, SAR, a1, b1, c1, Slice, dist, grams)

si=size(SAR);
row=si(1);
col=si(2);

avesphSAR=zeros(si(1), si(2));

for k=dist:row-dist+1
    k;
    for l=dist:col-dist+1
        if (Material(k,l, Slice)>0)
        avesphSAR(k, l) = comptS(Material, SAR, k, l, Slice, a1, b1, c1, grams);
        end
    end
end
end     

%%

function totSAR = comptS(Material, SAR, a, b, c, a1, b1, c1, grams)

si=size(SAR);
radius=0;
OK=0;
totwei=0;
totSAR=0;
totpx=0;
while (totwei<=grams*1e-3 && OK==0)
    totwei2=totwei;
    totSAR2=totSAR;
    totpx2=totpx;
    totwei=0;
    totpx=0;
    totSAR1=0;
    totSAR=0;
    radius=radius+1;
    for o=-radius:radius
        rado=floor(sqrt(radius^2-o^2));
        for m=-rado:rado
            radm=floor(sqrt(rado^2-m^2));
            for n=-radm:radm
                if (a+m >= 1 && a+m <= si(1) && b+n >=1 && b+n <=si(2) && c+o >= 1 && c+o <= si(3))
                if totwei<=10e-3
                    totwei=totwei+a1*b1*c1*Material(a+m, b+n, c+o);
                    if SAR(a+m, b+n, c+o)>0
                        totpx=totpx+1;
                        totSAR=totSAR+SAR(a+m, b+n, c+o);
                    end
                end
                end
            end
        end
    end
    if totSAR==totSAR1
        OK=1;
    end
end

coefw = (grams*1e-3 - totwei2)/(totwei-totwei2);
totpxs = coefw*(totpx-totpx2);
totSARs = coefw*(totSAR-totSAR2);

totpx;
if totpx>0
totSAR=(totSAR2+totSARs)/(totpx2+totpxs);
end
end