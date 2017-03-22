function A = ItmlAlg(C, X, A_0, params)
% A = ItmlAlg(C, X, A_0, params)
%
% Core ITML learning algorithm
% 
% C: 4 column matrix
%      column 1, 2: index of constrained points.  Indexes between 1 and n
%      column 3: 1 if points are similar, -1 if dissimilar
%      column 4: right-hand side (lower or upper bound, depending on 
%                   whether points are similar or dissimilar)
%
% X: (n x m) data matrix - each row corresponds to a single instance
%
% A_0: (m x m) regularization matrix
%
% params: algorithm parameters - see see SetDefaultParams for defaults
%           params.thresh: algorithm convergence threshold
%           params.gamma: gamma value for slack variables
%           params.max_iters: maximum number of iterations
%
% returns A: learned Mahalanobis matrix

tol = params.thresh;
gamma = params.gamma;
max_iters = params.max_iters;

% check to make sure that no 2 constrained vectors are identical
valid = ones(size(C,1),1);
for (i=1:size(C,1)),
   i1 = C(i,1);
   i2 = C(i,2);
   v = X(i1,:)' - X(i2,:)'; 
   if (norm(v) < 10e-10),
      valid(i) = 0;
   end
end
C = C(valid>0,:);

i = 1;
iter = 0;
c = size(C, 1);
lambda = zeros(c,1);
bhat = C(:,4);
lambdaold = zeros(c,1);
conv = Inf;
A = A_0;

while (true),
    i1 = C(i,1);
    i2 = C(i,2);
    v = X(i1,:)' - X(i2,:)';
    wtw = v'*A*v;

    if (abs(bhat(i)) < 10e-10),
        error('bhat should never be 0!');
    end
    if (inf == gamma),
        gamma_proj = 1;
    else
        gamma_proj = gamma/(gamma+1);
    end
    
    if C(i,3) == 1
        alpha = min(lambda(i),gamma_proj*(1/(wtw) - 1/bhat(i)));
        lambda(i) = lambda(i) - alpha;
        beta = alpha/(1 - alpha*wtw);        
        bhat(i) = inv((1 / bhat(i)) + (alpha / gamma));        
    elseif C(i,3) == -1
        alpha = min(lambda(i),gamma_proj*(1/bhat(i) - 1/(wtw)));
        lambda(i) = lambda(i) - alpha;
        beta = -1*alpha/(1 + alpha*wtw); 
        bhat(i) = inv((1 / bhat(i)) - (alpha / gamma));
    end

    A = A + (beta*A*v*v'*A);

    if i == c
        normsum = norm(lambda) + norm(lambdaold);
        if (normsum == 0)
            break;
        else
            conv = norm(lambdaold - lambda, 1) / normsum;
            if (conv < tol || iter > max_iters),
                break;
            end
        end
        lambdaold = lambda;
    end
    i = mod(i,c) + 1;

    iter = iter + 1;
    if (mod(iter, 5000) == 0),       
       disp(sprintf('itml iter: %d, conv = %f', iter, conv));
    end
end
disp(sprintf('itml converged to tol: %f, iter: %d', conv, iter));



