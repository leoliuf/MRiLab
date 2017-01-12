/* Basic SAR Kernel running at CPU */

#ifndef _SAR_KERNEL_CPU_H_
#define _SAR_KERNEL_CPU_H_


void SARKernelNormalCPU(float *TxE1x, float *TxE1y, float *TxE1z,
                        float *SARxTmp, float *SARyTmp, float *SARzTmp,
                        float dt, double *rfAmp, double *rfPhase, double *rfFreq,
                        mwSize SpinMxNum, mwSize SpinMxSliceNum, mwSize TxCoilNum)
{
    /* variables for dealing multi-Tx */
    float rfAmpSum = 0;
    float rfAmpBuf;
    
    for (int i=0; i<TxCoilNum; i++){
        rfAmpSum+=fabs((float)rfAmp[i]);
    }
    
    /* power accumulation */
    if (rfAmpSum != 0){
        /* set buffer */
        Ipp32f *buffer1 = ippsMalloc_32f(SpinMxNum);
        Ipp32f *buffer2 = ippsMalloc_32f(SpinMxNum);
        Ipp32f *buffer3 = ippsMalloc_32f(SpinMxNum);
        Ipp32f *bufferx = ippsMalloc_32f(SpinMxNum);
        Ipp32f *buffery = ippsMalloc_32f(SpinMxNum);
        Ipp32f *bufferz = ippsMalloc_32f(SpinMxNum);
        ippsZero_32f(bufferx, SpinMxNum);
        ippsZero_32f(buffery, SpinMxNum);
        ippsZero_32f(bufferz, SpinMxNum);
        
        for (int i=0; i<TxCoilNum; i++){ /* multi-Tx or single-Tx */
            rfAmpBuf = (float)rfAmp[i];
            if (rfAmpBuf !=0 ){
                ippsMulC_32f(TxE1x + i * SpinMxSliceNum * SpinMxNum, rfAmpBuf, buffer1, SpinMxNum); 
                ippsMulC_32f(TxE1y + i * SpinMxSliceNum * SpinMxNum, rfAmpBuf, buffer2, SpinMxNum); 
                ippsMulC_32f(TxE1z + i * SpinMxSliceNum * SpinMxNum, rfAmpBuf, buffer3, SpinMxNum);
                ippsAdd_32f_I(buffer1, bufferx, SpinMxNum);
                ippsAdd_32f_I(buffer2, buffery, SpinMxNum);
                ippsAdd_32f_I(buffer3, bufferz, SpinMxNum);
            }
        }
        
        ippsSqr_32f_I(bufferx, SpinMxNum);
        ippsSqr_32f_I(buffery, SpinMxNum);
        ippsSqr_32f_I(bufferz, SpinMxNum);
        
        ippsMulC_32f_I(dt, bufferx, SpinMxNum);
        ippsMulC_32f_I(dt, buffery, SpinMxNum);
        ippsMulC_32f_I(dt, bufferz, SpinMxNum);
        
        ippsAdd_32f_I(bufferx, SARxTmp, SpinMxNum);
        ippsAdd_32f_I(buffery, SARyTmp, SpinMxNum);
        ippsAdd_32f_I(bufferz, SARzTmp, SpinMxNum);
        
        /* Free memory */
        ippsFree(buffer1);
        ippsFree(buffer2);
        ippsFree(buffer3);
        ippsFree(bufferx);
        ippsFree(buffery);
        ippsFree(bufferz);
    }
}

#endif