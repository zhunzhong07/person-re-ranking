function [ ds ] = CrossValidatePairs(ds, metric_learn_algs, pairs, X, idxa, idxb, fHPairsToLabel)
%function [ds,runs]=CrossValidatePairs(ds, metric_learn_algs, pairs, X,
%idxa, idxb, fHPairsToLabel)
%
%  Leave one our cross-validation. The pairs of one fold serve for testing
%  the rest for training.
%
% Input:
%
%  ds - data struct that stores the result
%  metric_learn_algs - algorithms that are used for cross validation
%  pairs - [1xN] struct. N is the number of pairs. Fields, pairs.fold
%  pairs.match, pairs.img1, pairs.img2.
%  X - input matrix, each column is an input vector [DxN*2]. N is the
%  number of pairs. D is the feature dimensionality
%  idxa - index of image A in X [1xN]
%  idxb - index of image B in X [1xN]
%  fHPairsToLabel (opt) - function handle to generate real class labels of
%  the pairs struct.
%
% Output:
%
%  ds - struct [1xnumFolds] that contains the result, e.g. ds.kissme for
%  our method.
%
% See also CrossValidateViper
%
% copyright by Martin Koestinger (2011)
% Graz University of Technology
% contact koestinger@icg.tugraz.at
%
% For more information, see <a href="matlab: 
% web('http://lrs.icg.tugraz.at/members/koestinger')">the ICG Web site</a>.

if nargin < 7
    fHPairsToLabel = [];
end

matches = logical([pairs.match]);

un = unique([pairs.fold]);
for c=un
    trainMask = [pairs.fold] ~= c;
    testMask = [pairs.fold] == c; 
    
    %-- TRAIN --%
    for aC=1:length(metric_learn_algs)
        cHandle = metric_learn_algs{aC};
        if isempty(fHPairsToLabel)
            s = learnPairwise(cHandle,X,idxa(trainMask),idxb(trainMask),matches(trainMask));
        else
            [CX,cy] = feval(fHPairsToLabel,pairs(trainMask & matches), X);
            s = learn(cHandle,CX,cy);
        end
        if ~isempty(fieldnames(s))
            ds(c).(cHandle.type) = s;
        end
    end
    
    %-- TEST --%
    names = fieldnames(ds(c));
    for nameCounter=1:length(names)       
        ds(c).(names{nameCounter}).dist = dist(ds(c).(names{nameCounter}).learnAlgo, ... 
            ds(c).(names{nameCounter}), X,idxa(testMask),idxb(testMask));
    end
end

end