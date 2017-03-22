function Mv=mulv(M,v);

% function Mv=mulv(M,v);
%
% Multiplies each column of a matrix with a vector element-wise.
%
% Input:
% 
% Matrix M (mxn)
% vector v (mx1)
%
% Output:
% Mv=M.*repmat(v,1,size(M,2));
%

if(size(v,2)~=1) v=v.';end;
Mv=M.*repmat(v,1,size(M,2));
