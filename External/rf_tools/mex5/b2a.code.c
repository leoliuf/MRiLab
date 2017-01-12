/*
 *  b2a (b, n, a)
 *  
 *  C program version of b2a.
 *
 *  Gets complex minimum phase a from complex polynomial b.
 *
 *
 *  Written by Adam Kerr, October 1992
 *  Modified from John Pauly's code.
 *  (c) Board of Trustees, Leland Stanford Junior University
 */

#include <math.h>

#define ZEROPAD (16)
#define MAXN (1024 * ZEROPAD)
#define MP (0.0000001)

#define max(a,b) ((a)>(b) ? (a) : (b))
#define min(a,b) ((a)<(b) ? (a) : (b))
#define magsqr(a,j) (a[2*j]*a[2*j] + a[2*j+1]*a[2*j+1])
void four1(double bf[], int nnc, int fwd);
double bf[MAXN*2], am[MAXN*2], af[MAXN*2];

void b2a(double *b, int n, double *a)
{
  double bmx, bm, p;
  int i, j, nn, nnc;
  char s[80];

  /* next bigger power of 2 */
  for (nn=1; nn<=n; nn*=2);
  nn *=2;
  /*nn = (int) (exp(log(2)*ceil(log((double)n)/log(2))))+1;*/

  /* size of arrays used for computation */
  nnc = nn*ZEROPAD;

  for (i=0; i<n; i++) {bf[i*2] = b[i*2]; bf[i*2+1] = b[i*2+1];}
  for (i=n; i<nnc; i++) {bf[i*2] = 0; bf[i*2+1] = 0.0;}
  four1(bf-1, nnc, 1);

  /* check to see (| Fourier (beta(x)) |) < 1 */

  for (i=0, bmx=0; i<nnc; i++)
  {
     bm = magsqr(bf,i);
     if (bm > bmx) 
	bmx = bm;
  }
  if (bmx >= 1.0)
     for (i=0; i<nnc; i++) 
     {
	bf[i*2] /= (sqrt(bmx)+MP);
	bf[i*2+1] /= (sqrt(bmx)+MP);
     }

  /* compute |alpha(x)| */
  for (i=0; i<nnc; i++) {
    am[i*2] = sqrt(1.0 - magsqr(bf,i));
  }

  /* compute the phase of alpha, mag and phase are HT pair */
  /* ABK - God, it took me forever to figure out what John did here...
     he wants the hilbert transform of the log magnitude, so what
     he does is to generate the analytic version of the signal knowing
     that the imaginary part will be the negative of the hilbert transform
     of the log magnitude....  this is why I took 261...
     */
  for (i=0; i<nnc; i++) {
    af[i*2] = log(am[i*2]); 
    af[i*2+1] = 0;
  }
  four1(af-1,nnc,1);
  for (i=1; i<(nnc/2)-1; i++) {	/* leave DC and halfway point untouched!! */
    af[i*2] *= 2.0;
    af[i*2+1] *= 2.0;
  }
  for (i=(nnc/2)+1; i<nnc; i++) {
    af[i*2] = 0.0;
    af[i*2+1] = 0.0;
  }
  four1(af-1,nnc,-1);
  for (i=0; i<nnc; i++) {
    af[i*2] /= nnc;
    af[i*2+1] /= nnc;
  }

  /* compute the minimum phase alpha */
  for (i=0; i<nnc; i++) {
    p = af[i*2+1];
    af[i*2] = am[i*2] * cos(-p);
    af[i*2+1] = am[i*2] * sin(-p);
  }

  /* compute the minimum phase alpha coefficients */
  four1(af-1, nnc, -1);
  for (i=0; i<n; i++)
  {
    j = n-i-1;
    a[j*2] = af[i*2]/nnc;
    a[j*2+1] = af[i*2+1]/nnc;
  }
}



