
/**************************************************************************
MEX code for calculating local SAR using IPP or Framewave
and multi-threading (OpenMP) written by Fang Liu (leoliuf@gmail.com).
*************************************************************************/

/* system header */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
/* MEX header */
#include <mex.h> 
#include "matrix.h"
/* OpenMP header*/
#include <omp.h>
/* Intel IPP header */
#ifdef IPP
#include <ipp.h>
#endif
/* AMD Framewave header */
#ifdef FW
#include <fwSignal.h>
#include <fwBase.h>
#define Ipp32f                  Fw32f
#define ippAlgHintFast          fwAlgHintFast
#define ippsMalloc_32f          fwsMalloc_32f
#define ippsFree                fwsFree
#define ippsZero_32f            fwsZero_32f
#define ippsZero_64f            fwsZero_64f
#define ippsSum_32f             fwsSum_32f
#define ippsCopy_32f            fwsCopy_32f
#define ippsAddC_32f            fwsAddC_32f
#define ippsAddC_32f_I          fwsAddC_32f_I
#define ippsAdd_32f             fwsAdd_32f 
#define ippsAdd_32f_I           fwsAdd_32f_I
#define ippsMulC_32f            fwsMulC_32f
#define ippsMulC_32f_I          fwsMulC_32f_I
#define ippsMul_32f             fwsMul_32f
#define ippsMul_32f_I           fwsMul_32f_I
#define ippsDiv_32f             fwsDiv_32f
#define ippsDivC_32f            fwsDivC_32f
#define ippsInv_32f_A24         fwsInv_32f_A24
#define ippsThreshold_LT_32f_I  fwsThreshold_LT_32f_I
#define ippsExp_32f_I           fwsExp_32f_I
#define ippsArctan_32f          fwsArctan_32f
#define ippsSqr_32f             fwsSqr_32f
#define ippsSqr_32f_I           fwsSqr_32f_I
#define ippsSqrt_32f_I          fwsSqrt_32f_I
#define ippsSin_32f_A24         fwsSin_32f_A24
#define ippsCos_32f_A24         fwsCos_32f_A24
#define ippsPolarToCart_32f     fwsPolarToCart_32f
#define ippsCartToPolar_32f     fwsCartToPolar_32f
#endif

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#define fmin min
#endif

#define PI      3.14159265359 /* pi constant */

/* includes CPU kernel */
#include "SARKernel.h"
extern "C" bool mxUnshareArray(mxArray *array_ptr, bool noDeepCopy);

/* MEX entry function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])

{
    
/* pointers for VObj */
    double *Gyro;
    mwSize SpinMxNum, SpinMxSliceNum, SpinMxDimNum, ThreadNum;
    const mwSize *SpinMxDims;
	float *ECon;
    
/* pointers for VCoi */
    float *TxE1xBase, *TxE1yBase, *TxE1zBase, *TxE1x, *TxE1y, *TxE1z;
    
/* pointers for VCtl */
    int *TRNum, *MaxThreadNum;
	
/* pointers for VSeq */
    double *utsLine, *tsLine, *rfAmpLine, *rfPhaseLine, *rfFreqLine, *rfCoilLine, *ExtLine, *flagsLine;
    
/* pointers for VVar */
    double *t, *dt, *rfAmp, *rfPhase, *rfFreq, *rfCoil, *Ext;
    int *SARi, *utsi, *rfi, *Exti, *TRCount;
    float *SARBase, *SARxTmp, *SARyTmp, *SARzTmp;
    
/* pointers for VSig */
    double *Muts, *tSample, *tRealSample;
	float *SAR;

/* loop control */
    mwIndex i=0, j=0, s=0, TxCoili;
	int Slicei;
    mwSize MaxStep, MaxutsStep, MaxrfStep, MaxSARStep, *TxCoilNum;
    double flag[6];
    
/* IPP or FW buffer */
    Ipp32f *buffer1, *buffer2, *buffer3, *buffer4, *buffer;
    
/* Function status */
    int ExtCall;
    
/* force breaking Copy-on-Write */   
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VObj")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VCoi")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VCtl")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VVar")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VSeq")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VSig")), true);
    
/* assign pointers */
    ECon            = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "ECon"));
    
    TxE1xBase       = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxE1x"));
    TxE1yBase       = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxE1y"));
    TxE1zBase       = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxE1z"));
    TxCoilNum       = (mwSize*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilNum"));
 
    TRNum           = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "TRNum"));
    MaxThreadNum    = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "MaxThreadNum"));
	
	utsLine         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "utsLine"));
    tsLine          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "tsLine"));
    rfAmpLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfAmpLine"));
    rfPhaseLine     = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfPhaseLine"));
    rfFreqLine      = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfFreqLine"));
    rfCoilLine      = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfCoilLine"));
    ExtLine         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "ExtLine"));
    flagsLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "flagsLine"));
	
	MaxStep         = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "tsLine"));
    MaxutsStep      = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "utsLine"));
    MaxrfStep       = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfAmpLine"));
	
    t               = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "t"));
    dt              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "dt"));
    rfAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfAmp"));
    rfPhase         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfPhase"));
    rfFreq          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfFreq"));
    rfCoil          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfCoil"));
    Ext             = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Ext"));
    SARBase         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "SAR"));
    SARi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "SARi"));
    utsi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "utsi"));
    rfi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfi"));
    Exti            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Exti"));
    TRCount         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "TRCount"));
    
    SAR             = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "SAR"));
    Muts            = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Muts"));
    tSample         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "tSample"));
    tRealSample     = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "tRealSample"));
  
    
    MaxSARStep      = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "tSample"));
    
 /* get dimensions of spin matrix */
    SpinMxDimNum    = mxGetNumberOfDimensions(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "MassDen"));
    SpinMxDims      = (mwSize*) mxCalloc(SpinMxDimNum, sizeof(mwSize));
    SpinMxDims      = mxGetDimensions(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "MassDen"));
    SpinMxNum       = SpinMxDims[0] * SpinMxDims[1];
    
    if (SpinMxDimNum == 2){
        SpinMxSliceNum = 1;
    }else{
        SpinMxSliceNum = SpinMxDims[2];
    }
    
/* assign spins to multi-threads */
    if (SpinMxSliceNum < *MaxThreadNum)
        ThreadNum = SpinMxSliceNum;
    else
        ThreadNum = *MaxThreadNum;  /* Full CPU load */
    
/* set buffer */
    buffer1 = ippsMalloc_32f(SpinMxSliceNum*SpinMxNum);
    
/* start simulator execution loop */
    mexPrintf("TR Counts: %d of %d\n", 1, *TRNum);
    while (i < MaxStep-1){
        /* check MR sequence pulse flag */
        flag[0]=0;
        flag[1]=0;
        flag[2]=0;
        flag[3]=0;
        flag[4]=0;
        flag[5]=0;
        if (tsLine[i]!=tsLine[i+1]){
            flag[0]+=flagsLine[i*6];
            flag[1]+=flagsLine[i*6+1];
            flag[2]+=flagsLine[i*6+2];
            flag[3]+=flagsLine[i*6+3];
            flag[4]+=flagsLine[i*6+4];
            flag[5]+=flagsLine[i*6+5];
            i++;
        }
        else{
            flag[0]+=flagsLine[i*6];
            flag[1]+=flagsLine[i*6+1];
            flag[2]+=flagsLine[i*6+2];
            flag[3]+=flagsLine[i*6+3];
            flag[4]+=flagsLine[i*6+4];
            flag[5]+=flagsLine[i*6+5];
            
            while (tsLine[i]==tsLine[i+1]){
                flag[0]+=flagsLine[(i+1)*6];
                flag[1]+=flagsLine[(i+1)*6+1];
                flag[2]+=flagsLine[(i+1)*6+2];
                flag[3]+=flagsLine[(i+1)*6+3];
                flag[4]+=flagsLine[(i+1)*6+4];
                flag[5]+=flagsLine[(i+1)*6+5];
                i++;
                if (i==MaxStep-1){
                    break;
                }
            }
            i++;
        }
        
        /* Sample SAR, no miss for the start point */
        if ((*SARi)< MaxSARStep){
            if (*(Muts+*utsi)>=*(tSample+*SARi)){
                /* store SAR value */
                ippsMul_32f(SARBase, ECon, buffer1, SpinMxSliceNum*SpinMxNum);
                ippsAdd_32f_I(buffer1, SAR+(*SARi)*SpinMxSliceNum*SpinMxNum, SpinMxSliceNum*SpinMxNum);
                
                ippsMul_32f(SARBase+SpinMxSliceNum*SpinMxNum, ECon+SpinMxSliceNum*SpinMxNum, buffer1, SpinMxSliceNum*SpinMxNum);
                ippsAdd_32f_I(buffer1, SAR+(*SARi)*SpinMxSliceNum*SpinMxNum, SpinMxSliceNum*SpinMxNum);
                
                ippsMul_32f(SARBase+2*SpinMxSliceNum*SpinMxNum, ECon+2*SpinMxSliceNum*SpinMxNum, buffer1, SpinMxSliceNum*SpinMxNum);
                ippsAdd_32f_I(buffer1, SAR+(*SARi)*SpinMxSliceNum*SpinMxNum, SpinMxSliceNum*SpinMxNum);
                
                *(tRealSample+*SARi)=*(Muts+*utsi);
                (*SARi)++;
                mexPrintf("SAR Sample Point: %fs, (%d of %d)\n", *(Muts+*utsi), *SARi, MaxSARStep);
            }
            if (*SARi == MaxSARStep){
                return;
            }
        }
        
        /* update pulse status */
        *t = *(utsLine + *utsi);
        *dt = *(utsLine + (int)fmin(*utsi+1, MaxutsStep-1))-*(utsLine + *utsi);
        *utsi = (int)fmin(*utsi+1, MaxutsStep-1);
        
        if (flag[0]>=1 ){ /* update rfAmp, rfPhase, rfFreq, rfCoil for multiple rf lines*/
            for (j = 0; j < flag[0]; j++){
                 *rfCoil = *(rfCoilLine+ *rfi);
                 TxCoili = (int)(*rfCoil);
                 s = *rfi + 1;
                 while (s < MaxrfStep){
                    if (*rfCoil == *(rfCoilLine + s)){
                        if (fabs(*(rfAmpLine+ *rfi)) <= fabs(*(rfAmpLine + s)))
                            *(rfAmp + TxCoili - 1)= *(rfAmpLine+ *rfi);
                        else
                            *(rfAmp + TxCoili - 1)= *(rfAmpLine+ s);
                        
                        if (fabs(*(rfPhaseLine+ *rfi)) <= fabs(*(rfPhaseLine + s)))
                            *(rfPhase + TxCoili - 1)= *(rfPhaseLine+ *rfi);
                        else
                            *(rfPhase + TxCoili - 1)= *(rfPhaseLine+ s);
                        
                        if (fabs(*(rfFreqLine+ *rfi)) <= fabs(*(rfFreqLine + s)))
                            *(rfFreq + TxCoili - 1)= *(rfFreqLine+ *rfi);
                        else
                            *(rfFreq + TxCoili - 1)= *(rfFreqLine+ s);
                        
                        break;
                    }
                    s++;
                 }
                 (*rfi)++;
            }
        }
        
        if (flag[0]+flag[1]+flag[2]+flag[3]+flag[4]+flag[5] == 0){ /* reset VVar */
            ippsZero_64f(rfAmp, *TxCoilNum);
            ippsZero_64f(rfPhase, *TxCoilNum);
            ippsZero_64f(rfFreq, *TxCoilNum);
            *Ext = 0;
        }
        
        /* execute spin precessing */
        if (*dt == 0){ /* end of time point */
            continue;
        }
        else if (*dt < 0){ /* uncontinuous time point process */
            (*TRCount)++;
            mexPrintf("TR Counts: %d of %d\n", *TRCount, *TRNum);
            ExtCall = mexEvalString("pause(0.001);");
            if (ExtCall){
                mexErrMsgTxt("SAR calculation process encounters ERROR!");
                return;
            }
            *(Muts+*utsi) = *(Muts+*utsi-1);
            continue;
        }
        
        /* set openMP for core inner loop */
        #pragma omp parallel num_threads(ThreadNum)
        {
            #pragma omp for private(Slicei, TxE1x, TxE1y, TxE1z, SARxTmp, SARyTmp, SARzTmp)
            /* need private clause to keep variables isolated, VERY IMPORTANT!!! Otherwise cause cross influence by threads */
            for (Slicei=0; Slicei<SpinMxSliceNum; Slicei++){
                
                /* set pointer offset for input */
                TxE1x	= TxE1xBase + Slicei*SpinMxNum;
                TxE1y	= TxE1yBase + Slicei*SpinMxNum;
                TxE1z	= TxE1zBase + Slicei*SpinMxNum;
                
                SARxTmp = SARBase + Slicei*SpinMxNum;
                SARyTmp = SARBase + Slicei*SpinMxNum + SpinMxSliceNum*SpinMxNum;
                SARzTmp = SARBase + Slicei*SpinMxNum + 2*SpinMxSliceNum*SpinMxNum;
                
                /* call spin discrete precessing */
                SARKernelNormalCPU(TxE1x, TxE1y, TxE1z,
                                   SARxTmp, SARyTmp, SARzTmp,
                                   (float)*dt, rfAmp, rfPhase, rfFreq,
                                   SpinMxNum, SpinMxSliceNum, *TxCoilNum);
                
            }
        }
        
        *(Muts+*utsi) = *(Muts+*utsi-1) + *dt;

        /* Sample SAR, no miss for the end point */
        if ((*SARi)< MaxSARStep){
            if (*(Muts+*utsi)>=*(tSample+*SARi)){
                /* store SAR value */
                ippsMul_32f(SARBase, ECon, buffer1, SpinMxSliceNum*SpinMxNum);
                ippsAdd_32f_I(buffer1, SAR+(*SARi)*SpinMxSliceNum*SpinMxNum, SpinMxSliceNum*SpinMxNum);
                
                ippsMul_32f(SARBase+SpinMxSliceNum*SpinMxNum, ECon+SpinMxSliceNum*SpinMxNum, buffer1, SpinMxSliceNum*SpinMxNum);
                ippsAdd_32f_I(buffer1, SAR+(*SARi)*SpinMxSliceNum*SpinMxNum, SpinMxSliceNum*SpinMxNum);
                
                ippsMul_32f(SARBase+2*SpinMxSliceNum*SpinMxNum, ECon+2*SpinMxSliceNum*SpinMxNum, buffer1, SpinMxSliceNum*SpinMxNum);
                ippsAdd_32f_I(buffer1, SAR+(*SARi)*SpinMxSliceNum*SpinMxNum, SpinMxSliceNum*SpinMxNum);
                
                *(tRealSample+*SARi)=*(Muts+*utsi);
                (*SARi)++;
                mexPrintf("SAR Sample Point: %fs, (%d of %d)\n", *(Muts+*utsi), *SARi, MaxSARStep);
            }
            if (*SARi == MaxSARStep){
                return;
            }
        }
    }
}


