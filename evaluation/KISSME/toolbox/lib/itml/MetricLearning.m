function A = MetricLearning(metric_learn_alg, y, X, A0, params);
% A = MetricLearning(metric_learn_alg, X, C, A0, params);
%
% Wrapper script that takes in a set of data points and their true labels
% computes upper and lower bounds for these constraints, and then invokes
% metric learning



if (~exist('params')),
    params = struct();
end
params = SetDefaultParams(params);

if (~exist('A0')),
    A0 = eye(size(X,2));
end

% Determine similarity/dissimilarity constraints from the true labels
[l, u] = ComputeDistanceExtremes(X, 5, 95, A0);

% Choose the number of constraints to be const_factors times the number of
% distinct pairs of classes
k = length(unique(y));
num_constraints = params.const_factor * (k * (k-1));
C = GetConstraints(y, num_constraints, l, u);

try    
    A = feval(metric_learn_alg, C, X, A0, params);
catch   
    disp('Unable to learn mahal matrix');
    le = lasterror;
    disp(le.message);
    A = zeros(d,d);
end    
