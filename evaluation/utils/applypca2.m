function [ux,u,m] = applypca2(X)
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

% [u,v]=pca(X);
[d,N]  = size(X);

mm = mean(X,2);
X = X - mm*ones(1,N); % remove mean from data

cc = cov(X,1); % compute covariance 
[cvv,cdd] = eig(cc); % compute eignvectors
[zz,ii] = sort(diag(-cdd)); % sort according to eigenvalues
evects = cvv(:,ii); % pick leading eigenvectors
u = X*evects;


m=mean(X,2);
ux=u'*(X-repmat(m,1,size(X,2)));

