/*
 * =============================================================
 * mink.c 
  
 * takes two inputs, one (mxn) matrix M and one 
 *                       (1x1) scalar k
 * 
 * 
 * mink finds the smallest k elements in each column of M
 * 
 * =============================================================
 */

/* $Revision: 1.2 $ */

#include "mex.h"

/* If you are using a compiler that equates NaN to zero, you must
 * compile this example using the flag -DNAN_EQUALS_ZERO. For 
 * example:
 *
 *     mex -DNAN_EQUALS_ZERO findnz.c  
 *
 * This will correctly define the IsNonZero macro for your
   compiler. */

#if NAN_EQUALS_ZERO
#define IsNonZero(d) ((d) != 0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d) != 0.0)
#endif



void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Declare variables. */ 
  int a,b,c,k,M,N, m,n,i,kstart,j,insert;
  int size1,size2;
  double *ps,*pM, *pk , *po,*po2;
  int mRows,nCols;
  mxArray *infOut[1];
  double inf;
  


  /* Check for proper number of input and output arguments. */    
  if (nrhs != 2) {
    mexErrMsgTxt("Two input arguments required.");
  } 
  if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* Check data type of input argument. */
  if (!(mxIsDouble(prhs[0]))) {
    mexErrMsgTxt("Input array must be of type double.");
  }
    
  /* Get the number of elements in the input argument. */
  M = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);
  
  /* Get the data. */
  pM  = (double *)mxGetPr(prhs[0]);
  pk  = (double *)mxGetPr(prhs[1]);

  k=(int) pk[0];
  plhs[0]=mxCreateDoubleMatrix(k,N,mxREAL);
  plhs[1]=mxCreateDoubleMatrix(k,N,mxREAL);
  po=mxGetPr(plhs[0]);
  po2=mxGetPr(plhs[1]);
  
  mexCallMATLAB(1,infOut,0,NULL,"inf");
  ps=mxGetPr(infOut[0]); 
  inf=ps[0];

  i=0;kstart=0;

  for(n=0;n<N;n++){
    for(j=kstart;j<kstart+k;j++) po[j]=inf;
   for(m=0;m<M;m++){
     if(pM[i]<po[kstart+k-1]){
       /* find place to insert*/
     for(j=kstart;j<kstart+k && po[j]<pM[i];j++);
     insert=j;
     /* move everything down one */
     for(j=kstart+k-1;j>insert;j--){po[j]=po[j-1];po2[j]=po2[j-1];}
     /* insert */
     if(insert<kstart+k) {po[insert]=pM[i];po2[insert]=m+1;}
     }
     i=i+1;
   }	
   kstart+=k;
  };
}

