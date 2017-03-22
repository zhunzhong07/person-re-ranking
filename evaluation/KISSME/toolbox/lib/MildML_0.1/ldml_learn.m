function [ L b info ] = ldml_learn( X, Y, k, it, verbose, A0 )
% [ L b info ] = ldml_learn( X, Y, k, it, verbose, A0 )
%
%  * Mandatory inputs:
% X : (m x d) data matrix (m data points with d dimensions)
% Y : (m x 1) class labels
%
%  * To learn a kernelized metric, provide the kernel Gram matrix instead of the data matrix X.
%
%  * Optional inputs:
% k : number of dimensions of projection space (default=d)
% it : number of iterations (default=100)
% verbose : boolean for verbosity (default=false)
% A0 : parameter initialization vector (default=random)
%
%  * Outputs:
% L : (d x k) projection matrix
% b : (scalar) distance threshold as learnt by LDML (may or may not be optimal depending on application)
% info : struct with information about the optimization, with following fields
%     .fA : sequence of function values during gradient descent
%     .it : effective number of iterations
%     .A  : parameter vector that you can re-use for initialization (cf "A0" in input section)
%
% Matthieu Guillaumin, INRIA.

[ n d ] = size(X);
m = numel(Y);
I=(1:n);

if n ~= m,
   error('ldml','Second input must have a number of elements equal to the number of rows of the first input');
end

YY=sparse(1:n,Y(:),true);
c=size(YY,2);

% Set default values
opt=2;
if nargin<opt+1,    k=d;                    end
if nargin<opt+2,    it=100;                 end
if nargin<opt+3,    verbose=false;          end

if verbose, fprintf('Learning (%d x %d) LDML with %d instances in %d bags with %d labels\n',d,k,n,m,c); end

% Set initial projection as a random orthogonal matrix. TODO: several random initialization.
if nargin<opt+4,
    A0 = orth(rand(d,k));
    A0 = A0(:);
    A0(end+1)=rand;
end

H=vec(hist_count(I));
if m>size(H,1),
    H(size(H,1)+1:m)=0;
end

% Perform gradient descent
[ A fA it ] = minimize( A0, 'mildml_fg', it, verbose, double(X), double(I)-1, double(sparse(YY)), double(H), n, d, k, m, c);
info.A=A;info.fA=fA;info.it=it;

% Get projection matrix and bias from learned parameter vector
b = A(end);
L = reshape(A(1:end-1),d,k);

