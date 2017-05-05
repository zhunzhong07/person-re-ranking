function [ final_dist ] = re_ranking( feat, M, W, query_num, k1, k2, lambda)
% k-reciprocal re-ranking

%% initial ranking list
original_dist = MahDist(M, feat' * W, feat' * W);
[~, initial_rank] = sort(original_dist, 2, 'ascend');
gallery_num = size(original_dist,2);
%% compute k-reciprocal feature
V = zeros(size(original_dist), 'single');
original_dist = original_dist./ repmat(max(original_dist, [], 2), 1, size(original_dist, 2));
for i = 1:size(original_dist, 1)
    %% k-reciprocal neighbors
    forward_k_neigh_index = initial_rank(i, 1: k1 + 1);
    backward_k_neigh_index  = initial_rank(forward_k_neigh_index, 1: k1+1);
    [fi, ~, ~]= find(backward_k_neigh_index == i);
    k_reciprocal_index  = forward_k_neigh_index(fi);
    k_reciprocal_expansion_index = k_reciprocal_index;
    for j = 1: length(k_reciprocal_index)
        candidate = k_reciprocal_index(j);
        candidate_forward_k_neigh_index = initial_rank(candidate, 1: round((k1+1)/2));
        candidate_backward_k_neigh_index = initial_rank(candidate_forward_k_neigh_index, 1: round((k1+1)/2));
        [fi_candidate, ~, ~]= find(candidate_backward_k_neigh_index == candidate);
        candidate_k_reciprocal_index = candidate_forward_k_neigh_index(fi_candidate);
        if length(intersect(k_reciprocal_index, candidate_k_reciprocal_index)) > 2/3*length(candidate_k_reciprocal_index)
            k_reciprocal_expansion_index = [k_reciprocal_expansion_index candidate_k_reciprocal_index];
        end
    end
    k_reciprocal_expansion_index = unique(k_reciprocal_expansion_index);
    %% feature encoding
    weight = exp(-original_dist(i, k_reciprocal_expansion_index));
    V(i, k_reciprocal_expansion_index) = weight/sum(weight);
end
%% local query expansion
if k2 ~=1
    V_qe = zeros(size(V), 'single');
    for i = 1:size(V, 1)
        V_qe(i, :) = single(mean(V(initial_rank(i, 1:k2), :), 1));
    end
    V = V_qe;
    V_qe = [];
end

%% Inverted Index 
% Inpsired by Song Bai, Xiang Bai,
% Sparse Contextual Activation for Efficient Visual Re-ranking, TIP, 2016.
% We apply the inverted index to quickly compute the Jaccard distance.

invIndex = cell(gallery_num, 1);
for i = 1:gallery_num
    invIndex{i} = find(V(:, i) ~=0);
end

jaccard_dist = zeros(size(original_dist), 'single');

for i = 1:query_num 
    temp_min = zeros(1, gallery_num, 'single');
    indNonZero = find( V( i, : ) ~= 0 );
    indImages = invIndex( indNonZero );
    for j = 1 : length( indNonZero )
        temp_min( 1, indImages{j} ) = temp_min( 1, indImages{j} )...
            + single( min( V(i, indNonZero(j)), V(indImages{j}, indNonZero(j)) ) )';
    end
    jaccard_dist(i, :) = bsxfun(@minus, 1, temp_min./(2 - temp_min)); 
end

final_dist = jaccard_dist*(1-lambda) + original_dist*lambda;
final_dist = final_dist(1:query_num,query_num+1:end)';

end