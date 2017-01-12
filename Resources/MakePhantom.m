%make a MT or ME model based on a picture

% load a picture
Circle=double(Circle);
Circle=repmat(Circle, [1 1 10]);
T1=Circle;
T2=Circle;
Rho=Circle;
K=Circle;
T2Star=Circle;

% load a VObj phantom, change properties
VObj=rmfield(VObj, 'T1');
VObj=rmfield(VObj, 'T2');
VObj=rmfield(VObj, 'Rho');
VObj=rmfield(VObj, 'T2Star');
VObj=rmfield(VObj, 'K');

% % MT model
% % free pool
% K(Circle==0)        =8;        
% Rho(Circle==0)      =0.85;
% T1(Circle==0)       =1;
% T2(Circle==0)       =35e-3;
% T2Star(Circle==0)   =3.5e-3;
% 
% K(Circle==255)        =0;        
% Rho(Circle==255)      =0;
% T1(Circle==255)       =0;
% T2(Circle==255)       =0;
% T2Star(Circle==255)   =0;
% 
% VObj.T1(:,:,:,1)      = T1;
% VObj.T2(:,:,:,1)      = T2;
% VObj.Rho(:,:,:,1)     = Rho;
% VObj.T2Star(:,:,:,1)  = T2Star;
% VObj.K(:,:,:,1)       = K;
% 
% % bound pool
% K                   =(K .* Rho) ./ (1 - Rho);
% Rho                 =1 - Rho;
% T1(Circle==0)       =1;
% T2(Circle==0)       =7e-6;
% T2Star(Circle==0)   =7e-7;
% 
% K(Circle==255)        =0;        
% Rho(Circle==255)      =0;
% T1(Circle==255)       =0;
% T2(Circle==255)       =0;
% T2Star(Circle==255)   =0;
% 
% VObj.T1(:,:,:,2)      = T1;
% VObj.T2(:,:,:,2)      = T2;
% VObj.Rho(:,:,:,2)     = Rho;
% VObj.T2Star(:,:,:,2)  = T2Star;
% VObj.K(:,:,:,2)       = K;

% ME model
% water pool 1
K(Circle==0)        =2.5;        
Rho(Circle==0)      =0.8;
T1(Circle==0)       =1.070;
T2(Circle==0)       =117e-3;
T2Star(Circle==0)   =11.7e-3;

K(Circle==255)        =0;        
Rho(Circle==255)      =0;
T1(Circle==255)       =0;
T2(Circle==255)       =0;
T2Star(Circle==255)   =0;

VObj.T1(:,:,:,1)      = T1;
VObj.T2(:,:,:,1)      = T2;
VObj.Rho(:,:,:,1)     = Rho;
VObj.T2Star(:,:,:,1)  = T2Star;
VObj.K(:,:,:,2)       = K;

% water pool 2
K                   =(K .* Rho) ./ (1 - Rho);
Rho                 =1 - Rho;
T1(Circle==0)       =0.465;
T2(Circle==0)       =26e-3;
T2Star(Circle==0)   =2.6e-3;

K(Circle==255)        =0;        
Rho(Circle==255)      =0;
T1(Circle==255)       =0;
T2(Circle==255)       =0;
T2Star(Circle==255)   =0;

VObj.T1(:,:,:,2)      = T1;
VObj.T2(:,:,:,2)      = T2;
VObj.Rho(:,:,:,2)     = Rho;
VObj.T2Star(:,:,:,2)  = T2Star;
VObj.K(:,:,:,3)       = K;

VObj.K(:,:,:,1)       = zeros(size(VObj.K(:,:,:,3)));
VObj.K(:,:,:,4)       = zeros(size(VObj.K(:,:,:,3)));