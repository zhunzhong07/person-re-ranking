function [v,i]=mink(D,k);
% function [v,i]=mink(D,k);
%
% Finds the k smallest entries in the rows of D
% 
% equivalent to:
%
% [v,i]=sort(D);
% v=v(1:k,:);
% i=i(1:k,:);
%
% A significant speedup is only apparent when k is small and D
% large.  
% Useful, for example, to find the k nearest neighbors in a
% distance matrix. 
%
% copyright 2005 by Kilian Q. Weinberger
% University of Pennsylvania
% kilianw@seas.upenn.edu
% ********************************************

[v,i]=sort(D);
v=v(1:k,:);
i=i(1:k,:);
