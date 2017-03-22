function res=SODW(x,a,b,w);
% function res=SODW(x,a,b,w);
%
% Computes and sums over all outer products of the columns in x and
% weights them according to w. 
%
% equivalent to:
%
% res=zeros(size(x,1));
% for i=1:n
%   res=res+w(i).*x(:,a(i))*x(:,b(i))';
% end;
%
%
% copyright 2005 by Kilian Q. Weinberger
% University of Pennsylvania
% kilianw@seas.upenn.edu
% ********************************************


if(min(w)<0) error('Weights must be non-negative in matlab version!\nPlease call "mex SODW.cpp" in the mexfunctions directory.\n');end; 
[D,N]=size(x);
B=round(2500/D^2*1000000);
res=zeros(D^2,1);
sw=sqrt(w);
for i=1:B:length(a)
  BB=min(B,length(a)-i);
  Xa=mulh(x(:,a(i:i+BB)),sw(i:i+BB));
  Xb=mulh(x(:,b(i:i+BB)),sw(i:i+BB));
  XaXb=Xa*Xb';
  res=res+vec(Xa*Xa'+Xb*Xb'-XaXb-XaXb');
 
  if(i>1)   fprintf('.');end;
end;
  
