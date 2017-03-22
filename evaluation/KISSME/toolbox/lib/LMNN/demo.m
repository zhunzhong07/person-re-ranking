
load('data/bal2.mat');
[L,Det]=lmnn(xTr,yTr,'quiet',1);
enerr=energyclassify(L,xTr,yTr,xTe,yTe,3);
knnerrL=knnclassify(L,xTr,yTr,xTe,yTe,3);
knnerrI=knnclassify(eye(size(L)),xTr,yTr,xTe,yTe,3);

clc;
fprintf('Bal data set:\n');
fprintf('3-NN Euclidean training error: %2.2f\n',knnerrI(1)*100);
fprintf('3-NN Euclidean testing error: %2.2f\n',knnerrI(2)*100);
fprintf('3-NN Malhalanobis training error: %2.2f\n',knnerrL(1)*100);
fprintf('3-NN Malhalanobis testing error: %2.2f\n',knnerrL(2)*100);
fprintf('Energy classification error: %2.2f\n',enerr*100);
fprintf('Training time: %2.2fs\n (As a reality check: My desktop needs 20.53s)\n\n',Det.time);
