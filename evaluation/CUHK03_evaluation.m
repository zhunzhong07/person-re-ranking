clc;clear all;close all;
%**************************************************%
% This code implements IDE baseline for the CUHK03 %
% dataset under the new traning/testing protocol.  %
% Please modify the path to your own folder.       %
% We use the mAP and rank-1 rate as evaluation     %
%**************************************************%
% if you find this code useful in your research, please kindly cite our
% paper as,
% Zhun Zhong, Liang Zheng, Donglin Cao, Shaozi Li,
% Re-ranking Person Re-identification with k-reciprocal Encoding, CVPR, 2017.

% Please download CUHK03 dataset and unzip it in the "dataset/CUHK03" folder.
addpath(genpath('LOMO_XQDA/'));
run('KISSME/toolbox/init.m');
addpath(genpath('utils/'));

%% re-ranking setting
k1 = 20;
k2 = 6;
lambda = 0.3;

%% network name
netname = 'ResNet_50'; % network: CaffeNet  or ResNet_50 googlenet

detected_or_labeled = 'detected'; % detected/labeled
load(['data/CUHK03/cuhk03_new_protocol_config_' detected_or_labeled '.mat']);

%% load feature Deep feature
feat = importdata(['feat/CUHK03/' netname '_IDE_' detected_or_labeled '.mat']);
feat = double(feat);

%% load feature LOMO feature
% feat = importdata(['feat/CUHK03/cuhk03_' detected_or_labeled '_lomo.mat']);
% feat = single(feat.descriptors);
%% train info
label_train = labels(train_idx);
cam_train = camId(train_idx);
train_feature = feat(:, train_idx);
%% test info
galFea = feat(:, gallery_idx);
probFea = feat(:, query_idx);
label_gallery = labels(gallery_idx);
label_query = labels(query_idx);
cam_gallery = camId(gallery_idx);
cam_query = camId(query_idx);

%% normalize
sum_val = sqrt(sum(galFea.^2));
for n = 1:size(galFea, 1)
    galFea(n, :) = galFea(n, :)./sum_val;
end

sum_val = sqrt(sum(probFea.^2));
for n = 1:size(probFea, 1)
    probFea(n, :) = probFea(n, :)./sum_val;
end

sum_val = sqrt(sum(train_feature.^2));
for n = 1:size(train_feature, 1)
    train_feature(n, :) = train_feature(n, :)./sum_val;
end

%% Euclidean
%dist_eu = pdist2(galFea', probFea');
my_pdist2 = @(A, B) sqrt( bsxfun(@plus, sum(A.^2, 2), sum(B.^2, 2)') - 2*(A*B'));
dist_eu = my_pdist2(galFea', probFea');
[CMC_eu, map_eu, ~, ~] = evaluation(dist_eu, label_gallery, label_query, cam_gallery, cam_query);

fprintf(['The IDE (' netname ') + Euclidean performance:\n']);
fprintf(' Rank1,  mAP\n');
fprintf('%5.2f%%, %5.2f%%\n\n', CMC_eu(1) * 100, map_eu(1)*100);

%% Euclidean + re-ranking
query_num = size(probFea, 2);
dist_eu_re = re_ranking( [probFea galFea], 1, 1, query_num, k1, k2, lambda);
[CMC_eu_re, map_eu_re, ~, ~] = evaluation(dist_eu_re, label_gallery, label_query, cam_gallery, cam_query);

fprintf(['The IDE (' netname ') + Euclidean + re-ranking performance:\n']);
fprintf(' Rank1,  mAP\n');
fprintf('%5.2f%%, %5.2f%%\n\n', CMC_eu_re(1) * 100, map_eu_re(1)*100);

%% train and test XQDA
[train_sample1, train_sample2, label1, label2] = gen_train_sample_xqda(label_train, cam_train, train_feature); % generate pairwise training features for XQDA
[W, M_xqda] = XQDA(train_sample1, train_sample2, label1, label2);% train XQDA
% Calculate distance
dist_xqda = MahDist(M_xqda, galFea' * W, probFea' * W); % calculate MahDist between query and gallery boxes with learnt subspace. Smaller distance means larger similarity
[CMC_xqda, map_xqda, ~, ~] = evaluation(dist_xqda, label_gallery, label_query, cam_gallery, cam_query);

fprintf(['The IDE (' netname ') + XQDA performance:\n']);
fprintf(' Rank1,  mAP\n');
fprintf('%5.2f%%, %5.2f%%\n\n', CMC_xqda(1) * 100, map_xqda(1)*100);
%% XQDA + re-ranking
query_num = size(probFea, 2);
dist_xqda_re = re_ranking( [probFea galFea], M_xqda, W, query_num, k1, k2, lambda);
[CMC_xqda_re, map_xqda_re, ~, ~] = evaluation(dist_xqda_re, label_gallery, label_query, cam_gallery, cam_query);

fprintf(['The IDE (' netname ') + XQDA + re-ranking performance:\n']);
fprintf(' Rank1,  mAP\n');
fprintf('%5.2f%%, %5.2f%%\n\n', CMC_xqda_re(1) * 100, map_xqda_re(1)*100);
