%make a brain VObj based on McGill BrainWeb brain model

type    = 'McGill BrainWeb Brain Model';
tissue  = '0=Background, 1=CSF, 2=Grey Matter, 3=White Matter, 5=Muscle/Skin, 6=Skin,   7=Skull, 9=Connective';
list    = [ 0            1      2              3               5              6         7        9           ];
rho     = [ 0            1      0.8            0.65            0.7            0.6       0.05     0.75        ];
t1      = [ 0            4.5    0.95           0.6             1.1            0.3       0.1      1           ];
t2      = [ 0            2.2    0.1            0.08            0.035          0.03      0.01     0.042       ];
t2star  = [ 0            1.1    0.05           0.04            0.0175         0.015     0.005    0.021       ];
massden = [ 0            1007   1045           1041            1090           1109      1908     1027        ];
econ    = [ 0            1.8    0.19           0.37            0.29           0.001215  0.1      0.29
            0            1.8    0.19           0.37            0.29           0.001215  0.1      0.29
            0            1.8    0.19           0.37            0.29           0.001215  0.1      0.29];

Rho=Anatomy;
T1=Anatomy;
T2=Anatomy;
T2Star=Anatomy;
MassDen=Anatomy;
ECon=repmat(Anatomy,[1 1 1 3]);

for i=2:length(rho)
    Rho(Rho==list(i))=rho(i);
    T1(T1==list(i))=t1(i);
    T2(T2==list(i))=t2(i);
    T2Star(T2Star==list(i))=t2star(i);
    MassDen(MassDen==list(i))=massden(i);
    
    tmp = ECon(:,:,:,1);
    tmp(tmp==list(i))=econ(1,i);
    ECon(:,:,:,1)=tmp;
    
    tmp = ECon(:,:,:,2);
    tmp(tmp==list(i))=econ(2,i);
    ECon(:,:,:,2)=tmp;
    
    tmp = ECon(:,:,:,3);
    tmp(tmp==list(i))=econ(3,i);
    ECon(:,:,:,3)=tmp;
    
end

VObj.Rho=Rho;
VObj.T1=T1;
VObj.T2=T2;
VObj.T2Star=T2Star;
VObj.ECon=ECon;
VObj.MassDen=MassDen;