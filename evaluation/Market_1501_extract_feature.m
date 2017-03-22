%% Etract IDE features
clear;clc;
addpath('../caffe/matlab/');
addpath(genpath('utils/'));
% load model and creat network
caffe.set_device(0);
caffe.set_mode_gpu();
netname = 'ResNet_50'; % network: CaffeNet  or ResNet_50 or googlenet

% set your path to the prototxt and model
model =  ['../models/Market-1501/' netname '/' netname '_test.prototxt'];
weights = ['../output/Market-1501_train/' netname '_IDE_iter_50000.caffemodel']; 
net = caffe.Net(model, weights, 'test');

if strcmp(netname, 'ResNet_50')
    im_size = 224;
    feat_dim = 2048;
elseif strcmp(netname, 'CaffeNet')
    im_size = 227;
    feat_dim = 4096;
else
    im_size = 227;
    feat_dim = 1024;
end

% mean data
mean_data = importdata('../caffe/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat');
image_mean = mean_data;
off = floor((size(image_mean,1) - im_size)/2)+1;
image_mean = image_mean(off:off+im_size-1, off:off+im_size-1, :);

ef_path = {'data/Market-1501/bounding_box_train/', 'data/Market-1501/bounding_box_test/', 'data/Market-1501/query/'};
ef_name = {'train', 'test', 'query'};

if ~exist('feat/Market-1501/') 
    mkdir('featMarket-1501/')    
end

% extract features
for i = 1:3
    img_path = ef_path{i};
    img_file = dir([img_path '*.jpg']);
    feat = single(zeros(feat_dim, length(img_file)));
    
    for n = 1:length(img_file)   
        if mod(n, 1000) ==0
            fprintf('%s: %d/%d\n',ef_name{i}, n, length(img_file))
        end
        img_name = [img_path  img_file(n).name];
        im = imread(img_name);
        im = prepare_img( im, image_mean, im_size);
        feat_img = net.forward({im});
        feat(:, n) = single(feat_img{1}(:));
    end
    
    save(['feat/Market-1501/'  netname  '_IDE_' ef_name{i} '.mat'], 'feat');
    feat = [];
end

caffe.reset_all();
