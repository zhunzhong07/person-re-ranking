function dist = MahDist(M, Xg, Xp)
%% function dist = MahDist(M, Xg, Xp)
% Mahalanobis distance
%
% Input:
%   <M>: the metric kernel
%   <Xg>: features of the gallery samples. Size: [n, d]
%   [Xp]: features of the probe samples. Optional. Size: [m, d]
%
%   Note: MahDist(M, Xg) is the same as MahDist(M, Xg, Xg).
%
% Output:
%   dist: the computed distance matrix between Xg and Xp
%
% Reference:
%   Shengcai Liao, Yang Hu, Xiangyu Zhu, and Stan Z. Li. Person
%   re-identification by local maximal occurrence representation and metric
%   learning. In IEEE Conference on Computer Vision and Pattern Recognition, 2015.
% 
% Version: 1.0
% Date: 2014-05-15
%
% Author: Shengcai Liao
% Institute: National Laboratory of Pattern Recognition,
%   Institute of Automation, Chinese Academy of Sciences
% Email: scliao@nlpr.ia.ac.cn


if nargin == 2
    D = Xg * M * Xg';
    u = diag(D);
    dist = bsxfun(@plus, u, u') - 2 * D;
else
    u = sum( (Xg * M) .* Xg, 2);
    v = sum( (Xp * M) .* Xp, 2);
    dist = bsxfun(@plus, u, v') - 2 * Xg * M * Xp';
end
