function res=cdist(x,i,j);
% function res=cdist(x,i,j);
%
% Computes the L2-squared distances between all the columns of x
% indexed by i and j and stores them in one vector.
%
% res=sum((x(:,i)-x(:,j)).^2);
%
%
% copyright 2005 by Kilian Q. Weinberger
% University of Pennsylvania
% kilianw@seas.upenn.edu
% ********************************************

B=10;
res=zeros(1,length(i));
for k=1:B:length(i)
 ind=k:min(k+B-1,length(i));
 res(ind)=sum((x(:,i(ind))-x(:,j(ind))).^2);  
end;  
