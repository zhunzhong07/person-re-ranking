function M=mat(C);

r=round(sqrt(size(C,1)));
M=reshape(C,r,r);