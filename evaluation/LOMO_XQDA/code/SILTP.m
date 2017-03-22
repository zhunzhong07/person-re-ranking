function J = SILTP(I, tau, R, numPoints, encoder)
%% function J = SILTP(I, tau, R, numPoints, encoder)
%  Returns scale invariant local ternary patterns of image I (or multi images).
%
%  I: input image, or multi images arranged in 3-d arrays. The size of each
%  image must be at least (2R+1)*(2R+1) pixels.
%  tau: the scale parameter (>0) of SILTP. The default value is 0.03.
%  R: the radius parameter of SILTP. It should be a positive integer (default is 1).
%  numPoints: the number of neighboring pixels, which can be 4 or 8 (default is 4).
%      Note that in this function if numPoints=8, R actually means 8 points
%      in a (2R+1)*(2R+1) square rectangle, instead of a circle with radius R. 
%      This is in consideration of faster computation.
%  encoder: the way of encoding. The value can be 0 or 1. Default is 0.
%      0: encoded as 0 ~ 3^numPoints-1, suitable for histogram calculation.
%      1: encoded as 0 ~ 2^(2*numPoints), as the way in the reference
%      paper, suitable for calculating hamming distance.
%  J: output of the encoded image(s), which is the same size as I.
%
%  Parameter selection:
%        There are three parameters, tau, R, and numPoints. The default parameter 
%     values are tau=0.03, R=1, and numPoints=4. 
%        numPoints=4 results in lower feature dimensions. numPoints=8 results in 
%     better description but with longer feature length.
%        tau can be selected from 0.004 to 0.15. Smaller tau results in better
%     discrimination but would be more sensitive to noise. Larger tau results in
%     better robustness to noise but is less discriminative. Generally tau in [0.01,0.08] 
%     gives a good balance between discrimination and robustness to noise.
%        R is the neighborhood size or the scale parameter like in LBP. Generally,
%     smaller R (e.g. R=1) results in better discrimination of fine details of image.
%     Larger R can capture larger scale of structure, but is less discriminative. 
%     With this function, it is also convenient to form a multiscale representation
%     by using several R values together and concatenating the feature vector.
%
%  Vertion 1.2
%
%  Written by: 
%     Shengcai Liao, Center for Biometric and Security Research (CBSR) &
%     National Laboratory of Pattern Recognition (NLPR), 
%     Institute of Automation, Chinese Academy of Sciences (CASIA)

%  Email: scliao@nlpr.ia.ac.cn
% 
%  Reference:
%     Shengcai Liao, Guoying Zhao, Vili Kellokumpu, Matti Pietikäinen, and Stan Z. Li. 
%      “Modeling Pixel Process with Scale Invariant Local Patterns for Background Subtraction in Complex Scenes”. 
%      In CVPR 2010, San Francisco, CA, USA, June 13-18, 2010.
% 
% ----------------------------------
% Copyright (c) 2010 Shengcai Liao
% ----------------------------------

%% set default parameters
if nargin < 5
    encoder = 0;
    if nargin < 4
        numPoints = 4;
        if nargin < 3
            R = 1;
            if nargin < 2
                tau = 0.03;
            end
        end
    end
end

%% check parameters
if tau <= 0 || floor(R) ~= R || R < 1 || ~(numPoints==4 || numPoints==8) || ~(encoder == 0 || encoder == 1)
    help SILTP;
    error('Error parameter values!');
end

%% check image(s) size
[h, w, n] = size(I);
if h < 2*R+1 || w < 2*R+1
    error('Too small image or too large R!');
end

%% put the image(s) in a larger container
I0 = zeros(h+2*R, w+2*R, n);
I0(R+1:end-R, R+1:end-R, :) = double(I);

%% replicate border image pixels to the outer area
I0(1:R,:,:) = repmat(I0(R+1,:,:), [R,1,1]);
I0(end-R+1:end,:,:) = repmat(I0(end-R,:,:), [R,1,1]);
I0(:,1:R,:) = repmat(I0(:,R+1,:), [1,R,1]);
I0(:,end-R+1:end,:) = repmat(I0(:,end-R,:), [1,R,1]);

%% copy image(s) in specified directions
I1 = I0(R+1:end-R, 2*R+1:end, :);
I3 = I0(1:end-2*R, R+1:end-R, :);
I5 = I0(R+1:end-R, 1:end-2*R, :);
I7 = I0(2*R+1:end, R+1:end-R, :);

if numPoints == 8
    I2 = I0(1:end-2*R, 2*R+1:end, :);
    I4 = I0(1:end-2*R, 1:end-2*R, :);
    I6 = I0(2*R+1:end, 1:end-2*R, :);
    I8 = I0(2*R+1:end, 2*R+1:end, :);
end

%% compute the upper and lower range
L = (1-tau) * I;
U = (1+tau) * I;

%% compute the scale invariant local ternary patterns
if encoder == 0
    if numPoints == 4
        J = (I1 < L) + (I1 > U) * 2 + ((I3 < L) + (I3 > U) * 2) * 3 + ((I5 < L) + (I5 > U) * 2) * 9 + ((I7 < L) + (I7 > U) * 2) * 27;
    else
        J = (I1 < L) + (I1 > U) * 2 + ((I2 < L) + (I2 > U) * 2) * 3 + ((I3 < L) + (I3 > U) * 2) * 3^2 + ((I4 < L) + (I4 > U) * 2) * 3^3 + ...
             + ((I5 < L) + (I5 > U) * 2) * 3^4 + ((I6 < L) + (I6 > U) * 2) * 3^5 + ((I7 < L) + (I7 > U) * 2) * 3^6 + ((I8 < L) + (I8 > U) * 2) * 3^7;
    end
else
    if numPoints == 4
        J = (I1 > U) + (I1 < L) * 2 + (I3 > U) * 2^2 + (I3 < L) * 2^3 + (I5 > U) * 2^4 + (I5 < L) * 2^5 + (I7 > U) * 2^6 + (I7 < L) * 2^7;
    else
        J = (I1 > U) + (I1 < L) * 2 + (I2 > U) * 2^2 + (I2 < L) * 2^3 + (I3 > U) * 2^4 + (I3 < L) * 2^5 + (I4 > U) * 2^6 + (I4 < L) * 2^7 + ...
            (I5 > U) * 2^8 + (I5 < L) * 2^9 + (I6 > U) * 2^10 + (I6 < L) * 2^11 + (I7 > U) * 2^12 + (I7 < L) * 2^13 + (I8 > U) * 2^14 + (I8 < L) * 2^15;
    end
end
