/* Magnetization Transfer (MT) Bloch Equation Kernel running at CUDA GPU */

#ifndef _BLOCH_KERNEL_MT_GPU_H_
#define _BLOCH_KERNEL_MT_GPU_H_

__global__ void
BlochKernelMTGPU(float Gyro, double *d_CS, float *d_Rho, float *d_T1, float *d_T2, float *d_K, float *d_Mz, float *d_My, float *d_Mx,
				 float *d_dB0, float *d_dWRnd, float *d_Gzgrid, float *d_Gygrid, float *d_Gxgrid, float *d_TxCoilmg, float *d_TxCoilpe, float *d_RxCoilx, float *d_RxCoily, 
				 float *d_Sig, float RxCoilDefault, float TxCoilDefault,
				 float *d_Sx, float *d_Sy, float rfRef, int SignalLen, int SBufferLen,
				 int RunMode, int utsi, float *d_b_Mz, float *d_b_My, float *d_b_Mx,
				 int SpinMxX, int SpinMxY, int SpinMxZ, int SpinNum, int TypeNum, int TxCoilNum, int RxCoilNum, int SeqLen)
{
    /* CUDA index */
	unsigned tid	 = blockIdx.x * blockDim.y + threadIdx.y; /* thread id in one slice */
	unsigned id      = threadIdx.y;                           /* thread id in one block */

	/* sequence buffer in shared memory */
	float *g_d_Sig;
	extern __shared__ float s_d_Sig[];
	int i;
	if (SBufferLen !=0){
		for (i=0; i< (int)floor((float)(SeqLen*(5 + 3 * TxCoilNum))/(float)blockDim.y); i++){
			s_d_Sig[blockDim.y*i+id] = d_Sig[blockDim.y*i+id];
		}
		if (blockDim.y*i+id < SeqLen*(5 + 3 * TxCoilNum)){
			s_d_Sig[blockDim.y*i+id] = d_Sig[blockDim.y*i+id];
		}

        __syncthreads();
		g_d_Sig = s_d_Sig;
	}else{
		g_d_Sig = d_Sig;
	}

	/* matrix dim */
	int SpinMxNum	 = SpinMxX * SpinMxY;
	int SpinMxAllNum = SpinMxX * SpinMxY * SpinMxZ;
	
	/* signal counter*/
	int Signalptr;
	
	/* dt buffer */
	float dt;
	float ExpdtT2;
	float ExpdtT1;
	float M0dtT1;
	float ExpdtK;
	float rffreq;
	float t2b;
	float ExpdtT1b;
	float M0dtT1b;
	float ExpdtKb;
	
	/* matrix pointers */
	float *p_d_Mz;
	float *p_d_Mzb;
	float *p_d_My;
	float *p_d_Mx;
	float *p_d_dWRnd;
	float *p_d_Rho;
	float *p_d_T1;
	float *p_d_T2;
	float *p_d_K12;
	float *p_d_K21;
	float *p_d_Gzgrid;
	float *p_d_Gygrid;
	float *p_d_Gxgrid;
	float *p_d_dB0;
	float *p_d_TxCoilmg;
	float *p_d_TxCoilpe;
	float *p_d_RxCoilx;
	float *p_d_RxCoily;
	float *p_d_Sx;
	float *p_d_Sy;
	
	float *p_d_rfAmp;
	float *p_d_rfPhase;
	float *p_d_rfFreq;
	float *p_d_GzAmp;
	float *p_d_GyAmp;
	float *p_d_GxAmp;
	float *p_d_dt;
	float *p_d_ADC;
	
	float *p_d_b_Mx;
	float *p_d_b_My;
	float *p_d_b_Mz;
	
	/* multi-Tx  variables */
	float rfAmpSum; 
	float rfAmp;
	float rfPhase;
	float rfFreq;
	float buffer1;
	float buffer2;
	float buffer3;
	float buffer4;
	
	/* spin variables */
	float Mx, My, Mz;
	float T1, T2, Rho;
	float Gzgrid, Gygrid, Gxgrid, dB0, dWRnd;
	float Mzb, T1b, T2b, Rhob;
	float K12, K21;
	
	/* temporary  variables */
	float dW, sinAlpha, sinBeta, sinPhi, cosAlpha, cosBeta, cosPhi, Alpha, Beta;
	float bufferMz, bufferMy, bufferMx;
	float Mzbuffer, Mzbbuffer;
	float u, n, G, W;
	
	/* loop through slice <- spins <- species */
	rffreq = g_d_Sig[3] + 1; /* rffreq != rfFreq at start-up */
	t2b     = 0;   /* flag for calculating lineshape */
	for (int s=0; s < SpinNum; s++){
		for (int k=0; k < SpinMxZ; k++){
			/* free pool */
			p_d_Rho			= d_Rho 		+ k * SpinMxNum	+ tid 	+ 0 * SpinMxAllNum;
			p_d_T1        	= d_T1 			+ k * SpinMxNum	+ tid 	+ 0 * SpinMxAllNum;
			p_d_T2        	= d_T2 			+ k * SpinMxNum	+ tid 	+ 0 * SpinMxAllNum;
			
			if (*p_d_T2==0 || *p_d_T1==0 || *p_d_Rho==0) continue; /* avoid background  23%*/
			
			/* free pool */
			p_d_Mz        	= d_Mz 			+ k * SpinMxNum	+ tid 	+ 0 * (SpinMxAllNum * SpinNum) 	+ s * SpinMxAllNum;
			p_d_My        	= d_My 			+ k * SpinMxNum	+ tid 	+ 0 * (SpinMxAllNum * SpinNum) 	+ s * SpinMxAllNum;
			p_d_Mx        	= d_Mx 			+ k * SpinMxNum	+ tid 	+ 0 * (SpinMxAllNum * SpinNum) 	+ s * SpinMxAllNum;
			p_d_dWRnd		= d_dWRnd 		+ k * SpinMxNum	+ tid 	+ 0 * (SpinMxAllNum * SpinNum) 	+ s * SpinMxAllNum;
			Rho 			= *p_d_Rho;
			T1              = *p_d_T1;
			T2 				= *p_d_T2;
			Mx              = *p_d_Mx;
			My				= *p_d_My;
			Mz              = *p_d_Mz;
			Mzbuffer		= Mz;
			dWRnd			= *p_d_dWRnd;
			
			/* bound pool */
			p_d_Rho			= d_Rho 		+ k * SpinMxNum	+ tid 	+ 1 * SpinMxAllNum;
			p_d_T1        	= d_T1 			+ k * SpinMxNum	+ tid 	+ 1 * SpinMxAllNum;
			p_d_T2        	= d_T2 			+ k * SpinMxNum	+ tid 	+ 1 * SpinMxAllNum;
			p_d_Mzb        	= d_Mz 			+ k * SpinMxNum	+ tid 	+ 1 * (SpinMxAllNum * SpinNum) 	+ s * SpinMxAllNum;
			Rhob 			= *p_d_Rho;
			T1b             = *p_d_T1;
			T2b 		    = *p_d_T2;
			Mzb             = *p_d_Mzb;
			Mzbbuffer		= Mzb;
			
			/* exchange term */
			p_d_K12			= d_K 			+ k * SpinMxNum	+ tid 	+ 1 * SpinMxAllNum;
			p_d_K21			= d_K 			+ k * SpinMxNum	+ tid 	+ 2 * SpinMxAllNum;
			K12 			= *p_d_K12;
			K21 			= *p_d_K21;
			
			/* field term */
			p_d_Gzgrid    	= d_Gzgrid 		+ k * SpinMxNum	+ tid ;
			p_d_Gygrid    	= d_Gygrid 		+ k * SpinMxNum	+ tid ;
			p_d_Gxgrid    	= d_Gxgrid 		+ k * SpinMxNum	+ tid ;
			p_d_dB0       	= d_dB0 		+ k * SpinMxNum	+ tid ;
			p_d_TxCoilmg	= d_TxCoilmg	+ k * SpinMxNum	+ tid ;
			p_d_TxCoilpe	= d_TxCoilpe 	+ k * SpinMxNum	+ tid ;
			p_d_RxCoilx		= d_RxCoilx		+ k * SpinMxNum	+ tid ;
			p_d_RxCoily		= d_RxCoily 	+ k * SpinMxNum	+ tid ;
		    Gzgrid			= *p_d_Gzgrid;
			Gygrid			= *p_d_Gygrid;
			Gxgrid			= *p_d_Gxgrid;
			dB0				= *p_d_dB0;
			
			Signalptr = 0;
			dt		  = 0;
			for (int q=0; q< SeqLen; q++){

				if (RunMode == 1){
					/* free pool */
					p_d_b_Mz  = d_b_Mz 	+ (utsi - SeqLen + q) * SpinMxAllNum * SpinNum * 2	+ k * SpinMxNum	+ tid  + 0 * (SpinMxAllNum * SpinNum)  + s * SpinMxAllNum;
					p_d_b_My  = d_b_My 	+ (utsi - SeqLen + q) * SpinMxAllNum * SpinNum * 2	+ k * SpinMxNum	+ tid  + 0 * (SpinMxAllNum * SpinNum)  + s * SpinMxAllNum;
					p_d_b_Mx  = d_b_Mx 	+ (utsi - SeqLen + q) * SpinMxAllNum * SpinNum * 2	+ k * SpinMxNum	+ tid  + 0 * (SpinMxAllNum * SpinNum)  + s * SpinMxAllNum;
					*p_d_b_Mz = Mz;
					*p_d_b_My = My;
					*p_d_b_Mx = Mx;
					/* bound pool */
					p_d_b_Mz  = d_b_Mz 	+ (utsi - SeqLen + q) * SpinMxAllNum * SpinNum * 2	+ k * SpinMxNum	+ tid  + 1 * (SpinMxAllNum * SpinNum)  + s * SpinMxAllNum;
					*p_d_b_Mz = Mzb;
				}

				p_d_dt		= g_d_Sig + q * (5 + 3 * TxCoilNum);
				
				if (*p_d_dt<= 0) continue;

				p_d_rfAmp 	= g_d_Sig + q * (5 + 3 * TxCoilNum) + 1;
				p_d_rfPhase = g_d_Sig + q * (5 + 3 * TxCoilNum) + 2;
				p_d_rfFreq 	= g_d_Sig + q * (5 + 3 * TxCoilNum) + 3;
				p_d_GzAmp 	= g_d_Sig + q * (5 + 3 * TxCoilNum) + 3 * TxCoilNum + 1;
				p_d_GyAmp 	= g_d_Sig + q * (5 + 3 * TxCoilNum) + 3 * TxCoilNum + 2;
				p_d_GxAmp 	= g_d_Sig + q * (5 + 3 * TxCoilNum) + 3 * TxCoilNum + 3;
				p_d_ADC 	= g_d_Sig + q * (5 + 3 * TxCoilNum) + 3 * TxCoilNum + 4;
				
				/* signal acquisition */
				if (*p_d_ADC == 1) {
					for (int c = 0; c < RxCoilNum; c++){  /* signal acquisition per Rx coil */    
						/* RxCoil sensitivity */
						if (RxCoilDefault ==0){
							buffer1 =  Mx * (* (p_d_RxCoilx + c * SpinMxAllNum))
									  +My * (* (p_d_RxCoily + c * SpinMxAllNum));
							buffer2 = -Mx * (* (p_d_RxCoily + c * SpinMxAllNum))
									  +My * (* (p_d_RxCoilx + c * SpinMxAllNum));
							buffer3 = buffer1;
							buffer4 = buffer2;
						}else{
							buffer1 = Mx;
							buffer2 = My;
							buffer3 = buffer1;
							buffer4 = buffer2;
						}
						
						/* rfRef for demodulating rf Phase */
						if (rfRef!=0){
							buffer1 = cos(-rfRef) * buffer1;
							buffer2 = -sin(-rfRef) * buffer2;
							buffer3 = sin(-rfRef) * buffer3;
							buffer4 = cos(-rfRef) * buffer4;
							buffer1 = buffer1 + buffer2;
							buffer3 = buffer3 + buffer4;
						}else{
							buffer3 = buffer4;
						}
						
						/* signal buffer pointer */
						p_d_Sx = d_Sx + tid + 0 * (SpinMxNum * SignalLen * RxCoilNum) + c * (SpinMxNum * SignalLen) + Signalptr * SpinMxNum;
						p_d_Sy = d_Sy + tid + 0 * (SpinMxNum * SignalLen * RxCoilNum) + c * (SpinMxNum * SignalLen) + Signalptr * SpinMxNum;
						
						/* update signal buffer */
						*p_d_Sx += buffer1;
						*p_d_Sy += buffer3;
					}
					Signalptr++;
				}
				
				/* free pool spin precession */
				dW =    dB0 * Gyro + dWRnd + 2 * PI * (float)d_CS[0]
						+ Gzgrid * (*p_d_GzAmp) * Gyro
						+ Gygrid * (*p_d_GyAmp) * Gyro
						+ Gxgrid * (*p_d_GxAmp) * Gyro;
				
				rfAmpSum = 0;
				for (int c = 0; c<TxCoilNum; c++){
					rfAmpSum+=fabs(p_d_rfAmp[c*3]);
				}

				if (rfAmpSum != 0){
					if (TxCoilNum == 1) { /* single-Tx */
						rfAmp   = p_d_rfAmp[0];
						rfPhase = p_d_rfPhase[0];
						rfFreq  = p_d_rfFreq[0]; /* note rfFreq is defined as fB0-frf */

						dW		+= 2 * PI * rfFreq;
						buffer1	 = *p_d_TxCoilmg * rfAmp;
						buffer2	 = *p_d_TxCoilpe + rfPhase;

						Alpha	 = sqrt(pow(dW,2) + pow(buffer1,2) * pow(Gyro,2)) * (*p_d_dt);  /* calculate alpha */
						Beta	 = atan(dW/(buffer1 * Gyro));  /* calculate beta */
						sinAlpha = sin(Alpha);
						sinBeta	 = sin(Beta);
						cosAlpha = cos(Alpha);
						cosBeta  = cos(Beta);
						cosPhi   = cos(-buffer2);
						sinPhi   = sin(-buffer2);
					}
					else{
						buffer3 = 0;
						buffer4 = 0;
						for (int c = 0; c<TxCoilNum; c++){ /* multi-Tx,  sum all (B1+ * rf) */
							rfAmp   = p_d_rfAmp[c*3];
							rfPhase = p_d_rfPhase[c*3];
							rfFreq  = p_d_rfFreq[c*3]; /* note rfFreq is defined as fB0-frf */
							if (rfAmp !=0 ){
								dW      += 2 * PI * rfFreq;
								buffer1  = *(p_d_TxCoilmg + c * SpinMxAllNum) * rfAmp;
								buffer2  = *(p_d_TxCoilpe + c * SpinMxAllNum) + rfPhase;
								buffer3 += buffer1 * cos(buffer2);
								buffer4 += buffer1 * sin(buffer2);
							}
						}
						buffer1 = sqrt(pow(buffer3, 2) + pow(buffer4,2));
						buffer2 = atan2(buffer4, buffer3);

						Alpha	  = sqrt(pow(dW,2) + pow(buffer1,2) * pow(Gyro,2)) * (*p_d_dt);  /* calculate alpha */
						Beta      = atan(dW/(buffer1 * Gyro));  /* calculate beta */
						sinAlpha  = sin(Alpha);
						sinBeta   = sin(Beta);
						cosAlpha  = cos(Alpha);
						cosBeta   = cos(Beta);
						cosPhi    = cos(-buffer2);
						sinPhi    = sin(-buffer2);
					}

					buffer1 = pow(cosBeta,2)*cosPhi - sinBeta*(sinAlpha*sinPhi - cosAlpha*cosPhi*sinBeta);
					buffer2 = sinPhi*pow(cosBeta,2) + sinBeta*(cosPhi*sinAlpha + cosAlpha*sinBeta*sinPhi);
					
					bufferMx = Mx * (cosPhi*buffer1 + sinPhi*(cosAlpha*sinPhi + cosPhi*sinAlpha*sinBeta))
							  -My * (sinPhi*buffer1 - cosPhi*(cosAlpha*sinPhi + cosPhi*sinAlpha*sinBeta))
							  +Mz * (cosBeta*(sinAlpha*sinPhi - cosAlpha*cosPhi*sinBeta) + cosBeta*cosPhi*sinBeta);  /*Calculate Mx */
					
					bufferMy = My * (sinPhi*buffer2 + cosPhi*(cosAlpha*cosPhi - sinAlpha*sinBeta*sinPhi))
							  -Mx * (cosPhi*buffer2 - sinPhi*(cosAlpha*cosPhi - sinAlpha*sinBeta*sinPhi))
							  +Mz * (cosBeta*(cosPhi*sinAlpha + cosAlpha*sinBeta*sinPhi) - cosBeta*sinBeta*sinPhi);  /*Calculate My */
					
					bufferMz = Mx * (cosPhi*(cosBeta*sinBeta - cosAlpha*cosBeta*sinBeta) - cosBeta*sinAlpha*sinPhi)
							  -My * (sinPhi*(cosBeta*sinBeta - cosAlpha*cosBeta*sinBeta) + cosBeta*cosPhi*sinAlpha)
							  +Mz * (cosAlpha*pow(cosBeta,2) + pow(sinBeta,2));     /*Calculate Mz */
				}
				else{

					Alpha	 = dW * (*p_d_dt);  /* calculate alpha */
					sinAlpha = sin(Alpha);
					cosAlpha = cos(Alpha);

					bufferMx = Mx * cosAlpha + My * sinAlpha;     /* calculate Mx */
					bufferMy = My * cosAlpha - Mx * sinAlpha;     /* calculate My */
					bufferMz = Mz ;								  /* calculate Mz */
				}
				
				 /* relax & exchange*/
				if (dt != *p_d_dt){ /* exp & division is very time consuming */
					ExpdtT2 = exp(-*p_d_dt/T2);
					ExpdtT1 = exp(-*p_d_dt/T1 - *p_d_dt*K12);
					M0dtT1  = (Rho*(1-exp(-*p_d_dt/T1)))/SpinNum;
					ExpdtK  = 1-exp(-*p_d_dt*K21);
				}
				Mx = bufferMx * ExpdtT2;
				My = bufferMy * ExpdtT2;
				Mz = bufferMz * ExpdtT1 + M0dtT1 + Mzbbuffer * ExpdtK; 
				
				/* bound pool spin evolution */
                if (rfAmpSum != 0){
                    if (TxCoilNum == 1) { /* single-Tx */
                        rfAmp   = fabs(p_d_rfAmp[0]);
                        rfFreq  = p_d_rfFreq[0]; /* note rfFreq is defined as fB0-frf*/
                        buffer1 = *p_d_TxCoilmg * rfAmp;
                        
                        /* bound pool saturation */
                        /* deal with on-resonance singularity
                        if (rfFreq == 0){ 
                            rfFreq = 1;
                        }
                        */
                        if (rffreq != rfFreq || t2b != T2b){ /* this is very time consuming */
							rffreq = rfFreq;
							t2b = T2b;
							u=0;
							G=0;
							for (int t=0; t < 1000; t++){
								buffer2 = ((2*PI*rfFreq+dB0*Gyro)*T2b)/(3*pow(u,2)-1);
								G+=(sqrt(2/PI)*(T2b/fabs(3*pow(u,2)-1))*exp(-2*pow(buffer2,2)))*0.001;
								u+=0.001;
							}
						}
                        W = PI * pow(buffer1 * Gyro, 2) * G;
                    }
                    else{
                        n=0;
                        W=0;
                        for (int c=0; c<TxCoilNum; c++){ /* multi-Tx,  sum all (B1+ * rf) */
                            rfAmp   = p_d_rfAmp[c*3];
                            rfFreq  = p_d_rfFreq[c*3]; /* note rfFreq is defined as fB0-frf*/
                            if (rfAmp !=0 ){
                                rfAmp=fabs(rfAmp);
                                buffer1= *(p_d_TxCoilmg + c * SpinMxAllNum) * rfAmp;
                                
                                /* bound pool saturation */
                                /* deal with on-resonance singularity
                                if (rfFreq == 0){ 
                                    rfFreq = 1;
                                }
                                */
                                if (rffreq != rfFreq || t2b != T2b){ /* this is very time consuming */
									rffreq = rfFreq;
									t2b = T2b;
									u=0;
									G=0;
									for (int t=0; t < 1000; t++){
										buffer2 = ((2*PI*rfFreq+dB0*Gyro)*T2b)/(3*pow(u,2)-1);
										G+=(sqrt(2/PI)*(T2b/fabs(3*pow(u,2)-1))*exp(-2*pow(buffer2,2)))*0.001;
										u+=0.001;
									}
								}
                                W += PI * pow(buffer1 * Gyro, 2) * G;
                                n++;
                            }
                        }
                        W = W / n;
                    }
                    bufferMz = Mzb * exp(-W*(*p_d_dt));     /*calculate Mz */
                }
                else{
                    bufferMz = Mzb;                  /* calculate Mz */
                }
                
                /* relax & exchange*/
				if (dt != *p_d_dt){ /* exp & division is very time consuming */
					dt	   = *p_d_dt;
					ExpdtT1b = exp(-dt/T1b - dt*K21);
					M0dtT1b	 = (Rhob*(1-exp(-dt/T1b)))/SpinNum;
					ExpdtKb	 = 1-exp(-dt*K12);
				}
                Mzb = bufferMz * ExpdtT1b + M0dtT1b + Mzbuffer * ExpdtKb;
						 
			    /* update Mz buffer */
				Mzbuffer = Mz;
				Mzbbuffer = Mzb;
			}
			
			*p_d_Mx  = Mx;
			*p_d_My  = My;
			*p_d_Mz  = Mz;
			*p_d_Mzb = Mzb;
		}
	}
}

#endif