function [acc, pred] = CrossValidateKNN(y, X, tCL, k, knn_size);
% [acc, pred] = CrossValidateKNN(y, X, tCL, k, knn_size);
% 
% Cross-validation for evaluating the k-nearest neighbor classifier with
% a learned metric.  Performs k-fold cross validation, training on the
% training fold and evaluating on the test fold
%
% y: (n x 1) true labels
%
% X: (n x m) data matrix
%
% tCL: Metric learning algorithm that takes in true labels as first
% argument, and data as a second
%
% k: Number of cross-validated folds
%
% knn_size: size of nearest neighbor window
%
% Returns 
% acc: cross-validated accuracy
% pred: predictions on test set for each row in X

[n,m] = size(X);
if (n ~= length(y)),
   disp('ERROR: num rows of X must equal length of y');
   return;
end

%permute the rows of X and y
rp = randperm(n);
y = y(rp);
X = X(rp, :);

pred = zeros(n,1);
for (i=1:k),
   test_start = ceil(n/k * (i-1)) + 1;
   test_end = ceil(n/k * i);

   yt = [];
   Xt = zeros(0, m);
   if (i > 1);
       yt = y(1:test_start-1);
       Xt = X(1:test_start-1,:);
   end
   if (i < k),
       yt = [yt; y(test_end+1:length(y))];
       Xt = [Xt; X(test_end+1:length(y), :)];
   end
   
   nt = length(yt);
   yt = yt(1:nt);
   Xt = Xt(1:nt, :);

   %train model
   M = feval(tCL, yt, Xt);
   
   %evaluate model 
   XT = X(test_start:test_end, :);
   yT =  y(test_start:test_end);
   pred(test_start:test_end) = KNN(yt, Xt, sqrtm(M), knn_size, XT); 
end
acc = sum(pred==y)/n;
