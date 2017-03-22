function [ f G ] = mildml_fg(A, X, I, Y, H, n, d, k, m, c)
% [ f G ] = mildml_fg( A, X, I, Y, H, n, d, k, m, c)
%
% inputs:
% A : vector representing MildML parameters (a (d x k) matrix and a bias)
% X : (n x d) data matrix with m data points with d dimensions
% I : (n x 1) bagging of data (values 1 to m)
% Y : (m x c) bag class label (logical, sparse)
% H : (m x 1) bag sizes
% n : number of rows of X
% d : number of columns of X
% k : number of dimensions of projection space (default=d)
% m : number of bags
% c : number of classes
%
% outputs:
% f : MildML objective evaluation at A (negative log-likelihood)
% G : gradient of f with respect to A
%
% note:
% Use this function with minimize or fminunc
%
% Copyright (C) 2009 - 2010 by Matthieu Guillaumin.


% Get projection matrix and bias from parameter vector
b = A(end);
L = reshape(A(1:end-1),d,k);

% Project data according to current projection. O(ndk)
Z=(X*L)';

% Evaluate log-likelihood and also compute pre-gradient U and bias gradient db. O(n²k)
[ f U db ] = mildml_evalg_sparse(Z,I,Y',H,b,n,k,m,c);

% Finish gradient computation. O(dnk)
G = 4*(U*X)';

% Reshape and add bias gradient
G = [ G(:); db ];

