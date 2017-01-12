

/**************************************************************************
MEX code for spin discrete evolution using IPP or Framewave
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
#include "BlochKernel.h"
extern "C" bool mxUnshareArray(mxArray *array_ptr, bool noDeepCopy);

/* MEX entry function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])

{
    
/* pointers for VObj */
    double *Gyro;
    mwSize SpinMxNum, SpinMxSliceNum, SpinMxDimNum, ThreadNum;
    const mwSize *SpinMxDims;
	float *MzBase, *MyBase, *MxBase, *Mz, *My, *Mx, *RhoBase, *T1Base, *T2Base, *Rho, *T1, *T2;

/* pointers for VMag */
    float *dB0Base, *dWRndBase, *GzgridBase, *GygridBase, *GxgridBase;
    float *dB0, *dWRnd, *Gzgrid, *Gygrid, *Gxgrid;
    
/* pointers for VCoi */
    float *RxCoilx, *RxCoily;
    float *TxCoilmg, *TxCoilpe, *TxCoilmgBase, *TxCoilpeBase;
	double *RxCoilDefault, *TxCoilDefault;
    
/* pointers for VCtl */
    double *CS;
    int *TRNum, *RunMode, *MaxThreadNum;
	
/* pointers for VSeq */
    double *utsLine, *tsLine, *rfAmpLine, *rfPhaseLine, *rfFreqLine, *rfCoilLine, *GzAmpLine, *GyAmpLine, *GxAmpLine, *ADCLine, *ExtLine, *flagsLine;
    
/* pointers for VVar */
    double *t, *dt, *rfAmp, *rfPhase, *rfFreq, *rfCoil, *rfRef, *GzAmp, *GyAmp, *GxAmp, *ADC, *Ext, *KzTmp, *KyTmp, *KxTmp;
    int *utsi, *rfi, *Gzi, *Gyi, *Gxi, *ADCi, *Exti, *TRCount;
    
/* pointers for VSig */
    double *Sx, *Sy, *Kz, *Ky, *Kx, *Muts;
	float *MxsBase, *MysBase, *MzsBase;
    

/* loop control */
    mwIndex i=0, j=0, s=0, Signali=0, Spini, Typei, RxCoili, TxCoili;
	int Slicei;
    mwSize MaxStep, MaxutsStep, MaxrfStep, MaxGzStep, MaxGyStep, MaxGxStep, *SpinNum, *TypeNum, *TxCoilNum, *RxCoilNum, *SignalNum;
    double flag[6];
    
/* IPP or FW buffer */
    Ipp32f *buffer1, *buffer2, *buffer3, *buffer4, *buffer;
    
/* Function status */
    int ExtCall;
    
/* force breaking Copy-on-Write */   
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VObj")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VMag")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VCoi")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VCtl")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VVar")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VSeq")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VSig")), true);
    
/* assign pointers */
    Gyro            = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Gyro"));
    MzBase          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
    MyBase          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "My"));
    MxBase          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mx"));
    RhoBase         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Rho"));
    T1Base          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T1"));
    T2Base          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T2"));
    SpinNum         = (mwSize*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "SpinNum"));
    TypeNum         = (mwSize*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "TypeNum"));
    
    dB0Base         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dB0"));
    dWRndBase       = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dWRnd"));
    GzgridBase      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gzgrid"));
    GygridBase      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gygrid"));
    GxgridBase      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gxgrid"));
    
    TxCoilmgBase    = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilmg"));
    TxCoilpeBase    = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilpe"));
    RxCoilx         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilx"));
    RxCoily         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoily"));
    TxCoilNum       = (mwSize*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilNum"));
    RxCoilNum       = (mwSize*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilNum"));
    TxCoilDefault   = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilDefault"));
    RxCoilDefault   = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilDefault"));
 
    CS              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "CS"));
    TRNum           = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "TRNum"));
    RunMode         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "RunMode"));
    MaxThreadNum    = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "MaxThreadNum"));
	
	utsLine         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "utsLine"));
    tsLine          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "tsLine"));
    rfAmpLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfAmpLine"));
    rfPhaseLine     = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfPhaseLine"));
    rfFreqLine      = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfFreqLine"));
    rfCoilLine      = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfCoilLine"));
    GzAmpLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "GzAmpLine"));
    GyAmpLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "GyAmpLine"));
    GxAmpLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "GxAmpLine"));
    ADCLine         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "ADCLine"));
    ExtLine         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "ExtLine"));
    flagsLine       = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "flagsLine"));
	
	MaxStep         = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "tsLine"));
    MaxutsStep      = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "utsLine"));
    MaxrfStep       = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "rfAmpLine"));
    MaxGzStep       = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "GzAmpLine"));
    MaxGyStep       = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "GyAmpLine"));
    MaxGxStep       = mxGetNumberOfElements(mxGetField(mexGetVariablePtr("global", "VSeq"), 0, "GxAmpLine"));
	
    t               = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "t"));
    dt              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "dt"));
    rfAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfAmp"));
    rfPhase         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfPhase"));
    rfFreq          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfFreq"));
    rfCoil          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfCoil"));
    rfRef           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfRef"));
    GzAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "GzAmp"));
    GyAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "GyAmp"));
    GxAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "GxAmp"));
    ADC             = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "ADC"));
    Ext             = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Ext"));
    KzTmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Kz"));
    KyTmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Ky"));
    KxTmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Kx"));
    utsi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "utsi"));
    rfi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfi"));
    Gzi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gzi"));
    Gyi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gyi"));
    Gxi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gxi"));
    ADCi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "ADCi"));
    Exti            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Exti"));
    TRCount         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "TRCount"));
    
    Sy              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Sy"));
    Sx              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Sx"));
    Kz              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Kz"));
    Ky              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Ky"));
    Kx              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Kx"));
    MzsBase         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Mz"));
    MysBase         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "My"));
    MxsBase         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Mx"));
    Muts            = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Muts"));
    SignalNum       = (mwSize*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "SignalNum"));
    
 /* get dimensions of spin matrix */
    SpinMxDimNum    = mxGetNumberOfDimensions(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
    SpinMxDims      = (mwSize*) mxCalloc(SpinMxDimNum, sizeof(mwSize));
    SpinMxDims      = mxGetDimensions(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
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
    /*  Number of parallel threads that the code will try to use (integer). 
        Set to 1 if you want to use a single core, set >1 for multithreading. 
        This number should be less than the #cpus per machine x #cores/cpu x #thread/core. 
        i.e. a machine which two quad-core cpu's could have upto 8 threads. 
        Note that if there are fewer images than threads...
        then the code will automatically turn down the number of threads 
        (since the extra ones do nothing and waste resources) */
    
/* set buffer */
    buffer1 = ippsMalloc_32f(SpinMxSliceNum*SpinMxNum);
    buffer2 = ippsMalloc_32f(SpinMxSliceNum*SpinMxNum);
    buffer3 = ippsMalloc_32f(SpinMxSliceNum*SpinMxNum);
    buffer4 = ippsMalloc_32f(SpinMxSliceNum*SpinMxNum);
    buffer = ippsMalloc_32f(1);
    
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
        
        if (flag[1]==1 ){ /*update GzAmp */
            if (fabs(*(GzAmpLine+ *Gzi)) <= fabs(*(GzAmpLine + (int)fmin(*Gzi+1, MaxGzStep-1))))
                *GzAmp = *(GzAmpLine+ *Gzi);
            else
                *GzAmp = *(GzAmpLine+ *Gzi+1);
            
            (*Gzi)++;
        }
        
        if (flag[2]==1 ){ /*update GyAmp */
            if (fabs(*(GyAmpLine+ *Gyi)) <= fabs(*(GyAmpLine + (int)fmin(*Gyi+1, MaxGyStep-1))))
                *GyAmp = *(GyAmpLine+ *Gyi);
            else
                *GyAmp = *(GyAmpLine+ *Gyi+1);
            
            (*Gyi)++;
        }
        
        if (flag[3]==1 ){ /*update GxAmp */
            if (fabs(*(GxAmpLine+ *Gxi)) <= fabs(*(GxAmpLine + (int)fmin(*Gxi+1, MaxGxStep-1))))
                *GxAmp = *(GxAmpLine+ *Gxi);
            else
                *GxAmp = *(GxAmpLine+ *Gxi+1);
            
            (*Gxi)++;
        }
        
        *ADC = 0;   /* prevent ADC overflow*/
        if (flag[4]==1){ /* update ADC */
            *ADC = *(ADCLine+ *ADCi);
            
            (*ADCi)++;
        }
        
        if (flag[5]==1){ /* update Ext */
            *Ext = *(ExtLine+ *Exti);
            /* execute extended process */
            if (*Ext != 0){
                ExtCall = mexEvalString("DoExtPlugin");
                if (ExtCall){
                    mexErrMsgTxt("Extended process encounters ERROR!");
                    return;
                }
                
                /* update pointers, avoid pointer change between Matlab and Mex call */
                MzBase          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
                MyBase          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "My"));
                MxBase          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mx"));
                RhoBase         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Rho"));
                T1Base          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T1"));
                T2Base          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T2"));
                dWRndBase       = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dWRnd"));
                dB0Base         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dB0"));
                GzgridBase      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gzgrid"));
                GygridBase      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gygrid"));
                GxgridBase      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gxgrid"));
                TxCoilmgBase    = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilmg"));
                TxCoilpeBase    = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilpe"));
                RxCoilx         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilx"));
                RxCoily         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoily"));
                
                t               = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "t"));
                dt              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "dt"));
                rfAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfAmp"));
                rfPhase         = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfPhase"));
                rfFreq          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfFreq"));
                rfCoil          = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfCoil"));
                rfRef           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfRef"));
                GzAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "GzAmp"));
                GyAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "GyAmp"));
                GxAmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "GxAmp"));
                ADC             = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "ADC"));
                Ext             = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Ext"));
                KzTmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Kz"));
                KyTmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Ky"));
                KxTmp           = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Kx"));
                utsi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "utsi"));
                rfi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfi"));
                Gzi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gzi"));
                Gyi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gyi"));
                Gxi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gxi"));
                ADCi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "ADCi"));
                Exti            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Exti"));
                TRCount         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "TRCount"));
                
            }
            (*Exti)++;
        }
        
        if (flag[0]+flag[1]+flag[2]+flag[3]+flag[4]+flag[5] == 0){ /* reset VVar */
            ippsZero_64f(rfAmp, *TxCoilNum);
            ippsZero_64f(rfPhase, *TxCoilNum);
            ippsZero_64f(rfFreq, *TxCoilNum);
            *GzAmp = 0;
            *GyAmp = 0;
            *GxAmp = 0;
            *ADC = 0;
            *Ext = 0;
        }
        
        /* execute spin precessing */
        if (*dt == 0){ /* end of time point */
            continue;
        }
        else if (*dt < 0){ /* uncontinuous time point process */
            (*TRCount)++;
            
            mexPrintf("TR Counts: %d of %d\n", *TRCount, *TRNum);
            
            switch (*RunMode){
                case 1: /* spin rotation simulation & rf simulation */
                    ippsCopy_32f(MzBase, MzsBase+(*utsi)*(*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum, (*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum);
                    ippsCopy_32f(MyBase, MysBase+(*utsi)*(*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum, (*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum);
                    ippsCopy_32f(MxBase, MxsBase+(*utsi)*(*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum, (*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum);
                    *(Muts+*utsi) = *(Muts+*utsi-1);
                    break;
            }
            continue;
        }
        
        for (Typei = 0; Typei < *TypeNum; Typei++){
            for (Spini = 0; Spini < *SpinNum; Spini++){
                /* signal acquisition */
                if (*ADC == 1)
                {
                    Mx = MxBase + (Typei*(*SpinNum)*SpinMxSliceNum*SpinMxNum + Spini*SpinMxSliceNum*SpinMxNum);
                    My = MyBase + (Typei*(*SpinNum)*SpinMxSliceNum*SpinMxNum + Spini*SpinMxSliceNum*SpinMxNum);

                    for (RxCoili = 0; RxCoili < *RxCoilNum; RxCoili++){  /* signal acquisition per Rx coil */
                        /* RxCoil sensitivity */
						if (*RxCoilDefault == 0){
							ippsMul_32f(Mx, RxCoilx+RxCoili*SpinMxSliceNum*SpinMxNum, buffer1, SpinMxSliceNum*SpinMxNum); 
							ippsMul_32f(My, RxCoily+RxCoili*SpinMxSliceNum*SpinMxNum, buffer2, SpinMxSliceNum*SpinMxNum);
							ippsAdd_32f(buffer1, buffer2, buffer3, SpinMxSliceNum*SpinMxNum);
							
							ippsMul_32f(Mx, RxCoily+RxCoili*SpinMxSliceNum*SpinMxNum, buffer1, SpinMxSliceNum*SpinMxNum);
							ippsMulC_32f_I(-1, buffer1, SpinMxSliceNum*SpinMxNum);
							ippsMul_32f(My, RxCoilx+RxCoili*SpinMxSliceNum*SpinMxNum, buffer2, SpinMxSliceNum*SpinMxNum);
							ippsAdd_32f(buffer1, buffer2, buffer4, SpinMxSliceNum*SpinMxNum);
							
							ippsCopy_32f(buffer3, buffer1, SpinMxSliceNum*SpinMxNum);
							ippsCopy_32f(buffer4, buffer2, SpinMxSliceNum*SpinMxNum);
						}else{
							ippsCopy_32f(Mx, buffer1, SpinMxSliceNum*SpinMxNum);
							ippsCopy_32f(My, buffer2, SpinMxSliceNum*SpinMxNum);
							ippsCopy_32f(Mx, buffer3, SpinMxSliceNum*SpinMxNum);
							ippsCopy_32f(My, buffer4, SpinMxSliceNum*SpinMxNum);
						}
                        
						/* rfRef for demodulating rf Phase */
						if (*rfRef != 0){
							ippsMulC_32f_I((float)cos(-(*rfRef)), buffer1, SpinMxSliceNum*SpinMxNum);
							ippsMulC_32f_I((float)-sin(-(*rfRef)), buffer2, SpinMxSliceNum*SpinMxNum);
							ippsAdd_32f_I(buffer2, buffer1, SpinMxSliceNum*SpinMxNum);
							
							ippsMulC_32f_I((float)sin(-(*rfRef)), buffer3, SpinMxSliceNum*SpinMxNum);
							ippsMulC_32f_I((float)cos(-(*rfRef)), buffer4, SpinMxSliceNum*SpinMxNum);
							ippsAdd_32f_I(buffer4, buffer3, SpinMxSliceNum*SpinMxNum);
						}else{
							ippsCopy_32f(buffer4, buffer3, SpinMxSliceNum*SpinMxNum);
						}
						
						/* signal summation */
						ippsSum_32f(buffer1, SpinMxSliceNum*SpinMxNum, buffer, ippAlgHintFast);
                        Sx[Typei*(*RxCoilNum)*(*SignalNum)+RxCoili*(*SignalNum)+Signali] += (double)*buffer;
                        
                        ippsSum_32f(buffer3, SpinMxSliceNum*SpinMxNum, buffer, ippAlgHintFast);
                        Sy[Typei*(*RxCoilNum)*(*SignalNum)+RxCoili*(*SignalNum)+Signali] += (double)*buffer;
                    } 
                }
                
                /* set openMP for core inner loop */
                #pragma omp parallel num_threads(ThreadNum)
                {   
                    #pragma omp for private(Slicei, Mz, My, Mx, dWRnd, Rho, T1, T2, dB0, Gzgrid, Gygrid, Gxgrid, TxCoilmg, TxCoilpe) 
					/* need private clause to keep variables isolated, VERY IMPORTANT!!! Otherwise cause cross influence by threads */
                        for (Slicei=0; Slicei<SpinMxSliceNum; Slicei++){                                                             
                        
                        /* don't put Matlab function here, may cause Matlab crash! */
						
                        /* set pointer offset for input */
                        Mz			= MzBase + (Typei*(*SpinNum)*SpinMxSliceNum*SpinMxNum + Spini*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        My			= MyBase + (Typei*(*SpinNum)*SpinMxSliceNum*SpinMxNum + Spini*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        Mx			= MxBase + (Typei*(*SpinNum)*SpinMxSliceNum*SpinMxNum + Spini*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        dWRnd		= dWRndBase + (Typei*(*SpinNum)*SpinMxSliceNum*SpinMxNum + Spini*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        
                        Rho			= RhoBase+(Typei*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        T1			= T1Base+ (Typei*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        T2			= T2Base+ (Typei*SpinMxSliceNum*SpinMxNum + Slicei*SpinMxNum);
                        
                        dB0			= dB0Base + Slicei*SpinMxNum;
                        Gzgrid		= GzgridBase + Slicei*SpinMxNum;
                        Gygrid		= GygridBase + Slicei*SpinMxNum;
                        Gxgrid		= GxgridBase + Slicei*SpinMxNum;
                        TxCoilmg	= TxCoilmgBase + Slicei*SpinMxNum;
                        TxCoilpe	= TxCoilpeBase + Slicei*SpinMxNum;
                        
                        /* call spin discrete precessing */
                        BlochKernelNormalCPU((float)*Gyro, CS, SpinNum, Rho, T1, T2, Mz, My, Mx,
											 dB0, dWRnd, Gzgrid, Gygrid, Gxgrid, TxCoilmg, TxCoilpe,
											 (float)*dt, rfAmp, rfPhase, rfFreq, (float)*GzAmp, (float)*GyAmp, (float)*GxAmp,
											 Typei, SpinMxNum, SpinMxSliceNum, *TxCoilNum);
                        
                        
                    }
                }
            }
        }
        
        if (*ADC == 1){
            
            Kz[Signali] += *KzTmp;
            Ky[Signali] += *KyTmp;
            Kx[Signali] += *KxTmp;
            Signali++;
        }
        
        /* update Kz, Ky & Kx */
        *KzTmp +=(*GzAmp)*(*dt)*(*Gyro/(2*PI));
        *KyTmp +=(*GyAmp)*(*dt)*(*Gyro/(2*PI));
        *KxTmp +=(*GxAmp)*(*dt)*(*Gyro/(2*PI));
        
        switch (*RunMode){
            case 1: /* spin rotation simulation & rf simulation */
                ippsCopy_32f(MzBase, MzsBase+(*utsi)*(*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum, (*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum);
                ippsCopy_32f(MyBase, MysBase+(*utsi)*(*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum, (*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum);
                ippsCopy_32f(MxBase, MxsBase+(*utsi)*(*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum, (*TypeNum)*(*SpinNum)*SpinMxSliceNum*SpinMxNum);
                *(Muts+*utsi) = *(Muts+*utsi-1) + *dt;
                break;
                
        }
    }
}


