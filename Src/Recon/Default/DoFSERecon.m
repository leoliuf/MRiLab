

function DoFSERecon(Simuh)

global VSig;
global VCtl;
global VObj;
global VCoi;
global VImg;


SX=reshape(VSig.Sx,VCtl.ResFreq * VCtl.FSE_ETL,VCtl.FSE_ShotNum,VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum); % matlab col priority
SY=reshape(VSig.Sy,VCtl.ResFreq * VCtl.FSE_ETL,VCtl.FSE_ShotNum,VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum);

SX=sum(SX, 5); % sum signal from all spin types
SY=sum(SY, 5);
%% FSE k-space recon
% sort k-space & row flipping
Sx=zeros(VCtl.ResFreq,VCtl.FSE_ETL*VCtl.FSE_ShotNum,VCtl.SliceNum,VCoi.RxCoilNum);
Sy=zeros(VCtl.ResFreq,VCtl.FSE_ETL*VCtl.FSE_ShotNum,VCtl.SliceNum,VCoi.RxCoilNum);
for e = 1: VCtl.FSE_ETL
    Sx(:,(e-1)*VCtl.FSE_ShotNum+1: e*VCtl.FSE_ShotNum, :,:) = reshape(SX((e-1)*VCtl.ResFreq+1: e*VCtl.ResFreq, :,:,:), [VCtl.ResFreq ,VCtl.FSE_ShotNum ,VCtl.SliceNum,VCoi.RxCoilNum]);
    Sy(:,(e-1)*VCtl.FSE_ShotNum+1: e*VCtl.FSE_ShotNum, :,:) = reshape(SY((e-1)*VCtl.ResFreq+1: e*VCtl.ResFreq, :,:,:), [VCtl.ResFreq ,VCtl.FSE_ShotNum ,VCtl.SliceNum,VCoi.RxCoilNum]);
end

% default -KxMax -> KxMax, -KyMax -> KyMax
% remove the most positive Kx point for making even number of Kx sample points (used for Matlab default fft)
Sx(end,:,:,:)=[];
Sy(end,:,:,:)=[];
ResFreq = VCtl.ResFreq - 1;

if isfield(VCtl,'ZF_Kx') % Zero Filling of k-space for increasing matrix size, no increae of resolution
    Sx2=zeros(str2double(VCtl.ZF_Kx),str2double(VCtl.ZF_Ky),str2double(VCtl.ZF_Kz(2:end))*VCtl.SliceNum,VCoi.RxCoilNum);
    Sy2=zeros(str2double(VCtl.ZF_Kx),str2double(VCtl.ZF_Ky),str2double(VCtl.ZF_Kz(2:end))*VCtl.SliceNum,VCoi.RxCoilNum);
    for i = 1:VCoi.RxCoilNum
        Sx2(str2double(VCtl.ZF_Kx)/2-ResFreq/2+1:str2double(VCtl.ZF_Kx)/2-ResFreq/2+1+ResFreq-1, ...
            str2double(VCtl.ZF_Ky)/2-(VCtl.FSE_ETL*VCtl.FSE_ShotNum)/2+1:str2double(VCtl.ZF_Ky)/2-(VCtl.FSE_ETL*VCtl.FSE_ShotNum)/2+1+(VCtl.FSE_ETL*VCtl.FSE_ShotNum)-1, ...
            str2double(VCtl.ZF_Kz(2:end))*floor(VCtl.SliceNum/2)-floor(VCtl.SliceNum/2)+1:str2double(VCtl.ZF_Kz(2:end))*floor(VCtl.SliceNum/2)-floor(VCtl.SliceNum/2)+1+VCtl.SliceNum-1,i)=Sx(:,:,:,i);
        Sy2(str2double(VCtl.ZF_Kx)/2-ResFreq/2+1:str2double(VCtl.ZF_Kx)/2-ResFreq/2+1+ResFreq-1, ...
            str2double(VCtl.ZF_Ky)/2-(VCtl.FSE_ETL*VCtl.FSE_ShotNum)/2+1:str2double(VCtl.ZF_Ky)/2-(VCtl.FSE_ETL*VCtl.FSE_ShotNum)/2+1+(VCtl.FSE_ETL*VCtl.FSE_ShotNum)-1, ...
            str2double(VCtl.ZF_Kz(2:end))*floor(VCtl.SliceNum/2)-floor(VCtl.SliceNum/2)+1:str2double(VCtl.ZF_Kz(2:end))*floor(VCtl.SliceNum/2)-floor(VCtl.SliceNum/2)+1+VCtl.SliceNum-1,i)=Sy(:,:,:,i);
    end
    Sx=Sx2;
    Sy=Sy2;
    clear Sx2 Sy2;
end
Sx=permute(Sx,[2 1 3 4]);
Sy=permute(Sy,[2 1 3 4]);

% match XYZ orientation
switch VCtl.ScanPlane
    case 'Axial'
        if  strcmp(VCtl.FreqDir,'A/P')
            Sx=permute(Sx,[2 1 3 4]);
            Sy=permute(Sy,[2 1 3 4]);
        else
            Sx=permute(Sx,[1 2 3 4]);
            Sy=permute(Sy,[1 2 3 4]);
        end
    case 'Sagittal'
        if  strcmp(VCtl.FreqDir,'S/I')
            Sx=permute(Sx,[2 1 3 4]);
            Sy=permute(Sy,[2 1 3 4]);
        else
            Sx=permute(Sx,[1 2 3 4]);
            Sy=permute(Sy,[1 2 3 4]);
        end
    case 'Coronal'
        if  strcmp(VCtl.FreqDir,'L/R')
            Sx=permute(Sx,[1 2 3 4]);
            Sy=permute(Sy,[1 2 3 4]);
        else
            Sx=permute(Sx,[2 1 3 4]);
            Sy=permute(Sy,[2 1 3 4]);
        end
end

S=Sx+1i*Sy;
for i = 1: VCoi.RxCoilNum
    VImg.Real(:,:,:,i)=real(fftshift(ifftn(fftshift(S(:,:,:,i)))));
    VImg.Imag(:,:,:,i)=imag(fftshift(ifftn(fftshift(S(:,:,:,i)))));
    VImg.Mag(:,:,:,i)=abs(VImg.Real(:,:,:,i)+1i*VImg.Imag(:,:,:,i));
    VImg.Phase(:,:,:,i)=angle(VImg.Real(:,:,:,i)+1i*VImg.Imag(:,:,:,i));
end
VImg.Sx(:,:,:,:)=Sx;
VImg.Sy(:,:,:,:)=Sy;

guidata(Simuh.SimuPanel_figure, Simuh);


end