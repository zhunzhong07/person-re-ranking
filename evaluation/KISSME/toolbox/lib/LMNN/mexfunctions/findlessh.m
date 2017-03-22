function res=findlessh(M,thresh);

% function res=findlessh(M,thresh);
%/*
% * =============================================================
% * findlessh.c
%  
% * takes two input vectors M,thresh
% * 
% * equivalent to: find(M<repmat(thresh,size(M,1),1))
% * =============================================================
% */
%

if(size(thresh,1)~=1) thresh=thresh.';end;
res=find(M<repmat(thresh,size(M,1),1)).';


