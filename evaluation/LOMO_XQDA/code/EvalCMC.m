function cms = EvalCMC( score, galLabels, probLabels, numRanks )
%% cms = EvalCMC( score, galLabels, probLabels, numRanks )
% 
% A function for the CMC curve evaluation.
% 
% Inputs:
%     score: score matrix with rows corresponding to gallery and columns probe.
%     galLabels: a vector containing class labels of each gallery sample,
%           corresponding to rows of the score matrix.
%     probLabels: a vector containing class labels of each probe sample,
%           corresponding to columns of the score matrix.
%     numRanks: the maximal number of the matching ranks. Optional.
% 
% Outputs:
%     cms: the cumulative matching scores.
% 
% Version: 1.0
% Date: 2014-07-22
%
% Author: Shengcai Liao
% Institute: National Laboratory of Pattern Recognition,
%   Institute of Automation, Chinese Academy of Sciences
% Email: scliao@nlpr.ia.ac.cn


%% preprocess
if nargin >= 4
    numRanks = min(100, min(size(score)));
end

if ~iscolumn(galLabels)
    galLabels = galLabels';
end

if ~isrow(probLabels)
    probLabels = probLabels';
end

binaryLabels = bsxfun(@eq, galLabels, probLabels); % match / non-match labels corresponding to the score matrix

if any( all(binaryLabels == false, 1) ); % check whether all probe samples belong to the gallery
    error('This is not a closed-set identification experiment.');
end

%% get the matching rank of each probe
[~, sortedIndex] = sort(score, 'descend'); % rank the score
score(binaryLabels == false) = -Inf; % set scores of non-matches to -Inf
clear binaryLabels
[~, maxIndex] = max(score); % get the location of the maximum genuine score
[probRanks, ~] = find( bsxfun(@eq, sortedIndex, maxIndex) ); % get the matching rank of each probe, by finding the location of the matches in the sorted index
clear sortedIndex maxIndex

%% evaluate
if ~iscolumn(probRanks)
    probRanks = probRanks';
end

T = bsxfun(@le, probRanks, 1 : numRanks); % compare the probe matching ranks to the number of retrievals
cms = squeeze( mean(T) ); % average over all probes 
