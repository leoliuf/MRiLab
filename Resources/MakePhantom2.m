%make a trangle model based on a picture

% load a picture
Trangle=double(Trangle);
Trangle=repmat(Trangle, [1 1 30]);
T1=Trangle;
T2=Trangle;
Rho=Trangle;
T2Star=Trangle;

% load a VObj phantom, change properties
VObj=rmfield(VObj, 'T1');
VObj=rmfield(VObj, 'T2');
VObj=rmfield(VObj, 'Rho');
VObj=rmfield(VObj, 'T2Star');

% VObj properties
Rho(Trangle==0)      =1;
T1(Trangle==0)       =1.2;
T2(Trangle==0)       =40e-3;
T2Star(Trangle==0)   =4e-3;
  
Rho(Trangle==255)      =1;
T1(Trangle==255)       =3;
T2(Trangle==255)       =2;
T2Star(Trangle==255)   =0.2;

VObj.T1(:,:,:,1)      = T1;
VObj.T2(:,:,:,1)      = T2;
VObj.Rho(:,:,:,1)     = Rho;
VObj.T2Star(:,:,:,1)  = T2Star;
