function p = createMultiframeTestphan()

% load the k-space of a predifined multiecho testphantom from file
basePath = fileparts(mfilename('fullpath'));
dat = load(fullfile(basePath, 'testPhan64.mat'));
p = dat.p;

% create a movie with different (simulated) shifts of the phantom
NF = 30; % number of frames
dim = size(p,1);
P = zeros([size(p),NF]);

x = linspace(0,1,dim);
[X,Y] = meshgrid(x,x');
shiftMax = dim * 2*pi;
shiftInc = shiftMax / NF;

shift = 0;
for i = 1 : NF    
    shiftPhX = exp(1i * -shift * X);
    shiftPhY = exp(1i * shift * Y);
    shift = shift + shiftInc;    
    currP = ftimes(p,shiftPhX);    
    currP = ftimes(currP,shiftPhY);
    P(:,:,:,i) = currP;
end

% do a Fourier reconstruction of the data
P = asDataClass.mrIfft(P);

% simulate 4 different coil profiles
coils = cat(5,X,Y,1-X, 1-Y);
P = ftimes(P,coils);

% simulate phase perturbations
phase = exp(1i *2 * pi * (1.5 - coils));
P = ftimes(P,phase);

% create pseudo k-space data from the fft of the images
p = asDataClass.mrFft(P);
end
