

/**************************************************************************
 * MEX C code for doing gridding for non-Cartesian MRI recon
 * Written by Fang Liu (leoliuf@gmail.com) 6/10/13.
 *
 * Input Arguments
 * [Kx,Ky,Sx,Sy,DCF,Ker,GridSize,VCtl.KernelWidth/2]
 *
 * Output Arguments
 * [Sx2, Sy2]
 *************************************************************************/

#include "mex.h"
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])

{
    double *Kx;         /* Kx locations.	*/
    double *Ky;         /* Ky locations.	*/
    double *Sx;         /* real-part of data samples.	*/
    double *Sy;         /* imaginary-part of data samples. */
    double *DCF;        /* density compensation factor at each k space point*/
    double *Sx2;        /* real-part of gridded data sample. */
    double *Sy2;        /* imaginary-part of gridded data sample. */
    double *Sx2p;       /* loop through pointer for Sx2 */
    double *Sy2p;       /* loop through pointer for Sy2 */
    double *Kernel;     /* lookup-table for linearly-interpolated kernel.  */
    double KernelWidth;	/* normalized half width of convolution kernel for gridding. */
    double GridSize;	/* size of grid, in samples */
    double GridCenter;  /* center of grid, in samples */
    int NSample;		/* number of trajectory points */
    int NKernelPts;		/* number of points in kernel lookup table. */
    
    double kxmin;
    double kxmax;
    double kymin;
    double kymax;
    int    ixmin;
    int    ixmax;
    int    iymin;
    int    iymax;
    
    double dKx;
    double dKy;
    double dK;
    double FracInd;    /* Kernel fractional index */
    int    KernelInd;  /* Kernel index */
    double FracdK;     /* Kernel seperation fraction */
    double Kern;       /* Kernel value */
    
    
    Kx                  = mxGetPr(prhs[0]);
    Ky                  = mxGetPr(prhs[1]);
    Sx                  = mxGetPr(prhs[2]);
    Sy                  = mxGetPr(prhs[3]);
    DCF                 = mxGetPr(prhs[4]);
    Kernel              = mxGetPr(prhs[5]);
    GridSize            = *mxGetPr(prhs[6]);
    KernelWidth         = *mxGetPr(prhs[7])/(GridSize-1);
    NSample             = mxGetM(prhs[0]) * mxGetN(prhs[0]);
    NKernelPts          = mxGetM(prhs[5]) * mxGetN(prhs[5]);
    GridCenter          = (GridSize-1)/2;
    
    plhs[0]             = mxCreateDoubleMatrix(GridSize,GridSize,mxREAL);
    plhs[1]             = mxCreateDoubleMatrix(GridSize,GridSize,mxREAL);
    Sx2                 = mxGetPr(plhs[0]);
    Sy2                 = mxGetPr(plhs[1]);
    
    
    /* loop through K space */
    for (int i = 0; i < NSample; i++)
    {
        
        /* find sample point affect K space region */
        kxmin = *Kx-KernelWidth;
        kxmax = *Kx+KernelWidth;
        kymin = *Ky-KernelWidth;
        kymax = *Ky+KernelWidth;
        
        if (kxmin < -0.5) kxmin=-0.5;
        if (kxmax > 0.5) kxmax=0.5;
        if (kymin < -0.5) kymin=-0.5;
        if (kymax > 0.5) kymax=0.5;
        
        ixmin = int ((kxmin + 0.5 ) * (GridSize-1));
        ixmax = int ((kxmax + 0.5 ) * (GridSize-1));
        iymin = int ((kymin + 0.5 ) * (GridSize-1));
        iymax = int ((kymax + 0.5 ) * (GridSize-1));
        
        for (int ix = ixmin; ix <= ixmax; ix++)
        {
            dKx = ((double)ix-GridCenter) / (GridSize-1) - *Kx;
            for (int iy = iymin; iy <= iymax; iy++)
            {
                dKy = ((double)iy-GridCenter) / (GridSize-1) - *Ky;
                
                dK = sqrt(dKx*dKx+dKy*dKy);	/* K space seperation*/
                if (dK <= KernelWidth)	/* sample point affect K space region */
                {
                    Sx2p = Sx2 + ix * (int)GridSize + iy;
                    Sy2p = Sy2 + ix * (int)GridSize + iy;
                    
                    /* find index in kernel lookup table */
                    FracInd     = (dK/KernelWidth)*(double)(NKernelPts-1);
                    KernelInd   = (int)FracInd;
                    FracdK      = FracInd-(double)KernelInd;
                    
                    /* linearly interpolate in kernel lookup table */
                    Kern = Kernel[KernelInd]*(1-FracdK)+ Kernel[KernelInd+1]*FracdK;
                    
                    *Sx2p += Kern * (*Sx) * (*DCF);
                    *Sy2p += Kern * (*Sy) * (*DCF);
                }
            }
        }
        Kx++;
        Ky++;
        DCF++;
        Sx++;
        Sy++;
    }
}
