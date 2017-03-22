function dist=cdistM(M,x,i,j)
%CDISTM Compute the quadratic distances (x(i)-x(j))^T * M * (x(i)-x(j))
%between pairs of samples
%
% [ Arguments ]
%   - x:       the sample matrices
%   - M:       the resulting metric matrix
%   - i,j:     index of respective samples
%
%   [ Example ]
%
%         M = rand(10, 10);
%         dist = slmetric_pw(M, x, i, j);
%

dist = zeros(1,length(i));
for c=1:length(i)
    dist(c) = (x(:,i(c)) - x(:,j(c)))' ...
        * M * (x(:,i(c)) - x(:,j(c)));
end