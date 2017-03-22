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
  int N1,N2, o1,o2,i1,i2,ci,co,r,vi;
  int size1,size2;
  double *pi1, *pi2 , *po1, *po2;
  int mRows,nCols;



  /* Check for proper number of input and output arguments. */    
  if (nrhs != 1) {
    mexErrMsgTxt("ONE input argument required.");
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
  

  /* Get the data. */
  pi1  = (double *)mxGetPr(prhs[0]);

  mRows = mxGetM(prhs[0]);
  nCols = mxGetN(prhs[0]);
  
  
  /*  m1=mxGetM(prhs[0]);
  n1=mxGetN(prhs[0]);
  m2=mxGetM(prhs[1]);
  n2=mxGetN(prhs[1]);*/
  
  plhs[0]=mxCreateDoubleMatrix(mRows,nCols,mxREAL);
  po1=mxGetPr(plhs[0]);
  plhs[1]=mxCreateDoubleMatrix(1,nCols,mxREAL);
  po2=mxGetPr(plhs[1]);


  ci=0;
  co=-1;
  i1=0;
  o1=-mRows;
  while(ci<nCols){
    if(ci==0 || pi1[i1]!=po1[o1]){
      o1=o1+mRows;
      for(r=0;r<mRows;r++){
	po1[o1+r]=pi1[i1+r];
      }
    co=co+1;
     po2[co]=1;
    } else{
      po2[co]=po2[co]+1;
    }
    ci=ci+1;
    i1=i1+mRows;
  }

  mxSetN(plhs[0],co+1);
  mxSetN(plhs[1],co+1);
}



