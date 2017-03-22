function [train_sample1, train_sample2, label1, label2] = gen_train_sample_xqda(label, cam, train_feat)
 
uni_label = unique(label);
ind1 = [];
ind2 = [];
label1 = [];
label2 = [];
for n = 1:length(uni_label)
    pos = find(label == uni_label(n));
    
    perm = randperm(length(pos));
    tmp1 = pos(perm(1:floor(length(pos)/2)));
    tmp2 = pos(perm(floor(length(pos)/2)+1:floor(length(pos)/2)*2));
    cam1 = cam(tmp1);
    cam2 = cam(tmp2);
    pos2 = find(cam1~=cam2);
    tmp1 = tmp1(pos2);
    tmp2 = tmp2(pos2);
    ind1 = [ind1; tmp1];
    ind2 = [ind2; tmp2];
    label1 = [label1; repmat(uni_label(n), [length(tmp1), 1])];
    label2 = [label2; repmat(uni_label(n), [length(tmp2), 1])];
end
train_sample1 = train_feat(:, ind1)';
train_sample2 = train_feat(:, ind2)';