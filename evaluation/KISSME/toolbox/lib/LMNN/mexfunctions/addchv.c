/*
 * =============================================================
 * addchv.c 
  
 * takes one input matrix M and two input vectors h,v
 * 
 * equivalent to: addh(M,v)=c*M+repmat(h,size(M,1),1)+repmat(v,1,size(M,2));
 * =============================================================
 */

/* $Revision: 1.1 $ */

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
  int elements, elementsV1,elementsV2, r,c,j, ndims, cmplx;
  int nnz = 0, count = 0; 
  double *pr, *prc, *prV1, *prV2 , *pindV, *pind, CV;
  int mRows,nCols;

  /* Check for proper number of input and output arguments. */    
  if (nrhs != 4) {
    mexErrMsgTxt("Two input arguments required.");
  } 
  if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* Check data type of input argument. */
  if (!(mxIsDouble(prhs[0]))) {
    mexErrMsgTxt("Input array must be of type double.");
  }
    
  /* Get the number of elements in the input argument. */
  elements = mxGetNumberOfElements(prhs[0]);

  elementsV1= mxGetNumberOfElements(prhs[2]);
  elementsV2= mxGetNumberOfElements(prhs[3]);

  /* Get the data. */
  pr  = (double *)mxGetPr(prhs[0]);
  prc  = (double *)mxGetPr(prhs[1]);
  prV1 = (double *)mxGetPr(prhs[2]);
  prV2 = (double *)mxGetPr(prhs[3]);

  CV=(int) prc[0];
  
  mRows = mxGetM(prhs[0]);
  nCols = mxGetN(prhs[0]);

 if(elementsV1!=nCols)  mexErrMsgTxt("Second input must have same number of elements as first argument has rows.\n");
 if(elementsV2!=mRows)  mexErrMsgTxt("Third input must have same number of elements as first argument has columns.\n");
  
  plhs[0]= mxCreateDoubleMatrix(mRows,nCols,mxREAL);
  pind=mxGetPr(plhs[0]);
  
  j=0; 
  for(c=0;c<nCols;c++)
      for(r=0;r<mRows;r++){
        pind[j]=CV*pr[j]+prV1[c]+prV2[r];        
        j=j+1;
      }
  
  
}
