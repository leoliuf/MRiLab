

function DoNonCartRecon(Simuh)

global VSig;
global VCtl;
global VObj;
global VCoi;
global VImg;


SX=reshape(VSig.Sx, length(VSig.Sx)/(VCtl.FirstPhNum * VCtl.SliceNum * VCoi.RxCoilNum * VObj.TypeNum),VCtl.FirstPhNum, VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum); % matlab col priority
SY=reshape(VSig.Sy, length(VSig.Sy)/(VCtl.FirstPhNum * VCtl.SliceNum * VCoi.RxCoilNum * VObj.TypeNum),VCtl.FirstPhNum, VCtl.SliceNum,VCoi.RxCoilNum,VObj.TypeNum);
KX=reshape(VSig.Kx, length(VSig.Kx)/(VCtl.FirstPhNum * VCtl.SliceNum), VCtl.FirstPhNum, VCtl.SliceNum);
KY=reshape(VSig.Ky, length(VSig.Ky)/(VCtl.FirstPhNum * VCtl.SliceNum), VCtl.FirstPhNum, VCtl.SliceNum);

SX=sum(SX, 5); % sum signal from all spin types
SY=sum(SY, 5);
%% Non-Cartesian k-space recon
if ~isfield(VCtl,'G_KernelWidth')
    KernelSample = 32;
    KernelWidth  = 1.5;
    OverGrid     = 2;
else
    KernelSample = VCtl.G_KernelSample;
    KernelWidth  = VCtl.G_KernelWidth;
    OverGrid     = VCtl.G_OverGrid;
end

NumSamples = length(VSig.Sx)/(VCtl.TEPerTR * VCtl.FirstPhNum * VCtl.SliceNum * VCoi.RxCoilNum * VObj.TypeNum);
GridSize = round(VCtl.ResFreq * OverGrid);
GridSize = GridSize + ~mod(GridSize,2); % guarantee odd number of grid point for gridding [0,0]
tmpSx    = zeros(GridSize, GridSize, VCtl.SliceNum, VCoi.RxCoilNum);
tmpSy    = zeros(GridSize, GridSize, VCtl.SliceNum, VCoi.RxCoilNum);

for e = 1: VCtl.TEPerTR
    for r = 1: VCoi.RxCoilNum
        for s = 1: VCtl.SliceNum
            % buffer signal & kspace info
            Sx=SX((e-1)*NumSamples + 1: e*NumSamples,:,s,r);
            Sy=SY((e-1)*NumSamples + 1: e*NumSamples,:,s,r);
            Kx=KX((e-1)*NumSamples + 1: e*NumSamples,:,s);
            Ky=KY((e-1)*NumSamples + 1: e*NumSamples,:,s);
            
            Sx=Sx(:);
            Sy=Sy(:);
            Kx=Kx(:);
            Ky=Ky(:);
            
            % normalize K space to -0.5 and 0.5
            Kx = Kx / (max(abs(Kx)) * 2);
            Ky = Ky / (max(abs(Ky)) * 2);
            
            Kx(isnan(Kx)) = 0;
            Ky(isnan(Ky)) = 0;
            Kx(isinf(Kx)) = 0;
            Ky(isinf(Ky)) = 0;
            
            % calculate density compensation using Voronoi diagram
            try
                DCF = DoCalcDCF(Kx,Ky);
            catch me
                DCF = zeros(size(Kx));
            end
            
            % calculate Kaiser-Bessel Kernel
            [Ker,KGrid] = DoCalcKBKernel(KernelSample, KernelWidth, OverGrid);
            
            % gridding according to given parameters
            [Sx2,Sy2]= DoGridding(Kx,Ky,Sx,Sy,DCF,Ker,GridSize,KernelWidth/2);
            tmpSx(:,:,s,r) = Sx2;
            tmpSy(:,:,s,r) = Sy2;
        end
    end
    Sx = tmpSx;
    Sy = tmpSy;
    % default -KxMax -> KxMax, -KyMax -> KyMax
    % remove the most positive Kx point for making even number of Kx sample points (used for Matlab default fft)
    Sx(:,end,:,:)=[];
    Sy(:,end,:,:)=[];
    % remove the most positive Ky point for making even number of Ky sample points (used for Matlab default fft)
    Sx(end,:,:,:)=[];
    Sy(end,:,:,:)=[];
    
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
    Deapod=DoDeapodization(GridSize, KernelWidth, OverGrid); % calculate apodization correction matrix
    VImg.Deapod=Deapod;
    Deapod=repmat(Deapod,[1,1,VCtl.SliceNum]);
    for i = 1: VCoi.RxCoilNum
        Im = fftshift(ifftn(fftshift(S(:,:,:,i))));
        if isfield(VCtl,'G_Deapodization')
            if strcmp(VCtl.G_Deapodization,'on')
                Im = Im./Deapod; % correct apodization
            end
        end
        if isfield(VCtl,'G_Truncation')
            if strcmp(VCtl.G_Truncation,'on')
                % save raw image
                VImg.Real_raw(:,:,:,i,e)=real(Im);
                VImg.Imag_raw(:,:,:,i,e)=imag(Im);
                VImg.Mag_raw(:,:,:,i,e)=abs(VImg.Real_raw(:,:,:,i,e)+1i*VImg.Imag_raw(:,:,:,i,e));
                VImg.Phase_raw(:,:,:,i,e)=angle(VImg.Real_raw(:,:,:,i,e)+1i*VImg.Imag_raw(:,:,:,i,e));
                % truncate image
                Im = Im(ceil(GridSize/2)-floor(VCtl.ResFreq/2) : ceil(GridSize/2)+VCtl.ResFreq-floor(VCtl.ResFreq/2)-1,...
                        ceil(GridSize/2)-floor(VCtl.ResFreq/2) : ceil(GridSize/2)+VCtl.ResFreq-floor(VCtl.ResFreq/2)-1,:);
            end
        end
        VImg.Real(:,:,:,i,e)=real(Im);
        VImg.Imag(:,:,:,i,e)=imag(Im);
        VImg.Mag(:,:,:,i,e)=abs(VImg.Real(:,:,:,i,e)+1i*VImg.Imag(:,:,:,i,e));
        VImg.Phase(:,:,:,i,e)=angle(VImg.Real(:,:,:,i,e)+1i*VImg.Imag(:,:,:,i,e));
    end
    VImg.Sx(:,:,:,:,e)=Sx;
    VImg.Sy(:,:,:,:,e)=Sy;
    
end

guidata(Simuh.SimuPanel_figure, Simuh);


end