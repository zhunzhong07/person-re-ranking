function [ux,u,m] = applypca(X)
% [ux,u,m] = applypca(X)
%
% finds principal components of 
%
% input: 
%  x  input data (each column is an input vector)
%
% output:
%  ux  data projected onto pca (1st row=leading principal component)
%  u   the orthogonal matrix with all principal components
%  m   mean of the data
%
% You can recover the original data with
% 
% xoriginal=u*ux+repmat(m,1,size(ux,2));
%
% See also pca
%
% copyright by Kilian Q. Weinberger, 2006

[u,v]=pca(X);
m=mean(X,2);
ux=u'*(X-repmat(m,1,size(X,2)));

