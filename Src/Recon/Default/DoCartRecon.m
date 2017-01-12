

function DoCartRecon(Simuh)

global VSig;
global VCtl;
global VObj;
global VCoi;
global VImg;


SX=reshape(VSig.Sx, VCtl.ResFreq * VCtl.TEPerTR,VCtl.ResPhase,VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum); % matlab col priority
SY=reshape(VSig.Sy, VCtl.ResFreq * VCtl.TEPerTR,VCtl.ResPhase,VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum);

SX=sum(SX, 5); % sum signal from all spin types
SY=sum(SY, 5);
%% Cartesian k-space recon
for e = 1: VCtl.TEPerTR
    
    Sx=SX((e-1)*VCtl.ResFreq + 1: e*VCtl.ResFreq, :,:,:);
    Sy=SY((e-1)*VCtl.ResFreq + 1: e*VCtl.ResFreq, :,:,:);
    
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
                str2double(VCtl.ZF_Ky)/2-VCtl.ResPhase/2+1:str2double(VCtl.ZF_Ky)/2-VCtl.ResPhase/2+1+VCtl.ResPhase-1, ...
                str2double(VCtl.ZF_Kz(2:end))*floor(VCtl.SliceNum/2)-floor(VCtl.SliceNum/2)+1:str2double(VCtl.ZF_Kz(2:end))*floor(VCtl.SliceNum/2)-floor(VCtl.SliceNum/2)+1+VCtl.SliceNum-1,i)=Sx(:,:,:,i);
            Sy2(str2double(VCtl.ZF_Kx)/2-ResFreq/2+1:str2double(VCtl.ZF_Kx)/2-ResFreq/2+1+ResFreq-1, ...
                str2double(VCtl.ZF_Ky)/2-VCtl.ResPhase/2+1:str2double(VCtl.ZF_Ky)/2-VCtl.ResPhase/2+1+VCtl.ResPhase-1, ...
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
    
    % signal normalization
    % Sx=Sx/(sum(VMag.FRange(:))/(VCtl.ResFreq*VCtl.ResPhase*VCtl.SliceNum));
    % Sy=Sy/(sum(VMag.FRange(:))/(VCtl.ResFreq*VCtl.ResPhase*VCtl.SliceNum));
    
    S=Sx+1i*Sy;
    for i = 1: VCoi.RxCoilNum
        VImg.Real(:,:,:,i,e)=real(fftshift(ifftn(fftshift(S(:,:,:,i)))));
        VImg.Imag(:,:,:,i,e)=imag(fftshift(ifftn(fftshift(S(:,:,:,i)))));
        VImg.Mag(:,:,:,i,e)=abs(VImg.Real(:,:,:,i,e)+1i*VImg.Imag(:,:,:,i,e));
        VImg.Phase(:,:,:,i,e)=angle(VImg.Real(:,:,:,i,e)+1i*VImg.Imag(:,:,:,i,e));
    end
    VImg.Sx(:,:,:,:,e)=Sx;
    VImg.Sy(:,:,:,:,e)=Sy;
end

guidata(Simuh.SimuPanel_figure, Simuh);


end