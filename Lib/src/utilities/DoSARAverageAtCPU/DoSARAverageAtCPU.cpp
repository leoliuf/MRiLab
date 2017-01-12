

/**************************************************************************
 * MEX C code for doing 3D local SAR averaging
 * Written by Fang Liu (leoliuf@gmail.com) 4/21/14.
 * Adapted from SARavesphnp.m from Giuseppe Carluccio, PhD
 *
 * Input Arguments
 * [SAR, Power, MassDen, dx, dy, dz, grams]
 *
 * Output Arguments
 * [aveSAR, avePower]
 *************************************************************************/

#include "mex.h"
#include <math.h>
#include <vector>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    double *SAR,*Power,*MassDen;
    double *aveSAR, *avePower;
    
    double dx, dy, dz, grams;
    mwSize MxSliceNum, MxTimeNum, MxDimNum;
    const mwSize *MxDims;
    
    int shift, radius, rado, radm, totpx, totpx2;
    double totwei,totwei2;
    double coefw, totpxs, totSARs, totPowers;
    
    int ExtCall;
    
    SAR                 = mxGetPr(prhs[0]); /* unaveraged local SAR */
    Power               = mxGetPr(prhs[1]); /* unaveraged local Power */
    MassDen             = mxGetPr(prhs[2]); /* Mass Density */
    dx                  = *mxGetPr(prhs[3]); /* resolution in x */
    dy                  = *mxGetPr(prhs[4]); /* resolution in y */
    dz                  = *mxGetPr(prhs[5]); /* resolution in z */
    grams               = *mxGetPr(prhs[6]); /* N-gram */
    
    /* get dimensions of the matrix */
    MxDimNum            = mxGetNumberOfDimensions(prhs[0]);
    MxDims              = (mwSize*) mxCalloc(MxDimNum, sizeof(mwSize));
    MxDims              = mxGetDimensions(prhs[0]);
    if (MxDimNum < 3){
        MxSliceNum = 1;
    }else{
        MxSliceNum = MxDims[2];
    }
    
    if (MxDimNum < 4){
        MxTimeNum = 1;
    }else{
        MxTimeNum = MxDims[3];
    }
    
    std::vector<double> totSAR(MxTimeNum,0);
    std::vector<double> totSAR2(MxTimeNum,0);
    std::vector<double> totPower(MxTimeNum,0);
    std::vector<double> totPower2(MxTimeNum,0);
    
    plhs[0]             = mxCreateNumericArray(MxDimNum, MxDims, mxDOUBLE_CLASS, mxREAL);
    plhs[1]             = mxCreateNumericArray(MxDimNum, MxDims, mxDOUBLE_CLASS, mxREAL);
    aveSAR              = mxGetPr(plhs[0]); /* N-gram local SAR */
    avePower            = mxGetPr(plhs[1]); /* N-gram local Power */
    
    /* loop through each voxel */
    shift = MxDims[0]* MxDims[1]* MxSliceNum;
    for (int s = 0; s < MxSliceNum; s++){
        for (int i=0; i < MxDims[1]; i++){
            for (int j=0; j < MxDims[0]; j++){
                if (MassDen[j+i*MxDims[0]+s*MxDims[0]*MxDims[1]]==0) continue;
                totwei=0;
                std::fill(totSAR.begin(), totSAR.end(), 0);
                std::fill(totPower.begin(), totPower.end(), 0);
                totpx=0;
                radius=0;
                
                while (totwei<=grams*1e-3){
                    totwei2=totwei;
                    totSAR2=totSAR;
                    totPower2=totPower;
                    totpx2=totpx;
                    totwei=0;
                    std::fill(totSAR.begin(), totSAR.end(), 0);
                    std::fill(totPower.begin(), totPower.end(), 0);
                    totpx=0;
                    radius++;
                    
                    for (int o=-radius; o<=radius; o++){
                        rado=(int)floor(sqrt((double)(radius*radius-o*o)));
                        for (int m=-rado; m<=rado; m++){
                            radm=(int)floor(sqrt((double)(rado*rado-m*m)));
                            for (int n=-radm; n<=radm; n++){
                                if (i+m >= 0 && i+m < MxDims[1] && j+n >=0 && j+n <MxDims[0] && s+o >= 0 && s+o < MxSliceNum){
                                    totwei=totwei+dx*dy*dz*MassDen[j+n+(i+m)*MxDims[0]+(s+o)*MxDims[0]*MxDims[1]];
                                    if (SAR[j+i*MxDims[0]+s*MxDims[0]*MxDims[1]]>0){
                                        totpx++;
                                        for (int t=0; t<MxTimeNum; t++){
                                            totSAR[t]=totSAR[t]+SAR[t*shift+j+n+(i+m)*MxDims[0]+(s+o)*MxDims[0]*MxDims[1]];
                                            totPower[t]=totPower[t]+Power[t*shift+j+n+(i+m)*MxDims[0]+(s+o)*MxDims[0]*MxDims[1]];
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                coefw = (grams*1e-3 - totwei2)/(totwei-totwei2);
                totpxs = coefw*(totpx-totpx2);
                
                for (int t=0; t<MxTimeNum; t++){
                    totSARs = coefw*(totSAR[t]-totSAR2[t]);
                    totPowers = coefw*(totPower[t]-totPower2[t]);
                    if (totpx>0){
                        totSAR[t]=(totSAR2[t]+totSARs)/(totpx2+totpxs);
                        totPower[t]=(totPower2[t]+totPowers)/(totpx2+totpxs);
                        
                        aveSAR[t*shift+j+i*MxDims[0]+s*MxDims[0]*MxDims[1]]=totSAR[t];
                        avePower[t*shift+j+i*MxDims[0]+s*MxDims[0]*MxDims[1]]=totPower[t];
                    }
                }
            }
        }
        mexPrintf("Calculating %f-gram local SAR %.2f %% Completed\n",grams ,100*((float)s+1)/(float)MxSliceNum);
        ExtCall = mexEvalString("pause(0.001);");
        if (ExtCall){
            mexErrMsgTxt("Local SAR average process encounters ERROR!");
            return;
        }
    }
}
