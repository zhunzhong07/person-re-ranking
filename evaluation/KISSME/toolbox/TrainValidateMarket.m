function [ ds ] = TrainValidateMarket(ds, learn_algs, X, X_test, X_query, idxa, idxb, flag)
%   
% Input:
%
%  ds - data struct that stores the result
%  learn_algs - algorithms that are used for cross validation
%  X - input matrix, each column is an input vector [DxN*2]. N is the
%  number of pairs.
%  idxa - index of image A in X [1xN]
%  idxb - index of image B in X [1xN]
%
% Output:
%
%  ds - contains the result

c = 1;
clc;
% train 
for aC=1:length(learn_algs)
    cHandle = learn_algs{aC};
    fprintf('    training %s ',upper(cHandle.type));
    if aC > 3
        s = learnPairwise(cHandle,X,idxa(1:10:end),idxb(1:10:end),logical(flag(1:10:end)));
    else
        s = learnPairwise(cHandle,X,idxa,idxb,logical(flag));
    end
    if ~isempty(fieldnames(s))
        fprintf('... done in %.4fs\n',s.t);
        ds(c).(cHandle.type) = s;
    else
        fprintf('... not available');
    end
end

% test
testID = importdata('data\testID.mat'); % identity label of all testing bboxes
testCAM = importdata('data\testCAM.mat'); % camera label of all testing bboxes
queryID = importdata('data\queryID.mat'); % identity label of all query bboxes
queryCAM = importdata('data\queryCAM.mat'); % camera label of all query bboxes
names = fieldnames(ds(c));
for nameCounter=1:length(names)       
    fprintf('    evaluating %s ',upper(names{nameCounter}));
    [ds(c).(names{nameCounter}).mAP, ds(c).(names{nameCounter}).cmc] = ...
        calcmAP(ds(c).(names{nameCounter}).M, X_test, X_query, testID, testCAM, queryID, queryCAM);
    fprintf('... done \n');
end

end