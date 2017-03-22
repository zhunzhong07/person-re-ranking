function [ mAP, CMC ] = calcmAP( M, data_test, data_query, testID, testCAM, queryID, queryCAM )
dist = sqdist(data_test, data_query, M);
ap = zeros(size(dist, 2), 1);
CMC = zeros(size(dist, 2), size(dist, 1));
for k = 1:size(dist, 2)
    % find groudtruth index (good and junk)
    good_index = intersect(find(testID == queryID(k)), find(testCAM ~= queryCAM(k)))';
    junk_index1 = find(testID == -1);
    junk_index2 = intersect(find(testID == queryID(k)), find(testCAM == queryCAM(k)));
    junk_index = [junk_index1; junk_index2]';
    score = dist(:, k);
    [~, index] = sort(score, 'ascend');% the higher, the better
    [ap(k), CMC(k, :)] = compute_AP(good_index, junk_index, index);% see compute_AP
end
%% cmc and mAP
CMC = mean(CMC);
mAP = mean(ap);

end

