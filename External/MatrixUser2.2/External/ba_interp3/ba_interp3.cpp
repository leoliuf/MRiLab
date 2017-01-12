// Fast nearest, bi-linear and bi-cubic interpolation for 3d image data on a regular grid.
//
// Usage:
// ------
//     R = ba_interp3(F, X, Y, Z, [method])
//     R = ba_interp3(Fx, Fy, Fz, F, X, Y, Z, [method])
//
// where method is one off nearest, linear, or cubic.
//
// Fx, Fy, Fz 
//         are the coordinate system in which F is given. Only the first and
//         last entry in Fx, Fy, Fz are used, and it is assumed that the
//         inbetween values are linearly interpolated.
// F       is a WxHxDxC Image with an arbitray number of channels C.
// X, Y, Z are I_1 x ... x I_n matrices with the x and y coordinates to
//         interpolate.
// R       is a I_1 x ... x I_n x C matrix, which contains the interpolated image channels.
//
// Notes:
// ------
// This method handles the border by repeating the closest values to the point accessed. 
// This is different from matlabs border handling.
//
// Example
// ------
//
//    %% Interpolation of 3D volumes (e.g. distance transforms)
//    clear
//    sz=5;
//
//    % Dist 
//    dist1.D = randn(sz,sz,sz);
//    [dist1.x dist1.y dist.z] = meshgrid(linspace(-1,1,sz), linspace(-1,1,sz), linspace(-1,1,sz));
//    
//    R = [cos(pi/4) sin(pi/4); -sin(pi/4) cos(pi/4)];
//    RD = R * [Dx(:)'; Dy(:)'] + 250;
//    RDx = reshape(RD(1,:), size(Dx));
//    RDy = reshape(RD(2,:), size(Dy));
//    
//    methods = {'nearest', 'linear', 'cubic'};
//    la=nan(1,3);
//    for i=1:3
//      la(i) = subplot(2,2,i);
//      tic;
//      IMG_R = ba_interp2(IMG, RDx, RDy, methods{i});
//      elapsed=toc;
//      imshow(IMG_R);
//      title(sprintf('Rotation and zoom using %s interpolation took %gs', methods{i}, elapsed));
//    end
//    linkaxes(la);
//
// Licence:
// --------
// GPL
// (c) 2008 Brian Amberg
// http://www.brian-amberg.de/
  
#include <mex.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <iostream>

/*-----------Add function provided by Thomas Hamsphire 27 Jul 2012--------<Fang Liu 27 Sep 2013>*/
double round(double val) 
{ 
return floor(val + 0.5); 
}
/*------------------------------End---------------------------------------<Fang Liu 27 Sep 2013>*/

inline 
static
int access(int M, int N, int O, int x, int y, int z) {
  if (x<0) x=0; else if (x>=N) x=N-1;
  if (y<0) y=0; else if (y>=M) y=M-1;
  if (z<0) z=0; else if (z>=O) z=O-1;
  return y + M*(x + N*z);
}

inline 
static
int access_unchecked(int M, int N, int O, int x, int y, int z) {
  return y + M*(x + N*z);
}

inline
static
void indices_linear(
    int &f000_i,
    int &f100_i,
    int &f010_i,
    int &f110_i,
    int &f001_i,
    int &f101_i,
    int &f011_i,
    int &f111_i,
    const int x, const int y, const int z,
    const mwSize &M, const mwSize &N, const mwSize &O) {
  if (x<=1 || y<=1 || z<=1 || x>=N-2 || y>=M-2 || z>=O-2) {
    f000_i = access(M,N,O, x,   y  , z);
    f100_i = access(M,N,O, x+1, y  , z);

    f010_i = access(M,N,O, x,   y+1, z);
    f110_i = access(M,N,O, x+1, y+1, z);

    f001_i = access(M,N,O, x,   y  , z+1);
    f101_i = access(M,N,O, x+1, y  , z+1);

    f011_i = access(M,N,O, x,   y+1, z+1);
    f111_i = access(M,N,O, x+1, y+1, z+1);
  } else {
    f000_i = access_unchecked(M,N,O, x,   y  , z);
    f100_i = access_unchecked(M,N,O, x+1, y  , z);

    f010_i = access_unchecked(M,N,O, x,   y+1, z);
    f110_i = access_unchecked(M,N,O, x+1, y+1, z);

    f001_i = access_unchecked(M,N,O, x,   y  , z+1);
    f101_i = access_unchecked(M,N,O, x+1, y  , z+1);

    f011_i = access_unchecked(M,N,O, x,   y+1, z+1);
    f111_i = access_unchecked(M,N,O, x+1, y+1, z+1);
  }
}

inline
static
void indices_cubic(
    int f_i[64],
    const int x, const int y, const int z,
    const mwSize &M, const mwSize &N, const mwSize &O) {
  if (x<=2 || y<=2 || z<=2 || x>=N-3 || y>=M-3 || z>=O-3) {
    for (int i=0; i<4; ++i)
      for (int j=0; j<4; ++j)
        for (int k=0; k<4; ++k)
          f_i[i+4*(j+4*k)] = access(M,N,O, x+i-1, y+j-1, z+k-1);
  } else {
    for (int i=0; i<4; ++i)
      for (int j=0; j<4; ++j)
        for (int k=0; k<4; ++k)
          f_i[i+4*(j+4*k)] = access_unchecked(M,N,O, x+i-1, y+j-1, z+k-1);
  }
}


static
void interpolate_nearest(double *pO, const double *pF, 
  const double *pX, const double *pY, const double *pZ,
  const mwSize ND, const mwSize M, const mwSize N, const mwSize O, const mwSize P,
  const double s_x, const double o_x,
  const double s_y, const double o_y,
  const double s_z, const double o_z) {
  const mwSize LO = M*N*O;
  for (mwSize i=0; i<ND; ++i) {
    const double &x = pX[i];
    const double &y = pY[i];
    const double &z = pZ[i];

    const int x_round = int(round(s_x*x+o_x))-1;
    const int y_round = int(round(s_y*y+o_y))-1;
    const int z_round = int(round(s_z*z+o_z))-1;

    const int f00_i = access(M,N,O, x_round,y_round,z_round);
    for (mwSize j=0; j<P; ++j) {
      pO[i + j*ND] = pF[f00_i + j*LO];
    }
  }
}

template <mwSize P>
static
void interpolate_nearest_unrolled(double *pO, const double *pF, 
  const double *pX, const double *pY, const double *pZ,
  const mwSize ND, const mwSize M, const mwSize N, const mwSize O,
  const double s_x, const double o_x,
  const double s_y, const double o_y,
  const double s_z, const double o_z) {
  const mwSize LO = M*N*O;
  for (mwSize i=0; i<ND; ++i) {
    const double &x = pX[i];
    const double &y = pY[i];
    const double &z = pZ[i];

    const int x_round = int(round(s_x*x+o_x))-1;
    const int y_round = int(round(s_y*y+o_y))-1;
    const int z_round = int(round(s_z*z+o_z))-1;

    const int f00_i = access(M,N,O, x_round,y_round,z_round);
    for (mwSize j=0; j<P; ++j) {
      pO[i + j*ND] = pF[f00_i + j*LO];
    }
  }
}

static
void interpolate_linear(double *pO, const double *pF, 
  const double *pX, const double *pY, const double *pZ,
  const mwSize ND, const mwSize M, const mwSize N, const mwSize O, const mwSize P,
  const double s_x, const double o_x,
  const double s_y, const double o_y,
  const double s_z, const double o_z) {
  const mwSize LO = M*N*O;
  for (mwSize i=0; i<ND; ++i) {
    const double &x_ = pX[i];
    const double &y_ = pY[i];
    const double &z_ = pZ[i];
    
    const double x = s_x*x_+o_x;
    const double y = s_y*y_+o_y;
    const double z = s_z*z_+o_z;

    const double x_floor = floor(x);
    const double y_floor = floor(y);
    const double z_floor = floor(z);

    const double dx = x-x_floor;
    const double dy = y-y_floor;
    const double dz = z-z_floor;

    const double wx0 = 1.0-dx;
    const double wx1 = dx;

    const double wy0 = 1.0-dy;
    const double wy1 = dy;

    const double wz0 = 1.0-dz;
    const double wz1 = dz;

    int f000_i, f100_i, f010_i, f110_i;
    int f001_i, f101_i, f011_i, f111_i;

    // TODO: Use openmp
    indices_linear(
        f000_i, f100_i, f010_i, f110_i, 
        f001_i, f101_i, f011_i, f111_i, 
        int(x_floor-1), int(y_floor-1), int(z_floor-1), M, N, O);

    for (mwSize j=0; j<P; ++j) {

      pO[i + j*ND] =
        wz0*(
            wy0*(wx0 * pF[f000_i + j*LO] + wx1 * pF[f100_i + j*LO]) +
            wy1*(wx0 * pF[f010_i + j*LO] + wx1 * pF[f110_i + j*LO])
            )+
        wz1*(
            wy0*(wx0 * pF[f001_i + j*LO] + wx1 * pF[f101_i + j*LO]) +
            wy1*(wx0 * pF[f011_i + j*LO] + wx1 * pF[f111_i + j*LO])
            );
    }

  }
}

template <mwSize P>
static
void interpolate_linear_unrolled(double *pO, const double *pF, 
  const double *pX, const double *pY, const double *pZ,
  const mwSize ND, const mwSize M, const mwSize N, const mwSize O,
  const double s_x, const double o_x,
  const double s_y, const double o_y,
  const double s_z, const double o_z) {
  const mwSize LO = M*N*O;
  for (mwSize i=0; i<ND; ++i) {
    const double &x_ = pX[i];
    const double &y_ = pY[i];
    const double &z_ = pZ[i];
    
    const double x = s_x*x_+o_x;
    const double y = s_y*y_+o_y;
    const double z = s_z*z_+o_z;

    const double x_floor = floor(x);
    const double y_floor = floor(y);
    const double z_floor = floor(z);

    const double dx = x-x_floor;
    const double dy = y-y_floor;
    const double dz = z-z_floor;

    const double wx0 = 1.0-dx;
    const double wx1 = dx;

    const double wy0 = 1.0-dy;
    const double wy1 = dy;

    const double wz0 = 1.0-dz;
    const double wz1 = dz;

    int f000_i, f100_i, f010_i, f110_i;
    int f001_i, f101_i, f011_i, f111_i;

    // TODO: Use openmp

    indices_linear(
        f000_i, f100_i, f010_i, f110_i, 
        f001_i, f101_i, f011_i, f111_i, 
        int(x_floor-1), int(y_floor-1), int(z_floor-1), M, N, O);

    for (mwSize j=0; j<P; ++j) {

      pO[i + j*ND] =
        wz0*(
            wy0*(wx0 * pF[f000_i + j*LO] + wx1 * pF[f100_i + j*LO]) +
            wy1*(wx0 * pF[f010_i + j*LO] + wx1 * pF[f110_i + j*LO])
            )+
        wz1*(
            wy0*(wx0 * pF[f001_i + j*LO] + wx1 * pF[f101_i + j*LO]) +
            wy1*(wx0 * pF[f011_i + j*LO] + wx1 * pF[f111_i + j*LO])
            );
    }

  }
}

static
void interpolate_bicubic(double *pO, const double *pF, 
  const double *pX, const double *pY, const double *pZ, 
  const mwSize ND, const mwSize M, const mwSize N, const mwSize O, const mwSize P,
  const double s_x, const double o_x,
  const double s_y, const double o_y,
  const double s_z, const double o_z) {
  const mwSize LO = M*N*O;
  for (mwSize i=0; i<ND; ++i) {
    const double &x_ = pX[i];
    const double &y_ = pY[i];
    const double &z_ = pZ[i];
    
    const double x = s_x*x_+o_x;
    const double y = s_y*y_+o_y;
    const double z = s_z*z_+o_z;
    
    const double x_floor = floor(x);
    const double y_floor = floor(y);
    const double z_floor = floor(z);

    const double dx = x-x_floor;
    const double dy = y-y_floor;
    const double dz = z-z_floor;

    const double dxx = dx*dx;
    const double dxxx = dxx*dx;

    const double dyy = dy*dy;
    const double dyyy = dyy*dy;

    const double dzz = dz*dz;
    const double dzzz = dzz*dz;

    const double wx0 = 0.5 * (    - dx + 2.0*dxx -       dxxx);
    const double wx1 = 0.5 * (2.0      - 5.0*dxx + 3.0 * dxxx);
    const double wx2 = 0.5 * (      dx + 4.0*dxx - 3.0 * dxxx);
    const double wx3 = 0.5 * (         -     dxx +       dxxx);

    const double wy0 = 0.5 * (    - dy + 2.0*dyy -       dyyy);
    const double wy1 = 0.5 * (2.0      - 5.0*dyy + 3.0 * dyyy);
    const double wy2 = 0.5 * (      dy + 4.0*dyy - 3.0 * dyyy);
    const double wy3 = 0.5 * (         -     dyy +       dyyy);

    const double wz0 = 0.5 * (    - dz + 2.0*dzz -       dzzz);
    const double wz1 = 0.5 * (2.0      - 5.0*dzz + 3.0 * dzzz);
    const double wz2 = 0.5 * (      dz + 4.0*dzz - 3.0 * dzzz);
    const double wz3 = 0.5 * (         -     dzz +       dzzz);

    int f_i[64];

    indices_cubic(
        f_i,
        int(x_floor-1), int(y_floor-1), int(z_floor-1), M, N, O);

    for (mwSize j=0; j<P; ++j) {

      pO[i + j*ND] =
        wz0*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*0)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*0)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*0)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*0)] + j*LO])
            ) +
        wz1*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*1)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*1)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*1)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*1)] + j*LO])
            ) +
        wz2*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*2)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*2)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*2)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*2)] + j*LO])
            ) +
        wz3*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*3)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*3)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*3)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*3)] + j*LO])
            );
    }

  }
}

template <size_t P>
static
void interpolate_bicubic_unrolled(double *pO, const double *pF, 
  const double *pX, const double *pY, const double *pZ, 
  const mwSize ND, const mwSize M, const mwSize N, const mwSize O,
  const double s_x, const double o_x,
  const double s_y, const double o_y,
  const double s_z, const double o_z) {
  const mwSize LO = M*N*O;
  for (mwSize i=0; i<ND; ++i) {
    const double &x_ = pX[i];
    const double &y_ = pY[i];
    const double &z_ = pZ[i];
    
    const double x = s_x*x_+o_x;
    const double y = s_y*y_+o_y;
    const double z = s_z*z_+o_z;
    
    const double x_floor = floor(x);
    const double y_floor = floor(y);
    const double z_floor = floor(z);

    const double dx = x-x_floor;
    const double dy = y-y_floor;
    const double dz = z-z_floor;

    const double dxx = dx*dx;
    const double dxxx = dxx*dx;

    const double dyy = dy*dy;
    const double dyyy = dyy*dy;

    const double dzz = dz*dz;
    const double dzzz = dzz*dz;

    const double wx0 = 0.5 * (    - dx + 2.0*dxx -       dxxx);
    const double wx1 = 0.5 * (2.0      - 5.0*dxx + 3.0 * dxxx);
    const double wx2 = 0.5 * (      dx + 4.0*dxx - 3.0 * dxxx);
    const double wx3 = 0.5 * (         -     dxx +       dxxx);

    const double wy0 = 0.5 * (    - dy + 2.0*dyy -       dyyy);
    const double wy1 = 0.5 * (2.0      - 5.0*dyy + 3.0 * dyyy);
    const double wy2 = 0.5 * (      dy + 4.0*dyy - 3.0 * dyyy);
    const double wy3 = 0.5 * (         -     dyy +       dyyy);

    const double wz0 = 0.5 * (    - dz + 2.0*dzz -       dzzz);
    const double wz1 = 0.5 * (2.0      - 5.0*dzz + 3.0 * dzzz);
    const double wz2 = 0.5 * (      dz + 4.0*dzz - 3.0 * dzzz);
    const double wz3 = 0.5 * (         -     dzz +       dzzz);

    int f_i[64];

    indices_cubic(
        f_i,
        int(x_floor-1), int(y_floor-1), int(z_floor-1), M, N, O);

    for (mwSize j=0; j<P; ++j) {

      pO[i + j*ND] =
        wz0*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*0)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*0)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*0)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*0)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*0)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*0)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*0)] + j*LO])
            ) +
        wz1*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*1)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*1)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*1)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*1)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*1)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*1)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*1)] + j*LO])
            ) +
        wz2*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*2)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*2)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*2)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*2)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*2)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*2)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*2)] + j*LO])
            ) +
        wz3*(
            wy0*(wx0 * pF[f_i[0+4*(0+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(0+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(0+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(0+4*3)] + j*LO]) +
            wy1*(wx0 * pF[f_i[0+4*(1+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(1+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(1+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(1+4*3)] + j*LO]) +
            wy2*(wx0 * pF[f_i[0+4*(2+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(2+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(2+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(2+4*3)] + j*LO]) +
            wy3*(wx0 * pF[f_i[0+4*(3+4*3)] + j*LO] + wx1 * pF[f_i[1+4*(3+4*3)] + j*LO] +  wx2 * pF[f_i[2+4*(3+4*3)] + j*LO] + wx3 * pF[f_i[3+4*(3+4*3)] + j*LO])
            );
    }

  }
}

enum InterpolationMethod { Nearest, Linear, Cubic };

/*
static
InterpolationMethod parseInterpolationMethod(const mxArray *method_string) {
  if (method_string == NULL)
    return Cubic;

  char method[10] = "cubic    ";

  mxGetString(method_string, method, 9);

  if (std::string(method).substr(0, 7) == "nearest")
    return Nearest;
  else if (std::string(method).substr(0, 6) == "linear")
    return Linear;
  else if (std::string(method).substr(0, 5) == "cubic")
    return Cubic;
  else
    mexErrMsgTxt("Specify one of nearest, linear, cubic as the interpolation method argument.");

  return(Cubic);
}
*/ 
/*--replace above with function provided by Thomas Hampshire 27 Jul 2012--<Fang Liu 27 Sep 2013>*/

static 
InterpolationMethod parseInterpolationMethod(const mxArray *method_string) { 
if (method_string == NULL) 
return Cubic;

char method[10] = "cubic ";

mxGetString(method_string, method, 9);

if (std::string(method).substr(0, 7).compare("nearest") == 0) 
return Nearest; 
else if (std::string(method).substr(0, 7).compare("linear") == 0) 
return Linear; 
else if (std::string(method).substr(0, 5).compare("cubic") == 0) 
return Cubic; 
else 
mexErrMsgTxt("Specify one of nearest, linear, cubic as the interpolation method argument.");

return(Cubic); 
}
/*------------------------------End---------------------------------------<Fang Liu 27 Sep 2013>*/

void mexFunction(int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[]) {

  if (nlhs>1)
    mexErrMsgTxt("Wrong number of output arguments for Z = ba_interp3(Fx, Fy, Fz, F, X, Y, Z, method)");

  const mxArray *Fx = NULL;
  const mxArray *Fy = NULL;
  const mxArray *Fz = NULL;
  const mxArray *F = NULL;
  const mxArray *X = NULL;
  const mxArray *Y = NULL;
  const mxArray *Z = NULL;
  const mxArray *method = NULL;

  if (nrhs==4) {
    // ba_interp(F, X, Y, Z);
    F = prhs[0];
    X = prhs[1];
    Y = prhs[2];
    Z = prhs[3];
  } else if (nrhs==5) {
    // ba_interp(F, X, Y, Z, 'method');
    F = prhs[0];
    X = prhs[1];
    Y = prhs[2];
    Z = prhs[3];
    method = prhs[4];
  } else if (nrhs==7) {
    // ba_interp(Fx, Fy, Fz, F, X, Y, Z);
    Fx= prhs[0];
    Fy= prhs[1];
    Fz= prhs[2];
    F = prhs[3];
    X = prhs[4];
    Y = prhs[5];
    Z = prhs[6];
    method = prhs[4];
  } else if (nrhs==8) {
    // ba_interp(Fx, Fy, Fz, F, X, Y, Z, 'method');
    Fx= prhs[0];
    Fy= prhs[1];
    Fz= prhs[2];
    F = prhs[3];
    X = prhs[4];
    Y = prhs[5];
    Z = prhs[6];
    method = prhs[7];
  } else {
    mexErrMsgTxt("Wrong number of input arguments for Z = ba_interp3(Fx, Fy, Fz, F, X, Y, Z, method)");
  }
  if ((Fx && !mxIsDouble(Fx)) ||(Fy && !mxIsDouble(Fy)) ||(Fz && !mxIsDouble(Fz)) ||
      (F && !mxIsDouble(F)) ||
      (X && !mxIsDouble(X)) || (Y && !mxIsDouble(Y)) || (Z && !mxIsDouble(Z)))
    mexErrMsgTxt("ba_interp3 takes only double arguments for Fx,Fy,Fz,F,X,Y,Z");

  const mwSize *F_dims = mxGetDimensions(F);
  const mwSize *X_dims = mxGetDimensions(X);
  const mwSize *Y_dims = mxGetDimensions(Y);
  const mwSize *Z_dims = mxGetDimensions(Z);

  const mwSize M=F_dims[0];
  const mwSize N=F_dims[1];
  const mwSize O=F_dims[2];

  if (Fx && mxGetNumberOfElements(Fx)<2) mexErrMsgTxt("Fx needs at least two elements.");
  if (Fy && mxGetNumberOfElements(Fy)<2) mexErrMsgTxt("Fy needs at least two elements.");
  if (Fz && mxGetNumberOfElements(Fz)<2) mexErrMsgTxt("Fz needs at least two elements.");

  if ((mxGetNumberOfDimensions(X) != mxGetNumberOfDimensions(Y)) ||
      (mxGetNumberOfDimensions(X) != mxGetNumberOfDimensions(Z)) ||
      (mxGetNumberOfElements(X) != mxGetNumberOfElements(Y)) ||
      (mxGetNumberOfElements(X) != mxGetNumberOfElements(Z)))
    mexErrMsgTxt("X, Y, Z should have the same size");

  mwSize P=1;

  mwSize outDims[50];
  if (mxGetNumberOfDimensions(X) + mxGetNumberOfDimensions(F) - 3 > 50)
    mexErrMsgTxt("Can't have that many dimensions in interpolated data.");

  for (mwSize i=0; i<mxGetNumberOfDimensions(X); ++i) outDims[i] = X_dims[i];

  for (mwSize i=3; i<mxGetNumberOfDimensions(F); ++i) {
    outDims[mxGetNumberOfDimensions(X)+i-3] = F_dims[i];
    P *= F_dims[i];
  }


  plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(X) + mxGetNumberOfDimensions(F) - 3, outDims, mxDOUBLE_CLASS, mxREAL);

  const mwSize ND = mxGetNumberOfElements(X);

  const double *pF = mxGetPr(F);
  const double *pX = mxGetPr(X);
  const double *pY = mxGetPr(Y);
  const double *pZ = mxGetPr(Z);
  double       *pO = mxGetPr(plhs[0]);  

  if (Fx) { 
    
    const double x_low = mxGetPr(Fx)[0]; const double x_high = mxGetPr(Fx)[mxGetNumberOfElements(Fx)-1];
    const double y_low = mxGetPr(Fy)[0]; const double y_high = mxGetPr(Fy)[mxGetNumberOfElements(Fy)-1];
    const double z_low = mxGetPr(Fz)[0]; const double z_high = mxGetPr(Fz)[mxGetNumberOfElements(Fz)-1];
    
    const double s_x = double(1-N)/(x_low - x_high);
    const double s_y = double(1-M)/(y_low - y_high);
    const double s_z = double(1-O)/(z_low - z_high);

    const double o_x = double(1)-x_low*s_x;
    const double o_y = double(1)-y_low*s_y;
    const double o_z = double(1)-z_low*s_z;
    
    // Scale X, Y, Z before accessing
    // I've deliberatly copied these two paths, such that the compiler can optimize out the multiplication with 1 and addition of 0
  switch(parseInterpolationMethod(method)) { 
    case Nearest:
      switch (P) {
        case 1: interpolate_nearest_unrolled<1>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 2: interpolate_nearest_unrolled<2>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 3: interpolate_nearest_unrolled<3>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 4: interpolate_nearest_unrolled<4>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 5: interpolate_nearest_unrolled<5>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 6: interpolate_nearest_unrolled<6>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 7: interpolate_nearest_unrolled<7>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 8: interpolate_nearest_unrolled<8>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 9: interpolate_nearest_unrolled<9>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        default: 
                interpolate_nearest(pO, pF, pX, pY, pZ, ND, M, N, O, P, s_x, o_x, s_y, o_y, s_z, o_z);
      }
      break;
    case Linear:
      switch (P) {
        case 1: interpolate_linear_unrolled<1>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 2: interpolate_linear_unrolled<2>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 3: interpolate_linear_unrolled<3>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 4: interpolate_linear_unrolled<4>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 5: interpolate_linear_unrolled<5>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 6: interpolate_linear_unrolled<6>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 7: interpolate_linear_unrolled<7>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 8: interpolate_linear_unrolled<8>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 9: interpolate_linear_unrolled<9>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        default: 
                interpolate_linear(pO, pF, pX, pY, pZ, ND, M, N, O, P, s_x, o_x, s_y, o_y, s_z, o_z);
      }
      break;
    case Cubic:
      switch (P) {
        case 1: interpolate_bicubic_unrolled<1>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 2: interpolate_bicubic_unrolled<2>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 3: interpolate_bicubic_unrolled<3>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 4: interpolate_bicubic_unrolled<4>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 5: interpolate_bicubic_unrolled<5>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 6: interpolate_bicubic_unrolled<6>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 7: interpolate_bicubic_unrolled<7>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 8: interpolate_bicubic_unrolled<8>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        case 9: interpolate_bicubic_unrolled<9>(pO, pF, pX, pY, pZ, ND, M, N, O, s_x, o_x, s_y, o_y, s_z, o_z); break;
        default: 
                interpolate_bicubic(pO, pF, pX, pY, pZ, ND, M, N, O, P, s_x, o_x, s_y, o_y, s_z, o_z);
      }
      break;
    default:
      mexErrMsgTxt("Unimplemented interpolation method.");
  }
  } else {
  switch(parseInterpolationMethod(method)) {
    case Nearest:
      switch (P) {
        case 1: interpolate_nearest_unrolled<1>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 2: interpolate_nearest_unrolled<2>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 3: interpolate_nearest_unrolled<3>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 4: interpolate_nearest_unrolled<4>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 5: interpolate_nearest_unrolled<5>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 6: interpolate_nearest_unrolled<6>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 7: interpolate_nearest_unrolled<7>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 8: interpolate_nearest_unrolled<8>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 9: interpolate_nearest_unrolled<9>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        default: 
                interpolate_nearest(pO, pF, pX, pY, pZ, ND, M, N, O, P, double(1), double(0), double(1), double(0), double(1), double(0));
      }
      break;
    case Linear:
      switch (P) {
        case 1: interpolate_linear_unrolled<1>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 2: interpolate_linear_unrolled<2>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 3: interpolate_linear_unrolled<3>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 4: interpolate_linear_unrolled<4>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 5: interpolate_linear_unrolled<5>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 6: interpolate_linear_unrolled<6>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 7: interpolate_linear_unrolled<7>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 8: interpolate_linear_unrolled<8>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 9: interpolate_linear_unrolled<9>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        default: 
                interpolate_linear(pO, pF, pX, pY, pZ, ND, M, N, O, P, double(1), double(0), double(1), double(0), double(1), double(0));
      }
      break;
    case Cubic:
      switch (P) {
        case 1: interpolate_bicubic_unrolled<1>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 2: interpolate_bicubic_unrolled<2>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 3: interpolate_bicubic_unrolled<3>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 4: interpolate_bicubic_unrolled<4>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 5: interpolate_bicubic_unrolled<5>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 6: interpolate_bicubic_unrolled<6>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 7: interpolate_bicubic_unrolled<7>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 8: interpolate_bicubic_unrolled<8>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        case 9: interpolate_bicubic_unrolled<9>(pO, pF, pX, pY, pZ, ND, M, N, O, double(1), double(0), double(1), double(0), double(1), double(0)); break;
        default: 
                interpolate_bicubic(pO, pF, pX, pY, pZ, ND, M, N, O, P, double(1), double(0), double(1), double(0), double(1), double(0));
      }
      break;
    default:
      mexErrMsgTxt("Unimplemented interpolation method.");
  }
  }
}
