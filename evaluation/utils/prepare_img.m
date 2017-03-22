function [ im_data ] = prepare_img( im_data, mean_data, im_size )
%PREPARE_IMG Summary of this function goes here
%   Detailed explanation goes here
IMAGE_DIM = im_size;
% Convert an image returned by Matlab's imread to im_data in caffe's data
% format: W x H x C with BGR channels
im_data = im_data(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
im_data = permute(im_data, [2, 1, 3]);  % flip width and height
im_data = single(im_data);  % convert from uint8 to single
im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
im_data = im_data - mean_data;  % subtract mean_data (already in W x H x C, BGR)
end

