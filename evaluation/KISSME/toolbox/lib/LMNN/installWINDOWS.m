setpaths
cd mexfunctions
fprintf('Compiling all mex functions ...\n');
mex SOD.c -lmwblas  -lmwlapack
mex SODW.c -lmwblas  -lmwlapack
mex addchv.c -lmwblas  -lmwlapack
mex addh.c -lmwblas  -lmwlapack
mex addv.c -lmwblas  -lmwlapack
mex cdist.c -lmwblas  -lmwlapack
mex count.c -lmwblas  -lmwlapack
mex findimps3Dac.c -lmwblas  -lmwlapack
mex findlessh.c -lmwblas  -lmwlapack 
mex mink.c -lmwblas  -lmwlapack
mex mulh.c -lmwblas  -lmwlapack
mex sd.c -lmwblas  -lmwlapack
mex sumiflessh2.c -lmwblas  -lmwlapack
mex sumiflessv2.c -lmwblas  -lmwlapack 
%%mex distance.c  %% de-comment this line for maximum speed on 64 processors
fprintf('done\n\n');
cd ..

fprintf('Please note that I did NOT compile the function distance.c (in mexfunctions). \n');
fprintf('To guarantee maximal compatibility, we will use distance.m for now.\n');
fprintf('In case you are interested in maximum speed, try to compile distance.c\n');
fprintf('in the mexfunctions directory.\n(It will probably not work on windows computers - unless you link it with BLAS)\n');
fprintf('\nBTW, for maximum speed, I recommend to apply PCA to the data before running lmnn.\n');
fprintf('[xTrpca,u]=applypca(xTr);\n');
fprintf('(But do not forget to also transform the test vectors: xTepca=u''*xTe.)\n\n');
fprintf('LMNN works fast with up to around 100-200 dimensions.\n');
fprintf('After PCA you can easily crop the input to the top (eg 100) principal components:\n');
fprintf('[L,Details]=lmnn(xTrpca(1:100,:),yTr);\n\n');
fprintf('Last thing:\nIf you want to map into a lower dimensional space, initialize LMNN with a rectangular matrix.\nFor exmaple use:\n')
fprintf('[L,Details]=lmnn(xTrpca(1:100,:),yTr,3,eye(10,100));\n');
fprintf('(This creates an L matrix that is 10x100 and hence maps the output into 10 dimensions.)\n\n')



