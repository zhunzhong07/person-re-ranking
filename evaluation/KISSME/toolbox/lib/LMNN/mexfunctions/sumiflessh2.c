/*
 * =============================================================
 * sumiflessv.c 
  
 * takes two inputs, one (mxn) matrix M and one vector 
 *                       (1xm) vector v
 * each element of every column of M that is less than the 
 * corresponding v entry is added to the output vector
 * output(j)=sum_{i} M_{j,i}*(M_{j,i}<v(i))
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
  int j,N3,M,N,Mv,Nv, mv,m,n,i;
  int size1,size2;
  double *pM, *pv , *po,*p3;
  int mRows,nCols;



  /* Check for proper number of input and output arguments. */    
  if (nrhs != 3) {
    mexErrMsgTxt("Three input arguments required.");
  } 
  if (nlhs > 3) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* Check data type of input argument. */
  if (!(mxIsDouble(prhs[0]))) {
    mexErrMsgTxt("Input array must be of type double.");
  }
    
  /* Get the number of elements in the input argument. */
  M = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);

  Mv = mxGetM(prhs[1]);
  Nv = mxGetN(prhs[1]);

  N3=mxGetNumberOfElements(prhs[2]);

  if(Nv!=N) mexErrMsgTxt("2nd dimension of 2nd vector must equal 1st dimension of 1st input\n");
  
  /* Get the data. */
  pM  = (double *)mxGetPr(prhs[0]);
  pv  = (double *)mxGetPr(prhs[1]);
  p3  = (double *)mxGetPr(prhs[2]);

  
  plhs[0]=mxCreateDoubleMatrix(1,N,mxREAL);
  po=mxGetPr(plhs[0]);
  

  for(n=0;n<N;n++){
     for(m=0;m<N3;m++){
       i=n*M+p3[m]-1;
       for(mv=Mv*n;mv<Mv*(n+1);mv++)
        if(pv[mv]>pM[i]) po[n]=po[n]+pv[mv]-pM[i];     
     
    }	
  }
}

