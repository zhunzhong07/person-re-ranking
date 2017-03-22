/*
 * =============================================================
 * findlessh.c
  
 * takes two input vectors M,v
 * 
 * equivalent to: find(M<repmat(v,size(M,1),1)
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
  int Ni1,Ni2, r,c,i,j, ndims, cmplx;
  int nnz = 0, count = 0; 
  double *pr, *prV ,*pout;
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
  Ni1 = mxGetNumberOfElements(prhs[0]);

  Ni2 = mxGetNumberOfElements(prhs[1]);

  /* Get the data. */
  pr  = (double *)mxGetPr(prhs[0]);
  prV = (double *)mxGetPr(prhs[1]);

  
  mRows = mxGetM(prhs[0]);
  nCols = mxGetN(prhs[0]);


 if(Ni2!=nCols){
   mexErrMsgTxt("Second input must have same number of elements as first argument has columns.\n");
  }
  
  plhs[0]= mxCreateDoubleMatrix(1,Ni1,mxREAL);
  pout=mxGetPr(plhs[0]);
  
  j=0; i=0;
  for(c=0;c<nCols;c++){
      for(r=0;r<mRows;r++){
       if(pr[j]<prV[c]){
           pout[i]=j+1;
	   i=i+1;
         }
        j=j+1;
      }
  }
 mxSetN(plhs[0],i);  
}
