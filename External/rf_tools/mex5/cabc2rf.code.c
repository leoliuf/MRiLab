/*
 *  cabc2rf (a, b, n, rf)
 *  
 *  C program version of cabc2rf.
 *
 *  Performs inverse SLR tranform on complex a,b to give complex rf pulse
 *
 *
 *  Written by Adam Kerr, October 1992
 *  Modified from John Pauly's code.
 *  (c) Board of Trustees, Leland Stanford Junior University
 */

#include <math.h>

#define MAXN (1024)

#define max(a,b) ((a)>(b) ? (a) : (b))
#define min(a,b) ((a)<(b) ? (a) : (b))
#define mag(a,j) (sqrt (a[(j)*2]*a[(j)*2]+a[(j)*2+1]*a[(j)*2+1]))
#define re_div(a,i,b,j) ((a[i*2]*b[j*2] + a[i*2+1]*b[j*2+1])/(b[j*2]*b[j*2] + b[j*2+1]*b[j*2+1]))
#define im_div(a,i,b,j) ((a[i*2+1]*b[j*2] - a[i*2]*b[j*2+1])/(b[j*2]*b[j*2] + b[j*2+1]*b[j*2+1]))
double a2[MAXN*2], b2[MAXN*2];


void cabc2rf(double a[], double b[], int n, double rf[])
{
   int i, j;
   double sj[2], cj;
   double phi, theta;		/* use definitions from SLR paper, somewhat
				 different from those in John's abc2rf() */

   for (j=n-1; j>=0; j--)
   {
      /* get real cj and complex sj now */
      cj = sqrt (1 / (1 + (b[j*2]*b[j*2] + b[j*2+1]*b[j*2+1])/
		            (a[j*2]*a[j*2] + a[j*2+1]*a[j*2+1]) ));
      sj[0] = re_div (b,j,a,j) * cj;
      sj[1] = -im_div (b,j,a,j) * cj;

      /* get phi and theta now */
      phi = 2 * atan2 (mag(sj,0), cj);
      theta = atan2 (sj[1],sj[0]);

      /* get rf now from phi and theta */
      rf[j*2] = phi * cos (theta);
      rf[j*2+1] = phi * sin (theta);

      /* create new polynomials now */
      for (i=0; i<=j; i++)
      {
	 a2[i*2] = cj * a[i*2] + sj[0] * b[i*2] - sj[1] * b[i*2+1];
	 a2[i*2+1] = cj * a[i*2+1] + sj[0] * b[i*2+1] + sj[1] * b[i*2];
	 b2[i*2] = -sj[0] * a[i*2] - sj[1] * a[i*2+1] + cj * b[i*2];
	 b2[i*2+1] = -sj[0] * a[i*2+1] + sj[1] * a[i*2] + cj * b[i*2+1];
      }
      
      /* copy back into old polynomials now */
      /* try other way 
      for (i=0; i<=j-1; i++)
      {
	 a[i*2] = a2[i*2+2];
	 a[i*2+1] = a2[i*2+3];
	 b[i*2] = b2[i*2];
	 b[i*2+1] = b2[i*2+1];
      } */
      for (i=0; i<=2*j-1; i++)
      {
	 a[i] = a2[i+2];
	 b[i] = b2[i];
      }
   }
}

