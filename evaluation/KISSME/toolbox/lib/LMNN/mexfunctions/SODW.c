/*
 * =============================================================
 * SODW.c
  
 * input: x,a,b,w
 *    x : matrix DxN
 *    a : vector 1xnn
 *    b : vector 1xnn
 * 
 * output: for i=1:nn; res=res+w(i)*(x(:,a(i))-x(:,b(i)))*(x(:,a(i))-x(:,b(i)))';end;
 * 
 * =============================================================
 */

/* $Revision: 1.2 $ */

#include "mex.h"
#include <string.h>

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


double square(double x) { return(x*x);}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Declare variables. */ 

  double *X, *dummy, *v1,*v2, *C;
  double *av,*bv;
  int m,p,n,inds;
  int j,i,r,c;
  int ione=1;
  char *chu="U"; 
  char *chl="L";
  char *chn2="T";
  char *chn="N";
  double w,minusone=-1.0,one=1.0, zero=0.0;
  double * weights;  


  /* Check for proper number of input and output arguments. */    
  if (nrhs != 4) {
    mexErrMsgTxt("Exactly four input arguments required.");
  } 

  if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* Check data type of input argument. */
  if (!(mxIsDouble(prhs[0]))) {
   mexErrMsgTxt("Input array must be of type double.");
  }

  /* Get the number of elements in the input argument. */
  inds = mxGetNumberOfElements(prhs[1]);
  if(inds != mxGetNumberOfElements(prhs[2]))
    mexErrMsgTxt("Hey Bongo! Both index vectors must have same length!\n");

 if(inds != mxGetNumberOfElements(prhs[3]))
  mexErrMsgTxt("Hey Bongo! Weight  vector must have same length as index vectors!\n");

  n = mxGetN(prhs[0]);
  m = mxGetM(prhs[0]);

  /* Get the data. */
  X  = mxGetPr(prhs[0]);
  av  = mxGetPr(prhs[1]);
  bv  = mxGetPr(prhs[2]);
  weights  = mxGetPr(prhs[3]);
	

  /* Create output matrix */
  plhs[0]=mxCreateDoubleMatrix(m,m,mxREAL);
  C=mxGetPr(plhs[0]);
  memset(C,0,sizeof(double)*m*m);
/*  dummy=new double[m];*/
  dummy=malloc(m*sizeof(double));

 /* compute outer products and sum them up */
  for(i=0;i<inds;i++){
   /* Assign cols addresses */
   v1=&X[(int) (av[i]-1)*m];
   v2=&X[(int) (bv[i]-1)*m];
   w=weights[i];

   for(j=0;j<m;j++) dummy[j]=v1[j]-v2[j];

  j=0;	
   for(r=0;r<m;r++){
	 for(c=0;c<=r;c++) {C[j]+=dummy[r]*dummy[c]*w;j++;};
	 j+=m-r-1;
   }
  }


  /* fill in lower triangular part of C */
  if(inds>0)
   for(r=0;r<m;r++)
	 for(c=r+1;c<m;c++) C[c+r*m]=C[r+c*m]; 
 free(dummy);
}



