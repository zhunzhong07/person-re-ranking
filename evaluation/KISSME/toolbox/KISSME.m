function [M_kissme, M_mahal, M_eu] = KISSME(learn_algs, X, X_test, X_query, idxa, idxb, flag)
%   
% Input:
%
%  learn_algs - algorithms that are used for cross validation
%  X - input matrix, each column is an input vector [DxN*2]. N is the
%  number of pairs.
%  idxa - index of image A in X [1xN]
%  idxb - index of image B in X [1xN]
%
% Output:
%
%  M_kissme, M_mahal, M_eu - contains the learned distance metrics

% train 
cHandle = learn_algs{1};
s = learnPairwise(cHandle,X,idxa(1:10:end),idxb(1:10:end),logical(flag(1:10:end)));
M_kissme = s.M;

cHandle = learn_algs{2};
s = learnPairwise(cHandle,X,idxa(1:10:end),idxb(1:10:end),logical(flag(1:10:end)));
M_mahal = s.M;

cHandle = learn_algs{3};
s = learnPairwise(cHandle,X,idxa(1:10:end),idxb(1:10:end),logical(flag(1:10:end)));
M_eu = s.M;

end