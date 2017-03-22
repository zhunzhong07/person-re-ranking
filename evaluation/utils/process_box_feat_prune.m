function video_feat = process_box_feat_prune(box_feat, video_info, prune, lp, pyramid)

nVideo = size(video_info, 1);
video_feat = zeros(size(box_feat, 1) * (pyramid), nVideo);
for n = 1:nVideo
    feature_set = box_feat(:, video_info(n, 1):video_info(n, 2));
    feature_set = double(feature_set);
    
    if prune ~= 0
        %% prune video track ****************
        prune_feat = feature_set;
        
        sum_val = sqrt(sum(prune_feat.^2));
        for qqq = 1:size(prune_feat, 1)
            prune_feat(qqq, :) = prune_feat(qqq, :)./sum_val;
        end
        
        dist_prune = pdist2(prune_feat', prune_feat');
        avg_sum = sum(dist_prune, 2);
        avg = mean(avg_sum);
        
        feature_set = feature_set(:, avg_sum(:, 1) <= avg*prune);
        
    end
    %% pyramid pooling
    if pyramid ~= 1
        
        video_len = size(feature_set, 2);
        
        video_feat(1: 1024, n) = sum(feature_set.^lp, 2).^(1/lp) * (1/size(feature_set, 2)).^(1/lp);
        
        py_2_1 = round(video_len/4);
        py_2_2 = 2 *round(video_len/4);
        py_2_3 = 3 * round(video_len/4);
        
        %% pyramid 2
        if video_len <= 20
            
            video_feat(1025 : 2048, n) = sum(feature_set.^lp, 2).^(1/lp) * (1/size(feature_set, 2)).^(1/lp);
            video_feat(2049 : 3072, n) = sum(feature_set.^lp, 2).^(1/lp) * (1/size(feature_set, 2)).^(1/lp);
            video_feat(3073 : 4096, n) = sum(feature_set.^lp, 2).^(1/lp) * (1/size(feature_set, 2)).^(1/lp);
            video_feat(4097 : 5120, n) = sum(feature_set.^lp, 2).^(1/lp) * (1/size(feature_set, 2)).^(1/lp);
            
        else
            feature_set_2_1 = feature_set(:, 1: py_2_1);
            feature_set_2_2 = feature_set(:, py_2_1  : py_2_2);
            feature_set_2_3 = feature_set(:, py_2_2 : py_2_3);
            feature_set_2_4 = feature_set(:, py_2_3 : end);
            video_feat(1025 : 2048, n) = sum(feature_set_2_1.^lp, 2).^(1/lp) * (1/size(feature_set_2_1, 2)).^(1/lp);
            video_feat(2049 : 3072, n) = sum(feature_set_2_2.^lp, 2).^(1/lp) * (1/size(feature_set_2_2, 2)).^(1/lp);
            video_feat(3073 : 4096, n) = sum(feature_set_2_3.^lp, 2).^(1/lp) * (1/size(feature_set_2_3, 2)).^(1/lp);
            video_feat(4097 : 5120, n) = sum(feature_set_2_4.^lp, 2).^(1/lp) * (1/size(feature_set_2_4, 2)).^(1/lp);
        end
        
    else
        %% lp-norm pooling
        feature_set = (feature_set).^lp;
        video_feat(:, n) = sum(feature_set, 2).^(1/lp) * (1/size(feature_set, 2)).^(1/lp);
        
    end
    
    %% **********************
    % video_feat(:, n) = max(feature_set, [], 2); % max pooling
    %     video_feat(:, n) = mean(feature_set, 2); % avg pooling
end

%%% normalize train and test features
sum_val = sqrt(sum(video_feat.^2));
for n = 1:size(video_feat, 1)
    video_feat(n, :) = video_feat(n, :)./sum_val;
end