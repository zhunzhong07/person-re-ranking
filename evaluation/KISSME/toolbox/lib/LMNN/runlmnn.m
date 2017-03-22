function [enerr,knnerrL,knnerrI]=runlmnn(xTr,yTr,xTe,yTe,varargin);
%  function [enerr,knnerrL,knnerrI]=runlmnn(xTr,yTr,xTe,yTe,parameters);
%
%  Runs LMNN on the training data and estimates the classification
%  test and train error. 
%
% Input: 
% 
% xTr : (DxN) N input column vectors (training data)
% yTr : (1xN) N input labels (training)
% xTe : (DxM) M input column vectors (testing data)  
% yTe : (1xM) M input labels (testing)
%  
% See "help lmnn" for parameter options. 
%
% copyright by Kilian Q. Weinberger, 2006
%

pars.quiet=1;
pars=extractpars(varargin,pars);
  
fprintf('Running LMNN with k=3 starting from identity matrix ...\n');
[L,Det]=lmnn(xTr,yTr,pars);
fprintf('Energy classification ...\n');
enerr=energyclassify(L,xTr,yTr,xTe,yTe,3);
fprintf('KNN classification ...\n');
knnerrL=knnclassify(L,xTr,yTr,xTe,yTe,3);
knnerrI=knnclassify(eye(size(L)),xTr,yTr,xTe,yTe,3);

clc;
fprintf('Overview:\n');
fprintf('Final objective value: %i\n',Det.obj(end));
fprintf('3-NN Euclidean training error: %2.2f\n',knnerrI(1)*100);
fprintf('3-NN Euclidean testing error: %2.2f\n',knnerrI(2)*100);
fprintf('3-NN Malhalanobis training error: %2.2f\n',knnerrL(1)*100);
fprintf('3-NN Malhalanobis testing error: %2.2f\n',knnerrL(2)*100);
fprintf('Energy classification error: %2.2f\n',enerr*100);
fprintf('Training time: %2.2fs\n\n',Det.time);
