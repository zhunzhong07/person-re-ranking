function [ result ] = calcMCMC( M, data, idxa, idxb, idxtest )

dist = sqdist(data(:,idxa(idxtest)), data(:,idxb(idxtest)),M);

result = zeros(1,size(dist,2));
for pairCounter=1:size(dist,2)
    distPair = dist(pairCounter,:);  
    [tmp,idx] = sort(distPair,'ascend');
    result(idx==pairCounter) = result(idx==pairCounter) + 1;
end

tmp = 0;
for counter=1:length(result)
    result(counter) = result(counter) + tmp;
    tmp = result(counter);
end

end

