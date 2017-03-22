%% Etract IDE features for CUHK03
clear;clc;
addpath('../caffe/matlab/');
addpath(genpath('utils/'));
% load model and creat network
caffe.set_device(0);
caffe.set_mode_gpu();
netname = 'ResNet_50'; % network: CaffeNet  or ResNet_50 or googlenet
detected_or_labeled = 'detected'; %detected or labeled

% set your path to the prototxt and model
model =  ['../models/CUHK03/' netname '/' netname '_test.prototxt'];
weights = ['../output/CUHK03_train/' netname '_IDE_' detected_or_labeled '_iter_75000.caffemodel'];
net = caffe.Net(model, weights, 'test');

if strcmp(netname, 'ResNet_50')
    im_size = 224;
    feat_dim = 2048;
elseif strcmp(netname, 'CaffeNet')
    im_size = 227;
    feat_dim = 1024;
else
    im_size = 227;
    feat_dim = 1024;
end

% mean data
mean_data = importdata('../caffe/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat');
image_mean = mean_data;
off = floor((size(image_mean,1) - im_size)/2)+1;
image_mean = image_mean(off:off+im_size-1, off:off+im_size-1, :);

ef_path = {['data/CUHK03/cuhk03_' detected_or_labeled '/']};

if ~exist('feat/CUHK03/')
    mkdir('feat/CUHK03/')
end

% extract features

img_path = ef_path{1};
img_file = dir([img_path '*.png']);
feat = single(zeros(feat_dim, length(img_file)));

for n = 1:length(img_file)
    if mod(n, 1000) ==0
        fprintf('%d/%d\n',n, length(img_file))
    end
    img_name = [img_path  img_file(n).name];
    im = imread(img_name);
    im = prepare_img( im, image_mean, im_size);
    feat_img = net.forward({im});
    feat(:, n) = single(feat_img{1}(:));
end

save(['feat/CUHK03/'  netname  '_IDE_' detected_or_labeled '.mat'], 'feat');
feat = [];
caffe.reset_all();