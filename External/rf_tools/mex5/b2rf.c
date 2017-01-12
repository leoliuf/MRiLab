/*
 *  [rf] = b2rf (b)
 *  
 *  C program version of b2rf.
 *
 *  Mex driver for subroutine.
 *  Gets complex rf from complex polynomial b.  
 *
 *  Written by Adam Kerr, October 1992
 *  Modified from John Pauly's code.
 *  (c) Board of Trustees, Leland Stanford Junior University
 */

#include <math.h>
#include <stdio.h>
#include "mex.h"

#define MAXN (1024)

#define max(a,b) ((a)>(b) ? (a) : (b))

/* driver for matlab call  */

#define B prhs[0]		/* alpha polynomial */
#define RF plhs[0]		/* RF pulse */
void b2a(double *b, int n, double *a);
void cabc2rf(double *a, double *b, int n, double *rf);
double a[MAXN*2], b[MAXN*2];
double rf[MAXN*2];

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

   double *bpr, *bpi, *rfr, *rfi;
   int n;
   int i, j;

   if ((nrhs != 1) || (nlhs != 1))
      mexErrMsgTxt("Usage: [rf] = b2rf (b)");

   n = max (mxGetN(B), mxGetM(B));
   if (n > MAXN) 
      mexErrMsgTxt("beta polynomial too long");

   /* copy b into array */
   bpr = mxGetPr(B);
   bpi = mxGetPi(B);
   if (bpi != NULL)
      for (i=0; i<n; i++) {
	     b[i*2]   = bpr[i];
	     b[i*2+1] = bpi[i];
      } else 
         for (i=0; i<n; i++) {
    	   b[i*2]   = bpr[i];
	   b[i*2+1] = 0.0;
         }

   /* get alpha polynomial */
   b2a (b, n, a);

   /* get rf from ab now */
   cabc2rf (a, b, n, rf);

   /* copy rf back into matlab matrix */
   RF = mxCreateDoubleMatrix (1, n, mxCOMPLEX);
   rfr = mxGetPr(RF); rfi = mxGetPi(RF);
   for (i=0; i<n; i++) {
      rfr[i] = rf[i*2];
      rfi[i] = rf[i*2+1];
   }
}

#undef MAXN
#include "b2a.code.c"
#undef MAXN
#include "cabc2rf.code.c"
#include "four1.c"


