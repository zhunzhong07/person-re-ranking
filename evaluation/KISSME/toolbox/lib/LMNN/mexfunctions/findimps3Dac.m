function ind=findimps3D(X1,X2,t1,t2);
% function ind=findimps3D(X1,X2,t1,t2);
%
% Takes two sets of vectors as input with accompaning thresholds. 
% Finds all indices (i,j) of columns in X1 and X2 such the L2 squared
% distance between vectors X1(:,i) and X(:,j) is greater-equal than
% t1(i) or t2(j).  
%
% equivalent to: 
%
%      Dist=distance(X1.'*X2);  % computes L2-distance matrix
%      imp1=find(Dist<repmat(t1,N1,1))';
%      imp2=find(Dist<repmat(t2,N1,1))';
%      [a,b]=ind2sub([N1,N2],[imp1;imp2]);
%      ind=[b;a];
%      
%
%
% copyright 2005 by Kilian Q. Weinberger
% University of Pennsylvania
% kilianw@seas.upenn.edu
% ********************************************

N1=size(X1,2);
N2=size(X2,2);
if(size(t1,1)==1) t1=t1.';end;
if(size(t2,2)==1) t2=t2.';end;


      Dist=distance(X1,X2);  % computes L2-distance matrix
      imp1=find(Dist<repmat(t2,N1,1))';
      imp2=find(Dist<repmat(t1,1,N2))';
      [a,b]=ind2sub([N1,N2],[imp1 imp2]);
ind=[a;b];
ind=unique(ind','rows')';
