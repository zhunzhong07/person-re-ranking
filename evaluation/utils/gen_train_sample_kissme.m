function [idxa,idxb,flag] = gen_train_sample_kissme(label_train, cam_train)

% generate ground truth pairs for training
uni_label = unique(label_train);
idxa = []; % index of the first image in a pair
idxb = []; % index of the second image in a pair
flag = []; % indicate whether two images are of the same identity
for n = 1:length(uni_label)
    curr_label = uni_label(n);
    pos = find(label_train == uni_label(n));
    if length(pos) == 1
        pos = [pos, pos];
    end
    comb = nchoosek(pos,2);
    idxa = [idxa; comb(:, 1)];
    idxb = [idxb; comb(:, 2)];
end
% remove pairs from the same camera
cam1 = cam_train(idxa);
cam2 = cam_train(idxb);
Eq_pos = find(cam1 == cam2);
diff_pos = setdiff(1:length(idxa), Eq_pos);
idxa = idxa(diff_pos);
idxb = idxb(diff_pos);
nPos = length(idxa);
flag = [flag; ones(nPos, 1)];

% generate negative training pairs
nTrainImg = length(label_train);
rand_pos = ceil(rand(150000, 2).*nTrainImg);
ID1 = label_train(rand_pos(:, 1));
ID2 = label_train(rand_pos(:, 2));
Eq_pos = find(ID1 == ID2);
diff_pos = setdiff(1:150000, Eq_pos); % remove pairs of the same identity
rand_pos = rand_pos(diff_pos, :);
cam1 = cam_train(rand_pos(:, 1));
cam2 = cam_train(rand_pos(:, 2));
Eq_pos = find(cam1 == cam2);
diff_pos = setdiff(1:length(rand_pos), Eq_pos);% remove pairs of the same camera

%%%% training image pairs and their ground truth labels %%%%%%%%
idxa = [idxa; rand_pos(diff_pos(1:nPos), 1)];
idxb = [idxb; rand_pos(diff_pos(1:nPos), 2)];
flag = [flag; zeros(nPos, 1)];