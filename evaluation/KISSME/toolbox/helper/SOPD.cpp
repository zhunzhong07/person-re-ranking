// C=SOPD(X,a,b)
// Computes and sums over all outer products of the columns in x.
// based on code (c) by Kilian Q. Weinberger

#include "mex.h"
#include <string.h>

#ifdef INT_2_BYTES
    typedef char      int8;
    typedef int       int16;
    typedef long      int32;
    typedef long long int64;
    
    typedef unsigned char      uint8;
    typedef unsigned int       uint16;
    typedef unsigned long      uint32;
    typedef unsigned long long uint64;
#else
    typedef char      int8;
    typedef short     int16;
    typedef int       int32;
    typedef long long int64;
    
    typedef unsigned char      uint8;
    typedef unsigned short     uint16;
    typedef unsigned int       uint32;
    typedef unsigned long long uint64;
#endif

static const int ARG_NUM_X = 0;
static const int ARG_NUM_IDXA = 1;
static const int ARG_NUM_IDXB = 2;

static const int ARG_NUM_OUT_SOPD = 0;

//-------------------------------------------------------------------------
template < typename dataType, mxClassID mxClassId  >
inline void sopd(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
  /* Declare variables. */ 

  dataType *X, *dummy, *v1,*v2, *C;
  dataType *av,*bv;
  int m,n,inds;
  int j,i,r,c;     
     
  /* Get the number of elements in the input argument. */
  inds = mxGetNumberOfElements(prhs[ARG_NUM_IDXA]);
  if(inds != mxGetNumberOfElements(prhs[ARG_NUM_IDXB]))
    mexErrMsgTxt("Both index vectors must have same length!\n");
  n = mxGetN(prhs[ARG_NUM_X]);
  m = mxGetM(prhs[ARG_NUM_X]);

  /* Get the data. */
  X   = (dataType*)mxGetPr(prhs[ARG_NUM_X]);
  av  = (dataType*)mxGetPr(prhs[ARG_NUM_IDXA]);
  bv  = (dataType*)mxGetPr(prhs[ARG_NUM_IDXB]);

  /* Create output matrix */
  plhs[ARG_NUM_OUT_SOPD]=mxCreateNumericMatrix(m,m,mxClassId,mxREAL);
  C=(dataType*)mxGetPr(plhs[ARG_NUM_OUT_SOPD]);
  memset(C,0,sizeof(dataType)*m*m);
  dummy=(dataType*)malloc(m*sizeof(dataType));

  /* compute outer products and sum them up */
  for(i=0;i<inds;i++){
   /* Assign cols addresses */
   v1=&X[(int) (av[i]-1)*m];
   v2=&X[(int) (bv[i]-1)*m];

   for(j=0;j<m;j++) dummy[j]=v1[j]-v2[j];

   j=0;	
   for(r=0;r<m;r++){
	 for(c=0;c<=r;c++) {C[j]+=dummy[r]*dummy[c];j++;};
	 j+=m-r-1;
   }
  }

  /* fill in lower triangular part of C */
  if(inds>0)
   for(r=0;r<m;r++)
	 for(c=r+1;c<m;c++) C[c+r*m]=C[r+c*m];
  free(dummy);
}
//-------------------------------------------------------------------------
void mexFunction(int outputSize, mxArray *output[], int inputSize, const mxArray *input[]) 
{
  /* Check for proper number of input and output arguments. */    
  if (inputSize != 3) {
    mexErrMsgTxt("Exactly three input arguments required.");
  } 

  if (outputSize > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
   /* Check data type of input arguments is the same. */
  if (!(mxGetClassID(input[ARG_NUM_X]) == mxGetClassID(input[ARG_NUM_IDXA]) && mxGetClassID(input[ARG_NUM_X]) == mxGetClassID(input[ARG_NUM_IDXB]))) {
   mexErrMsgTxt("inputs should be of same type.");
  }
  
  try
  {
    switch(mxGetClassID(input[ARG_NUM_X]))
    {
        case mxUINT16_CLASS:
            if(sizeof(uint16)!=2)
                mexErrMsgTxt("error uint16");
            sopd<uint16,mxUINT16_CLASS>(outputSize, output, inputSize, input);        
            break;
        case mxINT16_CLASS:
            if(sizeof(int16)!=2)
                mexErrMsgTxt("error int16");
            sopd<int16,mxINT16_CLASS>(outputSize, output, inputSize, input);              
            break;
        case mxUINT32_CLASS:
            if(sizeof(uint32)!=4)
                mexErrMsgTxt("error uint32");
            sopd<uint32,mxUINT32_CLASS>(outputSize, output, inputSize, input);        
            break;
        case mxINT32_CLASS:
            if(sizeof(int32)!=4)
                mexErrMsgTxt("error int32");
            sopd<int32,mxINT32_CLASS>(outputSize, output, inputSize, input);           
            break;
        case mxUINT64_CLASS:
            if(sizeof(uint64)!=8)
                mexErrMsgTxt("error uint64");
            sopd<uint64,mxUINT64_CLASS>(outputSize, output, inputSize, input);            
            break;
        case mxINT64_CLASS:
            if(sizeof(int64)!=8)
                mexErrMsgTxt("error int64");
            sopd<int64,mxINT64_CLASS>(outputSize, output, inputSize, input);            
            break;
		case mxSINGLE_CLASS:
            sopd<float,mxSINGLE_CLASS>(outputSize, output, inputSize, input);          
            break;	
        case mxDOUBLE_CLASS:
            sopd<double,mxDOUBLE_CLASS>(outputSize, output, inputSize, input);          
            break;
        default:
           mexErrMsgTxt("sorry class not supported!");         
    }
  }
  catch(...)
  {
    mexErrMsgTxt("Internal error");
  }
}
//-------------------------------------------------------------------------



