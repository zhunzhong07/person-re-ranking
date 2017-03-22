function [tpr,fpr,thresh] = icg_roc(tp,confs)
% ICG_ROC computes ROC measures (tpr,fpr)
%
% Input:
%   tp      - [m x n] matrix of zero-one labels. one row per class.
%   confs   - [m x n] matrix of classifier scores. one row per class.
%
% Output:
%   tpr   - true positive rate in interval [0,1], [m x n+1] matrix 
%   fpr   - false positive rate in interval [0,1], [m x n+1] matrix 
%   confs - thresholds over interval
% 
% Example:
%   icg_plotroc([ones(1,10) zeros(1,10)],20:-1:1);
%   produces a perfect step curve
%
% copyright by Martin Koestinger (2011)
% Graz University of Technology
% contact koestinger@icg.tugraz.at
%
% For more information, see <a href="matlab: 
% web('http://lrs.icg.tugraz.at/members/koestinger')">the ICG Web site</a>.
%

m = size(tp,1);
n = size(tp,2);

tpr = zeros(m,n+1);
fpr = zeros(m,n+1);
thresh = zeros(m,n);

for c=1:m
    [tpr(c,:),fpr(c,:),thresh(c,:)] = icg_roc_one_class(tp(c,:),confs(c,:));
end

end

function [tpr,fpr,confs] = icg_roc_one_class(tp,confs)

[confs,idx] = sort(confs,'descend');
tps = tp(idx);

% calc recall/precision
tpr = zeros(1,numel(tps));
fpr = zeros(1,numel(tps));
tp = 0;
fp = 0;
tn = sum(tps < 0.5);
fn = numel(tps) - tn;
for i=1:numel(tps)
    if tps(i) > 0.5
        tp = tp + 1;
        fn = fn - 1;
    else
        fp = fp + 1;
        tn = tn - 1;
    end
    tpr(i) = tp/(tp+fn);
    fpr(i) = fp/(fp+tn);
end

fpr = [0 fpr];
tpr = [0 tpr];

end