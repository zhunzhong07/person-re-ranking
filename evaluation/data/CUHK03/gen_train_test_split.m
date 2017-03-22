clc;clear all;close all;

seed = 0;
rng(seed);

train_ID_num = 767;
test_ID_num = 700;

detected_or_labeled = 'detected'; % detected or labeled

load(['cuhk03_config_' detected_or_labeled '.mat']);

uni_label = unique(labels);
uni_label = uni_label(randperm(length(uni_label)));

%% test samples
query_idx = [];
gallery_idx = [];
test_ID = [];
for i = 1:length(uni_label)
    if length(test_ID) < test_ID_num
        id = uni_label(i);
        idx = find(labels == id);
        idx_cam1 = find(labels == id & camId == 1);
        idx_cam2 = find(labels == id & camId == 2);
        if (length(idx_cam1) > 1 & length(idx_cam2) > 1)
            idx_cam1 = idx_cam1(randperm(length(idx_cam1)));
            idx_cam2 = idx_cam2(randperm(length(idx_cam2)));
            query_idx = [query_idx; idx_cam1(1); idx_cam2(1)];
            gallery_idx = [gallery_idx; idx_cam1(2:end); idx_cam2(2:end)];
            test_ID = [test_ID; id];
        else
            continue;
        end
    else
        break;
    end
end
% query_label = labels(query_idx);
% gallery_label = labels(gallery_idx);
% query_cam = camId(query_idx);
% gallery_cam = camId(gallery_idx);

%% train samples
train_ID = setdiff(uni_label, test_ID);
train_idx = [];
for i = 1:length(train_ID)
    id = train_ID(i);
    idx = find(labels == id);
    train_idx = [train_idx; idx];
end
%train_label = labels(train_idx);
%train_cam = camId(train_idx);
query_idx = sort(query_idx, 'ascend');
gallery_idx = sort(gallery_idx, 'ascend');
train_idx = sort(train_idx, 'ascend');

save(['cuhk03_new_protocol_config_' detected_or_labeled '.mat'], 'labels', 'camId', 'train_idx', ...
     'query_idx', 'gallery_idx', 'filelist');

% save(['cuhk03_new_protocol_config_' detected_or_labeled '.mat'], 'labels', 'camId', 'train_idx', ...
%     'train_label', 'train_cam', 'query_idx', 'gallery_idx', 'query_label', ...
%     'gallery_label', 'query_cam', 'gallery_cam', 'filelist');
