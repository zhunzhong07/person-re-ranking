/*
 * =============================================================
 * sd.c 
  
 * takes two input sorted input vectors and finds the difference
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
  int N1,N2, o1,o2,i1,i2;
  int size1,size2;
  double *pi1, *pi2 , *po1, *po2;
  int mRows,nCols;



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
  N1 = mxGetNumberOfElements(prhs[0]);
  N2 = mxGetNumberOfElements(prhs[1]);

  

  /* Get the data. */
  pi1  = (double *)mxGetPr(prhs[0]);
  pi2  = (double *)mxGetPr(prhs[1]);

  /*  mRows = mxGetM(prhs[0]);
  nCols = mxGetN(prhs[0]);*/
  
  
  /*  m1=mxGetM(prhs[0]);
  n1=mxGetN(prhs[0]);
  m2=mxGetM(prhs[1]);
  n2=mxGetN(prhs[1]);*/
  
  plhs[0]=mxCreateDoubleMatrix(1,N1,mxREAL);
  po1=mxGetPr(plhs[0]);
  plhs[1]=mxCreateDoubleMatrix(1,N2,mxREAL);
  po2=mxGetPr(plhs[1]);


  i1=0;i2=0;
  o1=0;o2=0;
  while(i1<N1 && i2<N2){
    if(pi1[i1]==pi2[i2]) {i1=i1+1;i2=i2+1;}
    else
      if(pi1[i1]<pi2[i2]) {po1[o1]=pi1[i1];o1=o1+1;i1=i1+1;} 
      else {po2[o2]=pi2[i2];o2=o2+1;i2=i2+1;};
      
  }

  for(;i1<N1;i1=i1+1) {po1[o1]=pi1[i1];o1=o1+1;}
  for(;i2<N2;i2=i2+1) {po2[o2]=pi2[i2];o2=o2+1;}
   
  mxSetN(plhs[0],o1);
  mxSetN(plhs[1],o2);
}

