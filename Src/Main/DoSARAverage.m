
function [aveSAR,avePower,aveKGram]=DoSARAverage(SAR,Power,VMass,N_KGram)

global VObj;

%% average SAR
try
    % create 3D searching sphere voxel index list
    Mxdims=size(VObj.MassDen);
    [xgrid,ygrid,zgrid]=meshgrid((-(Mxdims(2)-1)/2)*VObj.XDimRes:VObj.XDimRes:((Mxdims(2)-1)/2)*VObj.XDimRes,...
                                 (-(Mxdims(1)-1)/2)*VObj.YDimRes:VObj.YDimRes:((Mxdims(1)-1)/2)*VObj.YDimRes,...
                                 (-(Mxdims(3)-1)/2)*VObj.ZDimRes:VObj.ZDimRes:((Mxdims(3)-1)/2)*VObj.ZDimRes);
    dist=sqrt(xgrid.^2+ygrid.^2+zgrid.^2);
    [B,idx]=sort(dist(:));
    idx=idx-idx(1);
    
    aveSAR=zeros(size(VObj.MassDen));
    avePower=zeros(size(VObj.MassDen));
    aveKGram=zeros(size(VObj.MassDen));
    totnum=numel(VObj.MassDen);
    num=numel(find(VObj.MassDen~=0));
    vrange=1;
    for i=(find(VObj.MassDen~=0))'
        tidx=idx+i;
        tidx(tidx<1 | tidx>totnum)=[];
        signal=1;
        direct=0;
        vrange=max(1,min(length(tidx),vrange));
        while vrange>=1 & vrange<=length(tidx)
            mass=sum(VMass(tidx(1:vrange)));
            if mass<N_KGram
                if direct==-1
                    break;
                end
                if signal==1
                    direct=1;
                end
                flag=1;
            else
                if direct==1
                    break;
                end
                if signal==1
                    direct=-1;
                end
                flag=-1;
            end
            vrange=vrange+flag;
            signal=0;
        end
        aveKGram(i)=mass;
        tmpSAR=SAR(tidx(1:max(1,min(length(tidx),vrange))));
        aveSAR(i)=mean(tmpSAR(tmpSAR~=0));
        tmpPower=Power(tidx(1:max(1,min(length(tidx),vrange))));
        avePower(i)=mean(tmpPower(tmpPower~=0));
    end
    
catch me
    error_msg{1,1}='ERROR!!! SAR averaging process aborted.';
    error_msg{2,1}=me.message;
    errordlg(error_msg);
    return;
end

end