function dist=distance(X,x);
% dist=distance(X,x)
%
% computes the pairwise squared distance matrix between any column vectors in X and
% in x
%
% INPUT:
%
% X     dxN matrix consisting of N column vectors
% x     dxn matrix consisting of n column vectors
%
% OUTPUT:
%
% dist  Nxn matrix 
%
% Example:
% Dist=distance(X,X);
% is equivalent to
% Dist=distance(X);
%
[D,N] = size(X);


  
try 
 if(nargin>=2)
    % PAIRWISE DISTANCES
  [d,n] = size(x);
  if(D~=d)
   error('Both sets of vectors must have same dimensionality!\n');
  end;
  X2 = sum(X.^2,1);
  x2 = sum(x.^2,1);
  if(exist('addchv') & isreal(X))
   dist=addchv(X.'*x,-2,x2,X2); 
  else
   dist = repmat(x2,N,1)+repmat(X2.',1,n)-2*X.'*x; 
  end;
  
 else
  [D,N] = size(X);
  if(exist('addchv') & isreal(X))
   X2 = sum(X.^2,1);
   dist=addchv(X.'*X,-2,X2,X2);
  else
   X2 = repmat(sum(X.^2,1),N,1);
   dist = X2+X2.'-2*X.'*X;   
%   fprintf('Please install addv and addh.\n');
  end;
 end;
 
catch
  if(nargin==1)
   dist=distanceBlock(X);
  else    
   dist=distanceBlock(X,x);
  end;
end;



function dist=distanceBlock(X,x);
% dist=distance(X,x)
%
% computes the pairwise squared distance matrix between any column vectors in X and
% in x
%
% INPUT:
%
% X     dxN matrix consisting of N column vectors
% x     dxn matrix consisting of n column vectors
%
% OUTPUT:
%
% dist  Nxn matrix 
%
% Example:
% Dist=distance(X,X);
% is equivalent to
% Dist=distance(X);
%

  [D,N] = size(X);  
if(nargin==1)
  dist=zeros(N);
else
  dist=zeros(N,size(x,2));
end;

  B=round(0.1*N);
  fprintf('Blocksize:%i\n',B);
  dist=zeros(N);
  for i=1:B:N
    bi=min(B,N-i);
    for j=1:B:N
      bj=min(B,N-j);
      dist([i,j]);
      if(nargin>1)
       dist(i:i+bi,j:j+bj)=distance(X(:,i:i+bi),x(:,j:j+bj));
      else
       dist(i:i+bi,j:j+bj)=distance(X(:,i:i+bi),X(:,j:j+bj));
      end;      
      dist(j:j+bj,i:i+bi)=dist(i:i+bi,j:j+bj).';    
     end;
  end;
  fprintf('\n');


