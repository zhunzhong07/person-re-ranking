function A = PairMetricLearning(metric_learn_alg, idxa, idxb, matches, X, A0, params)
% X ... data in rows (hopefully)
% idxa ... idx in x of image A of a pair
% idxb ... idx in x of image B of a pair
% matches ... wheter the pair matches or not
% der koe
%

if (~exist('params')),
    params = struct();
end
params = SetDefaultParams(params);

if (~exist('A0')),
    A0 = eye(size(X,2));
end

[l, u] = ComputeDistanceExtremes(X, 5, 95, A0);

C = zeros(length(idxa),4);

C(:,1) = idxa;
C(:,2) = idxb;
C( matches,3)  = 1;
C(~matches,3) = -1;

C( matches,4)  = l;
C(~matches,4) =  u;

try    
    A = feval(metric_learn_alg, C, X, A0, params);
catch ME
    disp('Unable to learn mahal matrix');
    le = lasterror;
    disp(le.message);
    A = zeros(d,d);
end    
