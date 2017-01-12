

/************************************************************************
 MEX code for Magnetization Transfer (MT) spin discrete evolution using IPP or Framewave and 
 parallel GPU computation (CUDA) written by Fang Liu (leoliuf@gmail.com).
************************************************************************/

/* system header */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
/* MEX header */
#include <mex.h> 
#include "matrix.h"
/* nVIDIA CUDA header */
#include <cuda.h> 
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

/* for fixing error : identifier "IUnknown" is undefined" */
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#endif

#if defined(_WIN32) || defined(_WIN64)
#include <windows.h>
#endif

#define PI      3.14159265359 /* pi constant */

/* includes CUDA kernel */
#include "BlochKernelMT.cuh"
extern "C" bool mxUnshareArray(mxArray *array_ptr, bool noDeepCopy);

/* MEX entry function */
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])

{
/* pointers for VObj */
    double *Gyro;
    int SpinMxNum, SpinMxColNum, SpinMxRowNum, SpinMxSliceNum, SpinMxDimNum;
    const mwSize *SpinMxDims;
	float *Mz, *My, *Mx, *Rho, *T1, *T2, *K;

/* pointers for VMag */
    float *dB0, *dWRnd, *Gzgrid, *Gygrid, *Gxgrid;
    
/* pointers for VCoi */
    float *RxCoilx, *RxCoily, *TxCoilmg, *TxCoilpe;
	double *RxCoilDefault, *TxCoilDefault;
    
/* pointers for VCtl */
    double *CS;
    int *TRNum, *MaxThreadNum, ThreadNum, *RunMode;
	int *ActiveThreadNum;
	int *GPUIndex;
    
/* pointers for VSeq */
    double *utsLine, *tsLine, *rfAmpLine, *rfPhaseLine, *rfFreqLine, *rfCoilLine, *GzAmpLine, *GyAmpLine, *GxAmpLine, *ADCLine, *ExtLine, *flagsLine;

/* pointers for VVar */
    double *t, *dt, *rfAmp, *rfPhase, *rfFreq, *rfCoil, *rfRef, *GzAmp, *GyAmp, *GxAmp, *ADC, *Ext, *KzTmp, *KyTmp, *KxTmp, *gpuFetch;
    int *utsi, *rfi, *Gzi, *Gyi, *Gxi, *ADCi, *Exti, *TRCount;
    
/* pointers for VSig */
    double *Sx, *Sy, *Kz, *Ky, *Kx, *Muts;
	float *Mxs, *Mys, *Mzs;
	double *p_Sx, *p_Sy;
	
/* loop control */
    int i=0, j=0, s=0, Signali=0, Signalptr=0, PreSignalLen=0, SignalLen=0, SBufferLen=0, Typei, RxCoili, TxCoili;
    int MaxStep, MaxutsStep, MaxrfStep, MaxGzStep, MaxGyStep, MaxGxStep, *SpinNum, *TypeNum, *TxCoilNum, *RxCoilNum, *SignalNum;
    double flag[6];
    
/* IPP or FW buffer */
    Ipp32f buffer, *Sxbuffer, *Sybuffer;
	
/* function status */
    int ExtCall;
    
/* GPU execution sequence */
	std::vector<float> g_Sig;	

/* force breaking Copy-on-Write in Matlab */   
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VObj")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VMag")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VCoi")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VCtl")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VSeq")), true);
	mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VVar")), true);
    mxUnshareArray(const_cast<mxArray *>(mexGetVariablePtr("global", "VSig")), true);
    
/* assign pointers */
   Gyro            = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Gyro"));
    Mz              = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
    My              = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "My"));
    Mx              = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mx"));
    Rho             = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Rho"));
    T1              = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T1"));
    T2              = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T2"));
	K               = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "K"));
    SpinNum         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "SpinNum"));
    TypeNum         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "TypeNum"));
    
    dB0             = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dB0"));
    dWRnd           = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dWRnd"));
    Gzgrid          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gzgrid"));
    Gygrid          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gygrid"));
    Gxgrid          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gxgrid"));
    
    TxCoilmg        = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilmg"));
    TxCoilpe        = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilpe"));
    RxCoilx         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilx"));
    RxCoily         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoily"));
    TxCoilNum       = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilNum"));
    RxCoilNum       = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilNum"));
	TxCoilDefault   = (double*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilDefault"));
    RxCoilDefault   = (double*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilDefault"));
     
    CS              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "CS"));
    TRNum  			= (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "TRNum"));
	RunMode         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "RunMode"));
    MaxThreadNum    = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "MaxThreadNum"));
	ActiveThreadNum = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "ActiveThreadNum"));
	GPUIndex		= (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VCtl"), 0, "GPUIndex"));
    
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
	gpuFetch     	= (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "gpuFetch"));
    utsi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "utsi"));
    rfi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfi"));
    Gzi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gzi"));
    Gyi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gyi"));
    Gxi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gxi"));
    ADCi            = (int*)	mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "ADCi"));
    Exti            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Exti"));
    TRCount         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "TRCount"));
	
	Sy              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Sy"));
    Sx              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Sx"));
    Kz              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Kz"));
    Ky              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Ky"));
    Kx              = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Kx"));
	Mzs         	= (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Mz"));
    Mys             = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "My"));
    Mxs             = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Mx"));
    Muts            = (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "Muts"));
    SignalNum       = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VSig"), 0, "SignalNum"));
    
/* get size of spin matrix */
    SpinMxDimNum    		= mxGetNumberOfDimensions(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
    SpinMxDims      		= (mwSize*) mxCalloc(SpinMxDimNum, sizeof(mwSize));
    SpinMxDims      		= mxGetDimensions(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
	
    SpinMxRowNum    		= SpinMxDims[0];
    SpinMxColNum    		= SpinMxDims[1];
    SpinMxNum       		= SpinMxDims[0] * SpinMxDims[1];
    if (SpinMxDimNum == 2){
        SpinMxSliceNum = 1;
    }else{
        SpinMxSliceNum = SpinMxDims[2];
    }
	
/* choose selected GPU */
	if( cudaSuccess != cudaSetDevice(*GPUIndex)){
        mexPrintf( "\n%s", cudaGetErrorString(cudaGetLastError()));
        return;
    }
	
/* set GPU grid & block configuration*/
    cudaDeviceProp deviceProp;
    memset( &deviceProp, 0, sizeof(deviceProp));
    if( cudaSuccess != cudaGetDeviceProperties(&deviceProp, *GPUIndex)){
        mexPrintf( "\n%s", cudaGetErrorString(cudaGetLastError()));
        return;
    }

	dim3 dimGridImg(SpinMxColNum,1,1);
    dim3 dimBlockImg(1,SpinMxRowNum,1);

	for (i=SpinMxColNum - 1; i >= deviceProp.multiProcessorCount; i--){
		if ( SpinMxNum % i == 0 ){
			if (SpinMxNum/i > deviceProp.maxThreadsPerBlock) break;
			if ((SpinMxNum/i)*63 > deviceProp.regsPerBlock) break; // 63 registers per thread for current kernel
			dimGridImg.x = i;
		    dimBlockImg.y = SpinMxNum/i;
		}
	}
	i=0;
	
/* allocate device memory for matrices */
    float *d_Mz = NULL;
    cudaMalloc( (void**) &d_Mz, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_Mz, Mz, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_My = NULL;
    cudaMalloc( (void**) &d_My, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_My, My, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_Mx = NULL;
    cudaMalloc( (void**) &d_Mx, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_Mx, Mx, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_dWRnd = NULL;
    cudaMalloc( (void**) &d_dWRnd, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_dWRnd, dWRnd, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_Rho = NULL;
    cudaMalloc( (void**) &d_Rho, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_Rho, Rho, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_T1 = NULL;
    cudaMalloc( (void**) &d_T1, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_T1, T1, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_T2 = NULL;
    cudaMalloc( (void**) &d_T2, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_T2, T2, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
	
	float *d_K = NULL;
    cudaMalloc( (void**) &d_K, SpinMxNum * SpinMxSliceNum * (*TypeNum) * (*TypeNum) * sizeof(float)) ;
	cudaMemcpy( d_K, K, SpinMxNum * SpinMxSliceNum * (*TypeNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_Gzgrid = NULL;
    cudaMalloc( (void**) &d_Gzgrid, SpinMxNum * SpinMxSliceNum * sizeof(float)) ;
	cudaMemcpy( d_Gzgrid, Gzgrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_Gygrid = NULL;
    cudaMalloc( (void**) &d_Gygrid, SpinMxNum * SpinMxSliceNum * sizeof(float)) ;
	cudaMemcpy( d_Gygrid, Gygrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_Gxgrid = NULL;
    cudaMalloc( (void**) &d_Gxgrid, SpinMxNum * SpinMxSliceNum * sizeof(float)) ;
	cudaMemcpy( d_Gxgrid, Gxgrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice ) ;
    
    float *d_dB0 = NULL;
    cudaMalloc( (void**) &d_dB0, SpinMxNum * SpinMxSliceNum * sizeof(float)) ;
	cudaMemcpy( d_dB0, dB0, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice ) ;

    float *d_TxCoilmg = NULL;
    cudaMalloc( (void**) &d_TxCoilmg, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float)) ;
	cudaMemcpy( d_TxCoilmg, TxCoilmg, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float), cudaMemcpyHostToDevice ) ;

    float *d_TxCoilpe = NULL;
    cudaMalloc( (void**) &d_TxCoilpe, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float)) ;
	cudaMemcpy( d_TxCoilpe, TxCoilpe, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
	
	float *d_RxCoilx = NULL;
    cudaMalloc( (void**) &d_RxCoilx, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float)) ;
	cudaMemcpy( d_RxCoilx, RxCoilx, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float), cudaMemcpyHostToDevice ) ;

	float *d_RxCoily = NULL;
    cudaMalloc( (void**) &d_RxCoily, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float)) ;
	cudaMemcpy( d_RxCoily, RxCoily, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float), cudaMemcpyHostToDevice ) ;
	
    double *d_CS = NULL;
    cudaMalloc( (void**) &d_CS, *TypeNum * sizeof(double)) ;
	cudaMemcpy( d_CS, CS, *TypeNum * sizeof(double), cudaMemcpyHostToDevice ) ;
	
/* allocate device memory for GPU execution sequence*/
    float *d_Sig = NULL;
    cudaMalloc( (void**) &d_Sig, (5+3*(*TxCoilNum)) * MaxutsStep * sizeof(float)) ;
	
/* allocate device memory according to RunMode */
	float *d_b_Mz = NULL;
	float *d_b_My = NULL;
	float *d_b_Mx = NULL;

	switch (*RunMode){
		case 1: /* spin rotation simulation & rf simulation */
			cudaMalloc( (void**) &d_b_Mz, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float));
			cudaMalloc( (void**) &d_b_My, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float));
			cudaMalloc( (void**) &d_b_Mx, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float));
			/* zero buffer */
			cudaMemset(d_b_Mz, 0 ,SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float)); /* only work for 0 */
			cudaMemset(d_b_My, 0 ,SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float)); /* only work for 0 */
			cudaMemset(d_b_Mx, 0 ,SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float)); /* only work for 0 */

			break;
			
		default:
			cudaMalloc( (void**) &d_b_Mz, 1 * sizeof(float)) ;
			cudaMalloc( (void**) &d_b_My, 1 * sizeof(float)) ;
			cudaMalloc( (void**) &d_b_Mx, 1 * sizeof(float)) ;

			break;
	}
	
/* set CPU signal buffer */
	Sxbuffer    = ippsMalloc_32f(SpinMxNum * PreSignalLen * (*TypeNum) * (*RxCoilNum));
	Sybuffer    = ippsMalloc_32f(SpinMxNum * PreSignalLen * (*TypeNum) * (*RxCoilNum));

/* allocate device memory for buffering acquired signal */
    float *d_Sx = NULL;
    cudaMalloc( (void**) &d_Sx, SpinMxNum * PreSignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)) ;
    float *d_Sy = NULL;
    cudaMalloc( (void**) &d_Sy, SpinMxNum * PreSignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)) ;

/* start simulator execution loop */
	mexPrintf("------ Current active GPU device : %s ------\n", &deviceProp.name[0]);
    mexPrintf("TR Counts: %d of %d\n", 1, *TRNum);
    while (i < MaxStep){
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
        *t 		= *(utsLine + *utsi);
        *dt		= *(utsLine + (int)min(*utsi+1, MaxutsStep-1))-*(utsLine + *utsi);
        *utsi	= (int)*utsi+1;  /* how to address the end point of the sequence? */
		g_Sig.push_back((float)*dt);
		
		switch (*RunMode){
			case 1: /* spin rotation simulation & rf simulation */
				if (*dt > 0)
					*(Muts+*utsi) = *(Muts+*utsi-1) + *dt;
				else if (*dt < 0)
					*(Muts+*utsi) = *(Muts+*utsi-1);
				
				break;
		}
		
        if (flag[0]>=1 ){ /* update rfAmp, rfPhase, rfFreq, rfCoil for multiple rf lines */
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
			
			for (j = 0; j < *TxCoilNum; j++){ /* multi-Tx, deal with rfPhase */
				if (rfAmp[j]<0){
					rfAmp[j]=fabs(rfAmp[j]);
					rfPhase[j]=rfPhase[j]+PI;
				}
			}
        }

		for (j = 0; j < *TxCoilNum; j++){
			g_Sig.push_back((float)rfAmp[j]);
			g_Sig.push_back((float)rfPhase[j]);
			g_Sig.push_back((float)rfFreq[j]);
		}

        if (flag[1]==1 ){ /* update GzAmp */
            if (fabs(*(GzAmpLine+ *Gzi)) <= fabs(*(GzAmpLine + (int)min(*Gzi+1, MaxGzStep-1))))
                *GzAmp = *(GzAmpLine+ *Gzi);
            else
                *GzAmp = *(GzAmpLine+ *Gzi+1);
            
            (*Gzi)++;
        }
        g_Sig.push_back((float)*GzAmp);
		
        if (flag[2]==1 ){ /* update GyAmp */
            if (fabs(*(GyAmpLine+ *Gyi)) <= fabs(*(GyAmpLine + (int)min(*Gyi+1, MaxGyStep-1))))
                *GyAmp = *(GyAmpLine+ *Gyi);
            else
                *GyAmp = *(GyAmpLine+ *Gyi+1);
            
            (*Gyi)++;
        }
        g_Sig.push_back((float)*GyAmp);
		
        if (flag[3]==1 ){ /* update GxAmp */
            if (fabs(*(GxAmpLine+ *Gxi)) <= fabs(*(GxAmpLine + (int)min(*Gxi+1, MaxGxStep-1))))
                *GxAmp = *(GxAmpLine+ *Gxi);
            else
                *GxAmp = *(GxAmpLine+ *Gxi+1);
            
            (*Gxi)++;
        }			
		g_Sig.push_back((float)*GxAmp);
        
        *ADC = 0;   /* avoid ADC overflow */
        if (flag[4]==1){ /* update ADC */
            *ADC = *(ADCLine+ *ADCi);
            (*ADCi)++;
        }
		g_Sig.push_back((float)*ADC);
		
		if (*ADC == 1){
			/* update k-space */
            Kz[Signali] += *KzTmp;
            Ky[Signali] += *KyTmp;
            Kx[Signali] += *KxTmp;
            Signali++;
		}
		
		 /* update Kz, Ky & Kx buffer */
        *KzTmp +=(*GzAmp)*(*dt)*(*Gyro/(2*PI));
        *KyTmp +=(*GyAmp)*(*dt)*(*Gyro/(2*PI));
        *KxTmp +=(*GxAmp)*(*dt)*(*Gyro/(2*PI));
		
        if (flag[5]==1){ /* update Ext */
            *Ext = *(ExtLine+ *Exti);
            /* execute extended process */
            if (*Ext != 0){
				if (g_Sig.size() !=0){
				
					/* calculate signal length */
					SignalLen = Signali-Signalptr;

					/* reset buffer */
					if (PreSignalLen!=SignalLen && SignalLen>0){
						PreSignalLen = SignalLen;
						/* allocate device memory for acquired signal buffer */
						cudaFree(d_Sx);
						cudaFree(d_Sy);
						cudaMalloc( (void**) &d_Sx, SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)) ;
						cudaMalloc( (void**) &d_Sy, SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)) ;
						/* zero signal buffer */
						cudaMemset(d_Sx, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
						cudaMemset(d_Sy, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
						/* set buffer */
						ippsFree(Sxbuffer);
						ippsFree(Sybuffer);
						Sxbuffer = ippsMalloc_32f(SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum));
						Sybuffer = ippsMalloc_32f(SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum));
					}

					/* avoid shared memory overflow */
					if (g_Sig.size() * sizeof(float) > deviceProp.sharedMemPerBlock){
						SBufferLen = 0;
					}else{
						SBufferLen = g_Sig.size() * sizeof(float);
					}

					/* upload GPU sequence */
					cudaMemcpy( d_Sig, 	&g_Sig[0], 	g_Sig.size() * sizeof(float),	cudaMemcpyHostToDevice ) ;

					/* call GPU kernel for spin discrete precessing */
					BlochKernelMTGPU<<< dimGridImg, dimBlockImg, SBufferLen >>>
										((float)*Gyro, d_CS, d_Rho, d_T1, d_T2, d_K, d_Mz, d_My, d_Mx,
										d_dB0, d_dWRnd, d_Gzgrid, d_Gygrid, d_Gxgrid, d_TxCoilmg, d_TxCoilpe, d_RxCoilx, d_RxCoily,
										d_Sig, (float)*RxCoilDefault, (float)*TxCoilDefault,
										d_Sx, d_Sy, (float)*rfRef, SignalLen, SBufferLen,
										*RunMode, *utsi, d_b_Mz, d_b_My, d_b_Mx,
										SpinMxColNum, SpinMxRowNum, SpinMxSliceNum, *SpinNum, *TypeNum, *TxCoilNum, *RxCoilNum, g_Sig.size()/(5+3*(*TxCoilNum)));
					cudaThreadSynchronize();
					g_Sig.clear();
					Signalptr = Signali; /* shift signal array pointer */
				}
				
				/* signal acquisition */
				if (SignalLen>0){
					/* get Sx, Sy buffer from GPU */
					cudaMemcpy( Sybuffer, d_Sy, SpinMxNum * SignalLen * (*RxCoilNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost ) ;
					cudaMemcpy( Sxbuffer, d_Sx, SpinMxNum * SignalLen * (*RxCoilNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost ) ;
					
					/* sum MR signal via openMP */
					for (Typei = 0; Typei < *TypeNum; Typei++){
						for (RxCoili = 0; RxCoili < *RxCoilNum; RxCoili++){  /* signal acquisition per Rx coil */
							#pragma omp parallel
							{   
								#pragma omp for private(j, s, p_Sx, p_Sy, buffer) 
								for (j=0; j < SignalLen; j++){
									
									if (j==0){
										*ActiveThreadNum = omp_get_num_threads();
									}
									
									s=Signali-SignalLen+j;
									p_Sx = Sx + (Typei*(*RxCoilNum)*(*SignalNum)+RxCoili*(*SignalNum)+s);
									p_Sy = Sy + (Typei*(*RxCoilNum)*(*SignalNum)+RxCoili*(*SignalNum)+s);
								
									ippsSum_32f(&Sxbuffer[Typei * (SpinMxNum * SignalLen * (*RxCoilNum)) + RxCoili * (SpinMxNum * SignalLen) +  j*SpinMxNum], SpinMxNum, &buffer, ippAlgHintFast);
									*p_Sx = (double)buffer;
									ippsSum_32f(&Sybuffer[Typei * (SpinMxNum * SignalLen * (*RxCoilNum)) + RxCoili * (SpinMxNum * SignalLen) +  j*SpinMxNum], SpinMxNum, &buffer, ippAlgHintFast);
									*p_Sy = (double)buffer;
								
								}
							}
						}       
					}
					
					/* zero signal buffer */
					cudaMemset(d_Sx, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
					cudaMemset(d_Sy, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
				}

			    /* fetch GPU data? */
                ExtCall = mexEvalString("DoGPUFetch");
                if (ExtCall){
                    mexErrMsgTxt("Extended process encounters ERROR!");
                    return;
                }
				
				if (*gpuFetch !=0){
					/* fetch data from GPU */
					cudaMemcpy( Mz, d_Mz, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( My, d_My, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( Mx, d_Mx, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( dWRnd, d_dWRnd, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( Rho, d_Rho, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( T1, d_T1, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( T2, d_T2, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( K, d_K, SpinMxNum * SpinMxSliceNum * (*TypeNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( Gzgrid, d_Gzgrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( Gygrid, d_Gygrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( Gxgrid, d_Gxgrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( dB0, d_dB0, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( TxCoilmg, d_TxCoilmg, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( TxCoilpe, d_TxCoilpe, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( RxCoilx, d_RxCoilx, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float), cudaMemcpyDeviceToHost );
					cudaMemcpy( RxCoily, d_RxCoily, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float), cudaMemcpyDeviceToHost );
				}

                /* execute extended process */
                ExtCall = mexEvalString("DoExtPlugin");
                if (ExtCall){
                    mexErrMsgTxt("Extended process encounters ERROR!");
                    return;
                }

                /* update pointers, avoid pointer change between Matlab and Mex call */
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
                gpuFetch     	= (double*) mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "gpuFetch"));
                utsi            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "utsi"));
                rfi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "rfi"));
                Gzi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gzi"));
                Gyi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gyi"));
                Gxi             = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Gxi"));
                ADCi            = (int*)	mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "ADCi"));
                Exti            = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "Exti"));
                TRCount         = (int*)    mxGetData(mxGetField(mexGetVariablePtr("global", "VVar"), 0, "TRCount"));

				if (*gpuFetch !=0){
					*gpuFetch =0;
					/* update pointers, avoid pointer change between Matlab and Mex call */
					Mz          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mz"));
					My          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "My"));
					Mx          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Mx"));
					Rho         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "Rho"));
					T1          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T1"));
					T2          = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "T2"));
					K           = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VObj"), 0, "K"));
					dWRnd       = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dWRnd"));
					dB0         = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "dB0"));
					Gzgrid      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gzgrid"));
					Gygrid      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gygrid"));
					Gxgrid      = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VMag"), 0, "Gxgrid"));
					TxCoilmg    = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilmg"));
					TxCoilpe    = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "TxCoilpe"));
					RxCoilx     = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoilx"));
					RxCoily     = (float*) mxGetData(mxGetField(mexGetVariablePtr("global", "VCoi"), 0, "RxCoily"));

					/* send data back to GPU */
					cudaMemcpy( d_Mz, Mz, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_My, My, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_Mx, Mx, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_dWRnd, dWRnd, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_Rho, Rho, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_T1, T1, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_T2, T2, SpinMxNum * SpinMxSliceNum * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_K, K, SpinMxNum * SpinMxSliceNum * (*TypeNum) * (*TypeNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_Gzgrid, Gzgrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_Gygrid, Gygrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_Gxgrid, Gxgrid, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_dB0, dB0, SpinMxNum * SpinMxSliceNum * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_TxCoilmg, TxCoilmg, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_TxCoilpe, TxCoilpe, SpinMxNum * SpinMxSliceNum * (*TxCoilNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_RxCoilx, RxCoilx, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float), cudaMemcpyHostToDevice );
					cudaMemcpy( d_RxCoily, RxCoily, SpinMxNum * SpinMxSliceNum * (*RxCoilNum) * sizeof(float), cudaMemcpyHostToDevice );
				}
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
        
		/* check TR point & end of time point */
		 if (*dt <= 0){ 
			if (g_Sig.size() !=0){
				/* calculate signal length */
				SignalLen = Signali-Signalptr;

				/* reset buffer if needed */
				if (PreSignalLen!=SignalLen && SignalLen>0){
					PreSignalLen = SignalLen;
					/* allocate device memory for acquired signal buffer */
					cudaFree(d_Sx);
					cudaFree(d_Sy);
					cudaMalloc( (void**) &d_Sx, SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)) ;
					cudaMalloc( (void**) &d_Sy, SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)) ;
					/* zero signal buffer */
					cudaMemset(d_Sx, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
					cudaMemset(d_Sy, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
					/* set buffer */
					ippsFree(Sxbuffer);
					ippsFree(Sybuffer);
					Sxbuffer = ippsMalloc_32f(SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum));
					Sybuffer = ippsMalloc_32f(SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum));
				}

				/* avoid shared memory overflow */
				if (g_Sig.size() * sizeof(float) > deviceProp.sharedMemPerBlock){
					SBufferLen = 0;
				}else{
					SBufferLen = g_Sig.size() * sizeof(float);
				}

				/* upload GPU sequence */
				cudaMemcpy( d_Sig, 	&g_Sig[0], 	g_Sig.size() * sizeof(float),	cudaMemcpyHostToDevice ) ;

				/* call GPU kernel for spin discrete precessing */
				BlochKernelMTGPU<<< dimGridImg, dimBlockImg, SBufferLen >>>
									((float)*Gyro, d_CS, d_Rho, d_T1, d_T2, d_K, d_Mz, d_My, d_Mx,
									d_dB0, d_dWRnd, d_Gzgrid, d_Gygrid, d_Gxgrid, d_TxCoilmg, d_TxCoilpe, d_RxCoilx, d_RxCoily,
									d_Sig, (float)*RxCoilDefault, (float)*TxCoilDefault,
									d_Sx, d_Sy, (float)*rfRef, SignalLen, SBufferLen,
									*RunMode, *utsi, d_b_Mz, d_b_My, d_b_Mx,
									SpinMxColNum, SpinMxRowNum, SpinMxSliceNum, *SpinNum, *TypeNum, *TxCoilNum, *RxCoilNum, g_Sig.size()/(5+3*(*TxCoilNum)));
				cudaThreadSynchronize(); /* stabilize simulation */
				g_Sig.clear();
				Signalptr = Signali;
			}
			
			/* signal acquisition */
			if (SignalLen>0){
				/* get Sx, Sy buffer from GPU */
				cudaMemcpy( Sybuffer, d_Sy, SpinMxNum * SignalLen * (*RxCoilNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost ) ;
				cudaMemcpy( Sxbuffer, d_Sx, SpinMxNum * SignalLen * (*RxCoilNum) * (*TypeNum) * sizeof(float), cudaMemcpyDeviceToHost ) ;
				
				/* sum MR signal via openMP */
				for (Typei = 0; Typei < *TypeNum; Typei++){
					for (RxCoili = 0; RxCoili < *RxCoilNum; RxCoili++){  /* signal acquisition per Rx coil */
						#pragma omp parallel
						{   
							#pragma omp for private(j, s, p_Sx, p_Sy, buffer) 
							for (j=0; j < SignalLen; j++){
								
								if (j==0){
									*ActiveThreadNum = omp_get_num_threads();
								}
								
								s=Signali-SignalLen+j;
								p_Sx = Sx + (Typei*(*RxCoilNum)*(*SignalNum)+RxCoili*(*SignalNum)+s);
								p_Sy = Sy + (Typei*(*RxCoilNum)*(*SignalNum)+RxCoili*(*SignalNum)+s);
							
								ippsSum_32f(&Sxbuffer[Typei * (SpinMxNum * SignalLen * (*RxCoilNum)) + RxCoili * (SpinMxNum * SignalLen) +  j*SpinMxNum], SpinMxNum, &buffer, ippAlgHintFast);
								*p_Sx = (double)buffer;
								ippsSum_32f(&Sybuffer[Typei * (SpinMxNum * SignalLen * (*RxCoilNum)) + RxCoili * (SpinMxNum * SignalLen) +  j*SpinMxNum], SpinMxNum, &buffer, ippAlgHintFast);
								*p_Sy = (double)buffer;
							
							}
						}
					}       
				}
				
				/* zero signal buffer */
				cudaMemset(d_Sx, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
				cudaMemset(d_Sy, 0 ,SpinMxNum * SignalLen * (*TypeNum) * (*RxCoilNum) * sizeof(float)); /* only work for 0 */
			}

			if (*dt < 0){
				(*TRCount)++;
				mexPrintf("TR Counts: %d of %d\n", *TRCount, *TRNum);
			}
        }
    }

	
	switch (*RunMode){
		case 1: /* spin rotation simulation & rf simulation */

			/* Get Mx, My & Mz from GPU */
			cudaMemcpy( Mzs, d_b_Mz, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float), cudaMemcpyDeviceToHost ) ;
			cudaMemcpy( Mys, d_b_My, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float), cudaMemcpyDeviceToHost ) ;
			cudaMemcpy( Mxs, d_b_Mx, SpinMxNum * SpinMxSliceNum * (*SpinNum) * (*TypeNum) * MaxutsStep * sizeof(float), cudaMemcpyDeviceToHost ) ;
			break;
	}
	
    /* free GPU memory */
    cudaFree(d_Mz);
    cudaFree(d_My);
    cudaFree(d_Mx);
    cudaFree(d_dWRnd);
    cudaFree(d_Rho);
    cudaFree(d_T1);
    cudaFree(d_T2);
	cudaFree(d_K);
    cudaFree(d_Gzgrid);
    cudaFree(d_Gygrid);
    cudaFree(d_Gxgrid);
    cudaFree(d_dB0);
    cudaFree(d_TxCoilmg);
    cudaFree(d_TxCoilpe);
	cudaFree(d_RxCoilx);
    cudaFree(d_RxCoily);
    cudaFree(d_CS);
    cudaFree(d_Sig);
	cudaFree(d_Sx);
	cudaFree(d_Sy);
	cudaFree(d_b_Mz);
    cudaFree(d_b_My);
    cudaFree(d_b_Mx);
	
	/* reset device, may slow down subsequent startup due to initialization */
	// cudaDeviceReset();
    
}
