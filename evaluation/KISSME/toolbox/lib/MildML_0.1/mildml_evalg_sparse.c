/*
 * =======================================================================
 * mildml_evalg_double.c 
 *
 * Compute MildML log-likelihood and gradient in double precision
 *
 * Compile using "mex -largeArrayDims mildml_evalg_sparse.c"
 *
 * Copyright (C) 2009 - 2010 by Matthieu Guillaumin, INRIA
 * =======================================================================
 */

#include "string.h"
#include "math.h"
#include "mex.h"
#include "compute_tasks.c"

#define MIN_PAIRS_PER_CPU 1000
#define INF 1e300

#define sigmoid(x) (1/(1+exp(x)))
#define min(x,y) ((x)<(y))?(x):(y)
#define max(x,y) ((x)>(y))?(x):(y)

typedef double(*bagmatchPtr)(const int,const int);

double *Z=NULL,*Y=NULL,*I=NULL,*U=NULL,*UU=NULL,*UUp=NULL,*UUn=NULL,*D=NULL,*H=NULL;
double *lni=NULL,*lpi=NULL,*dbi=NULL,*dbip=NULL,*dbin=NULL,*nni=NULL,*npi=NULL;
long *Yir, *Yjc;
double b=0,np=0,nn=0;
int n,k,m,c,wtype=0;
int ncpu=1;
bagmatchPtr bagmatch_sparse=NULL;

int count_cpu(int nn) {
    cpu_set_t set;
    int i, count=0;
    sched_getaffinity(0, sizeof(cpu_set_t), &set);
    for(i=0;i<CPU_SETSIZE;i++)
        if(CPU_ISSET(i, &set)) count++;
    if (count*MIN_PAIRS_PER_CPU>nn)
        count=(int) floor(nn/MIN_PAIRS_PER_CPU);
    return count;
}

double sum(const double *vec, int p) {
    double s=0;
    while (p--)
	s += vec[p];
    return s;
}


int bagmatch(const double *yi, const double *yj, int cc) {
    while (cc--)
	if (((int)yi[cc]) && ((int)yj[cc]))
	    return 1;
    return 0;
}

double bagmatch_binary(const int i, const int j) {
    int ii = Yjc[i];
    int ij = Yjc[j];
    while (ii<Yjc[i+1] && ij<Yjc[j+1]) {
	if (Yir[ii]==Yir[ij])
	    return 1;
	if (Yir[ii]<Yir[ij]) {
	    ii++;
	} else {
	    ij++;
	}
    }
    return 0;
}


double bagmatch_innerproduct(const int i, const int j) {
    int ii = Yjc[i];
    int ij = Yjc[j];
    double w = 0;
    while (ii<Yjc[i+1] && ij<Yjc[j+1]) {
	if (Yir[ii]==Yir[ij]) {
	    ii++;
	    ij++;
	    w++;
	} else {
	    if (Yir[ii]<Yir[ij]) {
		ii++;
	    } else {
		ij++;
	    }
	}
    }
    return w;
}

double bagmatch_logistic(const int i, const int j) {
    int ii = Yjc[i];
    int ij = Yjc[j];
    double w = 0;
    while (ii<Yjc[i+1] && ij<Yjc[j+1]) {
	if (Yir[ii]==Yir[ij]) {
	    w++;
            ii++;
	    ij++;
	} else {
	    if (Yir[ii]<Yir[ij]) {
		ii++;
	    } else {
		ij++;
	    }
	}
    }
    if (w==0)
	return 0;
    return 2*sigmoid(-w)-1;
}

/*
double bagmatch_sparse(const int i, const int j) {
    return bagmatch_binary(i,j);
}
*/

void setBagMatch() {
    bagmatch_sparse=NULL;
    switch (wtype) {
        case 0 : bagmatch_sparse=bagmatch_binary;              break;
        case 1 : bagmatch_sparse=bagmatch_innerproduct;        break;
        case 2 : bagmatch_sparse=bagmatch_logistic;            break;
    }
}


void add(double *U, double *Ut, int nk) {
    while (nk--)
	U[nk] += Ut[nk];
}

double dist2(const double *xi, const double *xj, int p) {
    double d=0;
    while(p--) {
	const double df = xi[p]-xj[p];
	d += df*df;
    }
    return d;
}

void diffsto(const double *xi, const double *xj, double *Dt, int p) {
    while(p--) 
	Dt[p] = xi[p]-xj[p];
}

double dist2sto(const double *xi, const double *xj, double *Dt, int p) {
    double d=0;
    while(p--) {
	Dt[p] = xi[p]-xj[p];
	d += Dt[p]*Dt[p];
    }
    return d;
}

void updateU(double *Ui, double *xj, const double qij, int p) {
    while(p--)
	Ui[p] += xj[p]*qij;
}

void computeU(double *Ut, double *Dt, double *lp, double *ln, double *db, int begin, int end ) {
    int i,j;
    double *xi = Z+k*begin;
    double *Ui = Ut+k*begin;

    for(i=begin;i<end;) {
       const double *yi  = Y+((int)I[i])*c; /* label vector for bag of i */
       const int nbi = (int) H[(int) I[i]]; /* number of elements in bag of i */
       const int ue = k*nbi;
       double *Uj = Ui+ue;
       double *xj = xi+ue;

       for (j=i+nbi;j<n;) {
           const double *yj = Y+((int)I[j])*c; /* label vector for bag of j */
           const int nbj    = (int) H[(int) I[j]]; /* compute nbj, number of elements in bag of j */
	   const int ve=k*nbj;
           const int t      = bagmatch(yi,yj,c);       /* Target value 0|1 */
	   int um,vm;
	   double p;

	   /* Probability output of LDML for pair (i,j), store data difference */
	   if (nbi==1 && nbj==1) {
               p = sigmoid(dist2sto(xi,xj,Dt,k)-b);
	       um = 0;
	       vm = 0;
	   } else {
	       /* TODO: consider storing (um,vm) to save time ? */
	       int u=0,v=0;
	       double d=INF;
               for (u=0;u<ue;u+=k) {
	          for (v=0;v<ve;v+=k) {
                      double dtmp = dist2(xi+u,xj+v,k); 
		      if (dtmp<d) {
			 um=u;
			 vm=v;
			 d=dtmp;
		      }
	          }
  	       }
	       diffsto(xi+um,xj+vm,Dt,k);
	       p = sigmoid(d-b);
	   }

           const double q   = (p-(double) t)/(t?np:nn);     /* Weighted difference between target and probability */
           t?(*lp+=log(p)):(*ln+=log(1-p));                 /* Log-likelihood */
           updateU(Uj,Dt,q,k);
           updateU(Ui,Dt,-q,k);
	   *db+=q;
	   xj+=ve;
	   Uj+=ve;
	   j+=nbj;
       }
       xi+=ue;
       Ui+=ue;
       i+=nbi;
    }
}

void computeU_thread( void *arg, int tid, int ii ) {
    double *Ut = UU+(long)tid*k*n;
    double *Dt = D+(long)tid*k;
    int begin = max(0,floor(n-sqrt((1-((double) ii)/ncpu)*n*(n-1))));
    if (begin>0) {
        while (begin>0 && I[begin]==I[begin-1])
	    begin--;
    }
    int end   = min(n,floor(n-sqrt((1-(((double) ii)+1)/ncpu)*n*(n-1))));
    if (end<n) {
	while (end>0 && I[end]==I[end-1])
	    end--;
    }
/*    fprintf(stdout,"Task %d: %d--%d\n",ii,begin,end); */
    computeU(Ut, Dt, lpi+tid, lni+tid, dbi+tid, begin, end );
}

void computeUsp(double *Utp, double *Utn, double *Dt, double *ltp, double *ltn, double *dbtp, double *dbtn, double *ntp, double *ntn, int begin, int end ) {
    int i,j;
    double *xi = Z+k*begin;
    double *Uip = Utp+k*begin;
    double *Uin = Utn+k*begin;

    for(i=begin;i<end;) {
       const bi      = (int) I[i];  /* bag number */
       const int nbi = (int) H[bi]; /* number of elements in bag */
       const int ue  = k*nbi;
       double *Ujp   = Uip+ue;
       double *Ujn   = Uin+ue;
       double *xj    = xi+ue;

       for (j=i+nbi;j<n;) {
	   const int bj     = (int) I[j]; /* bag number */
           const int nbj    = (int) H[bj]; /* number of elements in bag */
	   const int ve     = k*nbj;
           const double t   = bagmatch_sparse(bi,bj); /* Target and weight value for bag pair */
	   int um,vm;
	   double p;

	   /* Probability output of LDML for pair (i,j), store data difference */
	   if (nbi==1 && nbj==1) {
               p = sigmoid(dist2sto(xi,xj,Dt,k)-b);
	       um = 0;
	       vm = 0;
	   } else {
	       /* TODO: consider storing (um,vm) to save time ? */
	       int u=0,v=0;
	       double d=INF;
               for (u=0;u<ue;u+=k) {
	          for (v=0;v<ve;v+=k) {
                      double dtmp = dist2(xi+u,xj+v,k); 
		      if (dtmp<d) {
			 um=u;
			 vm=v;
			 d=dtmp;
		      }
	          }
  	       }
	       diffsto(xi+um,xj+vm,Dt,k);
	       p = sigmoid(d-b);
	   }


	   if (t==0) {
               *ntn+=1;
	       *ltn+=log(1-p);
	       *dbtn+=p;
	       updateU(Ujn+vm,Dt,p,k);
	       updateU(Uin+um,Dt,-p,k);
	   } else {
	       const double q = (p-1)*t;
	       *ntp+=t;
	       *ltp+=log(p)*t;
	       *dbtp+=q;
	       updateU(Ujp+vm,Dt,q,k);
	       updateU(Uip+um,Dt,-q,k);
	   }
	   
          /* fprintf(stdout,"Number of pairs in thread: %d %f (%d,%d)\n",(int)t,p,*npi,*nni); */

           /*const double q   = (p-(double) t)/(t?np:nn);*/     /* Weighted difference between target and probability => TODO: differ normalization */
	   /*t?(*npi+=t):(*nni+=1);*/                           /* Update normalization terms */
           /*t?(*lp+=log(p)):(*ln+=log(1-p));*/                 /* Log-likelihood */
           /*updateU(Uj+vm,Dt,q,k);*/
           /*updateU(Ui+um,Dt,-q,k);*/
	   /**db+=q;*/

	   xj+=ve;
	   Ujp+=ve;
	   Ujn+=ve;
	   j+=nbj;
       }
       xi+=ue;
       Uip+=ue;
       Uin+=ue;
       i+=nbi;
    }
}

void computeUsp_thread( void *arg, int tid, int ii ) {
    int begin = max(0,floor(n-sqrt((1-((double) ii)/ncpu)*n*(n-1))));
    if (begin>0) {
        while (begin>0 && I[begin]==I[begin-1])
	    begin--;
    }
    int end   = min(n,floor(n-sqrt((1-(((double) ii)+1)/ncpu)*n*(n-1))));
    if (end<n) {
	while (end>0 && I[end]==I[end-1])
	    end--;
    }
    computeUsp(UUp+(long)tid*k*n, UUn+(long)tid*k*n, D+(long)tid*k, lpi+tid, lni+tid, dbip+tid, dbin+tid, npi+tid, nni+tid, begin, end );
/*    fprintf(stdout,"Number of pairs in thread %d: (%f,%f)\n",tid,npi[tid],nni[tid]); */
}

void addU_thread( void *arg, int tid, int ii ) {
    int i;
    const long kn = k*n;
    const long slice = kn/ncpu;
    double *Ui = U+(long)ii*slice;
    double *UUip = UUp+(long)ii*slice;
    double *UUin = UUn+(long)ii*slice;
    const double inp = 1/np; /* precompute normalizations */
    const double inn = 1/nn;
    for(i=0;i<ncpu;i++) {
	updateU(Ui,UUip,inp,slice);
	updateU(Ui,UUin,inn,slice);
	UUip += kn;
	UUin += kn;
    }
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ /* Matlab arguments are: Z,I,Y,H,b,n,k,m,c,wtype */
    int i;
    double l,p0,db;

    if (nrhs != 9) {
        mexErrMsgTxt("Nine inputs required");
    }

    for(i=0;i<9;i++) {
        if (!mxIsDouble(prhs[i]) && i!=2)
            mexErrMsgTxt("Inputs must be DOUBLE");
        if (i>3 && mxGetNumberOfElements(prhs[i])!=1)
            mexErrMsgTxt("Inputs 5 to 9 must be scalar");
    }

    b = (double) mxGetScalar(prhs[4]); /* bias term */
    n = (int) mxGetScalar(prhs[5]);    /* number of data points */
    k = (int) mxGetScalar(prhs[6]);    /* data dimensionality */
    m = (int) mxGetScalar(prhs[7]);    /* number of data bags */
    c = (int) mxGetScalar(prhs[8]);    /* number of labels */
    /* wtype = (int) mxGetScalar(prhs[9]);  weight type. only 0 supported yet */
        
    if (mxGetNumberOfElements(prhs[1])!=n)
        mexErrMsgTxt("Input 2 must be of length given by 6th argument");
    if (mxGetN(prhs[0])!=n || mxGetM(prhs[0])!=k)
        mexErrMsgTxt("Input 1 must be of size given by 6th and 7th arguments");
    if (mxGetN(prhs[2])!=m || mxGetM(prhs[2])!=c)
        mexErrMsgTxt("Input 3 must be of size given by 8th and 9th arguments");
    if (mxGetNumberOfElements(prhs[3])!=m)
        mexErrMsgTxt("Input 4 must be of length given by 8th argument");
    if (mxIsSparse(prhs[2])) {
        Yir = mxGetIr(prhs[2]); /* bag labels as sparse matrix: ir */
        Yjc = mxGetJc(prhs[2]); /*                          and jc */
	Y=NULL;
    } else {
        mexErrMsgTxt("Input 3 must be sparse");
        Y=mxGetData(prhs[2]); /* bag labels as full matrix */
	Yir=NULL;
	Yjc=NULL;
    }

    ncpu=count_cpu(n*n);

    Z = mxGetData(prhs[0]); /* data */
    I = mxGetData(prhs[1]); /* bags */
    H = mxGetData(prhs[3]); /* bag sizes */
    plhs[1] = mxCreateNumericMatrix(k,n,mxDOUBLE_CLASS,mxREAL);
    U = mxGetData(plhs[1]); /* D-by-d */

    lpi  = calloc(ncpu,sizeof(double));
    if (lpi==NULL)
        mexErrMsgTxt("Can't allocate (0)");
    lni  = calloc(ncpu,sizeof(double));
    if (lni==NULL)
        mexErrMsgTxt("Can't allocate (1)");
    dbip = calloc(ncpu,sizeof(double));
    if (dbip==NULL)
        mexErrMsgTxt("Can't allocate (2)");
    dbin = calloc(ncpu,sizeof(double));
    if (dbin==NULL)
        mexErrMsgTxt("Can't allocate (3)");
    npi  = calloc(ncpu,sizeof(double));
    if (npi==NULL)
        mexErrMsgTxt("Can't allocate (4)");
    nni  = calloc(ncpu,sizeof(double));
    if (nni==NULL)
        mexErrMsgTxt("Can't allocate (5)");
    UUp  = calloc(k*n*ncpu,sizeof(double));
    if (UUp==NULL)
        mexErrMsgTxt("Can't allocate (6)");
    UUn  = calloc(k*n*ncpu,sizeof(double));
    if (UUn==NULL)
        mexErrMsgTxt("Can't allocate (7)");
    D    = calloc(k*ncpu,sizeof(double));
    if (D==NULL)
        mexErrMsgTxt("Can't allocate (8)");

    setBagMatch();
    if (bagmatch_sparse==NULL)
        mexErrMsgTxt("Unknown weight type");

/*    if (Y) { 
        compute_tasks(ncpu, ncpu, &computeU_thread, NULL); */
        /*computeU(U, D, lpi, lni, dbi, 0, n );*/
/*    } else { */
        compute_tasks(ncpu, ncpu, &computeUsp_thread, NULL);
/*    } */

    np  = sum(npi,ncpu);
    nn  = sum(nni,ncpu);

/*    fprintf(stdout,"Class normalization: (%f,%f)\n",np,nn); */

    compute_tasks(ncpu, ncpu, &addU_thread, NULL);

    p0 = sigmoid(-b);

    l = sum(lpi,ncpu)/np+sum(lni,ncpu)/nn;               /* Normalize class weights */
    plhs[0] = mxCreateDoubleScalar(-2*l-(n*log(p0))/np); /* Negative log-likelihood */

    db  = sum(dbip,ncpu)/np+sum(dbin,ncpu)/nn;           /* Normalize class weights */
    plhs[2] = mxCreateDoubleScalar(2*db+n*(p0-1)/np);    /* Gradient of bias term   */ 

    free(D);
    free(UUp);
    free(UUn);

    free(lni);
    free(lpi);
    free(dbip);
    free(dbin);
    free(npi);
    free(nni);

    return;
}

