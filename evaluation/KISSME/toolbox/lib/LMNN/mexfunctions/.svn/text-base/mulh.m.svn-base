function Mv=mulh(M,v);

% function Mv=mulh(M,v);
%
% Multiplies each row of a matrix with a vector element-wise.
%
% Input:
% 
% Matrix M (mxn)
% vector v (1xm)
%
% Output:
% Mv=M.*repmat(v,1,size(M,2));
%


 if(size(v,1)~=1) v=v.';end;
 Mv=M.*repmat(v,size(M,1),1);
