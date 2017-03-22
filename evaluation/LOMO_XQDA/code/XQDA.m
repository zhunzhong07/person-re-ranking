function [W, M, inCov, exCov] = XQDA(galX, probX, galLabels, probLabels, options)
%% function [W, M, inCov, exCov] = XQDA(galX, probX, galLabels, probLabels, options)
% Cross-view Quadratic Discriminant Analysis for subspace and metric
% learning
%
% Input:
%   <galX>: features of gallery samples. Size: [n, d]
%   <probX>: features of probe samples. Size: [m, d]
%   <galLabels>: class labels of the gallery samples
%   <probLabels>: class labels of the probe samples
%   [options]: optional parameters. A structure containing any of the
%   following fields:
%       lambda: the regularizer. Default: 0.001
%       qdaDims: the number of dimensions to be preserved in the learned
%       subspace. Negative values indicate automatic dimension selection by
%       perserving latent values larger than 1. Default: -1.
%       verbose: whether to print the learning details. Default: false
%
% Output:
%   W: the subspace projection matrix. Size: [d, r], where r is the
%   subspace dimension.
%   M: the learned metric kernel. Size: [r,r]
%   inCov: covariance matrix of the intra-personal difference class. Size:
%   [r,r]
%   exCov: covriance matrix of the extra-personal difference class. Size:
%   [r,r]
%
%   With W, inCov, and exCov, we can quickly learn another metric of different dimensions:
%       W2 = W(:, 1:r2);
%       M2 = inv(inCov(1:r2, 1:r2)) - inv(exCov(1:r2, 1:r2));
% 
% Example:
%     Please see Demo_XQDA.m.
%
% Reference:
%   Shengcai Liao, Yang Hu, Xiangyu Zhu, and Stan Z. Li. Person
%   re-identification by local maximal occurrence representation and metric
%   learning. In IEEE Conference on Computer Vision and Pattern Recognition, 2015.
% 
% Version: 1.0
% Date: 2015-04-30
%
% Author: Shengcai Liao
% Institute: National Laboratory of Pattern Recognition,
%   Institute of Automation, Chinese Academy of Sciences
% Email: scliao@nlpr.ia.ac.cn


lambda = 0.001;
qdaDims = -1;
verbose = false;

if nargin >= 5 && ~isempty(options)
    if isfield(options,'lambda') && ~isempty(options.lambda) && isscalar(options.lambda) && isnumeric(options.lambda)
        lambda = options.lambda;
    end
    if isfield(options,'qdaDims') && ~isempty(options.qdaDims) && isscalar(options.qdaDims) && isnumeric(options.qdaDims) && options.qdaDims > 0
        qdaDims = options.qdaDims;
    end
    if isfield(options,'verbose') && ~isempty(options.verbose) && isscalar(options.verbose) && islogical(options.verbose)
        verbose = options.verbose;
    end
end

if verbose == true
    fprintf('options.lambda = %g.\n', lambda);
    fprintf('options.qdaDims = %d.\n', qdaDims);
    fprintf('options.verbose = %d.\n', verbose);
end

[numGals, d] = size(galX); % n
numProbs = size(probX, 1); % m

% If d > numGals + numProbs, it is not necessary to apply XQDA on the high dimensional space. 
% In this case we can apply XQDA on QR decomposed space, achieving the same performance but much faster.
if d > numGals + numProbs
    if verbose == true
        fprintf('\nStart to apply QR decomposition.\n');
    end
    
    t0 = tic;
    [W, X] = qr([galX', probX'], 0); % [d, n]
    galX = X(:, 1:numGals)';
    probX = X(:, numGals+1:end)';
    d = size(X,1);
    clear X;
    
    if verbose == true
        fprintf('QR decomposition time: %.3g seconds.\n', toc(t0));
    end
end


labels = unique([galLabels; probLabels]);
c = length(labels);

if verbose == true
    fprintf('#Classes: %d\n', c);
    fprintf('Compute intra/extra-class covariance matrix...');
end
    
t0 = tic;

galW = zeros(numGals, 1);
galClassSum = zeros(c, d);
probW = zeros(numProbs, 1);
probClassSum = zeros(c, d);
ni = 0;

for k = 1 : c
    galIndex = find(galLabels == labels(k));
    nk = length(galIndex);
    galClassSum(k, :) = sum( galX(galIndex, :), 1 );
    
    probIndex = find(probLabels == labels(k));
    mk = length(probIndex);
    probClassSum(k, :) = sum( probX(probIndex, :), 1 );
    
    ni = ni + nk * mk;
    galW(galIndex) = sqrt(mk);
    probW(probIndex) = sqrt(nk);
end

galSum = sum(galClassSum, 1);
probSum = sum(probClassSum, 1);
galCov = galX' * galX;
probCov = probX' * probX;

galX = bsxfun( @times, galW, galX );
probX = bsxfun( @times, probW, probX );
inCov = galX' * galX + probX' * probX - galClassSum' * probClassSum - probClassSum' * galClassSum;
exCov = numProbs * galCov + numGals * probCov - galSum' * probSum - probSum' * galSum - inCov;

ne = numGals * numProbs - ni;
inCov = inCov / ni;
exCov = exCov / ne;

inCov = inCov + lambda * eye(d);

if verbose == true
    fprintf(' %.3g seconds.\n', toc(t0));
    fprintf('#Intra: %d, #Extra: %d\n', ni, ne);
    fprintf('Compute eigen vectors...');
end


t0 = tic;
[V, S] = svd(inCov \ exCov);

if verbose == true
    fprintf(' %.3g seconds.\n', toc(t0));
end

latent = diag(S);
[latent, index] = sort(latent, 'descend');
energy = sum(latent);
minv = latent(end);

r = sum(latent > 1);
energy = sum(latent(1:r)) / energy;

if qdaDims > r
    qdaDims = r;
end

if qdaDims <= 0
    qdaDims = max(1,r);
end

if verbose == true
    fprintf('Energy remained: %f, max: %f, min: %f, all min: %f, #opt-dim: %d, qda-dim: %d.\n', energy, latent(1), latent(max(1,r)), minv, r, qdaDims);
end

V = V(:, index(1:qdaDims));
if ~exist('W', 'var');
    W = V;
else
    W = W * V;
end

if verbose == true
    fprintf('Compute kernel matrix...');
end

t0 = tic;

inCov = V' * inCov * V;
exCov = V' * exCov * V;
M = inv(inCov) - inv(exCov);

if verbose == true
    fprintf(' %.3g seconds.\n\n', toc(t0));
end
