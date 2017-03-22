function descriptors = LOMO(images, options)
%% function Descriptors = LOMO(images, options)
% Function for the Local Maximal Occurrence (LOMO) feature extraction
%
% Input:
%   <images>: a set of n RGB color images. Size: [h, w, 3, n]
%   [optioins]: optional parameters. A structure containing any of the
%   following fields:
%       numScales: number of pyramid scales in feature extraction. Default: 3
%       blockSize: size of the sub-window for histogram counting. Default: 10
%       blockStep: sliding step for the sub-windows. Default: 5
%       hsvBins: number of bins for HSV channels. Default: [8,8,8]
%       tau: the tau parameter in SILTP. Default: 0.3
%       R: the radius paramter in SILTP. Specify multiple values for multiscale SILTP. Default: [3, 5]
%       numPoints: number of neiborhood points for SILTP encoding. Default: 4
%   The above default parameters are good for 128x48 and 160x60 person
%   images. You may need to adjust the numScales, blockSize, and R parameters
%   for other smaller or higher resolutions.
%
% Output:
%   descriptors: the extracted LOMO descriptors. Size: [d, n]
% 
% Example:
%     I = imread('../images/000_45_a.bmp');
%     descriptor = LOMO(I);
%
% Reference:
%   Shengcai Liao, Yang Hu, Xiangyu Zhu, and Stan Z. Li. Person
%   re-identification by local maximal occurrence representation and metric
%   learning. In IEEE Conference on Computer Vision and Pattern Recognition, 2015.
% 
% Version: 1.0
% Date: 2015-04-29
%
% Author: Shengcai Liao
% Institute: National Laboratory of Pattern Recognition,
%   Institute of Automation, Chinese Academy of Sciences
% Email: scliao@nlpr.ia.ac.cn

%% set parameters
numScales = 3;
blockSize = 10;
blockStep = 5;

hsvBins = [8,8,8];
tau = 0.3;
R = [3, 5];
numPoints = 4;

if nargin >= 2
    if isfield(options,'numScales') && ~isempty(options.numScales) && isscalar(options.numScales) && isnumeric(options.numScales) && options.numScales > 0
        numScales = options.numScales;
        fprintf('numScales = %d.\n', numScales);
    end
    if isfield(options,'blockSize') && ~isempty(options.blockSize) && isscalar(options.blockSize) && isnumeric(options.blockSize) && options.blockSize > 0
        blockSize = options.blockSize;
        fprintf('blockSize = %d.\n', blockSize);
    end
    if isfield(options,'blockStep') && ~isempty(options.blockStep) && isscalar(options.blockStep) && isnumeric(options.blockStep) && options.blockStep > 0
        blockStep = options.blockStep;
        fprintf('blockStep = %d.\n', blockStep);
    end
    if isfield(options,'hsvBins') && ~isempty(options.hsvBins) && isvector(options.blockStep) && isnumeric(options.hsvBins) && length(options.hsvBins) == 3 && all(options.hsvBins > 0)
        hsvBins = options.hsvBins;
        fprintf('hsvBins = [%d, %d, %d].\n', hsvBins);
    end
    if isfield(options,'tau') && ~isempty(options.tau) && isscalar(options.tau) && isnumeric(options.tau) && options.tau > 0
        tau = options.tau;
        fprintf('tau = %g.\n', tau);
    end
    if isfield(options,'R') && ~isempty(options.R) && isnumeric(options.R) && all(options.R > 0)
        R = options.R;
        fprintf('R = %d.\n', R);
    end
    if isfield(options,'numPoints') && ~isempty(options.numPoints) && isscalar(options.numPoints) && isnumeric(options.numPoints) && options.numPoints > 0
        numPoints = options.numPoints;
        fprintf('numPoints = %d.\n', numPoints);
    end
end

t0 = tic;

%% extract Joint HSV based LOMO descriptors
fea1 = PyramidMaxJointHist( images, numScales, blockSize, blockStep, hsvBins );

%% extract SILTP based LOMO descriptors
fea2 = [];

for i = 1 : length(R)
    fea2 = [fea2; PyramidMaxSILTPHist( images, numScales, blockSize, blockStep, tau, R(i), numPoints )]; %#ok<AGROW>
end

%% finishing
descriptors = [fea1; fea2];
clear Fea1 Fea2

feaTime = toc(t0);
meanTime = feaTime / size(images, 4);
% fprintf('LOMO feature extraction finished. Running time: %.3f seconds in total, %.3f seconds per image.\n', feaTime, meanTime);
end


function descriptors = PyramidMaxJointHist( oriImgs, numScales, blockSize, blockStep, colorBins )
%% PyramidMaxJointHist: HSV based LOMO representation

    if nargin == 1
        numScales = 3;
        blockSize = 10;
        blockStep = 5;
        colorBins = [8,8,8];
    end

    totalBins = prod(colorBins);
    numImgs = size(oriImgs, 4);
    images = zeros(size(oriImgs));

    % color transformation
    for i = 1 : numImgs
        I = oriImgs(:,:,:,i);
        I = Retinex(I);

        I = rgb2hsv(I);
        I(:,:,1) = min( floor( I(:,:,1) * colorBins(1) ), colorBins(1)-1 );
        I(:,:,2) = min( floor( I(:,:,2) * colorBins(2) ), colorBins(2)-1 );
        I(:,:,3) = min( floor( I(:,:,3) * colorBins(3) ), colorBins(3)-1 );
        images(:,:,:,i) = I; % HSV
    end

    minRow = 1;
    minCol = 1;
    descriptors = [];

    % Scan multi-scale blocks and compute histograms
    for i = 1 : numScales
        patterns = images(:,:,3,:) * colorBins(2) * colorBins(1) + images(:,:,2,:)*colorBins(1) + images(:,:,1,:); % HSV
        patterns = reshape(patterns, [], numImgs);
        
        height = size(images, 1);
        width = size(images, 2);
        maxRow = height - blockSize + 1;
        maxCol = width - blockSize + 1;

        [cols,rows] = meshgrid(minCol:blockStep:maxCol, minRow:blockStep:maxRow); % top-left positions
        cols = cols(:);
        rows = rows(:);
        numBlocks = length(cols);
        numBlocksCol = length(minCol:blockStep:maxCol);

        if numBlocks == 0
            break;
        end

        offset = bsxfun(@plus, (0 : blockSize-1)', (0 : blockSize-1) * height); % offset to the top-left positions. blockSize-by-blockSize
        index = sub2ind([height, width], rows, cols);
        index = bsxfun(@plus, offset(:), index'); % (blockSize*blockSize)-by-numBlocks
        patches = patterns(index(:), :); % (blockSize * blockSize * numBlocks)-by-numImgs
        patches = reshape(patches, [], numBlocks * numImgs); % (blockSize * blockSize)-by-(numBlocks * numChannels * numImgs)

        fea = hist(patches, 0 : totalBins-1); % totalBins-by-(numBlocks * numImgs)
        fea = reshape(fea, [totalBins, numBlocks / numBlocksCol, numBlocksCol, numImgs]);
        fea = max(fea, [], 3);
        fea = reshape(fea, [], numImgs);

        descriptors = [descriptors; fea]; %#ok<AGROW>

        if i < numScales
            images = ColorPooling(images, 'average');
        end
    end

    descriptors = log(descriptors + 1);
    descriptors = normc(descriptors);
end


function outImages = ColorPooling(images, method)
    [height, width, numChannels, numImgs] = size(images);
    outImages = images;
    
    if mod(height, 2) == 1
        outImages(end, :, :, :) = [];
        height = height - 1;
    end
    
    if mod(width, 2) == 1
        outImages(:, end, :, :) = [];
        width = width - 1;
    end
    
    if height == 0 || width == 0
        error('Over scaled image: height=%d, width=%d.', height, width);
    end
    
    height = height / 2;
    width = width / 2;
    
    outImages = reshape(outImages, 2, height, 2, width, numChannels, numImgs);
    outImages = permute(outImages, [2, 4, 5, 6, 1, 3]);
    outImages = reshape(outImages, height, width, numChannels, numImgs, 2*2);
    
    if strcmp(method, 'average')
        outImages = floor(mean(outImages, 5));
    else if strcmp(method, 'max')
            outImages = max(outImages, [], 5);
        else
            error('Error pooling method: %s.', method);
        end
    end
end

function descriptors = PyramidMaxSILTPHist( oriImgs, numScales, blockSize, blockStep, tau, R, numPoints )
%% PyramidMaxSILTPHist: SILTP based LOMO representation

    if nargin == 1
        numScales = 3;
        blockSize = 10;
        blockStep = 5;
        tau = 0.3;
        R = 5;
        numPoints = 4;
    end

    totalBins = 3^numPoints;

    [imgHeight, imgWidth, ~, numImgs] = size(oriImgs);
    images = zeros(imgHeight,imgWidth, numImgs);

    % Convert gray images
    for i = 1 : numImgs
        I = oriImgs(:,:,:,i);
        I = rgb2gray(I);
        images(:,:,i) = double(I) / 255;
    end

    minRow = 1;
    minCol = 1;
    descriptors = [];

    % Scan multi-scale blocks and compute histograms
    for i = 1 : numScales
        height = size(images, 1);
        width = size(images, 2);
        
        if width < R * 2 + 1
            fprintf('Skip scale R = %d, width = %d.\n', R, width);
            continue;
        end
        
        patterns = SILTP(images, tau, R, numPoints);
        patterns = reshape(patterns, [], numImgs);
        
        maxRow = height - blockSize + 1;
        maxCol = width - blockSize + 1;

        [cols,rows] = meshgrid(minCol:blockStep:maxCol, minRow:blockStep:maxRow); % top-left positions
        cols = cols(:);
        rows = rows(:);
        numBlocks = length(cols);
        numBlocksCol = length(minCol:blockStep:maxCol);

        if numBlocks == 0
            break;
        end

        offset = bsxfun(@plus, (0 : blockSize-1)', (0 : blockSize-1) * height); % offset to the top-left positions. blockSize-by-blockSize
        index = sub2ind([height, width], rows, cols);
        index = bsxfun(@plus, offset(:), index'); % (blockSize*blockSize)-by-numBlocks
        patches = patterns(index(:), :); % (blockSize * blockSize * numBlocks)-by-numImgs
        patches = reshape(patches, [], numBlocks * numImgs); % (blockSize * blockSize)-by-(numBlocks * numChannels * numImgs)
        
        fea = hist(patches, 0:totalBins-1); % totalBins-by-(numBlocks * numImgs)
        fea = reshape(fea, [totalBins, numBlocks / numBlocksCol, numBlocksCol, numImgs]);
        fea = max(fea, [], 3);
        fea = reshape(fea, [], numImgs);
        
        descriptors = [descriptors; fea]; %#ok<AGROW>

        if i < numScales
            images = Pooling(images, 'average');
        end
    end

    descriptors = log(descriptors + 1);
    descriptors = normc(descriptors);
end


function outImages = Pooling(images, method)
    [height, width, numImgs] = size(images);
    outImages = images;
    
    if mod(height, 2) == 1
        outImages(end, :, :) = [];
        height = height - 1;
    end
    
    if mod(width, 2) == 1
        outImages(:, end, :) = [];
        width = width - 1;
    end
    
    if height == 0 || width == 0
        error('Over scaled image: height=%d, width=%d.', height, width);
    end
    
    height = height / 2;
    width = width / 2;
    
    outImages = reshape(outImages, 2, height, 2, width, numImgs);
    outImages = permute(outImages, [2, 4, 5, 1, 3]);
    outImages = reshape(outImages, height, width, numImgs, 2*2);
    
    if strcmp(method, 'average')
        outImages = mean(outImages, 4);
    else if strcmp(method, 'max')
            outImages = max(outImages, [], 4);
        else
            error('Error pooling method: %s.', method);
        end
    end
end
