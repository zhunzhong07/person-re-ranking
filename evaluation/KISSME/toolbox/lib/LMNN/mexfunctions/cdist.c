/*
 * =============================================================
 * cdist.c 
  
 * input: x,a,b
 * x: DxN matrix
 * a: 1xN vector of indices
 * b: 1xN vector of indices
 * 
 * output: sum((x(:,a)-x(:,b)).^2)
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

#define X_IN prhs[0]
#define A_IN prhs[1]
#define B_IN prhs[2]

double square(double x) { return(x*x);}



double dotp(int m, double *v1,double *v2){
  int j;
  double dp=0;

   for(j=0;j<m;j++){ 
     dp=dp+v1[j]*v2[j];
   }
   return (dp);
};

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Declare variables. */ 

  double *a,*b,*sx2,*X, *X2,*v1, *v2, *dis;
  int i1,i2,m,n,inds,i,j;
  int ione=1;



  /* Check for proper number of input and output arguments. */    
  if (nrhs != 3) {
    mexErrMsgTxt("Exactly three input arguments required.");
  } 

  /* Check data type of input argument. */
  if (!(mxIsDouble(X_IN))) {
   mexErrMsgTxt("Input array must be of type double.");
  }
      
  /* Get the data. */
  n = mxGetN(X_IN);
  m = mxGetM(X_IN);
  X  = mxGetPr(X_IN);

  a = mxGetPr(A_IN);
  b = mxGetPr(B_IN);
 
  inds=mxGetNumberOfElements(A_IN);

  if(inds!=mxGetNumberOfElements(B_IN))
    mexErrMsgTxt("Both index vectors must have identical length!\n");

  /* Create output matrix */
  plhs[0]=mxCreateDoubleMatrix(1,inds,mxREAL);
  dis=mxGetPr(plhs[0]);
  
  /* Allocate storage for sx2=sum(x.^2) */
  sx2=mxCalloc(n,sizeof(double));

  
  /* compute sx2 */
  for (i=0;i<n;i++){
   v1=&X[i*m];
   /*   dis[i]=ddot_(&m,v1,&ione,v1,&ione);*/
   /*   for(j=0;j<m;j++){ 
         sx2[i]=sx2[i]+v1[j]*v1[j];
	 }*/
   sx2[i]=dotp(m,v1,v1);
  }

  
  /* compute distances */
  for (i=0;i<inds;i++){
    i1=(int) a[i]-1;
    i2=(int) b[i]-1;
    v1=&X[i1*m];
    v2=&X[i2*m];
    dis[i]=sx2[i1]+sx2[i2]-2*dotp(m, v1,v2);
  }
}



