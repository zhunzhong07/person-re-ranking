function [sigma] = validateCovMatrix(sig)

% [sigma] = validateCovMatrix(sig)
%
% -- INPUT --
% sig:      sample covariance matrix
%
% -- OUTPUT --
% sigma:    positive-definite covariance matrix
%

EPS = 10^-6;
ZERO = 10^-10;

sigma = sig;
[r err] = cholcov(sigma, 0);

if (err ~= 0)
    % the covariance matrix is not positive definite!
    [v d] = eig(sigma);

    % set any of the eigenvalues that are <= 0 to some small positive value
    for n = 1:size(d,1)
        if (d(n, n) <= ZERO)
            d(n, n) = EPS;
        end
    end
    % recompose the covariance matrix, now it should be positive definite.
    sigma = v*d*v';

    [r err] = cholcov(sigma, 0);
    if (err ~= 0)
        disp('ERROR!');
    end
end