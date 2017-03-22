function res=SOD(x,a,b);
% function res=SOD(x,a,b);
%
% Computes and sums over all outer products of the columns in x. 
%
% equivalent to:
%
% res=zeros(size(x,1));
% for i=1:n
%   res=res+x(:,a(i))*x(:,b(i))';
% end;
%
%
% copyright 2005 by Kilian Q. Weinberger
% University of Pennsylvania
% kilianw@seas.upenn.edu
% ********************************************


[D,N]=size(x);
B=round(2500/D^2*1000000);
res=zeros(D^2,1);
for i=1:B:length(a)
  BB=min(B,length(a)-i);
  Xa=x(:,a(i:i+BB));
  Xb=x(:,b(i:i+BB));
  XaXb=Xa*Xb';
  res=res+vec(Xa*Xa'+Xb*Xb'-XaXb-XaXb');
 
  if(i>1)   fprintf('.');end;
end;
%res=mat(res);  
  
