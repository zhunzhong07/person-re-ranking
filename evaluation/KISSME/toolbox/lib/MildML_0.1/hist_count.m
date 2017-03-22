function [ Y, Z ] = hist_count( X, d, Z )
%HIST_COUNT 
%   Counts the occurrences of values in matrix X along dimension d with
%   bins given by Z. X and Z should contain integers only.
%

if nargin<2,
    X=X(:);
    d=1;
end
if nargin<3,
    m = full(min(X(:)));
    M = full(max(X(:)));
    Z = m:M;
end
p = [ d setdiff(1:ndims(X),d) ];
X = permute( X, p );
D = size(X);
D(1) = length(Z);
Y = zeros(D);
for k=1:length(Z),
    if Z(k)==0 && issparse(X),
        Y(k,:) = size(X,1)*prod(D(2:end))-sum(X~=0,1);
    else
        Y(k,:) = reshape(sum(X==Z(k),1),[],1);
    end
end
Y = ipermute( Y, p );
